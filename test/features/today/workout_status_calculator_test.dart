import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';

void main() {
  final now = DateTime.utc(2026, 7, 20, 10);
  final prescription = PrescribedSetRecord(
    id: 'prescribed-set-1',
    programVersionId: 'version-1',
    trainingDayOrder: 0,
    exerciseId: 'barbell_bench_press',
    exerciseOrder: 0,
    setOrder: 0,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: 50,
    restSeconds: 180,
    progressionStrategy: ProgressionStrategy.doubleProgression,
    createdAt: now,
  );

  test('classifies set status separately from persisted set lifecycle', () {
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.planned,
        prescribedSet: prescription,
        latestLog: null,
      ),
      TodaySetStatus.pending,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, repetitions: 6, loadKilograms: 50),
      ),
      TodaySetStatus.targetMet,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, repetitions: 5, loadKilograms: 50),
      ),
      TodaySetStatus.performanceMiss,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, repetitions: 6, loadKilograms: 47.5),
      ),
      TodaySetStatus.performanceMiss,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, result: SetResult.techniqueLimitation),
      ),
      TodaySetStatus.performanceMiss,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, result: SetResult.externalInterruption),
      ),
      TodaySetStatus.interrupted,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, result: SetResult.pain),
      ),
      TodaySetStatus.painReported,
    );
    expect(
      calculateTodaySetStatus(
        lifecycle: SetLifecycle.completed,
        prescribedSet: prescription,
        latestLog: _log(now, repetitions: 6),
      ),
      TodaySetStatus.notComparable,
    );
  });

  test('aggregates exercise and session statuses independently', () {
    expect(
      calculateTodayExerciseStatus([
        TodaySetStatus.targetMet,
        TodaySetStatus.pending,
      ]),
      TodayExerciseStatus.inProgress,
    );
    expect(
      calculateTodayExerciseStatus([
        TodaySetStatus.targetMet,
        TodaySetStatus.performanceMiss,
      ]),
      TodayExerciseStatus.needsReview,
    );
    expect(
      calculateTodayExerciseStatus([
        TodaySetStatus.targetMet,
        TodaySetStatus.targetMet,
      ]),
      TodayExerciseStatus.successful,
    );

    expect(
      calculateTodaySessionStatus([
        TodayExerciseStatus.successful,
        TodayExerciseStatus.needsReview,
      ]),
      TodaySessionStatus.needsReview,
    );
    expect(
      calculateTodaySessionStatus([
        TodayExerciseStatus.successful,
        TodayExerciseStatus.inProgress,
      ]),
      TodaySessionStatus.inProgress,
    );
    expect(
      calculateTodaySessionStatus([
        TodayExerciseStatus.successful,
        TodayExerciseStatus.painReported,
      ]),
      TodaySessionStatus.painReported,
    );
  });
}

ActualSetLogRecord _log(
  DateTime now, {
  int? repetitions,
  double? loadKilograms,
  SetResult? result,
}) {
  return ActualSetLogRecord(
    id: 'log-${now.microsecondsSinceEpoch}-${result?.name ?? repetitions}',
    sessionSetId: 'session-set-1',
    revision: 1,
    repetitions: repetitions,
    loadKilograms: loadKilograms,
    result: result,
    recordedAt: now,
  );
}
