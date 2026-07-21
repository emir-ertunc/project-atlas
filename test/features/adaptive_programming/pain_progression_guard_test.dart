import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/pain_progression_guard.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test('stops progression and returns guidance when pain is reported', () {
    final decision = guardProgressionForPain(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'latest',
          performedAt: now,
          setResults: {1: null, 2: SetResult.pain, 3: SetResult.pain},
        ),
      ],
    );

    expect(decision.ruleSetVersion, painProgressionGuardRuleSetVersion);
    expect(decision.status, PainProgressionGuardStatus.progressionStopped);
    expect(decision.blocksProgression, isTrue);
    expect(decision.hasSafetyGuidance, isTrue);
    expect(decision.triggeringExposureIds, ['latest']);
    expect(decision.triggers.single.setOrders, [2, 3]);
    expect(
      decision.guidance,
      contains(PainSafetyGuidance.stopLoadedProgression),
    );
    expect(
      decision.guidance,
      contains(PainSafetyGuidance.avoidTrainingThroughPain),
    );
    expect(decision.boundedDecision.status, BoundedProgressionStatus.held);
    expect(
      decision.boundedDecision.direction,
      BoundedProgressionDirection.hold,
    );
    expect(decision.boundedDecision.proposedLoadKilograms, 80);
    expect(decision.boundedDecision.changesLoad, isFalse);
  });

  test('ignores pain reports for other exercises', () {
    final decision = guardProgressionForPain(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'other-exercise',
          exerciseId: 'back_squat',
          performedAt: now,
          setResults: {1: SetResult.pain},
        ),
      ],
    );

    expect(decision.status, PainProgressionGuardStatus.noPainReported);
    expect(decision.blocksProgression, isFalse);
    expect(decision.guidance, isEmpty);
    expect(decision.triggers, isEmpty);
    expect(decision.boundedDecision.status, BoundedProgressionStatus.held);
  });

  test('returns no pain decision when matching exposures are pain free', () {
    final decision = guardProgressionForPain(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(id: 'latest', performedAt: now),
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
      ],
    );

    expect(decision.status, PainProgressionGuardStatus.noPainReported);
    expect(decision.blocksProgression, isFalse);
    expect(decision.hasSafetyGuidance, isFalse);
    expect(decision.triggeringExposureIds, isEmpty);
  });

  test('orders pain triggers by most recent matching exposure first', () {
    final decision = guardProgressionForPain(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          setResults: {1: SetResult.pain},
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          setResults: {3: SetResult.pain},
        ),
      ],
    );

    expect(decision.status, PainProgressionGuardStatus.progressionStopped);
    expect(decision.triggeringExposureIds, ['latest', 'older']);
    expect(decision.triggers.first.setOrders, [3]);
    expect(decision.triggers.last.setOrders, [1]);
  });

  test('keeps pain out of performance miss streaks', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 4,
        loadKilograms: 60,
        setResults: {1: SetResult.pain},
      ),
    );

    expect(classification.signal, PerformanceMissSignal.notComparable);
    expect(classification.countsTowardPerformanceFailureStreak, isFalse);
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.painReported),
    );
  });
}

ProgramExercisePrescription _prescription({required double? loadKilograms}) {
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

ProgressionExposureEvidence _exposure({
  required String id,
  required DateTime performedAt,
  String exerciseId = 'barbell_bench_press',
  int repetitions = 8,
  double loadKilograms = 80,
  Map<int, SetResult?> setResults = const {},
}) {
  return ProgressionExposureEvidence(
    id: id,
    exerciseId: exerciseId,
    performedAt: performedAt,
    sets: [
      for (var setOrder = 1; setOrder <= 3; setOrder += 1)
        ProgressionSetEvidence(
          setOrder: setOrder,
          repetitions: repetitions,
          loadKilograms: loadKilograms,
          result: setResults[setOrder],
        ),
    ],
  );
}
