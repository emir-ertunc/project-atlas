import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';

enum ProgramStatus { draft, active, archived }

@DataClassName('ProgramRow')
@TableIndex(name: 'programs_profile_status_idx', columns: {#profileId, #status})
class Programs extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get status => textEnum<ProgramStatus>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('draft', 'active', 'archived'))",
  ];
}
