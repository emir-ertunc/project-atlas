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
