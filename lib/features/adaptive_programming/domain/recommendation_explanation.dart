import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/pain_progression_guard.dart';
import 'package:project_atlas/features/adaptive_programming/domain/performance_miss_response.dart';
import 'package:project_atlas/features/adaptive_programming/domain/smallest_load_increase.dart';

const adaptiveRecommendationExplanationRuleSetVersion =
    'adaptive_recommendation_explanation.v1';

enum AdaptiveRecommendationExplanationStatus { explained, noChange }

enum AdaptiveRecommendationSubject {
  loadIncrease,
  loadDecrease,
  progressionStopped,
}

enum AdaptiveRecommendationChangeField {
  loadKilograms,
  loadedProgressionAllowed,
}

enum AdaptiveRecommendationReason {
  twoQualifyingExposures,
  repeatedPerformanceMisses,
  painReported,
  boundedLoadChange,
  roundedToLoadIncrement,
  increaseCappedByPercent,
  decreaseCappedByPercent,
  minimumLoadFloor,
  noProgramChangeToUndo,
}

enum AdaptiveRecommendationEvidenceKind { exerciseExposure, painExposure }

enum AdaptiveRecommendationUndoAction { restorePreviousLoad, noProgramChange }

final class AdaptiveRecommendationChange {
  const AdaptiveRecommendationChange.loadKilograms({
    required this.previousLoadKilograms,
    required this.proposedLoadKilograms,
  }) : field = AdaptiveRecommendationChangeField.loadKilograms,
       previousLoadedProgressionAllowed = null,
       proposedLoadedProgressionAllowed = null;

  const AdaptiveRecommendationChange.loadedProgressionAllowed({
    required this.previousLoadedProgressionAllowed,
    required this.proposedLoadedProgressionAllowed,
  }) : field = AdaptiveRecommendationChangeField.loadedProgressionAllowed,
       previousLoadKilograms = null,
       proposedLoadKilograms = null;

  final AdaptiveRecommendationChangeField field;
  final double? previousLoadKilograms;
  final double? proposedLoadKilograms;
  final bool? previousLoadedProgressionAllowed;
  final bool? proposedLoadedProgressionAllowed;

  bool get changesValue {
    return switch (field) {
      AdaptiveRecommendationChangeField.loadKilograms =>
        previousLoadKilograms != proposedLoadKilograms,
      AdaptiveRecommendationChangeField.loadedProgressionAllowed =>
        previousLoadedProgressionAllowed != proposedLoadedProgressionAllowed,
    };
  }
}

final class AdaptiveRecommendationEvidenceReference {
  const AdaptiveRecommendationEvidenceReference({
    required this.kind,
    required this.id,
    this.performedAt,
    this.setOrders = const [],
  });

  final AdaptiveRecommendationEvidenceKind kind;
  final String id;
  final DateTime? performedAt;
  final List<int> setOrders;
}

final class AdaptiveRecommendationUndoInstruction {
  const AdaptiveRecommendationUndoInstruction({
    required this.action,
    this.field,
    this.restoreLoadKilograms,
  });

  final AdaptiveRecommendationUndoAction action;
  final AdaptiveRecommendationChangeField? field;
  final double? restoreLoadKilograms;

  bool get canUndo =>
      action == AdaptiveRecommendationUndoAction.restorePreviousLoad &&
      restoreLoadKilograms != null;
}

final class AdaptiveRecommendationExplanation {
  const AdaptiveRecommendationExplanation({
    required this.ruleSetVersion,
    required this.status,
    required this.subject,
    required this.changes,
    required this.reasons,
    required this.triggeringEvidence,
    required this.undo,
  });

  final String ruleSetVersion;
  final AdaptiveRecommendationExplanationStatus status;
  final AdaptiveRecommendationSubject subject;
  final List<AdaptiveRecommendationChange> changes;
  final List<AdaptiveRecommendationReason> reasons;
  final List<AdaptiveRecommendationEvidenceReference> triggeringEvidence;
  final AdaptiveRecommendationUndoInstruction undo;

  bool get hasChangedValue => changes.any((change) => change.changesValue);

  bool get canUndoAfterApply => undo.canUndo;

  List<String> get triggeringEvidenceIds =>
      List.unmodifiable(triggeringEvidence.map((evidence) => evidence.id));
}

AdaptiveRecommendationExplanation explainSmallestLoadIncreaseProposal({
  required SmallestLoadIncreaseProposal proposal,
}) {
  if (!proposal.hasProposal) {
    return _noChangeExplanation(
      subject: AdaptiveRecommendationSubject.loadIncrease,
    );
  }

  return _loadChangeExplanation(
    subject: AdaptiveRecommendationSubject.loadIncrease,
    boundedDecision: proposal.boundedDecision,
    reasons: [
      AdaptiveRecommendationReason.twoQualifyingExposures,
      AdaptiveRecommendationReason.boundedLoadChange,
      ..._boundedLimitReasons(proposal.boundedDecision),
    ],
    triggeringEvidence: [
      for (final exposureId in proposal.qualifyingExposureIds)
        AdaptiveRecommendationEvidenceReference(
          kind: AdaptiveRecommendationEvidenceKind.exerciseExposure,
          id: exposureId,
        ),
    ],
  );
}

AdaptiveRecommendationExplanation explainPerformanceMissResponseProposal({
  required PerformanceMissResponseProposal proposal,
}) {
  if (!proposal.hasDecreaseProposal) {
    return _noChangeExplanation(
      subject: AdaptiveRecommendationSubject.loadDecrease,
    );
  }

  return _loadChangeExplanation(
    subject: AdaptiveRecommendationSubject.loadDecrease,
    boundedDecision: proposal.boundedDecision,
    reasons: [
      AdaptiveRecommendationReason.repeatedPerformanceMisses,
      AdaptiveRecommendationReason.boundedLoadChange,
      ..._boundedLimitReasons(proposal.boundedDecision),
    ],
    triggeringEvidence: [
      for (final exposureId in proposal.performanceMissExposureIds)
        AdaptiveRecommendationEvidenceReference(
          kind: AdaptiveRecommendationEvidenceKind.exerciseExposure,
          id: exposureId,
        ),
    ],
  );
}

AdaptiveRecommendationExplanation explainPainProgressionGuardDecision({
  required PainProgressionGuardDecision decision,
}) {
  if (!decision.blocksProgression) {
    return _noChangeExplanation(
      subject: AdaptiveRecommendationSubject.progressionStopped,
    );
  }

  return AdaptiveRecommendationExplanation(
    ruleSetVersion: adaptiveRecommendationExplanationRuleSetVersion,
    status: AdaptiveRecommendationExplanationStatus.explained,
    subject: AdaptiveRecommendationSubject.progressionStopped,
    changes: const [
      AdaptiveRecommendationChange.loadedProgressionAllowed(
        previousLoadedProgressionAllowed: true,
        proposedLoadedProgressionAllowed: false,
      ),
    ],
    reasons: const [
      AdaptiveRecommendationReason.painReported,
      AdaptiveRecommendationReason.noProgramChangeToUndo,
    ],
    triggeringEvidence: [
      for (final trigger in decision.triggers)
        AdaptiveRecommendationEvidenceReference(
          kind: AdaptiveRecommendationEvidenceKind.painExposure,
          id: trigger.exposureId,
          performedAt: trigger.performedAt,
          setOrders: List.unmodifiable(trigger.setOrders),
        ),
    ],
    undo: const AdaptiveRecommendationUndoInstruction(
      action: AdaptiveRecommendationUndoAction.noProgramChange,
      field: AdaptiveRecommendationChangeField.loadedProgressionAllowed,
    ),
  );
}

AdaptiveRecommendationExplanation _loadChangeExplanation({
  required AdaptiveRecommendationSubject subject,
  required BoundedProgressionDecision boundedDecision,
  required List<AdaptiveRecommendationReason> reasons,
  required List<AdaptiveRecommendationEvidenceReference> triggeringEvidence,
}) {
  final previousLoad = boundedDecision.previousLoadKilograms;
  final proposedLoad = boundedDecision.proposedLoadKilograms;

  if (previousLoad == null || proposedLoad == null) {
    return _noChangeExplanation(subject: subject);
  }

  return AdaptiveRecommendationExplanation(
    ruleSetVersion: adaptiveRecommendationExplanationRuleSetVersion,
    status: AdaptiveRecommendationExplanationStatus.explained,
    subject: subject,
    changes: [
      AdaptiveRecommendationChange.loadKilograms(
        previousLoadKilograms: previousLoad,
        proposedLoadKilograms: proposedLoad,
      ),
    ],
    reasons: List.unmodifiable(reasons),
    triggeringEvidence: List.unmodifiable(triggeringEvidence),
    undo: AdaptiveRecommendationUndoInstruction(
      action: AdaptiveRecommendationUndoAction.restorePreviousLoad,
      field: AdaptiveRecommendationChangeField.loadKilograms,
      restoreLoadKilograms: previousLoad,
    ),
  );
}

AdaptiveRecommendationExplanation _noChangeExplanation({
  required AdaptiveRecommendationSubject subject,
}) {
  return AdaptiveRecommendationExplanation(
    ruleSetVersion: adaptiveRecommendationExplanationRuleSetVersion,
    status: AdaptiveRecommendationExplanationStatus.noChange,
    subject: subject,
    changes: const [],
    reasons: const [],
    triggeringEvidence: const [],
    undo: const AdaptiveRecommendationUndoInstruction(
      action: AdaptiveRecommendationUndoAction.noProgramChange,
    ),
  );
}

List<AdaptiveRecommendationReason> _boundedLimitReasons(
  BoundedProgressionDecision decision,
) {
  return [
    for (final limit in decision.limits)
      switch (limit) {
        BoundedProgressionLimit.roundedToLoadIncrement =>
          AdaptiveRecommendationReason.roundedToLoadIncrement,
        BoundedProgressionLimit.increaseCappedByPercent =>
          AdaptiveRecommendationReason.increaseCappedByPercent,
        BoundedProgressionLimit.decreaseCappedByPercent =>
          AdaptiveRecommendationReason.decreaseCappedByPercent,
        BoundedProgressionLimit.minimumLoadFloor =>
          AdaptiveRecommendationReason.minimumLoadFloor,
      },
  ];
}
