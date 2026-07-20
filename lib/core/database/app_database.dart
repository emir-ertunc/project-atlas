import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:project_atlas/core/database/tables/actual_set_logs.dart';
import 'package:project_atlas/core/database/tables/measurement_records.dart';
import 'package:project_atlas/core/database/tables/prescribed_sets.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';
import 'package:project_atlas/core/database/tables/program_version_training_days.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';
import 'package:project_atlas/core/database/tables/programs.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Programs,
    ProgramVersions,
    ProgramVersionTrainingDays,
    PrescribedSets,
    WorkoutSessions,
    SessionSets,
    ActualSetLogs,
    MeasurementRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase.defaults() : super(driftDatabase(name: 'project_atlas'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createAll();
        return;
      }
      if (from < 3) {
        await migrator.createTable(programVersions);
        await migrator.createTable(programVersionTrainingDays);
        await migrator.createTable(prescribedSets);
        await migrator.addColumn(
          workoutSessions,
          workoutSessions.programVersionId,
        );
        await migrator.addColumn(sessionSets, sessionSets.prescribedSetId);
        await migrator.createTable(actualSetLogs);
        await customStatement(
          'CREATE INDEX program_versions_program_status_idx '
          'ON program_versions (program_id, status)',
        );
        await customStatement(
          'CREATE INDEX program_version_training_days_version_idx '
          'ON program_version_training_days (program_version_id)',
        );
        await customStatement(
          'CREATE INDEX prescribed_sets_version_day_idx '
          'ON prescribed_sets (program_version_id, training_day_order)',
        );
        await customStatement(
          'CREATE INDEX workout_sessions_program_version_idx '
          'ON workout_sessions (program_version_id)',
        );
        await customStatement(
          'CREATE INDEX session_sets_prescribed_set_idx '
          'ON session_sets (prescribed_set_id)',
        );
        await customStatement(
          'CREATE INDEX actual_set_logs_session_set_recorded_idx '
          'ON actual_set_logs (session_set_id, recorded_at)',
        );
      }
      if (from == 3) {
        await migrator.createTable(programVersionTrainingDays);
        await customStatement(
          'CREATE INDEX program_version_training_days_version_idx '
          'ON program_version_training_days (program_version_id)',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
