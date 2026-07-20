import 'package:flutter/foundation.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';

@immutable
class AnatomyPerformanceSnapshot {
  const AnatomyPerformanceSnapshot({
    required this.launchWaitTimeMs,
    required this.frameCount,
    required this.p95FrameMs,
    required this.jankyFrameCount,
    required this.totalPssKb,
  });

  final int launchWaitTimeMs;
  final int frameCount;
  final double p95FrameMs;
  final int jankyFrameCount;
  final int totalPssKb;

  double get jankyFrameRatio {
    if (frameCount <= 0) {
      return 1;
    }
    return jankyFrameCount / frameCount;
  }
}

@immutable
class AnatomyPerformanceThresholds {
  const AnatomyPerformanceThresholds({
    required this.maxLaunchWaitTimeMs,
    required this.minFrameSampleCount,
    required this.maxP95FrameMs,
    required this.maxJankyFrameRatio,
    required this.maxTotalPssKb,
  });

  final int maxLaunchWaitTimeMs;
  final int minFrameSampleCount;
  final double maxP95FrameMs;
  final double maxJankyFrameRatio;
  final int maxTotalPssKb;

  List<String> missedBy(AnatomyPerformanceSnapshot snapshot) {
    final missed = <String>[];
    if (snapshot.launchWaitTimeMs > maxLaunchWaitTimeMs) {
      missed.add('launch_wait_time');
    }
    if (snapshot.frameCount < minFrameSampleCount) {
      missed.add('frame_sample_count');
    }
    if (snapshot.p95FrameMs > maxP95FrameMs) {
      missed.add('p95_frame_time');
    }
    if (snapshot.jankyFrameRatio > maxJankyFrameRatio) {
      missed.add('janky_frame_ratio');
    }
    if (snapshot.totalPssKb > maxTotalPssKb) {
      missed.add('total_pss');
    }
    return List<String>.unmodifiable(missed);
  }
}

enum AnatomyRendererFallbackReason {
  none('none'),
  assetNotBundled('asset_not_bundled'),
  performanceThresholdMissed('performance_threshold_missed'),
  manualOverride('manual_override');

  const AnatomyRendererFallbackReason(this.wireName);

  final String wireName;
}

@immutable
class AnatomyRendererOptions {
  const AnatomyRendererOptions({
    required this.mode,
    required this.lodTier,
    required this.fallbackReason,
    required this.missedThresholds,
  });

  final AnatomyRendererMode mode;
  final AnatomyLodTier lodTier;
  final AnatomyRendererFallbackReason fallbackReason;
  final List<String> missedThresholds;

  bool get usesPlatformView => mode == AnatomyRendererMode.interactiveLite;

  Map<String, Object?> toCreationParams() {
    return <String, Object?>{
      'renderMode': mode.wireName,
      'lodTier': lodTier.wireName,
      'performanceFallbackReason': fallbackReason.wireName,
      'missedPerformanceThresholds': missedThresholds,
    };
  }
}

abstract final class AnatomyPerformancePolicy {
  static const latestPhysicalDeviceSnapshot = AnatomyPerformanceSnapshot(
    launchWaitTimeMs: 3027,
    frameCount: 1,
    p95FrameMs: 150,
    jankyFrameCount: 1,
    totalPssKb: 137077,
  );

  static const midRangeThresholds = AnatomyPerformanceThresholds(
    maxLaunchWaitTimeMs: 2500,
    minFrameSampleCount: 30,
    maxP95FrameMs: 33.34,
    maxJankyFrameRatio: 0.05,
    maxTotalPssKb: 180000,
  );

  static const _rendererModeOverride = String.fromEnvironment(
    'PROJECT_ATLAS_ANATOMY_RENDERER_MODE',
  );

  static AnatomyRendererOptions defaultOptions({bool assetBundled = false}) {
    return decide(
      assetBundled: assetBundled,
      snapshot: latestPhysicalDeviceSnapshot,
      thresholds: midRangeThresholds,
      rendererModeOverride: _rendererModeOverride,
    );
  }

  static AnatomyRendererOptions decide({
    required bool assetBundled,
    required AnatomyPerformanceSnapshot snapshot,
    required AnatomyPerformanceThresholds thresholds,
    String rendererModeOverride = '',
  }) {
    final missedThresholds = thresholds.missedBy(snapshot);
    final overrideMode = AnatomyRendererMode.fromWireName(rendererModeOverride);

    if (overrideMode == AnatomyRendererMode.interactiveLite) {
      return AnatomyRendererOptions(
        mode: AnatomyRendererMode.interactiveLite,
        lodTier: AnatomyLodTier.lod2,
        fallbackReason: AnatomyRendererFallbackReason.manualOverride,
        missedThresholds: missedThresholds,
      );
    }

    if (!assetBundled) {
      return AnatomyRendererOptions(
        mode: AnatomyRendererMode.staticFallback,
        lodTier: AnatomyLodTier.lod2,
        fallbackReason: AnatomyRendererFallbackReason.assetNotBundled,
        missedThresholds: missedThresholds,
      );
    }

    if (missedThresholds.isNotEmpty) {
      return AnatomyRendererOptions(
        mode: AnatomyRendererMode.staticFallback,
        lodTier: AnatomyLodTier.lod2,
        fallbackReason:
            AnatomyRendererFallbackReason.performanceThresholdMissed,
        missedThresholds: missedThresholds,
      );
    }

    return const AnatomyRendererOptions(
      mode: AnatomyRendererMode.interactiveLite,
      lodTier: AnatomyLodTier.lod2,
      fallbackReason: AnatomyRendererFallbackReason.none,
      missedThresholds: <String>[],
    );
  }
}
