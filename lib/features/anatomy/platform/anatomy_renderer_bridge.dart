import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AnatomyRendererMode {
  staticFallback('static_fallback'),
  interactiveLite('interactive_lite');

  const AnatomyRendererMode(this.wireName);

  final String wireName;

  static AnatomyRendererMode fromWireName(String? value) {
    for (final mode in AnatomyRendererMode.values) {
      if (mode.wireName == value) {
        return mode;
      }
    }
    return AnatomyRendererMode.staticFallback;
  }
}

enum AnatomyLodTier {
  lod0('lod0'),
  lod1('lod1'),
  lod2('lod2');

  const AnatomyLodTier(this.wireName);

  final String wireName;

  static AnatomyLodTier fromWireName(String? value) {
    for (final tier in AnatomyLodTier.values) {
      if (tier.wireName == value) {
        return tier;
      }
    }
    return AnatomyLodTier.lod2;
  }
}

@immutable
class AnatomyRendererCapabilities {
  const AnatomyRendererCapabilities({
    required this.platform,
    required this.backend,
    required this.viewType,
    required this.supportsGlb,
    required this.supportsOrbitCamera,
    required this.supportsZoom,
    required this.supportsPicking,
    required this.supportsHeatmap,
    required this.assetBundled,
    required this.requiredNodeExtras,
    required this.supportsLod,
    required this.supportedLodTiers,
    required this.defaultLodTier,
    required this.defaultRenderMode,
    required this.renderLoopMode,
  });

  factory AnatomyRendererCapabilities.fromMap(Object? value) {
    final map = value as Map<Object?, Object?>? ?? const <Object?, Object?>{};
    return AnatomyRendererCapabilities(
      platform: map['platform'] as String? ?? 'unknown',
      backend: map['backend'] as String? ?? 'unavailable',
      viewType: map['viewType'] as String? ?? AnatomyRendererBridge.viewType,
      supportsGlb: map['supportsGlb'] as bool? ?? false,
      supportsOrbitCamera: map['supportsOrbitCamera'] as bool? ?? false,
      supportsZoom: map['supportsZoom'] as bool? ?? false,
      supportsPicking: map['supportsPicking'] as bool? ?? false,
      supportsHeatmap: map['supportsHeatmap'] as bool? ?? false,
      assetBundled: map['assetBundled'] as bool? ?? false,
      requiredNodeExtras: List<String>.unmodifiable(
        (map['requiredNodeExtras'] as List<Object?>? ?? const <Object?>[])
            .whereType<String>(),
      ),
      supportsLod: map['supportsLod'] as bool? ?? false,
      supportedLodTiers: List<AnatomyLodTier>.unmodifiable(
        (map['supportedLodTiers'] as List<Object?>? ?? const <Object?>[])
            .whereType<String>()
            .map(AnatomyLodTier.fromWireName),
      ),
      defaultLodTier: AnatomyLodTier.fromWireName(
        map['defaultLodTier'] as String?,
      ),
      defaultRenderMode: AnatomyRendererMode.fromWireName(
        map['defaultRenderMode'] as String?,
      ),
      renderLoopMode: map['renderLoopMode'] as String? ?? 'unavailable',
    );
  }

  factory AnatomyRendererCapabilities.unavailable() {
    return const AnatomyRendererCapabilities(
      platform: 'unavailable',
      backend: 'unavailable',
      viewType: AnatomyRendererBridge.viewType,
      supportsGlb: false,
      supportsOrbitCamera: false,
      supportsZoom: false,
      supportsPicking: false,
      supportsHeatmap: false,
      assetBundled: false,
      requiredNodeExtras: AnatomyRendererBridge.requiredNodeExtras,
      supportsLod: false,
      supportedLodTiers: <AnatomyLodTier>[],
      defaultLodTier: AnatomyLodTier.lod2,
      defaultRenderMode: AnatomyRendererMode.staticFallback,
      renderLoopMode: 'unavailable',
    );
  }

  final String platform;
  final String backend;
  final String viewType;
  final bool supportsGlb;
  final bool supportsOrbitCamera;
  final bool supportsZoom;
  final bool supportsPicking;
  final bool supportsHeatmap;
  final bool assetBundled;
  final List<String> requiredNodeExtras;
  final bool supportsLod;
  final List<AnatomyLodTier> supportedLodTiers;
  final AnatomyLodTier defaultLodTier;
  final AnatomyRendererMode defaultRenderMode;
  final String renderLoopMode;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'platform': platform,
      'backend': backend,
      'viewType': viewType,
      'supportsGlb': supportsGlb,
      'supportsOrbitCamera': supportsOrbitCamera,
      'supportsZoom': supportsZoom,
      'supportsPicking': supportsPicking,
      'supportsHeatmap': supportsHeatmap,
      'assetBundled': assetBundled,
      'requiredNodeExtras': requiredNodeExtras,
      'supportsLod': supportsLod,
      'supportedLodTiers': supportedLodTiers
          .map((tier) => tier.wireName)
          .toList(growable: false),
      'defaultLodTier': defaultLodTier.wireName,
      'defaultRenderMode': defaultRenderMode.wireName,
      'renderLoopMode': renderLoopMode,
    };
  }
}

@immutable
class AnatomyCameraPose {
  const AnatomyCameraPose({
    required this.yawDegrees,
    required this.pitchDegrees,
    required this.zoom,
  });

  factory AnatomyCameraPose.fromMap(Object? value) {
    final map = _asObjectMap(value);
    return AnatomyCameraPose(
      yawDegrees: _readDouble(map['yawDegrees'], initial.yawDegrees),
      pitchDegrees: _readDouble(map['pitchDegrees'], initial.pitchDegrees),
      zoom: _readDouble(map['zoom'], initial.zoom),
    ).normalized();
  }

  static const initial = AnatomyCameraPose(
    yawDegrees: 0,
    pitchDegrees: 8,
    zoom: 4,
  );

  static const minPitchDegrees = -70.0;
  static const maxPitchDegrees = 70.0;
  static const minZoom = 1.2;
  static const maxZoom = 8.0;

  final double yawDegrees;
  final double pitchDegrees;
  final double zoom;

  AnatomyCameraPose copyWith({
    double? yawDegrees,
    double? pitchDegrees,
    double? zoom,
  }) {
    return AnatomyCameraPose(
      yawDegrees: yawDegrees ?? this.yawDegrees,
      pitchDegrees: pitchDegrees ?? this.pitchDegrees,
      zoom: zoom ?? this.zoom,
    );
  }

  AnatomyCameraPose normalized() {
    return AnatomyCameraPose(
      yawDegrees: _normalizeYaw(yawDegrees),
      pitchDegrees: _clampDouble(
        pitchDegrees,
        minPitchDegrees,
        maxPitchDegrees,
      ),
      zoom: _clampDouble(zoom, minZoom, maxZoom),
    );
  }

  Map<String, Object?> toMap() {
    final normalizedPose = normalized();
    return <String, Object?>{
      'yawDegrees': normalizedPose.yawDegrees,
      'pitchDegrees': normalizedPose.pitchDegrees,
      'zoom': normalizedPose.zoom,
    };
  }
}

@immutable
class AnatomyPickResult {
  const AnatomyPickResult({
    required this.hit,
    required this.regionId,
    required this.normalizedX,
    required this.normalizedY,
  });

  factory AnatomyPickResult.fromMap(
    Object? value, {
    required double fallbackX,
    required double fallbackY,
  }) {
    final map = _asObjectMap(value);
    final regionId = map['regionId'] as String?;
    return AnatomyPickResult(
      hit: map['hit'] as bool? ?? regionId != null,
      regionId: regionId,
      normalizedX: _clampDouble(
        _readDouble(map['normalizedX'], fallbackX),
        0,
        1,
      ),
      normalizedY: _clampDouble(
        _readDouble(map['normalizedY'], fallbackY),
        0,
        1,
      ),
    );
  }

  final bool hit;
  final String? regionId;
  final double normalizedX;
  final double normalizedY;
}

class AnatomyRendererBridge {
  AnatomyRendererBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'project_atlas/anatomy_renderer_bridge';
  static const viewType = 'project_atlas/anatomy_renderer';
  static const requiredNodeExtras = <String>[
    'muscle_region_id',
    'semantic_group_id',
    'side',
    'reduction_slot',
    'source_element_ids',
  ];

  final MethodChannel _channel;

  Future<AnatomyRendererCapabilities> getCapabilities() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getCapabilities');
      return AnatomyRendererCapabilities.fromMap(result);
    } on MissingPluginException {
      return AnatomyRendererCapabilities.unavailable();
    } on PlatformException {
      return AnatomyRendererCapabilities.unavailable();
    }
  }

  Future<AnatomyCameraPose> setCameraPose({
    required int viewId,
    required AnatomyCameraPose pose,
  }) async {
    final normalizedPose = pose.normalized();
    try {
      final result = await _channel.invokeMethod<Object?>('setCameraPose', {
        'viewId': viewId,
        ...normalizedPose.toMap(),
      });
      return AnatomyCameraPose.fromMap(result);
    } on MissingPluginException {
      return normalizedPose;
    } on PlatformException {
      return normalizedPose;
    }
  }

  Future<Map<String, double>> setHeatmap({
    required int viewId,
    required Map<String, double> heatmap,
  }) async {
    final sanitizedHeatmap = sanitizeHeatmap(heatmap);
    try {
      final result = await _channel.invokeMethod<Object?>('setHeatmap', {
        'viewId': viewId,
        'heatmap': sanitizedHeatmap,
      });
      return _readHeatmapFromState(result, fallback: sanitizedHeatmap);
    } on MissingPluginException {
      return sanitizedHeatmap;
    } on PlatformException {
      return sanitizedHeatmap;
    }
  }

  Future<String?> selectRegion({
    required int viewId,
    required String? regionId,
  }) async {
    final normalizedRegionId = _normalizeRegionId(regionId);
    try {
      final result = await _channel.invokeMethod<Object?>('selectRegion', {
        'viewId': viewId,
        'regionId': normalizedRegionId,
      });
      return _asObjectMap(result)['selectedRegionId'] as String?;
    } on MissingPluginException {
      return normalizedRegionId;
    } on PlatformException {
      return normalizedRegionId;
    }
  }

  Future<AnatomyPickResult> pick({
    required int viewId,
    required double normalizedX,
    required double normalizedY,
  }) async {
    final x = _clampDouble(normalizedX, 0, 1);
    final y = _clampDouble(normalizedY, 0, 1);
    try {
      final result = await _channel.invokeMethod<Object?>('pick', {
        'viewId': viewId,
        'normalizedX': x,
        'normalizedY': y,
      });
      return AnatomyPickResult.fromMap(result, fallbackX: x, fallbackY: y);
    } on MissingPluginException {
      return AnatomyPickResult(
        hit: false,
        regionId: null,
        normalizedX: x,
        normalizedY: y,
      );
    } on PlatformException {
      return AnatomyPickResult(
        hit: false,
        regionId: null,
        normalizedX: x,
        normalizedY: y,
      );
    }
  }

  Future<Map<String, Object?>> getState({required int viewId}) async {
    try {
      final result = await _channel.invokeMethod<Object?>('getState', {
        'viewId': viewId,
      });
      return _asObjectMap(result);
    } on MissingPluginException {
      return const <String, Object?>{};
    } on PlatformException {
      return const <String, Object?>{};
    }
  }

  static Map<String, double> sanitizeHeatmap(Map<String, double> heatmap) {
    return Map<String, double>.unmodifiable(
      Map<String, double>.fromEntries(
        heatmap.entries
            .where((entry) => entry.key.trim().isNotEmpty)
            .map(
              (entry) =>
                  MapEntry(entry.key.trim(), _clampDouble(entry.value, 0, 1)),
            ),
      ),
    );
  }
}

Map<String, Object?> _asObjectMap(Object? value) {
  if (value is! Map<Object?, Object?>) {
    return const <String, Object?>{};
  }
  final map = value;
  return Map<String, Object?>.fromEntries(
    map.entries
        .where((entry) => entry.key is String)
        .map((entry) => MapEntry(entry.key! as String, entry.value)),
  );
}

Map<String, double> _readHeatmapFromState(
  Object? value, {
  required Map<String, double> fallback,
}) {
  final state = _asObjectMap(value);
  final heatmap = state.containsKey('heatmap') ? state['heatmap'] : value;
  final heatmapMap = _asObjectMap(heatmap);
  if (heatmapMap.isEmpty) {
    return fallback;
  }
  return AnatomyRendererBridge.sanitizeHeatmap(
    Map<String, double>.fromEntries(
      heatmapMap.entries
          .where((entry) => entry.value is num)
          .map(
            (entry) => MapEntry(entry.key, (entry.value! as num).toDouble()),
          ),
    ),
  );
}

double _readDouble(Object? value, double fallback) {
  final numericValue = value as num?;
  return numericValue?.toDouble() ?? fallback;
}

double _clampDouble(double value, double lowerLimit, double upperLimit) {
  return value.clamp(lowerLimit, upperLimit).toDouble();
}

double _normalizeYaw(double value) {
  var result = value % 360;
  if (result < -180) {
    result += 360;
  }
  if (result > 180) {
    result -= 360;
  }
  return result;
}

String? _normalizeRegionId(String? value) {
  final regionId = value?.trim();
  if (regionId == null || regionId.isEmpty) {
    return null;
  }
  return regionId;
}
