import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/program_generator.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  late ExerciseCatalog catalog;
  final now = DateTime.utc(2026, 7, 21, 12);

  setUpAll(() {
    catalog = _loadCatalog();
  });

  test('builds a bounded weekly plan from availability and volume limits', () {
    final preferences = _preferences(
      now,
      goal: TrainingGoal.hypertrophy,
      experienceLevel: TrainingExperienceLevel.advanced,
      equipment: const [
        EquipmentPreference.bodyweight,
        EquipmentPreference.dumbbells,
        EquipmentPreference.barbell,
      ],
      preferredSessionLengthMinutes: 60,
      preferredWeekdays: TrainingWeekday.values,
    );

    final plan = buildAdaptiveProgramPlan(
      preferences: preferences,
      availabilityWindows: [
        _window(now, TrainingWeekday.monday, startMinute: 18 * 60),
        _window(now, TrainingWeekday.tuesday, startMinute: 18 * 60),
        _window(now, TrainingWeekday.thursday, startMinute: 18 * 60),
        _window(now, TrainingWeekday.saturday, startMinute: 18 * 60),
        _window(now, TrainingWeekday.sunday, startMinute: 18 * 60),
      ],
      catalog: catalog,
    );

    expect(plan.ruleSetVersion, adaptiveProgramPlannerRuleSetVersion);
    expect(plan.sessionsPerWeek, 5);
    expect(plan.days, hasLength(5));
    expect(plan.maxExercisesPerSession, 4);
    expect(plan.minimumRir, 2);
    expect(plan.weeklySetTarget, greaterThan(0));
    expect(plan.days.map((day) => day.weekday), [
      TrainingWeekday.monday,
      TrainingWeekday.tuesday,
      TrainingWeekday.thursday,
      TrainingWeekday.saturday,
      TrainingWeekday.sunday,
    ]);
    expect(
      plan.days.every(
        (day) => day.prescriptions.length <= plan.maxExercisesPerSession,
      ),
      isTrue,
    );
    expect(
      plan.days.expand((day) => day.prescriptions).every((prescription) {
        return catalog.exerciseById(prescription.exerciseId) != null;
      }),
      isTrue,
    );
  });

  test('keeps bodyweight-only plans inside bodyweight candidate choices', () {
    final preferences = _preferences(
      now,
      goal: TrainingGoal.generalFitness,
      experienceLevel: TrainingExperienceLevel.beginner,
      equipment: const [EquipmentPreference.bodyweight],
    );

    final plan = buildAdaptiveProgramPlan(
      preferences: preferences,
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.friday),
      ],
      catalog: catalog,
    );

    final generatedIds = plan.days
        .expand((day) => day.prescriptions)
        .map((prescription) => prescription.exerciseId)
        .toSet();

    expect(generatedIds, isNotEmpty);
    expect(
      generatedIds.difference({
        'bodyweight_squat',
        'wall_sit',
        'bird_dog',
        'push_up',
        'close_grip_push_up',
        'reverse_lunge',
        'walking_lunge',
        'split_squat',
        'single_leg_calf_raise',
        'tibialis_raise',
        'plank',
        'dead_bug',
        'side_plank',
        'burpee',
      }),
      isEmpty,
    );
  });

  test('uses strength-oriented prescriptions for main lifts', () {
    final preferences = _preferences(
      now,
      goal: TrainingGoal.maximumStrength,
      experienceLevel: TrainingExperienceLevel.intermediate,
      equipment: const [
        EquipmentPreference.bodyweight,
        EquipmentPreference.barbell,
      ],
    );

    final plan = buildAdaptiveProgramPlan(
      preferences: preferences,
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.friday),
      ],
      catalog: catalog,
    );

    final firstPrescription = plan.days.first.prescriptions.first;

    expect(firstPrescription.exerciseId, 'barbell_back_squat');
    expect(firstPrescription.setCount, 3);
    expect(firstPrescription.minimumRepetitions, 4);
    expect(firstPrescription.maximumRepetitions, 6);
    expect(firstPrescription.targetRir, 2);
    expect(firstPrescription.restSeconds, 180);
  });

  test('converts a generated plan into an editable local program draft', () {
    final preferences = _preferences(
      now,
      goal: TrainingGoal.bodyRecomposition,
      experienceLevel: TrainingExperienceLevel.beginner,
      equipment: const [
        EquipmentPreference.bodyweight,
        EquipmentPreference.dumbbells,
      ],
    );
    final plan = buildAdaptiveProgramPlan(
      preferences: preferences,
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.friday),
      ],
      catalog: catalog,
    );

    final draft = plan.toProgramDraft(name: 'Local planner draft');

    expect(draft.name, 'Local planner draft');
    expect(draft.lifecycle, ProgramDraftLifecycle.local);
    expect(draft.programId, isNull);
    expect(draft.selectedDayId, 'day_1');
    expect(draft.trainingDays, hasLength(plan.days.length));
    expect(draft.exerciseCount, plan.exerciseCount);
    expect(draft.setCount, plan.weeklySetTarget);
  });
}

OnboardingPreferencesRecord _preferences(
  DateTime now, {
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
  required List<EquipmentPreference> equipment,
  int preferredSessionLengthMinutes = 60,
  List<TrainingWeekday> preferredWeekdays = const [
    TrainingWeekday.monday,
    TrainingWeekday.wednesday,
    TrainingWeekday.friday,
  ],
}) {
  return OnboardingPreferencesRecord(
    profileId: 'profile-1',
    goal: goal,
    experienceLevel: experienceLevel,
    equipment: equipment,
    preferredSessionLengthMinutes: preferredSessionLengthMinutes,
    preferredWeekdays: preferredWeekdays,
    createdAt: now,
    updatedAt: now,
  );
}

AvailabilityWindowRecord _window(
  DateTime now,
  TrainingWeekday weekday, {
  int startMinute = 18 * 60,
  int endMinute = 19 * 60,
}) {
  return AvailabilityWindowRecord(
    id: 'availability-${weekday.name}',
    profileId: 'profile-1',
    weekday: weekday,
    windowType: AvailabilityWindowType.flexible,
    startMinute: startMinute,
    endMinute: endMinute,
    createdAt: now,
    updatedAt: now,
  );
}

ExerciseCatalog _loadCatalog() {
  String asset(String path) => File(path).readAsStringSync();

  return ExerciseCatalog.fromJsonDocuments(
    inventoryJson: asset(ExerciseCatalogAssetLoader.inventoryAsset),
    categoriesJson: asset(ExerciseCatalogAssetLoader.categoriesAsset),
    filtersJson: asset(ExerciseCatalogAssetLoader.filtersAsset),
    contentJson: asset(ExerciseCatalogAssetLoader.contentAsset),
    muscleMappingsJson: asset(ExerciseCatalogAssetLoader.muscleMappingsAsset),
    mediaJson: asset(ExerciseCatalogAssetLoader.mediaAsset),
    compoundAnimationsJson: asset(
      ExerciseCatalogAssetLoader.compoundAnimationsAsset,
    ),
    muscleOntologyJson: asset(ExerciseCatalogAssetLoader.muscleOntologyAsset),
  );
}
