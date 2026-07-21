import 'package:project_atlas/features/anatomy/domain/body_morph_visual_ranges.dart';

const bodyVisualEstimateLabelContractVersion = 'body_visual_estimate_label.v1';

enum BodyVisualEstimateKind { measurementBasedVisualEstimate }

enum BodyVisualEstimateGuardrail {
  notMedicalScan,
  notDiagnostic,
  measurementBased,
  trainingSeparate,
}

final class LocalizedDisclosureText {
  const LocalizedDisclosureText({required this.en, required this.tr});

  final String en;
  final String tr;
}

final class BodyVisualEstimateGuardrailText {
  const BodyVisualEstimateGuardrailText({
    required this.guardrail,
    required this.text,
  });

  final BodyVisualEstimateGuardrail guardrail;
  final LocalizedDisclosureText text;
}

final class BodyVisualEstimateDisclosure {
  const BodyVisualEstimateDisclosure({
    required this.kind,
    required this.title,
    required this.summary,
    required this.guardrails,
  });

  final BodyVisualEstimateKind kind;
  final LocalizedDisclosureText title;
  final LocalizedDisclosureText summary;
  final List<BodyVisualEstimateGuardrailText> guardrails;

  bool get isMedicalScan => false;
  bool get supportsDiagnosis => false;
}

final class LabeledBodyVisualEstimate {
  const LabeledBodyVisualEstimate({
    required this.contractVersion,
    required this.sourceVisualRangeContractVersion,
    required this.disclosure,
    required this.targetSet,
  });

  final String contractVersion;
  final String sourceVisualRangeContractVersion;
  final BodyVisualEstimateDisclosure disclosure;
  final ClampedBodyMorphTargetSet targetSet;

  BodyVisualEstimateKind get kind => disclosure.kind;
  bool get hasBlockingIssues => targetSet.hasBlockingIssues;
  bool get hasMissingRanges => targetSet.hasMissingRanges;
  bool get isMedicalScan => disclosure.isMedicalScan;
  bool get supportsDiagnosis => disclosure.supportsDiagnosis;
}

LabeledBodyVisualEstimate labelBodyVisualEstimate(
  ClampedBodyMorphTargetSet targetSet, {
  BodyVisualEstimateDisclosure disclosure = bodyVisualEstimateDisclosure,
}) {
  return LabeledBodyVisualEstimate(
    contractVersion: bodyVisualEstimateLabelContractVersion,
    sourceVisualRangeContractVersion: targetSet.contractVersion,
    disclosure: disclosure,
    targetSet: targetSet,
  );
}

const bodyVisualEstimateDisclosure = BodyVisualEstimateDisclosure(
  kind: BodyVisualEstimateKind.measurementBasedVisualEstimate,
  title: LocalizedDisclosureText(
    en: 'Visual estimate, not a medical scan',
    tr: 'Görsel tahmin, tıbbi tarama değil',
  ),
  summary: LocalizedDisclosureText(
    en:
        'This anatomy view is built from saved measurements and training data. '
        'It is an approximate visual model, not a diagnostic image or medical '
        'assessment.',
    tr:
        'Bu anatomi görünümü kayıtlı ölçümler ve antrenman verilerinden '
        'oluşturulur. Yaklaşık bir görsel modeldir; tanısal görüntü veya '
        'tıbbi değerlendirme değildir.',
  ),
  guardrails: [
    BodyVisualEstimateGuardrailText(
      guardrail: BodyVisualEstimateGuardrail.notMedicalScan,
      text: LocalizedDisclosureText(
        en: 'It must not be presented as a body scan, imaging result, or exam.',
        tr:
            'Vücut taraması, görüntüleme sonucu veya muayene gibi '
            'sunulmamalıdır.',
      ),
    ),
    BodyVisualEstimateGuardrailText(
      guardrail: BodyVisualEstimateGuardrail.notDiagnostic,
      text: LocalizedDisclosureText(
        en: 'It cannot diagnose health, injury, disease, or body composition.',
        tr:
            'Sağlık, sakatlık, hastalık veya vücut kompozisyonu tanısı '
            'koyamaz.',
      ),
    ),
    BodyVisualEstimateGuardrailText(
      guardrail: BodyVisualEstimateGuardrail.measurementBased,
      text: LocalizedDisclosureText(
        en: 'If the model looks wrong, review the saved measurement inputs.',
        tr:
            'Model hatalı görünüyorsa kayıtlı ölçüm girişlerini tekrar '
            'kontrol et.',
      ),
    ),
    BodyVisualEstimateGuardrailText(
      guardrail: BodyVisualEstimateGuardrail.trainingSeparate,
      text: LocalizedDisclosureText(
        en: 'Training recommendations remain driven by workout evidence.',
        tr: 'Antrenman önerileri antrenman kanıtlarına göre yönetilmeye devam eder.',
      ),
    ),
  ],
);
