import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';

final anatomyTrainingHeatmapClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final anatomyTrainingHeatmapsProvider =
    FutureProvider<AnatomyTrainingHeatmapSet>((ref) async {
      final catalog = await ref.watch(exerciseCatalogProvider.future);
      final workoutRepository = ref.watch(workoutRepositoryProvider);
      final profileId = ref.watch(localProgramProfileIdProvider);
      final now = ref.watch(anatomyTrainingHeatmapClockProvider)().toUtc();
      final performances = await _completedSetPerformances(
        workoutRepository: workoutRepository,
        profileId: profileId,
      );

      return buildAnatomyTrainingHeatmaps(
        catalog: catalog,
        performances: performances,
        now: now,
      );
    });

Future<List<ExerciseSetPerformanceRecord>> _completedSetPerformances({
  required WorkoutRepository workoutRepository,
  required String profileId,
}) async {
  final sessions = await workoutRepository.getSessions(profileId);
  final performances = <ExerciseSetPerformanceRecord>[];

  for (final session in sessions) {
    if (session.lifecycle == WorkoutLifecycle.cancelled) {
      continue;
    }

    final sessionSets = await workoutRepository.getSessionSets(session.id);
    final performanceFutures = [
      for (final sessionSet in sessionSets)
        _performanceForSet(
          workoutRepository: workoutRepository,
          session: session,
          sessionSet: sessionSet,
        ),
    ];
    final sessionPerformances = await Future.wait(performanceFutures);
    performances.addAll(sessionPerformances.whereType());
  }

  return List.unmodifiable(performances);
}

Future<ExerciseSetPerformanceRecord?> _performanceForSet({
  required WorkoutRepository workoutRepository,
  required WorkoutSessionRecord session,
  required SessionSetRecord sessionSet,
}) async {
  if (sessionSet.lifecycle != SetLifecycle.completed) {
    return null;
  }

  final logs = await workoutRepository.getActualSetLogs(sessionSet.id);
  final latestLog = _latestLog(logs);
  if (latestLog == null) {
    return null;
  }

  return ExerciseSetPerformanceRecord(
    sessionId: session.id,
    sessionSetId: sessionSet.id,
    exerciseId: sessionSet.exerciseId,
    setOrder: sessionSet.setOrder,
    sessionLifecycle: session.lifecycle,
    sessionCreatedAt: session.createdAt,
    sessionScheduledAt: session.scheduledAt,
    sessionStartedAt: session.startedAt,
    log: latestLog,
  );
}

ActualSetLogRecord? _latestLog(List<ActualSetLogRecord> logs) {
  if (logs.isEmpty) {
    return null;
  }

  var latest = logs.first;
  for (final log in logs.skip(1)) {
    if (log.revision > latest.revision) {
      latest = log;
    }
  }
  return latest;
}
