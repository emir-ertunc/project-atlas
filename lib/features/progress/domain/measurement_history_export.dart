import 'dart:convert';

import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

const measurementHistoryExportSchemaVersion = 'measurement_history_export.v1';

enum MeasurementHistoryDirection { increased, decreased, stable }

final class MeasurementHistoryReadModel {
  MeasurementHistoryReadModel({
    required this.schemaVersion,
    required this.generatedAt,
    required List<MeasurementRecord> records,
    required List<MeasurementHistoryComparison> comparisons,
    required List<MeasurementHistorySideComparison> sideComparisons,
  }) : records = List.unmodifiable(records),
       comparisons = List.unmodifiable(comparisons),
       sideComparisons = List.unmodifiable(sideComparisons);

  final String schemaVersion;
  final DateTime generatedAt;
  final List<MeasurementRecord> records;
  final List<MeasurementHistoryComparison> comparisons;
  final List<MeasurementHistorySideComparison> sideComparisons;

  bool get isEmpty => records.isEmpty;

  bool get hasComparisons =>
      comparisons.isNotEmpty || sideComparisons.isNotEmpty;

  MeasurementHistoryComparison? comparisonFor(BodyMeasurementField field) {
    for (final comparison in comparisons) {
      if (comparison.field == field) {
        return comparison;
      }
    }
    return null;
  }

  MeasurementHistorySideComparison? sideComparisonFor(String pairKey) {
    for (final comparison in sideComparisons) {
      if (comparison.pairKey == pairKey) {
        return comparison;
      }
    }
    return null;
  }

  String toCsv() {
    final buffer = StringBuffer()
      ..writeln(_csvRow(_measurementHistoryCsvColumns));

    for (final record in records) {
      buffer.writeln(
        _csvRow([
          schemaVersion,
          record.id,
          record.measuredAt.toUtc().toIso8601String(),
          record.createdAt.toUtc().toIso8601String(),
          record.origin.name,
          record.bodyMeasurementMethod?.name ?? '',
          record.bodyFatMeasurementMethod?.name ?? '',
          for (final guide in bodyMeasurementGuides)
            _formatExportNumber(measurementValueFor(record, guide.field)),
          record.notes ?? '',
        ]),
      );
    }

    return buffer.toString();
  }

  String toJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'schema_version': schemaVersion,
      'generated_at': generatedAt.toUtc().toIso8601String(),
      'record_count': records.length,
      'records': [for (final record in records) _recordToJson(record)],
      'comparisons': [
        for (final comparison in comparisons) comparison.toJson(),
      ],
      'side_comparisons': [
        for (final comparison in sideComparisons) comparison.toJson(),
      ],
    });
  }
}

final class MeasurementHistoryComparison {
  const MeasurementHistoryComparison({
    required this.field,
    required this.storageName,
    required this.valueKind,
    required this.baselineRecordId,
    required this.latestRecordId,
    required this.baselineMeasuredAt,
    required this.latestMeasuredAt,
    required this.baselineValue,
    required this.latestValue,
  });

  final BodyMeasurementField field;
  final String storageName;
  final MeasurementValueKind valueKind;
  final String baselineRecordId;
  final String latestRecordId;
  final DateTime baselineMeasuredAt;
  final DateTime latestMeasuredAt;
  final double baselineValue;
  final double latestValue;

  double get delta => latestValue - baselineValue;

  double get deltaPercent => baselineValue == 0
      ? 0
      : ((latestValue - baselineValue) / baselineValue) * 100;

  MeasurementHistoryDirection get direction => _directionFor(delta);

  Map<String, Object?> toJson() {
    return {
      'field': storageName,
      'unit': valueKind.name,
      'baseline_record_id': baselineRecordId,
      'latest_record_id': latestRecordId,
      'baseline_measured_at': baselineMeasuredAt.toUtc().toIso8601String(),
      'latest_measured_at': latestMeasuredAt.toUtc().toIso8601String(),
      'baseline_value': baselineValue,
      'latest_value': latestValue,
      'delta': delta,
      'delta_percent': deltaPercent,
      'direction': direction.name,
    };
  }
}

final class MeasurementHistorySideComparison {
  const MeasurementHistorySideComparison({
    required this.pairKey,
    required this.leftField,
    required this.rightField,
    required this.recordId,
    required this.measuredAt,
    required this.leftValue,
    required this.rightValue,
  });

  final String pairKey;
  final BodyMeasurementField leftField;
  final BodyMeasurementField rightField;
  final String recordId;
  final DateTime measuredAt;
  final double leftValue;
  final double rightValue;

  double get delta => rightValue - leftValue;

  double get absoluteDelta => delta.abs();

  double get absoluteDeltaPercent {
    final average = (leftValue + rightValue) / 2;
    return average == 0 ? 0 : (absoluteDelta / average) * 100;
  }

  MeasurementHistoryDirection get direction => _directionFor(delta);

  Map<String, Object?> toJson() {
    return {
      'pair_key': pairKey,
      'left_field': guideForMeasurementField(leftField).storageName,
      'right_field': guideForMeasurementField(rightField).storageName,
      'record_id': recordId,
      'measured_at': measuredAt.toUtc().toIso8601String(),
      'left_value': leftValue,
      'right_value': rightValue,
      'delta': delta,
      'absolute_delta': absoluteDelta,
      'absolute_delta_percent': absoluteDeltaPercent,
      'direction': direction.name,
    };
  }
}

MeasurementHistoryReadModel buildMeasurementHistoryReadModel({
  required Iterable<MeasurementRecord> measurements,
  required DateTime generatedAt,
}) {
  final sortedRecords = measurements.toList(growable: false)
    ..sort((left, right) {
      final measuredComparison = left.measuredAt.compareTo(right.measuredAt);
      if (measuredComparison != 0) {
        return measuredComparison;
      }
      return left.id.compareTo(right.id);
    });

  return MeasurementHistoryReadModel(
    schemaVersion: measurementHistoryExportSchemaVersion,
    generatedAt: generatedAt.toUtc(),
    records: sortedRecords,
    comparisons: _buildComparisons(sortedRecords),
    sideComparisons: _buildSideComparisons(sortedRecords),
  );
}

List<MeasurementHistoryComparison> _buildComparisons(
  List<MeasurementRecord> records,
) {
  final comparisons = <MeasurementHistoryComparison>[];

  for (final guide in bodyMeasurementGuides) {
    final points = <_MeasurementHistoryPoint>[];
    for (final record in records) {
      final value = measurementValueFor(record, guide.field);
      if (_isUsableMeasurementValue(value, guide.valueKind)) {
        points.add(
          _MeasurementHistoryPoint(
            recordId: record.id,
            measuredAt: record.measuredAt.toUtc(),
            value: value!,
          ),
        );
      }
    }

    if (points.length >= 2) {
      comparisons.add(
        MeasurementHistoryComparison(
          field: guide.field,
          storageName: guide.storageName,
          valueKind: guide.valueKind,
          baselineRecordId: points.first.recordId,
          latestRecordId: points.last.recordId,
          baselineMeasuredAt: points.first.measuredAt,
          latestMeasuredAt: points.last.measuredAt,
          baselineValue: points.first.value,
          latestValue: points.last.value,
        ),
      );
    }
  }

  return List.unmodifiable(comparisons);
}

List<MeasurementHistorySideComparison> _buildSideComparisons(
  List<MeasurementRecord> records,
) {
  final pairGuides =
      <String, ({MeasurementGuide? left, MeasurementGuide? right})>{};
  for (final guide in bodyMeasurementGuides) {
    final pairKey = guide.pairKey;
    if (pairKey == null) {
      continue;
    }
    final current = pairGuides[pairKey] ?? (left: null, right: null);
    pairGuides[pairKey] = switch (guide.side) {
      MeasurementSide.left => (left: guide, right: current.right),
      MeasurementSide.right => (left: current.left, right: guide),
      MeasurementSide.none => current,
    };
  }

  final comparisons = <MeasurementHistorySideComparison>[];
  for (final entry in pairGuides.entries) {
    final leftGuide = entry.value.left;
    final rightGuide = entry.value.right;
    if (leftGuide == null || rightGuide == null) {
      continue;
    }

    for (final record in records.reversed) {
      final leftValue = measurementValueFor(record, leftGuide.field);
      final rightValue = measurementValueFor(record, rightGuide.field);
      if (_isUsableMeasurementValue(leftValue, leftGuide.valueKind) &&
          _isUsableMeasurementValue(rightValue, rightGuide.valueKind)) {
        comparisons.add(
          MeasurementHistorySideComparison(
            pairKey: entry.key,
            leftField: leftGuide.field,
            rightField: rightGuide.field,
            recordId: record.id,
            measuredAt: record.measuredAt.toUtc(),
            leftValue: leftValue!,
            rightValue: rightValue!,
          ),
        );
        break;
      }
    }
  }

  comparisons.sort((left, right) => left.pairKey.compareTo(right.pairKey));
  return List.unmodifiable(comparisons);
}

Map<String, Object?> _recordToJson(MeasurementRecord record) {
  return {
    'record_id': record.id,
    'measured_at': record.measuredAt.toUtc().toIso8601String(),
    'created_at': record.createdAt.toUtc().toIso8601String(),
    'origin': record.origin.name,
    'body_measurement_method': record.bodyMeasurementMethod?.name,
    'body_fat_measurement_method': record.bodyFatMeasurementMethod?.name,
    for (final guide in bodyMeasurementGuides)
      guide.storageName: measurementValueFor(record, guide.field),
    'notes': record.notes,
  };
}

bool _isUsableMeasurementValue(double? value, MeasurementValueKind valueKind) {
  if (value == null || !value.isFinite) {
    return false;
  }
  return switch (valueKind) {
    MeasurementValueKind.percentage => value > 0 && value < 100,
    _ => value > 0,
  };
}

MeasurementHistoryDirection _directionFor(double delta) {
  if (delta.abs() < 0.0001) {
    return MeasurementHistoryDirection.stable;
  }
  return delta > 0
      ? MeasurementHistoryDirection.increased
      : MeasurementHistoryDirection.decreased;
}

String _csvRow(Iterable<String> values) {
  return values.map(_csvCell).join(',');
}

String _csvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

String _formatExportNumber(double? value) {
  if (value == null) {
    return '';
  }
  final text = value.toStringAsFixed(4);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

final _measurementHistoryCsvColumns = <String>[
  'schema_version',
  'record_id',
  'measured_at',
  'created_at',
  'origin',
  'body_measurement_method',
  'body_fat_measurement_method',
  for (final guide in bodyMeasurementGuides) guide.storageName,
  'notes',
];

final class _MeasurementHistoryPoint {
  const _MeasurementHistoryPoint({
    required this.recordId,
    required this.measuredAt,
    required this.value,
  });

  final String recordId;
  final DateTime measuredAt;
  final double value;
}
