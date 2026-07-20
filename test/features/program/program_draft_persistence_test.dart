import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_builder_controller.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('saves draft snapshots without mutating earlier versions', () async {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(
      programName: 'Strength Base',
      firstDayName: 'Upper A',
    );
    controller.addExerciseToSelectedDay('barbell_bench_press');
    controller.updateSetCount(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      setCount: 2,
    );

    await controller.saveDraftSnapshot();

    var draft = container.read(programBuilderControllerProvider).draft!;
    final programId = draft.programId!;
    final firstVersionId = draft.latestVersionId!;
    expect(draft.lifecycle, ProgramDraftLifecycle.savedDraft);
    expect(draft.latestVersionNumber, 1);

    final repository = container.read(programRepositoryProvider);
    final profile = await container
        .read(profileRepositoryProvider)
        .getProfile(localProgramProfileId);
    final programs = await repository
        .watchPrograms(localProgramProfileId)
        .firstWhere((items) => items.isNotEmpty);
    final firstTrainingDays = await repository
        .watchTrainingDays(firstVersionId)
        .firstWhere((items) => items.isNotEmpty);
    final firstPrescription = await repository
        .watchPrescription(firstVersionId)
        .firstWhere((items) => items.isNotEmpty);

    expect(profile, isNotNull);
    expect(programs.single.lifecycle, ProgramLifecycle.draft);
    expect(firstTrainingDays.single.name, 'Upper A');
    expect(firstPrescription, hasLength(2));
    expect(firstPrescription.first.minimumRepetitions, 8);
    expect(firstPrescription.first.maximumRepetitions, 10);

    controller.setRepetitionMode(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      mode: ProgramRepetitionMode.fixed,
    );
    controller.updateFixedRepetitions(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      repetitions: 5,
    );
    await controller.saveDraftSnapshot();

    draft = container.read(programBuilderControllerProvider).draft!;
    final secondVersionId = draft.latestVersionId!;
    final versions = await repository
        .watchVersions(programId)
        .firstWhere((items) => items.length == 2);
    final unchangedFirstPrescription = await repository
        .watchPrescription(firstVersionId)
        .firstWhere((items) => items.isNotEmpty);
    final secondPrescription = await repository
        .watchPrescription(secondVersionId)
        .firstWhere((items) => items.isNotEmpty);

    expect(versions.map((version) => version.versionNumber).toList(), [2, 1]);
    expect(unchangedFirstPrescription.first.minimumRepetitions, 8);
    expect(unchangedFirstPrescription.first.maximumRepetitions, 10);
    expect(secondPrescription.first.minimumRepetitions, 5);
    expect(secondPrescription.first.maximumRepetitions, 5);
  });

  test('saves empty editable program shells as draft snapshots', () async {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(programName: 'Starter', firstDayName: 'Day 1');

    await controller.saveDraftSnapshot();

    final draft = container.read(programBuilderControllerProvider).draft!;
    final repository = container.read(programRepositoryProvider);
    final trainingDays = await repository
        .watchTrainingDays(draft.latestVersionId!)
        .firstWhere((items) => items.isNotEmpty);
    final prescription = await repository
        .watchPrescription(draft.latestVersionId!)
        .first;

    expect(draft.lifecycle, ProgramDraftLifecycle.savedDraft);
    expect(draft.latestVersionNumber, 1);
    expect(trainingDays.single.name, 'Day 1');
    expect(prescription, isEmpty);
  });

  test('publishes one active immutable version at a time', () async {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(
      programName: 'Strength Base',
      firstDayName: 'Upper A',
    );
    controller.addExerciseToSelectedDay('barbell_bench_press');

    await controller.publishImmutableVersion();
    final firstActiveVersionId = container
        .read(programBuilderControllerProvider)
        .draft!
        .latestVersionId!;

    controller.updateRestSeconds(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      restSeconds: 90,
    );
    await controller.publishImmutableVersion();

    final draft = container.read(programBuilderControllerProvider).draft!;
    final repository = container.read(programRepositoryProvider);
    final program = await repository.getProgram(draft.programId!);
    final versions = await repository
        .watchVersions(draft.programId!)
        .firstWhere((items) => items.length == 2);
    final firstActiveVersion = versions.singleWhere(
      (version) => version.id == firstActiveVersionId,
    );
    final activeVersions = versions.where(
      (version) => version.lifecycle == ProgramVersionLifecycle.active,
    );

    expect(draft.lifecycle, ProgramDraftLifecycle.published);
    expect(program?.lifecycle, ProgramLifecycle.active);
    expect(firstActiveVersion.lifecycle, ProgramVersionLifecycle.retired);
    expect(activeVersions, hasLength(1));
    expect(activeVersions.single.versionNumber, 2);
  });

  test(
    'copies persisted programs into a new local draft and archives them',
    () async {
      final controller = container.read(
        programBuilderControllerProvider.notifier,
      );

      controller.createProgram(programName: 'Plan', firstDayName: 'Day 1');
      controller.addExerciseToSelectedDay('barbell_bench_press');
      await controller.saveDraftSnapshot();

      final originalProgramId = container
          .read(programBuilderControllerProvider)
          .draft!
          .programId!;

      controller.copyDraft('Copied Plan');
      var draft = container.read(programBuilderControllerProvider).draft!;

      expect(draft.name, 'Copied Plan');
      expect(draft.lifecycle, ProgramDraftLifecycle.local);
      expect(draft.programId, isNull);
      expect(
        draft.selectedDay!.prescriptionFor('barbell_bench_press'),
        isNotNull,
      );

      await controller.saveDraftSnapshot();
      draft = container.read(programBuilderControllerProvider).draft!;
      expect(draft.programId, isNot(originalProgramId));

      await controller.archiveProgram();
      draft = container.read(programBuilderControllerProvider).draft!;

      final archived = await container
          .read(programRepositoryProvider)
          .getProgram(draft.programId!);

      expect(draft.lifecycle, ProgramDraftLifecycle.archived);
      expect(archived?.lifecycle, ProgramLifecycle.archived);
      expect(archived?.archivedAt, isNotNull);
    },
  );
}
