// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Project Atlas';

  @override
  String get todayNavigationLabel => 'Bugün';

  @override
  String get programNavigationLabel => 'Program';

  @override
  String get anatomyNavigationLabel => 'Anatomi';

  @override
  String get progressNavigationLabel => 'İlerleme';

  @override
  String get settingsNavigationLabel => 'Ayarlar';

  @override
  String get anatomyRendererTitle => '3B anatomi görüntüleyici';

  @override
  String get anatomyRendererDescription =>
      'Android derlemeleri yerel Filament yüzeyi kullanır. GLB anatomi varlıkları paketleme kontrol noktasına kadar harici kalır.';

  @override
  String get anatomyInteractionInstructions =>
      'Döndürmek için sürükle, yakınlaştırmak için iki parmakla sıkıştır, seçmek için bir bölgeye dokun. Heatmap önizlemesi çalışma zamanı GLB pakete eklenene kadar semantik kas kimliklerini kullanır.';

  @override
  String get anatomyRendererContentDescription =>
      'Etkileşimli anatomi görüntüleyici';

  @override
  String get anatomyRendererAndroidOnly =>
      'Yerel Filament görüntüleyici Android derlemelerinde kullanılabilir. Bu ortam güvenli bir yedek görünüm gösterir.';

  @override
  String get anatomyRendererPerformanceFallback =>
      'Performans güvenli semantik önizleme etkin. Paketlenmiş varlıklar ve orta seviye cihaz ölçümleri eşiği karşılayana kadar yerel görüntüleyici kapalı kalır.';

  @override
  String get anatomyRendererStatusLoading =>
      'Görüntüleyici köprüsü kontrol ediliyor...';

  @override
  String anatomyRendererStatus(
    String backend,
    String glbStatus,
    String assetStatus,
  ) {
    return 'Görüntüleyici: $backend; GLB: $glbStatus; Varlık: $assetStatus';
  }

  @override
  String get anatomyRendererGlbSupported => 'destekleniyor';

  @override
  String get anatomyRendererGlbUnavailable => 'kullanılamıyor';

  @override
  String get anatomyRendererAssetBundled => 'paketlendi';

  @override
  String get anatomyRendererAssetExternal => 'harici';

  @override
  String anatomyRendererPolicyStatus(String mode, String lodTier) {
    return 'Performans politikası: $mode; LOD: $lodTier';
  }

  @override
  String get anatomyRendererModeStaticFallback => 'semantik yedek görünüm';

  @override
  String get anatomyRendererModeInteractiveLite => 'hafif etkileşimli';

  @override
  String get anatomyRendererResetCamera => 'Kamerayı sıfırla';

  @override
  String get anatomyRendererPreviewHeatmap => 'Heatmap önizle';

  @override
  String get anatomyRendererNoRegionSelected => 'Seçili kas bölgesi yok';

  @override
  String anatomyRendererSelectedRegion(String regionId) {
    return 'Seçili bölge: $regionId';
  }

  @override
  String anatomyRendererCameraState(String yaw, String pitch, String zoom) {
    return 'Kamera: yaw $yaw, pitch $pitch, zoom $zoom';
  }

  @override
  String get anatomyRendererHeatmapLegend => 'Aktif heatmap bölgeleri';

  @override
  String get anatomyRendererHeatmapEmpty => 'Uygulanmış heatmap yok';
}
