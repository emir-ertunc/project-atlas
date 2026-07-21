import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test('holds after an isolated latest performance miss', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.targetMet,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    );

    expect(proposal.ruleSetVersion, performanceMissResponseRuleSetVersion);
    expect(proposal.status, PerformanceMissResponseStatus.held);
    expect(proposal.hasDecreaseProposal, isFalse);
    expect(proposal.evaluatedExposureIds, ['latest', 'older']);
    expect(proposal.performanceMissExposureIds, ['latest']);
    expect(
      proposal.blockers,
      contains(PerformanceMissResponseBlocker.isolatedPerformanceMiss),
    );
    expect(
      proposal.boundedDecision.direction,
      BoundedProgressionDirection.hold,
    );
    expect(proposal.boundedDecision.proposedLoadKilograms, 80);
  });

  test('proposes a bounded decrease after two repeated performance misses', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.decreaseProposed);
    expect(proposal.hasDecreaseProposal, isTrue);
    expect(proposal.requiresUserConfirmation, isTrue);
    expect(proposal.requiredRepeatedMissCount, 2);
    expect(proposal.evaluatedExposureIds, ['latest', 'older']);
    expect(proposal.performanceMissExposureIds, ['latest', 'older']);
    expect(proposal.blockers, isEmpty);
    expect(
      proposal.boundedDecision.direction,
      BoundedProgressionDirection.decrease,
    );
    expect(proposal.boundedDecision.requestedChangeKilograms, -2.5);
    expect(proposal.boundedDecision.proposedLoadKilograms, 77.5);
  });

  test('holds when the latest matching exposure is successful', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.targetMet,
        ),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.held);
    expect(proposal.hasDecreaseProposal, isFalse);
    expect(
      proposal.blockers,
      contains(PerformanceMissResponseBlocker.latestExposureNotPerformanceMiss),
    );
  });

  test('does not skip a recent non-miss to find older repeated misses', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'oldest',
          performedAt: now.subtract(const Duration(days: 14)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'middle',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.targetMet,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.held);
    expect(proposal.evaluatedExposureIds, ['latest', 'middle']);
    expect(proposal.performanceMissExposureIds, ['latest']);
    expect(
      proposal.blockers,
      contains(
        PerformanceMissResponseBlocker.notEnoughRepeatedPerformanceMisses,
      ),
    );
  });

  test('requires bounded progression to be comparable before decreasing', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: null),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
        _exposure(
          id: 'latest',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.notComparable);
    expect(proposal.hasDecreaseProposal, isFalse);
    expect(
      proposal.blockers,
      contains(PerformanceMissResponseBlocker.boundedProgressionNotComparable),
    );
    expect(
      proposal.boundedDecision.status,
      BoundedProgressionStatus.notComparable,
    );
  });

  test('ignores exposures for other exercises', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'other-latest',
          exerciseId: 'barbell_back_squat',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    );

    expect(proposal.status, PerformanceMissResponseStatus.held);
    expect(proposal.evaluatedExposureIds, isEmpty);
    expect(
      proposal.blockers,
      contains(PerformanceMissResponseBlocker.noMatchingExposureHistory),
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

PerformanceMissExposure _exposure({
  required String id,
  required DateTime performedAt,
  required PerformanceMissSignal signal,
  String exerciseId = 'barbell_bench_press',
}) {
  return PerformanceMissExposure(
    id: id,
    exerciseId: exerciseId,
    performedAt: performedAt,
    signal: signal,
  );
}
