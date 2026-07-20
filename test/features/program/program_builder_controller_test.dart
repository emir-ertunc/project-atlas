import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/program/application/program_builder_controller.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('creates a local program draft with one selected training day', () {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(
      programName: 'Upper Lower',
      firstDayName: 'Upper A',
    );

    final state = container.read(programBuilderControllerProvider);
    final draft = state.draft;

    expect(draft, isNotNull);
    expect(draft!.name, 'Upper Lower');
    expect(draft.trainingDays, hasLength(1));
    expect(draft.trainingDays.single.id, 'day_1');
    expect(draft.trainingDays.single.name, 'Upper A');
    expect(draft.selectedDayId, 'day_1');
    expect(state.nextDayNumber, 2);
  });

  test('edits training days and keeps selection valid after deletion', () {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(programName: 'Plan', firstDayName: 'Day 1');
    controller.addTrainingDay('Lower A');
    controller.renameTrainingDay('day_2', 'Lower Strength');
    controller.selectTrainingDay('day_2');
    controller.deleteTrainingDay('day_2');

    final draft = container.read(programBuilderControllerProvider).draft!;

    expect(draft.trainingDays, hasLength(1));
    expect(draft.trainingDays.single.id, 'day_1');
    expect(draft.selectedDayId, 'day_1');
  });

  test('adds, prevents duplicate, reorders, and removes exercises', () {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(programName: 'Plan', firstDayName: 'Day 1');
    controller.addExerciseToSelectedDay('barbell_bench_press');
    controller.addExerciseToSelectedDay('barbell_back_squat');
    controller.addExerciseToSelectedDay('barbell_bench_press');
    controller.moveExercise(dayId: 'day_1', fromIndex: 1, toIndex: 0);
    controller.removeExercise('day_1', 'barbell_bench_press');

    final day = container
        .read(programBuilderControllerProvider)
        .draft!
        .trainingDays
        .single;

    expect(day.exerciseIds, ['barbell_back_squat']);
  });

  test(
    'updates fixed and ranged exercise prescription targets independently',
    () {
      final controller = container.read(
        programBuilderControllerProvider.notifier,
      );

      controller.createProgram(programName: 'Plan', firstDayName: 'Day 1');
      controller.addExerciseToSelectedDay('barbell_bench_press');

      var prescription = container
          .read(programBuilderControllerProvider)
          .draft!
          .selectedDay!
          .prescriptionFor('barbell_bench_press')!;

      expect(prescription.setCount, 3);
      expect(prescription.minimumRepetitions, 8);
      expect(prescription.maximumRepetitions, 10);
      expect(prescription.repetitionMode, ProgramRepetitionMode.range);
      expect(prescription.targetRir, 2);
      expect(prescription.loadKilograms, isNull);
      expect(prescription.restSeconds, 120);

      controller.updateSetCount(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        setCount: 4,
      );
      controller.setRepetitionMode(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        mode: ProgramRepetitionMode.fixed,
      );
      controller.updateFixedRepetitions(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        repetitions: 6,
      );
      controller.updateTargetRirEnabled(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        enabled: false,
      );
      controller.updateLoadKilograms(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        loadKilograms: 55.5,
      );
      controller.updateRestSeconds(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        restSeconds: 90,
      );

      prescription = container
          .read(programBuilderControllerProvider)
          .draft!
          .selectedDay!
          .prescriptionFor('barbell_bench_press')!;

      expect(prescription.setCount, 4);
      expect(prescription.minimumRepetitions, 6);
      expect(prescription.maximumRepetitions, 6);
      expect(prescription.repetitionMode, ProgramRepetitionMode.fixed);
      expect(prescription.targetRir, isNull);
      expect(prescription.loadKilograms, 55.5);
      expect(prescription.restSeconds, 90);

      controller.setRepetitionMode(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        mode: ProgramRepetitionMode.range,
      );
      controller.updateMaximumRepetitions(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        maximumRepetitions: 8,
      );
      controller.updateTargetRirEnabled(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        enabled: true,
      );
      controller.updateTargetRir(
        dayId: 'day_1',
        exerciseId: 'barbell_bench_press',
        targetRir: 1,
      );

      prescription = container
          .read(programBuilderControllerProvider)
          .draft!
          .selectedDay!
          .prescriptionFor('barbell_bench_press')!;

      expect(prescription.minimumRepetitions, 6);
      expect(prescription.maximumRepetitions, 8);
      expect(prescription.repetitionMode, ProgramRepetitionMode.range);
      expect(prescription.targetRir, 1);
    },
  );

  test('normalizes prescription values to safe local bounds', () {
    final controller = container.read(
      programBuilderControllerProvider.notifier,
    );

    controller.createProgram(programName: 'Plan', firstDayName: 'Day 1');
    controller.addExerciseToSelectedDay('barbell_bench_press');
    controller.updateSetCount(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      setCount: 0,
    );
    controller.updateMinimumRepetitions(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      minimumRepetitions: 150,
    );
    controller.updateMaximumRepetitions(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      maximumRepetitions: 1,
    );
    controller.updateTargetRir(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      targetRir: 99,
    );
    controller.updateLoadKilograms(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      loadKilograms: -5,
    );
    controller.updateRestSeconds(
      dayId: 'day_1',
      exerciseId: 'barbell_bench_press',
      restSeconds: 2000,
    );

    final prescription = container
        .read(programBuilderControllerProvider)
        .draft!
        .selectedDay!
        .prescriptionFor('barbell_bench_press')!;

    expect(prescription.setCount, ProgramExercisePrescription.minimumSetCount);
    expect(
      prescription.minimumRepetitions,
      ProgramExercisePrescription.maximumRepetitionsLimit,
    );
    expect(
      prescription.maximumRepetitions,
      ProgramExercisePrescription.maximumRepetitionsLimit,
    );
    expect(prescription.targetRir, ProgramExercisePrescription.maximumRir);
    expect(prescription.loadKilograms, 0);
    expect(
      prescription.restSeconds,
      ProgramExercisePrescription.maximumRestSeconds,
    );
  });
}
