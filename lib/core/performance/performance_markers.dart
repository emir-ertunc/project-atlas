import 'package:flutter/foundation.dart';

final Stopwatch _performanceStopwatch = Stopwatch()..start();

abstract final class PerformanceMarkers {
  static const enabled = bool.fromEnvironment('PROJECT_ATLAS_PERF_LOGS');
  static const tag = 'PROJECT_ATLAS_PERF';

  static void mark(String name) {
    if (!enabled) {
      return;
    }

    debugPrint(
      '$tag $name elapsed_ms=${_performanceStopwatch.elapsedMilliseconds}',
    );
  }
}
