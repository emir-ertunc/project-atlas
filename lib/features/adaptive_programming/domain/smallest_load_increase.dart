import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const smallestLoadIncreaseRuleSetVersion = 'smallest_load_increase.v1';
const requiredLoadIncreaseQualifyingExposureCount = 2;

enum SmallestLoadIncreaseStatus {
  proposed,
  insufficientQualifyingExposures,
  notComparable,
}

enum SmallestLoadIncreaseBlocker {
  missingCurrentLoad,
  noMatchingExposureHistory,
  notEnoughQualifyingExposures,
  latestExposureNotQualifying,
  missingSetEvidence,
  limitingOutcome,
  missingActualLoad,
  loadBelowPrescription,
  missingActualRepetitions,
  repetitionsBelowUpperTarget,
  missingActualRir,
  rirBelowTarget,
  boundedProgressionNotComparable,
}

final class LoadProgressionExposure {
  const LoadProgressionExposure({
    required this.id,
    required this.exerciseId,
    required this.performedAt,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final DateTime performedAt;
  final List<LoadProgressionSetObservation> sets;
}

final class LoadProgressionSetObservation {
  const LoadProgressionSetObservation({
    required this.setOrder,
    this.repetitions,
    this.loadKilograms,
    this.rir,
    this.result,
  });

  final int setOrder;
  final int? repetitions;
  final double? loadKilograms;
  final int? rir;
  final SetResult? result;
}

final class SmallestLoadIncreaseProposal {
  const SmallestLoadIncreaseProposal({
    required this.ruleSetVersion,
    required this.status,
    required this.requiredQualifyingExposureCount,
    required this.qualifyingExposureIds,
    required this.evaluatedExposureIds,
    required this.blockers,
    required this.boundedDecision,
  });

  final String ruleSetVersion;
  final SmallestLoadIncreaseStatus status;
  final int requiredQualifyingExposureCount;
  final List<String> qualifyingExposureIds;
  final List<String> evaluatedExposureIds;
  final List<SmallestLoadIncreaseBlocker> blockers;
  final BoundedProgressionDecision boundedDecision;

  bool get hasProposal =>
      status == SmallestLoadIncreaseStatus.proposed &&
      boundedDecision.changesLoad;

  bool get requiresUserConfirmation =>
      hasProposal && boundedDecision.requiresUserConfirmation;
}

SmallestLoadIncreaseProposal proposeSmallestAvailableLoadIncrease({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
  required List<LoadProgressionExposure> exposures,
}) {
  final boundedDecision = proposeBoundedLoadProgression(
    prescription: prescription,
    direction: BoundedProgressionDirection.increase,
    policy: policy,
    requestedChangeKilograms: policy.loadIncrementKilograms,
  );

  if (prescription.loadKilograms == null) {
    return _proposal(
      status: SmallestLoadIncreaseStatus.notComparable,
      boundedDecision: boundedDecision,
      blockers: const [SmallestLoadIncreaseBlocker.missingCurrentLoad],
    );
  }

  if (boundedDecision.status == BoundedProgressionStatus.notComparable) {
    return _proposal(
      status: SmallestLoadIncreaseStatus.notComparable,
      boundedDecision: boundedDecision,
      blockers: const [
        SmallestLoadIncreaseBlocker.boundedProgressionNotComparable,
      ],
    );
  }

  final matchingExposures =
      exposures
          .where((exposure) => exposure.exerciseId == prescription.exerciseId)
          .toList(growable: false)
        ..sort(_compareExposureRecency);

  if (matchingExposures.isEmpty) {
    return _proposal(
      status: SmallestLoadIncreaseStatus.insufficientQualifyingExposures,
      boundedDecision: boundedDecision,
      blockers: const [SmallestLoadIncreaseBlocker.noMatchingExposureHistory],
    );
  }

  final qualifyingExposureIds = <String>[];
  final evaluatedExposureIds = <String>[];
  final blockers = <SmallestLoadIncreaseBlocker>{};

  for (final exposure in matchingExposures) {
    if (qualifyingExposureIds.length >=
        requiredLoadIncreaseQualifyingExposureCount) {
      break;
    }

    evaluatedExposureIds.add(exposure.id);
    final result = _evaluateExposure(
      prescription: prescription,
      exposure: exposure,
    );

    if (result.qualifies) {
      qualifyingExposureIds.add(exposure.id);
      continue;
    }

    blockers
      ..add(SmallestLoadIncreaseBlocker.latestExposureNotQualifying)
      ..addAll(result.blockers);
    break;
  }

  if (qualifyingExposureIds.length <
      requiredLoadIncreaseQualifyingExposureCount) {
    return _proposal(
      status: SmallestLoadIncreaseStatus.insufficientQualifyingExposures,
      boundedDecision: boundedDecision,
      qualifyingExposureIds: qualifyingExposureIds,
      evaluatedExposureIds: evaluatedExposureIds,
      blockers: [
        SmallestLoadIncreaseBlocker.notEnoughQualifyingExposures,
        ...blockers,
      ],
    );
  }

  return _proposal(
    status: SmallestLoadIncreaseStatus.proposed,
    boundedDecision: boundedDecision,
    qualifyingExposureIds: qualifyingExposureIds,
    evaluatedExposureIds: evaluatedExposureIds,
  );
}

SmallestLoadIncreaseProposal _proposal({
  required SmallestLoadIncreaseStatus status,
  required BoundedProgressionDecision boundedDecision,
  List<String> qualifyingExposureIds = const [],
  List<String> evaluatedExposureIds = const [],
  List<SmallestLoadIncreaseBlocker> blockers = const [],
}) {
  return SmallestLoadIncreaseProposal(
    ruleSetVersion: smallestLoadIncreaseRuleSetVersion,
    status: status,
    requiredQualifyingExposureCount:
        requiredLoadIncreaseQualifyingExposureCount,
    qualifyingExposureIds: List.unmodifiable(qualifyingExposureIds),
    evaluatedExposureIds: List.unmodifiable(evaluatedExposureIds),
    blockers: List.unmodifiable(blockers),
    boundedDecision: boundedDecision,
  );
}

_ExposureEvaluation _evaluateExposure({
  required ProgramExercisePrescription prescription,
  required LoadProgressionExposure exposure,
}) {
  final blockers = <SmallestLoadIncreaseBlocker>{};
  final orderedSets = exposure.sets.toList(growable: false)
    ..sort((left, right) => left.setOrder.compareTo(right.setOrder));
  final requiredSets = orderedSets
      .take(prescription.setCount)
      .toList(growable: false);

  if (requiredSets.length < prescription.setCount) {
    blockers.add(SmallestLoadIncreaseBlocker.missingSetEvidence);
  }

  for (final set in requiredSets) {
    _evaluateSet(prescription: prescription, set: set, blockers: blockers);
  }

  return _ExposureEvaluation(
    qualifies: blockers.isEmpty,
    blockers: List.unmodifiable(blockers),
  );
}

void _evaluateSet({
  required ProgramExercisePrescription prescription,
  required LoadProgressionSetObservation set,
  required Set<SmallestLoadIncreaseBlocker> blockers,
}) {
  if (set.result != null) {
    blockers.add(SmallestLoadIncreaseBlocker.limitingOutcome);
  }

  final currentLoad = prescription.loadKilograms;
  final actualLoad = set.loadKilograms;
  if (actualLoad == null) {
    blockers.add(SmallestLoadIncreaseBlocker.missingActualLoad);
  } else if (currentLoad != null &&
      actualLoad + _comparisonTolerance < currentLoad) {
    blockers.add(SmallestLoadIncreaseBlocker.loadBelowPrescription);
  }

  final repetitions = set.repetitions;
  if (repetitions == null) {
    blockers.add(SmallestLoadIncreaseBlocker.missingActualRepetitions);
  } else if (repetitions < prescription.maximumRepetitions) {
    blockers.add(SmallestLoadIncreaseBlocker.repetitionsBelowUpperTarget);
  }

  final targetRir = prescription.targetRir;
  if (targetRir != null) {
    final actualRir = set.rir;
    if (actualRir == null) {
      blockers.add(SmallestLoadIncreaseBlocker.missingActualRir);
    } else if (actualRir < targetRir) {
      blockers.add(SmallestLoadIncreaseBlocker.rirBelowTarget);
    }
  }
}

int _compareExposureRecency(
  LoadProgressionExposure left,
  LoadProgressionExposure right,
) {
  final timeComparison = right.performedAt.compareTo(left.performedAt);
  if (timeComparison != 0) {
    return timeComparison;
  }
  return right.id.compareTo(left.id);
}

const _comparisonTolerance = 0.000001;

final class _ExposureEvaluation {
  const _ExposureEvaluation({required this.qualifies, required this.blockers});

  final bool qualifies;
  final List<SmallestLoadIncreaseBlocker> blockers;
}
