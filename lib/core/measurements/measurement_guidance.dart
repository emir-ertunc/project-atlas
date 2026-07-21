import 'package:project_atlas/core/repositories/repository_records.dart';

const measurementGuidanceVersion = 'measurement_guidance.v1';

enum BodyMeasurementField {
  heightCentimeters,
  weightKilograms,
  torsoLengthCentimeters,
  chestCircumferenceCentimeters,
  waistCircumferenceCentimeters,
  hipCircumferenceCentimeters,
  leftUpperArmCircumferenceCentimeters,
  rightUpperArmCircumferenceCentimeters,
  leftForearmCircumferenceCentimeters,
  rightForearmCircumferenceCentimeters,
  leftThighCircumferenceCentimeters,
  rightThighCircumferenceCentimeters,
  leftCalfCircumferenceCentimeters,
  rightCalfCircumferenceCentimeters,
  bodyFatPercentage,
}

enum BodyMeasurementGroup { stature, mass, torso, circumference, composition }

enum MeasurementValueKind { lengthCentimeters, massKilograms, percentage }

enum MeasurementSide { none, left, right }

enum MeasurementValidationSeverity { warning, error }

enum MeasurementValidationCode {
  noMeasuredValues,
  nonFiniteValue,
  nonPositiveValue,
  percentageOutOfRange,
  belowReferenceRange,
  aboveReferenceRange,
  missingBodyMeasurementMethod,
  missingBodyFatMethod,
  sideToSideDifference,
}

final class LocalizedMeasurementText {
  const LocalizedMeasurementText({required this.en, required this.tr});

  final String en;
  final String tr;
}

final class MeasurementReferenceRange {
  const MeasurementReferenceRange({
    required this.minimum,
    required this.maximum,
  }) : assert(minimum < maximum, 'Minimum must be lower than maximum.');

  final double minimum;
  final double maximum;

  bool contains(double value) => value >= minimum && value <= maximum;
}

final class MeasurementGuide {
  const MeasurementGuide({
    required this.field,
    required this.storageName,
    required this.title,
    required this.group,
    required this.valueKind,
    required this.side,
    required this.referencePoint,
    required this.instruction,
    required this.referenceRange,
    this.pairKey,
  });

  final BodyMeasurementField field;
  final String storageName;
  final LocalizedMeasurementText title;
  final BodyMeasurementGroup group;
  final MeasurementValueKind valueKind;
  final MeasurementSide side;
  final LocalizedMeasurementText referencePoint;
  final LocalizedMeasurementText instruction;
  final MeasurementReferenceRange referenceRange;
  final String? pairKey;
}

final class MeasurementValidationPolicy {
  const MeasurementValidationPolicy({
    this.requireAtLeastOneMeasuredValue = true,
    this.warnWhenBodyMeasurementMethodMissing = true,
    this.warnWhenBodyFatMethodMissing = true,
    this.sideDifferenceWarningPercent = 20,
  });

  final bool requireAtLeastOneMeasuredValue;
  final bool warnWhenBodyMeasurementMethodMissing;
  final bool warnWhenBodyFatMethodMissing;
  final double sideDifferenceWarningPercent;
}

final class MeasurementValidationIssue {
  const MeasurementValidationIssue({
    required this.severity,
    required this.code,
    this.field,
    this.relatedField,
    this.value,
  });

  final MeasurementValidationSeverity severity;
  final MeasurementValidationCode code;
  final BodyMeasurementField? field;
  final BodyMeasurementField? relatedField;
  final double? value;

  bool get isBlocking => severity == MeasurementValidationSeverity.error;
}

final class MeasurementValidationResult {
  const MeasurementValidationResult(this.issues);

  final List<MeasurementValidationIssue> issues;

  bool get hasBlockingIssues => issues.any((issue) => issue.isBlocking);

  List<MeasurementValidationIssue> get blockingIssues =>
      List.unmodifiable(issues.where((issue) => issue.isBlocking));

  List<MeasurementValidationIssue> get warnings =>
      List.unmodifiable(issues.where((issue) => !issue.isBlocking));
}

final class MeasurementValidationException implements Exception {
  const MeasurementValidationException(this.result);

  final MeasurementValidationResult result;

  @override
  String toString() {
    final codes = result.blockingIssues
        .map((issue) => issue.code.name)
        .join(', ');
    return 'Measurement validation failed: $codes';
  }
}

const bodyMeasurementGuides = <MeasurementGuide>[
  MeasurementGuide(
    field: BodyMeasurementField.heightCentimeters,
    storageName: 'height_centimeters',
    title: LocalizedMeasurementText(en: 'Height', tr: 'Boy'),
    group: BodyMeasurementGroup.stature,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Floor to the crown of the head while standing tall.',
      tr: 'Dik dururken zemin ile başın en üst noktası arası.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Measure barefoot, heels against a flat surface, eyes forward.',
      tr: 'Çıplak ayakla, topuklar düz yüzeye yakın ve gözler karşıya bakarken ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 100, maximum: 230),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.weightKilograms,
    storageName: 'weight_kilograms',
    title: LocalizedMeasurementText(en: 'Weight', tr: 'Kilo'),
    group: BodyMeasurementGroup.mass,
    valueKind: MeasurementValueKind.massKilograms,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Scale reading under repeatable conditions.',
      tr: 'Tekrarlanabilir koşullarda tartı değeri.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Use the same scale, similar time of day, and similar clothing.',
      tr: 'Aynı tartıyı, benzer gün saatini ve benzer kıyafeti kullan.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 30, maximum: 250),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.torsoLengthCentimeters,
    storageName: 'torso_length_centimeters',
    title: LocalizedMeasurementText(en: 'Torso length', tr: 'Gövde uzunluğu'),
    group: BodyMeasurementGroup.torso,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Base of neck to the top of the hip line along the front of the torso.',
      tr: 'Boyun tabanından kalça çizgisinin üstüne, gövdenin ön hattı boyunca.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand relaxed and keep the tape vertical without compressing tissue.',
      tr: 'Rahat dur, mezurayı dik tut ve dokuyu sıkıştırma.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 35, maximum: 90),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.chestCircumferenceCentimeters,
    storageName: 'chest_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Chest', tr: 'Göğüs'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Around the chest at nipple line or the widest consistent point.',
      tr: 'Meme ucu hizası veya tutarlı en geniş göğüs noktası çevresi.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Keep the tape level, arms relaxed, and record after a normal exhale.',
      tr: 'Mezurayı yatay tut, kolları rahat bırak ve normal nefes verdikten sonra kaydet.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 60, maximum: 170),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.waistCircumferenceCentimeters,
    storageName: 'waist_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Waist', tr: 'Bel'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Around the natural waist, usually between the lower ribs and hip bones.',
      tr: 'Alt kaburgalar ile kalça kemikleri arasındaki doğal bel çevresi.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Measure level around the body without pulling the tape tight.',
      tr: 'Mezurayı vücut çevresinde yatay tut ve fazla sıkmadan ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 50, maximum: 180),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.hipCircumferenceCentimeters,
    storageName: 'hip_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Hips', tr: 'Kalça'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'Around the widest repeatable point of the hips and glutes.',
      tr: 'Kalça ve glute bölgesinin tutarlı en geniş noktası çevresi.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand with feet close together and keep the tape parallel to the floor.',
      tr: 'Ayakları birbirine yakın tut ve mezurayı zemine paralel kullan.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 60, maximum: 180),
  ),
  MeasurementGuide(
    field: BodyMeasurementField.leftUpperArmCircumferenceCentimeters,
    storageName: 'left_upper_arm_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Left upper arm', tr: 'Sol üst kol'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.left,
    referencePoint: LocalizedMeasurementText(
      en: 'Midpoint between shoulder tip and elbow on the left arm.',
      tr: 'Sol kolda omuz ucu ile dirsek arasındaki orta nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Keep the arm relaxed at the side and measure the same midpoint each time.',
      tr: 'Kolu yanda rahat bırak ve her seferinde aynı orta noktayı ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 15, maximum: 60),
    pairKey: 'upper_arm',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.rightUpperArmCircumferenceCentimeters,
    storageName: 'right_upper_arm_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Right upper arm', tr: 'Sağ üst kol'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.right,
    referencePoint: LocalizedMeasurementText(
      en: 'Midpoint between shoulder tip and elbow on the right arm.',
      tr: 'Sağ kolda omuz ucu ile dirsek arasındaki orta nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Keep the arm relaxed at the side and measure the same midpoint each time.',
      tr: 'Kolu yanda rahat bırak ve her seferinde aynı orta noktayı ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 15, maximum: 60),
    pairKey: 'upper_arm',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.leftForearmCircumferenceCentimeters,
    storageName: 'left_forearm_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Left forearm', tr: 'Sol ön kol'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.left,
    referencePoint: LocalizedMeasurementText(
      en: 'Widest repeatable point below the left elbow.',
      tr: 'Sol dirsek altındaki tutarlı en geniş nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Relax the hand and forearm, then keep the tape level around the widest point.',
      tr: 'El ve ön kolu gevşet, mezurayı en geniş noktada yatay tut.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 15, maximum: 45),
    pairKey: 'forearm',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.rightForearmCircumferenceCentimeters,
    storageName: 'right_forearm_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Right forearm', tr: 'Sağ ön kol'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.right,
    referencePoint: LocalizedMeasurementText(
      en: 'Widest repeatable point below the right elbow.',
      tr: 'Sağ dirsek altındaki tutarlı en geniş nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Relax the hand and forearm, then keep the tape level around the widest point.',
      tr: 'El ve ön kolu gevşet, mezurayı en geniş noktada yatay tut.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 15, maximum: 45),
    pairKey: 'forearm',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.leftThighCircumferenceCentimeters,
    storageName: 'left_thigh_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Left thigh', tr: 'Sol uyluk'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.left,
    referencePoint: LocalizedMeasurementText(
      en: 'Midpoint between the hip crease and kneecap on the left thigh.',
      tr: 'Sol uylukta kalça kıvrımı ile diz kapağı arasındaki orta nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand evenly on both feet and keep the tape level at the marked midpoint.',
      tr: 'İki ayağa eşit bas ve mezurayı işaretli orta noktada yatay tut.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 35, maximum: 90),
    pairKey: 'thigh',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.rightThighCircumferenceCentimeters,
    storageName: 'right_thigh_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Right thigh', tr: 'Sağ uyluk'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.right,
    referencePoint: LocalizedMeasurementText(
      en: 'Midpoint between the hip crease and kneecap on the right thigh.',
      tr: 'Sağ uylukta kalça kıvrımı ile diz kapağı arasındaki orta nokta.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand evenly on both feet and keep the tape level at the marked midpoint.',
      tr: 'İki ayağa eşit bas ve mezurayı işaretli orta noktada yatay tut.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 35, maximum: 90),
    pairKey: 'thigh',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.leftCalfCircumferenceCentimeters,
    storageName: 'left_calf_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Left calf', tr: 'Sol baldır'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.left,
    referencePoint: LocalizedMeasurementText(
      en: 'Widest repeatable point of the left calf.',
      tr: 'Sol baldırın tutarlı en geniş noktası.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand relaxed and measure the widest point without flexing.',
      tr: 'Rahat dur ve kasmadan en geniş noktayı ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 25, maximum: 60),
    pairKey: 'calf',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.rightCalfCircumferenceCentimeters,
    storageName: 'right_calf_circumference_centimeters',
    title: LocalizedMeasurementText(en: 'Right calf', tr: 'Sağ baldır'),
    group: BodyMeasurementGroup.circumference,
    valueKind: MeasurementValueKind.lengthCentimeters,
    side: MeasurementSide.right,
    referencePoint: LocalizedMeasurementText(
      en: 'Widest repeatable point of the right calf.',
      tr: 'Sağ baldırın tutarlı en geniş noktası.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Stand relaxed and measure the widest point without flexing.',
      tr: 'Rahat dur ve kasmadan en geniş noktayı ölç.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 25, maximum: 60),
    pairKey: 'calf',
  ),
  MeasurementGuide(
    field: BodyMeasurementField.bodyFatPercentage,
    storageName: 'body_fat_percentage',
    title: LocalizedMeasurementText(en: 'Body fat', tr: 'Vücut yağı'),
    group: BodyMeasurementGroup.composition,
    valueKind: MeasurementValueKind.percentage,
    side: MeasurementSide.none,
    referencePoint: LocalizedMeasurementText(
      en: 'A clearly labeled estimate from the selected method.',
      tr: 'Seçilen yönteme göre açıkça etiketlenmiş tahmin.',
    ),
    instruction: LocalizedMeasurementText(
      en: 'Use the same method over time and avoid mixing estimates as exact scans.',
      tr: 'Zaman içinde aynı yöntemi kullan ve tahminleri kesin tarama gibi karıştırma.',
    ),
    referenceRange: MeasurementReferenceRange(minimum: 3, maximum: 60),
  ),
];

MeasurementGuide guideForMeasurementField(BodyMeasurementField field) =>
    bodyMeasurementGuides.firstWhere((guide) => guide.field == field);

MeasurementValidationResult validateMeasurementRecord(
  MeasurementRecord measurement, {
  MeasurementValidationPolicy policy = const MeasurementValidationPolicy(),
}) {
  final issues = <MeasurementValidationIssue>[];
  final values = <BodyMeasurementField, double?>{
    for (final guide in bodyMeasurementGuides)
      guide.field: measurementValueFor(measurement, guide.field),
  };
  final presentFields = values.entries
      .where((entry) => entry.value != null)
      .map((entry) => entry.key)
      .toSet();

  if (policy.requireAtLeastOneMeasuredValue && presentFields.isEmpty) {
    issues.add(
      const MeasurementValidationIssue(
        severity: MeasurementValidationSeverity.error,
        code: MeasurementValidationCode.noMeasuredValues,
      ),
    );
  }

  for (final guide in bodyMeasurementGuides) {
    final value = values[guide.field];
    if (value == null) {
      continue;
    }
    if (!value.isFinite) {
      issues.add(
        MeasurementValidationIssue(
          severity: MeasurementValidationSeverity.error,
          code: MeasurementValidationCode.nonFiniteValue,
          field: guide.field,
          value: value,
        ),
      );
      continue;
    }
    if (guide.valueKind == MeasurementValueKind.percentage) {
      if (value <= 0 || value >= 100) {
        issues.add(
          MeasurementValidationIssue(
            severity: MeasurementValidationSeverity.error,
            code: MeasurementValidationCode.percentageOutOfRange,
            field: guide.field,
            value: value,
          ),
        );
        continue;
      }
    } else if (value <= 0) {
      issues.add(
        MeasurementValidationIssue(
          severity: MeasurementValidationSeverity.error,
          code: MeasurementValidationCode.nonPositiveValue,
          field: guide.field,
          value: value,
        ),
      );
      continue;
    }

    if (value < guide.referenceRange.minimum) {
      issues.add(
        MeasurementValidationIssue(
          severity: MeasurementValidationSeverity.warning,
          code: MeasurementValidationCode.belowReferenceRange,
          field: guide.field,
          value: value,
        ),
      );
    } else if (value > guide.referenceRange.maximum) {
      issues.add(
        MeasurementValidationIssue(
          severity: MeasurementValidationSeverity.warning,
          code: MeasurementValidationCode.aboveReferenceRange,
          field: guide.field,
          value: value,
        ),
      );
    }
  }

  if (policy.warnWhenBodyMeasurementMethodMissing &&
      _hasNonCompositionValue(presentFields) &&
      measurement.bodyMeasurementMethod == null) {
    issues.add(
      const MeasurementValidationIssue(
        severity: MeasurementValidationSeverity.warning,
        code: MeasurementValidationCode.missingBodyMeasurementMethod,
      ),
    );
  }

  if (policy.warnWhenBodyFatMethodMissing &&
      measurement.bodyFatPercentage != null &&
      measurement.bodyFatMeasurementMethod == null) {
    issues.add(
      const MeasurementValidationIssue(
        severity: MeasurementValidationSeverity.warning,
        code: MeasurementValidationCode.missingBodyFatMethod,
        field: BodyMeasurementField.bodyFatPercentage,
      ),
    );
  }

  if (policy.sideDifferenceWarningPercent > 0 &&
      policy.sideDifferenceWarningPercent.isFinite) {
    issues.addAll(
      _sideDifferenceIssues(
        values,
        warningPercent: policy.sideDifferenceWarningPercent,
      ),
    );
  }

  return MeasurementValidationResult(List.unmodifiable(issues));
}

void throwIfMeasurementHasBlockingIssues(MeasurementRecord measurement) {
  final result = validateMeasurementRecord(measurement);
  if (result.hasBlockingIssues) {
    throw MeasurementValidationException(result);
  }
}

double? measurementValueFor(
  MeasurementRecord measurement,
  BodyMeasurementField field,
) {
  return switch (field) {
    BodyMeasurementField.heightCentimeters => measurement.heightCentimeters,
    BodyMeasurementField.weightKilograms => measurement.weightKilograms,
    BodyMeasurementField.torsoLengthCentimeters =>
      measurement.torsoLengthCentimeters,
    BodyMeasurementField.chestCircumferenceCentimeters =>
      measurement.chestCircumferenceCentimeters,
    BodyMeasurementField.waistCircumferenceCentimeters =>
      measurement.waistCircumferenceCentimeters,
    BodyMeasurementField.hipCircumferenceCentimeters =>
      measurement.hipCircumferenceCentimeters,
    BodyMeasurementField.leftUpperArmCircumferenceCentimeters =>
      measurement.leftUpperArmCircumferenceCentimeters,
    BodyMeasurementField.rightUpperArmCircumferenceCentimeters =>
      measurement.rightUpperArmCircumferenceCentimeters,
    BodyMeasurementField.leftForearmCircumferenceCentimeters =>
      measurement.leftForearmCircumferenceCentimeters,
    BodyMeasurementField.rightForearmCircumferenceCentimeters =>
      measurement.rightForearmCircumferenceCentimeters,
    BodyMeasurementField.leftThighCircumferenceCentimeters =>
      measurement.leftThighCircumferenceCentimeters,
    BodyMeasurementField.rightThighCircumferenceCentimeters =>
      measurement.rightThighCircumferenceCentimeters,
    BodyMeasurementField.leftCalfCircumferenceCentimeters =>
      measurement.leftCalfCircumferenceCentimeters,
    BodyMeasurementField.rightCalfCircumferenceCentimeters =>
      measurement.rightCalfCircumferenceCentimeters,
    BodyMeasurementField.bodyFatPercentage => measurement.bodyFatPercentage,
  };
}

bool _hasNonCompositionValue(Set<BodyMeasurementField> presentFields) {
  return presentFields.any(
    (field) =>
        guideForMeasurementField(field).group !=
        BodyMeasurementGroup.composition,
  );
}

Iterable<MeasurementValidationIssue> _sideDifferenceIssues(
  Map<BodyMeasurementField, double?> values, {
  required double warningPercent,
}) sync* {
  yield* _sidePairIssue(
    values,
    left: BodyMeasurementField.leftUpperArmCircumferenceCentimeters,
    right: BodyMeasurementField.rightUpperArmCircumferenceCentimeters,
    warningPercent: warningPercent,
  );
  yield* _sidePairIssue(
    values,
    left: BodyMeasurementField.leftForearmCircumferenceCentimeters,
    right: BodyMeasurementField.rightForearmCircumferenceCentimeters,
    warningPercent: warningPercent,
  );
  yield* _sidePairIssue(
    values,
    left: BodyMeasurementField.leftThighCircumferenceCentimeters,
    right: BodyMeasurementField.rightThighCircumferenceCentimeters,
    warningPercent: warningPercent,
  );
  yield* _sidePairIssue(
    values,
    left: BodyMeasurementField.leftCalfCircumferenceCentimeters,
    right: BodyMeasurementField.rightCalfCircumferenceCentimeters,
    warningPercent: warningPercent,
  );
}

Iterable<MeasurementValidationIssue> _sidePairIssue(
  Map<BodyMeasurementField, double?> values, {
  required BodyMeasurementField left,
  required BodyMeasurementField right,
  required double warningPercent,
}) sync* {
  final leftValue = values[left];
  final rightValue = values[right];
  if (leftValue == null ||
      rightValue == null ||
      !leftValue.isFinite ||
      !rightValue.isFinite ||
      leftValue <= 0 ||
      rightValue <= 0) {
    return;
  }
  final larger = leftValue > rightValue ? leftValue : rightValue;
  final differencePercent = (leftValue - rightValue).abs() / larger * 100;
  if (differencePercent > warningPercent) {
    yield MeasurementValidationIssue(
      severity: MeasurementValidationSeverity.warning,
      code: MeasurementValidationCode.sideToSideDifference,
      field: left,
      relatedField: right,
      value: differencePercent,
    );
  }
}
