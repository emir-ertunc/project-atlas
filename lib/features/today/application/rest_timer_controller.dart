import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/features/today/platform/rest_notification_scheduler.dart';

final restTimerClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final restNotificationSchedulerProvider = Provider<RestNotificationScheduler>(
  (ref) => const MethodChannelRestNotificationScheduler(),
);

final restTimerControllerProvider =
    NotifierProvider<RestTimerController, RestTimerState>(
      RestTimerController.new,
    );

enum RestTimerPhase { idle, running, completed }

final class RestTimerState {
  const RestTimerState({
    this.timer,
    this.phase = RestTimerPhase.idle,
    this.notificationResult,
  });

  final ActiveRestTimer? timer;
  final RestTimerPhase phase;
  final RestNotificationScheduleResult? notificationResult;

  bool get hasTimer => timer != null && phase != RestTimerPhase.idle;

  RestTimerState copyWith({
    ActiveRestTimer? timer,
    RestTimerPhase? phase,
    RestNotificationScheduleResult? notificationResult,
    bool clearNotificationResult = false,
  }) {
    return RestTimerState(
      timer: timer ?? this.timer,
      phase: phase ?? this.phase,
      notificationResult: clearNotificationResult
          ? null
          : notificationResult ?? this.notificationResult,
    );
  }
}

final class ActiveRestTimer {
  const ActiveRestTimer({
    required this.id,
    required this.sourceSessionSetId,
    required this.exerciseName,
    required this.setNumber,
    required this.durationSeconds,
    required this.startedAt,
    required this.endsAt,
  });

  final String id;
  final String sourceSessionSetId;
  final String exerciseName;
  final int setNumber;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime endsAt;

  int remainingSeconds(DateTime now) {
    final remainingMillis = endsAt.difference(now.toUtc()).inMilliseconds;
    if (remainingMillis <= 0) {
      return 0;
    }

    return (remainingMillis / Duration.millisecondsPerSecond).ceil();
  }
}

final class RestTimerController extends Notifier<RestTimerState> {
  @override
  RestTimerState build() => const RestTimerState();

  Future<RestNotificationScheduleResult> startRestTimer({
    required String sourceSessionSetId,
    required String exerciseName,
    required int setNumber,
    required int durationSeconds,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (durationSeconds <= 0) {
      await cancelRestTimer();
      return const RestNotificationScheduleResult(
        RestNotificationScheduleStatus.skipped,
      );
    }

    final now = ref.read(restTimerClockProvider)().toUtc();
    final normalizedDuration = math.min(durationSeconds, 1200);
    final timer = ActiveRestTimer(
      id: '$sourceSessionSetId-${now.microsecondsSinceEpoch}',
      sourceSessionSetId: sourceSessionSetId,
      exerciseName: exerciseName,
      setNumber: setNumber,
      durationSeconds: normalizedDuration,
      startedAt: now,
      endsAt: now.add(Duration(seconds: normalizedDuration)),
    );

    await ref
        .read(restNotificationSchedulerProvider)
        .cancelRestTimerNotification();
    state = RestTimerState(timer: timer, phase: RestTimerPhase.running);

    final result = await ref
        .read(restNotificationSchedulerProvider)
        .scheduleRestTimerNotification(
          endsAt: timer.endsAt,
          title: notificationTitle,
          body: notificationBody,
        );

    final currentTimer = state.timer;
    if (currentTimer?.id == timer.id && state.phase == RestTimerPhase.running) {
      state = state.copyWith(notificationResult: result);
    }
    return result;
  }

  void markRestTimerCompleted() {
    final timer = state.timer;
    if (timer == null || state.phase != RestTimerPhase.running) {
      return;
    }

    final now = ref.read(restTimerClockProvider)().toUtc();
    if (timer.remainingSeconds(now) > 0) {
      return;
    }

    state = state.copyWith(phase: RestTimerPhase.completed);
  }

  Future<void> cancelRestTimer() async {
    await ref
        .read(restNotificationSchedulerProvider)
        .cancelRestTimerNotification();
    state = const RestTimerState();
  }
}
