import 'dart:math' as math;

import 'package:project_atlas/core/repositories/repository_records.dart';

const calibrationBlockRuleSetVersion = 'calibration_block.v1';

enum CalibrationWeekFocus {
  techniqueBaseline,
  repeatableExecution,
  stableExposure,
  prescriptionPreview,
}

enum CalibrationExitRequirement {
  plannedWeeksCompleted,
  noPainReports,
  noRepeatedPerformanceMisses,
  stableRirEvidence,
}

final class CalibrationBlockPlan {
  const CalibrationBlockPlan({
    required this.ruleSetVersion,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.sessionLengthMinutes,
    required this.minimumRir,
    required this.recommendedWeekdays,
    required this.weeks,
    required this.exitRequirements,
  });

  final String ruleSetVersion;
  final int durationWeeks;
  final int sessionsPerWeek;
  final int sessionLengthMinutes;
  final int minimumRir;
  final List<TrainingWeekday> recommendedWeekdays;
  final List<CalibrationWeekPlan> weeks;
  final List<CalibrationExitRequirement> exitRequirements;

  bool get loadProgressionAllowed => false;
}

final class CalibrationWeekPlan {
  const CalibrationWeekPlan({
    required this.weekNumber,
    required this.focus,
    required this.plannedVolumePercent,
    required this.minimumRir,
    required this.loadProgressionAllowed,
  });

  final int weekNumber;
  final CalibrationWeekFocus focus;
  final int plannedVolumePercent;
  final int minimumRir;
  final bool loadProgressionAllowed;
}

CalibrationBlockPlan buildConservativeCalibrationBlock(
  OnboardingPreferencesRecord preferences,
) {
  final durationWeeks = _durationWeeks(
    goal: preferences.goal,
    experienceLevel: preferences.experienceLevel,
  );
  final sessionsPerWeek = _sessionsPerWeek(preferences);
  final minimumRir = _minimumRir(
    goal: preferences.goal,
    experienceLevel: preferences.experienceLevel,
  );
  final recommendedWeekdays = _firstPreferredWeekdays(
    preferences.preferredWeekdays,
    count: sessionsPerWeek,
  );

  return CalibrationBlockPlan(
    ruleSetVersion: calibrationBlockRuleSetVersion,
    durationWeeks: durationWeeks,
    sessionsPerWeek: sessionsPerWeek,
    sessionLengthMinutes: preferences.preferredSessionLengthMinutes,
    minimumRir: minimumRir,
    recommendedWeekdays: List.unmodifiable(recommendedWeekdays),
    weeks: List.unmodifiable(
      _weekPlans(durationWeeks: durationWeeks, minimumRir: minimumRir),
    ),
    exitRequirements: const [
      CalibrationExitRequirement.plannedWeeksCompleted,
      CalibrationExitRequirement.noPainReports,
      CalibrationExitRequirement.noRepeatedPerformanceMisses,
      CalibrationExitRequirement.stableRirEvidence,
    ],
  );
}

int _durationWeeks({
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
}) {
  final baseWeeks = switch (experienceLevel) {
    TrainingExperienceLevel.newToTraining => 4,
    TrainingExperienceLevel.beginner => 4,
    TrainingExperienceLevel.intermediate => 3,
    TrainingExperienceLevel.advanced => 2,
  };
  final riskAdjustment = switch (goal) {
    TrainingGoal.maximumStrength ||
    TrainingGoal.bodyRecomposition ||
    TrainingGoal.athleticPerformance => 1,
    TrainingGoal.generalFitness ||
    TrainingGoal.hypertrophy ||
    TrainingGoal.muscularEndurance ||
    TrainingGoal.maintenance => 0,
  };

  return math.min(4, math.max(2, baseWeeks + riskAdjustment));
}

int _sessionsPerWeek(OnboardingPreferencesRecord preferences) {
  final preferredDayCount = preferences.preferredWeekdays.length;
  final experienceCap = switch (preferences.experienceLevel) {
    TrainingExperienceLevel.newToTraining => 3,
    TrainingExperienceLevel.beginner => 4,
    TrainingExperienceLevel.intermediate => 4,
    TrainingExperienceLevel.advanced => 5,
  };

  return math.max(1, math.min(preferredDayCount, experienceCap));
}

int _minimumRir({
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
}) {
  final experienceMinimum = switch (experienceLevel) {
    TrainingExperienceLevel.newToTraining => 3,
    TrainingExperienceLevel.beginner => 3,
    TrainingExperienceLevel.intermediate => 2,
    TrainingExperienceLevel.advanced => 2,
  };
  final goalMinimum = switch (goal) {
    TrainingGoal.generalFitness ||
    TrainingGoal.muscularEndurance ||
    TrainingGoal.maintenance => 3,
    TrainingGoal.hypertrophy ||
    TrainingGoal.maximumStrength ||
    TrainingGoal.bodyRecomposition ||
    TrainingGoal.athleticPerformance => 2,
  };

  return math.max(experienceMinimum, goalMinimum);
}

List<TrainingWeekday> _firstPreferredWeekdays(
  List<TrainingWeekday> weekdays, {
  required int count,
}) {
  final canonicalIndex = {
    for (final (index, weekday) in TrainingWeekday.values.indexed)
      weekday: index,
  };
  final ordered = weekdays.toSet().toList(growable: false)
    ..sort(
      (left, right) => canonicalIndex[left]!.compareTo(canonicalIndex[right]!),
    );
  return ordered.take(count).toList(growable: false);
}

List<CalibrationWeekPlan> _weekPlans({
  required int durationWeeks,
  required int minimumRir,
}) {
  final volumePercentages = switch (durationWeeks) {
    2 => const [70, 80],
    3 => const [65, 75, 85],
    _ => const [60, 70, 80, 90],
  };

  return [
    for (final (index, volumePercent) in volumePercentages.indexed)
      CalibrationWeekPlan(
        weekNumber: index + 1,
        focus: _weekFocus(index: index, durationWeeks: durationWeeks),
        plannedVolumePercent: volumePercent,
        minimumRir: index == 0 ? math.min(4, minimumRir + 1) : minimumRir,
        loadProgressionAllowed: false,
      ),
  ];
}

CalibrationWeekFocus _weekFocus({
  required int index,
  required int durationWeeks,
}) {
  if (index == 0) {
    return CalibrationWeekFocus.techniqueBaseline;
  }
  if (index == durationWeeks - 1) {
    return CalibrationWeekFocus.prescriptionPreview;
  }
  if (index == 1) {
    return CalibrationWeekFocus.repeatableExecution;
  }
  return CalibrationWeekFocus.stableExposure;
}
