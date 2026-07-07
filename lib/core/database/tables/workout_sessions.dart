import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';
import 'package:project_atlas/core/database/tables/programs.dart';

enum WorkoutSessionStatus { planned, inProgress, completed, cancelled }

@DataClassName('WorkoutSessionRow')
@TableIndex(
  name: 'workout_sessions_profile_scheduled_idx',
  columns: {#profileId, #scheduledAt},
)
@TableIndex(name: 'workout_sessions_program_idx', columns: {#programId})
@TableIndex(
  name: 'workout_sessions_program_version_idx',
  columns: {#programVersionId},
)
class WorkoutSessions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get programId => text()
      .references(Programs, #id, onDelete: KeyAction.setNull)
      .nullable()();

  TextColumn get programVersionId => text()
      .references(ProgramVersions, #id, onDelete: KeyAction.setNull)
      .nullable()();

  TextColumn get status => textEnum<WorkoutSessionStatus>()();

  DateTimeColumn get scheduledAt => dateTime().nullable()();

  DateTimeColumn get startedAt => dateTime().nullable()();

  DateTimeColumn get endedAt => dateTime().nullable()();

  TextColumn get notes => text().withLength(max: 2000).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('planned', 'inProgress', 'completed', 'cancelled'))",
    'CHECK (ended_at IS NULL OR started_at IS NULL OR ended_at >= started_at)',
  ];
}
