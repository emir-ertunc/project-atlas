import 'package:flutter/services.dart';

enum RestNotificationScheduleStatus {
  scheduled,
  permissionDenied,
  unsupported,
  failed,
  skipped,
}

final class RestNotificationScheduleResult {
  const RestNotificationScheduleResult(this.status, {this.message});

  final RestNotificationScheduleStatus status;
  final String? message;

  bool get isScheduled => status == RestNotificationScheduleStatus.scheduled;
}

abstract interface class RestNotificationScheduler {
  Future<RestNotificationScheduleResult> scheduleRestTimerNotification({
    required DateTime endsAt,
    required String title,
    required String body,
  });

  Future<void> cancelRestTimerNotification();
}

final class MethodChannelRestNotificationScheduler
    implements RestNotificationScheduler {
  const MethodChannelRestNotificationScheduler({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : this._(channel);

  const MethodChannelRestNotificationScheduler._(this._channel);

  static const _channelName = 'project_atlas/rest_notifications';

  final MethodChannel _channel;

  @override
  Future<RestNotificationScheduleResult> scheduleRestTimerNotification({
    required DateTime endsAt,
    required String title,
    required String body,
  }) async {
    try {
      final rawResult = await _channel
          .invokeMapMethod<String, Object?>('scheduleRestTimerNotification', {
            'endsAtEpochMillis': endsAt.toUtc().millisecondsSinceEpoch,
            'title': title,
            'body': body,
          });
      return RestNotificationScheduleResult(
        _statusFromName(rawResult?['status'] as String?),
        message: rawResult?['message'] as String?,
      );
    } on MissingPluginException {
      return const RestNotificationScheduleResult(
        RestNotificationScheduleStatus.unsupported,
      );
    } on PlatformException catch (error) {
      return RestNotificationScheduleResult(
        RestNotificationScheduleStatus.failed,
        message: error.message,
      );
    }
  }

  @override
  Future<void> cancelRestTimerNotification() async {
    try {
      await _channel.invokeMethod<void>('cancelRestTimerNotification');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}

RestNotificationScheduleStatus _statusFromName(String? name) {
  for (final status in RestNotificationScheduleStatus.values) {
    if (status.name == name) {
      return status;
    }
  }

  return RestNotificationScheduleStatus.failed;
}
