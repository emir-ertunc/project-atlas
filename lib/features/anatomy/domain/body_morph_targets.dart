import 'dart:math' as math;

import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

const bodyMorphTargetRuleSetVersion = 'body_morph_targets.v1';

enum BodyMorphChannel {
  statureScale,
  massScale,
  torsoLength,
  circumference,
  softTissueEstimate,
}

enum BodyMorphComputation {
  directValue,
  measurementToHeightRatio,
  massHeightRatio,
}

enum BodyMorphTargetConfidence {
  direct,
  heightNormalized,
  broadRangeFallback,
  composite,
}

final class BodyMorphTargetDefinition {
  const BodyMorphTargetDefinition({
    required this.id,
    required this.channel,
    required this.computation,
    required this.sourceFields,
    required this.affectedRegionIds,
    required this.neutralValue,
    required this.fullScaleDelta,
  });

  final String id;
  final BodyMorphChannel channel;
  final BodyMorphComputation computation;
  final List<BodyMeasurementField> sourceFields;
  final List<String> affectedRegionIds;
  final double neutralValue;
  final double fullScaleDelta;
}

final class BodyMorphTarget {
  const BodyMorphTarget({
    required this.definitionId,
    required this.channel,
    required this.value,
    required this.confidence,
    required this.sourceFields,
    required this.affectedRegionIds,
  });

  final String definitionId;
  final BodyMorphChannel channel;

  /// Normalized pre-renderer morph signal.
  ///
  /// `-1` means the available measurement is at or beyond the low-side rule
  /// bound, `0` is neutral, and `1` means the measurement is at or beyond the
  /// high-side rule bound. The visual range contract maps this neutral signal
  /// into mesh-specific ranges before renderer consumption.
  final double value;
  final BodyMorphTargetConfidence confidence;
  final List<BodyMeasurementField> sourceFields;
  final List<String> affectedRegionIds;
}

final class BodyMorphTargetSet {
  const BodyMorphTargetSet({
    required this.ruleSetVersion,
    required this.validation,
    required this.targets,
  });

  final String ruleSetVersion;
  final MeasurementValidationResult validation;
  final List<BodyMorphTarget> targets;

  bool get hasBlockingIssues => validation.hasBlockingIssues;

  Map<String, BodyMorphTarget> get byDefinitionId => {
    for (final target in targets) target.definitionId: target,
  };
}

BodyMorphTargetSet buildBodyMorphTargets(MeasurementRecord measurement) {
  final validation = validateMeasurementRecord(measurement);
  if (validation.hasBlockingIssues) {
    return BodyMorphTargetSet(
      ruleSetVersion: bodyMorphTargetRuleSetVersion,
      validation: validation,
      targets: const [],
    );
  }

  final targets = <BodyMorphTarget>[];
  for (final definition in bodyMorphTargetDefinitions) {
    final target = _targetFromDefinition(definition, measurement);
    if (target != null) {
      targets.add(target);
    }
  }

  return BodyMorphTargetSet(
    ruleSetVersion: bodyMorphTargetRuleSetVersion,
    validation: validation,
    targets: List.unmodifiable(targets),
  );
}

final bodyMorphTargetDefinitions = <BodyMorphTargetDefinition>[
  BodyMorphTargetDefinition(
    id: 'stature_height_scale',
    channel: BodyMorphChannel.statureScale,
    computation: BodyMorphComputation.directValue,
    sourceFields: const [BodyMeasurementField.heightCentimeters],
    affectedRegionIds: _regionsForGroups(_allMorphGroups),
    neutralValue: 170,
    fullScaleDelta: 40,
  ),
  BodyMorphTargetDefinition(
    id: 'mass_height_scale',
    channel: BodyMorphChannel.massScale,
    computation: BodyMorphComputation.massHeightRatio,
    sourceFields: const [
      BodyMeasurementField.weightKilograms,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForGroups(_allMorphGroups),
    neutralValue: 23,
    fullScaleDelta: 12,
  ),
  BodyMorphTargetDefinition(
    id: 'torso_length_scale',
    channel: BodyMorphChannel.torsoLength,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.torsoLengthCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForGroups(_torsoMorphGroups),
    neutralValue: 0.32,
    fullScaleDelta: 0.08,
  ),
  BodyMorphTargetDefinition(
    id: 'chest_girth_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.chestCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForGroups(_chestMorphGroups),
    neutralValue: 0.55,
    fullScaleDelta: 0.16,
  ),
  BodyMorphTargetDefinition(
    id: 'waist_girth_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.waistCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForGroups(_waistMorphGroups),
    neutralValue: 0.45,
    fullScaleDelta: 0.16,
  ),
  BodyMorphTargetDefinition(
    id: 'hip_girth_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.hipCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForGroups(_hipMorphGroups),
    neutralValue: 0.55,
    fullScaleDelta: 0.14,
  ),
  BodyMorphTargetDefinition(
    id: 'upper_arm_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.leftUpperArmCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_upperArmMorphGroups, 'left'),
    neutralValue: 0.18,
    fullScaleDelta: 0.08,
  ),
  BodyMorphTargetDefinition(
    id: 'upper_arm_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.rightUpperArmCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_upperArmMorphGroups, 'right'),
    neutralValue: 0.18,
    fullScaleDelta: 0.08,
  ),
  BodyMorphTargetDefinition(
    id: 'forearm_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.leftForearmCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_forearmMorphGroups, 'left'),
    neutralValue: 0.15,
    fullScaleDelta: 0.06,
  ),
  BodyMorphTargetDefinition(
    id: 'forearm_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.rightForearmCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_forearmMorphGroups, 'right'),
    neutralValue: 0.15,
    fullScaleDelta: 0.06,
  ),
  BodyMorphTargetDefinition(
    id: 'thigh_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.leftThighCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_thighMorphGroups, 'left'),
    neutralValue: 0.32,
    fullScaleDelta: 0.10,
  ),
  BodyMorphTargetDefinition(
    id: 'thigh_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.rightThighCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_thighMorphGroups, 'right'),
    neutralValue: 0.32,
    fullScaleDelta: 0.10,
  ),
  BodyMorphTargetDefinition(
    id: 'calf_girth_left_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.leftCalfCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_calfMorphGroups, 'left'),
    neutralValue: 0.20,
    fullScaleDelta: 0.08,
  ),
  BodyMorphTargetDefinition(
    id: 'calf_girth_right_scale',
    channel: BodyMorphChannel.circumference,
    computation: BodyMorphComputation.measurementToHeightRatio,
    sourceFields: const [
      BodyMeasurementField.rightCalfCircumferenceCentimeters,
      BodyMeasurementField.heightCentimeters,
    ],
    affectedRegionIds: _regionsForSideGroups(_calfMorphGroups, 'right'),
    neutralValue: 0.20,
    fullScaleDelta: 0.08,
  ),
  BodyMorphTargetDefinition(
    id: 'body_fat_soft_tissue_estimate',
    channel: BodyMorphChannel.softTissueEstimate,
    computation: BodyMorphComputation.directValue,
    sourceFields: const [BodyMeasurementField.bodyFatPercentage],
    affectedRegionIds: _regionsForGroups(_softTissueMorphGroups),
    neutralValue: 18,
    fullScaleDelta: 25,
  ),
];

BodyMorphTarget? _targetFromDefinition(
  BodyMorphTargetDefinition definition,
  MeasurementRecord measurement,
) {
  final signal = switch (definition.computation) {
    BodyMorphComputation.directValue => _directSignal(definition, measurement),
    BodyMorphComputation.measurementToHeightRatio => _ratioSignal(
      definition,
      measurement,
    ),
    BodyMorphComputation.massHeightRatio => _massHeightSignal(
      definition,
      measurement,
    ),
  };
  if (signal == null) {
    return null;
  }

  return BodyMorphTarget(
    definitionId: definition.id,
    channel: definition.channel,
    value: _clampMorphSignal(signal.value),
    confidence: signal.confidence,
    sourceFields: List.unmodifiable(signal.sourceFields),
    affectedRegionIds: definition.affectedRegionIds,
  );
}

_MorphSignal? _directSignal(
  BodyMorphTargetDefinition definition,
  MeasurementRecord measurement,
) {
  final sourceField = definition.sourceFields.single;
  final value = measurementValueFor(measurement, sourceField);
  if (value == null || !value.isFinite) {
    return null;
  }
  return _MorphSignal(
    value: _normalize(
      value: value,
      neutralValue: definition.neutralValue,
      fullScaleDelta: definition.fullScaleDelta,
    ),
    confidence: BodyMorphTargetConfidence.direct,
    sourceFields: [sourceField],
  );
}

_MorphSignal? _ratioSignal(
  BodyMorphTargetDefinition definition,
  MeasurementRecord measurement,
) {
  final sourceField = definition.sourceFields.first;
  final value = measurementValueFor(measurement, sourceField);
  if (value == null || !value.isFinite) {
    return null;
  }

  final height = measurement.heightCentimeters;
  if (height != null && height.isFinite && height > 0) {
    return _MorphSignal(
      value: _normalize(
        value: value / height,
        neutralValue: definition.neutralValue,
        fullScaleDelta: definition.fullScaleDelta,
      ),
      confidence: BodyMorphTargetConfidence.heightNormalized,
      sourceFields: definition.sourceFields,
    );
  }

  final guide = guideForMeasurementField(sourceField);
  final fallbackNeutral =
      (guide.referenceRange.minimum + guide.referenceRange.maximum) / 2;
  final fallbackDelta =
      (guide.referenceRange.maximum - guide.referenceRange.minimum) / 2;
  return _MorphSignal(
    value: _normalize(
      value: value,
      neutralValue: fallbackNeutral,
      fullScaleDelta: fallbackDelta,
    ),
    confidence: BodyMorphTargetConfidence.broadRangeFallback,
    sourceFields: [sourceField],
  );
}

_MorphSignal? _massHeightSignal(
  BodyMorphTargetDefinition definition,
  MeasurementRecord measurement,
) {
  final weight = measurement.weightKilograms;
  final height = measurement.heightCentimeters;
  if (weight == null ||
      height == null ||
      !weight.isFinite ||
      !height.isFinite ||
      weight <= 0 ||
      height <= 0) {
    return null;
  }

  final heightMeters = height / 100;
  final massHeightRatio = weight / math.pow(heightMeters, 2);
  return _MorphSignal(
    value: _normalize(
      value: massHeightRatio,
      neutralValue: definition.neutralValue,
      fullScaleDelta: definition.fullScaleDelta,
    ),
    confidence: BodyMorphTargetConfidence.composite,
    sourceFields: definition.sourceFields,
  );
}

double _normalize({
  required double value,
  required double neutralValue,
  required double fullScaleDelta,
}) {
  if (!value.isFinite ||
      !neutralValue.isFinite ||
      !fullScaleDelta.isFinite ||
      fullScaleDelta <= 0) {
    return 0;
  }
  return (value - neutralValue) / fullScaleDelta;
}

double _clampMorphSignal(double value) => value.clamp(-1, 1).toDouble();

List<String> _regionsForGroups(List<String> groupIds) {
  final regionIds = <String>{};
  for (final groupId in groupIds) {
    regionIds.add('${groupId}_right');
    regionIds.add('${groupId}_left');
  }
  return List.unmodifiable(regionIds);
}

List<String> _regionsForSideGroups(List<String> groupIds, String side) {
  final regionIds = <String>{};
  for (final groupId in groupIds) {
    regionIds.add('${groupId}_$side');
  }
  return List.unmodifiable(regionIds);
}

final class _MorphSignal {
  const _MorphSignal({
    required this.value,
    required this.confidence,
    required this.sourceFields,
  });

  final double value;
  final BodyMorphTargetConfidence confidence;
  final List<BodyMeasurementField> sourceFields;
}

const _chestMorphGroups = <String>[
  'pectoralis_major',
  'pectoralis_minor',
  'serratus_anterior',
  'deltoid_anterior',
];

const _waistMorphGroups = <String>['external_oblique', 'erector_spinae'];

const _torsoMorphGroups = <String>[
  'trapezius',
  'erector_spinae',
  'external_oblique',
  'serratus_anterior',
];

const _hipMorphGroups = <String>[
  'gluteus_maximus',
  'gluteus_medius_minimus',
  'hip_adductors',
  'iliopsoas',
  'hip_external_rotators_deep',
];

const _upperArmMorphGroups = <String>[
  'biceps_brachii',
  'brachialis',
  'triceps_brachii',
];

const _forearmMorphGroups = <String>[
  'forearm_flexors_pronators',
  'forearm_extensors_supinators',
];

const _thighMorphGroups = <String>['quadriceps', 'hamstrings', 'hip_adductors'];

const _calfMorphGroups = <String>[
  'gastrocnemius',
  'soleus',
  'tibialis_anterior',
  'fibularis',
];

const _softTissueMorphGroups = <String>[
  ..._chestMorphGroups,
  ..._waistMorphGroups,
  ..._hipMorphGroups,
  ..._upperArmMorphGroups,
  ..._forearmMorphGroups,
  ..._thighMorphGroups,
  ..._calfMorphGroups,
];

const _allMorphGroups = <String>[
  ..._softTissueMorphGroups,
  'deltoid_lateral',
  'deltoid_posterior',
  'rhomboids',
  'rotator_cuff',
  'teres_major',
];
