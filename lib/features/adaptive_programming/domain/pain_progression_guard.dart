import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/adaptive_programming/domain/progression_signal_classifier.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const painProgressionGuardRuleSetVersion = 'pain_progression_guard.v1';

enum PainProgressionGuardStatus { progressionStopped, noPainReported }

enum PainSafetyGuidance {
  stopLoadedProgression,
  keepPrescriptionUnchanged,
  avoidTrainingThroughPain,
  resumeOnlyWhenPainFree,
  seekQualifiedHelpForSharpPersistentOrWorseningPain,
}

final class PainProgressionTrigger {
  const PainProgressionTrigger({
    required this.exposureId,
    required this.performedAt,
    required this.setOrders,
  });

  final String exposureId;
  final DateTime performedAt;
  final List<int> setOrders;
}

final class PainProgressionGuardDecision {
  const PainProgressionGuardDecision({
    required this.ruleSetVersion,
    required this.status,
    required this.triggers,
    required this.guidance,
    required this.boundedDecision,
  });

  final String ruleSetVersion;
  final PainProgressionGuardStatus status;
  final List<PainProgressionTrigger> triggers;
  final List<PainSafetyGuidance> guidance;
  final BoundedProgressionDecision boundedDecision;

  bool get blocksProgression =>
      status == PainProgressionGuardStatus.progressionStopped;

  bool get hasSafetyGuidance => guidance.isNotEmpty;

  List<String> get triggeringExposureIds =>
      List.unmodifiable(triggers.map((trigger) => trigger.exposureId));
}

PainProgressionGuardDecision guardProgressionForPain({
  required ProgramExercisePrescription prescription,
  required BoundedProgressionPolicy policy,
  required List<ProgressionExposureEvidence> exposures,
}) {
  final triggers =
      exposures
          .where((exposure) => exposure.exerciseId == prescription.exerciseId)
          .map(_painTriggerFor)
          .nonNulls
          .toList(growable: false)
        ..sort((left, right) => right.performedAt.compareTo(left.performedAt));
  final holdDecision = proposeBoundedLoadProgression(
    prescription: prescription,
    direction: BoundedProgressionDirection.hold,
    policy: policy,
  );

  if (triggers.isEmpty) {
    return PainProgressionGuardDecision(
      ruleSetVersion: painProgressionGuardRuleSetVersion,
      status: PainProgressionGuardStatus.noPainReported,
      triggers: const [],
      guidance: const [],
      boundedDecision: holdDecision,
    );
  }

  return PainProgressionGuardDecision(
    ruleSetVersion: painProgressionGuardRuleSetVersion,
    status: PainProgressionGuardStatus.progressionStopped,
    triggers: List.unmodifiable(triggers),
    guidance: const [
      PainSafetyGuidance.stopLoadedProgression,
      PainSafetyGuidance.keepPrescriptionUnchanged,
      PainSafetyGuidance.avoidTrainingThroughPain,
      PainSafetyGuidance.resumeOnlyWhenPainFree,
      PainSafetyGuidance.seekQualifiedHelpForSharpPersistentOrWorseningPain,
    ],
    boundedDecision: holdDecision,
  );
}

PainProgressionTrigger? _painTriggerFor(ProgressionExposureEvidence exposure) {
  final setOrders =
      exposure.sets
          .where((set) => set.result == SetResult.pain)
          .map((set) => set.setOrder)
          .toList(growable: false)
        ..sort();

  if (setOrders.isEmpty) {
    return null;
  }

  return PainProgressionTrigger(
    exposureId: exposure.id,
    performedAt: exposure.performedAt,
    setOrders: List.unmodifiable(setOrders),
  );
}
