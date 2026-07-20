import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';

@DataClassName('ProgramVersionTrainingDayRow')
@TableIndex(
  name: 'program_version_training_days_version_idx',
  columns: {#programVersionId},
)
class ProgramVersionTrainingDays extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get programVersionId =>
      text().references(ProgramVersions, #id, onDelete: KeyAction.cascade)();

  IntColumn get trainingDayOrder => integer()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {programVersionId, trainingDayOrder},
  ];

  @override
  List<String> get customConstraints => ['CHECK (training_day_order >= 0)'];
}
