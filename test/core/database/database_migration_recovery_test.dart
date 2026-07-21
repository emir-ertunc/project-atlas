import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/tables/availability_windows.dart';
import 'package:project_atlas/core/database/tables/measurement_records.dart';
import 'package:project_atlas/core/database/tables/onboarding_preferences.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late Directory temporaryDirectory;
  late File databaseFile;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'project_atlas_database_test_',
    );
    databaseFile = File('${temporaryDirectory.path}/project_atlas.sqlite');
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('migrates the empty version 1 database to the current schema', () async {
    final legacy = sqlite.sqlite3.open(databaseFile.path);
    legacy.userVersion = 1;
    legacy.close();

    final database = _openDatabase(databaseFile);
    addTearDown(database.close);
    await database.customSelect('SELECT 1').getSingle();

    await _expectCurrentSchema(database, temporaryDirectory);
    expect(await _userVersion(database), database.schemaVersion);
    expect(
      await _schemaNames(database),
      containsAll(<String>{
        'profiles',
        'programs',
        'program_versions',
        'program_version_training_days',
        'prescribed_sets',
        'workout_sessions',
        'session_sets',
        'actual_set_logs',
        'measurement_records',
        'onboarding_preferences',
        'availability_windows',
      }),
    );
  });

  test('migrates version 2 data without losing core records', () async {
    await _createVersion2Database(databaseFile);

    final database = _openDatabase(databaseFile);
    addTearDown(database.close);
    await database.customSelect('SELECT 1').getSingle();

    await _expectCurrentSchema(database, temporaryDirectory);
    expect(await _userVersion(database), database.schemaVersion);
    expect(
      (await database.select(database.profiles).getSingle()).displayName,
      'Legacy Profile',
    );
    expect(
      (await database.select(database.programs).getSingle()).name,
      'Legacy Program',
    );
    final session = await database.select(database.workoutSessions).getSingle();
    expect(session.programVersionId, isNull);
    expect(
      (await database.select(database.sessionSets).getSingle()).prescribedSetId,
      isNull,
    );
    expect(
      await database.select(database.measurementRecords).get(),
      hasLength(1),
    );

    await database
        .into(database.programVersions)
        .insert(
          ProgramVersionsCompanion.insert(
            id: 'version-after-migration',
            programId: 'program-legacy',
            versionNumber: 1,
            status: ProgramVersionStatus.active,
          ),
        );
    expect(await database.select(database.programVersions).get(), hasLength(1));
    await database
        .into(database.programVersionTrainingDays)
        .insert(
          ProgramVersionTrainingDaysCompanion.insert(
            id: 'day-after-migration',
            programVersionId: 'version-after-migration',
            trainingDayOrder: 0,
            name: 'Day 1',
          ),
        );
    expect(
      await database.select(database.programVersionTrainingDays).get(),
      hasLength(1),
    );
  });

  test(
    'migrates version 3 databases by adding training-day snapshots',
    () async {
      await _createVersion3Database(databaseFile);

      final database = _openDatabase(databaseFile);
      addTearDown(database.close);
      await database.customSelect('SELECT 1').getSingle();

      await _expectCurrentSchema(database, temporaryDirectory);
      expect(await _userVersion(database), database.schemaVersion);
      await database
          .into(database.programVersionTrainingDays)
          .insert(
            ProgramVersionTrainingDaysCompanion.insert(
              id: 'day-after-v3-migration',
              programVersionId: 'version-v3',
              trainingDayOrder: 0,
              name: 'Upper A',
            ),
          );
      final days = await database
          .select(database.programVersionTrainingDays)
          .get();
      expect(days.single.name, 'Upper A');
    },
  );

  test(
    'migrates version 4 databases by adding onboarding preferences',
    () async {
      await _createVersion4Database(databaseFile);

      final database = _openDatabase(databaseFile);
      addTearDown(database.close);
      await database.customSelect('SELECT 1').getSingle();

      await _expectCurrentSchema(database, temporaryDirectory);
      expect(await _userVersion(database), database.schemaVersion);
      await database
          .into(database.onboardingPreferences)
          .insert(
            OnboardingPreferencesCompanion.insert(
              profileId: 'profile-v4',
              goal: StoredTrainingGoal.bodyRecomposition,
              experienceLevel: StoredTrainingExperienceLevel.beginner,
              equipmentIds: 'bodyweight,dumbbells',
              preferredSessionLengthMinutes: 45,
              preferredWeekdays: 'tuesday,thursday,saturday',
            ),
          );
      final preferences = await database
          .select(database.onboardingPreferences)
          .getSingle();
      expect(preferences.goal, StoredTrainingGoal.bodyRecomposition);
      expect(preferences.preferredSessionLengthMinutes, 45);
    },
  );

  test('migrates version 5 databases by adding availability windows', () async {
    await _createVersion5Database(databaseFile);

    final database = _openDatabase(databaseFile);
    addTearDown(database.close);
    await database.customSelect('SELECT 1').getSingle();

    await _expectCurrentSchema(database, temporaryDirectory);
    expect(await _userVersion(database), database.schemaVersion);
    await database
        .into(database.availabilityWindows)
        .insert(
          AvailabilityWindowsCompanion.insert(
            id: 'availability-after-v5-migration',
            profileId: 'profile-v5',
            weekday: StoredTrainingWeekday.saturday,
            windowType: StoredAvailabilityWindowType.flexible,
            startMinute: 9 * 60,
            endMinute: 12 * 60,
          ),
        );
    final window = await database
        .select(database.availabilityWindows)
        .getSingle();
    expect(window.weekday, StoredTrainingWeekday.saturday);
    expect(window.windowType, StoredAvailabilityWindowType.flexible);
  });

  test('migrates version 6 databases by adding body measurements', () async {
    await _createVersion6Database(databaseFile);

    final database = _openDatabase(databaseFile);
    addTearDown(database.close);
    await database.customSelect('SELECT 1').getSingle();

    await _expectCurrentSchema(database, temporaryDirectory);
    expect(await _userVersion(database), database.schemaVersion);
    final legacyMeasurement = await database
        .select(database.measurementRecords)
        .getSingle();
    expect(legacyMeasurement.id, 'measurement-v6');
    expect(legacyMeasurement.heightCentimeters, isNull);
    expect(legacyMeasurement.bodyFatPercentage, isNull);
    expect(legacyMeasurement.bodyMeasurementMethod, isNull);
    expect(legacyMeasurement.bodyFatMeasurementMethod, isNull);

    await database
        .into(database.measurementRecords)
        .insert(
          MeasurementRecordsCompanion.insert(
            id: 'measurement-after-v6-migration',
            profileId: 'profile-v6',
            measuredAt: DateTime.utc(2026, 7, 21, 9),
            source: MeasurementSource.manual,
            heightCentimeters: const Value(181),
            weightKilograms: const Value(84),
            torsoLengthCentimeters: const Value(62),
            chestCircumferenceCentimeters: const Value(104),
            waistCircumferenceCentimeters: const Value(87),
            hipCircumferenceCentimeters: const Value(100),
            leftUpperArmCircumferenceCentimeters: const Value(35),
            rightUpperArmCircumferenceCentimeters: const Value(35.5),
            leftForearmCircumferenceCentimeters: const Value(29),
            rightForearmCircumferenceCentimeters: const Value(29.5),
            leftThighCircumferenceCentimeters: const Value(60),
            rightThighCircumferenceCentimeters: const Value(60.5),
            leftCalfCircumferenceCentimeters: const Value(39),
            rightCalfCircumferenceCentimeters: const Value(39.5),
            bodyFatPercentage: const Value(17),
            bodyMeasurementMethod: const Value(
              StoredBodyMeasurementMethod.tapeMeasure,
            ),
            bodyFatMeasurementMethod: const Value(
              StoredBodyFatMeasurementMethod.caliper,
            ),
          ),
        );

    final measurements = await database
        .select(database.measurementRecords)
        .get();
    final current = measurements.singleWhere(
      (measurement) => measurement.id == 'measurement-after-v6-migration',
    );
    expect(current.heightCentimeters, 181);
    expect(current.weightKilograms, 84);
    expect(current.torsoLengthCentimeters, 62);
    expect(current.leftUpperArmCircumferenceCentimeters, 35);
    expect(current.rightCalfCircumferenceCentimeters, 39.5);
    expect(current.bodyFatPercentage, 17);
    expect(
      current.bodyMeasurementMethod,
      StoredBodyMeasurementMethod.tapeMeasure,
    );
    expect(
      current.bodyFatMeasurementMethod,
      StoredBodyFatMeasurementMethod.caliper,
    );
  });

  test('migrates version 7 databases by adding body-fat metadata', () async {
    await _createVersion7Database(databaseFile);

    final database = _openDatabase(databaseFile);
    addTearDown(database.close);
    await database.customSelect('SELECT 1').getSingle();

    await _expectCurrentSchema(database, temporaryDirectory);
    expect(await _userVersion(database), database.schemaVersion);
    final legacyMeasurement = await database
        .select(database.measurementRecords)
        .getSingle();
    expect(legacyMeasurement.id, 'measurement-v7');
    expect(legacyMeasurement.weightKilograms, 83);
    expect(legacyMeasurement.bodyFatPercentage, isNull);
    expect(legacyMeasurement.bodyMeasurementMethod, isNull);
    expect(legacyMeasurement.bodyFatMeasurementMethod, isNull);

    await database
        .into(database.measurementRecords)
        .insert(
          MeasurementRecordsCompanion.insert(
            id: 'measurement-after-v7-migration',
            profileId: 'profile-v7',
            measuredAt: DateTime.utc(2026, 7, 21, 10),
            source: MeasurementSource.manual,
            weightKilograms: const Value(82.5),
            bodyFatPercentage: const Value(16.5),
            bodyMeasurementMethod: const Value(
              StoredBodyMeasurementMethod.smartScale,
            ),
            bodyFatMeasurementMethod: const Value(
              StoredBodyFatMeasurementMethod.bioelectricalImpedance,
            ),
          ),
        );

    final measurements = await database
        .select(database.measurementRecords)
        .get();
    final current = measurements.singleWhere(
      (measurement) => measurement.id == 'measurement-after-v7-migration',
    );
    expect(current.weightKilograms, 82.5);
    expect(current.bodyFatPercentage, 16.5);
    expect(
      current.bodyMeasurementMethod,
      StoredBodyMeasurementMethod.smartScale,
    );
    expect(
      current.bodyFatMeasurementMethod,
      StoredBodyFatMeasurementMethod.bioelectricalImpedance,
    );
  });

  test(
    'restores committed workout state and rolls back interrupted work',
    () async {
      var database = _openDatabase(databaseFile);
      await _insertRecoverableWorkout(database);
      await database.close();

      database = _openDatabase(databaseFile);
      var session = await database.select(database.workoutSessions).getSingle();
      var sessionSet = await database.select(database.sessionSets).getSingle();
      var logs = await database.select(database.actualSetLogs).get();
      expect(session.status, WorkoutSessionStatus.inProgress);
      expect(sessionSet.status, SessionSetStatus.completed);
      expect(logs.single.repetitions, 6);
      await database.close();

      final interrupted = sqlite.sqlite3.open(databaseFile.path);
      interrupted.execute('BEGIN IMMEDIATE');
      interrupted.execute(
        "UPDATE session_sets SET status = 'skipped' WHERE id = 'set-1'",
      );
      interrupted.execute(
        'INSERT INTO actual_set_logs '
        '(id, session_set_id, revision, repetitions) '
        "VALUES ('log-uncommitted', 'set-1', 2, 5)",
      );
      interrupted.close();

      database = _openDatabase(databaseFile);
      addTearDown(database.close);
      session = await database.select(database.workoutSessions).getSingle();
      sessionSet = await database.select(database.sessionSets).getSingle();
      logs = await database.select(database.actualSetLogs).get();

      expect(session.status, WorkoutSessionStatus.inProgress);
      expect(sessionSet.status, SessionSetStatus.completed);
      expect(logs.map((log) => log.id), ['log-1']);
      expect(await _foreignKeysEnabled(database), isTrue);
    },
  );
}

AppDatabase _openDatabase(File file) =>
    AppDatabase.forTesting(NativeDatabase(file));

Future<int> _userVersion(AppDatabase database) async {
  final row = await database.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
}

Future<bool> _foreignKeysEnabled(AppDatabase database) async {
  final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
  return row.read<int>('foreign_keys') == 1;
}

Future<Set<String>> _schemaNames(AppDatabase database) async {
  final rows = await database
      .customSelect(
        "SELECT name FROM sqlite_schema WHERE type IN ('table', 'index')",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<void> _expectCurrentSchema(
  AppDatabase migrated,
  Directory directory,
) async {
  final referenceFile = File('${directory.path}/reference.sqlite');
  final reference = _openDatabase(referenceFile);
  await reference.customSelect('SELECT 1').getSingle();

  try {
    expect(await _schemaSnapshot(migrated), await _schemaSnapshot(reference));
    expect(
      await migrated.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
    final integrity = await migrated
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.read<String>('integrity_check'), 'ok');
  } finally {
    await reference.close();
  }
}

Future<Map<String, List<String>>> _schemaSnapshot(AppDatabase database) async {
  final tableRows = await database
      .customSelect(
        "SELECT name FROM sqlite_schema WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  final tables = tableRows.map((row) => row.read<String>('name')).toList();
  final snapshot = <String, List<String>>{};

  for (final table in tables) {
    final escapedTable = table.replaceAll('"', '""');
    final columnRows = await database
        .customSelect('PRAGMA table_info("$escapedTable")')
        .get();
    snapshot['$table:columns'] =
        columnRows
            .map(
              (row) => <Object?>[
                row.read<String>('name'),
                row.read<String>('type'),
                row.read<int>('notnull'),
                row.read<String?>('dflt_value'),
                row.read<int>('pk'),
              ].join('|'),
            )
            .toList()
          ..sort();

    final foreignKeyRows = await database
        .customSelect('PRAGMA foreign_key_list("$escapedTable")')
        .get();
    snapshot['$table:foreignKeys'] =
        foreignKeyRows
            .map(
              (row) => <Object?>[
                row.read<String>('from'),
                row.read<String>('table'),
                row.read<String>('to'),
                row.read<String>('on_update'),
                row.read<String>('on_delete'),
              ].join('|'),
            )
            .toList()
          ..sort();

    final indexRows = await database
        .customSelect('PRAGMA index_list("$escapedTable")')
        .get();
    final indexes = <String>[];
    for (final row in indexRows) {
      final indexName = row.read<String>('name');
      final escapedIndex = indexName.replaceAll('"', '""');
      final indexColumns = await database
          .customSelect('PRAGMA index_info("$escapedIndex")')
          .get();
      indexes.add(
        <Object?>[
          indexName,
          row.read<int>('unique'),
          row.read<String>('origin'),
          row.read<int>('partial'),
          indexColumns.map((column) => column.read<String>('name')).join(','),
        ].join('|'),
      );
    }
    snapshot['$table:indexes'] = indexes..sort();
  }

  return snapshot;
}

Future<void> _createVersion2Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  legacy.execute('DROP INDEX workout_sessions_program_version_idx');
  legacy.execute('DROP INDEX session_sets_prescribed_set_idx');
  legacy.execute('DROP INDEX program_version_training_days_version_idx');
  legacy.execute('ALTER TABLE workout_sessions DROP COLUMN program_version_id');
  legacy.execute('ALTER TABLE session_sets DROP COLUMN prescribed_set_id');
  legacy.execute('DROP TABLE actual_set_logs');
  legacy.execute('DROP TABLE prescribed_sets');
  legacy.execute('DROP TABLE program_version_training_days');
  legacy.execute('DROP TABLE program_versions');
  legacy.execute('DROP TABLE availability_windows');
  legacy.execute('DROP TABLE onboarding_preferences');
  _dropP6MeasurementColumns(legacy);
  legacy.userVersion = 2;

  legacy.execute(
    'INSERT INTO profiles '
    '(id, display_name, preferred_locale, unit_system) '
    "VALUES ('profile-legacy', 'Legacy Profile', 'tr', 'metric')",
  );
  legacy.execute(
    'INSERT INTO programs (id, profile_id, name, status) '
    "VALUES ('program-legacy', 'profile-legacy', 'Legacy Program', 'active')",
  );
  legacy.execute(
    'INSERT INTO workout_sessions (id, profile_id, program_id, status) '
    "VALUES ('session-legacy', 'profile-legacy', 'program-legacy', 'planned')",
  );
  legacy.execute(
    'INSERT INTO session_sets '
    '(id, session_id, exercise_id, exercise_order, set_order, status) '
    "VALUES ('set-legacy', 'session-legacy', 'bench-press', 0, 0, 'planned')",
  );
  legacy.execute(
    'INSERT INTO measurement_records '
    '(id, profile_id, measured_at, source) '
    "VALUES ('measurement-legacy', 'profile-legacy', "
    "strftime('%s', '2026-07-01 09:00:00'), 'manual')",
  );
  legacy.close();
}

Future<void> _createVersion3Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current
      .into(current.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-v3',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await current.customStatement(
    "INSERT INTO programs (id, profile_id, name, status) "
    "VALUES ('program-v3', 'profile-v3', 'Version 3 Program', 'active')",
  );
  await current
      .into(current.programVersions)
      .insert(
        ProgramVersionsCompanion.insert(
          id: 'version-v3',
          programId: 'program-v3',
          versionNumber: 1,
          status: ProgramVersionStatus.active,
        ),
      );
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  legacy.execute('DROP INDEX program_version_training_days_version_idx');
  legacy.execute('DROP TABLE program_version_training_days');
  legacy.execute('DROP TABLE availability_windows');
  legacy.execute('DROP TABLE onboarding_preferences');
  _dropP6MeasurementColumns(legacy);
  legacy.userVersion = 3;
  legacy.close();
}

Future<void> _createVersion4Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current
      .into(current.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-v4',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  legacy.execute('DROP TABLE availability_windows');
  legacy.execute('DROP TABLE onboarding_preferences');
  _dropP6MeasurementColumns(legacy);
  legacy.userVersion = 4;
  legacy.close();
}

Future<void> _createVersion5Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current
      .into(current.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-v5',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  legacy.execute('DROP TABLE availability_windows');
  _dropP6MeasurementColumns(legacy);
  legacy.userVersion = 5;
  legacy.close();
}

Future<void> _createVersion6Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current
      .into(current.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-v6',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await current
      .into(current.measurementRecords)
      .insert(
        MeasurementRecordsCompanion.insert(
          id: 'measurement-v6',
          profileId: 'profile-v6',
          measuredAt: DateTime.utc(2026, 7, 1, 9),
          source: MeasurementSource.manual,
        ),
      );
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  _dropP6MeasurementColumns(legacy);
  legacy.userVersion = 6;
  legacy.close();
}

Future<void> _createVersion7Database(File file) async {
  final current = _openDatabase(file);
  await current.customSelect('SELECT 1').getSingle();
  await current
      .into(current.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-v7',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await current
      .into(current.measurementRecords)
      .insert(
        MeasurementRecordsCompanion.insert(
          id: 'measurement-v7',
          profileId: 'profile-v7',
          measuredAt: DateTime.utc(2026, 7, 7, 9),
          source: MeasurementSource.manual,
          heightCentimeters: const Value(180),
          weightKilograms: const Value(83),
          torsoLengthCentimeters: const Value(61),
          chestCircumferenceCentimeters: const Value(103),
        ),
      );
  await current.close();

  final legacy = sqlite.sqlite3.open(file.path);
  _dropP602MeasurementColumns(legacy);
  legacy.userVersion = 7;
  legacy.close();
}

void _dropP6MeasurementColumns(sqlite.Database legacy) {
  for (final column in _p6MeasurementColumns) {
    legacy.execute('ALTER TABLE measurement_records DROP COLUMN $column');
  }
}

void _dropP602MeasurementColumns(sqlite.Database legacy) {
  for (final column in _p602MeasurementColumns) {
    legacy.execute('ALTER TABLE measurement_records DROP COLUMN $column');
  }
}

const _p6MeasurementColumns = [
  'height_centimeters',
  'weight_kilograms',
  'torso_length_centimeters',
  'chest_circumference_centimeters',
  'waist_circumference_centimeters',
  'hip_circumference_centimeters',
  'left_upper_arm_circumference_centimeters',
  'right_upper_arm_circumference_centimeters',
  'left_forearm_circumference_centimeters',
  'right_forearm_circumference_centimeters',
  'left_thigh_circumference_centimeters',
  'right_thigh_circumference_centimeters',
  'left_calf_circumference_centimeters',
  'right_calf_circumference_centimeters',
  ..._p602MeasurementColumns,
];

const _p602MeasurementColumns = [
  'body_fat_percentage',
  'body_measurement_method',
  'body_fat_measurement_method',
];

Future<void> _insertRecoverableWorkout(AppDatabase database) async {
  await database
      .into(database.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: 'profile-1',
          unitSystem: UnitSystemPreference.metric,
        ),
      );
  await database
      .into(database.workoutSessions)
      .insert(
        WorkoutSessionsCompanion.insert(
          id: 'session-1',
          profileId: 'profile-1',
          status: WorkoutSessionStatus.inProgress,
          startedAt: Value(DateTime.utc(2026, 7, 7, 12)),
        ),
      );
  await database
      .into(database.sessionSets)
      .insert(
        SessionSetsCompanion.insert(
          id: 'set-1',
          sessionId: 'session-1',
          exerciseId: 'bench-press',
          exerciseOrder: 0,
          setOrder: 0,
          status: SessionSetStatus.completed,
        ),
      );
  await database
      .into(database.actualSetLogs)
      .insert(
        ActualSetLogsCompanion.insert(
          id: 'log-1',
          sessionSetId: 'set-1',
          revision: 1,
          repetitions: const Value(6),
          loadKilograms: const Value(50),
          rir: const Value(2),
        ),
      );
}
