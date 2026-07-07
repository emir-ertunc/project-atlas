import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/prescribed_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';

enum SessionSetStatus { planned, completed, skipped }

@DataClassName('SessionSetRow')
@TableIndex(
  name: 'session_sets_session_exercise_idx',
  columns: {#sessionId, #exerciseId},
)
@TableIndex(
  name: 'session_sets_prescribed_set_idx',
  columns: {#prescribedSetId},
)
class SessionSets extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();

  TextColumn get prescribedSetId => text()
      .references(PrescribedSets, #id, onDelete: KeyAction.setNull)
      .nullable()();

  TextColumn get exerciseId => text().withLength(min: 1, max: 128)();

  IntColumn get exerciseOrder => integer()();

  IntColumn get setOrder => integer()();

  TextColumn get status => textEnum<SessionSetStatus>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, exerciseOrder, setOrder},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('planned', 'completed', 'skipped'))",
    'CHECK (exercise_order >= 0)',
    'CHECK (set_order >= 0)',
  ];
}
