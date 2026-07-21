import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const progressionSignalClassifierRuleSetVersion =
    'progression_signal_classifier.v1';

enum ProgressionSignalBlocker {
  missingSetEvidence,
  missingActualRepetitions,
  missingActualLoad,
  strengthLimitation,
  techniqueLimitation,
  repetitionsBelowMinimum,
  loadBelowPrescription,
  timeInterruption,
  equipmentInterruption,
  externalInterruption,
  painReported,
}

final class ProgressionExposureEvidence {
  const ProgressionExposureEvidence({
    required this.id,
    required this.exerciseId,
    required this.performedAt,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final DateTime performedAt;
  final List<ProgressionSetEvidence> sets;
}

final class ProgressionSetEvidence {
  const ProgressionSetEvidence({
    required this.setOrder,
    this.repetitions,
    this.loadKilograms,
    this.result,
  });

  final int setOrder;
  final int? repetitions;
  final double? loadKilograms;
  final SetResult? result;
}

final class ProgressionSignalClassification {
  const ProgressionSignalClassification({
    required this.ruleSetVersion,
    required this.exposureId,
    required this.exerciseId,
    required this.performedAt,
    required this.signal,
    required this.blockers,
  });

  final String ruleSetVersion;
  final String exposureId;
  final String exerciseId;
  final DateTime performedAt;
  final PerformanceMissSignal signal;
  final List<ProgressionSignalBlocker> blockers;

  bool get countsTowardPerformanceFailureStreak =>
      signal == PerformanceMissSignal.performanceMiss;

  PerformanceMissExposure toPerformanceMissExposure() {
    return PerformanceMissExposure(
      id: exposureId,
      exerciseId: exerciseId,
      performedAt: performedAt,
      signal: signal,
    );
  }
}

ProgressionSignalClassification classifyProgressionSignal({
  required ProgramExercisePrescription prescription,
  required ProgressionExposureEvidence exposure,
}) {
  final notComparableBlockers = <ProgressionSignalBlocker>{};
  final performanceMissBlockers = <ProgressionSignalBlocker>{};
  final orderedSets = exposure.sets.toList(growable: false)
    ..sort((left, right) => left.setOrder.compareTo(right.setOrder));
  final requiredSets = orderedSets
      .take(prescription.setCount)
      .toList(growable: false);

  if (requiredSets.length < prescription.setCount) {
    notComparableBlockers.add(ProgressionSignalBlocker.missingSetEvidence);
  }

  for (final set in requiredSets) {
    _classifySet(
      prescription: prescription,
      set: set,
      notComparableBlockers: notComparableBlockers,
      performanceMissBlockers: performanceMissBlockers,
    );
  }

  if (notComparableBlockers.isNotEmpty) {
    return _classification(
      exposure: exposure,
      signal: PerformanceMissSignal.notComparable,
      blockers: notComparableBlockers,
    );
  }

  if (performanceMissBlockers.isNotEmpty) {
    return _classification(
      exposure: exposure,
      signal: PerformanceMissSignal.performanceMiss,
      blockers: performanceMissBlockers,
    );
  }

  return _classification(
    exposure: exposure,
    signal: PerformanceMissSignal.targetMet,
  );
}

void _classifySet({
  required ProgramExercisePrescription prescription,
  required ProgressionSetEvidence set,
  required Set<ProgressionSignalBlocker> notComparableBlockers,
  required Set<ProgressionSignalBlocker> performanceMissBlockers,
}) {
  switch (set.result) {
    case null:
      break;
    case SetResult.strengthLimitation:
      performanceMissBlockers.add(ProgressionSignalBlocker.strengthLimitation);
    case SetResult.techniqueLimitation:
      performanceMissBlockers.add(ProgressionSignalBlocker.techniqueLimitation);
    case SetResult.pain:
      notComparableBlockers.add(ProgressionSignalBlocker.painReported);
    case SetResult.timeLimitation:
      notComparableBlockers.add(ProgressionSignalBlocker.timeInterruption);
    case SetResult.equipmentLimitation:
      notComparableBlockers.add(ProgressionSignalBlocker.equipmentInterruption);
    case SetResult.externalInterruption:
      notComparableBlockers.add(ProgressionSignalBlocker.externalInterruption);
  }

  final repetitions = set.repetitions;
  if (repetitions == null) {
    notComparableBlockers.add(
      ProgressionSignalBlocker.missingActualRepetitions,
    );
  } else if (repetitions < prescription.minimumRepetitions) {
    performanceMissBlockers.add(
      ProgressionSignalBlocker.repetitionsBelowMinimum,
    );
  }

  final prescribedLoad = prescription.loadKilograms;
  if (prescribedLoad != null) {
    final actualLoad = set.loadKilograms;
    if (actualLoad == null) {
      notComparableBlockers.add(ProgressionSignalBlocker.missingActualLoad);
    } else if (actualLoad + _comparisonTolerance < prescribedLoad) {
      performanceMissBlockers.add(
        ProgressionSignalBlocker.loadBelowPrescription,
      );
    }
  }
}

ProgressionSignalClassification _classification({
  required ProgressionExposureEvidence exposure,
  required PerformanceMissSignal signal,
  Set<ProgressionSignalBlocker> blockers = const {},
}) {
  return ProgressionSignalClassification(
    ruleSetVersion: progressionSignalClassifierRuleSetVersion,
    exposureId: exposure.id,
    exerciseId: exposure.exerciseId,
    performedAt: exposure.performedAt,
    signal: signal,
    blockers: List.unmodifiable(blockers),
  );
}

const _comparisonTolerance = 0.000001;
