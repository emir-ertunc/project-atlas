import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_targets.dart';
import 'package:project_atlas/features/anatomy/domain/body_morph_visual_ranges.dart';
import 'package:project_atlas/features/anatomy/domain/body_visual_estimate_label.dart';

void main() {
  test('labels clamped morph output as a visual estimate only', () {
    final targetSet = buildBodyMorphTargets(
      _measurement(
        heightCentimeters: 180,
        weightKilograms: 82.5,
        chestCircumferenceCentimeters: 110,
      ),
    );
    final clamped = clampBodyMorphTargetsToVisualRanges(targetSet);

    final labeled = labelBodyVisualEstimate(clamped);

    expect(labeled.contractVersion, 'body_visual_estimate_label.v1');
    expect(labeled.sourceVisualRangeContractVersion, clamped.contractVersion);
    expect(labeled.targetSet, same(clamped));
    expect(labeled.kind, BodyVisualEstimateKind.measurementBasedVisualEstimate);
    expect(labeled.isMedicalScan, isFalse);
    expect(labeled.supportsDiagnosis, isFalse);
  });

  test('provides English and Turkish non-diagnostic disclosure copy', () {
    const disclosure = bodyVisualEstimateDisclosure;

    expect(disclosure.title.en, 'Visual estimate, not a medical scan');
    expect(disclosure.title.tr, 'Görsel tahmin, tıbbi tarama değil');
    expect(disclosure.summary.en, contains('approximate visual model'));
    expect(disclosure.summary.tr, contains('Yaklaşık bir görsel modeldir'));
    expect(disclosure.isMedicalScan, isFalse);
    expect(disclosure.supportsDiagnosis, isFalse);

    final guardrails = {
      for (final guardrail in disclosure.guardrails) guardrail.guardrail,
    };
    expect(guardrails, BodyVisualEstimateGuardrail.values.toSet());
    for (final guardrail in disclosure.guardrails) {
      expect(guardrail.text.en.trim(), isNotEmpty);
      expect(guardrail.text.tr.trim(), isNotEmpty);
    }
  });

  test(
    'preserves blocking and missing-range status from the clamped target set',
    () {
      final blockingTargetSet = buildBodyMorphTargets(_measurement());
      final blockingClamped = clampBodyMorphTargetsToVisualRanges(
        blockingTargetSet,
      );

      final labeledBlocking = labelBodyVisualEstimate(blockingClamped);

      expect(labeledBlocking.hasBlockingIssues, isTrue);
      expect(labeledBlocking.hasMissingRanges, isFalse);

      final targetSet = buildBodyMorphTargets(
        _measurement(chestCircumferenceCentimeters: 110),
      );
      final clampedWithMissingRange = clampBodyMorphTargetsToVisualRanges(
        targetSet,
        ranges: bodyMorphVisualRanges
            .where((range) => range.targetDefinitionId != 'chest_girth_scale')
            .toList(),
      );

      final labeledMissingRange = labelBodyVisualEstimate(
        clampedWithMissingRange,
      );

      expect(labeledMissingRange.hasBlockingIssues, isFalse);
      expect(labeledMissingRange.hasMissingRanges, isTrue);
      expect(labeledMissingRange.targetSet.missingRangeTargetIds, [
        'chest_girth_scale',
      ]);
    },
  );
}

MeasurementRecord _measurement({
  double? heightCentimeters,
  double? weightKilograms,
  double? chestCircumferenceCentimeters,
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
    chestCircumferenceCentimeters: chestCircumferenceCentimeters,
    bodyMeasurementMethod: BodyMeasurementMethod.tapeMeasure,
  );
}
