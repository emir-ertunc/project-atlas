import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_targets.dart';

void main() {
  test('defines morph targets against stable anatomy region identifiers', () {
    final ontologyRegionIds = _ontologyRegionIds();

    expect(bodyMorphTargetRuleSetVersion, 'body_morph_targets.v1');
    expect(
      bodyMorphTargetDefinitions.map((definition) => definition.id).toSet(),
      hasLength(bodyMorphTargetDefinitions.length),
    );
    for (final definition in bodyMorphTargetDefinitions) {
      expect(definition.sourceFields, isNotEmpty);
      expect(definition.affectedRegionIds, isNotEmpty);
      expect(
        definition.affectedRegionIds.toSet(),
        hasLength(definition.affectedRegionIds.length),
      );
      expect(
        definition.affectedRegionIds,
        everyElement(isIn(ontologyRegionIds)),
      );
      expect(definition.fullScaleDelta, greaterThan(0));
    }
  });

  test('builds bounded regional morph targets from a complete measurement', () {
    final targetSet = buildBodyMorphTargets(
      _measurement(
        heightCentimeters: 180,
        weightKilograms: 82.5,
        torsoLengthCentimeters: 61,
        chestCircumferenceCentimeters: 110,
        waistCircumferenceCentimeters: 86,
        hipCircumferenceCentimeters: 102,
        leftUpperArmCircumferenceCentimeters: 36,
        rightUpperArmCircumferenceCentimeters: 37,
        leftForearmCircumferenceCentimeters: 29,
        rightForearmCircumferenceCentimeters: 30,
        leftThighCircumferenceCentimeters: 61,
        rightThighCircumferenceCentimeters: 62,
        leftCalfCircumferenceCentimeters: 39,
        rightCalfCircumferenceCentimeters: 40,
        bodyFatPercentage: 16,
      ),
    );

    expect(targetSet.hasBlockingIssues, isFalse);
    expect(targetSet.targets, hasLength(bodyMorphTargetDefinitions.length));
    expect(
      targetSet.targets.map((target) => target.value),
      everyElement(inInclusiveRange(-1, 1)),
    );

    final targets = targetSet.byDefinitionId;
    expect(
      targets['chest_girth_scale']?.affectedRegionIds,
      containsAll(<String>['pectoralis_major_right', 'pectoralis_major_left']),
    );
    expect(
      targets['mass_height_scale']?.confidence,
      BodyMorphTargetConfidence.composite,
    );
    expect(
      targets['body_fat_soft_tissue_estimate']?.channel,
      BodyMorphChannel.softTissueEstimate,
    );
  });

  test('keeps left and right limb morph targets side-specific', () {
    final targetSet = buildBodyMorphTargets(
      _measurement(
        heightCentimeters: 180,
        leftUpperArmCircumferenceCentimeters: 60,
        rightUpperArmCircumferenceCentimeters: 20,
      ),
    );
    final left = targetSet.byDefinitionId['upper_arm_girth_left_scale']!;
    final right = targetSet.byDefinitionId['upper_arm_girth_right_scale']!;

    expect(left.value, 1);
    expect(right.value, lessThan(0));
    expect(left.affectedRegionIds, everyElement(endsWith('_left')));
    expect(right.affectedRegionIds, everyElement(endsWith('_right')));
    expect(left.affectedRegionIds, contains('biceps_brachii_left'));
    expect(right.affectedRegionIds, contains('triceps_brachii_right'));
  });

  test('uses broad-range fallback when height is missing', () {
    final targetSet = buildBodyMorphTargets(
      _measurement(chestCircumferenceCentimeters: 110),
    );
    final chest = targetSet.byDefinitionId['chest_girth_scale']!;

    expect(chest.confidence, BodyMorphTargetConfidence.broadRangeFallback);
    expect(chest.sourceFields, [
      BodyMeasurementField.chestCircumferenceCentimeters,
    ]);
    expect(chest.value, inInclusiveRange(-1, 1));
    expect(targetSet.byDefinitionId, isNot(contains('mass_height_scale')));
  });

  test('returns no targets when measurement validation blocks the event', () {
    final targetSet = buildBodyMorphTargets(_measurement());

    expect(targetSet.hasBlockingIssues, isTrue);
    expect(targetSet.targets, isEmpty);
    expect(
      targetSet.validation.blockingIssues.map((issue) => issue.code),
      contains(MeasurementValidationCode.noMeasuredValues),
    );
  });

  test('bounds extreme but valid measurements before renderer mapping', () {
    final targetSet = buildBodyMorphTargets(
      _measurement(
        heightCentimeters: 230,
        weightKilograms: 250,
        bodyFatPercentage: 99,
      ),
    );

    expect(targetSet.byDefinitionId['stature_height_scale']?.value, 1);
    expect(targetSet.byDefinitionId['mass_height_scale']?.value, 1);
    expect(targetSet.byDefinitionId['body_fat_soft_tissue_estimate']?.value, 1);
  });
}

MeasurementRecord _measurement({
  double? heightCentimeters,
  double? weightKilograms,
  double? torsoLengthCentimeters,
  double? chestCircumferenceCentimeters,
  double? waistCircumferenceCentimeters,
  double? hipCircumferenceCentimeters,
  double? leftUpperArmCircumferenceCentimeters,
  double? rightUpperArmCircumferenceCentimeters,
  double? leftForearmCircumferenceCentimeters,
  double? rightForearmCircumferenceCentimeters,
  double? leftThighCircumferenceCentimeters,
  double? rightThighCircumferenceCentimeters,
  double? leftCalfCircumferenceCentimeters,
  double? rightCalfCircumferenceCentimeters,
  double? bodyFatPercentage,
}) {
  final now = DateTime.utc(2026, 7, 21, 12);
  return MeasurementRecord(
    id: 'measurement',
    profileId: 'profile',
    measuredAt: now,
    origin: MeasurementOrigin.manual,
    createdAt: now,
    heightCentimeters: heightCentimeters,
    weightKilograms: weightKilograms,
    torsoLengthCentimeters: torsoLengthCentimeters,
    chestCircumferenceCentimeters: chestCircumferenceCentimeters,
    waistCircumferenceCentimeters: waistCircumferenceCentimeters,
    hipCircumferenceCentimeters: hipCircumferenceCentimeters,
    leftUpperArmCircumferenceCentimeters: leftUpperArmCircumferenceCentimeters,
    rightUpperArmCircumferenceCentimeters:
        rightUpperArmCircumferenceCentimeters,
    leftForearmCircumferenceCentimeters: leftForearmCircumferenceCentimeters,
    rightForearmCircumferenceCentimeters: rightForearmCircumferenceCentimeters,
    leftThighCircumferenceCentimeters: leftThighCircumferenceCentimeters,
    rightThighCircumferenceCentimeters: rightThighCircumferenceCentimeters,
    leftCalfCircumferenceCentimeters: leftCalfCircumferenceCentimeters,
    rightCalfCircumferenceCentimeters: rightCalfCircumferenceCentimeters,
    bodyFatPercentage: bodyFatPercentage,
    bodyMeasurementMethod: BodyMeasurementMethod.tapeMeasure,
    bodyFatMeasurementMethod: BodyFatMeasurementMethod.caliper,
  );
}

Set<String> _ontologyRegionIds() {
  final file = File('tool/anatomy/muscle_region_ontology.v1.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final groups = json['groups'] as List<Object?>;
  final regionIds = <String>{};
  for (final group in groups) {
    final groupMap = group as Map<String, Object?>;
    final regions = groupMap['regions'] as Map<String, Object?>;
    for (final region in regions.values) {
      final regionMap = region as Map<String, Object?>;
      regionIds.add(regionMap['id']! as String);
    }
  }
  return regionIds;
}
