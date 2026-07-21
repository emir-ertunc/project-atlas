import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/pain_progression_guard.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/plateau_deload_data_gate.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/adaptive_programming/domain/recommendation_explanation.dart';
import 'package:project_atlas/features/adaptive_programming/domain/recommendation_review_flow.dart';
import 'package:project_atlas/features/adaptive_programming/domain/smallest_load_increase.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final start = DateTime.utc(2026, 7, 21, 12);

  test('golden persona completes twelve weeks of clean progression safely', () {
    final result = _runTwelveWeekSimulation(
      start: start,
      initialPrescription: _prescription(loadKilograms: 80),
      policy: policy,
      weeks: [for (var week = 1; week <= 12; week += 1) _WeekOutcome.success()],
    );

    expect(result.weekCount, 12);
    expect(result.finalLoadKilograms, 95);
    expect(result.acceptedIncreaseWeeks, [2, 4, 6, 8, 10, 12]);
    expect(result.acceptedDecreaseWeeks, isEmpty);
    expect(result.progressionStopWeeks, isEmpty);
    expect(result.reviewedRecommendationCount, 6);
    expect(result.maximumWeeklyLoadIncreaseKilograms, 2.5);
    expect(result.plateauGate.status, PlateauDeloadDataGateStatus.eligible);
    expect(result.deloadGate.status, PlateauDeloadDataGateStatus.eligible);
  });

  test(
    'golden persona holds isolated misses and reduces only after repeated misses',
    () {
      final result = _runTwelveWeekSimulation(
        start: start,
        initialPrescription: _prescription(loadKilograms: 100),
        policy: policy,
        weeks: [
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.performanceMiss(),
          _WeekOutcome.performanceMiss(),
          _WeekOutcome.interruption(SetResult.timeLimitation),
          _WeekOutcome.performanceMiss(),
          _WeekOutcome.performanceMiss(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
        ],
      );

      expect(result.weekCount, 12);
      expect(result.finalLoadKilograms, 102.5);
      expect(result.acceptedIncreaseWeeks, [2, 9, 11]);
      expect(result.acceptedDecreaseWeeks, [4, 7]);
      expect(result.progressionStopWeeks, isEmpty);
      expect(result.weekRecords[2].action, _SimulationAction.hold);
      expect(result.weekRecords[5].action, _SimulationAction.hold);
      expect(result.weekRecords[4].signal, PerformanceMissSignal.notComparable);
      expect(result.maximumWeeklyLoadDecreaseKilograms, -2.5);
    },
  );

  test(
    'golden persona stops progression after pain during a twelve-week run',
    () {
      final result = _runTwelveWeekSimulation(
        start: start,
        initialPrescription: _prescription(loadKilograms: 80),
        policy: policy,
        weeks: [
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.pain(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
          _WeekOutcome.success(),
        ],
      );

      expect(result.weekCount, 12);
      expect(result.finalLoadKilograms, 85);
      expect(result.acceptedIncreaseWeeks, [2, 4]);
      expect(result.acceptedDecreaseWeeks, isEmpty);
      expect(result.progressionStopWeeks, [5, 6, 7, 8, 9, 10, 11, 12]);
      expect(result.reviewedRecommendationCount, 10);
      expect(result.weekRecords[4].triggeringEvidenceIds, contains('week-5'));
      expect(result.weekRecords.last.triggeringEvidenceIds, contains('week-5'));
    },
  );
}

_SimulationResult _runTwelveWeekSimulation({
  required DateTime start,
  required ProgramExercisePrescription initialPrescription,
  required BoundedProgressionPolicy policy,
  required List<_WeekOutcome> weeks,
}) {
  assert(weeks.length == 12);

  var prescription = initialPrescription;
  final loadExposures = <LoadProgressionExposure>[];
  final rawExposures = <ProgressionExposureEvidence>[];
  final classifiedExposures = <PerformanceMissExposure>[];
  final records = <_SimulationWeekRecord>[];

  for (var index = 0; index < weeks.length; index += 1) {
    final weekNumber = index + 1;
    final outcome = weeks[index];
    final loadAtStart = prescription.loadKilograms;
    final performedAt = start.add(Duration(days: index * 7));
    final exposureId = 'week-$weekNumber';
    final actualLoad = loadAtStart ?? 0;
    final rawExposure = _rawExposure(
      id: exposureId,
      performedAt: performedAt,
      repetitions: outcome.repetitions,
      loadKilograms: actualLoad,
      rir: outcome.rir,
      result: outcome.result,
    );
    final loadExposure = _loadExposure(
      id: exposureId,
      performedAt: performedAt,
      repetitions: outcome.repetitions,
      loadKilograms: actualLoad,
      rir: outcome.rir,
      result: outcome.result,
    );

    rawExposures.add(rawExposure);
    loadExposures.add(loadExposure);

    final classification = classifyProgressionSignal(
      prescription: prescription,
      exposure: rawExposure,
    );
    classifiedExposures.add(classification.toPerformanceMissExposure());

    final painDecision = guardProgressionForPain(
      prescription: prescription,
      policy: policy,
      exposures: rawExposures,
    );
    final painExplanation = explainPainProgressionGuardDecision(
      decision: painDecision,
    );

    var action = _SimulationAction.hold;
    var reviewed = false;
    var triggeringEvidenceIds = <String>[];

    if (painExplanation.hasChangedValue) {
      final review = acceptAdaptiveRecommendation(
        openAdaptiveRecommendationReview(
          recommendationId: 'pain-$exposureId',
          explanation: painExplanation,
          prescription: prescription,
        ),
      );
      prescription = review.currentPrescription;
      action = _SimulationAction.progressionStopped;
      reviewed = true;
      triggeringEvidenceIds = painExplanation.triggeringEvidenceIds;
    } else {
      final increase = proposeSmallestAvailableLoadIncrease(
        prescription: prescription,
        policy: policy,
        exposures: loadExposures,
      );

      if (increase.hasProposal) {
        final explanation = explainSmallestLoadIncreaseProposal(
          proposal: increase,
        );
        final review = acceptAdaptiveRecommendation(
          openAdaptiveRecommendationReview(
            recommendationId: 'increase-$exposureId',
            explanation: explanation,
            prescription: prescription,
          ),
        );
        prescription = review.currentPrescription;
        action = _SimulationAction.increaseAccepted;
        reviewed = true;
        triggeringEvidenceIds = explanation.triggeringEvidenceIds;
      } else {
        final decrease = proposePerformanceMissResponse(
          prescription: prescription,
          policy: policy,
          exposures: classifiedExposures,
        );

        if (decrease.hasDecreaseProposal) {
          final explanation = explainPerformanceMissResponseProposal(
            proposal: decrease,
          );
          final review = acceptAdaptiveRecommendation(
            openAdaptiveRecommendationReview(
              recommendationId: 'decrease-$exposureId',
              explanation: explanation,
              prescription: prescription,
            ),
          );
          prescription = review.currentPrescription;
          action = _SimulationAction.decreaseAccepted;
          reviewed = true;
          triggeringEvidenceIds = explanation.triggeringEvidenceIds;
        }
      }
    }

    records.add(
      _SimulationWeekRecord(
        weekNumber: weekNumber,
        loadAtStart: loadAtStart,
        loadAtEnd: prescription.loadKilograms,
        signal: classification.signal,
        action: action,
        reviewed: reviewed,
        triggeringEvidenceIds: triggeringEvidenceIds,
      ),
    );
  }

  return _SimulationResult(
    finalPrescription: prescription,
    weekRecords: records,
    plateauGate: evaluatePlateauDeloadDataGate(
      prescription: prescription,
      recommendationKind: PlateauDeloadRecommendationKind.plateau,
      exposures: classifiedExposures,
    ),
    deloadGate: evaluatePlateauDeloadDataGate(
      prescription: prescription,
      recommendationKind: PlateauDeloadRecommendationKind.deload,
      exposures: classifiedExposures,
    ),
  );
}

ProgramExercisePrescription _prescription({required double loadKilograms}) {
  return ProgramExercisePrescription(
    exerciseId: 'barbell_bench_press',
    setCount: 3,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: loadKilograms,
    restSeconds: 120,
  );
}

ProgressionExposureEvidence _rawExposure({
  required String id,
  required DateTime performedAt,
  required int repetitions,
  required double loadKilograms,
  required int? rir,
  SetResult? result,
}) {
  return ProgressionExposureEvidence(
    id: id,
    exerciseId: 'barbell_bench_press',
    performedAt: performedAt,
    sets: [
      for (var setOrder = 1; setOrder <= 3; setOrder += 1)
        ProgressionSetEvidence(
          setOrder: setOrder,
          repetitions: repetitions,
          loadKilograms: loadKilograms,
          result: result,
        ),
    ],
  );
}

LoadProgressionExposure _loadExposure({
  required String id,
  required DateTime performedAt,
  required int repetitions,
  required double loadKilograms,
  required int? rir,
  SetResult? result,
}) {
  return LoadProgressionExposure(
    id: id,
    exerciseId: 'barbell_bench_press',
    performedAt: performedAt,
    sets: [
      for (var setOrder = 1; setOrder <= 3; setOrder += 1)
        LoadProgressionSetObservation(
          setOrder: setOrder,
          repetitions: repetitions,
          loadKilograms: loadKilograms,
          rir: rir,
          result: result,
        ),
    ],
  );
}

final class _WeekOutcome {
  const _WeekOutcome({
    required this.repetitions,
    required this.rir,
    this.result,
  });

  factory _WeekOutcome.success() {
    return const _WeekOutcome(repetitions: 8, rir: 2);
  }

  factory _WeekOutcome.performanceMiss() {
    return const _WeekOutcome(
      repetitions: 4,
      rir: 0,
      result: SetResult.strengthLimitation,
    );
  }

  factory _WeekOutcome.interruption(SetResult result) {
    return _WeekOutcome(repetitions: 4, rir: null, result: result);
  }

  factory _WeekOutcome.pain() {
    return const _WeekOutcome(
      repetitions: 5,
      rir: null,
      result: SetResult.pain,
    );
  }

  final int repetitions;
  final int? rir;
  final SetResult? result;
}

enum _SimulationAction {
  hold,
  increaseAccepted,
  decreaseAccepted,
  progressionStopped,
}

final class _SimulationWeekRecord {
  const _SimulationWeekRecord({
    required this.weekNumber,
    required this.loadAtStart,
    required this.loadAtEnd,
    required this.signal,
    required this.action,
    required this.reviewed,
    required this.triggeringEvidenceIds,
  });

  final int weekNumber;
  final double? loadAtStart;
  final double? loadAtEnd;
  final PerformanceMissSignal signal;
  final _SimulationAction action;
  final bool reviewed;
  final List<String> triggeringEvidenceIds;
}

final class _SimulationResult {
  const _SimulationResult({
    required this.finalPrescription,
    required this.weekRecords,
    required this.plateauGate,
    required this.deloadGate,
  });

  final ProgramExercisePrescription finalPrescription;
  final List<_SimulationWeekRecord> weekRecords;
  final PlateauDeloadDataGateDecision plateauGate;
  final PlateauDeloadDataGateDecision deloadGate;

  int get weekCount => weekRecords.length;

  double? get finalLoadKilograms => finalPrescription.loadKilograms;

  int get reviewedRecommendationCount =>
      weekRecords.where((record) => record.reviewed).length;

  List<int> get acceptedIncreaseWeeks => [
    for (final record in weekRecords)
      if (record.action == _SimulationAction.increaseAccepted)
        record.weekNumber,
  ];

  List<int> get acceptedDecreaseWeeks => [
    for (final record in weekRecords)
      if (record.action == _SimulationAction.decreaseAccepted)
        record.weekNumber,
  ];

  List<int> get progressionStopWeeks => [
    for (final record in weekRecords)
      if (record.action == _SimulationAction.progressionStopped)
        record.weekNumber,
  ];

  double get maximumWeeklyLoadIncreaseKilograms {
    return weekRecords
        .map((record) => (record.loadAtEnd ?? 0) - (record.loadAtStart ?? 0))
        .fold<double>(
          0,
          (maximum, change) => change > maximum ? change : maximum,
        );
  }

  double get maximumWeeklyLoadDecreaseKilograms {
    return weekRecords
        .map((record) => (record.loadAtEnd ?? 0) - (record.loadAtStart ?? 0))
        .fold<double>(
          0,
          (minimum, change) => change < minimum ? change : minimum,
        );
  }
}
