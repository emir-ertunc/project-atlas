import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/today/application/rest_timer_controller.dart';
import 'package:project_atlas/features/today/platform/rest_notification_scheduler.dart';

void main() {
  late DateTime now;
  late _FakeRestNotificationScheduler scheduler;
  late ProviderContainer container;

  setUp(() {
    now = DateTime.utc(2026, 7, 20, 10);
    scheduler = _FakeRestNotificationScheduler();
    container = ProviderContainer(
      overrides: [
        restTimerClockProvider.overrideWithValue(() => now),
        restNotificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('starts a rest timer and schedules a background notification', () async {
    final result = await container
        .read(restTimerControllerProvider.notifier)
        .startRestTimer(
          sourceSessionSetId: 'set-1',
          exerciseName: 'Bench Press',
          setNumber: 1,
          durationSeconds: 180,
          notificationTitle: 'Rest complete',
          notificationBody: 'Time for your next set.',
        );

    final state = container.read(restTimerControllerProvider);

    expect(result.status, RestNotificationScheduleStatus.scheduled);
    expect(state.phase, RestTimerPhase.running);
    expect(state.timer?.sourceSessionSetId, 'set-1');
    expect(state.timer?.remainingSeconds(now), 180);
    expect(scheduler.scheduledEndsAt, now.add(const Duration(seconds: 180)));
    expect(scheduler.cancelCount, 1);

    now = now.add(const Duration(seconds: 180));
    container
        .read(restTimerControllerProvider.notifier)
        .markRestTimerCompleted();

    expect(
      container.read(restTimerControllerProvider).phase,
      RestTimerPhase.completed,
    );
  });

  test('skips zero-duration rest timers', () async {
    final result = await container
        .read(restTimerControllerProvider.notifier)
        .startRestTimer(
          sourceSessionSetId: 'set-1',
          exerciseName: 'Bench Press',
          setNumber: 1,
          durationSeconds: 0,
          notificationTitle: 'Rest complete',
          notificationBody: 'Time for your next set.',
        );

    expect(result.status, RestNotificationScheduleStatus.skipped);
    expect(
      container.read(restTimerControllerProvider).phase,
      RestTimerPhase.idle,
    );
    expect(scheduler.scheduledEndsAt, isNull);
    expect(scheduler.cancelCount, 1);
  });
}

final class _FakeRestNotificationScheduler
    implements RestNotificationScheduler {
  DateTime? scheduledEndsAt;
  int cancelCount = 0;

  @override
  Future<void> cancelRestTimerNotification() async {
    cancelCount += 1;
  }

  @override
  Future<RestNotificationScheduleResult> scheduleRestTimerNotification({
    required DateTime endsAt,
    required String title,
    required String body,
  }) async {
    scheduledEndsAt = endsAt;
    return const RestNotificationScheduleResult(
      RestNotificationScheduleStatus.scheduled,
    );
  }
}
