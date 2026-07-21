import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/calibration_block.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 21, 12);

  test('keeps calibration duration between two and four weeks', () {
    for (final goal in TrainingGoal.values) {
      for (final level in TrainingExperienceLevel.values) {
        final plan = buildConservativeCalibrationBlock(
          _preferences(createdAt, goal: goal, experienceLevel: level),
        );

        expect(plan.durationWeeks, inInclusiveRange(2, 4));
        expect(plan.weeks, hasLength(plan.durationWeeks));
        expect(plan.loadProgressionAllowed, isFalse);
        expect(
          plan.weeks.every((week) => !week.loadProgressionAllowed),
          isTrue,
        );
      }
    }
  });

  test('uses four weeks and capped exposure for new strength trainees', () {
    final plan = buildConservativeCalibrationBlock(
      _preferences(
        createdAt,
        goal: TrainingGoal.maximumStrength,
        experienceLevel: TrainingExperienceLevel.newToTraining,
        preferredWeekdays: TrainingWeekday.values,
      ),
    );

    expect(plan.durationWeeks, 4);
    expect(plan.sessionsPerWeek, 3);
    expect(plan.minimumRir, 3);
    expect(plan.recommendedWeekdays, [
      TrainingWeekday.monday,
      TrainingWeekday.tuesday,
      TrainingWeekday.wednesday,
    ]);
    expect(plan.weeks.map((week) => week.plannedVolumePercent), [
      60,
      70,
      80,
      90,
    ]);
    expect(plan.weeks.first.minimumRir, 4);
  });

  test('allows a shorter block only for experienced lower-risk goals', () {
    final plan = buildConservativeCalibrationBlock(
      _preferences(
        createdAt,
        goal: TrainingGoal.hypertrophy,
        experienceLevel: TrainingExperienceLevel.advanced,
        preferredWeekdays: const [
          TrainingWeekday.friday,
          TrainingWeekday.monday,
          TrainingWeekday.wednesday,
          TrainingWeekday.sunday,
        ],
      ),
    );

    expect(plan.durationWeeks, 2);
    expect(plan.sessionsPerWeek, 4);
    expect(plan.minimumRir, 2);
    expect(plan.recommendedWeekdays, [
      TrainingWeekday.monday,
      TrainingWeekday.wednesday,
      TrainingWeekday.friday,
      TrainingWeekday.sunday,
    ]);
    expect(plan.weeks.last.focus, CalibrationWeekFocus.prescriptionPreview);
    expect(
      plan.exitRequirements,
      contains(CalibrationExitRequirement.noPainReports),
    );
  });
}

OnboardingPreferencesRecord _preferences(
  DateTime createdAt, {
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
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
    equipment: const [
      EquipmentPreference.bodyweight,
      EquipmentPreference.dumbbells,
    ],
    preferredSessionLengthMinutes: 60,
    preferredWeekdays: preferredWeekdays,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
