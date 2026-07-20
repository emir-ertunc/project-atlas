import 'package:project_atlas/core/repositories/repository_records.dart';

enum TodaySetStatus {
  pending,
  targetMet,
  performanceMiss,
  interrupted,
  painReported,
  notComparable,
}

enum TodayExerciseStatus {
  notStarted,
  inProgress,
  successful,
  needsReview,
  interrupted,
  painReported,
  notComparable,
}

enum TodaySessionStatus {
  notStarted,
  inProgress,
  successful,
  needsReview,
  interrupted,
  painReported,
  notComparable,
}

TodaySetStatus calculateTodaySetStatus({
  required SetLifecycle lifecycle,
  required PrescribedSetRecord? prescribedSet,
  required ActualSetLogRecord? latestLog,
}) {
  if (lifecycle == SetLifecycle.planned) {
    return TodaySetStatus.pending;
  }
  if (lifecycle == SetLifecycle.skipped) {
    return TodaySetStatus.interrupted;
  }
  if (latestLog == null) {
    return TodaySetStatus.notComparable;
  }

  final outcomeStatus = _statusFromOutcome(latestLog.result);
  if (outcomeStatus != null) {
    return outcomeStatus;
  }

  final prescription = prescribedSet;
  if (prescription == null || latestLog.repetitions == null) {
    return TodaySetStatus.notComparable;
  }
  if (latestLog.repetitions! < prescription.minimumRepetitions) {
    return TodaySetStatus.performanceMiss;
  }

  final prescribedLoad = prescription.loadKilograms;
  if (prescribedLoad != null) {
    final actualLoad = latestLog.loadKilograms;
    if (actualLoad == null) {
      return TodaySetStatus.notComparable;
    }
    if (actualLoad + 0.001 < prescribedLoad) {
      return TodaySetStatus.performanceMiss;
    }
  }

  return TodaySetStatus.targetMet;
}

TodayExerciseStatus calculateTodayExerciseStatus(
  Iterable<TodaySetStatus> setStatuses,
) {
  final statuses = setStatuses.toList(growable: false);
  if (statuses.isEmpty || statuses.every(_isPendingSet)) {
    return TodayExerciseStatus.notStarted;
  }
  if (statuses.any(_isPainSet)) {
    return TodayExerciseStatus.painReported;
  }
  if (statuses.any(_isPerformanceMissSet)) {
    return TodayExerciseStatus.needsReview;
  }
  if (statuses.any(_isInterruptedSet)) {
    return TodayExerciseStatus.interrupted;
  }
  if (statuses.any(_isPendingSet)) {
    return TodayExerciseStatus.inProgress;
  }
  if (statuses.any(_isNotComparableSet)) {
    return TodayExerciseStatus.notComparable;
  }
  return TodayExerciseStatus.successful;
}

TodaySessionStatus calculateTodaySessionStatus(
  Iterable<TodayExerciseStatus> exerciseStatuses,
) {
  final statuses = exerciseStatuses.toList(growable: false);
  if (statuses.isEmpty || statuses.every(_isNotStartedExercise)) {
    return TodaySessionStatus.notStarted;
  }
  if (statuses.any(_isPainExercise)) {
    return TodaySessionStatus.painReported;
  }
  if (statuses.any(_isNeedsReviewExercise)) {
    return TodaySessionStatus.needsReview;
  }
  if (statuses.any(_isInterruptedExercise)) {
    return TodaySessionStatus.interrupted;
  }
  if (statuses.any(_isActiveExercise)) {
    return TodaySessionStatus.inProgress;
  }
  if (statuses.any(_isNotComparableExercise)) {
    return TodaySessionStatus.notComparable;
  }
  return TodaySessionStatus.successful;
}

TodaySetStatus? _statusFromOutcome(SetResult? result) {
  return switch (result) {
    null => null,
    SetResult.pain => TodaySetStatus.painReported,
    SetResult.strengthLimitation ||
    SetResult.techniqueLimitation => TodaySetStatus.performanceMiss,
    SetResult.timeLimitation ||
    SetResult.equipmentLimitation ||
    SetResult.externalInterruption => TodaySetStatus.interrupted,
  };
}

bool _isPendingSet(TodaySetStatus status) => status == TodaySetStatus.pending;

bool _isPainSet(TodaySetStatus status) => status == TodaySetStatus.painReported;

bool _isPerformanceMissSet(TodaySetStatus status) =>
    status == TodaySetStatus.performanceMiss;

bool _isInterruptedSet(TodaySetStatus status) =>
    status == TodaySetStatus.interrupted;

bool _isNotComparableSet(TodaySetStatus status) =>
    status == TodaySetStatus.notComparable;

bool _isNotStartedExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.notStarted;

bool _isPainExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.painReported;

bool _isNeedsReviewExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.needsReview;

bool _isInterruptedExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.interrupted;

bool _isActiveExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.inProgress ||
    status == TodayExerciseStatus.notStarted;

bool _isNotComparableExercise(TodayExerciseStatus status) =>
    status == TodayExerciseStatus.notComparable;
