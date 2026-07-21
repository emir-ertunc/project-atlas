import 'package:project_atlas/features/adaptive_programming/domain/recommendation_explanation.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const adaptiveRecommendationReviewRuleSetVersion =
    'adaptive_recommendation_review.v1';

enum AdaptiveRecommendationReviewStatus {
  pending,
  accepted,
  rejected,
  edited,
  undone,
  blocked,
}

enum AdaptiveRecommendationReviewBlocker {
  noChangeCandidate,
  finalizedRecommendation,
  missingLoadChange,
  invalidEditedLoad,
  undoRequiresAcceptedRecommendation,
  undoUnavailable,
}

final class AdaptiveRecommendationReviewState {
  const AdaptiveRecommendationReviewState({
    required this.ruleSetVersion,
    required this.recommendationId,
    required this.explanation,
    required this.originalPrescription,
    required this.currentPrescription,
    required this.proposedChanges,
    required this.status,
    required this.blockers,
  });

  final String ruleSetVersion;
  final String recommendationId;
  final AdaptiveRecommendationExplanation explanation;
  final ProgramExercisePrescription originalPrescription;
  final ProgramExercisePrescription currentPrescription;
  final List<AdaptiveRecommendationChange> proposedChanges;
  final AdaptiveRecommendationReviewStatus status;
  final List<AdaptiveRecommendationReviewBlocker> blockers;

  bool get hasProgramChange =>
      currentPrescription.loadKilograms != originalPrescription.loadKilograms;

  bool get canAccept =>
      blockers.isEmpty &&
      (status == AdaptiveRecommendationReviewStatus.pending ||
          status == AdaptiveRecommendationReviewStatus.edited);

  bool get canReject => canAccept;

  bool get canEdit =>
      canAccept &&
      proposedChanges.any(
        (change) =>
            change.field == AdaptiveRecommendationChangeField.loadKilograms,
      );

  bool get canUndo =>
      status == AdaptiveRecommendationReviewStatus.accepted &&
      explanation.canUndoAfterApply;

  bool get isTerminal =>
      status == AdaptiveRecommendationReviewStatus.accepted ||
      status == AdaptiveRecommendationReviewStatus.rejected ||
      status == AdaptiveRecommendationReviewStatus.undone ||
      status == AdaptiveRecommendationReviewStatus.blocked;

  AdaptiveRecommendationReviewState copyWith({
    ProgramExercisePrescription? currentPrescription,
    List<AdaptiveRecommendationChange>? proposedChanges,
    AdaptiveRecommendationReviewStatus? status,
    List<AdaptiveRecommendationReviewBlocker>? blockers,
  }) {
    return AdaptiveRecommendationReviewState(
      ruleSetVersion: ruleSetVersion,
      recommendationId: recommendationId,
      explanation: explanation,
      originalPrescription: originalPrescription,
      currentPrescription: currentPrescription ?? this.currentPrescription,
      proposedChanges: List.unmodifiable(
        proposedChanges ?? this.proposedChanges,
      ),
      status: status ?? this.status,
      blockers: List.unmodifiable(blockers ?? this.blockers),
    );
  }
}

AdaptiveRecommendationReviewState openAdaptiveRecommendationReview({
  required String recommendationId,
  required AdaptiveRecommendationExplanation explanation,
  required ProgramExercisePrescription prescription,
}) {
  if (!explanation.hasChangedValue) {
    return AdaptiveRecommendationReviewState(
      ruleSetVersion: adaptiveRecommendationReviewRuleSetVersion,
      recommendationId: recommendationId,
      explanation: explanation,
      originalPrescription: prescription,
      currentPrescription: prescription,
      proposedChanges: const [],
      status: AdaptiveRecommendationReviewStatus.blocked,
      blockers: const [AdaptiveRecommendationReviewBlocker.noChangeCandidate],
    );
  }

  return AdaptiveRecommendationReviewState(
    ruleSetVersion: adaptiveRecommendationReviewRuleSetVersion,
    recommendationId: recommendationId,
    explanation: explanation,
    originalPrescription: prescription,
    currentPrescription: prescription,
    proposedChanges: List.unmodifiable(explanation.changes),
    status: AdaptiveRecommendationReviewStatus.pending,
    blockers: const [],
  );
}

AdaptiveRecommendationReviewState acceptAdaptiveRecommendation(
  AdaptiveRecommendationReviewState state,
) {
  final blocker = _activeStateBlocker(state);
  if (blocker != null) {
    return state.copyWith(blockers: [blocker]);
  }

  return state.copyWith(
    currentPrescription: _applyChanges(
      prescription: state.originalPrescription,
      changes: state.proposedChanges,
    ),
    status: AdaptiveRecommendationReviewStatus.accepted,
    blockers: const [],
  );
}

AdaptiveRecommendationReviewState rejectAdaptiveRecommendation(
  AdaptiveRecommendationReviewState state,
) {
  final blocker = _activeStateBlocker(state);
  if (blocker != null) {
    return state.copyWith(blockers: [blocker]);
  }

  return state.copyWith(
    currentPrescription: state.originalPrescription,
    status: AdaptiveRecommendationReviewStatus.rejected,
    blockers: const [],
  );
}

AdaptiveRecommendationReviewState editAdaptiveRecommendationLoad({
  required AdaptiveRecommendationReviewState state,
  required double editedLoadKilograms,
}) {
  final blocker = _activeStateBlocker(state);
  if (blocker != null) {
    return state.copyWith(blockers: [blocker]);
  }

  if (!editedLoadKilograms.isFinite || editedLoadKilograms < 0) {
    return state.copyWith(
      blockers: const [AdaptiveRecommendationReviewBlocker.invalidEditedLoad],
    );
  }

  final loadChange = _loadChangeFrom(state.proposedChanges);
  if (loadChange == null || loadChange.previousLoadKilograms == null) {
    return state.copyWith(
      blockers: const [AdaptiveRecommendationReviewBlocker.missingLoadChange],
    );
  }

  final editedChanges = [
    for (final change in state.proposedChanges)
      if (change.field == AdaptiveRecommendationChangeField.loadKilograms)
        AdaptiveRecommendationChange.loadKilograms(
          previousLoadKilograms: loadChange.previousLoadKilograms!,
          proposedLoadKilograms: editedLoadKilograms,
        )
      else
        change,
  ];

  return state.copyWith(
    proposedChanges: editedChanges,
    status: AdaptiveRecommendationReviewStatus.edited,
    blockers: const [],
  );
}

AdaptiveRecommendationReviewState undoAcceptedRecommendation(
  AdaptiveRecommendationReviewState state,
) {
  if (state.status != AdaptiveRecommendationReviewStatus.accepted) {
    return state.copyWith(
      blockers: const [
        AdaptiveRecommendationReviewBlocker.undoRequiresAcceptedRecommendation,
      ],
    );
  }

  if (!state.explanation.canUndoAfterApply) {
    return state.copyWith(
      blockers: const [AdaptiveRecommendationReviewBlocker.undoUnavailable],
    );
  }

  final restoreLoad = state.explanation.undo.restoreLoadKilograms;
  if (restoreLoad == null) {
    return state.copyWith(
      blockers: const [AdaptiveRecommendationReviewBlocker.undoUnavailable],
    );
  }

  return state.copyWith(
    currentPrescription: state.currentPrescription.copyWith(
      loadKilograms: restoreLoad,
    ),
    status: AdaptiveRecommendationReviewStatus.undone,
    blockers: const [],
  );
}

AdaptiveRecommendationReviewBlocker? _activeStateBlocker(
  AdaptiveRecommendationReviewState state,
) {
  if (state.status == AdaptiveRecommendationReviewStatus.blocked ||
      state.blockers.contains(
        AdaptiveRecommendationReviewBlocker.noChangeCandidate,
      )) {
    return AdaptiveRecommendationReviewBlocker.noChangeCandidate;
  }
  if (state.status != AdaptiveRecommendationReviewStatus.pending &&
      state.status != AdaptiveRecommendationReviewStatus.edited) {
    return AdaptiveRecommendationReviewBlocker.finalizedRecommendation;
  }
  return null;
}

ProgramExercisePrescription _applyChanges({
  required ProgramExercisePrescription prescription,
  required List<AdaptiveRecommendationChange> changes,
}) {
  var next = prescription;
  for (final change in changes) {
    switch (change.field) {
      case AdaptiveRecommendationChangeField.loadKilograms:
        final proposedLoad = change.proposedLoadKilograms;
        if (proposedLoad != null) {
          next = next.copyWith(loadKilograms: proposedLoad);
        }
      case AdaptiveRecommendationChangeField.loadedProgressionAllowed:
        break;
    }
  }
  return next;
}

AdaptiveRecommendationChange? _loadChangeFrom(
  List<AdaptiveRecommendationChange> changes,
) {
  for (final change in changes) {
    if (change.field == AdaptiveRecommendationChangeField.loadKilograms) {
      return change;
    }
  }
  return null;
}
