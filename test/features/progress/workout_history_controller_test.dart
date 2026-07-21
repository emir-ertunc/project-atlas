import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/progress/application/workout_history_controller.dart';
import 'package:project_atlas/features/progress/domain/progress_trends.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 7, 20, 10);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        workoutHistoryClockProvider.overrideWithValue(
          () => now.add(const Duration(minutes: 30)),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'builds workout history from sessions, sets, prescriptions, and logs',
    () async {
      await _seedProgram(container, now);
      await _seedCleanBenchSession(container, now);
      await _seedOlderLimitedBenchSession(container, now);

      final state = await container.read(workoutHistoryProvider.future);

      expect(state.isEmpty, isFalse);
      expect(state.sessions.map((session) => session.session.id), [
        'recent-session',
        'older-session',
      ]);

      final recent = state.sessions.first;
      expect(recent.session.notes, 'Upper A');
      expect(recent.status, TodaySessionStatus.successful);
      expect(recent.exerciseCount, 1);
      expect(recent.setCount, 1);
      expect(recent.completedSetCount, 1);

      final recentSet = recent.setDetails.single;
      expect(recentSet.sessionSet.id, 'recent-bench-set-0');
      expect(recentSet.prescribedSet?.id, 'upper-bench-0');
      expect(recentSet.logs.map((log) => log.revision), [1, 2]);
      expect(recentSet.latestLog?.id, 'recent-bench-log-2');
      expect(recentSet.status, TodaySetStatus.targetMet);

      final olderSet = state.sessions.last.setDetails.single;
      expect(olderSet.latestLog?.result, SetResult.strengthLimitation);
      expect(olderSet.status, TodaySetStatus.performanceMiss);

      final record = state.personalRecords.single;
      expect(record.exerciseId, 'barbell_bench_press');
      expect(record.bestLoad?.value, 55);
      expect(record.bestRepetitions?.value, 8);
      expect(record.bestVolume?.value, 440);
      expect(record.bestLoad?.setDetail.sessionSet.id, 'recent-bench-set-0');
      expect(
        record.bestRepetitions?.setDetail.sessionSet.id,
        'recent-bench-set-0',
      );
      expect(record.bestVolume?.setDetail.sessionSet.id, 'recent-bench-set-0');
    },
  );

  test('returns an empty state when no workout sessions exist', () async {
    await _seedProgram(container, now);

    final state = await container.read(workoutHistoryProvider.future);

    expect(state.isEmpty, isTrue);
    expect(state.sessions, isEmpty);
    expect(state.setDetails, isEmpty);
    expect(state.firstSetDetail, isNull);
    expect(state.personalRecords, isEmpty);
  });

  test(
    'corrects a historical log by appending a superseding revision',
    () async {
      await _seedProgram(container, now);
      await _seedCleanBenchSession(container, now);

      final state = await container.read(workoutHistoryProvider.future);
      final detail = state.setDetailById('recent-bench-set-0');

      await container
          .read(workoutHistoryCorrectionControllerProvider.notifier)
          .correctSet(
            detail: detail!,
            repetitions: 9,
            loadKilograms: 60,
            rir: 0,
            result: null,
          );

      final logs = await container
          .read(workoutRepositoryProvider)
          .getActualSetLogs('recent-bench-set-0');

      expect(logs, hasLength(3));
      expect(logs.map((log) => log.revision), [1, 2, 3]);
      expect(logs[0].repetitions, 6);
      expect(logs[0].loadKilograms, 50);
      expect(logs[1].repetitions, 8);
      expect(logs[1].loadKilograms, 55);
      expect(logs[2].supersedesLogId, 'recent-bench-log-2');
      expect(logs[2].repetitions, 9);
      expect(logs[2].loadKilograms, 60);
      expect(logs[2].rir, 0);
      expect(logs[2].recordedAt, now.add(const Duration(minutes: 30)));

      final refreshed = await container.read(workoutHistoryProvider.future);
      final correctedDetail = refreshed.setDetailById('recent-bench-set-0')!;
      expect(correctedDetail.latestLog?.revision, 3);
      expect(correctedDetail.latestLog?.repetitions, 9);
      expect(correctedDetail.latestLog?.loadKilograms, 60);

      final record = refreshed.personalRecords.single;
      expect(record.bestLoad?.value, 60);
      expect(record.bestRepetitions?.value, 9);
      expect(record.bestVolume?.value, 540);
    },
  );

  test('builds measurement and training trends from local history', () async {
    await _seedProgram(container, now);
    await _seedOlderCleanBenchSession(container, now);
    await _seedCleanBenchSession(container, now);
    await _seedMeasurements(container, now);

    final state = await container.read(workoutHistoryProvider.future);

    expect(state.measurementHistory.records, hasLength(2));
    expect(
      state.measurementHistory
          .comparisonFor(BodyMeasurementField.weightKilograms)
          ?.delta,
      -2,
    );

    final weightTrend = state.trends.measurementTrendFor(
      MeasurementTrendMetric.weight,
    );
    expect(weightTrend, isNotNull);
    expect(weightTrend!.latestPoint.value, 79);
    expect(weightTrend.delta, -2);

    final benchTrend = state.trends.trainingTrendFor('barbell_bench_press');
    expect(benchTrend, isNotNull);
    expect(
      benchTrend!.metricTrendFor(TrainingTrendMetric.volume)!.latestPoint.value,
      440,
    );
    expect(
      benchTrend
          .metricTrendFor(TrainingTrendMetric.estimatedStrength)!
          .latestPoint
          .value,
      closeTo(69.67, 0.01),
    );
  });
}

Future<void> _seedProgram(ProviderContainer container, DateTime now) async {
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
        [_trainingDay(now, order: 0, name: 'Upper A')],
        [
          _prescribedSet(
            now,
            id: 'upper-bench-0',
            exerciseId: 'barbell_bench_press',
            exerciseOrder: 0,
            setOrder: 0,
          ),
        ],
      );
}

Future<void> _seedCleanBenchSession(
  ProviderContainer container,
  DateTime now,
) async {
  final repository = container.read(workoutRepositoryProvider);
  final performedAt = now.subtract(const Duration(days: 1));
  final session = _session(
    id: 'recent-session',
    at: performedAt,
    notes: 'Upper A',
  );
  final set = _sessionSet(
    id: 'recent-bench-set-0',
    sessionId: session.id,
    prescribedSetId: 'upper-bench-0',
    at: performedAt,
  );

  await repository.saveSessionPlan(session, [set]);
  await repository.completeSessionSet(
    _completed(set, performedAt.add(const Duration(minutes: 5))),
    ActualSetLogRecord(
      id: 'recent-bench-log-1',
      sessionSetId: set.id,
      revision: 1,
      repetitions: 6,
      loadKilograms: 50,
      rir: 2,
      recordedAt: performedAt.add(const Duration(minutes: 5)),
    ),
  );
  await repository.appendActualSetLog(
    ActualSetLogRecord(
      id: 'recent-bench-log-2',
      sessionSetId: set.id,
      revision: 2,
      repetitions: 8,
      loadKilograms: 55,
      rir: 1,
      supersedesLogId: 'recent-bench-log-1',
      recordedAt: performedAt.add(const Duration(minutes: 8)),
    ),
  );
}

Future<void> _seedOlderLimitedBenchSession(
  ProviderContainer container,
  DateTime now,
) async {
  final repository = container.read(workoutRepositoryProvider);
  final performedAt = now.subtract(const Duration(days: 8));
  final session = _session(
    id: 'older-session',
    at: performedAt,
    notes: 'Upper A',
  );
  final set = _sessionSet(
    id: 'older-bench-set-0',
    sessionId: session.id,
    prescribedSetId: 'upper-bench-0',
    at: performedAt,
  );

  await repository.saveSessionPlan(session, [set]);
  await repository.completeSessionSet(
    _completed(set, performedAt.add(const Duration(minutes: 6))),
    ActualSetLogRecord(
      id: 'older-bench-log-1',
      sessionSetId: set.id,
      revision: 1,
      repetitions: 5,
      loadKilograms: 57.5,
      rir: 0,
      result: SetResult.strengthLimitation,
      recordedAt: performedAt.add(const Duration(minutes: 6)),
    ),
  );
}

Future<void> _seedOlderCleanBenchSession(
  ProviderContainer container,
  DateTime now,
) async {
  final repository = container.read(workoutRepositoryProvider);
  final performedAt = now.subtract(const Duration(days: 8));
  final session = _session(
    id: 'older-clean-session',
    at: performedAt,
    notes: 'Upper A',
  );
  final set = _sessionSet(
    id: 'older-clean-bench-set-0',
    sessionId: session.id,
    prescribedSetId: 'upper-bench-0',
    at: performedAt,
  );

  await repository.saveSessionPlan(session, [set]);
  await repository.completeSessionSet(
    _completed(set, performedAt.add(const Duration(minutes: 6))),
    ActualSetLogRecord(
      id: 'older-clean-bench-log-1',
      sessionSetId: set.id,
      revision: 1,
      repetitions: 6,
      loadKilograms: 50,
      rir: 2,
      recordedAt: performedAt.add(const Duration(minutes: 6)),
    ),
  );
}

Future<void> _seedMeasurements(
  ProviderContainer container,
  DateTime now,
) async {
  final repository = container.read(measurementRepositoryProvider);
  await repository.addMeasurement(
    MeasurementRecord(
      id: 'measurement-old',
      profileId: localProgramProfileId,
      measuredAt: now.subtract(const Duration(days: 30)),
      origin: MeasurementOrigin.manual,
      weightKilograms: 81,
      bodyFatPercentage: 18,
      createdAt: now.subtract(const Duration(days: 30)),
    ),
  );
  await repository.addMeasurement(
    MeasurementRecord(
      id: 'measurement-new',
      profileId: localProgramProfileId,
      measuredAt: now,
      origin: MeasurementOrigin.manual,
      weightKilograms: 79,
      bodyFatPercentage: 17.5,
      createdAt: now,
    ),
  );
}

ProgramTrainingDayRecord _trainingDay(
  DateTime now, {
  required int order,
  required String name,
}) {
  return ProgramTrainingDayRecord(
    id: 'training-day-$order',
    programVersionId: 'version-1',
    trainingDayOrder: order,
    name: name,
    createdAt: now,
  );
}

PrescribedSetRecord _prescribedSet(
  DateTime now, {
  required String id,
  required String exerciseId,
  required int exerciseOrder,
  required int setOrder,
}) {
  return PrescribedSetRecord(
    id: id,
    programVersionId: 'version-1',
    trainingDayOrder: 0,
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

WorkoutSessionRecord _session({
  required String id,
  required DateTime at,
  required String notes,
}) {
  return WorkoutSessionRecord(
    id: id,
    profileId: localProgramProfileId,
    programId: 'program-1',
    programVersionId: 'version-1',
    lifecycle: WorkoutLifecycle.completed,
    scheduledAt: at,
    startedAt: at,
    endedAt: at.add(const Duration(hours: 1)),
    notes: notes,
    createdAt: at,
    updatedAt: at.add(const Duration(hours: 1)),
  );
}

SessionSetRecord _sessionSet({
  required String id,
  required String sessionId,
  required String prescribedSetId,
  required DateTime at,
}) {
  return SessionSetRecord(
    id: id,
    sessionId: sessionId,
    prescribedSetId: prescribedSetId,
    exerciseId: 'barbell_bench_press',
    exerciseOrder: 0,
    setOrder: 0,
    lifecycle: SetLifecycle.planned,
    createdAt: at,
    updatedAt: at,
  );
}

SessionSetRecord _completed(SessionSetRecord set, DateTime at) {
  return SessionSetRecord(
    id: set.id,
    sessionId: set.sessionId,
    prescribedSetId: set.prescribedSetId,
    exerciseId: set.exerciseId,
    exerciseOrder: set.exerciseOrder,
    setOrder: set.setOrder,
    lifecycle: SetLifecycle.completed,
    createdAt: set.createdAt,
    updatedAt: at,
  );
}
