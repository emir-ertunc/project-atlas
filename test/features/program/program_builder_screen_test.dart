import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(WidgetTester tester, {AppDatabase? database}) async {
    final appDatabase =
        database ?? AppDatabase.forTesting(NativeDatabase.memory());
    if (database == null) {
      addTearDown(appDatabase.close);
    }

    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(appDatabase),
          appLocaleProvider.overrideWithValue(const Locale('en')),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAppWithProgramPersistence(
    WidgetTester tester,
    ProgramDraftPersistenceService persistenceService,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWithValue(const Locale('en')),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
          programDraftPersistenceProvider.overrideWithValue(persistenceService),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openProgramBuilder(WidgetTester tester) async {
    await tester.tap(_navigationLabel('Program'));
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(ProgramScreen.builderTabKey));
    await tester.tap(find.byKey(ProgramScreen.builderTabKey));
    await tester.pump();
    await _pumpUntilFound(
      tester,
      find.byKey(ProgramBuilderRouteScreen.screenKey),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(ProgramBuilderScreen.createProgramButtonKey),
    );
  }

  testWidgets(
    'shows active plan overview, training days, and inbox on Program hub',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await _seedActiveProgram(database, DateTime.utc(2026, 7, 26, 9));

      await pumpApp(tester, database: database);
      await tester.tap(_navigationLabel('Program'));
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(ProgramScreen.activePlanOverviewKey),
      );

      expect(find.text('Strength Base'), findsWidgets);
      expect(find.text('Version 1 · 2 days'), findsOneWidget);
      expect(find.text('2d · 5 sets'), findsOneWidget);
      expect(find.byKey(ProgramScreen.builderTabKey), findsOneWidget);
      expect(find.byKey(ProgramScreen.catalogTabKey), findsOneWidget);
      expect(
        find.byKey(ProgramScreen.recommendationInboxRouteCardKey),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.byKey(ProgramScreen.trainingDayCardKey(0)),
        320,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ProgramScreen.trainingDayCardKey(0)), findsOneWidget);
      expect(find.byKey(ProgramScreen.trainingDayCardKey(1)), findsOneWidget);
      expect(find.text('Upper A'), findsOneWidget);
      expect(find.text('Lower A'), findsOneWidget);
      expect(find.text('Barbell bench press'), findsWidgets);
      expect(find.text('Barbell back squat'), findsWidgets);

      await tester.ensureVisible(
        find.byKey(ProgramScreen.recommendationInboxRouteCardKey),
      );
      await tester.tap(
        find.byKey(ProgramScreen.recommendationInboxRouteCardKey),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(ProgramRecommendationInboxScreen.screenKey),
        findsOneWidget,
      );
      expect(find.text('Review queue'), findsWidgets);
      expect(find.text('0 pending'), findsWidgets);
    },
  );

  testWidgets('creates a local program draft and edits training days', (
    tester,
  ) async {
    await pumpApp(tester);
    await openProgramBuilder(tester);

    expect(find.byKey(ProgramScreen.screenKey), findsOneWidget);
    expect(find.text('Builder'), findsWidgets);
    expect(find.text('Catalog'), findsWidgets);

    await tester.tap(find.byKey(ProgramBuilderScreen.createProgramButtonKey));
    await tester.pump();

    expect(find.byKey(ProgramBuilderScreen.guidedProgressKey), findsOneWidget);
    expect(find.byKey(ProgramBuilderScreen.setupStepKey), findsOneWidget);
    expect(find.byKey(ProgramBuilderScreen.daysStepKey), findsOneWidget);
    expect(find.byKey(ProgramBuilderScreen.exercisesStepKey), findsOneWidget);
    expect(
      find.byKey(ProgramBuilderScreen.prescriptionStepKey),
      findsOneWidget,
    );
    expect(find.byKey(ProgramBuilderScreen.reviewStepKey), findsOneWidget);
    expect(find.text('Step 1/5'), findsWidgets);
    expect(
      find.byKey(ProgramBuilderScreen.programNameFieldKey),
      findsOneWidget,
    );
    expect(find.text('1d · 0 exercises'), findsOneWidget);

    await tester.enterText(
      find.byKey(ProgramBuilderScreen.programNameFieldKey),
      'Hypertrophy block',
    );
    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.addTrainingDayButtonKey),
    );
    await tester.pump();

    expect(
      find.byKey(ProgramBuilderScreen.trainingDayChipKey('day_2')),
      findsOneWidget,
    );
    expect(find.text('2d · 0 exercises'), findsOneWidget);

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.renameSelectedDayButtonKey),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(ProgramBuilderScreen.renameDayFieldKey),
      'Upper A',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await _pumpUntilNotFound(
      tester,
      find.byKey(ProgramBuilderScreen.renameDayFieldKey),
    );

    expect(find.text('Upper A'), findsWidgets);
  });

  testWidgets('adds catalog exercises and changes exercise order', (
    tester,
  ) async {
    await pumpApp(tester);
    await openProgramBuilder(tester);

    await tester.tap(find.byKey(ProgramBuilderScreen.createProgramButtonKey));
    await tester.pump();

    await _addExercise(tester, 'barbell bench press', 'barbell_bench_press');
    await _addExercise(tester, 'barbell back squat', 'barbell_back_squat');

    expect(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_bench_press')),
      findsOneWidget,
    );
    expect(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_back_squat')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(
        ProgramBuilderScreen.moveExerciseDownButtonKey('barbell_bench_press'),
      ),
    );
    await _tapVisible(
      tester,
      find.byKey(
        ProgramBuilderScreen.moveExerciseDownButtonKey('barbell_bench_press'),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_back_squat')),
    );
    final squatTop = tester.getTopLeft(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_back_squat')),
    );
    final benchTop = tester.getTopLeft(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_bench_press')),
    );
    expect(squatTop.dy, lessThan(benchTop.dy));

    await _tapVisible(
      tester,
      find.byKey(
        ProgramBuilderScreen.removeExerciseButtonKey('barbell_bench_press'),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(ProgramBuilderScreen.exerciseRowKey('barbell_bench_press')),
      findsNothing,
    );
    expect(find.text('1d · 1 exercises'), findsOneWidget);
  });
  testWidgets('edits exercise prescription inputs independently', (
    tester,
  ) async {
    await pumpApp(tester);
    await openProgramBuilder(tester);

    await tester.tap(find.byKey(ProgramBuilderScreen.createProgramButtonKey));
    await tester.pump();
    await _addExercise(tester, 'barbell bench press', 'barbell_bench_press');

    var summary = _prescriptionSummaryText(tester, 'barbell_bench_press');
    expect(summary, contains('3 sets'));
    expect(summary, contains('8-10 reps'));
    expect(summary, contains('RIR 2'));
    expect(summary, contains('no load'));
    expect(summary, contains('120 sec'));

    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.setCountFieldKey('barbell_bench_press'),
      '4',
    );
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.minimumRepsFieldKey('barbell_bench_press'),
      '6',
    );
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.maximumRepsFieldKey('barbell_bench_press'),
      '8',
    );
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.targetRirFieldKey('barbell_bench_press'),
      '1',
    );
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.loadFieldKey('barbell_bench_press'),
      '50',
    );
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.restSecondsFieldKey('barbell_bench_press'),
      '90',
    );

    summary = _prescriptionSummaryText(tester, 'barbell_bench_press');
    expect(summary, contains('4 sets'));
    expect(summary, contains('6-8 reps'));
    expect(summary, contains('RIR 1'));
    expect(summary, contains('50 kg'));
    expect(summary, contains('90 sec'));

    await tester.ensureVisible(
      find.byKey(
        ProgramBuilderScreen.targetRirSwitchKey('barbell_bench_press'),
      ),
    );
    await tester.tap(
      find.byKey(
        ProgramBuilderScreen.targetRirSwitchKey('barbell_bench_press'),
      ),
    );
    await tester.pump();

    summary = _prescriptionSummaryText(tester, 'barbell_bench_press');
    expect(summary, contains('6-8 reps'));
    expect(summary, contains('RIR off'));
    expect(
      find.byKey(ProgramBuilderScreen.targetRirFieldKey('barbell_bench_press')),
      findsNothing,
    );

    await tester.ensureVisible(
      find.byKey(
        ProgramBuilderScreen.fixedRepetitionModeKey('barbell_bench_press'),
      ),
    );
    await tester.tap(
      find.byKey(
        ProgramBuilderScreen.fixedRepetitionModeKey('barbell_bench_press'),
      ),
    );
    await tester.pump();
    await _enterPrescriptionText(
      tester,
      ProgramBuilderScreen.fixedRepsFieldKey('barbell_bench_press'),
      '5',
    );

    summary = _prescriptionSummaryText(tester, 'barbell_bench_press');
    expect(summary, contains('5 reps'));
    expect(summary, contains('RIR off'));
  });

  testWidgets('saves, publishes, copies, and archives from lifecycle actions', (
    tester,
  ) async {
    final profileRepository = _MemoryProfileRepository();
    final programRepository = _MemoryProgramRepository();

    await pumpAppWithProgramPersistence(
      tester,
      ProgramDraftPersistenceService(
        profileRepository: profileRepository,
        programRepository: programRepository,
        profileId: localProgramProfileId,
        now: () => DateTime.utc(2026, 7, 20, 12),
      ),
    );
    await openProgramBuilder(tester);

    await tester.tap(find.byKey(ProgramBuilderScreen.createProgramButtonKey));
    await tester.pump();

    expect(_lifecycleStatusText(tester), contains('Draft · unsaved'));

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.saveDraftButtonKey),
    );
    await _pumpUntilLifecycleContains(tester, 'Draft v1');

    expect(_lifecycleStatusText(tester), contains('Draft v1'));

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.publishVersionButtonKey),
    );
    await tester.pumpAndSettle();
    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.publishConfirmButtonKey),
    );
    await _pumpUntilLifecycleContains(tester, 'Active v2');

    expect(_lifecycleStatusText(tester), contains('Active v2'));

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.copyProgramButtonKey),
    );
    await _pumpUntilLifecycleContains(tester, 'Draft · unsaved');

    expect(_lifecycleStatusText(tester), contains('Draft · unsaved'));

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.saveDraftButtonKey),
    );
    await _pumpUntilLifecycleContains(tester, 'Draft v1');

    expect(_lifecycleStatusText(tester), contains('Draft v1'));

    await _tapVisible(
      tester,
      find.byKey(ProgramBuilderScreen.archiveProgramButtonKey),
    );
    await _pumpUntilLifecycleContains(tester, 'Archived v1');

    expect(_lifecycleStatusText(tester), contains('Archived v1'));
  });
}

Future<void> _seedActiveProgram(AppDatabase database, DateTime now) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);

  await container
      .read(profileRepositoryProvider)
      .saveProfile(
        ProfileRecord(
          id: localProgramProfileId,
          unitPreference: UnitPreference.metric,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await container
      .read(programRepositoryProvider)
      .saveProgramSnapshot(
        ProgramRecord(
          id: 'program-1',
          profileId: localProgramProfileId,
          name: 'Strength Base',
          lifecycle: ProgramLifecycle.active,
          createdAt: now,
          updatedAt: now,
        ),
        ProgramVersionRecord(
          id: 'version-1',
          programId: 'program-1',
          versionNumber: 1,
          lifecycle: ProgramVersionLifecycle.active,
          createdAt: now,
          activatedAt: now,
        ),
        [
          ProgramTrainingDayRecord(
            id: 'training-day-0',
            programVersionId: 'version-1',
            trainingDayOrder: 0,
            name: 'Upper A',
            createdAt: now,
          ),
          ProgramTrainingDayRecord(
            id: 'training-day-1',
            programVersionId: 'version-1',
            trainingDayOrder: 1,
            name: 'Lower A',
            createdAt: now,
          ),
        ],
        [
          for (var index = 0; index < 3; index += 1)
            _prescribedSet(
              now,
              id: 'upper-bench-$index',
              trainingDayOrder: 0,
              exerciseId: 'barbell_bench_press',
              exerciseOrder: 0,
              setOrder: index,
            ),
          for (var index = 0; index < 2; index += 1)
            _prescribedSet(
              now,
              id: 'lower-squat-$index',
              trainingDayOrder: 1,
              exerciseId: 'barbell_back_squat',
              exerciseOrder: 0,
              setOrder: index,
            ),
        ],
        retireActiveVersions: true,
      );
}

PrescribedSetRecord _prescribedSet(
  DateTime now, {
  required String id,
  required int trainingDayOrder,
  required String exerciseId,
  required int exerciseOrder,
  required int setOrder,
}) {
  return PrescribedSetRecord(
    id: id,
    programVersionId: 'version-1',
    trainingDayOrder: trainingDayOrder,
    exerciseId: exerciseId,
    exerciseOrder: exerciseOrder,
    setOrder: setOrder,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: 50,
    restSeconds: 180,
    progressionStrategy: ProgressionStrategy.doubleProgression,
    createdAt: now,
  );
}

Future<void> _addExercise(
  WidgetTester tester,
  String query,
  String exerciseId,
) async {
  await tester.ensureVisible(
    find.byKey(ProgramBuilderScreen.addExerciseButtonKey),
  );
  await _tapVisible(
    tester,
    find.byKey(ProgramBuilderScreen.addExerciseButtonKey),
  );
  await tester.pump();
  await _pumpUntilFound(
    tester,
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
  );

  await tester.enterText(
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
    query,
  );
  await tester.pump(const Duration(milliseconds: 250));

  final option = find.byKey(
    ProgramBuilderScreen.exercisePickerOptionKey(exerciseId),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pump();
  await _pumpUntilNotFound(
    tester,
    find.byKey(ProgramBuilderScreen.exercisePickerSearchFieldKey),
  );
}

Future<void> _enterPrescriptionText(
  WidgetTester tester,
  Key fieldKey,
  String value,
) async {
  final finder = find.byKey(fieldKey);
  await _ensureHittable(tester, finder);
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _ensureHittable(tester, finder);
  await tester.tap(finder);
}

Future<void> _ensureHittable(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(
    tester.element(finder),
    duration: Duration.zero,
    alignment: 0.35,
  );
  await tester.pump();
}

String _prescriptionSummaryText(WidgetTester tester, String exerciseId) {
  final text = tester.widget<Text>(
    find.byKey(ProgramBuilderScreen.prescriptionSummaryKey(exerciseId)),
  );
  return text.data ?? '';
}

String _lifecycleStatusText(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.byKey(ProgramBuilderScreen.lifecycleStatusKey),
  );
  return text.data ?? '';
}

Future<void> _pumpUntilLifecycleContains(
  WidgetTester tester,
  String expected,
) async {
  for (var attempt = 0; attempt < 60; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (_lifecycleStatusText(tester).contains(expected)) {
      return;
    }
  }
  fail('Expected lifecycle status to contain "$expected".');
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not found: $finder');
}

Future<void> _pumpUntilNotFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isEmpty) {
      return;
    }
  }
  fail('Expected widget to disappear: $finder');
}

final class _MemoryProfileRepository implements ProfileRepository {
  final _profiles = <String, ProfileRecord>{};

  @override
  Stream<ProfileRecord?> watchProfile(String profileId) {
    return Stream.value(_profiles[profileId]);
  }

  @override
  Future<ProfileRecord?> getProfile(String profileId) async {
    return _profiles[profileId];
  }

  @override
  Future<void> saveProfile(ProfileRecord profile) async {
    _profiles[profile.id] = profile;
  }
}

final class _MemoryProgramRepository implements ProgramRepository {
  final _programs = <String, ProgramRecord>{};
  final _versionsByProgram = <String, List<ProgramVersionRecord>>{};
  final _trainingDaysByVersion = <String, List<ProgramTrainingDayRecord>>{};
  final _prescriptionByVersion = <String, List<PrescribedSetRecord>>{};

  @override
  Stream<List<ProgramRecord>> watchPrograms(String profileId) {
    final records = _programs.values
        .where((program) => program.profileId == profileId)
        .toList(growable: false);
    return Stream.value(records);
  }

  @override
  Future<List<ProgramRecord>> getPrograms(String profileId) async {
    return _programs.values
        .where((program) => program.profileId == profileId)
        .toList(growable: false);
  }

  @override
  Future<ProgramRecord?> getProgram(String programId) async {
    return _programs[programId];
  }

  @override
  Stream<List<ProgramVersionRecord>> watchVersions(String programId) {
    final records = [...?_versionsByProgram[programId]]
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    return Stream.value(records);
  }

  @override
  Future<List<ProgramVersionRecord>> getVersions(String programId) async {
    return [...?_versionsByProgram[programId]]
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
  }

  @override
  Stream<List<ProgramTrainingDayRecord>> watchTrainingDays(String versionId) {
    final records = [...?_trainingDaysByVersion[versionId]]
      ..sort((a, b) => a.trainingDayOrder.compareTo(b.trainingDayOrder));
    return Stream.value(records);
  }

  @override
  Future<List<ProgramTrainingDayRecord>> getTrainingDays(
    String versionId,
  ) async {
    return [...?_trainingDaysByVersion[versionId]]
      ..sort((a, b) => a.trainingDayOrder.compareTo(b.trainingDayOrder));
  }

  @override
  Stream<List<PrescribedSetRecord>> watchPrescription(String versionId) {
    final records = [...?_prescriptionByVersion[versionId]]
      ..sort((a, b) {
        final dayOrder = a.trainingDayOrder.compareTo(b.trainingDayOrder);
        if (dayOrder != 0) {
          return dayOrder;
        }
        final exerciseOrder = a.exerciseOrder.compareTo(b.exerciseOrder);
        if (exerciseOrder != 0) {
          return exerciseOrder;
        }
        return a.setOrder.compareTo(b.setOrder);
      });
    return Stream.value(records);
  }

  @override
  Future<List<PrescribedSetRecord>> getPrescription(String versionId) async {
    return [...?_prescriptionByVersion[versionId]]..sort((a, b) {
      final dayOrder = a.trainingDayOrder.compareTo(b.trainingDayOrder);
      if (dayOrder != 0) {
        return dayOrder;
      }
      final exerciseOrder = a.exerciseOrder.compareTo(b.exerciseOrder);
      if (exerciseOrder != 0) {
        return exerciseOrder;
      }
      return a.setOrder.compareTo(b.setOrder);
    });
  }

  @override
  Future<void> saveProgram(ProgramRecord program) async {
    _programs[program.id] = program;
  }

  @override
  Future<void> saveProgramSnapshot(
    ProgramRecord program,
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription, {
    bool retireActiveVersions = false,
  }) async {
    _programs[program.id] = program;
    if (retireActiveVersions) {
      _versionsByProgram[program.id] = [
        for (final existing in _versionsByProgram[program.id] ?? const [])
          existing.lifecycle == ProgramVersionLifecycle.active
              ? ProgramVersionRecord(
                  id: existing.id,
                  programId: existing.programId,
                  versionNumber: existing.versionNumber,
                  lifecycle: ProgramVersionLifecycle.retired,
                  label: existing.label,
                  createdAt: existing.createdAt,
                  activatedAt: existing.activatedAt,
                )
              : existing,
      ];
    }
    await addVersion(version, trainingDays, prescription);
  }

  @override
  Future<void> addVersion(
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription,
  ) async {
    _versionsByProgram.update(
      version.programId,
      (records) => [...records, version],
      ifAbsent: () => [version],
    );
    _trainingDaysByVersion[version.id] = List.of(trainingDays);
    _prescriptionByVersion[version.id] = List.of(prescription);
  }
}
