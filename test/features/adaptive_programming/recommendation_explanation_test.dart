import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/pain_progression_guard.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/adaptive_programming/domain/recommendation_explanation.dart';
import 'package:project_atlas/features/adaptive_programming/domain/smallest_load_increase.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);
  final now = DateTime.utc(2026, 7, 21, 12);

  test('explains earned load increases with trigger data and undo', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _qualifyingExposure(id: 'latest', performedAt: now),
        _qualifyingExposure(
          id: 'previous',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
      ],
    );

    final explanation = explainSmallestLoadIncreaseProposal(proposal: proposal);

    expect(
      explanation.ruleSetVersion,
      adaptiveRecommendationExplanationRuleSetVersion,
    );
    expect(
      explanation.status,
      AdaptiveRecommendationExplanationStatus.explained,
    );
    expect(explanation.subject, AdaptiveRecommendationSubject.loadIncrease);
    expect(explanation.hasChangedValue, isTrue);
    expect(explanation.canUndoAfterApply, isTrue);
    expect(
      explanation.changes.single.field,
      AdaptiveRecommendationChangeField.loadKilograms,
    );
    expect(explanation.changes.single.previousLoadKilograms, 80);
    expect(explanation.changes.single.proposedLoadKilograms, 82.5);
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.twoQualifyingExposures),
    );
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.boundedLoadChange),
    );
    expect(explanation.triggeringEvidenceIds, ['latest', 'previous']);
    expect(
      explanation.triggeringEvidence.first.kind,
      AdaptiveRecommendationEvidenceKind.exerciseExposure,
    );
    expect(
      explanation.undo.action,
      AdaptiveRecommendationUndoAction.restorePreviousLoad,
    );
    expect(explanation.undo.restoreLoadKilograms, 80);
  });

  test('explains repeated miss decreases and bounded limits', () {
    final proposal = proposePerformanceMissResponse(
      prescription: _prescription(loadKilograms: 80),
      policy: const BoundedProgressionPolicy(
        loadIncrementKilograms: 2.5,
        maximumDecreasePercent: 10,
      ),
      exposures: [
        _missExposure(id: 'latest', performedAt: now),
        _missExposure(
          id: 'previous',
          performedAt: now.subtract(const Duration(days: 7)),
        ),
      ],
      requestedDecreaseKilograms: 25,
    );

    final explanation = explainPerformanceMissResponseProposal(
      proposal: proposal,
    );

    expect(
      explanation.status,
      AdaptiveRecommendationExplanationStatus.explained,
    );
    expect(explanation.subject, AdaptiveRecommendationSubject.loadDecrease);
    expect(explanation.changes.single.previousLoadKilograms, 80);
    expect(explanation.changes.single.proposedLoadKilograms, 72.5);
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.repeatedPerformanceMisses),
    );
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.decreaseCappedByPercent),
    );
    expect(explanation.triggeringEvidenceIds, ['latest', 'previous']);
    expect(explanation.undo.restoreLoadKilograms, 80);
  });

  test('explains pain safety holds without offering a load undo', () {
    final decision = guardProgressionForPain(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [
        _painExposure(
          id: 'latest',
          performedAt: now,
          painSetOrders: const [2, 3],
        ),
      ],
    );

    final explanation = explainPainProgressionGuardDecision(decision: decision);

    expect(
      explanation.status,
      AdaptiveRecommendationExplanationStatus.explained,
    );
    expect(
      explanation.subject,
      AdaptiveRecommendationSubject.progressionStopped,
    );
    expect(explanation.hasChangedValue, isTrue);
    expect(explanation.canUndoAfterApply, isFalse);
    expect(
      explanation.changes.single.field,
      AdaptiveRecommendationChangeField.loadedProgressionAllowed,
    );
    expect(explanation.changes.single.previousLoadedProgressionAllowed, isTrue);
    expect(
      explanation.changes.single.proposedLoadedProgressionAllowed,
      isFalse,
    );
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.painReported),
    );
    expect(
      explanation.reasons,
      contains(AdaptiveRecommendationReason.noProgramChangeToUndo),
    );
    expect(explanation.triggeringEvidenceIds, ['latest']);
    expect(explanation.triggeringEvidence.single.performedAt, now);
    expect(explanation.triggeringEvidence.single.setOrders, [2, 3]);
    expect(
      explanation.undo.action,
      AdaptiveRecommendationUndoAction.noProgramChange,
    );
  });

  test('returns no-change explanation for held recommendation candidates', () {
    final proposal = proposeSmallestAvailableLoadIncrease(
      prescription: _prescription(loadKilograms: 80),
      policy: policy,
      exposures: [_qualifyingExposure(id: 'latest', performedAt: now)],
    );

    final explanation = explainSmallestLoadIncreaseProposal(proposal: proposal);

    expect(
      explanation.status,
      AdaptiveRecommendationExplanationStatus.noChange,
    );
    expect(explanation.hasChangedValue, isFalse);
    expect(explanation.canUndoAfterApply, isFalse);
    expect(explanation.changes, isEmpty);
    expect(explanation.reasons, isEmpty);
    expect(explanation.triggeringEvidence, isEmpty);
    expect(
      explanation.undo.action,
      AdaptiveRecommendationUndoAction.noProgramChange,
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

PerformanceMissExposure _missExposure({
  required String id,
  required DateTime performedAt,
}) {
  return PerformanceMissExposure(
    id: id,
    exerciseId: 'barbell_bench_press',
    performedAt: performedAt,
    signal: PerformanceMissSignal.performanceMiss,
  );
}

ProgressionExposureEvidence _painExposure({
  required String id,
  required DateTime performedAt,
  required List<int> painSetOrders,
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
          result: painSetOrders.contains(setOrder) ? SetResult.pain : null,
        ),
    ],
  );
}
