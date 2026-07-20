import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_interaction_controller.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizes camera movement before native sync', () async {
    const channel = MethodChannel('test/anatomy_interaction_camera');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'setCameraPose') {
        return <String, Object?>{
          'yawDegrees': _argument<double>(call, 'yawDegrees'),
          'pitchDegrees': _argument<double>(call, 'pitchDegrees'),
          'zoom': _argument<double>(call, 'zoom'),
        };
      }
      if (call.method == 'setHeatmap') {
        return <String, Object?>{'heatmap': <String, double>{}};
      }
      if (call.method == 'selectRegion') {
        return <String, Object?>{'selectedRegionId': null};
      }
      fail('Unexpected method ${call.method}');
    });

    final controller = AnatomyInteractionController(
      bridge: AnatomyRendererBridge(channel: channel),
    );
    addTearDown(controller.dispose);

    controller.attachPlatformView(7);
    await pumpEventQueue();
    controller.rotateByDegrees(yawDelta: 720, pitchDelta: 100);
    controller.zoomByScale(10);
    await pumpEventQueue();

    expect(controller.cameraPose.yawDegrees, 0);
    expect(
      controller.cameraPose.pitchDegrees,
      AnatomyCameraPose.maxPitchDegrees,
    );
    expect(controller.cameraPose.zoom, AnatomyCameraPose.minZoom);
    expect(calls.where((call) => call.method == 'setCameraPose'), isNotEmpty);
  });

  test(
    'picks a preview muscle region when no platform view is attached',
    () async {
      final controller = AnatomyInteractionController();
      addTearDown(controller.dispose);

      controller.setHeatmap(const <String, double>{
        'quadriceps_left': 0.8,
        'hamstrings_right': 0.4,
      });
      await controller.pickAt(const Offset(95, 10), const Size(100, 100));

      expect(controller.selectedRegionId, 'hamstrings_right');
    },
  );

  test('syncs preview heatmap to an attached platform view', () async {
    const channel = MethodChannel('test/anatomy_interaction_heatmap');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'setCameraPose') {
        return <String, Object?>{
          'yawDegrees': _argument<double>(call, 'yawDegrees'),
          'pitchDegrees': _argument<double>(call, 'pitchDegrees'),
          'zoom': _argument<double>(call, 'zoom'),
        };
      }
      if (call.method == 'setHeatmap') {
        return <String, Object?>{
          'heatmap': _argument<Map<Object?, Object?>>(call, 'heatmap'),
        };
      }
      if (call.method == 'selectRegion') {
        return <String, Object?>{'selectedRegionId': null};
      }
      fail('Unexpected method ${call.method}');
    });

    final controller = AnatomyInteractionController(
      bridge: AnatomyRendererBridge(channel: channel),
    );
    addTearDown(controller.dispose);

    controller.attachPlatformView(11);
    await pumpEventQueue();
    controller.applyPreviewHeatmap();
    await pumpEventQueue();

    final heatmapCall = calls.lastWhere((call) => call.method == 'setHeatmap');
    final heatmap = _argument<Map<Object?, Object?>>(heatmapCall, 'heatmap');
    expect(heatmap['pectoralis_major_right'], 0.9);
    expect(heatmap['quadriceps_left'], 0.78);
  });
}

T _argument<T>(MethodCall call, String key) {
  final arguments = call.arguments as Map<Object?, Object?>;
  return arguments[key] as T;
}
