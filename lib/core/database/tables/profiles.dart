import 'package:drift/drift.dart';

enum UnitSystemPreference { metric, imperial }

@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get displayName => text().withLength(max: 120).nullable()();

  TextColumn get preferredLocale =>
      text().withLength(min: 2, max: 16).nullable()();

  TextColumn get unitSystem => textEnum<UnitSystemPreference>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (unit_system IN ('metric', 'imperial'))",
  ];
}
