import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_targets.dart';

const bodyMorphVisualRangeContractVersion = 'body_morph_visual_ranges.v1';

enum BodyMorphVisualClampStatus {
  insideRange,
  clampedToMinimum,
  clampedToMaximum,
  invalidInputResetToNeutral,
}

final class BodyMorphVisualRange {
  const BodyMorphVisualRange({
    required this.targetDefinitionId,
    required this.channel,
    required this.minimum,
    required this.neutral,
    required this.maximum,
  }) : assert(minimum <= neutral),
       assert(neutral <= maximum);

  final String targetDefinitionId;
  final BodyMorphChannel channel;

  /// Mesh-safe visual multiplier for a normalized morph value of `-1`.
  final double minimum;

  /// Mesh-safe visual multiplier for a normalized morph value of `0`.
  final double neutral;

  /// Mesh-safe visual multiplier for a normalized morph value of `1`.
  final double maximum;
}

final class ClampedBodyMorphTarget {
  const ClampedBodyMorphTarget({
    required this.definitionId,
    required this.channel,
    required this.normalizedValue,
    required this.visualValue,
    required this.visualMinimum,
    required this.visualNeutral,
    required this.visualMaximum,
    required this.clampStatus,
    required this.confidence,
    required this.sourceFields,
    required this.affectedRegionIds,
  });

  final String definitionId;
  final BodyMorphChannel channel;
  final double normalizedValue;
  final double visualValue;
  final double visualMinimum;
  final double visualNeutral;
  final double visualMaximum;
  final BodyMorphVisualClampStatus clampStatus;
  final BodyMorphTargetConfidence confidence;
  final List<BodyMeasurementField> sourceFields;
  final List<String> affectedRegionIds;
}

final class ClampedBodyMorphTargetSet {
  const ClampedBodyMorphTargetSet({
    required this.contractVersion,
    required this.sourceRuleSetVersion,
    required this.validation,
    required this.targets,
    required this.missingRangeTargetIds,
  });

  final String contractVersion;
  final String sourceRuleSetVersion;
  final MeasurementValidationResult validation;
  final List<ClampedBodyMorphTarget> targets;
  final List<String> missingRangeTargetIds;

  bool get hasBlockingIssues => validation.hasBlockingIssues;
  bool get hasMissingRanges => missingRangeTargetIds.isNotEmpty;

  Map<String, ClampedBodyMorphTarget> get byDefinitionId => {
    for (final target in targets) target.definitionId: target,
  };
}

ClampedBodyMorphTargetSet clampBodyMorphTargetsToVisualRanges(
  BodyMorphTargetSet targetSet, {
  List<BodyMorphVisualRange> ranges = bodyMorphVisualRanges,
}) {
  final rangesByDefinitionId = _rangesByDefinitionId(ranges);
  final clampedTargets = <ClampedBodyMorphTarget>[];
  final missingRangeTargetIds = <String>[];

  for (final target in targetSet.targets) {
    final range = rangesByDefinitionId[target.definitionId];
    if (range == null) {
      missingRangeTargetIds.add(target.definitionId);
      continue;
    }
    if (range.channel != target.channel) {
      throw StateError(
        'Visual range ${range.targetDefinitionId} uses ${range.channel.name}, '
        'but morph target uses ${target.channel.name}.',
      );
    }

    clampedTargets.add(_clampedTarget(target: target, range: range));
  }

  return ClampedBodyMorphTargetSet(
    contractVersion: bodyMorphVisualRangeContractVersion,
    sourceRuleSetVersion: targetSet.ruleSetVersion,
    validation: targetSet.validation,
    targets: List.unmodifiable(clampedTargets),
    missingRangeTargetIds: List.unmodifiable(missingRangeTargetIds),
  );
}

const bodyMorphVisualRanges = <BodyMorphVisualRange>[
  BodyMorphVisualRange(
    targetDefinitionId: 'stature_height_scale',
    channel: BodyMorphChannel.statureScale,
    minimum: 0.94,
    neutral: 1,
    maximum: 1.06,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'mass_height_scale',
    channel: BodyMorphChannel.massScale,
    minimum: 0.96,
    neutral: 1,
    maximum: 1.04,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'torso_length_scale',
    channel: BodyMorphChannel.torsoLength,
    minimum: 0.95,
    neutral: 1,
    maximum: 1.05,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'chest_girth_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.95,
    neutral: 1,
    maximum: 1.06,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'waist_girth_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.94,
    neutral: 1,
    maximum: 1.07,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'hip_girth_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.95,
    neutral: 1,
    maximum: 1.06,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'upper_arm_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.92,
    neutral: 1,
    maximum: 1.09,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'upper_arm_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.92,
    neutral: 1,
    maximum: 1.09,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'forearm_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.93,
    neutral: 1,
    maximum: 1.08,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'forearm_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.93,
    neutral: 1,
    maximum: 1.08,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'thigh_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.94,
    neutral: 1,
    maximum: 1.07,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'thigh_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.94,
    neutral: 1,
    maximum: 1.07,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'calf_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.93,
    neutral: 1,
    maximum: 1.08,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'calf_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    minimum: 0.93,
    neutral: 1,
    maximum: 1.08,
  ),
  BodyMorphVisualRange(
    targetDefinitionId: 'body_fat_soft_tissue_estimate',
    channel: BodyMorphChannel.softTissueEstimate,
    minimum: 0.95,
    neutral: 1,
    maximum: 1.06,
  ),
];

Map<String, BodyMorphVisualRange> _rangesByDefinitionId(
  List<BodyMorphVisualRange> ranges,
) {
  final rangesByDefinitionId = <String, BodyMorphVisualRange>{};
  for (final range in ranges) {
    final previous = rangesByDefinitionId[range.targetDefinitionId];
    if (previous != null) {
      throw StateError('Duplicate visual range: ${range.targetDefinitionId}');
    }
    rangesByDefinitionId[range.targetDefinitionId] = range;
  }
  return rangesByDefinitionId;
}

ClampedBodyMorphTarget _clampedTarget({
  required BodyMorphTarget target,
  required BodyMorphVisualRange range,
}) {
  final rawVisualValue = _rawVisualValue(
    normalizedValue: target.value,
    range: range,
  );
  final visualValue = rawVisualValue.clamp(range.minimum, range.maximum);

  return ClampedBodyMorphTarget(
    definitionId: target.definitionId,
    channel: target.channel,
    normalizedValue: target.value,
    visualValue: visualValue.toDouble(),
    visualMinimum: range.minimum,
    visualNeutral: range.neutral,
    visualMaximum: range.maximum,
    clampStatus: _clampStatus(
      normalizedValue: target.value,
      rawVisualValue: rawVisualValue,
      range: range,
    ),
    confidence: target.confidence,
    sourceFields: List.unmodifiable(target.sourceFields),
    affectedRegionIds: List.unmodifiable(target.affectedRegionIds),
  );
}

double _rawVisualValue({
  required double normalizedValue,
  required BodyMorphVisualRange range,
}) {
  if (!normalizedValue.isFinite) {
    return range.neutral;
  }

  if (normalizedValue >= 0) {
    return range.neutral + normalizedValue * (range.maximum - range.neutral);
  }

  return range.neutral + normalizedValue * (range.neutral - range.minimum);
}

BodyMorphVisualClampStatus _clampStatus({
  required double normalizedValue,
  required double rawVisualValue,
  required BodyMorphVisualRange range,
}) {
  if (!normalizedValue.isFinite) {
    return BodyMorphVisualClampStatus.invalidInputResetToNeutral;
  }
  if (rawVisualValue < range.minimum) {
    return BodyMorphVisualClampStatus.clampedToMinimum;
  }
  if (rawVisualValue > range.maximum) {
    return BodyMorphVisualClampStatus.clampedToMaximum;
  }
  return BodyMorphVisualClampStatus.insideRange;
}
