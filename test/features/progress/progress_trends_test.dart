import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/progress/domain/progress_trends.dart';

void main() {
  group('buildProgressTrends', () {
    test('builds measurement trends from sorted measurement history', () {
      final now = DateTime.utc(2026, 7, 21, 12);

      final trends = buildProgressTrends(
        measurements: [
          _measurement(
            id: 'measurement-new',
            measuredAt: now,
            weightKilograms: 79,
            bodyFatPercentage: 17.5,
            chestCircumferenceCentimeters: 104,
          ),
          _measurement(
            id: 'measurement-old',
            measuredAt: now.subtract(const Duration(days: 30)),
            weightKilograms: 81,
            bodyFatPercentage: 18.2,
            chestCircumferenceCentimeters: 101,
          ),
        ],
        workoutSets: const [],
        generatedAt: now,
      );

      expect(trends.ruleSetVersion, progressTrendsRuleSetVersion);
      expect(trends.trainingTrends, isEmpty);

      final weight = trends.measurementTrendFor(MeasurementTrendMetric.weight)!;
      expect(weight.unit, ProgressTrendValueUnit.kilograms);
      expect(weight.firstPoint.value, 81);
      expect(weight.latestPoint.value, 79);
      expect(weight.delta, -2);
      expect(weight.direction, ProgressTrendDirection.decreased);

      final bodyFat = trends.measurementTrendFor(
        MeasurementTrendMetric.bodyFat,
      )!;
      expect(bodyFat.unit, ProgressTrendValueUnit.percentage);
      expect(bodyFat.delta, closeTo(-0.7, 0.0001));

      final chest = trends.measurementTrendFor(MeasurementTrendMetric.chest)!;
      expect(chest.unit, ProgressTrendValueUnit.centimeters);
      expect(chest.delta, 3);
      expect(chest.direction, ProgressTrendDirection.increased);
    });

    test('builds volume, load, repetition, and estimated-strength trends', () {
      final now = DateTime.utc(2026, 7, 21, 12);

      final trends = buildProgressTrends(
        measurements: const [],
        workoutSets: [
          _setEvidence(
            sessionId: 'older-session',
            sessionSetId: 'older-bench-0',
            exerciseId: 'barbell_bench_press',
            occurredAt: now.subtract(const Duration(days: 7)),
            repetitions: 6,
            loadKilograms: 50,
          ),
          _setEvidence(
            sessionId: 'recent-session',
            sessionSetId: 'recent-bench-0',
            exerciseId: 'barbell_bench_press',
            occurredAt: now,
            repetitions: 8,
            loadKilograms: 55,
          ),
          _setEvidence(
            sessionId: 'recent-session',
            sessionSetId: 'recent-bench-1',
            exerciseId: 'barbell_bench_press',
            occurredAt: now,
            repetitions: 7,
            loadKilograms: 52.5,
          ),
        ],
        generatedAt: now,
      );

      final bench = trends.trainingTrendFor('barbell_bench_press')!;
      expect(bench.metricTrends, hasLength(4));

      final volume = bench.metricTrendFor(TrainingTrendMetric.volume)!;
      expect(volume.unit, ProgressTrendValueUnit.kilogramRepetitions);
      expect(volume.firstPoint.value, 300);
      expect(volume.latestPoint.value, 807.5);
      expect(volume.delta, 507.5);

      final load = bench.metricTrendFor(TrainingTrendMetric.load)!;
      expect(load.latestPoint.value, 55);

      final repetitions = bench.metricTrendFor(
        TrainingTrendMetric.repetitions,
      )!;
      expect(repetitions.latestPoint.value, 8);

      final estimatedStrength = bench.metricTrendFor(
        TrainingTrendMetric.estimatedStrength,
      )!;
      expect(estimatedStrength.latestPoint.value, closeTo(69.67, 0.01));
    });

    test('ignores limited outcomes and single-point inputs', () {
      final now = DateTime.utc(2026, 7, 21, 12);

      final trends = buildProgressTrends(
        measurements: [
          _measurement(
            id: 'single-measurement',
            measuredAt: now,
            weightKilograms: 80,
          ),
        ],
        workoutSets: [
          _setEvidence(
            sessionId: 'older-session',
            sessionSetId: 'older-bench-0',
            exerciseId: 'barbell_bench_press',
            occurredAt: now.subtract(const Duration(days: 7)),
            repetitions: 5,
            loadKilograms: 55,
            result: SetResult.strengthLimitation,
          ),
          _setEvidence(
            sessionId: 'recent-session',
            sessionSetId: 'recent-bench-0',
            exerciseId: 'barbell_bench_press',
            occurredAt: now,
            repetitions: 8,
            loadKilograms: 55,
          ),
        ],
        generatedAt: now,
      );

      expect(trends.isEmpty, isTrue);
      expect(trends.measurementTrends, isEmpty);
      expect(trends.trainingTrends, isEmpty);
    });
  });
}

MeasurementRecord _measurement({
  required String id,
  required DateTime measuredAt,
  double? weightKilograms,
  double? bodyFatPercentage,
  double? chestCircumferenceCentimeters,
}) {
  return MeasurementRecord(
    id: id,
    profileId: 'profile',
    measuredAt: measuredAt,
    origin: MeasurementOrigin.manual,
    weightKilograms: weightKilograms,
    bodyFatPercentage: bodyFatPercentage,
    chestCircumferenceCentimeters: chestCircumferenceCentimeters,
    createdAt: measuredAt,
  );
}

WorkoutTrendSetEvidence _setEvidence({
  required String sessionId,
  required String sessionSetId,
  required String exerciseId,
  required DateTime occurredAt,
  int? repetitions,
  double? loadKilograms,
  SetResult? result,
}) {
  return WorkoutTrendSetEvidence(
    sessionId: sessionId,
    sessionSetId: sessionSetId,
    exerciseId: exerciseId,
    occurredAt: occurredAt,
    repetitions: repetitions,
    loadKilograms: loadKilograms,
    result: result,
  );
}
