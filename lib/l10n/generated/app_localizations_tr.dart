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

  @override
  String get exerciseCatalogTitle => 'Egzersiz katalogu';

  @override
  String get exerciseCatalogSearchLabel => 'Egzersiz ara';

  @override
  String get exerciseCatalogSearchHint =>
      'Egzersiz, kas, ekipman veya ipucu ara';

  @override
  String get exerciseCatalogFiltersTitle => 'Filtreler';

  @override
  String get exerciseCatalogClearFilters => 'Temizle';

  @override
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount) {
    return '$totalCount egzersizden $visibleCount tanesi gosteriliyor';
  }

  @override
  String get exerciseCatalogLoading => 'Egzersiz katalogu yukleniyor...';

  @override
  String get exerciseCatalogLoadError => 'Egzersiz katalogu yuklenemedi.';

  @override
  String get exerciseCatalogEmptyTitle => 'Eslesen egzersiz yok';

  @override
  String get exerciseCatalogEmptyMessage =>
      'Egzersizleri gormek icin aramayi veya filtreleri degistir.';

  @override
  String get exerciseCatalogMovementFilter => 'Hareket';

  @override
  String get exerciseCatalogMuscleFilter => 'Kas';

  @override
  String get exerciseCatalogEquipmentFilter => 'Ekipman';

  @override
  String get exerciseCatalogLevelFilter => 'Seviye';

  @override
  String get exerciseCatalogLateralityFilter => 'Taraf';

  @override
  String get exerciseCatalogTypeFilter => 'Tip';

  @override
  String get exerciseDetailTitle => 'Egzersiz detayi';

  @override
  String get exerciseDetailSetup => 'Hazirlik';

  @override
  String get exerciseDetailExecution => 'Uygulama';

  @override
  String get exerciseDetailFormCues => 'Form ipuclari';

  @override
  String get exerciseDetailCommonErrors => 'Yaygin hatalar';

  @override
  String get exerciseDetailSubstitutions => 'Alternatifler';

  @override
  String get exerciseDetailRegressions => 'Kolaylastirmalar';

  @override
  String get exerciseDetailPrimaryMuscles => 'Birincil kaslar';

  @override
  String get exerciseDetailSecondaryMuscles => 'Ikincil kaslar';

  @override
  String get exerciseDetailStabilizerMuscles => 'Stabilizatorler';

  @override
  String get exerciseDetailEquipment => 'Ekipman';

  @override
  String get exerciseDetailLevel => 'Seviye';

  @override
  String get exerciseDetailLaterality => 'Taraf';

  @override
  String get exerciseDetailType => 'Tip';

  @override
  String get exerciseDetailNotFoundTitle => 'Egzersiz bulunamadi';

  @override
  String get exerciseDetailNotFoundMessage =>
      'Bu egzersiz yerel katalogda bulunmuyor.';

  @override
  String get programWorkspaceBuilderTab => 'Olusturucu';

  @override
  String get programWorkspaceCatalogTab => 'Katalog';

  @override
  String get programBuilderTitle => 'Program olusturucu';

  @override
  String get programBuilderEmptyTitle => 'Program taslagi olustur';

  @override
  String get programBuilderEmptyMessage =>
      'Bir isim ve bir antrenman gunu ile basla, sonra egzersizleri ve recete hedeflerini ekle.';

  @override
  String get programBuilderCreateProgram => 'Program olustur';

  @override
  String get programBuilderDefaultProgramName => 'Yeni program';

  @override
  String programBuilderDefaultDayName(int dayNumber) {
    return 'Gun $dayNumber';
  }

  @override
  String get programBuilderProgramNameLabel => 'Program adi';

  @override
  String get programBuilderLocalDraftLabel => 'Yerel taslak';

  @override
  String get programBuilderScopeNote =>
      'Bu taslak gunleri, egzersiz sirasini ve yerel recete hedeflerini tutar. Kalicilik ve versiyonlama sonraki checklist maddeleridir.';

  @override
  String programBuilderSummary(int dayCount, int exerciseCount) {
    return '$dayCount gun · $exerciseCount egzersiz';
  }

  @override
  String get programBuilderTrainingDays => 'Antrenman gunleri';

  @override
  String get programBuilderAddTrainingDay => 'Gun ekle';

  @override
  String get programBuilderSelectedDay => 'Secili gun';

  @override
  String get programBuilderRenameDay => 'Gunu yeniden adlandir';

  @override
  String get programBuilderDeleteDay => 'Gunu sil';

  @override
  String get programBuilderRenameDayTitle =>
      'Antrenman gununu yeniden adlandir';

  @override
  String get programBuilderDayNameLabel => 'Gun adi';

  @override
  String get programBuilderSave => 'Kaydet';

  @override
  String get programBuilderCancel => 'Iptal';

  @override
  String get programBuilderAddExercise => 'Egzersiz ekle';

  @override
  String get programBuilderExercisePickerTitle => 'Egzersiz ekle';

  @override
  String get programBuilderExercisePickerSearchLabel => 'Katalogda ara';

  @override
  String get programBuilderExercisePickerSearchHint =>
      'Egzersiz, kas, ekipman veya ipucu ara';

  @override
  String get programBuilderExercisePickerEmpty =>
      'Bu aramayla eslesen egzersiz yok.';

  @override
  String get programBuilderExerciseAlreadyAdded => 'Eklendi';

  @override
  String get programBuilderEmptyDayTitle => 'Henuz egzersiz yok';

  @override
  String get programBuilderEmptyDayMessage =>
      'Katalog egzersizlerini ekle, sonra bu antrenman gunu icin sirala.';

  @override
  String get programBuilderMoveExerciseUp => 'Yukari tasi';

  @override
  String get programBuilderMoveExerciseDown => 'Asagi tasi';

  @override
  String get programBuilderRemoveExercise => 'Kaldir';

  @override
  String get programBuilderSetCountLabel => 'Set';

  @override
  String get programBuilderFixedRepetitionMode => 'Sabit';

  @override
  String get programBuilderRangeRepetitionMode => 'Aralik';

  @override
  String get programBuilderFixedRepsLabel => 'Tekrar';

  @override
  String get programBuilderMinimumRepsLabel => 'Min tekrar';

  @override
  String get programBuilderMaximumRepsLabel => 'Maks tekrar';

  @override
  String get programBuilderTargetRirEnabled => 'RIR takip et';

  @override
  String get programBuilderTargetRirDescription =>
      'RIR opsiyoneldir ve sabit/aralik tekrar modundan bagimsizdir.';

  @override
  String get programBuilderTargetRirLabel => 'Hedef RIR';

  @override
  String get programBuilderLoadLabel => 'Yuk';

  @override
  String get programBuilderRestSecondsLabel => 'Dinlenme';

  @override
  String get programBuilderSecondsSuffix => 'sn';

  @override
  String programBuilderFixedRepsSummary(int repetitions) {
    return '$repetitions tekrar';
  }

  @override
  String programBuilderRangeRepsSummary(
    int minimumRepetitions,
    int maximumRepetitions,
  ) {
    return '$minimumRepetitions-$maximumRepetitions tekrar';
  }

  @override
  String programBuilderRirSummary(int targetRir) {
    return 'RIR $targetRir';
  }

  @override
  String get programBuilderRirOff => 'RIR kapali';

  @override
  String get programBuilderLoadUnset => 'yuk yok';

  @override
  String programBuilderPrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  ) {
    return '$setCount set Â· $repetitionTarget Â· $rirTarget Â· $loadTarget Â· $restSeconds sn';
  }

  @override
  String get programBuilderSaveDraft => 'Taslagi kaydet';

  @override
  String get programBuilderPublishVersion => 'Versiyon yayinla';

  @override
  String get programBuilderCopyProgram => 'Programi kopyala';

  @override
  String get programBuilderArchiveProgram => 'Programi arsivle';

  @override
  String get programBuilderLifecycleStatusLocal =>
      'Yerel taslak Â· henuz kaydedilmedi';

  @override
  String programBuilderLifecycleStatusSaved(int versionNumber) {
    return 'Kayitli taslak Â· versiyon $versionNumber';
  }

  @override
  String programBuilderLifecycleStatusPublished(int versionNumber) {
    return 'Yayinda Â· aktif versiyon $versionNumber';
  }

  @override
  String programBuilderLifecycleStatusArchived(int versionNumber) {
    return 'Arsivlendi Â· son versiyon $versionNumber';
  }

  @override
  String get programBuilderDraftSaved => 'Program taslagi kaydedildi.';

  @override
  String get programBuilderVersionPublished =>
      'Degistirilemez program versiyonu yayinlandi.';

  @override
  String get programBuilderProgramCopied =>
      'Program yeni bir yerel taslak olarak kopyalandi.';

  @override
  String get programBuilderProgramArchived => 'Program arsivlendi.';

  @override
  String get programBuilderPersistenceFailed =>
      'Program kaydedilemedi. Yerel taslagi kontrol edip tekrar dene.';

  @override
  String programBuilderCopiedProgramName(String programName) {
    return '$programName kopya';
  }
}
