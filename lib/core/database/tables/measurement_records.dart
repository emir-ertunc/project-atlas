import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';

enum MeasurementSource { manual, imported }

@DataClassName('MeasurementRecordRow')
@TableIndex(
  name: 'measurement_records_profile_measured_idx',
  columns: {#profileId, #measuredAt},
)
class MeasurementRecords extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get measuredAt => dateTime()();

  TextColumn get source => textEnum<MeasurementSource>()();

  TextColumn get notes => text().withLength(max: 2000).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (source IN ('manual', 'imported'))",
  ];
}
