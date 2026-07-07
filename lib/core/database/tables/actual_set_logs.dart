import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';

enum SetOutcome {
  strengthLimitation,
  techniqueLimitation,
  pain,
  timeLimitation,
  equipmentLimitation,
  externalInterruption,
}

@DataClassName('ActualSetLogRow')
@TableIndex(
  name: 'actual_set_logs_session_set_recorded_idx',
  columns: {#sessionSetId, #recordedAt},
)
class ActualSetLogs extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get sessionSetId =>
      text().references(SessionSets, #id, onDelete: KeyAction.cascade)();

  IntColumn get revision => integer()();

  IntColumn get repetitions => integer().nullable()();

  RealColumn get loadKilograms => real().nullable()();

  IntColumn get rir => integer().nullable()();

  TextColumn get outcome => textEnum<SetOutcome>().nullable()();

  TextColumn get notes => text().withLength(max: 1000).nullable()();

  TextColumn get supersedesLogId => text()
      .references(ActualSetLogs, #id, onDelete: KeyAction.setNull)
      .nullable()();

  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionSetId, revision},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (revision >= 1)',
    'CHECK (repetitions IS NULL OR repetitions >= 0)',
    'CHECK (load_kilograms IS NULL OR load_kilograms >= 0)',
    'CHECK (rir IS NULL OR rir BETWEEN 0 AND 10)',
    "CHECK (outcome IS NULL OR outcome IN ('strengthLimitation', "
        "'techniqueLimitation', 'pain', 'timeLimitation', "
        "'equipmentLimitation', 'externalInterruption'))",
    'CHECK (repetitions IS NOT NULL OR load_kilograms IS NOT NULL OR '
        'rir IS NOT NULL OR outcome IS NOT NULL)',
  ];
}
