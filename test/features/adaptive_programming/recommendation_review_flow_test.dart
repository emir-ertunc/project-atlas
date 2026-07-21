import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/pain_progression_guard.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/adaptive_programming/domain/recommendation_explanation.dart';
import 'package:project_atlas/features/adaptive_programming/domain/recommendation_review_flow.dart';
import 'package:project_atlas/features/adaptive_programming/domain/smallest_load_increase.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test(
    'accepts a load increase recommendation by copying the prescription',
    () {
      final prescription = _prescription(loadKilograms: 80);
      final state = openAdaptiveRecommendationReview(
        recommendationId: 'rec-increase',
        explanation: _increaseExplanation(
          prescription: prescription,
          policy: policy,
          now: now,
        ),
        prescription: prescription,
      );

      final accepted = acceptAdaptiveRecommendation(state);

      expect(
        accepted.ruleSetVersion,
        adaptiveRecommendationReviewRuleSetVersion,
      );
      expect(accepted.status, AdaptiveRecommendationReviewStatus.accepted);
      expect(accepted.originalPrescription.loadKilograms, 80);
      expect(accepted.currentPrescription.loadKilograms, 82.5);
      expect(accepted.hasProgramChange, isTrue);
      expect(accepted.canUndo, isTrue);
      expect(prescription.loadKilograms, 80);
    },
  );

  test('rejects a recommendation without changing the prescription copy', () {
    final prescription = _prescription(loadKilograms: 80);
    final state = openAdaptiveRecommendationReview(
      recommendationId: 'rec-reject',
      explanation: _increaseExplanation(
        prescription: prescription,
        policy: policy,
        now: now,
      ),
      prescription: prescription,
    );

    final rejected = rejectAdaptiveRecommendation(state);

    expect(rejected.status, AdaptiveRecommendationReviewStatus.rejected);
    expect(rejected.currentPrescription.loadKilograms, 80);
    expect(rejected.hasProgramChange, isFalse);
    expect(rejected.canUndo, isFalse);
  });

  test('edits a load recommendation before accepting it', () {
    final prescription = _prescription(loadKilograms: 80);
    final state = openAdaptiveRecommendationReview(
      recommendationId: 'rec-edit',
      explanation: _increaseExplanation(
        prescription: prescription,
        policy: policy,
        now: now,
      ),
      prescription: prescription,
    );

    final edited = editAdaptiveRecommendationLoad(
      state: state,
      editedLoadKilograms: 85,
    );
    final accepted = acceptAdaptiveRecommendation(edited);

    expect(edited.status, AdaptiveRecommendationReviewStatus.edited);
    expect(edited.currentPrescription.loadKilograms, 80);
    expect(edited.proposedChanges.single.previousLoadKilograms, 80);
    expect(edited.proposedChanges.single.proposedLoadKilograms, 85);
    expect(accepted.status, AdaptiveRecommendationReviewStatus.accepted);
    expect(accepted.currentPrescription.loadKilograms, 85);
  });

  test(
    'undoes an accepted load recommendation by restoring the previous load',
    () {
      final prescription = _prescription(loadKilograms: 80);
      final state = openAdaptiveRecommendationReview(
        recommendationId: 'rec-undo',
        explanation: _decreaseExplanation(
          prescription: prescription,
          policy: policy,
          now: now,
        ),
        prescription: prescription,
      );

      final accepted = acceptAdaptiveRecommendation(state);
      final undone = undoAcceptedRecommendation(accepted);

      expect(accepted.currentPrescription.loadKilograms, 77.5);
      expect(undone.status, AdaptiveRecommendationReviewStatus.undone);
      expect(undone.currentPrescription.loadKilograms, 80);
      expect(undone.hasProgramChange, isFalse);
      expect(undone.canUndo, isFalse);
    },
  );

  test('blocks review when the explanation has no changed value', () {
    final prescription = _prescription(loadKilograms: 80);
    final state = openAdaptiveRecommendationReview(
      recommendationId: 'rec-held',
      explanation: explainSmallestLoadIncreaseProposal(
        proposal: proposeSmallestAvailableLoadIncrease(
          prescription: prescription,
          policy: policy,
          exposures: [_qualifyingExposure(id: 'latest', performedAt: now)],
        ),
      ),
      prescription: prescription,
    );

    final accepted = acceptAdaptiveRecommendation(state);

    expect(state.status, AdaptiveRecommendationReviewStatus.blocked);
    expect(
      state.blockers,
      contains(AdaptiveRecommendationReviewBlocker.noChangeCandidate),
    );
    expect(accepted.status, AdaptiveRecommendationReviewStatus.blocked);
    expect(
      accepted.blockers,
      contains(AdaptiveRecommendationReviewBlocker.noChangeCandidate),
    );
  });

  test('accepts pain progression stop without load mutation or load undo', () {
    final prescription = _prescription(loadKilograms: 80);
    final state = openAdaptiveRecommendationReview(
      recommendationId: 'rec-pain',
      explanation: explainPainProgressionGuardDecision(
        decision: guardProgressionForPain(
          prescription: prescription,
          policy: policy,
          exposures: [_painExposure(id: 'latest', performedAt: now)],
        ),
      ),
      prescription: prescription,
    );

    final accepted = acceptAdaptiveRecommendation(state);
    final undoAttempt = undoAcceptedRecommendation(accepted);

    expect(accepted.status, AdaptiveRecommendationReviewStatus.accepted);
    expect(accepted.currentPrescription.loadKilograms, 80);
    expect(accepted.hasProgramChange, isFalse);
    expect(accepted.canUndo, isFalse);
    expect(undoAttempt.status, AdaptiveRecommendationReviewStatus.accepted);
    expect(
      undoAttempt.blockers,
      contains(AdaptiveRecommendationReviewBlocker.undoUnavailable),
    );
  });
}

AdaptiveRecommendationExplanation _increaseExplanation({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
  required DateTime now,
}) {
  return explainSmallestLoadIncreaseProposal(
    proposal: proposeSmallestAvailableLoadIncrease(
      prescription: prescription,
      policy: policy,
      exposures: [
        _qualifyingExposure(id: 'latest', performedAt: now),
        _qualifyingExposure(
          id: 'previous',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
      ],
    ),
  );
}

AdaptiveRecommendationExplanation _decreaseExplanation({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
  required DateTime now,
}) {
  return explainPerformanceMissResponseProposal(
    proposal: proposePerformanceMissResponse(
      prescription: prescription,
      policy: policy,
      exposures: [
        PerformanceMissExposure(
          id: 'latest',
          exerciseId: 'barbell_bench_press',
          performedAt: now,
          signal: PerformanceMissSignal.performanceMiss,
        ),
        PerformanceMissExposure(
          id: 'previous',
          exerciseId: 'barbell_bench_press',
          performedAt: now.subtract(const Duration(days: 7)),
          signal: PerformanceMissSignal.performanceMiss,
        ),
      ],
    ),
  );
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

LoadProgressionExposure _qualifyingExposure({
  required String id,
  required DateTime performedAt,
}) {
  return LoadProgressionExposure(
    id: id,
    exerciseId: 'barbell_bench_press',
    performedAt: performedAt,
    sets: [
      for (var setOrder = 1; setOrder <= 3; setOrder += 1)
        LoadProgressionSetObservation(
          setOrder: setOrder,
          repetitions: 8,
          loadKilograms: 80,
          rir: 2,
        ),
    ],
  );
}

ProgressionExposureEvidence _painExposure({
  required String id,
  required DateTime performedAt,
}) {
  return ProgressionExposureEvidence(
    id: id,
    exerciseId: 'barbell_bench_press',
    performedAt: performedAt,
    sets: [
      for (var setOrder = 1; setOrder <= 3; setOrder += 1)
        ProgressionSetEvidence(
          setOrder: setOrder,
          repetitions: 8,
          loadKilograms: 80,
          result: setOrder == 2 ? SetResult.pain : null,
        ),
    ],
  );
}
