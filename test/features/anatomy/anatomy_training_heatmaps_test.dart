import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  group('buildAnatomyTrainingHeatmaps', () {
    test('builds normalized heatmaps from catalog muscle roles', () {
      final catalog = loadTestExerciseCatalog();
      final now = DateTime.utc(2026, 7, 21, 12);
      final performances = [
        for (var index = 0; index < 3; index += 1)
          _performance(
            exerciseId: 'barbell_bench_press',
            performedAt: now.subtract(Duration(minutes: index)),
            repetitions: 8,
            loadKilograms: 80,
            rir: 1,
          ),
      ];

      final heatmaps = buildAnatomyTrainingHeatmaps(
        catalog: catalog,
        performances: performances,
        now: now,
      );

      expect(heatmaps.ruleSetVersion, anatomyTrainingHeatmapRuleSetVersion);
      expect(heatmaps.evidenceSetCount, 3);
      expect(heatmaps.ignoredExerciseIds, isEmpty);

      final trained = heatmaps.heatmapFor(
        AnatomyTrainingHeatmapKind.trainedMuscle,
      );
      expect(trained.scoreFor('pectoralis_major_right'), closeTo(1, 0.0001));
      expect(trained.scoreFor('serratus_anterior_right'), closeTo(0.65, 0.001));
      expect(trained.scoreFor('rotator_cuff_right'), closeTo(0.35, 0.001));

      final volume = heatmaps.heatmapFor(
        AnatomyTrainingHeatmapKind.weeklyVolume,
      );
      expect(
        volume.rawValueFor('pectoralis_major_right'),
        closeTo(1920, 0.0001),
      );
      expect(volume.scoreFor('pectoralis_major_left'), closeTo(1, 0.0001));

      final fatigue = heatmaps.heatmapFor(AnatomyTrainingHeatmapKind.fatigue);
      expect(fatigue.scoreFor('pectoralis_major_right'), closeTo(1, 0.0001));
      expect(fatigue.scoreFor('serratus_anterior_right'), closeTo(0.65, 0.001));
    });

    test('weights pain and low RIR higher in the fatigue heatmap only', () {
      final catalog = loadTestExerciseCatalog();
      final now = DateTime.utc(2026, 7, 21, 12);

      final heatmaps = buildAnatomyTrainingHeatmaps(
        catalog: catalog,
        performances: [
          _performance(
            exerciseId: 'barbell_bench_press',
            performedAt: now,
            repetitions: 10,
            loadKilograms: 10,
            rir: 4,
          ),
          _performance(
            exerciseId: 'dumbbell_lateral_raise',
            performedAt: now,
            repetitions: 10,
            loadKilograms: 10,
            rir: 0,
            result: SetResult.pain,
          ),
        ],
        now: now,
      );

      final fatigue = heatmaps.heatmapFor(AnatomyTrainingHeatmapKind.fatigue);
      final volume = heatmaps.heatmapFor(
        AnatomyTrainingHeatmapKind.weeklyVolume,
      );

      expect(
        fatigue.rawValueFor('deltoid_lateral_right'),
        greaterThan(fatigue.rawValueFor('pectoralis_major_right')),
      );
      expect(
        volume.rawValueFor('deltoid_lateral_right'),
        volume.rawValueFor('pectoralis_major_right'),
      );
    });

    test('ignores old, future, planned, cancelled, and unmapped evidence', () {
      final catalog = loadTestExerciseCatalog();
      final now = DateTime.utc(2026, 7, 21, 12);

      final heatmaps = buildAnatomyTrainingHeatmaps(
        catalog: catalog,
        performances: [
          _performance(
            exerciseId: 'unknown_exercise',
            performedAt: now,
            repetitions: 8,
            loadKilograms: 60,
          ),
          _performance(
            exerciseId: 'barbell_bench_press',
            performedAt: now.subtract(const Duration(days: 8)),
            repetitions: 8,
            loadKilograms: 60,
          ),
          _performance(
            exerciseId: 'barbell_back_squat',
            performedAt: now.add(const Duration(minutes: 1)),
            repetitions: 8,
            loadKilograms: 60,
          ),
          _performance(
            exerciseId: 'barbell_bench_press',
            performedAt: now,
            repetitions: 8,
            loadKilograms: 60,
            sessionLifecycle: WorkoutLifecycle.planned,
          ),
          _performance(
            exerciseId: 'barbell_back_squat',
            performedAt: now,
            repetitions: 8,
            loadKilograms: 60,
            sessionLifecycle: WorkoutLifecycle.cancelled,
          ),
        ],
        now: now,
      );

      expect(heatmaps.evidenceSetCount, 0);
      expect(heatmaps.ignoredExerciseIds, {'unknown_exercise'});
      expect(heatmaps.isEmpty, isTrue);
    });

    test(
      'returns empty heatmaps for empty evidence and rejects invalid window',
      () {
        final catalog = loadTestExerciseCatalog();
        final now = DateTime.utc(2026, 7, 21, 12);

        final empty = buildAnatomyTrainingHeatmaps(
          catalog: catalog,
          performances: const [],
          now: now,
        );

        expect(empty.evidenceSetCount, 0);
        expect(empty.isEmpty, isTrue);
        expect(
          empty.heatmapFor(AnatomyTrainingHeatmapKind.fatigue).scores,
          isEmpty,
        );

        expect(
          () => buildAnatomyTrainingHeatmaps(
            catalog: catalog,
            performances: const [],
            now: now,
            window: Duration.zero,
          ),
          throwsArgumentError,
        );
      },
    );
  });
}

ExerciseSetPerformanceRecord _performance({
  required String exerciseId,
  required DateTime performedAt,
  required int repetitions,
  required double loadKilograms,
  int? rir,
  SetResult? result,
  WorkoutLifecycle sessionLifecycle = WorkoutLifecycle.completed,
}) {
  final uniqueSuffix =
      '${exerciseId}_${performedAt.microsecondsSinceEpoch}_${sessionLifecycle.name}';
  return ExerciseSetPerformanceRecord(
    sessionId: 'session_$uniqueSuffix',
    sessionSetId: 'set_$uniqueSuffix',
    exerciseId: exerciseId,
    setOrder: 0,
    sessionLifecycle: sessionLifecycle,
    sessionCreatedAt: performedAt,
    sessionStartedAt: performedAt,
    log: ActualSetLogRecord(
      id: 'log_$uniqueSuffix',
      sessionSetId: 'set_$uniqueSuffix',
      revision: 1,
      repetitions: repetitions,
      loadKilograms: loadKilograms,
      rir: rir,
      result: result,
      recordedAt: performedAt,
    ),
  );
}
