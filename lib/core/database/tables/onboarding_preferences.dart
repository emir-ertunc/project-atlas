import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';

enum StoredTrainingGoal {
  generalFitness,
  hypertrophy,
  maximumStrength,
  bodyRecomposition,
  muscularEndurance,
  athleticPerformance,
  maintenance,
}

enum StoredTrainingExperienceLevel {
  newToTraining,
  beginner,
  intermediate,
  advanced,
}

@DataClassName('OnboardingPreferenceRow')
class OnboardingPreferences extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get goal => textEnum<StoredTrainingGoal>()();

  TextColumn get experienceLevel => textEnum<StoredTrainingExperienceLevel>()();

  TextColumn get equipmentIds => text().withLength(min: 1, max: 500)();

  IntColumn get preferredSessionLengthMinutes => integer()();

  TextColumn get preferredWeekdays => text().withLength(min: 1, max: 80)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {profileId};

  @override
  List<String> get customConstraints => [
    "CHECK (goal IN ('generalFitness', 'hypertrophy', 'maximumStrength', "
        "'bodyRecomposition', 'muscularEndurance', 'athleticPerformance', "
        "'maintenance'))",
    "CHECK (experience_level IN ('newToTraining', 'beginner', "
        "'intermediate', 'advanced'))",
    "CHECK (equipment_ids <> '')",
    'CHECK (preferred_session_length_minutes BETWEEN 20 AND 180)',
    "CHECK (preferred_weekdays <> '')",
  ];
}
