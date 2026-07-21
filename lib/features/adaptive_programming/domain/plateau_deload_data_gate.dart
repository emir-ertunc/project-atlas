import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const plateauDeloadDataGateRuleSetVersion = 'plateau_deload_data_gate.v1';
const defaultPlateauComparableExposureCount = 4;
const defaultPlateauObservationSpanDays = 21;
const defaultDeloadComparableExposureCount = 3;
const defaultDeloadObservationSpanDays = 14;

enum PlateauDeloadRecommendationKind { plateau, deload }

enum PlateauDeloadDataGateStatus { eligible, insufficientData }

enum PlateauDeloadDataGateBlocker {
  noMatchingExposureHistory,
  latestExposureNotComparable,
  notEnoughComparableExposures,
  notEnoughObservationSpan,
}

final class PlateauDeloadDataRequirements {
  const PlateauDeloadDataRequirements({
    this.plateauComparableExposureCount = defaultPlateauComparableExposureCount,
    this.plateauObservationSpanDays = defaultPlateauObservationSpanDays,
    this.deloadComparableExposureCount = defaultDeloadComparableExposureCount,
    this.deloadObservationSpanDays = defaultDeloadObservationSpanDays,
    this.requireLatestComparableExposure = true,
  }) : assert(plateauComparableExposureCount > 0),
       assert(plateauObservationSpanDays >= 0),
       assert(deloadComparableExposureCount > 0),
       assert(deloadObservationSpanDays >= 0);

  final int plateauComparableExposureCount;
  final int plateauObservationSpanDays;
  final int deloadComparableExposureCount;
  final int deloadObservationSpanDays;
  final bool requireLatestComparableExposure;

  int requiredComparableExposureCountFor(PlateauDeloadRecommendationKind kind) {
    return switch (kind) {
      PlateauDeloadRecommendationKind.plateau => plateauComparableExposureCount,
      PlateauDeloadRecommendationKind.deload => deloadComparableExposureCount,
    };
  }

  int requiredObservationSpanDaysFor(PlateauDeloadRecommendationKind kind) {
    return switch (kind) {
      PlateauDeloadRecommendationKind.plateau => plateauObservationSpanDays,
      PlateauDeloadRecommendationKind.deload => deloadObservationSpanDays,
    };
  }
}

final class PlateauDeloadDataGateDecision {
  const PlateauDeloadDataGateDecision({
    required this.ruleSetVersion,
    required this.recommendationKind,
    required this.status,
    required this.requiredComparableExposureCount,
    required this.requiredObservationSpanDays,
    required this.matchingExposureIds,
    required this.comparableExposureIds,
    required this.notComparableExposureIds,
    required this.observationSpanDays,
    required this.blockers,
  });

  final String ruleSetVersion;
  final PlateauDeloadRecommendationKind recommendationKind;
  final PlateauDeloadDataGateStatus status;
  final int requiredComparableExposureCount;
  final int requiredObservationSpanDays;
  final List<String> matchingExposureIds;
  final List<String> comparableExposureIds;
  final List<String> notComparableExposureIds;
  final int observationSpanDays;
  final List<PlateauDeloadDataGateBlocker> blockers;

  bool get allowsRecommendation =>
      status == PlateauDeloadDataGateStatus.eligible;
}

PlateauDeloadDataGateDecision evaluatePlateauDeloadDataGate({
  required ProgramExercisePrescription prescription,
  required PlateauDeloadRecommendationKind recommendationKind,
  required List<PerformanceMissExposure> exposures,
  PlateauDeloadDataRequirements requirements =
      const PlateauDeloadDataRequirements(),
}) {
  final requiredComparableExposureCount = requirements
      .requiredComparableExposureCountFor(recommendationKind);
  final requiredObservationSpanDays = requirements
      .requiredObservationSpanDaysFor(recommendationKind);
  final matchingExposures =
      exposures
          .where((exposure) => exposure.exerciseId == prescription.exerciseId)
          .toList(growable: false)
        ..sort(_compareExposureRecency);

  if (matchingExposures.isEmpty) {
    return _decision(
      recommendationKind: recommendationKind,
      status: PlateauDeloadDataGateStatus.insufficientData,
      requiredComparableExposureCount: requiredComparableExposureCount,
      requiredObservationSpanDays: requiredObservationSpanDays,
      blockers: const [PlateauDeloadDataGateBlocker.noMatchingExposureHistory],
    );
  }

  final comparableExposures = [
    for (final exposure in matchingExposures)
      if (_isComparable(exposure.signal)) exposure,
  ];
  final blockers = <PlateauDeloadDataGateBlocker>{};

  if (requirements.requireLatestComparableExposure &&
      !_isComparable(matchingExposures.first.signal)) {
    blockers.add(PlateauDeloadDataGateBlocker.latestExposureNotComparable);
  }

  if (comparableExposures.length < requiredComparableExposureCount) {
    blockers.add(PlateauDeloadDataGateBlocker.notEnoughComparableExposures);
  }

  final observationSpanDays = _observationSpanDays(comparableExposures);
  if (observationSpanDays < requiredObservationSpanDays) {
    blockers.add(PlateauDeloadDataGateBlocker.notEnoughObservationSpan);
  }

  return _decision(
    recommendationKind: recommendationKind,
    status: blockers.isEmpty
        ? PlateauDeloadDataGateStatus.eligible
        : PlateauDeloadDataGateStatus.insufficientData,
    requiredComparableExposureCount: requiredComparableExposureCount,
    requiredObservationSpanDays: requiredObservationSpanDays,
    matchingExposureIds: [
      for (final exposure in matchingExposures) exposure.id,
    ],
    comparableExposureIds: [
      for (final exposure in comparableExposures) exposure.id,
    ],
    notComparableExposureIds: [
      for (final exposure in matchingExposures)
        if (!_isComparable(exposure.signal)) exposure.id,
    ],
    observationSpanDays: observationSpanDays,
    blockers: blockers,
  );
}

PlateauDeloadDataGateDecision _decision({
  required PlateauDeloadRecommendationKind recommendationKind,
  required PlateauDeloadDataGateStatus status,
  required int requiredComparableExposureCount,
  required int requiredObservationSpanDays,
  List<String> matchingExposureIds = const [],
  List<String> comparableExposureIds = const [],
  List<String> notComparableExposureIds = const [],
  int observationSpanDays = 0,
  Iterable<PlateauDeloadDataGateBlocker> blockers = const [],
}) {
  return PlateauDeloadDataGateDecision(
    ruleSetVersion: plateauDeloadDataGateRuleSetVersion,
    recommendationKind: recommendationKind,
    status: status,
    requiredComparableExposureCount: requiredComparableExposureCount,
    requiredObservationSpanDays: requiredObservationSpanDays,
    matchingExposureIds: List.unmodifiable(matchingExposureIds),
    comparableExposureIds: List.unmodifiable(comparableExposureIds),
    notComparableExposureIds: List.unmodifiable(notComparableExposureIds),
    observationSpanDays: observationSpanDays,
    blockers: List.unmodifiable(blockers),
  );
}

bool _isComparable(PerformanceMissSignal signal) {
  return switch (signal) {
    PerformanceMissSignal.targetMet ||
    PerformanceMissSignal.performanceMiss => true,
    PerformanceMissSignal.notComparable => false,
  };
}

int _observationSpanDays(List<PerformanceMissExposure> exposures) {
  if (exposures.length < 2) {
    return 0;
  }

  final newest = exposures.first.performedAt;
  final oldest = exposures.last.performedAt;
  return newest.difference(oldest).inDays;
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
