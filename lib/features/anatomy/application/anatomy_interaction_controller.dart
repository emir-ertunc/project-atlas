import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:project_atlas/features/anatomy/platform/anatomy_renderer_bridge.dart';

class AnatomyInteractionController extends ChangeNotifier {
  AnatomyInteractionController({AnatomyRendererBridge? bridge})
    : _bridge = bridge ?? AnatomyRendererBridge();

  static const previewRegionIds = <String>[
    'pectoralis_major_right',
    'pectoralis_major_left',
    'deltoid_anterior_right',
    'deltoid_lateral_left',
    'rhomboids_right',
    'trapezius_left',
    'quadriceps_right',
    'quadriceps_left',
    'hamstrings_right',
    'hamstrings_left',
  ];

  static const previewHeatmap = <String, double>{
    'pectoralis_major_right': 0.90,
    'pectoralis_major_left': 0.84,
    'deltoid_anterior_right': 0.72,
    'rhomboids_right': 0.63,
    'quadriceps_left': 0.78,
    'hamstrings_right': 0.48,
  };

  static const _dragDegreesPerLogicalPixel = 0.35;

  final AnatomyRendererBridge _bridge;

  int? _viewId;
  AnatomyCameraPose _cameraPose = AnatomyCameraPose.initial;
  Map<String, double> _heatmap = const <String, double>{};
  String? _selectedRegionId;
  bool _disposed = false;

  int? get viewId => _viewId;

  AnatomyCameraPose get cameraPose => _cameraPose;

  Map<String, double> get heatmap => _heatmap;

  String? get selectedRegionId => _selectedRegionId;

  List<String> get pickableRegionIds {
    if (_heatmap.isEmpty) {
      return previewRegionIds;
    }
    return List<String>.unmodifiable(_heatmap.keys);
  }

  void attachPlatformView(int viewId) {
    _viewId = viewId;
    _safeNotifyListeners();
    unawaited(_syncPlatformState());
  }

  void rotateByDragDelta(Offset delta) {
    _cameraPose = _cameraPose
        .copyWith(
          yawDegrees:
              _cameraPose.yawDegrees + delta.dx * _dragDegreesPerLogicalPixel,
          pitchDegrees:
              _cameraPose.pitchDegrees - delta.dy * _dragDegreesPerLogicalPixel,
        )
        .normalized();
    _safeNotifyListeners();
    unawaited(_syncCameraPose());
  }

  void rotateByDegrees({required double yawDelta, required double pitchDelta}) {
    _cameraPose = _cameraPose
        .copyWith(
          yawDegrees: _cameraPose.yawDegrees + yawDelta,
          pitchDegrees: _cameraPose.pitchDegrees + pitchDelta,
        )
        .normalized();
    _safeNotifyListeners();
    unawaited(_syncCameraPose());
  }

  void zoomByScale(double scaleDelta) {
    if (scaleDelta <= 0) {
      return;
    }

    _cameraPose = _cameraPose
        .copyWith(zoom: _cameraPose.zoom / scaleDelta)
        .normalized();
    _safeNotifyListeners();
    unawaited(_syncCameraPose());
  }

  void resetCamera() {
    _cameraPose = AnatomyCameraPose.initial;
    _safeNotifyListeners();
    unawaited(_syncCameraPose());
  }

  void applyPreviewHeatmap() {
    setHeatmap(previewHeatmap);
  }

  void setHeatmap(Map<String, double> heatmap) {
    _heatmap = AnatomyRendererBridge.sanitizeHeatmap(heatmap);
    if (!_heatmap.containsKey(_selectedRegionId)) {
      _selectedRegionId = null;
    }
    _safeNotifyListeners();
    unawaited(_syncHeatmap());
  }

  void selectRegion(String? regionId) {
    _selectedRegionId = _normalizeRegionId(regionId);
    _safeNotifyListeners();
    unawaited(_syncSelectedRegion());
  }

  Future<void> pickAt(Offset localPosition, Size viewportSize) async {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      return;
    }

    final normalizedX = _clampUnit(localPosition.dx / viewportSize.width);
    final normalizedY = _clampUnit(localPosition.dy / viewportSize.height);
    final viewId = _viewId;

    if (viewId == null) {
      _selectedRegionId = _fallbackRegionFor(normalizedX);
      _safeNotifyListeners();
      return;
    }

    final result = await _bridge.pick(
      viewId: viewId,
      normalizedX: normalizedX,
      normalizedY: normalizedY,
    );
    if (_disposed) {
      return;
    }
    _selectedRegionId = result.hit ? result.regionId : null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _syncPlatformState() async {
    await _syncCameraPose();
    await _syncHeatmap();
    await _syncSelectedRegion();
  }

  Future<void> _syncCameraPose() async {
    final viewId = _viewId;
    if (viewId == null) {
      return;
    }

    final syncedPose = await _bridge.setCameraPose(
      viewId: viewId,
      pose: _cameraPose,
    );
    if (_disposed) {
      return;
    }
    _cameraPose = syncedPose.normalized();
    _safeNotifyListeners();
  }

  Future<void> _syncHeatmap() async {
    final viewId = _viewId;
    if (viewId == null) {
      return;
    }

    final syncedHeatmap = await _bridge.setHeatmap(
      viewId: viewId,
      heatmap: _heatmap,
    );
    if (_disposed) {
      return;
    }
    _heatmap = syncedHeatmap;
    _safeNotifyListeners();
  }

  Future<void> _syncSelectedRegion() async {
    final viewId = _viewId;
    if (viewId == null) {
      return;
    }

    final syncedRegionId = await _bridge.selectRegion(
      viewId: viewId,
      regionId: _selectedRegionId,
    );
    if (_disposed) {
      return;
    }
    _selectedRegionId = syncedRegionId;
    _safeNotifyListeners();
  }

  String? _fallbackRegionFor(double normalizedX) {
    final regions = pickableRegionIds;
    if (regions.isEmpty) {
      return null;
    }

    final index = (normalizedX * regions.length)
        .floor()
        .clamp(0, regions.length - 1)
        .toInt();
    return regions[index];
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}

double _clampUnit(double value) {
  return value.clamp(0, 1).toDouble();
}

String? _normalizeRegionId(String? value) {
  final regionId = value?.trim();
  if (regionId == null || regionId.isEmpty) {
    return null;
  }
  return regionId;
}
