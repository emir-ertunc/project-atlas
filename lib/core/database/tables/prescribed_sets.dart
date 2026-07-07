import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';

enum ProgressionMode { none, manual, doubleProgression }

@DataClassName('PrescribedSetRow')
@TableIndex(
  name: 'prescribed_sets_version_day_idx',
  columns: {#programVersionId, #trainingDayOrder},
)
class PrescribedSets extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get programVersionId =>
      text().references(ProgramVersions, #id, onDelete: KeyAction.cascade)();

  IntColumn get trainingDayOrder => integer()();

  TextColumn get exerciseId => text().withLength(min: 1, max: 128)();

  IntColumn get exerciseOrder => integer()();

  IntColumn get setOrder => integer()();

  IntColumn get minimumRepetitions => integer()();

  IntColumn get maximumRepetitions => integer()();

  IntColumn get targetRir => integer().nullable()();

  RealColumn get loadKilograms => real().nullable()();

  IntColumn get restSeconds => integer()();

  TextColumn get progressionMode => textEnum<ProgressionMode>()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {programVersionId, trainingDayOrder, exerciseOrder, setOrder},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (training_day_order >= 0)',
    'CHECK (exercise_order >= 0)',
    'CHECK (set_order >= 0)',
    'CHECK (minimum_repetitions >= 1)',
    'CHECK (maximum_repetitions >= minimum_repetitions)',
    'CHECK (target_rir IS NULL OR target_rir BETWEEN 0 AND 10)',
    'CHECK (load_kilograms IS NULL OR load_kilograms >= 0)',
    'CHECK (rest_seconds >= 0)',
    "CHECK (progression_mode IN ('none', 'manual', 'doubleProgression'))",
  ];
}
