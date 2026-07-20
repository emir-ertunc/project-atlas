import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'parses Android renderer capabilities from the platform channel',
    () async {
      const channel = MethodChannel('test/anatomy_renderer_bridge');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getCapabilities');
        return <String, Object?>{
          'platform': 'android',
          'backend': 'filament',
          'viewType': AnatomyRendererBridge.viewType,
          'supportsGlb': true,
          'supportsOrbitCamera': true,
          'supportsZoom': true,
          'supportsPicking': true,
          'supportsHeatmap': true,
          'assetBundled': false,
          'requiredNodeExtras': AnatomyRendererBridge.requiredNodeExtras,
          'supportsLod': true,
          'supportedLodTiers': <String>['lod2'],
          'defaultLodTier': 'lod2',
          'defaultRenderMode': 'interactive_lite',
          'renderLoopMode': 'dirty_frame',
        };
      });

      final bridge = AnatomyRendererBridge(channel: channel);
      final capabilities = await bridge.getCapabilities();

      expect(capabilities.platform, 'android');
      expect(capabilities.backend, 'filament');
      expect(capabilities.viewType, AnatomyRendererBridge.viewType);
      expect(capabilities.supportsGlb, isTrue);
      expect(capabilities.supportsOrbitCamera, isTrue);
      expect(capabilities.supportsZoom, isTrue);
      expect(capabilities.supportsPicking, isTrue);
      expect(capabilities.supportsHeatmap, isTrue);
      expect(capabilities.assetBundled, isFalse);
      expect(
        capabilities.requiredNodeExtras,
        AnatomyRendererBridge.requiredNodeExtras,
      );
      expect(capabilities.supportsLod, isTrue);
      expect(capabilities.supportedLodTiers, <AnatomyLodTier>[
        AnatomyLodTier.lod2,
      ]);
      expect(capabilities.defaultLodTier, AnatomyLodTier.lod2);
      expect(
        capabilities.defaultRenderMode,
        AnatomyRendererMode.interactiveLite,
      );
      expect(capabilities.renderLoopMode, 'dirty_frame');
    },
  );

  test(
    'falls back to unavailable capabilities when no platform handler exists',
    () async {
      final bridge = AnatomyRendererBridge(
        channel: const MethodChannel('test/missing_anatomy_renderer_bridge'),
      );

      final capabilities = await bridge.getCapabilities();

      expect(capabilities.platform, 'unavailable');
      expect(capabilities.backend, 'unavailable');
      expect(capabilities.supportsGlb, isFalse);
      expect(capabilities.supportsOrbitCamera, isFalse);
      expect(capabilities.supportsZoom, isFalse);
      expect(capabilities.supportsPicking, isFalse);
      expect(capabilities.supportsHeatmap, isFalse);
      expect(capabilities.assetBundled, isFalse);
      expect(capabilities.supportsLod, isFalse);
      expect(capabilities.supportedLodTiers, isEmpty);
      expect(capabilities.defaultLodTier, AnatomyLodTier.lod2);
      expect(
        capabilities.defaultRenderMode,
        AnatomyRendererMode.staticFallback,
      );
      expect(capabilities.renderLoopMode, 'unavailable');
    },
  );

  test('sends camera, heatmap, selection, and picking commands', () async {
    const channel = MethodChannel('test/anatomy_renderer_interactions');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'setCameraPose':
          return <String, Object?>{
            'yawDegrees': _argument<double>(call, 'yawDegrees'),
            'pitchDegrees': _argument<double>(call, 'pitchDegrees'),
            'zoom': _argument<double>(call, 'zoom'),
          };
        case 'setHeatmap':
          return <String, Object?>{
            'heatmap': _argument<Map<Object?, Object?>>(call, 'heatmap'),
          };
        case 'selectRegion':
          return <String, Object?>{
            'selectedRegionId': _argument<String?>(call, 'regionId'),
          };
        case 'pick':
          return <String, Object?>{
            'hit': true,
            'regionId': 'quadriceps_left',
            'normalizedX': _argument<double>(call, 'normalizedX'),
            'normalizedY': _argument<double>(call, 'normalizedY'),
          };
        case 'getState':
          return <String, Object?>{
            'viewId': _argument<int>(call, 'viewId'),
            'selectedRegionId': 'quadriceps_left',
          };
      }
      fail('Unexpected method ${call.method}');
    });

    final bridge = AnatomyRendererBridge(channel: channel);

    final pose = await bridge.setCameraPose(
      viewId: 4,
      pose: const AnatomyCameraPose(
        yawDegrees: 540,
        pitchDegrees: 90,
        zoom: 0.8,
      ),
    );
    final heatmap = await bridge.setHeatmap(
      viewId: 4,
      heatmap: const <String, double>{
        ' quadriceps_left ': 1.4,
        'hamstrings_right': -0.2,
      },
    );
    final selectedRegion = await bridge.selectRegion(
      viewId: 4,
      regionId: ' quadriceps_left ',
    );
    final pick = await bridge.pick(
      viewId: 4,
      normalizedX: 1.4,
      normalizedY: -1,
    );
    final state = await bridge.getState(viewId: 4);

    expect(pose.yawDegrees, 180);
    expect(pose.pitchDegrees, AnatomyCameraPose.maxPitchDegrees);
    expect(pose.zoom, AnatomyCameraPose.minZoom);
    expect(heatmap, <String, double>{
      'quadriceps_left': 1,
      'hamstrings_right': 0,
    });
    expect(selectedRegion, 'quadriceps_left');
    expect(pick.hit, isTrue);
    expect(pick.regionId, 'quadriceps_left');
    expect(pick.normalizedX, 1);
    expect(pick.normalizedY, 0);
    expect(state['viewId'], 4);
    expect(calls.map((call) => call.method), <String>[
      'setCameraPose',
      'setHeatmap',
      'selectRegion',
      'pick',
      'getState',
    ]);
  });
}

T _argument<T>(MethodCall call, String key) {
  final arguments = call.arguments as Map<Object?, Object?>;
  return arguments[key] as T;
}
