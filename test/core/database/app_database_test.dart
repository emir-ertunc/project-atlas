import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/database/tables/availability_windows.dart';
import 'package:project_atlas/core/database/tables/measurement_records.dart';
import 'package:project_atlas/core/database/tables/onboarding_preferences.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';
import 'package:project_atlas/core/database/tables/programs.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the current core schema with foreign keys enabled', () async {
    final schemaRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')",
        )
        .get();
    final schemaNames = schemaRows
        .map((row) => row.read<String>('name'))
        .toSet();
    final foreignKeys = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();

    expect(database.schemaVersion, 6);
    expect(
      schemaNames,
      containsAll(<String>{
        'profiles',
        'programs',
        'workout_sessions',
        'session_sets',
        'measurement_records',
        'program_versions',
        'program_version_training_days',
        'prescribed_sets',
        'onboarding_preferences',
        'availability_windows',
        'availability_windows_profile_weekday_idx',
        'programs_profile_status_idx',
        'program_versions_program_status_idx',
        'program_version_training_days_version_idx',
        'prescribed_sets_version_day_idx',
        'workout_sessions_profile_scheduled_idx',
        'workout_sessions_program_idx',
        'session_sets_session_exercise_idx',
        'measurement_records_profile_measured_idx',
      }),
    );
    expect(foreignKeys.read<int>('foreign_keys'), 1);
  });

  test('stores and reads the core profile training graph', () async {
    final measuredAt = DateTime.utc(2026, 7, 7, 9);

    await _insertProfile(database);
    await _insertOnboardingPreferences(database);
    await _insertAvailabilityWindow(database);
    await _insertProgram(database);
    await _insertSession(database);
    await _insertSet(database);
    await database
        .into(database.measurementRecords)
        .insert(
          MeasurementRecordsCompanion.insert(
            id: 'measurement-1',
            profileId: 'profile-1',
            measuredAt: measuredAt,
            source: MeasurementSource.manual,
            notes: const Value('Baseline'),
          ),
        );

    expect(
      (await database.select(database.profiles).getSingle()).unitSystem,
      UnitSystemPreference.metric,
    );
    expect(
      (await database.select(database.programs).getSingle()).status,
      ProgramStatus.active,
    );
    expect(
      (await database.select(database.workoutSessions).getSingle()).status,
      WorkoutSessionStatus.planned,
    );
    expect(
      (await database.select(database.sessionSets).getSingle()).status,
      SessionSetStatus.completed,
    );
    final measurement = await database
        .select(database.measurementRecords)
        .getSingle();
    final preferences = await database
        .select(database.onboardingPreferences)
        .getSingle();
    expect(measurement.source, MeasurementSource.manual);
    expect(measurement.measuredAt.toUtc(), measuredAt);
    expect(preferences.goal, StoredTrainingGoal.hypertrophy);
    expect(
      preferences.experienceLevel,
      StoredTrainingExperienceLevel.intermediate,
    );
    expect(preferences.equipmentIds, 'bodyweight,dumbbells,barbell');
    expect(preferences.preferredSessionLengthMinutes, 60);
    expect(preferences.preferredWeekdays, 'monday,wednesday,friday');
    final availabilityWindow = await database
        .select(database.availabilityWindows)
        .getSingle();
    expect(availabilityWindow.weekday, StoredTrainingWeekday.monday);
    expect(availabilityWindow.windowType, StoredAvailabilityWindowType.fixed);
    expect(availabilityWindow.startMinute, 18 * 60);
    expect(availabilityWindow.endMinute, 19 * 60);
  });

  test('deleting a profile cascades through its owned records', () async {
    await _insertProfile(database);
    await _insertOnboardingPreferences(database);
    await _insertAvailabilityWindow(database);
    await _insertProgram(database);
    await _insertSession(database);
    await _insertSet(database);
    await database
        .into(database.measurementRecords)
        .insert(
          MeasurementRecordsCompanion.insert(
            id: 'measurement-1',
            profileId: 'profile-1',
            measuredAt: DateTime.utc(2026, 7, 7),
            source: MeasurementSource.imported,
          ),
        );

    await (database.delete(
      database.profiles,
    )..where((row) => row.id.equals('profile-1'))).go();

    expect(await database.select(database.programs).get(), isEmpty);
    expect(await database.select(database.workoutSessions).get(), isEmpty);
    expect(await database.select(database.sessionSets).get(), isEmpty);
    expect(await database.select(database.measurementRecords).get(), isEmpty);
    expect(
      await database.select(database.onboardingPreferences).get(),
      isEmpty,
    );
    expect(await database.select(database.availabilityWindows).get(), isEmpty);
  });

  test(
    'deleting a program preserves history and clears its session link',
    () async {
      await _insertProfile(database);
      await _insertProgram(database);
      await _insertSession(database);

      await (database.delete(
        database.programs,
      )..where((row) => row.id.equals('program-1'))).go();

      final session = await database
          .select(database.workoutSessions)
          .getSingle();
      expect(session.programId, isNull);
    },
  );

  test('rejects duplicate and negative session set positions', () async {
    await _insertProfile(database);
    await _insertSession(database, withProgram: false);
    await _insertSet(database);

    expect(() => _insertSet(database, id: 'set-2'), throwsA(isA<Exception>()));
    expect(
      () => _insertSet(database, id: 'set-3', exerciseOrder: -1),
      throwsA(isA<Exception>()),
    );
  });

  test('rejects a session ending before it starts', () async {
    await _insertProfile(database);

    expect(
      () => database
          .into(database.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'session-invalid',
              profileId: 'profile-1',
              status: WorkoutSessionStatus.completed,
              startedAt: Value(DateTime.utc(2026, 7, 7, 10)),
              endedAt: Value(DateTime.utc(2026, 7, 7, 9)),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('supports a provider override for isolated tests', () {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    expect(container.read(appDatabaseProvider), same(database));
  });
}

Future<void> _insertProfile(AppDatabase database) {
  return database
      .into(database.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-1',
          displayName: const Value('Test Profile'),
          preferredLocale: const Value('tr'),
          unitSystem: UnitSystemPreference.metric,
        ),
      );
}

Future<void> _insertProgram(AppDatabase database) {
  return database
      .into(database.programs)
      .insert(
        ProgramsCompanion.insert(
          id: 'program-1',
          profileId: 'profile-1',
          name: 'Foundation',
          status: ProgramStatus.active,
        ),
      );
}

Future<void> _insertOnboardingPreferences(AppDatabase database) {
  return database
      .into(database.onboardingPreferences)
      .insert(
        OnboardingPreferencesCompanion.insert(
          profileId: 'profile-1',
          goal: StoredTrainingGoal.hypertrophy,
          experienceLevel: StoredTrainingExperienceLevel.intermediate,
          equipmentIds: 'bodyweight,dumbbells,barbell',
          preferredSessionLengthMinutes: 60,
          preferredWeekdays: 'monday,wednesday,friday',
        ),
      );
}

Future<void> _insertAvailabilityWindow(AppDatabase database) {
  return database
      .into(database.availabilityWindows)
      .insert(
        AvailabilityWindowsCompanion.insert(
          id: 'availability-1',
          profileId: 'profile-1',
          weekday: StoredTrainingWeekday.monday,
          windowType: StoredAvailabilityWindowType.fixed,
          startMinute: 18 * 60,
          endMinute: 19 * 60,
        ),
      );
}

Future<void> _insertSession(AppDatabase database, {bool withProgram = true}) {
  return database
      .into(database.workoutSessions)
      .insert(
        WorkoutSessionsCompanion.insert(
          id: 'session-1',
          profileId: 'profile-1',
          programId: withProgram
              ? const Value('program-1')
              : const Value.absent(),
          status: WorkoutSessionStatus.planned,
          scheduledAt: Value(DateTime.utc(2026, 7, 8, 18)),
        ),
      );
}

Future<void> _insertSet(
  AppDatabase database, {
  String id = 'set-1',
  int exerciseOrder = 0,
}) {
  return database
      .into(database.sessionSets)
      .insert(
        SessionSetsCompanion.insert(
          id: id,
          sessionId: 'session-1',
          exerciseId: 'barbell-bench-press',
          exerciseOrder: exerciseOrder,
          setOrder: 0,
          status: SessionSetStatus.completed,
        ),
      );
}
