import 'dart:math' as math;

import 'package:project_atlas/core/repositories/repository_records.dart';

const progressTrendsRuleSetVersion = 'progress_trends.v1';

enum ProgressTrendDirection { increased, decreased, stable }

enum ProgressTrendValueUnit {
  kilograms,
  centimeters,
  percentage,
  repetitions,
  kilogramRepetitions,
}

enum MeasurementTrendMetric {
  height,
  weight,
  torsoLength,
  chest,
  waist,
  hips,
  leftUpperArm,
  rightUpperArm,
  leftForearm,
  rightForearm,
  leftThigh,
  rightThigh,
  leftCalf,
  rightCalf,
  bodyFat,
}

enum TrainingTrendMetric { volume, load, repetitions, estimatedStrength }

final class ProgressTrendSet {
  ProgressTrendSet({
    required this.ruleSetVersion,
    required this.generatedAt,
    required List<MeasurementProgressTrend> measurementTrends,
    required List<ExerciseProgressTrend> trainingTrends,
  }) : measurementTrends = List.unmodifiable(measurementTrends),
       trainingTrends = List.unmodifiable(trainingTrends);

  final String ruleSetVersion;
  final DateTime generatedAt;
  final List<MeasurementProgressTrend> measurementTrends;
  final List<ExerciseProgressTrend> trainingTrends;

  bool get isEmpty => measurementTrends.isEmpty && trainingTrends.isEmpty;

  MeasurementProgressTrend? measurementTrendFor(MeasurementTrendMetric metric) {
    for (final trend in measurementTrends) {
      if (trend.metric == metric) {
        return trend;
      }
    }
    return null;
  }

  ExerciseProgressTrend? trainingTrendFor(String exerciseId) {
    for (final trend in trainingTrends) {
      if (trend.exerciseId == exerciseId) {
        return trend;
      }
    }
    return null;
  }
}

final class MeasurementProgressTrend {
  MeasurementProgressTrend({
    required this.metric,
    required this.unit,
    required List<ProgressTrendPoint> points,
  }) : points = List.unmodifiable(points);

  final MeasurementTrendMetric metric;
  final ProgressTrendValueUnit unit;
  final List<ProgressTrendPoint> points;

  ProgressTrendPoint get firstPoint => points.first;

  ProgressTrendPoint get latestPoint => points.last;

  double get delta => latestPoint.value - firstPoint.value;

  ProgressTrendDirection get direction => _directionFor(delta);
}

final class ExerciseProgressTrend {
  ExerciseProgressTrend({
    required this.exerciseId,
    required List<TrainingMetricProgressTrend> metricTrends,
  }) : metricTrends = List.unmodifiable(metricTrends);

  final String exerciseId;
  final List<TrainingMetricProgressTrend> metricTrends;

  TrainingMetricProgressTrend? metricTrendFor(TrainingTrendMetric metric) {
    for (final trend in metricTrends) {
      if (trend.metric == metric) {
        return trend;
      }
    }
    return null;
  }
}

final class TrainingMetricProgressTrend {
  TrainingMetricProgressTrend({
    required this.metric,
    required this.unit,
    required List<ProgressTrendPoint> points,
  }) : points = List.unmodifiable(points);

  final TrainingTrendMetric metric;
  final ProgressTrendValueUnit unit;
  final List<ProgressTrendPoint> points;

  ProgressTrendPoint get firstPoint => points.first;

  ProgressTrendPoint get latestPoint => points.last;

  double get delta => latestPoint.value - firstPoint.value;

  ProgressTrendDirection get direction => _directionFor(delta);
}

final class ProgressTrendPoint {
  const ProgressTrendPoint({
    required this.occurredAt,
    required this.value,
    required this.evidenceId,
  });

  final DateTime occurredAt;
  final double value;
  final String evidenceId;
}

final class WorkoutTrendSetEvidence {
  const WorkoutTrendSetEvidence({
    required this.sessionId,
    required this.sessionSetId,
    required this.exerciseId,
    required this.occurredAt,
    this.repetitions,
    this.loadKilograms,
    this.result,
  });

  final String sessionId;
  final String sessionSetId;
  final String exerciseId;
  final DateTime occurredAt;
  final int? repetitions;
  final double? loadKilograms;
  final SetResult? result;
}

ProgressTrendSet buildProgressTrends({
  required Iterable<MeasurementRecord> measurements,
  required Iterable<WorkoutTrendSetEvidence> workoutSets,
  required DateTime generatedAt,
}) {
  return ProgressTrendSet(
    ruleSetVersion: progressTrendsRuleSetVersion,
    generatedAt: generatedAt.toUtc(),
    measurementTrends: _measurementTrends(measurements),
    trainingTrends: _trainingTrends(workoutSets),
  );
}

List<MeasurementProgressTrend> _measurementTrends(
  Iterable<MeasurementRecord> measurements,
) {
  final sortedMeasurements = measurements.toList(growable: false)
    ..sort((left, right) => left.measuredAt.compareTo(right.measuredAt));
  final trends = <MeasurementProgressTrend>[];

  for (final metric in MeasurementTrendMetric.values) {
    final points = <ProgressTrendPoint>[];
    for (final measurement in sortedMeasurements) {
      final value = _measurementValue(metric, measurement);
      if (_isUsableTrendValue(value)) {
        points.add(
          ProgressTrendPoint(
            occurredAt: measurement.measuredAt.toUtc(),
            value: value!,
            evidenceId: measurement.id,
          ),
        );
      }
    }

    if (points.length >= 2) {
      trends.add(
        MeasurementProgressTrend(
          metric: metric,
          unit: _measurementUnit(metric),
          points: points,
        ),
      );
    }
  }

  trends.sort((left, right) {
    final metricComparison = left.metric.index.compareTo(right.metric.index);
    if (metricComparison != 0) {
      return metricComparison;
    }
    return left.latestPoint.occurredAt.compareTo(right.latestPoint.occurredAt);
  });
  return trends;
}

List<ExerciseProgressTrend> _trainingTrends(
  Iterable<WorkoutTrendSetEvidence> workoutSets,
) {
  final bucketsByExerciseAndSession = <String, _WorkoutSessionTrendBucket>{};

  for (final evidence in workoutSets) {
    if (!_isCleanWorkoutTrendEvidence(evidence)) {
      continue;
    }

    final key = '${evidence.exerciseId}|${evidence.sessionId}';
    final bucket = bucketsByExerciseAndSession.putIfAbsent(
      key,
      () => _WorkoutSessionTrendBucket(
        exerciseId: evidence.exerciseId,
        sessionId: evidence.sessionId,
        occurredAt: evidence.occurredAt.toUtc(),
      ),
    );
    bucket.add(evidence);
  }

  final bucketsByExercise = <String, List<_WorkoutSessionTrendBucket>>{};
  for (final bucket in bucketsByExerciseAndSession.values) {
    bucketsByExercise.putIfAbsent(bucket.exerciseId, () => []).add(bucket);
  }

  final trends = <ExerciseProgressTrend>[];
  for (final entry in bucketsByExercise.entries) {
    final buckets = entry.value
      ..sort((left, right) => left.occurredAt.compareTo(right.occurredAt));
    final metricTrends = <TrainingMetricProgressTrend>[
      if (_trainingMetricPoints(buckets, TrainingTrendMetric.volume).length >=
          2)
        TrainingMetricProgressTrend(
          metric: TrainingTrendMetric.volume,
          unit: ProgressTrendValueUnit.kilogramRepetitions,
          points: _trainingMetricPoints(buckets, TrainingTrendMetric.volume),
        ),
      if (_trainingMetricPoints(buckets, TrainingTrendMetric.load).length >= 2)
        TrainingMetricProgressTrend(
          metric: TrainingTrendMetric.load,
          unit: ProgressTrendValueUnit.kilograms,
          points: _trainingMetricPoints(buckets, TrainingTrendMetric.load),
        ),
      if (_trainingMetricPoints(
            buckets,
            TrainingTrendMetric.repetitions,
          ).length >=
          2)
        TrainingMetricProgressTrend(
          metric: TrainingTrendMetric.repetitions,
          unit: ProgressTrendValueUnit.repetitions,
          points: _trainingMetricPoints(
            buckets,
            TrainingTrendMetric.repetitions,
          ),
        ),
      if (_trainingMetricPoints(
            buckets,
            TrainingTrendMetric.estimatedStrength,
          ).length >=
          2)
        TrainingMetricProgressTrend(
          metric: TrainingTrendMetric.estimatedStrength,
          unit: ProgressTrendValueUnit.kilograms,
          points: _trainingMetricPoints(
            buckets,
            TrainingTrendMetric.estimatedStrength,
          ),
        ),
    ];

    if (metricTrends.isNotEmpty) {
      trends.add(
        ExerciseProgressTrend(
          exerciseId: entry.key,
          metricTrends: metricTrends,
        ),
      );
    }
  }

  trends.sort((left, right) => left.exerciseId.compareTo(right.exerciseId));
  return trends;
}

List<ProgressTrendPoint> _trainingMetricPoints(
  List<_WorkoutSessionTrendBucket> buckets,
  TrainingTrendMetric metric,
) {
  return [
    for (final bucket in buckets)
      if (bucket.valueFor(metric) case final value?)
        ProgressTrendPoint(
          occurredAt: bucket.occurredAt,
          value: value,
          evidenceId: bucket.sessionId,
        ),
  ];
}

double? _measurementValue(
  MeasurementTrendMetric metric,
  MeasurementRecord measurement,
) {
  return switch (metric) {
    MeasurementTrendMetric.height => measurement.heightCentimeters,
    MeasurementTrendMetric.weight => measurement.weightKilograms,
    MeasurementTrendMetric.torsoLength => measurement.torsoLengthCentimeters,
    MeasurementTrendMetric.chest => measurement.chestCircumferenceCentimeters,
    MeasurementTrendMetric.waist => measurement.waistCircumferenceCentimeters,
    MeasurementTrendMetric.hips => measurement.hipCircumferenceCentimeters,
    MeasurementTrendMetric.leftUpperArm =>
      measurement.leftUpperArmCircumferenceCentimeters,
    MeasurementTrendMetric.rightUpperArm =>
      measurement.rightUpperArmCircumferenceCentimeters,
    MeasurementTrendMetric.leftForearm =>
      measurement.leftForearmCircumferenceCentimeters,
    MeasurementTrendMetric.rightForearm =>
      measurement.rightForearmCircumferenceCentimeters,
    MeasurementTrendMetric.leftThigh =>
      measurement.leftThighCircumferenceCentimeters,
    MeasurementTrendMetric.rightThigh =>
      measurement.rightThighCircumferenceCentimeters,
    MeasurementTrendMetric.leftCalf =>
      measurement.leftCalfCircumferenceCentimeters,
    MeasurementTrendMetric.rightCalf =>
      measurement.rightCalfCircumferenceCentimeters,
    MeasurementTrendMetric.bodyFat => measurement.bodyFatPercentage,
  };
}

ProgressTrendValueUnit _measurementUnit(MeasurementTrendMetric metric) {
  return switch (metric) {
    MeasurementTrendMetric.weight => ProgressTrendValueUnit.kilograms,
    MeasurementTrendMetric.bodyFat => ProgressTrendValueUnit.percentage,
    _ => ProgressTrendValueUnit.centimeters,
  };
}

bool _isUsableTrendValue(double? value) {
  return value != null && value.isFinite && value > 0;
}

bool _isCleanWorkoutTrendEvidence(WorkoutTrendSetEvidence evidence) {
  final repetitions = evidence.repetitions;
  final loadKilograms = evidence.loadKilograms;
  return evidence.result == null &&
      ((repetitions != null && repetitions > 0) ||
          (loadKilograms != null && loadKilograms > 0));
}

ProgressTrendDirection _directionFor(double delta) {
  if (delta.abs() < 0.0001) {
    return ProgressTrendDirection.stable;
  }
  return delta > 0
      ? ProgressTrendDirection.increased
      : ProgressTrendDirection.decreased;
}

final class _WorkoutSessionTrendBucket {
  _WorkoutSessionTrendBucket({
    required this.exerciseId,
    required this.sessionId,
    required this.occurredAt,
  });

  final String exerciseId;
  final String sessionId;
  final DateTime occurredAt;
  var _volumeKilogramRepetitions = 0.0;
  double? _bestLoadKilograms;
  int? _bestRepetitions;
  double? _bestEstimatedStrengthKilograms;

  void add(WorkoutTrendSetEvidence evidence) {
    final repetitions = evidence.repetitions;
    final loadKilograms = evidence.loadKilograms;

    if (repetitions != null && repetitions > 0) {
      _bestRepetitions = math.max(_bestRepetitions ?? repetitions, repetitions);
    }
    if (loadKilograms != null && loadKilograms > 0) {
      _bestLoadKilograms = math.max(
        _bestLoadKilograms ?? loadKilograms,
        loadKilograms,
      );
    }
    if (repetitions != null &&
        repetitions > 0 &&
        loadKilograms != null &&
        loadKilograms > 0) {
      _volumeKilogramRepetitions += repetitions * loadKilograms;
      _bestEstimatedStrengthKilograms = math.max(
        _bestEstimatedStrengthKilograms ??
            _estimatedStrengthKilograms(
              repetitions: repetitions,
              loadKilograms: loadKilograms,
            ),
        _estimatedStrengthKilograms(
          repetitions: repetitions,
          loadKilograms: loadKilograms,
        ),
      );
    }
  }

  double? valueFor(TrainingTrendMetric metric) {
    return switch (metric) {
      TrainingTrendMetric.volume =>
        _volumeKilogramRepetitions > 0 ? _volumeKilogramRepetitions : null,
      TrainingTrendMetric.load => _bestLoadKilograms,
      TrainingTrendMetric.repetitions => _bestRepetitions?.toDouble(),
      TrainingTrendMetric.estimatedStrength => _bestEstimatedStrengthKilograms,
    };
  }
}

double _estimatedStrengthKilograms({
  required int repetitions,
  required double loadKilograms,
}) {
  final boundedRepetitions = repetitions.clamp(1, 30);
  return loadKilograms * (1 + boundedRepetitions / 30);
}
