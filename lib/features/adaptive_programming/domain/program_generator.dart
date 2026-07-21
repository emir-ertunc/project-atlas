import 'dart:math' as math;

import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/calibration_block.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const adaptiveProgramPlannerRuleSetVersion = 'adaptive_program_planner.v1';

enum GeneratedProgramDayFocus {
  fullBody,
  upperEmphasis,
  lowerEmphasis,
  posteriorChain,
  conditioningSupport,
}

final class GeneratedProgramPlan {
  const GeneratedProgramPlan({
    required this.ruleSetVersion,
    required this.name,
    required this.goal,
    required this.experienceLevel,
    required this.sessionsPerWeek,
    required this.sessionLengthMinutes,
    required this.weeklySetTarget,
    required this.minimumRir,
    required this.maxExercisesPerSession,
    required this.availableEquipment,
    required this.days,
  });

  final String ruleSetVersion;
  final String name;
  final TrainingGoal goal;
  final TrainingExperienceLevel experienceLevel;
  final int sessionsPerWeek;
  final int sessionLengthMinutes;
  final int weeklySetTarget;
  final int minimumRir;
  final int maxExercisesPerSession;
  final List<EquipmentPreference> availableEquipment;
  final List<GeneratedTrainingDayPlan> days;

  int get exerciseCount =>
      days.fold(0, (total, day) => total + day.prescriptions.length);

  ProgramDraft toProgramDraft({String? name}) {
    if (days.isEmpty) {
      throw StateError('A generated program requires at least one day.');
    }

    return ProgramDraft(
      name: _cleanName(name ?? this.name, fallback: this.name),
      trainingDays: [
        for (final day in days)
          ProgramTrainingDay(
            id: day.id,
            name: day.name,
            exercisePrescriptions: day.prescriptions,
          ),
      ],
      selectedDayId: days.first.id,
    );
  }
}

final class GeneratedTrainingDayPlan {
  const GeneratedTrainingDayPlan({
    required this.id,
    required this.name,
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    required this.focus,
    required this.prescriptions,
  });

  final String id;
  final String name;
  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;
  final GeneratedProgramDayFocus focus;
  final List<ProgramExercisePrescription> prescriptions;

  int get durationMinutes => endMinute - startMinute;

  int get setCount => prescriptions.fold(
    0,
    (total, prescription) => total + prescription.setCount,
  );
}

GeneratedProgramPlan buildAdaptiveProgramPlan({
  required OnboardingPreferencesRecord preferences,
  required List<AvailabilityWindowRecord> availabilityWindows,
  required ExerciseCatalog catalog,
}) {
  final calibrationBlock = buildConservativeCalibrationBlock(preferences);
  final windows = _effectiveAvailabilityWindows(
    preferences: preferences,
    availabilityWindows: availabilityWindows,
  );
  final sessionCount = math.min(
    calibrationBlock.sessionsPerWeek,
    windows.length,
  );
  final selectedWindows = _selectRecoverySpacedWindows(windows, sessionCount);
  final sessionLengthMinutes = _effectiveSessionLength(
    preferences.preferredSessionLengthMinutes,
    selectedWindows,
  );
  final maxExercisesPerSession = _maxExercisesFor(sessionLengthMinutes);
  final availableCapabilities = _equipmentCapabilities(preferences.equipment);
  final context = _ExerciseSelectionContext(
    catalog: catalog,
    availableCapabilities: availableCapabilities,
  );

  final days = <GeneratedTrainingDayPlan>[];
  for (final (dayIndex, window) in selectedWindows.indexed) {
    final focus = _focusFor(dayIndex: dayIndex, sessionCount: sessionCount);
    final slotPlan = _slotPlanFor(
      focus: focus,
      goal: preferences.goal,
      maxExercises: maxExercisesPerSession,
    );
    final prescriptions = <ProgramExercisePrescription>[];

    for (final slot in slotPlan) {
      final exerciseId = context.pickExercise(
        slot: slot,
        dayIndex: dayIndex,
        avoidWeeklyRepeats: slot != _MovementSlot.core,
      );
      if (exerciseId == null ||
          prescriptions.any(
            (prescription) => prescription.exerciseId == exerciseId,
          )) {
        continue;
      }

      prescriptions.add(
        _prescriptionFor(
          exerciseId: exerciseId,
          slot: slot,
          goal: preferences.goal,
          experienceLevel: preferences.experienceLevel,
          minimumRir: calibrationBlock.minimumRir,
        ),
      );

      if (prescriptions.length >= maxExercisesPerSession) {
        break;
      }
    }

    if (prescriptions.length < 3) {
      for (final fallbackSlot in _fallbackSlots) {
        final exerciseId = context.pickExercise(
          slot: fallbackSlot,
          dayIndex: dayIndex,
          avoidWeeklyRepeats: false,
        );
        if (exerciseId == null ||
            prescriptions.any(
              (prescription) => prescription.exerciseId == exerciseId,
            )) {
          continue;
        }
        prescriptions.add(
          _prescriptionFor(
            exerciseId: exerciseId,
            slot: fallbackSlot,
            goal: preferences.goal,
            experienceLevel: preferences.experienceLevel,
            minimumRir: calibrationBlock.minimumRir,
          ),
        );
        if (prescriptions.length >= 3 ||
            prescriptions.length >= maxExercisesPerSession) {
          break;
        }
      }
    }

    if (prescriptions.isEmpty) {
      continue;
    }

    days.add(
      GeneratedTrainingDayPlan(
        id: 'day_${dayIndex + 1}',
        name: _dayName(dayIndex: dayIndex, focus: focus),
        weekday: window.weekday,
        windowType: window.windowType,
        startMinute: window.startMinute,
        endMinute: window.endMinute,
        focus: focus,
        prescriptions: List.unmodifiable(prescriptions),
      ),
    );
  }

  final weeklySetTarget = days.fold(0, (total, day) => total + day.setCount);

  return GeneratedProgramPlan(
    ruleSetVersion: adaptiveProgramPlannerRuleSetVersion,
    name: _programName(preferences.goal),
    goal: preferences.goal,
    experienceLevel: preferences.experienceLevel,
    sessionsPerWeek: days.length,
    sessionLengthMinutes: sessionLengthMinutes,
    weeklySetTarget: weeklySetTarget,
    minimumRir: calibrationBlock.minimumRir,
    maxExercisesPerSession: maxExercisesPerSession,
    availableEquipment: List.unmodifiable(preferences.equipment),
    days: List.unmodifiable(days),
  );
}

List<AvailabilityWindowRecord> _effectiveAvailabilityWindows({
  required OnboardingPreferencesRecord preferences,
  required List<AvailabilityWindowRecord> availabilityWindows,
}) {
  final windows = availabilityWindows.isEmpty
      ? _defaultAvailabilityWindows(preferences)
      : availabilityWindows;

  return windows.where((window) => window.durationMinutes > 0).toList()
    ..sort(_compareAvailabilityWindows);
}

List<AvailabilityWindowRecord> _defaultAvailabilityWindows(
  OnboardingPreferencesRecord preferences,
) {
  const defaultStartMinute = 18 * 60;
  final endMinute = math.min(
    24 * 60,
    defaultStartMinute + preferences.preferredSessionLengthMinutes,
  );

  return [
    for (final weekday in preferences.preferredWeekdays.toSet())
      AvailabilityWindowRecord(
        id: 'default_${weekday.name}',
        profileId: preferences.profileId,
        weekday: weekday,
        windowType: AvailabilityWindowType.flexible,
        startMinute: defaultStartMinute,
        endMinute: endMinute,
        createdAt: preferences.updatedAt,
        updatedAt: preferences.updatedAt,
      ),
  ];
}

List<AvailabilityWindowRecord> _selectRecoverySpacedWindows(
  List<AvailabilityWindowRecord> windows,
  int count,
) {
  if (windows.length <= count) {
    return List.unmodifiable(windows);
  }

  final selected = <AvailabilityWindowRecord>[];
  final usedIndexes = <int>{};

  for (var slotIndex = 0; slotIndex < count; slotIndex += 1) {
    var sourceIndex = (slotIndex * windows.length / count).floor();
    while (usedIndexes.contains(sourceIndex)) {
      sourceIndex = (sourceIndex + 1) % windows.length;
    }
    usedIndexes.add(sourceIndex);
    selected.add(windows[sourceIndex]);
  }

  selected.sort(_compareAvailabilityWindows);
  return List.unmodifiable(selected);
}

int _effectiveSessionLength(
  int preferredSessionLengthMinutes,
  List<AvailabilityWindowRecord> windows,
) {
  if (windows.isEmpty) {
    return preferredSessionLengthMinutes;
  }

  final shortestWindow = windows
      .map((window) => window.durationMinutes)
      .reduce(math.min);
  return math.max(30, math.min(preferredSessionLengthMinutes, shortestWindow));
}

int _maxExercisesFor(int sessionLengthMinutes) {
  if (sessionLengthMinutes <= 40) {
    return 3;
  }
  if (sessionLengthMinutes <= 60) {
    return 4;
  }
  if (sessionLengthMinutes <= 75) {
    return 5;
  }
  return 6;
}

int _compareAvailabilityWindows(
  AvailabilityWindowRecord left,
  AvailabilityWindowRecord right,
) {
  final weekdayComparison = _weekdayIndex(
    left.weekday,
  ).compareTo(_weekdayIndex(right.weekday));
  if (weekdayComparison != 0) {
    return weekdayComparison;
  }
  final typeComparison = left.windowType.index.compareTo(
    right.windowType.index,
  );
  if (typeComparison != 0) {
    return typeComparison;
  }
  return left.startMinute.compareTo(right.startMinute);
}

GeneratedProgramDayFocus _focusFor({
  required int dayIndex,
  required int sessionCount,
}) {
  if (sessionCount <= 2) {
    return dayIndex.isEven
        ? GeneratedProgramDayFocus.fullBody
        : GeneratedProgramDayFocus.posteriorChain;
  }
  if (sessionCount == 3) {
    return switch (dayIndex) {
      0 => GeneratedProgramDayFocus.fullBody,
      1 => GeneratedProgramDayFocus.upperEmphasis,
      _ => GeneratedProgramDayFocus.lowerEmphasis,
    };
  }

  return switch (dayIndex % 4) {
    0 => GeneratedProgramDayFocus.upperEmphasis,
    1 => GeneratedProgramDayFocus.lowerEmphasis,
    2 => GeneratedProgramDayFocus.fullBody,
    _ => GeneratedProgramDayFocus.posteriorChain,
  };
}

List<_MovementSlot> _slotPlanFor({
  required GeneratedProgramDayFocus focus,
  required TrainingGoal goal,
  required int maxExercises,
}) {
  final base = switch (focus) {
    GeneratedProgramDayFocus.fullBody => const [
      _MovementSlot.squat,
      _MovementSlot.horizontalPush,
      _MovementSlot.horizontalPull,
      _MovementSlot.hinge,
      _MovementSlot.core,
      _MovementSlot.singleLeg,
    ],
    GeneratedProgramDayFocus.upperEmphasis => const [
      _MovementSlot.horizontalPush,
      _MovementSlot.horizontalPull,
      _MovementSlot.verticalPush,
      _MovementSlot.verticalPull,
      _MovementSlot.arms,
      _MovementSlot.core,
    ],
    GeneratedProgramDayFocus.lowerEmphasis => const [
      _MovementSlot.squat,
      _MovementSlot.hinge,
      _MovementSlot.singleLeg,
      _MovementSlot.calves,
      _MovementSlot.core,
    ],
    GeneratedProgramDayFocus.posteriorChain => const [
      _MovementSlot.hinge,
      _MovementSlot.horizontalPull,
      _MovementSlot.singleLeg,
      _MovementSlot.horizontalPush,
      _MovementSlot.core,
      _MovementSlot.calves,
    ],
    GeneratedProgramDayFocus.conditioningSupport => const [
      _MovementSlot.conditioning,
      _MovementSlot.singleLeg,
      _MovementSlot.horizontalPush,
      _MovementSlot.horizontalPull,
      _MovementSlot.core,
    ],
  };

  if (goal == TrainingGoal.muscularEndurance ||
      goal == TrainingGoal.athleticPerformance) {
    return [
      ...base.take(math.max(0, maxExercises - 1)),
      _MovementSlot.conditioning,
    ].take(maxExercises).toList(growable: false);
  }

  return base.take(maxExercises).toList(growable: false);
}

ProgramExercisePrescription _prescriptionFor({
  required String exerciseId,
  required _MovementSlot slot,
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
  required int minimumRir,
}) {
  final mainLift = {
    _MovementSlot.squat,
    _MovementSlot.hinge,
    _MovementSlot.horizontalPush,
    _MovementSlot.horizontalPull,
    _MovementSlot.verticalPush,
    _MovementSlot.verticalPull,
  }.contains(slot);
  final accessory = {
    _MovementSlot.arms,
    _MovementSlot.calves,
    _MovementSlot.core,
    _MovementSlot.conditioning,
  }.contains(slot);

  final setCount = _setCount(
    goal: goal,
    experienceLevel: experienceLevel,
    accessory: accessory,
  );
  final repetitions = _repetitionRange(goal: goal, mainLift: mainLift);
  final restSeconds = _restSeconds(goal: goal, mainLift: mainLift);

  return ProgramExercisePrescription(
    exerciseId: exerciseId,
    setCount: setCount,
    minimumRepetitions: repetitions.$1,
    maximumRepetitions: repetitions.$2,
    targetRir: minimumRir,
    loadKilograms: null,
    restSeconds: restSeconds,
  );
}

int _setCount({
  required TrainingGoal goal,
  required TrainingExperienceLevel experienceLevel,
  required bool accessory,
}) {
  final experienceBase = switch (experienceLevel) {
    TrainingExperienceLevel.newToTraining => 2,
    TrainingExperienceLevel.beginner => 2,
    TrainingExperienceLevel.intermediate => 3,
    TrainingExperienceLevel.advanced => 3,
  };
  final goalAdjustment = switch (goal) {
    TrainingGoal.hypertrophy || TrainingGoal.bodyRecomposition => 1,
    TrainingGoal.maximumStrength => 0,
    TrainingGoal.muscularEndurance => 0,
    TrainingGoal.athleticPerformance => 0,
    TrainingGoal.generalFitness || TrainingGoal.maintenance => 0,
  };
  final accessoryAdjustment = accessory ? -1 : 0;

  return (experienceBase + goalAdjustment + accessoryAdjustment)
      .clamp(1, 4)
      .toInt();
}

(int, int) _repetitionRange({
  required TrainingGoal goal,
  required bool mainLift,
}) {
  return switch (goal) {
    TrainingGoal.maximumStrength when mainLift => (4, 6),
    TrainingGoal.maximumStrength => (6, 8),
    TrainingGoal.muscularEndurance => (12, 15),
    TrainingGoal.athleticPerformance when mainLift => (6, 10),
    TrainingGoal.athleticPerformance => (8, 12),
    TrainingGoal.hypertrophy || TrainingGoal.bodyRecomposition => (8, 12),
    TrainingGoal.generalFitness || TrainingGoal.maintenance => (8, 10),
  };
}

int _restSeconds({required TrainingGoal goal, required bool mainLift}) {
  return switch (goal) {
    TrainingGoal.maximumStrength when mainLift => 180,
    TrainingGoal.maximumStrength => 120,
    TrainingGoal.muscularEndurance => 60,
    TrainingGoal.athleticPerformance when mainLift => 120,
    TrainingGoal.hypertrophy ||
    TrainingGoal.bodyRecomposition when mainLift => 120,
    _ => 90,
  };
}

Set<_EquipmentCapability> _equipmentCapabilities(
  List<EquipmentPreference> equipment,
) {
  final capabilities = <_EquipmentCapability>{_EquipmentCapability.bodyweight};
  for (final item in equipment) {
    switch (item) {
      case EquipmentPreference.bodyweight:
        capabilities.add(_EquipmentCapability.bodyweight);
      case EquipmentPreference.dumbbells:
        capabilities.add(_EquipmentCapability.dumbbells);
      case EquipmentPreference.barbell:
        capabilities.add(_EquipmentCapability.barbell);
      case EquipmentPreference.machines:
        capabilities.add(_EquipmentCapability.machines);
      case EquipmentPreference.cableStation:
        capabilities.add(_EquipmentCapability.cable);
      case EquipmentPreference.kettlebell:
        capabilities.add(_EquipmentCapability.kettlebell);
      case EquipmentPreference.resistanceBands:
        capabilities.add(_EquipmentCapability.bands);
      case EquipmentPreference.cardioEquipment:
        capabilities.add(_EquipmentCapability.cardio);
    }
  }
  return capabilities;
}

String _programName(TrainingGoal goal) {
  return switch (goal) {
    TrainingGoal.generalFitness => 'General fitness program',
    TrainingGoal.hypertrophy => 'Hypertrophy program',
    TrainingGoal.maximumStrength => 'Strength program',
    TrainingGoal.bodyRecomposition => 'Body recomposition program',
    TrainingGoal.muscularEndurance => 'Endurance program',
    TrainingGoal.athleticPerformance => 'Athletic performance program',
    TrainingGoal.maintenance => 'Maintenance program',
  };
}

String _dayName({
  required int dayIndex,
  required GeneratedProgramDayFocus focus,
}) {
  final focusName = switch (focus) {
    GeneratedProgramDayFocus.fullBody => 'Full body',
    GeneratedProgramDayFocus.upperEmphasis => 'Upper emphasis',
    GeneratedProgramDayFocus.lowerEmphasis => 'Lower emphasis',
    GeneratedProgramDayFocus.posteriorChain => 'Posterior chain',
    GeneratedProgramDayFocus.conditioningSupport => 'Conditioning support',
  };
  return 'Day ${dayIndex + 1} - $focusName';
}

int _weekdayIndex(TrainingWeekday weekday) =>
    TrainingWeekday.values.indexOf(weekday);

String _cleanName(String value, {required String fallback}) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

enum _MovementSlot {
  squat,
  hinge,
  horizontalPush,
  horizontalPull,
  verticalPush,
  verticalPull,
  singleLeg,
  arms,
  calves,
  core,
  conditioning,
}

enum _EquipmentCapability {
  bodyweight,
  dumbbells,
  barbell,
  machines,
  cable,
  kettlebell,
  bands,
  cardio,
}

const _fallbackSlots = [
  _MovementSlot.core,
  _MovementSlot.singleLeg,
  _MovementSlot.horizontalPush,
  _MovementSlot.squat,
];

final class _ExerciseSelectionContext {
  _ExerciseSelectionContext({
    required this.catalog,
    required this.availableCapabilities,
  });

  final ExerciseCatalog catalog;
  final Set<_EquipmentCapability> availableCapabilities;
  final _usedExerciseIds = <String>{};

  String? pickExercise({
    required _MovementSlot slot,
    required int dayIndex,
    required bool avoidWeeklyRepeats,
  }) {
    final candidates = _rotated(_candidatePools[slot] ?? const [], dayIndex);
    final weeklyFresh = _firstUsable(
      candidates,
      avoidWeeklyRepeats: avoidWeeklyRepeats,
    );
    if (weeklyFresh != null) {
      _usedExerciseIds.add(weeklyFresh);
      return weeklyFresh;
    }

    final repeat = _firstUsable(candidates, avoidWeeklyRepeats: false);
    if (repeat != null) {
      _usedExerciseIds.add(repeat);
    }
    return repeat;
  }

  String? _firstUsable(
    List<_ExerciseCandidate> candidates, {
    required bool avoidWeeklyRepeats,
  }) {
    for (final candidate in candidates) {
      if (avoidWeeklyRepeats && _usedExerciseIds.contains(candidate.id)) {
        continue;
      }
      if (!candidate.capabilities.every(availableCapabilities.contains)) {
        continue;
      }
      if (catalog.exerciseById(candidate.id) == null) {
        continue;
      }
      return candidate.id;
    }
    return null;
  }
}

List<_ExerciseCandidate> _rotated(
  List<_ExerciseCandidate> candidates,
  int offset,
) {
  if (candidates.isEmpty) {
    return const [];
  }

  final rotation = offset % candidates.length;
  return [...candidates.skip(rotation), ...candidates.take(rotation)];
}

final class _ExerciseCandidate {
  const _ExerciseCandidate(this.id, this.capabilities);

  final String id;
  final Set<_EquipmentCapability> capabilities;
}

const _bodyweight = {_EquipmentCapability.bodyweight};
const _dumbbells = {_EquipmentCapability.dumbbells};
const _barbell = {_EquipmentCapability.barbell};
const _machines = {_EquipmentCapability.machines};
const _cable = {_EquipmentCapability.cable};
const _kettlebell = {_EquipmentCapability.kettlebell};
const _bands = {_EquipmentCapability.bands};
const _cardio = {_EquipmentCapability.cardio};

const _candidatePools = <_MovementSlot, List<_ExerciseCandidate>>{
  _MovementSlot.squat: [
    _ExerciseCandidate('barbell_back_squat', _barbell),
    _ExerciseCandidate('goblet_squat', _dumbbells),
    _ExerciseCandidate('goblet_squat', _kettlebell),
    _ExerciseCandidate('leg_press', _machines),
    _ExerciseCandidate('bodyweight_squat', _bodyweight),
    _ExerciseCandidate('wall_sit', _bodyweight),
  ],
  _MovementSlot.hinge: [
    _ExerciseCandidate('romanian_deadlift', _barbell),
    _ExerciseCandidate('romanian_deadlift', _dumbbells),
    _ExerciseCandidate('kettlebell_swing', _kettlebell),
    _ExerciseCandidate('back_extension', _machines),
    _ExerciseCandidate('bird_dog', _bodyweight),
  ],
  _MovementSlot.horizontalPush: [
    _ExerciseCandidate('barbell_bench_press', _barbell),
    _ExerciseCandidate('dumbbell_bench_press', _dumbbells),
    _ExerciseCandidate('machine_chest_press', _machines),
    _ExerciseCandidate('cable_chest_press', _cable),
    _ExerciseCandidate('push_up', _bodyweight),
    _ExerciseCandidate('close_grip_push_up', _bodyweight),
  ],
  _MovementSlot.horizontalPull: [
    _ExerciseCandidate('bent_over_barbell_row', _barbell),
    _ExerciseCandidate('dumbbell_row', _dumbbells),
    _ExerciseCandidate('machine_row', _machines),
    _ExerciseCandidate('seated_cable_row', _cable),
    _ExerciseCandidate('band_pull_apart', _bands),
    _ExerciseCandidate('bird_dog', _bodyweight),
  ],
  _MovementSlot.verticalPush: [
    _ExerciseCandidate('standing_overhead_press', _barbell),
    _ExerciseCandidate('dumbbell_shoulder_press', _dumbbells),
    _ExerciseCandidate('landmine_press', _barbell),
    _ExerciseCandidate('dumbbell_lateral_raise', _dumbbells),
    _ExerciseCandidate('push_up', _bodyweight),
  ],
  _MovementSlot.verticalPull: [
    _ExerciseCandidate('lat_pulldown', _cable),
    _ExerciseCandidate('assisted_pull_up', _machines),
    _ExerciseCandidate('neutral_grip_lat_pulldown', _cable),
    _ExerciseCandidate('band_pull_apart', _bands),
  ],
  _MovementSlot.singleLeg: [
    _ExerciseCandidate('reverse_lunge', _bodyweight),
    _ExerciseCandidate('walking_lunge', _bodyweight),
    _ExerciseCandidate('split_squat', _bodyweight),
    _ExerciseCandidate('single_leg_romanian_deadlift', _dumbbells),
    _ExerciseCandidate('single_leg_romanian_deadlift', _kettlebell),
    _ExerciseCandidate('single_leg_press', _machines),
  ],
  _MovementSlot.arms: [
    _ExerciseCandidate('dumbbell_biceps_curl', _dumbbells),
    _ExerciseCandidate('hammer_curl', _dumbbells),
    _ExerciseCandidate('cable_triceps_pushdown', _cable),
    _ExerciseCandidate('cable_curl', _cable),
    _ExerciseCandidate('barbell_biceps_curl', _barbell),
    _ExerciseCandidate('close_grip_push_up', _bodyweight),
  ],
  _MovementSlot.calves: [
    _ExerciseCandidate('single_leg_calf_raise', _bodyweight),
    _ExerciseCandidate('tibialis_raise', _bodyweight),
    _ExerciseCandidate('standing_calf_raise', _machines),
    _ExerciseCandidate('leg_press_calf_raise', _machines),
  ],
  _MovementSlot.core: [
    _ExerciseCandidate('plank', _bodyweight),
    _ExerciseCandidate('dead_bug', _bodyweight),
    _ExerciseCandidate('side_plank', _bodyweight),
    _ExerciseCandidate('pallof_press', _cable),
    _ExerciseCandidate('pallof_press', _bands),
    _ExerciseCandidate('farmers_carry', _dumbbells),
    _ExerciseCandidate('farmers_carry', _kettlebell),
  ],
  _MovementSlot.conditioning: [
    _ExerciseCandidate('burpee', _bodyweight),
    _ExerciseCandidate('farmers_carry', _dumbbells),
    _ExerciseCandidate('farmers_carry', _kettlebell),
    _ExerciseCandidate('sled_push', _cardio),
  ],
};
