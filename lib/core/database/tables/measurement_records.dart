import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';

enum MeasurementSource { manual, imported }

enum StoredBodyMeasurementMethod {
  tapeMeasure,
  scaleOrStadiometer,
  smartScale,
  importedDevice,
  selfReported,
  other,
}

enum StoredBodyFatMeasurementMethod {
  caliper,
  bioelectricalImpedance,
  dexa,
  navyTape,
  visualEstimate,
  importedDevice,
  other,
}

@DataClassName('MeasurementRecordRow')
@TableIndex(
  name: 'measurement_records_profile_measured_idx',
  columns: {#profileId, #measuredAt},
)
class MeasurementRecords extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get measuredAt => dateTime()();

  TextColumn get source => textEnum<MeasurementSource>()();

  RealColumn get heightCentimeters => real()
      .named('height_centimeters')
      .nullable()
      .customConstraint('CHECK (height_centimeters > 0)')();

  RealColumn get weightKilograms => real()
      .named('weight_kilograms')
      .nullable()
      .customConstraint('CHECK (weight_kilograms > 0)')();

  RealColumn get torsoLengthCentimeters => real()
      .named('torso_length_centimeters')
      .nullable()
      .customConstraint('CHECK (torso_length_centimeters > 0)')();

  RealColumn get chestCircumferenceCentimeters => real()
      .named('chest_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (chest_circumference_centimeters > 0)')();

  RealColumn get waistCircumferenceCentimeters => real()
      .named('waist_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (waist_circumference_centimeters > 0)')();

  RealColumn get hipCircumferenceCentimeters => real()
      .named('hip_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (hip_circumference_centimeters > 0)')();

  RealColumn get leftUpperArmCircumferenceCentimeters => real()
      .named('left_upper_arm_circumference_centimeters')
      .nullable()
      .customConstraint(
        'CHECK (left_upper_arm_circumference_centimeters > 0)',
      )();

  RealColumn get rightUpperArmCircumferenceCentimeters => real()
      .named('right_upper_arm_circumference_centimeters')
      .nullable()
      .customConstraint(
        'CHECK (right_upper_arm_circumference_centimeters > 0)',
      )();

  RealColumn get leftForearmCircumferenceCentimeters => real()
      .named('left_forearm_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (left_forearm_circumference_centimeters > 0)')();

  RealColumn get rightForearmCircumferenceCentimeters => real()
      .named('right_forearm_circumference_centimeters')
      .nullable()
      .customConstraint(
        'CHECK (right_forearm_circumference_centimeters > 0)',
      )();

  RealColumn get leftThighCircumferenceCentimeters => real()
      .named('left_thigh_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (left_thigh_circumference_centimeters > 0)')();

  RealColumn get rightThighCircumferenceCentimeters => real()
      .named('right_thigh_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (right_thigh_circumference_centimeters > 0)')();

  RealColumn get leftCalfCircumferenceCentimeters => real()
      .named('left_calf_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (left_calf_circumference_centimeters > 0)')();

  RealColumn get rightCalfCircumferenceCentimeters => real()
      .named('right_calf_circumference_centimeters')
      .nullable()
      .customConstraint('CHECK (right_calf_circumference_centimeters > 0)')();

  RealColumn get bodyFatPercentage => real()
      .named('body_fat_percentage')
      .nullable()
      .customConstraint(
        'CHECK (body_fat_percentage > 0 AND body_fat_percentage < 100)',
      )();

  TextColumn get bodyMeasurementMethod =>
      textEnum<StoredBodyMeasurementMethod>()
          .named('body_measurement_method')
          .nullable()
          .customConstraint(
            "CHECK (body_measurement_method IN "
            "('tapeMeasure', 'scaleOrStadiometer', 'smartScale', "
            "'importedDevice', 'selfReported', 'other'))",
          )();

  TextColumn get bodyFatMeasurementMethod =>
      textEnum<StoredBodyFatMeasurementMethod>()
          .named('body_fat_measurement_method')
          .nullable()
          .customConstraint(
            "CHECK (body_fat_measurement_method IN "
            "('caliper', 'bioelectricalImpedance', 'dexa', 'navyTape', "
            "'visualEstimate', 'importedDevice', 'other'))",
          )();

  TextColumn get notes => text().withLength(max: 2000).nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (source IN ('manual', 'imported'))",
  ];
}
