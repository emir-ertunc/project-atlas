import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/programs.dart';

enum ProgramVersionStatus { draft, active, retired }

@DataClassName('ProgramVersionRow')
@TableIndex(
  name: 'program_versions_program_status_idx',
  columns: {#programId, #status},
)
class ProgramVersions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get programId =>
      text().references(Programs, #id, onDelete: KeyAction.cascade)();

  IntColumn get versionNumber => integer()();

  TextColumn get status => textEnum<ProgramVersionStatus>()();

  TextColumn get label => text().withLength(max: 120).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get activatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {programId, versionNumber},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (version_number >= 1)',
    "CHECK (status IN ('draft', 'active', 'retired'))",
  ];
}
