import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_targets.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_visual_ranges.dart';

void main() {
  group('body morph boundary and visual regression coverage', () {
    test('keeps minimum and maximum measurement boundaries renderer-safe', () {
      final boundaryMeasurements = [
        _measurement(
          id: 'minimum-boundary',
          heightCentimeters: 100,
          weightKilograms: 30,
          torsoLengthCentimeters: 35,
          chestCircumferenceCentimeters: 60,
          waistCircumferenceCentimeters: 50,
          hipCircumferenceCentimeters: 60,
          leftUpperArmCircumferenceCentimeters: 15,
          rightUpperArmCircumferenceCentimeters: 15,
          leftForearmCircumferenceCentimeters: 15,
          rightForearmCircumferenceCentimeters: 15,
          leftThighCircumferenceCentimeters: 35,
          rightThighCircumferenceCentimeters: 35,
          leftCalfCircumferenceCentimeters: 25,
          rightCalfCircumferenceCentimeters: 25,
          bodyFatPercentage: 3,
        ),
        _measurement(
          id: 'maximum-boundary',
          heightCentimeters: 230,
          weightKilograms: 250,
          torsoLengthCentimeters: 90,
          chestCircumferenceCentimeters: 170,
          waistCircumferenceCentimeters: 180,
          hipCircumferenceCentimeters: 180,
          leftUpperArmCircumferenceCentimeters: 60,
          rightUpperArmCircumferenceCentimeters: 60,
          leftForearmCircumferenceCentimeters: 45,
          rightForearmCircumferenceCentimeters: 45,
          leftThighCircumferenceCentimeters: 90,
          rightThighCircumferenceCentimeters: 90,
          leftCalfCircumferenceCentimeters: 60,
          rightCalfCircumferenceCentimeters: 60,
          bodyFatPercentage: 60,
        ),
      ];

      for (final measurement in boundaryMeasurements) {
        final targetSet = buildBodyMorphTargets(measurement);
        final clamped = clampBodyMorphTargetsToVisualRanges(targetSet);

        expect(targetSet.hasBlockingIssues, isFalse, reason: measurement.id);
        expect(
          targetSet.targets,
          hasLength(bodyMorphTargetDefinitions.length),
          reason: measurement.id,
        );
        expect(clamped.hasMissingRanges, isFalse, reason: measurement.id);
        expect(clamped.targets, hasLength(targetSet.targets.length));

        for (final target in targetSet.targets) {
          expect(target.value.isFinite, isTrue, reason: target.definitionId);
          expect(
            target.value,
            inInclusiveRange(-1, 1),
            reason: target.definitionId,
          );
        }

        for (final target in clamped.targets) {
          expect(target.visualValue.isFinite, isTrue);
          expect(
            target.visualValue,
            inInclusiveRange(target.visualMinimum, target.visualMaximum),
            reason: target.definitionId,
          );
          expect(
            target.clampStatus,
            BodyMorphVisualClampStatus.insideRange,
            reason: target.definitionId,
          );
        }
      }
    });

    test(
      'uses broad-range fallback for every ratio target when height is absent',
      () {
        final targetSet = buildBodyMorphTargets(
          _measurement(
            id: 'fallback-boundary',
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

        final ratioDefinitions = bodyMorphTargetDefinitions.where(
          (definition) =>
              definition.computation ==
              BodyMorphComputation.measurementToHeightRatio,
        );

        expect(targetSet.hasBlockingIssues, isFalse);
        expect(
          targetSet.byDefinitionId,
          isNot(contains('stature_height_scale')),
        );
        expect(targetSet.byDefinitionId, isNot(contains('mass_height_scale')));

        for (final definition in ratioDefinitions) {
          final target = targetSet.byDefinitionId[definition.id];

          expect(target, isNotNull, reason: definition.id);
          expect(
            target!.confidence,
            BodyMorphTargetConfidence.broadRangeFallback,
            reason: definition.id,
          );
          expect(target.sourceFields, [definition.sourceFields.first]);
          expect(target.value, inInclusiveRange(-1, 1));
        }
      },
    );

    test(
      'keeps visual ranges monotonic and resets invalid inputs to neutral',
      () {
        for (final range in bodyMorphVisualRanges) {
          final visualValues = <double>[];
          for (final normalizedValue in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
            final clamped = clampBodyMorphTargetsToVisualRanges(
              _syntheticTargetSet(range, normalizedValue),
            );
            final target = clamped.targets.single;

            visualValues.add(target.visualValue);
            expect(
              target.visualValue,
              inInclusiveRange(range.minimum, range.maximum),
              reason: range.targetDefinitionId,
            );
            expect(
              target.clampStatus,
              BodyMorphVisualClampStatus.insideRange,
              reason: range.targetDefinitionId,
            );
          }

          expect(visualValues[0], closeTo(range.minimum, 0.000001));
          expect(visualValues[2], closeTo(range.neutral, 0.000001));
          expect(visualValues[4], closeTo(range.maximum, 0.000001));
          for (var index = 1; index < visualValues.length; index += 1) {
            expect(
              visualValues[index],
              greaterThanOrEqualTo(visualValues[index - 1]),
              reason: range.targetDefinitionId,
            );
          }

          final invalid = clampBodyMorphTargetsToVisualRanges(
            _syntheticTargetSet(range, double.nan),
          ).targets.single;
          expect(
            invalid.clampStatus,
            BodyMorphVisualClampStatus.invalidInputResetToNeutral,
          );
          expect(invalid.visualValue, range.neutral);
        }
      },
    );

    test('matches the representative clamped morph visual snapshot', () {
      final targetSet = buildBodyMorphTargets(
        _measurement(
          id: 'representative-snapshot',
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

      expect(_visualSnapshot(clamped), [
        'stature_height_scale|statureScale|n=0.2500|v=1.0150|insideRange|direct',
        'mass_height_scale|massScale|n=0.2052|v=1.0082|insideRange|composite',
        'torso_length_scale|torsoLength|n=0.2361|v=1.0118|insideRange|heightNormalized',
        'chest_girth_scale|circumference|n=0.3819|v=1.0229|insideRange|heightNormalized',
        'waist_girth_scale|circumference|n=0.1736|v=1.0122|insideRange|heightNormalized',
        'hip_girth_scale|circumference|n=0.1190|v=1.0071|insideRange|heightNormalized',
        'upper_arm_girth_left_scale|circumference|n=0.2500|v=1.0225|insideRange|heightNormalized',
        'upper_arm_girth_right_scale|circumference|n=0.3194|v=1.0288|insideRange|heightNormalized',
        'forearm_girth_left_scale|circumference|n=0.1852|v=1.0148|insideRange|heightNormalized',
        'forearm_girth_right_scale|circumference|n=0.2778|v=1.0222|insideRange|heightNormalized',
        'thigh_girth_left_scale|circumference|n=0.1889|v=1.0132|insideRange|heightNormalized',
        'thigh_girth_right_scale|circumference|n=0.2444|v=1.0171|insideRange|heightNormalized',
        'calf_girth_left_scale|circumference|n=0.2083|v=1.0167|insideRange|heightNormalized',
        'calf_girth_right_scale|circumference|n=0.2778|v=1.0222|insideRange|heightNormalized',
        'body_fat_soft_tissue_estimate|softTissueEstimate|n=-0.0800|v=0.9960|insideRange|direct',
      ]);
    });
  });
}

BodyMorphTargetSet _syntheticTargetSet(
  BodyMorphVisualRange range,
  double normalizedValue,
) {
  return BodyMorphTargetSet(
    ruleSetVersion: bodyMorphTargetRuleSetVersion,
    validation: const MeasurementValidationResult([]),
    targets: [
      BodyMorphTarget(
        definitionId: range.targetDefinitionId,
        channel: range.channel,
        value: normalizedValue,
        confidence: BodyMorphTargetConfidence.direct,
        sourceFields: const [],
        affectedRegionIds: const [],
      ),
    ],
  );
}

List<String> _visualSnapshot(ClampedBodyMorphTargetSet targetSet) {
  return [
    for (final target in targetSet.targets)
      [
        target.definitionId,
        target.channel.name,
        'n=${target.normalizedValue.toStringAsFixed(4)}',
        'v=${target.visualValue.toStringAsFixed(4)}',
        target.clampStatus.name,
        target.confidence.name,
      ].join('|'),
  ];
}

MeasurementRecord _measurement({
  required String id,
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
    id: id,
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
