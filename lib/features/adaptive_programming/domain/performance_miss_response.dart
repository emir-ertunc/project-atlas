import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const performanceMissResponseRuleSetVersion = 'performance_miss_response.v1';
const requiredRepeatedPerformanceMissCount = 2;

enum PerformanceMissSignal { targetMet, performanceMiss, notComparable }

enum PerformanceMissResponseStatus { decreaseProposed, held, notComparable }

enum PerformanceMissResponseBlocker {
  noMatchingExposureHistory,
  latestExposureNotPerformanceMiss,
  isolatedPerformanceMiss,
  notEnoughRepeatedPerformanceMisses,
  boundedProgressionNotComparable,
  boundedProgressionHeld,
}

final class PerformanceMissExposure {
  const PerformanceMissExposure({
    required this.id,
    required this.exerciseId,
    required this.performedAt,
    required this.signal,
  });

  final String id;
  final String exerciseId;
  final DateTime performedAt;
  final PerformanceMissSignal signal;
}

final class PerformanceMissResponseProposal {
  const PerformanceMissResponseProposal({
    required this.ruleSetVersion,
    required this.status,
    required this.requiredRepeatedMissCount,
    required this.evaluatedExposureIds,
    required this.performanceMissExposureIds,
    required this.blockers,
    required this.boundedDecision,
  });

  final String ruleSetVersion;
  final PerformanceMissResponseStatus status;
  final int requiredRepeatedMissCount;
  final List<String> evaluatedExposureIds;
  final List<String> performanceMissExposureIds;
  final List<PerformanceMissResponseBlocker> blockers;
  final BoundedProgressionDecision boundedDecision;

  bool get hasDecreaseProposal =>
      status == PerformanceMissResponseStatus.decreaseProposed &&
      boundedDecision.changesLoad;

  bool get requiresUserConfirmation =>
      hasDecreaseProposal && boundedDecision.requiresUserConfirmation;
}

PerformanceMissResponseProposal proposePerformanceMissResponse({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
  required List<PerformanceMissExposure> exposures,
  double? requestedDecreaseKilograms,
}) {
  final matchingExposures =
      exposures
          .where((exposure) => exposure.exerciseId == prescription.exerciseId)
          .toList(growable: false)
        ..sort(_compareExposureRecency);

  if (matchingExposures.isEmpty) {
    return _proposal(
      status: PerformanceMissResponseStatus.held,
      boundedDecision: _holdDecision(
        prescription: prescription,
        policy: policy,
      ),
      blockers: const [
        PerformanceMissResponseBlocker.noMatchingExposureHistory,
      ],
    );
  }

  final evaluatedExposures = matchingExposures
      .take(requiredRepeatedPerformanceMissCount)
      .toList(growable: false);
  final evaluatedExposureIds = [
    for (final exposure in evaluatedExposures) exposure.id,
  ];
  final performanceMissExposureIds = [
    for (final exposure in evaluatedExposures)
      if (exposure.signal == PerformanceMissSignal.performanceMiss) exposure.id,
  ];
  final latestExposure = evaluatedExposures.first;

  if (latestExposure.signal != PerformanceMissSignal.performanceMiss) {
    return _proposal(
      status: PerformanceMissResponseStatus.held,
      boundedDecision: _holdDecision(
        prescription: prescription,
        policy: policy,
      ),
      evaluatedExposureIds: evaluatedExposureIds,
      performanceMissExposureIds: performanceMissExposureIds,
      blockers: const [
        PerformanceMissResponseBlocker.latestExposureNotPerformanceMiss,
      ],
    );
  }

  final hasRepeatedPerformanceMisses =
      evaluatedExposures.length >= requiredRepeatedPerformanceMissCount &&
      evaluatedExposures.every(
        (exposure) => exposure.signal == PerformanceMissSignal.performanceMiss,
      );

  if (!hasRepeatedPerformanceMisses) {
    return _proposal(
      status: PerformanceMissResponseStatus.held,
      boundedDecision: _holdDecision(
        prescription: prescription,
        policy: policy,
      ),
      evaluatedExposureIds: evaluatedExposureIds,
      performanceMissExposureIds: performanceMissExposureIds,
      blockers: const [
        PerformanceMissResponseBlocker.isolatedPerformanceMiss,
        PerformanceMissResponseBlocker.notEnoughRepeatedPerformanceMisses,
      ],
    );
  }

  final boundedDecision = proposeBoundedLoadProgression(
    prescription: prescription,
    direction: BoundedProgressionDirection.decrease,
    policy: policy,
    requestedChangeKilograms:
        -(requestedDecreaseKilograms?.abs() ?? policy.loadIncrementKilograms),
  );

  if (boundedDecision.status == BoundedProgressionStatus.notComparable) {
    return _proposal(
      status: PerformanceMissResponseStatus.notComparable,
      boundedDecision: boundedDecision,
      evaluatedExposureIds: evaluatedExposureIds,
      performanceMissExposureIds: performanceMissExposureIds,
      blockers: const [
        PerformanceMissResponseBlocker.boundedProgressionNotComparable,
      ],
    );
  }

  if (!boundedDecision.changesLoad) {
    return _proposal(
      status: PerformanceMissResponseStatus.held,
      boundedDecision: boundedDecision,
      evaluatedExposureIds: evaluatedExposureIds,
      performanceMissExposureIds: performanceMissExposureIds,
      blockers: const [PerformanceMissResponseBlocker.boundedProgressionHeld],
    );
  }

  return _proposal(
    status: PerformanceMissResponseStatus.decreaseProposed,
    boundedDecision: boundedDecision,
    evaluatedExposureIds: evaluatedExposureIds,
    performanceMissExposureIds: performanceMissExposureIds,
  );
}

PerformanceMissResponseProposal _proposal({
  required PerformanceMissResponseStatus status,
  required BoundedProgressionDecision boundedDecision,
  List<String> evaluatedExposureIds = const [],
  List<String> performanceMissExposureIds = const [],
  List<PerformanceMissResponseBlocker> blockers = const [],
}) {
  return PerformanceMissResponseProposal(
    ruleSetVersion: performanceMissResponseRuleSetVersion,
    status: status,
    requiredRepeatedMissCount: requiredRepeatedPerformanceMissCount,
    evaluatedExposureIds: List.unmodifiable(evaluatedExposureIds),
    performanceMissExposureIds: List.unmodifiable(performanceMissExposureIds),
    blockers: List.unmodifiable(blockers),
    boundedDecision: boundedDecision,
  );
}

BoundedProgressionDecision _holdDecision({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
}) {
  return proposeBoundedLoadProgression(
    prescription: prescription,
    direction: BoundedProgressionDirection.hold,
    policy: policy,
  );
}

int _compareExposureRecency(
  PerformanceMissExposure left,
  PerformanceMissExposure right,
) {
  final timeComparison = right.performedAt.compareTo(left.performedAt);
  if (timeComparison != 0) {
    return timeComparison;
  }
  return right.id.compareTo(left.id);
}
