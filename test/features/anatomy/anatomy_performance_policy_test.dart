import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_performance_policy.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';

void main() {
  test('defaults to the semantic fallback after the P2-07 threshold miss', () {
    final options = AnatomyPerformancePolicy.defaultOptions();

    expect(options.mode, AnatomyRendererMode.staticFallback);
    expect(options.lodTier, AnatomyLodTier.lod2);
    expect(options.usesPlatformView, isFalse);
    expect(
      options.fallbackReason,
      AnatomyRendererFallbackReason.assetNotBundled,
    );
    expect(
      options.missedThresholds,
      containsAll(<String>[
        'launch_wait_time',
        'frame_sample_count',
        'p95_frame_time',
        'janky_frame_ratio',
      ]),
    );
  });

  test('uses interactive lite only when assets and metrics are acceptable', () {
    final options = AnatomyPerformancePolicy.decide(
      assetBundled: true,
      snapshot: const AnatomyPerformanceSnapshot(
        launchWaitTimeMs: 1200,
        frameCount: 120,
        p95FrameMs: 16.2,
        jankyFrameCount: 2,
        totalPssKb: 90000,
      ),
      thresholds: AnatomyPerformancePolicy.midRangeThresholds,
    );

    expect(options.mode, AnatomyRendererMode.interactiveLite);
    expect(options.lodTier, AnatomyLodTier.lod2);
    expect(options.usesPlatformView, isTrue);
    expect(options.fallbackReason, AnatomyRendererFallbackReason.none);
    expect(options.missedThresholds, isEmpty);
  });

  test('allows an explicit interactive lite override for profiling', () {
    final options = AnatomyPerformancePolicy.decide(
      assetBundled: false,
      snapshot: AnatomyPerformancePolicy.latestPhysicalDeviceSnapshot,
      thresholds: AnatomyPerformancePolicy.midRangeThresholds,
      rendererModeOverride: AnatomyRendererMode.interactiveLite.wireName,
    );

    expect(options.mode, AnatomyRendererMode.interactiveLite);
    expect(options.lodTier, AnatomyLodTier.lod2);
    expect(options.usesPlatformView, isTrue);
    expect(
      options.fallbackReason,
      AnatomyRendererFallbackReason.manualOverride,
    );
    expect(options.missedThresholds, isNotEmpty);
    expect(options.toCreationParams(), containsPair('lodTier', 'lod2'));
    expect(
      options.toCreationParams(),
      containsPair('renderMode', 'interactive_lite'),
    );
  });
}
