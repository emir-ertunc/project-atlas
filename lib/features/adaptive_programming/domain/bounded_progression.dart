import 'dart:math' as math;

import 'package:project_atlas/features/program/domain/program_builder.dart';

const boundedProgressionRuleSetVersion = 'bounded_progression.v1';

enum BoundedProgressionDirection { increase, hold, decrease }

enum BoundedProgressionStatus { proposed, held, notComparable }

enum BoundedProgressionLimit {
  roundedToLoadIncrement,
  increaseCappedByPercent,
  decreaseCappedByPercent,
  minimumLoadFloor,
}

enum BoundedProgressionBlocker {
  missingCurrentLoad,
  invalidLoadIncrement,
  invalidMinimumLoad,
  invalidIncreaseBound,
  invalidDecreaseBound,
  invalidRequestedChange,
}

final class BoundedProgressionPolicy {
  const BoundedProgressionPolicy({
    required this.loadIncrementKilograms,
    this.minimumLoadKilograms = 0,
    this.maximumIncreasePercent = 10,
    this.maximumDecreasePercent = 10,
  });

  final double loadIncrementKilograms;
  final double minimumLoadKilograms;
  final double maximumIncreasePercent;
  final double maximumDecreasePercent;
}

final class BoundedProgressionDecision {
  const BoundedProgressionDecision({
    required this.ruleSetVersion,
    required this.status,
    required this.direction,
    required this.requestedChangeKilograms,
    required this.appliedChangeKilograms,
    required this.limits,
    required this.blockers,
    this.previousLoadKilograms,
    this.proposedLoadKilograms,
  });

  final String ruleSetVersion;
  final BoundedProgressionStatus status;
  final BoundedProgressionDirection direction;
  final double? previousLoadKilograms;
  final double? proposedLoadKilograms;
  final double requestedChangeKilograms;
  final double appliedChangeKilograms;
  final List<BoundedProgressionLimit> limits;
  final List<BoundedProgressionBlocker> blockers;

  bool get changesLoad =>
      previousLoadKilograms != null &&
      proposedLoadKilograms != null &&
      (proposedLoadKilograms! - previousLoadKilograms!).abs() >
          _comparisonTolerance;

  bool get requiresUserConfirmation => changesLoad;

  ProgramExercisePrescription applyTo(
    ProgramExercisePrescription prescription,
  ) {
    if (!changesLoad || proposedLoadKilograms == null) {
      return prescription;
    }
    return prescription.copyWith(loadKilograms: proposedLoadKilograms);
  }
}

BoundedProgressionDecision proposeBoundedLoadProgression({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionDirection direction,
  required BoundedProgressionPolicy policy,
  double? requestedChangeKilograms,
}) {
  final currentLoad = prescription.loadKilograms;
  final requestedMagnitude = _requestedMagnitude(
    direction: direction,
    requestedChangeKilograms: requestedChangeKilograms,
    fallbackMagnitude: policy.loadIncrementKilograms,
  );

  if (direction == BoundedProgressionDirection.hold) {
    return BoundedProgressionDecision(
      ruleSetVersion: boundedProgressionRuleSetVersion,
      status: BoundedProgressionStatus.held,
      direction: direction,
      previousLoadKilograms: currentLoad,
      proposedLoadKilograms: currentLoad,
      requestedChangeKilograms: 0,
      appliedChangeKilograms: 0,
      limits: const [],
      blockers: const [],
    );
  }

  final blockers = _blockersFor(
    policy: policy,
    requestedMagnitude: requestedMagnitude,
  );
  if (currentLoad == null) {
    blockers.add(BoundedProgressionBlocker.missingCurrentLoad);
  }

  if (blockers.isNotEmpty) {
    return BoundedProgressionDecision(
      ruleSetVersion: boundedProgressionRuleSetVersion,
      status: BoundedProgressionStatus.notComparable,
      direction: direction,
      previousLoadKilograms: currentLoad,
      proposedLoadKilograms: currentLoad,
      requestedChangeKilograms: _signedRequestedChange(
        direction: direction,
        magnitude: requestedMagnitude,
      ),
      appliedChangeKilograms: 0,
      limits: const [],
      blockers: List.unmodifiable(blockers),
    );
  }

  final decision = switch (direction) {
    BoundedProgressionDirection.increase => _increaseDecision(
      currentLoad: currentLoad!,
      requestedMagnitude: requestedMagnitude,
      policy: policy,
    ),
    BoundedProgressionDirection.decrease => _decreaseDecision(
      currentLoad: currentLoad!,
      requestedMagnitude: requestedMagnitude,
      policy: policy,
    ),
    BoundedProgressionDirection.hold => throw StateError(
      'Hold decisions are handled before load bounds are evaluated.',
    ),
  };

  final appliedChange = decision.proposedLoadKilograms - currentLoad;
  final status = appliedChange.abs() <= _comparisonTolerance
      ? BoundedProgressionStatus.held
      : BoundedProgressionStatus.proposed;

  return BoundedProgressionDecision(
    ruleSetVersion: boundedProgressionRuleSetVersion,
    status: status,
    direction: direction,
    previousLoadKilograms: currentLoad,
    proposedLoadKilograms: decision.proposedLoadKilograms,
    requestedChangeKilograms: _signedRequestedChange(
      direction: direction,
      magnitude: requestedMagnitude,
    ),
    appliedChangeKilograms: appliedChange,
    limits: List.unmodifiable(decision.limits),
    blockers: const [],
  );
}

List<BoundedProgressionBlocker> _blockersFor({
  required BoundedProgressionPolicy policy,
  required double requestedMagnitude,
}) {
  final blockers = <BoundedProgressionBlocker>[];
  if (!policy.loadIncrementKilograms.isFinite ||
      policy.loadIncrementKilograms <= _comparisonTolerance) {
    blockers.add(BoundedProgressionBlocker.invalidLoadIncrement);
  }
  if (!policy.minimumLoadKilograms.isFinite ||
      policy.minimumLoadKilograms < -_comparisonTolerance) {
    blockers.add(BoundedProgressionBlocker.invalidMinimumLoad);
  }
  if (!policy.maximumIncreasePercent.isFinite ||
      policy.maximumIncreasePercent <= _comparisonTolerance) {
    blockers.add(BoundedProgressionBlocker.invalidIncreaseBound);
  }
  if (!policy.maximumDecreasePercent.isFinite ||
      policy.maximumDecreasePercent <= _comparisonTolerance) {
    blockers.add(BoundedProgressionBlocker.invalidDecreaseBound);
  }
  if (!requestedMagnitude.isFinite ||
      requestedMagnitude <= _comparisonTolerance) {
    blockers.add(BoundedProgressionBlocker.invalidRequestedChange);
  }
  return blockers;
}

_LoadDecision _increaseDecision({
  required double currentLoad,
  required double requestedMagnitude,
  required BoundedProgressionPolicy policy,
}) {
  final limits = <BoundedProgressionLimit>{};
  final roundedRequest = _ceilToIncrement(
    requestedMagnitude,
    policy.loadIncrementKilograms,
  );
  if ((roundedRequest - requestedMagnitude).abs() > _comparisonTolerance) {
    limits.add(BoundedProgressionLimit.roundedToLoadIncrement);
  }

  final maximumIncrease = math.max(
    policy.loadIncrementKilograms,
    currentLoad * policy.maximumIncreasePercent / 100,
  );
  var appliedMagnitude = roundedRequest;
  if (appliedMagnitude > maximumIncrease + _comparisonTolerance) {
    limits.add(BoundedProgressionLimit.increaseCappedByPercent);
    appliedMagnitude = _floorToIncrement(
      maximumIncrease,
      policy.loadIncrementKilograms,
    );
    if (appliedMagnitude < policy.loadIncrementKilograms) {
      appliedMagnitude = policy.loadIncrementKilograms;
    }
  }

  return _LoadDecision(
    proposedLoadKilograms: _cleanLoad(currentLoad + appliedMagnitude),
    limits: limits,
  );
}

_LoadDecision _decreaseDecision({
  required double currentLoad,
  required double requestedMagnitude,
  required BoundedProgressionPolicy policy,
}) {
  final limits = <BoundedProgressionLimit>{};
  final roundedRequest = _ceilToIncrement(
    requestedMagnitude,
    policy.loadIncrementKilograms,
  );
  if ((roundedRequest - requestedMagnitude).abs() > _comparisonTolerance) {
    limits.add(BoundedProgressionLimit.roundedToLoadIncrement);
  }

  final maximumDecrease = math.max(
    policy.loadIncrementKilograms,
    currentLoad * policy.maximumDecreasePercent / 100,
  );
  final floorDistance = math.max(
    0.0,
    currentLoad - policy.minimumLoadKilograms,
  );
  var allowedMagnitude = math.min(maximumDecrease, floorDistance);
  var appliedMagnitude = roundedRequest;

  if (appliedMagnitude > maximumDecrease + _comparisonTolerance) {
    limits.add(BoundedProgressionLimit.decreaseCappedByPercent);
    appliedMagnitude = maximumDecrease;
  }
  if (appliedMagnitude > floorDistance + _comparisonTolerance) {
    limits.add(BoundedProgressionLimit.minimumLoadFloor);
    appliedMagnitude = floorDistance;
  }

  allowedMagnitude = math.min(allowedMagnitude, appliedMagnitude);
  if (allowedMagnitude >= policy.loadIncrementKilograms) {
    appliedMagnitude = _floorToIncrement(
      allowedMagnitude,
      policy.loadIncrementKilograms,
    );
    if (appliedMagnitude < policy.loadIncrementKilograms) {
      appliedMagnitude = policy.loadIncrementKilograms;
    }
  } else {
    appliedMagnitude = allowedMagnitude;
  }

  final proposedLoad = math.max(
    policy.minimumLoadKilograms,
    currentLoad - appliedMagnitude,
  );

  return _LoadDecision(
    proposedLoadKilograms: _cleanLoad(proposedLoad),
    limits: limits,
  );
}

double _requestedMagnitude({
  required BoundedProgressionDirection direction,
  required double? requestedChangeKilograms,
  required double fallbackMagnitude,
}) {
  if (direction == BoundedProgressionDirection.hold) {
    return 0;
  }
  final requested = requestedChangeKilograms?.abs();
  if (requested == null || requested <= _comparisonTolerance) {
    return fallbackMagnitude;
  }
  return requested;
}

double _signedRequestedChange({
  required BoundedProgressionDirection direction,
  required double magnitude,
}) {
  return switch (direction) {
    BoundedProgressionDirection.increase => magnitude,
    BoundedProgressionDirection.decrease => -magnitude,
    BoundedProgressionDirection.hold => 0,
  };
}

double _ceilToIncrement(double value, double increment) {
  return (value / increment).ceilToDouble() * increment;
}

double _floorToIncrement(double value, double increment) {
  return (value / increment).floorToDouble() * increment;
}

double _cleanLoad(double value) {
  final scaled = (value * _loadPrecisionScale).roundToDouble();
  return scaled / _loadPrecisionScale;
}

const _comparisonTolerance = 0.000001;
const _loadPrecisionScale = 1000;

final class _LoadDecision {
  const _LoadDecision({
    required this.proposedLoadKilograms,
    required this.limits,
  });

  final double proposedLoadKilograms;
  final Set<BoundedProgressionLimit> limits;
}
