import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_targets.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_visual_ranges.dart';

void main() {
  test('defines one finite visual range for every morph target definition', () {
    final definitionIds = bodyMorphTargetDefinitions
        .map((definition) => definition.id)
        .toSet();
    final rangeIds = bodyMorphVisualRanges
        .map((range) => range.targetDefinitionId)
        .toSet();

    expect(bodyMorphVisualRangeContractVersion, 'body_morph_visual_ranges.v1');
    expect(rangeIds, hasLength(bodyMorphVisualRanges.length));
    expect(rangeIds, definitionIds);

    final definitionsById = {
      for (final definition in bodyMorphTargetDefinitions)
        definition.id: definition,
    };
    for (final range in bodyMorphVisualRanges) {
      final definition = definitionsById[range.targetDefinitionId]!;

      expect(range.channel, definition.channel);
      expect(range.minimum.isFinite, isTrue);
      expect(range.neutral.isFinite, isTrue);
      expect(range.maximum.isFinite, isTrue);
      expect(range.minimum, lessThanOrEqualTo(range.neutral));
      expect(range.neutral, lessThanOrEqualTo(range.maximum));
    }
  });

  test(
    'maps normalized targets into visual ranges without exceeding bounds',
    () {
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

      final clamped = clampBodyMorphTargetsToVisualRanges(targetSet);

      expect(clamped.contractVersion, bodyMorphVisualRangeContractVersion);
      expect(clamped.sourceRuleSetVersion, bodyMorphTargetRuleSetVersion);
      expect(clamped.validation, same(targetSet.validation));
      expect(clamped.hasBlockingIssues, isFalse);
      expect(clamped.hasMissingRanges, isFalse);
      expect(clamped.targets, hasLength(targetSet.targets.length));

      for (final target in clamped.targets) {
        final source = targetSet.byDefinitionId[target.definitionId]!;

        expect(
          target.visualValue,
          inInclusiveRange(target.visualMinimum, target.visualMaximum),
        );
        expect(target.normalizedValue, source.value);
        expect(target.channel, source.channel);
        expect(target.confidence, source.confidence);
        expect(target.sourceFields, source.sourceFields);
        expect(target.affectedRegionIds, source.affectedRegionIds);
      }
    },
  );

  test('clamps malformed normalized inputs to visual minimum and maximum', () {
    final source = buildBodyMorphTargets(
      _measurement(
        heightCentimeters: 180,
        chestCircumferenceCentimeters: 100,
        waistCircumferenceCentimeters: 80,
      ),
    );
    final definitionsById = {
      for (final definition in bodyMorphTargetDefinitions)
        definition.id: definition,
    };

    final malformed = BodyMorphTargetSet(
      ruleSetVersion: source.ruleSetVersion,
      validation: source.validation,
      targets: [
        _targetFromDefinition(definitionsById['chest_girth_scale']!, value: 2),
        _targetFromDefinition(definitionsById['waist_girth_scale']!, value: -2),
      ],
    );

    final clamped = clampBodyMorphTargetsToVisualRanges(malformed);
    final chest = clamped.byDefinitionId['chest_girth_scale']!;
    final waist = clamped.byDefinitionId['waist_girth_scale']!;

    expect(chest.clampStatus, BodyMorphVisualClampStatus.clampedToMaximum);
    expect(chest.visualValue, chest.visualMaximum);
    expect(waist.clampStatus, BodyMorphVisualClampStatus.clampedToMinimum);
    expect(waist.visualValue, waist.visualMinimum);
  });

  test('preserves blocking validation and emits no clamped targets', () {
    final targetSet = buildBodyMorphTargets(_measurement());

    final clamped = clampBodyMorphTargetsToVisualRanges(targetSet);

    expect(clamped.hasBlockingIssues, isTrue);
    expect(clamped.targets, isEmpty);
    expect(clamped.missingRangeTargetIds, isEmpty);
    expect(clamped.validation, same(targetSet.validation));
  });

  test(
    'records missing visual ranges without fabricating a fallback clamp',
    () {
      final targetSet = buildBodyMorphTargets(
        _measurement(chestCircumferenceCentimeters: 110),
      );
      final rangesWithoutChest = bodyMorphVisualRanges
          .where((range) => range.targetDefinitionId != 'chest_girth_scale')
          .toList();

      final clamped = clampBodyMorphTargetsToVisualRanges(
        targetSet,
        ranges: rangesWithoutChest,
      );

      expect(clamped.targets, isEmpty);
      expect(clamped.hasMissingRanges, isTrue);
      expect(clamped.missingRangeTargetIds, ['chest_girth_scale']);
    },
  );
}

BodyMorphTarget _targetFromDefinition(
  BodyMorphTargetDefinition definition, {
  required double value,
}) {
  return BodyMorphTarget(
    definitionId: definition.id,
    channel: definition.channel,
    value: value,
    confidence: BodyMorphTargetConfidence.direct,
    sourceFields: List.unmodifiable(definition.sourceFields),
    affectedRegionIds: List.unmodifiable(definition.affectedRegionIds),
  );
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
