enum UnitPreference { metric, imperial }

enum TrainingGoal {
  generalFitness,
  hypertrophy,
  maximumStrength,
  bodyRecomposition,
  muscularEndurance,
  athleticPerformance,
  maintenance,
}

enum TrainingExperienceLevel { newToTraining, beginner, intermediate, advanced }

enum EquipmentPreference {
  bodyweight,
  dumbbells,
  barbell,
  machines,
  cableStation,
  kettlebell,
  resistanceBands,
  cardioEquipment,
}

enum TrainingWeekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum AvailabilityWindowType { fixed, flexible }

enum ProgramLifecycle { draft, active, archived }

enum ProgramVersionLifecycle { draft, active, retired }

enum WorkoutLifecycle { planned, inProgress, completed, cancelled }

enum SetLifecycle { planned, completed, skipped }

enum ProgressionStrategy { none, manual, doubleProgression }

enum SetResult {
  strengthLimitation,
  techniqueLimitation,
  pain,
  timeLimitation,
  equipmentLimitation,
  externalInterruption,
}

enum MeasurementOrigin { manual, imported }

final class ProfileRecord {
  const ProfileRecord({
    required this.id,
    required this.unitPreference,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
    this.preferredLocale,
  });

  final String id;
  final String? displayName;
  final String? preferredLocale;
  final UnitPreference unitPreference;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class OnboardingPreferencesRecord {
  const OnboardingPreferencesRecord({
    required this.profileId,
    required this.goal,
    required this.experienceLevel,
    required this.equipment,
    required this.preferredSessionLengthMinutes,
    required this.preferredWeekdays,
    required this.createdAt,
    required this.updatedAt,
  });

  final String profileId;
  final TrainingGoal goal;
  final TrainingExperienceLevel experienceLevel;
  final List<EquipmentPreference> equipment;
  final int preferredSessionLengthMinutes;
  final List<TrainingWeekday> preferredWeekdays;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class AvailabilityWindowRecord {
  const AvailabilityWindowRecord({
    required this.id,
    required this.profileId,
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get durationMinutes => endMinute - startMinute;
}

final class ProgramRecord {
  const ProgramRecord({
    required this.id,
    required this.profileId,
    required this.name,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String profileId;
  final String name;
  final ProgramLifecycle lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
}

final class ProgramVersionRecord {
  const ProgramVersionRecord({
    required this.id,
    required this.programId,
    required this.versionNumber,
    required this.lifecycle,
    required this.createdAt,
    this.label,
    this.activatedAt,
  });

  final String id;
  final String programId;
  final int versionNumber;
  final ProgramVersionLifecycle lifecycle;
  final String? label;
  final DateTime createdAt;
  final DateTime? activatedAt;
}

final class ProgramTrainingDayRecord {
  const ProgramTrainingDayRecord({
    required this.id,
    required this.programVersionId,
    required this.trainingDayOrder,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String programVersionId;
  final int trainingDayOrder;
  final String name;
  final DateTime createdAt;
}

final class PrescribedSetRecord {
  const PrescribedSetRecord({
    required this.id,
    required this.programVersionId,
    required this.trainingDayOrder,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setOrder,
    required this.minimumRepetitions,
    required this.maximumRepetitions,
    required this.restSeconds,
    required this.progressionStrategy,
    required this.createdAt,
    this.targetRir,
    this.loadKilograms,
  });

  final String id;
  final String programVersionId;
  final int trainingDayOrder;
  final String exerciseId;
  final int exerciseOrder;
  final int setOrder;
  final int minimumRepetitions;
  final int maximumRepetitions;
  final int? targetRir;
  final double? loadKilograms;
  final int restSeconds;
  final ProgressionStrategy progressionStrategy;
  final DateTime createdAt;
}

final class WorkoutSessionRecord {
  const WorkoutSessionRecord({
    required this.id,
    required this.profileId,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.programId,
    this.programVersionId,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.notes,
  });

  final String id;
  final String profileId;
  final String? programId;
  final String? programVersionId;
  final WorkoutLifecycle lifecycle;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class SessionSetRecord {
  const SessionSetRecord({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setOrder,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.prescribedSetId,
  });

  final String id;
  final String sessionId;
  final String? prescribedSetId;
  final String exerciseId;
  final int exerciseOrder;
  final int setOrder;
  final SetLifecycle lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class ActualSetLogRecord {
  const ActualSetLogRecord({
    required this.id,
    required this.sessionSetId,
    required this.revision,
    required this.recordedAt,
    this.repetitions,
    this.loadKilograms,
    this.rir,
    this.result,
    this.notes,
    this.supersedesLogId,
  });

  final String id;
  final String sessionSetId;
  final int revision;
  final int? repetitions;
  final double? loadKilograms;
  final int? rir;
  final SetResult? result;
  final String? notes;
  final String? supersedesLogId;
  final DateTime recordedAt;
}

final class ExerciseSetPerformanceRecord {
  const ExerciseSetPerformanceRecord({
    required this.sessionId,
    required this.sessionSetId,
    required this.exerciseId,
    required this.setOrder,
    required this.sessionLifecycle,
    required this.sessionCreatedAt,
    required this.log,
    this.sessionScheduledAt,
    this.sessionStartedAt,
  });

  final String sessionId;
  final String sessionSetId;
  final String exerciseId;
  final int setOrder;
  final WorkoutLifecycle sessionLifecycle;
  final DateTime sessionCreatedAt;
  final DateTime? sessionScheduledAt;
  final DateTime? sessionStartedAt;
  final ActualSetLogRecord log;

  DateTime get performedAt => log.recordedAt;
}

final class MeasurementRecord {
  const MeasurementRecord({
    required this.id,
    required this.profileId,
    required this.measuredAt,
    required this.origin,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String profileId;
  final DateTime measuredAt;
  final MeasurementOrigin origin;
  final String? notes;
  final DateTime createdAt;
}

final class ExerciseRecord {
  const ExerciseRecord({
    required this.id,
    required this.name,
    required this.bodyRegion,
  });

  final String id;
  final String name;
  final String bodyRegion;
}
