import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    now = DateTime.utc(2026, 7, 7, 12);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'profile writes flow immediately through the local watch stream',
    () async {
      final repository = container.read(profileRepositoryProvider);

      await repository.saveProfile(_profile(now));
      final profile = await repository
          .watchProfile('profile-1')
          .firstWhere((value) => value != null);

      expect(profile?.displayName, 'Local Profile');
      expect(profile?.unitPreference, UnitPreference.metric);
    },
  );

  test('program version and prescription are stored atomically', () async {
    await _saveProfile(container, now);
    final repository = container.read(programRepositoryProvider);
    await repository.saveProgram(_program(now));

    await repository.addVersion(
      _version(now),
      [_trainingDay(now)],
      [_prescribedSet(now)],
    );

    final versions = await repository
        .watchVersions('program-1')
        .firstWhere((items) => items.isNotEmpty);
    final trainingDays = await repository
        .watchTrainingDays('version-1')
        .firstWhere((items) => items.isNotEmpty);
    final prescription = await repository
        .watchPrescription('version-1')
        .firstWhere((items) => items.isNotEmpty);

    expect(versions.single.versionNumber, 1);
    expect(trainingDays.single.name, 'Upper A');
    expect(prescription.single.minimumRepetitions, 6);
    expect(prescription.single.maximumRepetitions, 8);
    expect(prescription.single.targetRir, 2);
    expect(
      prescription.single.progressionStrategy,
      ProgressionStrategy.doubleProgression,
    );
  });

  test(
    'a failed prescription write rolls back the version atomically',
    () async {
      await _saveProfile(container, now);
      final repository = container.read(programRepositoryProvider);
      await repository.saveProgram(_program(now));

      await expectLater(
        repository.addVersion(
          _version(now),
          [_trainingDay(now)],
          [_prescribedSet(now), _prescribedSet(now, id: 'prescribed-set-2')],
        ),
        throwsA(isA<Exception>()),
      );
      expect(await database.select(database.programVersions).get(), isEmpty);
      expect(
        await database.select(database.programVersionTrainingDays).get(),
        isEmpty,
      );
      expect(await database.select(database.prescribedSets).get(), isEmpty);
    },
  );

  test('actual set revisions remain separate from the prescription', () async {
    await _saveProgramGraph(container, now);
    final repository = container.read(workoutRepositoryProvider);
    final session = WorkoutSessionRecord(
      id: 'session-1',
      profileId: 'profile-1',
      programId: 'program-1',
      programVersionId: 'version-1',
      lifecycle: WorkoutLifecycle.inProgress,
      scheduledAt: now,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final sessionSet = SessionSetRecord(
      id: 'session-set-1',
      sessionId: session.id,
      prescribedSetId: 'prescribed-set-1',
      exerciseId: 'barbell-bench-press',
      exerciseOrder: 0,
      setOrder: 0,
      lifecycle: SetLifecycle.completed,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveSessionPlan(session, [sessionSet]);
    await repository.appendActualSetLog(
      ActualSetLogRecord(
        id: 'log-1',
        sessionSetId: sessionSet.id,
        revision: 1,
        repetitions: 6,
        loadKilograms: 50,
        rir: 2,
        recordedAt: now.add(const Duration(minutes: 5)),
      ),
    );
    await repository.appendActualSetLog(
      ActualSetLogRecord(
        id: 'log-2',
        sessionSetId: sessionSet.id,
        revision: 2,
        repetitions: 7,
        loadKilograms: 50,
        rir: 1,
        supersedesLogId: 'log-1',
        recordedAt: now.add(const Duration(minutes: 6)),
      ),
    );

    final logs = await repository
        .watchActualSetLogs(sessionSet.id)
        .firstWhere((items) => items.length == 2);
    final prescription = await container
        .read(programRepositoryProvider)
        .watchPrescription('version-1')
        .firstWhere((items) => items.isNotEmpty);

    expect(logs.map((log) => log.revision), [1, 2]);
    expect(logs.last.supersedesLogId, 'log-1');
    expect(prescription.single.maximumRepetitions, 8);
    expect(await database.select(database.actualSetLogs).get(), hasLength(2));
  });

  test('set completion and actual log are stored atomically', () async {
    await _saveProgramGraph(container, now);
    final repository = container.read(workoutRepositoryProvider);
    final session = WorkoutSessionRecord(
      id: 'session-1',
      profileId: 'profile-1',
      programId: 'program-1',
      programVersionId: 'version-1',
      lifecycle: WorkoutLifecycle.inProgress,
      scheduledAt: now,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final plannedSet = SessionSetRecord(
      id: 'session-set-1',
      sessionId: session.id,
      prescribedSetId: 'prescribed-set-1',
      exerciseId: 'barbell-bench-press',
      exerciseOrder: 0,
      setOrder: 0,
      lifecycle: SetLifecycle.planned,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveSessionPlan(session, [plannedSet]);

    await repository.completeSessionSet(
      SessionSetRecord(
        id: plannedSet.id,
        sessionId: plannedSet.sessionId,
        prescribedSetId: plannedSet.prescribedSetId,
        exerciseId: plannedSet.exerciseId,
        exerciseOrder: plannedSet.exerciseOrder,
        setOrder: plannedSet.setOrder,
        lifecycle: SetLifecycle.completed,
        createdAt: plannedSet.createdAt,
        updatedAt: now.add(const Duration(minutes: 5)),
      ),
      ActualSetLogRecord(
        id: 'log-1',
        sessionSetId: plannedSet.id,
        revision: 1,
        repetitions: 7,
        loadKilograms: 52.5,
        rir: 1,
        result: SetResult.techniqueLimitation,
        recordedAt: now.add(const Duration(minutes: 5)),
      ),
    );

    final completedSet = await database
        .select(database.sessionSets)
        .getSingle();
    final logs = await repository.getActualSetLogs(plannedSet.id);

    expect(completedSet.status.name, SetLifecycle.completed.name);
    expect(completedSet.updatedAt.toUtc(), now.add(const Duration(minutes: 5)));
    expect(logs.single.revision, 1);
    expect(logs.single.repetitions, 7);
    expect(logs.single.loadKilograms, 52.5);
    expect(logs.single.rir, 1);
    expect(logs.single.result, SetResult.techniqueLimitation);
  });

  test('set completion accepts an outcome-only actual log', () async {
    await _saveProgramGraph(container, now);
    final repository = container.read(workoutRepositoryProvider);
    final session = WorkoutSessionRecord(
      id: 'session-1',
      profileId: 'profile-1',
      programId: 'program-1',
      programVersionId: 'version-1',
      lifecycle: WorkoutLifecycle.inProgress,
      scheduledAt: now,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final plannedSet = SessionSetRecord(
      id: 'session-set-1',
      sessionId: session.id,
      prescribedSetId: 'prescribed-set-1',
      exerciseId: 'barbell-bench-press',
      exerciseOrder: 0,
      setOrder: 0,
      lifecycle: SetLifecycle.planned,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveSessionPlan(session, [plannedSet]);

    await repository.completeSessionSet(
      SessionSetRecord(
        id: plannedSet.id,
        sessionId: plannedSet.sessionId,
        prescribedSetId: plannedSet.prescribedSetId,
        exerciseId: plannedSet.exerciseId,
        exerciseOrder: plannedSet.exerciseOrder,
        setOrder: plannedSet.setOrder,
        lifecycle: SetLifecycle.completed,
        createdAt: plannedSet.createdAt,
        updatedAt: now.add(const Duration(minutes: 5)),
      ),
      ActualSetLogRecord(
        id: 'log-1',
        sessionSetId: plannedSet.id,
        revision: 1,
        result: SetResult.externalInterruption,
        recordedAt: now.add(const Duration(minutes: 5)),
      ),
    );

    final completedSet = await database
        .select(database.sessionSets)
        .getSingle();
    final logs = await repository.getActualSetLogs(plannedSet.id);

    expect(completedSet.status.name, SetLifecycle.completed.name);
    expect(logs.single.repetitions, isNull);
    expect(logs.single.loadKilograms, isNull);
    expect(logs.single.rir, isNull);
    expect(logs.single.result, SetResult.externalInterruption);
  });

  test(
    'exercise performance history excludes the active session and uses latest revisions',
    () async {
      await _saveProgramGraph(container, now);
      final repository = container.read(workoutRepositoryProvider);
      final previousAt = now.subtract(const Duration(days: 7));
      final previousSession = WorkoutSessionRecord(
        id: 'previous-session',
        profileId: 'profile-1',
        programId: 'program-1',
        programVersionId: 'version-1',
        lifecycle: WorkoutLifecycle.completed,
        scheduledAt: previousAt,
        startedAt: previousAt,
        endedAt: previousAt.add(const Duration(hours: 1)),
        createdAt: previousAt,
        updatedAt: previousAt.add(const Duration(hours: 1)),
      );
      final previousSet = SessionSetRecord(
        id: 'previous-set-1',
        sessionId: previousSession.id,
        prescribedSetId: 'prescribed-set-1',
        exerciseId: 'barbell-bench-press',
        exerciseOrder: 0,
        setOrder: 0,
        lifecycle: SetLifecycle.completed,
        createdAt: previousAt,
        updatedAt: previousAt.add(const Duration(minutes: 5)),
      );
      final activeSession = WorkoutSessionRecord(
        id: 'active-session',
        profileId: 'profile-1',
        programId: 'program-1',
        programVersionId: 'version-1',
        lifecycle: WorkoutLifecycle.inProgress,
        scheduledAt: now,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final activeSet = SessionSetRecord(
        id: 'active-set-1',
        sessionId: activeSession.id,
        prescribedSetId: 'prescribed-set-1',
        exerciseId: 'barbell-bench-press',
        exerciseOrder: 0,
        setOrder: 0,
        lifecycle: SetLifecycle.completed,
        createdAt: now,
        updatedAt: now.add(const Duration(minutes: 5)),
      );

      await repository.saveSessionPlan(previousSession, [previousSet]);
      await repository.appendActualSetLog(
        ActualSetLogRecord(
          id: 'previous-log-1',
          sessionSetId: previousSet.id,
          revision: 1,
          repetitions: 6,
          loadKilograms: 50,
          rir: 2,
          recordedAt: previousAt.add(const Duration(minutes: 5)),
        ),
      );
      await repository.appendActualSetLog(
        ActualSetLogRecord(
          id: 'previous-log-2',
          sessionSetId: previousSet.id,
          revision: 2,
          repetitions: 7,
          loadKilograms: 52.5,
          rir: 1,
          supersedesLogId: 'previous-log-1',
          recordedAt: now.add(const Duration(minutes: 30)),
        ),
      );
      final recentPreviousAt = now.subtract(const Duration(days: 1));
      final recentPreviousSession = WorkoutSessionRecord(
        id: 'recent-previous-session',
        profileId: 'profile-1',
        programId: 'program-1',
        programVersionId: 'version-1',
        lifecycle: WorkoutLifecycle.completed,
        scheduledAt: recentPreviousAt,
        startedAt: recentPreviousAt,
        endedAt: recentPreviousAt.add(const Duration(hours: 1)),
        createdAt: recentPreviousAt,
        updatedAt: recentPreviousAt.add(const Duration(hours: 1)),
      );
      final recentPreviousSet = SessionSetRecord(
        id: 'recent-previous-set-1',
        sessionId: recentPreviousSession.id,
        prescribedSetId: 'prescribed-set-1',
        exerciseId: 'barbell-bench-press',
        exerciseOrder: 0,
        setOrder: 0,
        lifecycle: SetLifecycle.completed,
        createdAt: recentPreviousAt,
        updatedAt: recentPreviousAt.add(const Duration(minutes: 5)),
      );
      await repository.saveSessionPlan(recentPreviousSession, [
        recentPreviousSet,
      ]);
      await repository.appendActualSetLog(
        ActualSetLogRecord(
          id: 'recent-previous-log-1',
          sessionSetId: recentPreviousSet.id,
          revision: 1,
          repetitions: 8,
          loadKilograms: 55,
          rir: 1,
          recordedAt: recentPreviousAt.add(const Duration(minutes: 5)),
        ),
      );
      await repository.saveSessionPlan(activeSession, [activeSet]);
      await repository.appendActualSetLog(
        ActualSetLogRecord(
          id: 'active-log-1',
          sessionSetId: activeSet.id,
          revision: 1,
          repetitions: 8,
          loadKilograms: 55,
          rir: 1,
          recordedAt: now.add(const Duration(minutes: 5)),
        ),
      );

      final history = await repository.getExercisePerformanceHistory(
        profileId: 'profile-1',
        exerciseId: 'barbell-bench-press',
        excludedSessionId: activeSession.id,
      );

      expect(history, hasLength(2));
      expect(history.first.sessionId, recentPreviousSession.id);
      expect(history.first.sessionSetId, recentPreviousSet.id);
      expect(history.first.setOrder, 0);
      expect(history.first.log.repetitions, 8);
      expect(history.first.log.loadKilograms, 55);
      expect(history.first.log.rir, 1);
      expect(history.last.sessionId, previousSession.id);
      expect(history.last.sessionSetId, previousSet.id);
      expect(history.last.setOrder, 0);
      expect(history.last.log.revision, 2);
      expect(history.last.log.repetitions, 7);
      expect(history.last.log.loadKilograms, 52.5);
      expect(history.last.log.rir, 1);
    },
  );

  test(
    'removing a program template preserves session history and actual logs',
    () async {
      await _saveProgramGraph(container, now);
      final repository = container.read(workoutRepositoryProvider);
      final session = WorkoutSessionRecord(
        id: 'session-1',
        profileId: 'profile-1',
        programId: 'program-1',
        programVersionId: 'version-1',
        lifecycle: WorkoutLifecycle.completed,
        scheduledAt: now,
        startedAt: now,
        endedAt: now.add(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now.add(const Duration(hours: 1)),
      );
      final sessionSet = SessionSetRecord(
        id: 'session-set-1',
        sessionId: session.id,
        prescribedSetId: 'prescribed-set-1',
        exerciseId: 'barbell-bench-press',
        exerciseOrder: 0,
        setOrder: 0,
        lifecycle: SetLifecycle.completed,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveSessionPlan(session, [sessionSet]);
      await repository.appendActualSetLog(
        ActualSetLogRecord(
          id: 'log-1',
          sessionSetId: sessionSet.id,
          revision: 1,
          repetitions: 6,
          loadKilograms: 50,
          rir: 2,
          recordedAt: now.add(const Duration(minutes: 5)),
        ),
      );

      await (database.delete(
        database.programs,
      )..where((row) => row.id.equals('program-1'))).go();

      final historicalSession = await database
          .select(database.workoutSessions)
          .getSingle();
      final historicalSet = await database
          .select(database.sessionSets)
          .getSingle();
      final logs = await database.select(database.actualSetLogs).get();

      expect(historicalSession.programId, isNull);
      expect(historicalSession.programVersionId, isNull);
      expect(historicalSet.prescribedSetId, isNull);
      expect(historicalSet.exerciseId, 'barbell-bench-press');
      expect(logs.single.repetitions, 6);
    },
  );

  test(
    'measurement history is emitted newest first from local storage',
    () async {
      await _saveProfile(container, now);
      final repository = container.read(measurementRepositoryProvider);
      await repository.addMeasurement(
        MeasurementRecord(
          id: 'measurement-1',
          profileId: 'profile-1',
          measuredAt: now,
          origin: MeasurementOrigin.manual,
          createdAt: now,
        ),
      );
      await repository.addMeasurement(
        MeasurementRecord(
          id: 'measurement-2',
          profileId: 'profile-1',
          measuredAt: now.add(const Duration(days: 7)),
          origin: MeasurementOrigin.manual,
          createdAt: now.add(const Duration(days: 7)),
        ),
      );

      final measurements = await repository
          .watchMeasurements('profile-1')
          .firstWhere((items) => items.length == 2);

      expect(measurements.map((item) => item.id), [
        'measurement-2',
        'measurement-1',
      ]);
    },
  );

  test('onboarding preferences are saved and replaced locally', () async {
    await _saveProfile(container, now);
    final repository = container.read(onboardingRepositoryProvider);

    await repository.savePreferences(
      OnboardingPreferencesRecord(
        profileId: 'profile-1',
        goal: TrainingGoal.maximumStrength,
        experienceLevel: TrainingExperienceLevel.intermediate,
        equipment: const [
          EquipmentPreference.barbell,
          EquipmentPreference.bodyweight,
        ],
        preferredSessionLengthMinutes: 75,
        preferredWeekdays: const [
          TrainingWeekday.friday,
          TrainingWeekday.monday,
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );

    final saved = await repository
        .watchPreferences('profile-1')
        .firstWhere((value) => value != null);
    expect(saved?.goal, TrainingGoal.maximumStrength);
    expect(saved?.equipment, [
      EquipmentPreference.bodyweight,
      EquipmentPreference.barbell,
    ]);
    expect(saved?.preferredWeekdays, [
      TrainingWeekday.monday,
      TrainingWeekday.friday,
    ]);

    await repository.savePreferences(
      OnboardingPreferencesRecord(
        profileId: 'profile-1',
        goal: TrainingGoal.hypertrophy,
        experienceLevel: TrainingExperienceLevel.advanced,
        equipment: const [EquipmentPreference.dumbbells],
        preferredSessionLengthMinutes: 60,
        preferredWeekdays: const [TrainingWeekday.wednesday],
        createdAt: saved!.createdAt,
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
    );

    final updated = await repository.getPreferences('profile-1');
    expect(updated?.goal, TrainingGoal.hypertrophy);
    expect(updated?.experienceLevel, TrainingExperienceLevel.advanced);
    expect(updated?.equipment, [EquipmentPreference.dumbbells]);
    expect(updated?.preferredSessionLengthMinutes, 60);
    expect(updated?.preferredWeekdays, [TrainingWeekday.wednesday]);
    expect(
      await database.select(database.onboardingPreferences).get(),
      hasLength(1),
    );
  });

  test(
    'availability windows are replaced and emitted in weekday order',
    () async {
      await _saveProfile(container, now);
      final repository = container.read(availabilityRepositoryProvider);

      await repository.replaceWindows('profile-1', [
        AvailabilityWindowRecord(
          id: 'availability-friday',
          profileId: 'profile-1',
          weekday: TrainingWeekday.friday,
          windowType: AvailabilityWindowType.flexible,
          startMinute: 17 * 60,
          endMinute: 21 * 60,
          createdAt: now,
          updatedAt: now,
        ),
        AvailabilityWindowRecord(
          id: 'availability-monday',
          profileId: 'profile-1',
          weekday: TrainingWeekday.monday,
          windowType: AvailabilityWindowType.fixed,
          startMinute: 18 * 60,
          endMinute: 19 * 60,
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      final saved = await repository
          .watchWindows('profile-1')
          .firstWhere((items) => items.length == 2);
      expect(saved.map((window) => window.weekday), [
        TrainingWeekday.monday,
        TrainingWeekday.friday,
      ]);
      expect(saved.first.windowType, AvailabilityWindowType.fixed);
      expect(saved.last.windowType, AvailabilityWindowType.flexible);

      await repository.replaceWindows('profile-1', [
        AvailabilityWindowRecord(
          id: 'availability-wednesday',
          profileId: 'profile-1',
          weekday: TrainingWeekday.wednesday,
          windowType: AvailabilityWindowType.flexible,
          startMinute: 6 * 60,
          endMinute: 8 * 60,
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 1)),
        ),
      ]);

      final updated = await repository.getWindows('profile-1');
      expect(updated, hasLength(1));
      expect(updated.single.weekday, TrainingWeekday.wednesday);
      expect(updated.single.durationMinutes, 120);
      expect(
        await database.select(database.availabilityWindows).get(),
        hasLength(1),
      );
    },
  );
}

ProfileRecord _profile(DateTime now) => ProfileRecord(
  id: 'profile-1',
  displayName: 'Local Profile',
  preferredLocale: 'tr',
  unitPreference: UnitPreference.metric,
  createdAt: now,
  updatedAt: now,
);

ProgramRecord _program(DateTime now) => ProgramRecord(
  id: 'program-1',
  profileId: 'profile-1',
  name: 'Strength Base',
  lifecycle: ProgramLifecycle.active,
  createdAt: now,
  updatedAt: now,
);

ProgramVersionRecord _version(DateTime now) => ProgramVersionRecord(
  id: 'version-1',
  programId: 'program-1',
  versionNumber: 1,
  lifecycle: ProgramVersionLifecycle.active,
  createdAt: now,
  activatedAt: now,
);

PrescribedSetRecord _prescribedSet(
  DateTime now, {
  String id = 'prescribed-set-1',
  String programVersionId = 'version-1',
}) => PrescribedSetRecord(
  id: id,
  programVersionId: programVersionId,
  trainingDayOrder: 0,
  exerciseId: 'barbell-bench-press',
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

Future<void> _saveProfile(ProviderContainer container, DateTime now) =>
    container.read(profileRepositoryProvider).saveProfile(_profile(now));

Future<void> _saveProgramGraph(
  ProviderContainer container,
  DateTime now,
) async {
  await _saveProfile(container, now);
  final repository = container.read(programRepositoryProvider);
  await repository.saveProgram(_program(now));
  await repository.addVersion(
    _version(now),
    [_trainingDay(now)],
    [_prescribedSet(now)],
  );
}

ProgramTrainingDayRecord _trainingDay(DateTime now) => ProgramTrainingDayRecord(
  id: 'training-day-1',
  programVersionId: 'version-1',
  trainingDayOrder: 0,
  name: 'Upper A',
  createdAt: now,
);
