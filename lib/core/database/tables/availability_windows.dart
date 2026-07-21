import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';

enum StoredTrainingWeekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum StoredAvailabilityWindowType { fixed, flexible }

@DataClassName('AvailabilityWindowRow')
@TableIndex(
  name: 'availability_windows_profile_weekday_idx',
  columns: {#profileId, #weekday},
)
class AvailabilityWindows extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get weekday => textEnum<StoredTrainingWeekday>()();

  TextColumn get windowType => textEnum<StoredAvailabilityWindowType>()();

  IntColumn get startMinute => integer()();

  IntColumn get endMinute => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {profileId, weekday, windowType, startMinute, endMinute},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (weekday IN ('monday', 'tuesday', 'wednesday', 'thursday', "
        "'friday', 'saturday', 'sunday'))",
    "CHECK (window_type IN ('fixed', 'flexible'))",
    'CHECK (start_minute BETWEEN 0 AND 1439)',
    'CHECK (end_minute BETWEEN 1 AND 1440)',
    'CHECK (end_minute > start_minute)',
  ];
}
