import 'dart:math' as math;

import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';

const anatomyTrainingHeatmapRuleSetVersion = 'anatomy_training_heatmaps.v1';

const defaultAnatomyTrainingHeatmapWindow = Duration(days: 7);

enum AnatomyTrainingHeatmapKind { trainedMuscle, weeklyVolume, fatigue }

final class AnatomyTrainingHeatmapSet {
  AnatomyTrainingHeatmapSet({
    required this.ruleSetVersion,
    required this.generatedAt,
    required this.windowStart,
    required this.windowEnd,
    required this.evidenceSetCount,
    required Map<AnatomyTrainingHeatmapKind, AnatomyTrainingHeatmap> heatmaps,
    Set<String> ignoredExerciseIds = const <String>{},
  }) : heatmaps = Map.unmodifiable(heatmaps),
       ignoredExerciseIds = Set.unmodifiable(ignoredExerciseIds);

  final String ruleSetVersion;
  final DateTime generatedAt;
  final DateTime windowStart;
  final DateTime windowEnd;
  final int evidenceSetCount;
  final Map<AnatomyTrainingHeatmapKind, AnatomyTrainingHeatmap> heatmaps;
  final Set<String> ignoredExerciseIds;

  AnatomyTrainingHeatmap heatmapFor(AnatomyTrainingHeatmapKind kind) {
    return heatmaps[kind] ??
        AnatomyTrainingHeatmap(kind: kind, entries: const []);
  }

  bool get isEmpty => heatmaps.values.every((heatmap) => heatmap.isEmpty);
}

final class AnatomyTrainingHeatmap {
  AnatomyTrainingHeatmap({
    required this.kind,
    required List<AnatomyTrainingHeatmapEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final AnatomyTrainingHeatmapKind kind;
  final List<AnatomyTrainingHeatmapEntry> entries;

  bool get isEmpty => entries.isEmpty;

  Map<String, double> get scores => Map.unmodifiable({
    for (final entry in entries) entry.regionId: entry.score,
  });

  AnatomyTrainingHeatmapEntry? get strongestEntry =>
      entries.isEmpty ? null : entries.first;

  double scoreFor(String regionId) {
    for (final entry in entries) {
      if (entry.regionId == regionId) {
        return entry.score;
      }
    }
    return 0;
  }

  double rawValueFor(String regionId) {
    for (final entry in entries) {
      if (entry.regionId == regionId) {
        return entry.rawValue;
      }
    }
    return 0;
  }
}

final class AnatomyTrainingHeatmapEntry {
  const AnatomyTrainingHeatmapEntry({
    required this.regionId,
    required this.score,
    required this.rawValue,
  });

  final String regionId;

  /// Normalized score in the renderer heatmap range `0.0..1.0`.
  final double score;

  /// Unnormalized evidence value used for ranking and audits.
  final double rawValue;
}

AnatomyTrainingHeatmapSet buildAnatomyTrainingHeatmaps({
  required ExerciseCatalog catalog,
  required Iterable<ExerciseSetPerformanceRecord> performances,
  required DateTime now,
  Duration window = defaultAnatomyTrainingHeatmapWindow,
}) {
  if (window <= Duration.zero) {
    throw ArgumentError.value(window, 'window', 'Window must be positive.');
  }

  final windowEnd = now.toUtc();
  final windowStart = windowEnd.subtract(window);
  final trainedTotals = <String, double>{};
  final volumeTotals = <String, double>{};
  final fatigueTotals = <String, double>{};
  final ignoredExerciseIds = <String>{};
  var evidenceSetCount = 0;

  for (final performance in performances) {
    final performedAt = performance.performedAt.toUtc();
    if (performedAt.isBefore(windowStart) || performedAt.isAfter(windowEnd)) {
      continue;
    }
    if (!_countsForTrainingHeatmaps(performance.sessionLifecycle)) {
      continue;
    }

    final exercise = catalog.exerciseById(performance.exerciseId);
    if (exercise == null) {
      ignoredExerciseIds.add(performance.exerciseId);
      continue;
    }

    final roleWeights = _roleWeightsFor(exercise.muscleMapping);
    if (roleWeights.isEmpty) {
      continue;
    }

    final trainedUnits = _trainedSetUnits(performance.log);
    final volumeUnits = _weeklyVolumeUnits(performance.log);
    final fatigueUnits = _fatigueUnits(
      log: performance.log,
      performedAt: performedAt,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );

    if (trainedUnits <= 0 && volumeUnits <= 0 && fatigueUnits <= 0) {
      continue;
    }

    evidenceSetCount += 1;
    for (final entry in roleWeights.entries) {
      _addWeightedTotal(trainedTotals, entry.key, trainedUnits * entry.value);
      _addWeightedTotal(volumeTotals, entry.key, volumeUnits * entry.value);
      _addWeightedTotal(fatigueTotals, entry.key, fatigueUnits * entry.value);
    }
  }

  return AnatomyTrainingHeatmapSet(
    ruleSetVersion: anatomyTrainingHeatmapRuleSetVersion,
    generatedAt: windowEnd,
    windowStart: windowStart,
    windowEnd: windowEnd,
    evidenceSetCount: evidenceSetCount,
    ignoredExerciseIds: ignoredExerciseIds,
    heatmaps: {
      AnatomyTrainingHeatmapKind.trainedMuscle: _normalizedHeatmap(
        AnatomyTrainingHeatmapKind.trainedMuscle,
        trainedTotals,
      ),
      AnatomyTrainingHeatmapKind.weeklyVolume: _normalizedHeatmap(
        AnatomyTrainingHeatmapKind.weeklyVolume,
        volumeTotals,
      ),
      AnatomyTrainingHeatmapKind.fatigue: _normalizedHeatmap(
        AnatomyTrainingHeatmapKind.fatigue,
        fatigueTotals,
      ),
    },
  );
}

bool _countsForTrainingHeatmaps(WorkoutLifecycle lifecycle) {
  return switch (lifecycle) {
    WorkoutLifecycle.inProgress || WorkoutLifecycle.completed => true,
    WorkoutLifecycle.planned || WorkoutLifecycle.cancelled => false,
  };
}

Map<String, double> _roleWeightsFor(ExerciseMuscleMapping mapping) {
  final weights = <String, double>{};
  void addAll(Iterable<String> regionIds, double weight) {
    for (final regionId in regionIds) {
      weights.update(
        regionId,
        (current) => math.max(current, weight),
        ifAbsent: () => weight,
      );
    }
  }

  addAll(mapping.primaryRegionIds, 1);
  addAll(mapping.secondaryRegionIds, 0.65);
  addAll(mapping.stabilizerRegionIds, 0.35);
  return weights;
}

double _trainedSetUnits(ActualSetLogRecord log) {
  final repetitions = log.repetitions ?? 0;
  final loadKilograms = log.loadKilograms ?? 0;
  if (repetitions > 0) {
    return 1;
  }
  if (loadKilograms > 0) {
    return 0.75;
  }

  return switch (log.result) {
    SetResult.strengthLimitation ||
    SetResult.techniqueLimitation ||
    SetResult.pain => 1,
    SetResult.timeLimitation ||
    SetResult.equipmentLimitation ||
    SetResult.externalInterruption => 0.25,
    null => 0,
  };
}

double _weeklyVolumeUnits(ActualSetLogRecord log) {
  final repetitions = log.repetitions;
  if (repetitions == null || repetitions <= 0) {
    return 0;
  }

  final loadKilograms = log.loadKilograms;
  if (loadKilograms == null || loadKilograms <= 0) {
    return repetitions.toDouble();
  }
  return repetitions * loadKilograms;
}

double _fatigueUnits({
  required ActualSetLogRecord log,
  required DateTime performedAt,
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final baseUnits = _trainedSetUnits(log);
  if (baseUnits <= 0) {
    return 0;
  }

  final outcomeMultiplier = switch (log.result) {
    SetResult.strengthLimitation => 1.25,
    SetResult.techniqueLimitation => 1.15,
    SetResult.pain => 1.50,
    SetResult.timeLimitation ||
    SetResult.equipmentLimitation ||
    SetResult.externalInterruption => 0.50,
    null => 1.0,
  };
  final rirMultiplier = switch (log.rir) {
    final rir? when rir <= 0 => 1.30,
    1 => 1.20,
    2 => 1.10,
    _ => 1.0,
  };
  final recencyMultiplier = _recencyMultiplier(
    performedAt: performedAt,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );

  return baseUnits * outcomeMultiplier * rirMultiplier * recencyMultiplier;
}

double _recencyMultiplier({
  required DateTime performedAt,
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final windowMilliseconds = windowEnd.difference(windowStart).inMilliseconds;
  if (windowMilliseconds <= 0) {
    return 1;
  }

  final ageMilliseconds = windowEnd
      .difference(performedAt)
      .inMilliseconds
      .clamp(0, windowMilliseconds);
  final ageFraction = ageMilliseconds / windowMilliseconds;
  return 1 - 0.65 * ageFraction;
}

void _addWeightedTotal(
  Map<String, double> totals,
  String regionId,
  double value,
) {
  if (value <= 0) {
    return;
  }
  totals.update(regionId, (current) => current + value, ifAbsent: () => value);
}

AnatomyTrainingHeatmap _normalizedHeatmap(
  AnatomyTrainingHeatmapKind kind,
  Map<String, double> totals,
) {
  if (totals.isEmpty) {
    return AnatomyTrainingHeatmap(kind: kind, entries: const []);
  }

  final maxRawValue = totals.values.reduce(math.max);
  if (maxRawValue <= 0) {
    return AnatomyTrainingHeatmap(kind: kind, entries: const []);
  }

  final entries =
      totals.entries
          .map(
            (entry) => AnatomyTrainingHeatmapEntry(
              regionId: entry.key,
              score: (entry.value / maxRawValue).clamp(0, 1).toDouble(),
              rawValue: entry.value,
            ),
          )
          .toList(growable: false)
        ..sort((left, right) {
          final scoreComparison = right.score.compareTo(left.score);
          if (scoreComparison != 0) {
            return scoreComparison;
          }
          return left.regionId.compareTo(right.regionId);
        });

  return AnatomyTrainingHeatmap(kind: kind, entries: entries);
}
