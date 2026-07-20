import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/today/application/today_workout_controller.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';

void main() {
  late Directory temporaryDirectory;
  late File databaseFile;
  late DateTime now;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'project_atlas_today_restore_test_',
    );
    databaseFile = File('${temporaryDirectory.path}/project_atlas.sqlite');
    now = DateTime.utc(2026, 7, 20, 10);
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'restores an in-progress session and continues logging after restart',
    () async {
      var database = _openDatabase(databaseFile);
      await _seedActiveProgram(database, now);
      await _seedActiveWorkout(database, now);

      var container = _container(database, now);
      var state = await container.read(todayWorkoutControllerProvider.future);

      expect(state.activeSession, isNotNull);
      expect(state.activeSession?.restoredAfterProcessTermination, isTrue);
      expect(state.selectedTrainingDayOrder, 1);

      await container
          .read(todayWorkoutControllerProvider.notifier)
          .completeSessionSet(
            sessionSetId: 'active-set-0',
            repetitions: 7,
            loadKilograms: 52.5,
            rir: 1,
            result: SetResult.techniqueLimitation,
          );
      state = container.read(todayWorkoutControllerProvider).value!;
      expect(state.activeSession?.completedSetCount, 1);
      expect(state.activeSession?.status, TodaySessionStatus.needsReview);
      expect(
        state.activeSession?.exerciseSummaries.single.status,
        TodayExerciseStatus.needsReview,
      );
      expect(
        state.activeSession?.setSummaries
            .singleWhere((summary) => summary.sessionSet.id == 'active-set-0')
            .status,
        TodaySetStatus.performanceMiss,
      );

      container.dispose();
      await database.close();

      database = _openDatabase(databaseFile);
      addTearDown(database.close);
      container = _container(database, now);
      addTearDown(container.dispose);

      state = await container.read(todayWorkoutControllerProvider.future);

      expect(state.activeSession, isNotNull);
      expect(state.activeSession?.session.id, 'active-session');
      expect(state.activeSession?.restoredAfterProcessTermination, isTrue);
      expect(state.selectedTrainingDayOrder, 1);
      expect(state.activeSession?.completedSetCount, 1);
      expect(state.activeSession?.status, TodaySessionStatus.needsReview);
      expect(
        state.activeSession?.setSummaries
            .singleWhere((summary) => summary.sessionSet.id == 'active-set-0')
            .latestLog
            ?.repetitions,
        7,
      );

      await container
          .read(todayWorkoutControllerProvider.notifier)
          .completeSessionSet(
            sessionSetId: 'active-set-1',
            repetitions: 6,
            loadKilograms: 50,
            rir: 2,
            result: null,
          );

      final logs = await database.select(database.actualSetLogs).get();

      expect(logs, hasLength(2));
      expect(logs.map((log) => log.id).toSet(), hasLength(2));
      expect(logs.map((log) => log.sessionSetId).toSet(), {
        'active-set-0',
        'active-set-1',
      });
    },
  );
}

AppDatabase _openDatabase(File file) =>
    AppDatabase.forTesting(NativeDatabase(file));

ProviderContainer _container(AppDatabase database, DateTime now) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      todayClockProvider.overrideWithValue(() => now),
    ],
  );
}

Future<void> _seedActiveProgram(AppDatabase database, DateTime now) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
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
            _trainingDay(now, order: 0, name: 'Upper A'),
            _trainingDay(now, order: 1, name: 'Lower A'),
          ],
          [
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
        );
  } finally {
    container.dispose();
  }
}

Future<void> _seedActiveWorkout(AppDatabase database, DateTime now) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
    await container.read(workoutRepositoryProvider).saveSessionPlan(
      WorkoutSessionRecord(
        id: 'active-session',
        profileId: localProgramProfileId,
        programId: 'program-1',
        programVersionId: 'version-1',
        lifecycle: WorkoutLifecycle.inProgress,
        scheduledAt: now,
        startedAt: now,
        notes: 'Lower A',
        createdAt: now,
        updatedAt: now,
      ),
      [
        for (var index = 0; index < 2; index += 1)
          SessionSetRecord(
            id: 'active-set-$index',
            sessionId: 'active-session',
            prescribedSetId: 'lower-squat-$index',
            exerciseId: 'barbell_back_squat',
            exerciseOrder: 0,
            setOrder: index,
            lifecycle: SetLifecycle.planned,
            createdAt: now,
            updatedAt: now,
          ),
      ],
    );
  } finally {
    container.dispose();
  }
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
