import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/plateau_deload_data_gate.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  final now = DateTime.utc(2026, 7, 21, 12);

  test('blocks plateau checks without enough comparable exposure data', () {
    final decision = evaluatePlateauDeloadDataGate(
      prescription: _prescription(),
      recommendationKind: PlateauDeloadRecommendationKind.plateau,
      exposures: [
        _exposure(id: 'latest', performedAt: now),
        _exposure(id: 'week-1', performedAt: now.subtract(_days(7))),
        _exposure(id: 'week-2', performedAt: now.subtract(_days(14))),
      ],
    );

    expect(decision.ruleSetVersion, plateauDeloadDataGateRuleSetVersion);
    expect(decision.status, PlateauDeloadDataGateStatus.insufficientData);
    expect(decision.allowsRecommendation, isFalse);
    expect(decision.requiredComparableExposureCount, 4);
    expect(decision.requiredObservationSpanDays, 21);
    expect(decision.comparableExposureIds, ['latest', 'week-1', 'week-2']);
    expect(
      decision.blockers,
      contains(PlateauDeloadDataGateBlocker.notEnoughComparableExposures),
    );
  });

  test('blocks plateau checks when comparable data is too compressed', () {
    final decision = evaluatePlateauDeloadDataGate(
      prescription: _prescription(),
      recommendationKind: PlateauDeloadRecommendationKind.plateau,
      exposures: [
        _exposure(id: 'latest', performedAt: now),
        _exposure(id: 'day-3', performedAt: now.subtract(_days(3))),
        _exposure(id: 'day-6', performedAt: now.subtract(_days(6))),
        _exposure(id: 'day-9', performedAt: now.subtract(_days(9))),
      ],
    );

    expect(decision.status, PlateauDeloadDataGateStatus.insufficientData);
    expect(decision.observationSpanDays, 9);
    expect(
      decision.blockers,
      contains(PlateauDeloadDataGateBlocker.notEnoughObservationSpan),
    );
  });

  test('allows plateau checks after enough comparable data over time', () {
    final decision = evaluatePlateauDeloadDataGate(
      prescription: _prescription(),
      recommendationKind: PlateauDeloadRecommendationKind.plateau,
      exposures: [
        _exposure(id: 'latest', performedAt: now),
        _exposure(id: 'week-1', performedAt: now.subtract(_days(7))),
        _exposure(id: 'week-2', performedAt: now.subtract(_days(14))),
        _exposure(id: 'week-3', performedAt: now.subtract(_days(21))),
      ],
    );

    expect(decision.status, PlateauDeloadDataGateStatus.eligible);
    expect(decision.allowsRecommendation, isTrue);
    expect(decision.matchingExposureIds, [
      'latest',
      'week-1',
      'week-2',
      'week-3',
    ]);
    expect(decision.comparableExposureIds, [
      'latest',
      'week-1',
      'week-2',
      'week-3',
    ]);
    expect(decision.notComparableExposureIds, isEmpty);
    expect(decision.observationSpanDays, 21);
    expect(decision.blockers, isEmpty);
  });

  test(
    'blocks deload checks when latest matching exposure is not comparable',
    () {
      final decision = evaluatePlateauDeloadDataGate(
        prescription: _prescription(),
        recommendationKind: PlateauDeloadRecommendationKind.deload,
        exposures: [
          _exposure(
            id: 'latest-interruption',
            performedAt: now,
            signal: PerformanceMissSignal.notComparable,
          ),
          _exposure(
            id: 'week-1',
            performedAt: now.subtract(_days(7)),
            signal: PerformanceMissSignal.performanceMiss,
          ),
          _exposure(
            id: 'week-2',
            performedAt: now.subtract(_days(14)),
            signal: PerformanceMissSignal.performanceMiss,
          ),
          _exposure(id: 'week-3', performedAt: now.subtract(_days(21))),
        ],
      );

      expect(
        decision.recommendationKind,
        PlateauDeloadRecommendationKind.deload,
      );
      expect(decision.status, PlateauDeloadDataGateStatus.insufficientData);
      expect(decision.requiredComparableExposureCount, 3);
      expect(decision.requiredObservationSpanDays, 14);
      expect(decision.comparableExposureIds, ['week-1', 'week-2', 'week-3']);
      expect(decision.notComparableExposureIds, ['latest-interruption']);
      expect(
        decision.blockers,
        contains(PlateauDeloadDataGateBlocker.latestExposureNotComparable),
      );
    },
  );

  test('allows deload checks with enough matching comparable data', () {
    final decision = evaluatePlateauDeloadDataGate(
      prescription: _prescription(),
      recommendationKind: PlateauDeloadRecommendationKind.deload,
      exposures: [
        _exposure(
          id: 'other-exercise',
          exerciseId: 'back_squat',
          performedAt: now,
          signal: PerformanceMissSignal.notComparable,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'week-1',
          performedAt: now.subtract(_days(7)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'week-2',
          performedAt: now.subtract(_days(14)),
          signal: PerformanceMissSignal.targetMet,
        ),
      ],
    );

    expect(decision.status, PlateauDeloadDataGateStatus.eligible);
    expect(decision.allowsRecommendation, isTrue);
    expect(decision.matchingExposureIds, ['latest', 'week-1', 'week-2']);
    expect(decision.comparableExposureIds, ['latest', 'week-1', 'week-2']);
    expect(decision.observationSpanDays, 14);
    expect(decision.blockers, isEmpty);
  });
}

ProgramExercisePrescription _prescription() {
  return const ProgramExercisePrescription(
    exerciseId: 'barbell_bench_press',
    setCount: 3,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: 80,
    restSeconds: 120,
  );
}

PerformanceMissExposure _exposure({
  required String id,
  required DateTime performedAt,
  String exerciseId = 'barbell_bench_press',
  PerformanceMissSignal signal = PerformanceMissSignal.targetMet,
}) {
  return PerformanceMissExposure(
    id: id,
    exerciseId: exerciseId,
    performedAt: performedAt,
    signal: signal,
  );
}

Duration _days(int days) => Duration(days: days);
