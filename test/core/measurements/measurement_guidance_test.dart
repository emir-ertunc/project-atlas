import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

void main() {
  test('defines guidance for every stored measurement field', () {
    expect(measurementGuidanceVersion, 'measurement_guidance.v1');
    expect(
      bodyMeasurementGuides,
      hasLength(BodyMeasurementField.values.length),
    );
    expect(
      bodyMeasurementGuides.map((guide) => guide.field).toSet(),
      BodyMeasurementField.values.toSet(),
    );
    expect(
      bodyMeasurementGuides.map((guide) => guide.storageName).toSet(),
      hasLength(bodyMeasurementGuides.length),
    );

    for (final guide in bodyMeasurementGuides) {
      expect(guide.title.en, isNotEmpty);
      expect(guide.title.tr, isNotEmpty);
      expect(guide.referencePoint.en, isNotEmpty);
      expect(guide.referencePoint.tr, isNotEmpty);
      expect(guide.instruction.en, isNotEmpty);
      expect(guide.instruction.tr, isNotEmpty);
      expect(
        guide.referenceRange.minimum,
        lessThan(guide.referenceRange.maximum),
      );
    }
  });

  test('maps record values by measurement field', () {
    final record = _measurement(
      heightCentimeters: 180,
      weightKilograms: 82,
      bodyFatPercentage: 16,
    );

    expect(
      measurementValueFor(record, BodyMeasurementField.heightCentimeters),
      180,
    );
    expect(
      measurementValueFor(record, BodyMeasurementField.weightKilograms),
      82,
    );
    expect(
      measurementValueFor(record, BodyMeasurementField.bodyFatPercentage),
      16,
    );
  });

  test('returns blocking issues for empty or impossible values', () {
    final empty = validateMeasurementRecord(_measurement());
    expect(empty.hasBlockingIssues, isTrue);
    expect(
      empty.blockingIssues.map((issue) => issue.code),
      contains(MeasurementValidationCode.noMeasuredValues),
    );

    final invalid = validateMeasurementRecord(
      _measurement(
        weightKilograms: double.nan,
        heightCentimeters: 0,
        bodyFatPercentage: 100,
      ),
    );
    expect(invalid.hasBlockingIssues, isTrue);
    expect(
      invalid.blockingIssues.map((issue) => issue.code),
      containsAll(<MeasurementValidationCode>{
        MeasurementValidationCode.nonFiniteValue,
        MeasurementValidationCode.nonPositiveValue,
        MeasurementValidationCode.percentageOutOfRange,
      }),
    );
  });

  test(
    'returns warnings for missing methods, range checks, and side mismatch',
    () {
      final result = validateMeasurementRecord(
        _measurement(
          heightCentimeters: 95,
          weightKilograms: 82,
          leftUpperArmCircumferenceCentimeters: 30,
          rightUpperArmCircumferenceCentimeters: 40,
          bodyFatPercentage: 16,
        ),
      );

      expect(result.hasBlockingIssues, isFalse);
      expect(
        result.warnings.map((issue) => issue.code),
        containsAll(<MeasurementValidationCode>{
          MeasurementValidationCode.belowReferenceRange,
          MeasurementValidationCode.missingBodyMeasurementMethod,
          MeasurementValidationCode.missingBodyFatMethod,
          MeasurementValidationCode.sideToSideDifference,
        }),
      );
    },
  );

  test('does not warn for complete same-method baseline measurements', () {
    final result = validateMeasurementRecord(
      _measurement(
        heightCentimeters: 180,
        weightKilograms: 82,
        leftThighCircumferenceCentimeters: 58,
        rightThighCircumferenceCentimeters: 59,
        bodyFatPercentage: 16,
        bodyMeasurementMethod: BodyMeasurementMethod.tapeMeasure,
        bodyFatMeasurementMethod: BodyFatMeasurementMethod.caliper,
      ),
    );

    expect(result.issues, isEmpty);
  });
}

MeasurementRecord _measurement({
  double? heightCentimeters,
  double? weightKilograms,
  double? leftUpperArmCircumferenceCentimeters,
  double? rightUpperArmCircumferenceCentimeters,
  double? leftThighCircumferenceCentimeters,
  double? rightThighCircumferenceCentimeters,
  double? bodyFatPercentage,
  BodyMeasurementMethod? bodyMeasurementMethod,
  BodyFatMeasurementMethod? bodyFatMeasurementMethod,
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
    leftUpperArmCircumferenceCentimeters: leftUpperArmCircumferenceCentimeters,
    rightUpperArmCircumferenceCentimeters:
        rightUpperArmCircumferenceCentimeters,
    leftThighCircumferenceCentimeters: leftThighCircumferenceCentimeters,
    rightThighCircumferenceCentimeters: rightThighCircumferenceCentimeters,
    bodyFatPercentage: bodyFatPercentage,
    bodyMeasurementMethod: bodyMeasurementMethod,
    bodyFatMeasurementMethod: bodyFatMeasurementMethod,
  );
}
