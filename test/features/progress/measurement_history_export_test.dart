import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/progress/domain/measurement_history_export.dart';

void main() {
  group('buildMeasurementHistoryReadModel', () {
    test('sorts records and compares first usable value with latest', () {
      final now = DateTime.utc(2026, 7, 20, 10);
      final history = buildMeasurementHistoryReadModel(
        generatedAt: now,
        measurements: [
          _measurement(
            id: 'new',
            measuredAt: now,
            weightKilograms: 79,
            waistCircumferenceCentimeters: 82,
          ),
          _measurement(
            id: 'old',
            measuredAt: now.subtract(const Duration(days: 30)),
            weightKilograms: 81,
            waistCircumferenceCentimeters: 86,
          ),
        ],
      );

      expect(history.schemaVersion, measurementHistoryExportSchemaVersion);
      expect(history.records.map((record) => record.id), ['old', 'new']);

      final weight = history.comparisonFor(
        BodyMeasurementField.weightKilograms,
      );
      expect(weight, isNotNull);
      expect(weight!.baselineRecordId, 'old');
      expect(weight.latestRecordId, 'new');
      expect(weight.baselineValue, 81);
      expect(weight.latestValue, 79);
      expect(weight.delta, -2);
      expect(weight.direction, MeasurementHistoryDirection.decreased);

      final waist = history.comparisonFor(
        BodyMeasurementField.waistCircumferenceCentimeters,
      );
      expect(waist, isNotNull);
      expect(waist!.deltaPercent, closeTo(-4.65, 0.01));
    });

    test('uses latest complete left and right pair for side comparison', () {
      final now = DateTime.utc(2026, 7, 20, 10);
      final history = buildMeasurementHistoryReadModel(
        generatedAt: now,
        measurements: [
          _measurement(
            id: 'old',
            measuredAt: now.subtract(const Duration(days: 30)),
            leftUpperArmCircumferenceCentimeters: 32,
            rightUpperArmCircumferenceCentimeters: 33,
          ),
          _measurement(
            id: 'latest-incomplete',
            measuredAt: now,
            leftUpperArmCircumferenceCentimeters: 34,
          ),
        ],
      );

      final upperArm = history.sideComparisonFor('upper_arm');

      expect(upperArm, isNotNull);
      expect(upperArm!.recordId, 'old');
      expect(upperArm.leftValue, 32);
      expect(upperArm.rightValue, 33);
      expect(upperArm.delta, 1);
      expect(upperArm.absoluteDeltaPercent, closeTo(3.08, 0.01));
    });

    test('exports deterministic CSV and JSON without profile identifiers', () {
      final now = DateTime.utc(2026, 7, 20, 10);
      final history = buildMeasurementHistoryReadModel(
        generatedAt: now,
        measurements: [
          _measurement(
            id: 'record-1',
            profileId: 'private-profile-id',
            measuredAt: now,
            weightKilograms: 79.25,
            bodyFatPercentage: 17.5,
            notes: 'same scale, "morning"',
          ),
        ],
      );

      final csv = history.toCsv();
      expect(csv, contains('"schema_version","record_id","measured_at"'));
      expect(csv, contains('"measurement_history_export.v1","record-1"'));
      expect(csv, contains('"79.25"'));
      expect(csv, contains('"same scale, ""morning"""'));
      expect(csv, isNot(contains('private-profile-id')));

      final json = jsonDecode(history.toJson()) as Map<String, Object?>;
      expect(json['schema_version'], measurementHistoryExportSchemaVersion);
      expect(json['record_count'], 1);
      expect(json.toString(), isNot(contains('private-profile-id')));
      expect(
        (json['records']! as List<Object?>).single,
        containsPair('weight_kilograms', 79.25),
      );
    });
  });
}

MeasurementRecord _measurement({
  required String id,
  required DateTime measuredAt,
  String profileId = 'profile-1',
  double? weightKilograms,
  double? waistCircumferenceCentimeters,
  double? leftUpperArmCircumferenceCentimeters,
  double? rightUpperArmCircumferenceCentimeters,
  double? bodyFatPercentage,
  String? notes,
}) {
  return MeasurementRecord(
    id: id,
    profileId: profileId,
    measuredAt: measuredAt,
    origin: MeasurementOrigin.manual,
    weightKilograms: weightKilograms,
    waistCircumferenceCentimeters: waistCircumferenceCentimeters,
    leftUpperArmCircumferenceCentimeters: leftUpperArmCircumferenceCentimeters,
    rightUpperArmCircumferenceCentimeters:
        rightUpperArmCircumferenceCentimeters,
    bodyFatPercentage: bodyFatPercentage,
    bodyMeasurementMethod: BodyMeasurementMethod.tapeMeasure,
    bodyFatMeasurementMethod: bodyFatPercentage == null
        ? null
        : BodyFatMeasurementMethod.navyTape,
    notes: notes,
    createdAt: measuredAt,
  );
}
