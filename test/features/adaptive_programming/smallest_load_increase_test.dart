import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/smallest_load_increase.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test('proposes the smallest available load increase after two exposures', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
        _exposure(id: 'latest', performedAt: now),
      ],
    );

    expect(proposal.ruleSetVersion, smallestLoadIncreaseRuleSetVersion);
    expect(proposal.status, SmallestLoadIncreaseStatus.proposed);
    expect(proposal.hasProposal, isTrue);
    expect(proposal.requiresUserConfirmation, isTrue);
    expect(proposal.requiredQualifyingExposureCount, 2);
    expect(proposal.qualifyingExposureIds, ['latest', 'older']);
    expect(proposal.evaluatedExposureIds, ['latest', 'older']);
    expect(proposal.blockers, isEmpty);
    expect(proposal.boundedDecision.requestedChangeKilograms, 2.5);
    expect(proposal.boundedDecision.proposedLoadKilograms, 82.5);
  });

  test('does not propose when only one qualifying exposure exists', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [_exposure(id: 'latest', performedAt: now)],
    );

    expect(
      proposal.status,
      SmallestLoadIncreaseStatus.insufficientQualifyingExposures,
    );
    expect(proposal.hasProposal, isFalse);
    expect(proposal.qualifyingExposureIds, ['latest']);
    expect(
      proposal.blockers,
      contains(SmallestLoadIncreaseBlocker.notEnoughQualifyingExposures),
    );
  });

  test('does not skip a recent non-qualifying exposure to find older wins', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older-1',
          performedAt: now.subtract(const Duration(days: 14)),
        ),
        _exposure(
          id: 'older-2',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
        _exposure(id: 'latest', performedAt: now, repetitions: 7),
      ],
    );

    expect(
      proposal.status,
      SmallestLoadIncreaseStatus.insufficientQualifyingExposures,
    );
    expect(proposal.qualifyingExposureIds, isEmpty);
    expect(proposal.evaluatedExposureIds, ['latest']);
    expect(
      proposal.blockers,
      contains(SmallestLoadIncreaseBlocker.latestExposureNotQualifying),
    );
    expect(
      proposal.blockers,
      contains(SmallestLoadIncreaseBlocker.repetitionsBelowUpperTarget),
    );
  });

  test('requires current prescription load before proposing an increase', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: null),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
        _exposure(id: 'latest', performedAt: now),
      ],
    );

    expect(proposal.status, SmallestLoadIncreaseStatus.notComparable);
    expect(proposal.hasProposal, isFalse);
    expect(
      proposal.blockers,
      contains(SmallestLoadIncreaseBlocker.missingCurrentLoad),
    );
    expect(
      proposal.boundedDecision.status,
      BoundedProgressionStatus.notComparable,
    );
  });

  test(
    'requires clean sets at the current load and upper repetition target',
    () {
      final proposal = proposeSmallestAvailableLoadIncrease(
        prescription: _prescription(loadKilograms: 80),
        policy: policy,
        exposures: [
          _exposure(
            id: 'latest',
            performedAt: now,
            loadKilograms: 77.5,
            result: SetResult.strengthLimitation,
          ),
          _exposure(
            id: 'older',
            performedAt: now.subtract(const Duration(days: 7)),
          ),
        ],
      );

      expect(
        proposal.status,
        SmallestLoadIncreaseStatus.insufficientQualifyingExposures,
      );
      expect(
        proposal.blockers,
        contains(SmallestLoadIncreaseBlocker.loadBelowPrescription),
      );
      expect(
        proposal.blockers,
        contains(SmallestLoadIncreaseBlocker.limitingOutcome),
      );
    },
  );

  test('allows missing RIR only when the prescription has no RIR target', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80, targetRir: null),
      policy: policy,
      exposures: [
        _exposure(
          id: 'older',
          performedAt: now.subtract(const Duration(days: 7)),
          rir: null,
        ),
        _exposure(id: 'latest', performedAt: now, rir: null),
      ],
    );

    expect(proposal.status, SmallestLoadIncreaseStatus.proposed);
    expect(proposal.boundedDecision.proposedLoadKilograms, 82.5);
  });
}

ProgramExercisePrescription _prescription({
  required double? loadKilograms,
  int? targetRir = 2,
}) {
  return ProgramExercisePrescription(
    exerciseId: 'barbell_bench_press',
    setCount: 3,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: targetRir,
    loadKilograms: loadKilograms,
    restSeconds: 120,
  );
}

LoadProgressionExposure _exposure({
  required String id,
  required DateTime performedAt,
  int repetitions = 8,
  double loadKilograms = 80,
  int? rir = 2,
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
