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
  String get progressScreenSubtitle =>
      'Antrenman gecmisini incele, set sonuclarina bak ve kisisel rekorlari takip et.';

  @override
  String get progressHistoryTitle => 'Antrenman gecmisi';

  @override
  String get progressHistoryEmptyTitle => 'Henuz antrenman gecmisi yok';

  @override
  String get progressHistoryEmptyMessage =>
      'Yerel gecmisi olusturmak icin Bugun sekmesinden setleri tamamla.';

  @override
  String get progressHistoryLoadError => 'Antrenman gecmisi yuklenemedi.';

  @override
  String get progressUnnamedSession => 'Antrenman oturumu';

  @override
  String progressSessionSummary(
    String status,
    int completedSetCount,
    int setCount,
  ) {
    return '$status - $completedSetCount/$setCount set kaydedildi';
  }

  @override
  String progressSetButtonLabel(String exerciseName, int setNumber) {
    return '$exerciseName set $setNumber';
  }

  @override
  String get progressSetDetailsTitle => 'Set detaylari';

  @override
  String get progressSetDetailsEmpty =>
      'Sonucunu incelemek icin antrenman gecmisinden bir set sec.';

  @override
  String progressSetDetailSession(String sessionName, String dateTime) {
    return '$sessionName - $dateTime';
  }

  @override
  String progressSetDetailStatus(String status) {
    return 'Durum: $status';
  }

  @override
  String progressSetDetailTarget(String target) {
    return '$target';
  }

  @override
  String progressSetDetailLatest(String latest) {
    return '$latest';
  }

  @override
  String progressSetDetailRevisionCount(int revisionCount) {
    return '$revisionCount revizyon';
  }

  @override
  String get progressNoActualLog => 'Gercek sonuc kaydedilmedi';

  @override
  String get progressRevisionHistoryTitle => 'Revizyon gecmisi';

  @override
  String progressRevisionRow(int revision, String result) {
    return 'Revizyon $revision: $result';
  }

  @override
  String progressRevisionSupersedes(String logId) {
    return '$logId kaydinin yerine gecer';
  }

  @override
  String get progressCorrectionTitle => 'Kayitli sonucu duzelt';

  @override
  String get progressCorrectionDescription =>
      'Duzeltme kaydedilince yeni bir revizyon eklenir. Eski kayitlar korunur.';

  @override
  String get progressCorrectionUnavailable =>
      'Yalnizca tamamlanmis ve sonucu kaydedilmis setler duzeltilebilir.';

  @override
  String get progressCorrectionRepetitionsLabel => 'Duzeltilen tekrar';

  @override
  String get progressCorrectionLoadLabel => 'Duzeltilen yuk';

  @override
  String get progressCorrectionRirLabel => 'Duzeltilen RIR';

  @override
  String get progressCorrectionOutcomeLabel => 'Duzeltilen sonuc';

  @override
  String get progressCorrectionSave => 'Duzeltmeyi kaydet';

  @override
  String get progressCorrectionSaved =>
      'Duzeltme yeni revizyon olarak kaydedildi.';

  @override
  String get progressCorrectionFailed => 'Duzeltme kaydedilemedi.';

  @override
  String get progressCorrectionInvalid =>
      'Gecerli tekrar, yuk ve RIR degerleri gir.';

  @override
  String get progressPersonalRecordsTitle => 'Kisisel rekorlar';

  @override
  String get progressPersonalRecordsEmpty =>
      'Henuz kisisel rekor yok. Rekor takibi icin tekrar veya yuk iceren temiz setleri tamamla.';

  @override
  String progressBestLoad(String load) {
    return 'En iyi yuk: $load';
  }

  @override
  String progressBestRepetitions(int repetitions) {
    return 'En iyi tekrar: $repetitions';
  }

  @override
  String progressBestVolume(String volume) {
    return 'En iyi hacim: $volume';
  }

  @override
  String get settingsNavigationLabel => 'Ayarlar';

  @override
  String get onboardingTitle => 'Uyarlanabilir başlangıç';

  @override
  String get onboardingDescription =>
      'Öneriler oluşturulmadan önce planlayıcının kullanacağı girişleri belirle. Bu seçimler yalnızca bu cihazda kalır.';

  @override
  String get onboardingGoalLabel => 'Ana hedef';

  @override
  String get onboardingExperienceLabel => 'Antrenman deneyimi';

  @override
  String get onboardingEquipmentLabel => 'Mevcut ekipman';

  @override
  String get onboardingSessionLengthLabel => 'Tercih edilen seans süresi';

  @override
  String get onboardingWeekdaysLabel => 'Tercih edilen antrenman günleri';

  @override
  String get onboardingSaveButton => 'Başlangıcı kaydet';

  @override
  String get onboardingSavedMessage => 'Başlangıç tercihleri kaydedildi.';

  @override
  String get onboardingSaveFailed => 'Başlangıç tercihleri kaydedilemedi.';

  @override
  String get onboardingLoadError => 'Başlangıç tercihleri yüklenemedi.';

  @override
  String onboardingSessionLengthValue(int minutes) {
    return '$minutes dakika';
  }

  @override
  String onboardingSavedSummary(
    String goal,
    String experience,
    int minutes,
    String weekdays,
    String equipment,
  ) {
    return 'Kaydedildi: $goal, $experience, $minutes dakika, $weekdays. Ekipman: $equipment.';
  }

  @override
  String get onboardingGoalGeneralFitness => 'Genel kondisyon';

  @override
  String get onboardingGoalHypertrophy => 'Kas gelişimi';

  @override
  String get onboardingGoalMaximumStrength => 'Maksimum güç';

  @override
  String get onboardingGoalBodyRecomposition => 'Vücut kompozisyonu';

  @override
  String get onboardingGoalMuscularEndurance => 'Kas dayanıklılığı';

  @override
  String get onboardingGoalAthleticPerformance => 'Atletik performans';

  @override
  String get onboardingGoalMaintenance => 'Korumak';

  @override
  String get onboardingExperienceNewToTraining => 'Antrenmana yeni';

  @override
  String get onboardingExperienceBeginner => 'Başlangıç';

  @override
  String get onboardingExperienceIntermediate => 'Orta seviye';

  @override
  String get onboardingExperienceAdvanced => 'İleri seviye';

  @override
  String get onboardingEquipmentBodyweight => 'Vücut ağırlığı';

  @override
  String get onboardingEquipmentDumbbells => 'Dambıl';

  @override
  String get onboardingEquipmentBarbell => 'Bar';

  @override
  String get onboardingEquipmentMachines => 'Makineler';

  @override
  String get onboardingEquipmentCableStation => 'Kablo istasyonu';

  @override
  String get onboardingEquipmentKettlebell => 'Kettlebell';

  @override
  String get onboardingEquipmentResistanceBands => 'Direnç bantları';

  @override
  String get onboardingEquipmentCardio => 'Kardiyo ekipmanı';

  @override
  String get onboardingWeekdayMonday => 'Pazartesi';

  @override
  String get onboardingWeekdayTuesday => 'Salı';

  @override
  String get onboardingWeekdayWednesday => 'Çarşamba';

  @override
  String get onboardingWeekdayThursday => 'Perşembe';

  @override
  String get onboardingWeekdayFriday => 'Cuma';

  @override
  String get onboardingWeekdaySaturday => 'Cumartesi';

  @override
  String get onboardingWeekdaySunday => 'Pazar';

  @override
  String get calibrationBlockTitle => 'Konservatif kalibrasyon bloğu';

  @override
  String get calibrationBlockDescription =>
      'Gelecek antrenmanı değiştiren önerilerden önce tekrarlanabilir başlangıç yüklerini bulmak için bu ilk bloğu kullan.';

  @override
  String calibrationBlockSummary(
    int weeks,
    int sessionsPerWeek,
    int minimumRir,
  ) {
    return '$weeks hafta - haftada $sessionsPerWeek seans - en az RIR $minimumRir koru';
  }

  @override
  String calibrationBlockSessionTarget(int minutes, String weekdays) {
    return '$minutes dakikalık hedef seanslar: $weekdays';
  }

  @override
  String get calibrationBlockNoProgression =>
      'Kalibrasyon sırasında yük artışı yok; önce temiz set kanıtı topla.';

  @override
  String calibrationWeekSummary(
    int weekNumber,
    String focus,
    int volumePercent,
    int minimumRir,
  ) {
    return 'Hafta $weekNumber: $focus - planlı hacmin %$volumePercent kadarı - RIR $minimumRir+';
  }

  @override
  String calibrationExitRequirements(String requirements) {
    return 'Sadece şu koşullardan sonra ilerle: $requirements.';
  }

  @override
  String get calibrationFocusTechniqueBaseline => 'teknik başlangıç noktası';

  @override
  String get calibrationFocusRepeatableExecution => 'tekrarlanabilir uygulama';

  @override
  String get calibrationFocusStableExposure => 'stabil maruziyet';

  @override
  String get calibrationFocusPrescriptionPreview => 'reçete önizlemesi';

  @override
  String get calibrationExitPlannedWeeksCompleted =>
      'planlanan haftalar tamamlandı';

  @override
  String get calibrationExitNoPainReports => 'ağrı bildirimi yok';

  @override
  String get calibrationExitNoRepeatedPerformanceMisses =>
      'tekrarlanan performans kaçırma yok';

  @override
  String get calibrationExitStableRirEvidence => 'RIR kanıtı stabil';

  @override
  String get availabilityTitle => 'Haftalık müsaitlik';

  @override
  String get availabilityDescription =>
      'Her hafta antrenmanın ne zaman sığabileceğini seç. Sabit dönemler kesin randevudur; esnek dönemler planlayıcının seansı pencere içine yerleştirmesine alan verir.';

  @override
  String get availabilityFixedPeriod => 'Sabit';

  @override
  String get availabilityFlexiblePeriod => 'Esnek';

  @override
  String get availabilityStartTimeLabel => 'Başlangıç';

  @override
  String get availabilityEndTimeLabel => 'Bitiş';

  @override
  String availabilityWindowSummary(
    String type,
    String startTime,
    String endTime,
  ) {
    return '$type pencere: $startTime - $endTime';
  }

  @override
  String get availabilitySaveButton => 'Müsaitliği kaydet';

  @override
  String get availabilitySavedMessage => 'Haftalık müsaitlik kaydedildi.';

  @override
  String get availabilitySaveFailed => 'Haftalık müsaitlik kaydedilemedi.';

  @override
  String get availabilityLoadError => 'Haftalık müsaitlik yüklenemedi.';

  @override
  String get availabilityLoading => 'Haftalık müsaitlik yükleniyor...';

  @override
  String get generatedProgramTitle => 'Program taslağı planlayıcı';

  @override
  String get generatedProgramDescription =>
      'Başlangıç bilgileri, haftalık müsaitlik, ekipman, toparlanma aralığı ve konservatif hacim kurallarıyla düzenlenebilir yerel taslak oluştur.';

  @override
  String get generatedProgramAvailabilityRequired =>
      'Program taslağı oluşturmadan önce haftalık müsaitliği kaydet.';

  @override
  String get generatedProgramCatalogLoadError =>
      'Egzersiz kataloğu yüklenemediği için program taslağı oluşturulamıyor.';

  @override
  String get generatedProgramNoPlan =>
      'Kaydedilmiş ekipmana uygun program oluşturulamadı. Daha fazla ekipman ekle veya müsaitliği güncelle.';

  @override
  String generatedProgramSummary(
    int sessionsPerWeek,
    int weeklySetTarget,
    int maxExercisesPerSession,
    int minimumRir,
  ) {
    return 'Haftada $sessionsPerWeek seans - $weeklySetTarget çalışma seti - seans başına en fazla $maxExercisesPerSession egzersiz - RIR $minimumRir+';
  }

  @override
  String generatedProgramDaySummary(
    String weekday,
    String windowType,
    String startTime,
    String endTime,
    int exerciseCount,
    int setCount,
  ) {
    return '$weekday - $windowType $startTime-$endTime - $exerciseCount egzersiz - $setCount set';
  }

  @override
  String generatedProgramExerciseSummary(
    int setCount,
    int minimumRepetitions,
    int maximumRepetitions,
    int targetRir,
    int restSeconds,
  ) {
    return '$setCount set - $minimumRepetitions-$maximumRepetitions tekrar - RIR $targetRir - $restSeconds sn dinlenme';
  }

  @override
  String get generatedProgramApplyDraft => 'Yerel taslak olarak uygula';

  @override
  String get generatedProgramAppliedMessage =>
      'Program taslağı yerel olarak uygulandı. Düzenlemek, kaydetmek veya yayınlamak için Program ekranını aç.';

  @override
  String get generatedProgramReplaceDraftTitle =>
      'Yerel taslak değiştirilsin mi?';

  @override
  String get generatedProgramReplaceDraftMessage =>
      'Bu plan uygulanırsa mevcut kaydedilmemiş Program taslağı değişir. Kaydedilmiş versiyonlar değişmez.';

  @override
  String get generatedProgramReplaceDraftCancel => 'Mevcut taslağı koru';

  @override
  String get generatedProgramReplaceDraftConfirm => 'Taslağı değiştir';

  @override
  String generatedProgramDraftName(String goal) {
    return '$goal taslağı';
  }

  @override
  String get generatedProgramFocusFullBody => 'Tüm vücut';

  @override
  String get generatedProgramFocusUpperEmphasis => 'Üst vücut odaklı';

  @override
  String get generatedProgramFocusLowerEmphasis => 'Alt vücut odaklı';

  @override
  String get generatedProgramFocusPosteriorChain => 'Arka zincir';

  @override
  String get generatedProgramFocusConditioningSupport => 'Kondisyon destek';

  @override
  String get missedSessionReplacementTitle => 'Kaçırılan seans telafisi';

  @override
  String get missedSessionReplacementDescription =>
      'Kaçırılan planlı günü seçerek en güvenli uygun telafi penceresini önizle. Bu işlem hiçbir antrenmanı taşımaz veya yayınlamaz.';

  @override
  String get missedSessionReplacementAvailabilityRequired =>
      'Telafi penceresini önizlemeden önce haftalık müsaitliği kaydet.';

  @override
  String get missedSessionReplacementMissedDayLabel => 'Kaçırılan planlı gün';

  @override
  String missedSessionReplacementDayOption(String dayName, String weekday) {
    return '$dayName - $weekday';
  }

  @override
  String missedSessionReplacementProposalSummary(
    String weekday,
    String windowType,
    String startTime,
    String endTime,
    int dayOffset,
    int recoveryHours,
  ) {
    return 'Öneri: $weekday, $windowType $startTime-$endTime. Bu pencere kaçırılan seanstan $dayOffset gün sonra ve planlı seanslar arasında en az $recoveryHours saat toparlanma bırakıyor.';
  }

  @override
  String get missedSessionReplacementNoSafeWindow =>
      'Kaydedilmiş haftalık müsaitlik içinde güvenli telafi penceresi yok.';

  @override
  String get missedSessionReplacementNoSafeWindowWithDuration =>
      'Planlı seans için yeterli süreye sahip güvenli telafi penceresi yok.';

  @override
  String missedSessionReplacementNoSafeWindowWithRecovery(int recoveryHours) {
    return 'Kalan planlı seanslar etrafında gereken $recoveryHours saat toparlanmayı koruyan güvenli telafi penceresi yok.';
  }

  @override
  String get missedSessionReplacementMissingDay =>
      'Seçilen planlı gün artık mevcut değil. Program önizlemesini yeniden oluşturup tekrar dene.';

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

  @override
  String get todayScreenSubtitle =>
      'Aktif programindan siradaki yerel antrenmani baslat.';

  @override
  String get todayNoActiveProgramTitle => 'Aktif program yok';

  @override
  String get todayNoActiveProgramMessage =>
      'Antrenman baslatmadan once Program sekmesinde bir program versiyonu yayinla.';

  @override
  String get todayOpenProgramBuilder => 'Programi ac';

  @override
  String todayActiveProgramSummary(int versionNumber, int dayCount) {
    return 'Aktif versiyon $versionNumber - $dayCount antrenman gunu';
  }

  @override
  String get todayChooseTrainingDay => 'Antrenman gunu sec';

  @override
  String todayTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount egzersiz - $setCount planli set';
  }

  @override
  String get todayStartWorkout => 'Antrenmani baslat';

  @override
  String get todaySessionStarted => 'Antrenman oturumu baslatildi.';

  @override
  String get todaySessionStartFailed => 'Antrenman baslatilamadi.';

  @override
  String get todayLoadError => 'Bugun ekrani yuklenemedi.';

  @override
  String get todayRetry => 'Tekrar dene';

  @override
  String todayFixedRepetitions(int repetitions) {
    return '$repetitions tekrar';
  }

  @override
  String todayRangeRepetitions(int minimumRepetitions, int maximumRepetitions) {
    return '$minimumRepetitions-$maximumRepetitions tekrar';
  }

  @override
  String todayExercisePrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  ) {
    return '$setCount set - $repetitionTarget - $rirTarget - $loadTarget - $restSeconds sn dinlenme';
  }

  @override
  String get todayNoExercisesTitle => 'Bu gunde egzersiz yok';

  @override
  String get todayNoExercisesMessage =>
      'Oturum baslatmadan once bu antrenman gunune egzersiz ekle.';

  @override
  String get todaySessionInProgressTitle => 'Oturum devam ediyor';

  @override
  String todaySessionInProgressSummary(int exerciseCount, int setCount) {
    return '$exerciseCount egzersiz - $setCount planli set';
  }

  @override
  String get todaySessionInProgressMessage =>
      'Her seti bitirdikce kaydet. Tamamlanan setler gercek sonucuyla yerel olarak saklanir.';

  @override
  String get todaySessionRestoredMessage =>
      'Devam eden bu antrenman yerel kayittan geri yuklendi.';

  @override
  String todaySessionStatusLabel(String status) {
    return 'Oturum durumu: $status';
  }

  @override
  String todayExerciseStatusLabel(String status) {
    return 'Egzersiz durumu: $status';
  }

  @override
  String todaySetStatusLabel(String status) {
    return 'Set durumu: $status';
  }

  @override
  String get todayStatusPending => 'Bekliyor';

  @override
  String get todayStatusNotStarted => 'Baslamadi';

  @override
  String get todayStatusInProgress => 'Devam ediyor';

  @override
  String get todayStatusSuccessful => 'Basarili';

  @override
  String get todayStatusTargetMet => 'Hedef karsilandi';

  @override
  String get todayStatusNeedsReview => 'Inceleme gerekli';

  @override
  String get todayStatusPerformanceMiss => 'Performans hedefi kacirildi';

  @override
  String get todayStatusInterrupted => 'Kesintiye ugradi';

  @override
  String get todayStatusPainReported => 'Agri bildirildi';

  @override
  String get todayStatusNotComparable => 'Kayit var, karsilastirilamaz';

  @override
  String todaySetProgressSummary(int completedSetCount, int setCount) {
    return '$completedSetCount/$setCount set tamamlandi';
  }

  @override
  String todayExerciseActiveSetSummary(int setCount) {
    return '$setCount set kaydedilecek';
  }

  @override
  String todaySessionSetLabel(int setNumber) {
    return 'Set $setNumber';
  }

  @override
  String get todayActualRepetitionsLabel => 'Gercek tekrar';

  @override
  String get todayActualLoadLabel => 'Gercek yuk';

  @override
  String get todayActualRirLabel => 'Gercek RIR';

  @override
  String get todayOutcomeLabel => 'Sonuc';

  @override
  String get todayOutcomeNone => 'Sinirlama yok';

  @override
  String get todayOutcomeStrengthLimitation => 'Guc limiti';

  @override
  String get todayOutcomeTechniqueLimitation => 'Teknik limiti';

  @override
  String get todayOutcomePain => 'Agri';

  @override
  String get todayOutcomeTimeLimitation => 'Zaman limiti';

  @override
  String get todayOutcomeEquipmentLimitation => 'Ekipman limiti';

  @override
  String get todayOutcomeExternalInterruption => 'Dis kesinti';

  @override
  String get todayCompleteSet => 'Seti tamamla';

  @override
  String todaySetPrescriptionSummary(
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
  ) {
    return 'Hedef: $repetitionTarget - $rirTarget - $loadTarget';
  }

  @override
  String get todaySetPrescriptionUnavailable => 'Hedef bulunamadi';

  @override
  String todayPreviousPerformanceSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  ) {
    return 'Onceki: $repetitionTarget - $loadTarget - $rirTarget - $outcomeTarget';
  }

  @override
  String get todayPreviousPerformanceUnavailable =>
      'Onceki: henuz kaydedilmis set yok';

  @override
  String get todayRepetitionsNotRecorded => 'tekrar kaydedilmedi';

  @override
  String todaySetActualSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  ) {
    return 'Kaydedildi: $repetitionTarget - $loadTarget - $rirTarget - $outcomeTarget';
  }

  @override
  String get todaySetLogSaved => 'Set kaydedildi.';

  @override
  String get todaySetLogFailed => 'Set kaydedilemedi.';

  @override
  String get todaySetLogInvalid => 'Gecerli tekrar, yuk ve RIR degerleri gir.';

  @override
  String get todayQuickLoadDecrease => 'Yuku azalt';

  @override
  String get todayQuickLoadIncrease => 'Yuku artir';

  @override
  String get todayRestTimerTitle => 'Dinlenme zamanlayicisi';

  @override
  String todayRestTimerRunning(
    String exerciseName,
    int setNumber,
    String remainingTime,
  ) {
    return '$exerciseName set $setNumber sonrasi dinlenme: $remainingTime';
  }

  @override
  String get todayRestTimerComplete =>
      'Dinlenme tamamlandi. Hazir olunca sonraki sete basla.';

  @override
  String get todayRestTimerDismiss => 'Kapat';

  @override
  String get todayRestTimerNotificationTitle => 'Dinlenme tamamlandi';

  @override
  String get todayRestTimerNotificationBody => 'Sonraki set zamani.';

  @override
  String get todayRestTimerNotificationScheduled =>
      'Arka plan uyarisi zamanlandi.';

  @override
  String get todayRestTimerNotificationPermissionDenied =>
      'Arka planda dinlenme uyarisi almak icin bildirimleri etkinlestir.';

  @override
  String get todayRestTimerNotificationUnsupported =>
      'Bu cihazda arka plan uyarisi kullanilamiyor.';

  @override
  String get todayRestTimerNotificationFailed =>
      'Arka plan uyarisi zamanlanamadi.';

  @override
  String get todayRestTimerNotificationSkipped =>
      'Dinlenme uyarisi gerekmiyor.';
}
