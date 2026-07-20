// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Project Atlas';

  @override
  String get todayNavigationLabel => 'Today';

  @override
  String get programNavigationLabel => 'Program';

  @override
  String get anatomyNavigationLabel => 'Anatomy';

  @override
  String get progressNavigationLabel => 'Progress';

  @override
  String get settingsNavigationLabel => 'Settings';

  @override
  String get anatomyRendererTitle => '3D anatomy renderer';

  @override
  String get anatomyRendererDescription =>
      'Android builds use a native Filament surface. GLB anatomy assets remain external until the bundling checkpoint.';

  @override
  String get anatomyInteractionInstructions =>
      'Drag to rotate, pinch to zoom, and tap a region to select it. Heatmap preview uses semantic muscle IDs until the runtime GLB is bundled.';

  @override
  String get anatomyRendererContentDescription =>
      'Interactive anatomy renderer';

  @override
  String get anatomyRendererAndroidOnly =>
      'The native Filament renderer is available on Android builds. This environment shows a safe fallback.';

  @override
  String get anatomyRendererPerformanceFallback =>
      'Performance-safe semantic preview is active. The native renderer stays off until bundled assets and mid-range device metrics meet the threshold.';

  @override
  String get anatomyRendererStatusLoading => 'Checking renderer bridge...';

  @override
  String anatomyRendererStatus(
    String backend,
    String glbStatus,
    String assetStatus,
  ) {
    return 'Renderer: $backend; GLB: $glbStatus; Asset: $assetStatus';
  }

  @override
  String get anatomyRendererGlbSupported => 'supported';

  @override
  String get anatomyRendererGlbUnavailable => 'unavailable';

  @override
  String get anatomyRendererAssetBundled => 'bundled';

  @override
  String get anatomyRendererAssetExternal => 'external';

  @override
  String anatomyRendererPolicyStatus(String mode, String lodTier) {
    return 'Performance policy: $mode; LOD: $lodTier';
  }

  @override
  String get anatomyRendererModeStaticFallback => 'semantic fallback';

  @override
  String get anatomyRendererModeInteractiveLite => 'interactive lite';

  @override
  String get anatomyRendererResetCamera => 'Reset camera';

  @override
  String get anatomyRendererPreviewHeatmap => 'Preview heatmap';

  @override
  String get anatomyRendererNoRegionSelected => 'No muscle region selected';

  @override
  String anatomyRendererSelectedRegion(String regionId) {
    return 'Selected region: $regionId';
  }

  @override
  String anatomyRendererCameraState(String yaw, String pitch, String zoom) {
    return 'Camera: yaw $yaw, pitch $pitch, zoom $zoom';
  }

  @override
  String get anatomyRendererHeatmapLegend => 'Active heatmap regions';

  @override
  String get anatomyRendererHeatmapEmpty => 'No heatmap applied';
}
