import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test('classifies clean exposure as target met', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(id: 'latest', performedAt: now),
    );

    expect(
      classification.ruleSetVersion,
      progressionSignalClassifierRuleSetVersion,
    );
    expect(classification.signal, PerformanceMissSignal.targetMet);
    expect(classification.blockers, isEmpty);
    expect(classification.countsTowardPerformanceFailureStreak, isFalse);
  });

  test('classifies strength limitation and low reps as performance miss', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 5,
        result: SetResult.strengthLimitation,
      ),
    );

    expect(classification.signal, PerformanceMissSignal.performanceMiss);
    expect(classification.countsTowardPerformanceFailureStreak, isTrue);
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.strengthLimitation),
    );
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.repetitionsBelowMinimum),
    );
  });

  test('keeps time interruption out of performance failure streaks', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 3,
        loadKilograms: 60,
        result: SetResult.timeLimitation,
      ),
    );

    expect(classification.signal, PerformanceMissSignal.notComparable);
    expect(classification.countsTowardPerformanceFailureStreak, isFalse);
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.timeInterruption),
    );
  });

  test('keeps equipment interruption out of performance failure streaks', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 4,
        loadKilograms: 40,
        result: SetResult.equipmentLimitation,
      ),
    );

    expect(classification.signal, PerformanceMissSignal.notComparable);
    expect(classification.countsTowardPerformanceFailureStreak, isFalse);
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.equipmentInterruption),
    );
  });

  test('keeps external interruption out of performance failure streaks', () {
    final classification = classifyProgressionSignal(
      prescription: _prescription(loadKilograms: 80),
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 4,
        loadKilograms: 40,
        result: SetResult.externalInterruption,
      ),
    );

    expect(classification.signal, PerformanceMissSignal.notComparable);
    expect(classification.countsTowardPerformanceFailureStreak, isFalse);
    expect(
      classification.blockers,
      contains(ProgressionSignalBlocker.externalInterruption),
    );
  });

  test('interruption breaks repeated performance miss decrease proposals', () {
    final prescription = _prescription(loadKilograms: 80);
    final olderMiss = classifyProgressionSignal(
      prescription: prescription,
      exposure: _exposure(
        id: 'older',
        performedAt: now.subtract(const Duration(days: 7)),
        repetitions: 5,
        result: SetResult.techniqueLimitation,
      ),
    );
    final latestInterruption = classifyProgressionSignal(
      prescription: prescription,
      exposure: _exposure(
        id: 'latest',
        performedAt: now,
        repetitions: 4,
        loadKilograms: 40,
        result: SetResult.equipmentLimitation,
      ),
    );

    final proposal = proposePerformanceMissResponse(
      prescription: prescription,
      policy: policy,
      exposures: [
        olderMiss.toPerformanceMissExposure(),
        latestInterruption.toPerformanceMissExposure(),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.held);
    expect(proposal.hasDecreaseProposal, isFalse);
    expect(proposal.evaluatedExposureIds, ['latest', 'older']);
    expect(proposal.performanceMissExposureIds, ['older']);
    expect(
      proposal.blockers,
      contains(PerformanceMissResponseBlocker.latestExposureNotPerformanceMiss),
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
  int repetitions = 8,
  double loadKilograms = 80,
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
