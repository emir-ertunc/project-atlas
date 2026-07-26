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
      'Seri, rekor, trend ve ölçüm değişimini takip et.';

  @override
  String get progressDashboardPathTitle => 'İlerleme yolu';

  @override
  String get progressDashboardPathDescription =>
      'Antrenman yap, kaydet, karşılaştır, tekrarla.';

  @override
  String progressDashboardStreakValue(int dayCount) {
    return '${dayCount}g';
  }

  @override
  String get progressDashboardStreakEmpty => 'Seriyi başlat';

  @override
  String progressDashboardStreakStatus(String streakValue) {
    return 'Seri $streakValue';
  }

  @override
  String progressDashboardWeekStatus(int completedCount) {
    return 'Hafta $completedCount/7g';
  }

  @override
  String get progressDashboardLocalFeedbackStart => 'Döngüyü başlat';

  @override
  String get progressDashboardLocalFeedbackStreak => 'Yerel ivme';

  @override
  String get progressDashboardLocalFeedbackWeek => 'Hafta yolunda';

  @override
  String get progressDashboardLocalFeedbackComplete =>
      'Kilometre taşları tamam';

  @override
  String progressDashboardLocalFeedbackNext(String milestoneLabel) {
    return 'Sıradaki: $milestoneLabel';
  }

  @override
  String progressDashboardMilestoneSummary(int completedCount, int totalCount) {
    return '$completedCount/$totalCount kilometre taşı';
  }

  @override
  String get progressDashboardMilestonesTitle => 'Kilometre taşları';

  @override
  String get progressDashboardMilestoneFirstWorkout => 'İlk antrenman';

  @override
  String get progressDashboardMilestoneWeekRhythm => 'Bu hafta 2 gün';

  @override
  String get progressDashboardMilestoneFirstRecord => 'İlk rekor';

  @override
  String get progressDashboardMilestoneBodyComparison =>
      'Vücut karşılaştırması';

  @override
  String get progressDashboardRecordBoardTitle => 'En iyi rekorlar';

  @override
  String progressDashboardRecordBoardSummary(int recordCount) {
    return '$recordCount takipte';
  }

  @override
  String get progressDashboardRecordBoardEmpty =>
      'Rekor için temiz set kaydet.';

  @override
  String get progressDashboardTrendEmpty =>
      'Trend için iki veri noktası kaydet.';

  @override
  String get progressDashboardMeasurementEmpty =>
      'Karşılaştırmak için iki ölçüm kaydet.';

  @override
  String progressDashboardMeasurementComparisonCount(int comparisonCount) {
    return '$comparisonCount karşılaştırma';
  }

  @override
  String get progressDashboardOpenRecords => 'Rekorlar';

  @override
  String get progressDashboardOpenTrends => 'Trendler';

  @override
  String get progressDashboardOpenMeasurements => 'Karşılaştır';

  @override
  String get progressHistoryTitle => 'Geçmiş';

  @override
  String get progressHistoryEmptyTitle => 'Henüz geçmiş yok';

  @override
  String get progressHistoryEmptyMessage =>
      'Geçmişi başlatmak için Bugün’de bir set tamamla.';

  @override
  String get progressHistoryLoadError => 'Geçmiş yüklenemedi.';

  @override
  String get progressUnnamedSession => 'Antrenman oturumu';

  @override
  String progressSessionSummary(
    String status,
    int completedSetCount,
    int setCount,
  ) {
    return '$status · $completedSetCount/$setCount set';
  }

  @override
  String progressSetButtonLabel(String exerciseName, int setNumber) {
    return '$exerciseName set $setNumber';
  }

  @override
  String get progressSetDetailsTitle => 'Set detayı';

  @override
  String get progressSetDetailsEmpty => 'Sonucu görmek için geçmişten set seç.';

  @override
  String progressSetDetailSession(String sessionName, String dateTime) {
    return '$sessionName · $dateTime';
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
  String get progressNoActualLog => 'Gerçek sonuç yok';

  @override
  String get progressRevisionHistoryTitle => 'Revizyonlar';

  @override
  String progressRevisionRow(int revision, String result) {
    return 'Revizyon $revision: $result';
  }

  @override
  String progressRevisionSupersedes(String logId) {
    return '$logId kaydının yerine geçer';
  }

  @override
  String get progressCorrectionTitle => 'Sonucu düzelt';

  @override
  String get progressCorrectionDescription =>
      'Düzeltme yeni revizyon olur; eski kayıtlar korunur.';

  @override
  String get progressCorrectionUnavailable =>
      'Yalnızca tamamlanmış kayıtlı setler düzeltilebilir.';

  @override
  String get progressCorrectionRepetitionsLabel => 'Tekrar';

  @override
  String get progressCorrectionLoadLabel => 'Yük';

  @override
  String get progressCorrectionRirLabel => 'RIR';

  @override
  String get progressCorrectionOutcomeLabel => 'Sonuç';

  @override
  String get progressCorrectionSave => 'Kaydet';

  @override
  String get progressCorrectionSaved => 'Düzeltme kaydedildi.';

  @override
  String get progressCorrectionFailed => 'Düzeltme kaydedilemedi.';

  @override
  String get progressCorrectionInvalid => 'Geçerli tekrar, yük ve RIR gir.';

  @override
  String get progressPersonalRecordsTitle => 'Kişisel rekorlar';

  @override
  String get progressPersonalRecordsEmpty =>
      'Rekor için tekrar veya yük içeren temiz set kaydet.';

  @override
  String get progressTrendsTitle => 'Trendler';

  @override
  String get progressTrendsDescription =>
      'Ölçüm ve temiz set kayıtlarından yerel hesaplanır. Güç tahmindir.';

  @override
  String get progressMeasurementTrendsTitle => 'Ölçümler';

  @override
  String get progressTrainingTrendsTitle => 'Antrenman';

  @override
  String get progressMeasurementHistoryTitle => 'Ölçümler';

  @override
  String get progressMeasurementHistoryDescription =>
      'Kayıtlı ölçümleri karşılaştır veya gerekirse export kopyala.';

  @override
  String get progressMeasurementComparisonTitle => 'İlk ve son';

  @override
  String progressMeasurementComparisonLine(
    String metric,
    String baseline,
    String latest,
    String change,
  ) {
    return '$metric: $baseline -> $latest ($change)';
  }

  @override
  String get progressMeasurementSideComparisonTitle => 'Son sağ/sol farkı';

  @override
  String progressMeasurementSideComparisonLine(
    String pair,
    String left,
    String right,
    String difference,
    String percent,
  ) {
    return '$pair: sol $left / sağ $right ($difference, %$percent)';
  }

  @override
  String get progressMeasurementPairUpperArm => 'Üst kol';

  @override
  String get progressMeasurementPairForearm => 'Ön kol';

  @override
  String get progressMeasurementPairThigh => 'Uyluk';

  @override
  String get progressMeasurementPairCalf => 'Baldır';

  @override
  String get progressMeasurementExportTitle => 'Ölçüm export';

  @override
  String get progressMeasurementExportDescription =>
      'Export kişisel ölçüm verisi içerir. Yalnızca güvendiğin yerde sakla.';

  @override
  String progressMeasurementExportCount(int recordCount) {
    return '$recordCount ölçüm kaydı hazır';
  }

  @override
  String get progressMeasurementExportCopyCsv => 'CSV kopyala';

  @override
  String get progressMeasurementExportCopyJson => 'JSON kopyala';

  @override
  String get progressMeasurementExportCopiedCsv => 'Ölçüm CSV kopyalandı.';

  @override
  String get progressMeasurementExportCopiedJson => 'Ölçüm JSON kopyalandı.';

  @override
  String progressTrendLine(
    String metric,
    String latest,
    String change,
    int pointCount,
  ) {
    return '$metric: $latest ($change, $pointCount nokta)';
  }

  @override
  String get progressTrendNoChange => 'değişim yok';

  @override
  String get progressTrendHeight => 'Boy';

  @override
  String get progressTrendWeight => 'Kilo';

  @override
  String get progressTrendTorsoLength => 'Gövde uzunluğu';

  @override
  String get progressTrendChest => 'Göğüs';

  @override
  String get progressTrendWaist => 'Bel';

  @override
  String get progressTrendHips => 'Kalça';

  @override
  String get progressTrendLeftUpperArm => 'Sol üst kol';

  @override
  String get progressTrendRightUpperArm => 'Sağ üst kol';

  @override
  String get progressTrendLeftForearm => 'Sol ön kol';

  @override
  String get progressTrendRightForearm => 'Sağ ön kol';

  @override
  String get progressTrendLeftThigh => 'Sol uyluk';

  @override
  String get progressTrendRightThigh => 'Sag uyluk';

  @override
  String get progressTrendLeftCalf => 'Sol baldır';

  @override
  String get progressTrendRightCalf => 'Sağ baldır';

  @override
  String get progressTrendBodyFat => 'Vücut yağı';

  @override
  String get progressTrendVolume => 'Hacim';

  @override
  String get progressTrendLoad => 'Yük';

  @override
  String get progressTrendRepetitions => 'Tekrar';

  @override
  String get progressTrendEstimatedStrength => 'Tahmini güç';

  @override
  String progressBestLoad(String load) {
    return 'En iyi yük: $load';
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
  String get settingsNavigationLabel => 'Profil';

  @override
  String get onboardingTitle => 'Planlayıcı kurulumu';

  @override
  String get onboardingDescription =>
      'Program önerileri için yerel girdileri kaydet.';

  @override
  String get onboardingGoalLabel => 'Hedef';

  @override
  String get onboardingExperienceLabel => 'Deneyim';

  @override
  String get onboardingEquipmentLabel => 'Ekipman';

  @override
  String get onboardingSessionLengthLabel => 'Seans süresi';

  @override
  String get onboardingWeekdaysLabel => 'Antrenman günleri';

  @override
  String get onboardingSaveButton => 'Kaydet';

  @override
  String get onboardingSavedMessage => 'Kurulum kaydedildi.';

  @override
  String get onboardingSaveFailed => 'Kurulum kaydedilemedi.';

  @override
  String get onboardingLoadError => 'Kurulum yüklenemedi.';

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
  String get setupWizardTitle => 'Kurulum';

  @override
  String get setupWizardDescription =>
      'Yerel planlama için beş hızlı adımı yanıtla.';

  @override
  String setupWizardStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get setupWizardBackButton => 'Geri';

  @override
  String get setupWizardNextButton => 'Devam';

  @override
  String get setupWizardReviewButton => 'Kontrol et';

  @override
  String get setupWizardSaveButton => 'Kaydet';

  @override
  String get setupWizardSavedMessage => 'Kurulum kaydedildi.';

  @override
  String get setupWizardSavedStatus => 'Kaydedildi';

  @override
  String get setupWizardSavedDescription =>
      'Hedef, ekipman, günler ve müsaitlik yerel kalır.';

  @override
  String get setupWizardSelectedStatus => 'Seçili';

  @override
  String get setupWizardGoalStepTitle => 'Hedef seç';

  @override
  String get setupWizardGoalStepShort => 'Hedef';

  @override
  String get setupWizardGoalStepDescription =>
      'İlk planlama önceliğini belirle; sonra değiştir.';

  @override
  String get setupWizardExperienceStepTitle => 'Seviye seç';

  @override
  String get setupWizardExperienceStepShort => 'Seviye';

  @override
  String get setupWizardExperienceStepDescription =>
      'Seviye, başlangıç hacmini kontrollü tutar.';

  @override
  String get setupWizardEquipmentStepTitle => 'Ekipman seç';

  @override
  String get setupWizardEquipmentStepShort => 'Ekipman';

  @override
  String get setupWizardEquipmentStepDescription =>
      'Çoğu hafta kullanabileceğin ekipmanı seç.';

  @override
  String get setupWizardAvailabilityStepTitle => 'Gün seç';

  @override
  String get setupWizardAvailabilityStepShort => 'Günler';

  @override
  String get setupWizardAvailabilityStepDescription =>
      'Gün seç, sonra pencereyi sabit veya esnek yap.';

  @override
  String get setupWizardAvailabilityWindowHint =>
      'Esnek alan açar; sabit randevuyu korur.';

  @override
  String setupWizardAvailabilityReview(int dayCount, int minutes) {
    return '$dayCount gün, varsayılan $minutes dk';
  }

  @override
  String get setupWizardMeasurementsStepTitle => 'Ölçüm akışı';

  @override
  String get setupWizardMeasurementsStepShort => 'Ölçüm';

  @override
  String get setupWizardMeasurementsStepDescription =>
      'Önce ne kadar rehberlik istediğini seç.';

  @override
  String get setupWizardMeasurementGuidedTitle => 'Rehberli giriş';

  @override
  String get setupWizardMeasurementGuidedDescription =>
      'En iyi tahmin için bölge adımlarını kullan.';

  @override
  String get setupWizardMeasurementEssentialsTitle => 'Önce temel ölçümler';

  @override
  String get setupWizardMeasurementEssentialsDescription =>
      'Boy, kilo ve ana çevrelerle başla.';

  @override
  String get setupWizardMeasurementLaterTitle => 'Sonra';

  @override
  String get setupWizardMeasurementLaterDescription =>
      'Şimdilik atla ve tahmini genel tut.';

  @override
  String get setupWizardMeasurementPrivacyNote =>
      'Bu adımda hiçbir ölçüm değeri kaydedilmez.';

  @override
  String get setupWizardReviewStepTitle => 'Kontrol et';

  @override
  String get setupWizardReviewStepShort => 'Kontrol';

  @override
  String get setupWizardReviewStepDescription =>
      'Planlamadan önce girdileri onayla.';

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
  String get generatedProgramTitle => 'Taslak planlayıcı';

  @override
  String get generatedProgramDescription =>
      'Kurulum, müsaitlik, ekipman, toparlanma ve hacim kurallarıyla taslak oluştur.';

  @override
  String get generatedProgramAvailabilityRequired =>
      'Taslak oluşturmadan önce müsaitliği kaydet.';

  @override
  String get generatedProgramCatalogLoadError =>
      'Katalog yüklenemedi; taslak oluşturulamıyor.';

  @override
  String get generatedProgramNoPlan =>
      'Kayıtlı ekipmana uygun plan yok. Ekipman ekle veya müsaitliği güncelle.';

  @override
  String generatedProgramSummary(
    int sessionsPerWeek,
    int weeklySetTarget,
    int maxExercisesPerSession,
    int minimumRir,
  ) {
    return '$sessionsPerWeek/hafta · $weeklySetTarget set · maks $maxExercisesPerSession/seans · RIR $minimumRir+';
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
    return '$weekday · $windowType $startTime-$endTime · $exerciseCount egzersiz · $setCount set';
  }

  @override
  String generatedProgramExerciseSummary(
    int setCount,
    int minimumRepetitions,
    int maximumRepetitions,
    int targetRir,
    int restSeconds,
  ) {
    return '$setCount set · $minimumRepetitions-$maximumRepetitions tekrar · RIR $targetRir · $restSeconds sn';
  }

  @override
  String get generatedProgramApplyDraft => 'Taslağı kullan';

  @override
  String get generatedProgramAppliedMessage =>
      'Taslak uygulandı. Düzenlemek, kaydetmek veya yayınlamak için Program’ı aç.';

  @override
  String get generatedProgramReplaceDraftTitle => 'Taslak değiştirilsin mi?';

  @override
  String get generatedProgramReplaceDraftMessage =>
      'Bu plan kaydedilmemiş Program taslağını değiştirir. Kayıtlı versiyonlar değişmez.';

  @override
  String get generatedProgramReplaceDraftCancel => 'Taslağı koru';

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
  String get anatomyRendererTitle => 'Anatomi görünümü';

  @override
  String get anatomyRendererDescription =>
      'Android derlemeleri yerel görünümü kullanır; varlıklar paketleme kontrolünde gelir.';

  @override
  String get anatomyInteractionInstructions =>
      'Sürükle, yakınlaştır veya bölgeye dokun. Heatmap, GLB gelene kadar kas kimliklerini kullanır.';

  @override
  String get anatomyOverlayVisualEstimate => 'Görsel tahmin';

  @override
  String get anatomyOverlayTapToInspect => 'Bölgeye dokun';

  @override
  String get anatomyMeasurementPromptTitle => 'Ölçüm ekle';

  @override
  String get anatomyMeasurementPromptDescription =>
      'Şekil değişimine güvenmeden önce rehberli ölçüm ekle.';

  @override
  String get anatomyMeasurementPromptAction => 'Rehber';

  @override
  String get anatomyVisualEstimateLabel => 'Görsel tahmin, tıbbi tarama değil';

  @override
  String get anatomyVisualEstimateDescription =>
      'Kayıtlı ölçüm ve antrenman verilerinden oluşur. Sağlık, sakatlık, hastalık veya vücut kompozisyonu tanısı koyamaz.';

  @override
  String get anatomyVisualEstimateInputNote =>
      'Trendler için kullan; yanlış görünürse kayıtlı girdileri kontrol et.';

  @override
  String get anatomyVisualEstimateIconLabel => 'Görsel tahmin bilgisi';

  @override
  String get anatomyRendererContentDescription =>
      'Etkileşimli anatomi görünümü';

  @override
  String get anatomyRendererAndroidOnly =>
      'Yerel görünüm Android derlemelerinde çalışır. Bu ortam güvenli yedek gösterir.';

  @override
  String get anatomyRendererPerformanceFallback =>
      'Varlıklar ve cihaz ölçümleri geçene kadar güvenli önizleme açık.';

  @override
  String get anatomyRendererStatusLoading => 'Görünüm kontrol ediliyor...';

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
  String get anatomyRendererModeStaticFallback => 'semantik yedek';

  @override
  String get anatomyRendererModeInteractiveLite => 'hafif etkileşimli';

  @override
  String get anatomyRendererResetCamera => 'Görünümü sıfırla';

  @override
  String get anatomyRendererPreviewHeatmap => 'Heatmap önizle';

  @override
  String get anatomyRendererNoRegionSelected => 'Kas bölgesine dokun';

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
  String get anatomyRendererHeatmapEmpty => 'Heatmap yok';

  @override
  String get anatomyTrainingHeatmapTitle => 'Kas heatmapleri';

  @override
  String get anatomyTrainingHeatmapDescription =>
      'Son 7 günden kas, hacim veya yorgunluk görünümünü aç.';

  @override
  String get anatomyTrainingHeatmapTrainedMuscle => 'Çalışan kaslar';

  @override
  String get anatomyTrainingHeatmapWeeklyVolume => 'Haftalık hacim';

  @override
  String get anatomyTrainingHeatmapFatigue => 'Yorgunluk';

  @override
  String get anatomyTrainingHeatmapLoading => 'Heatmap yükleniyor...';

  @override
  String get anatomyTrainingHeatmapLoadError => 'Heatmap yüklenemedi.';

  @override
  String get anatomyTrainingHeatmapEmpty =>
      '7 günlük heatmap için antrenman tamamla.';

  @override
  String anatomyTrainingHeatmapSummary(int regionCount, String topRegionId) {
    return '$regionCount bölge - en güçlü $topRegionId';
  }

  @override
  String get exerciseCatalogTitle => 'Egzersiz kataloğu';

  @override
  String get exerciseCatalogSubtitle => 'Ara, filtrele ve taslağına ekle.';

  @override
  String get exerciseCatalogSearchLabel => 'Egzersiz ara';

  @override
  String get exerciseCatalogSearchHint => 'Ad, kas, ekipman veya ipucu';

  @override
  String get exerciseCatalogFiltersTitle => 'Filtreler';

  @override
  String get exerciseCatalogClearFilters => 'Temizle';

  @override
  String get exerciseCatalogFilterButton => 'Filtreler';

  @override
  String get exerciseCatalogFilterSheetTitle => 'Egzersizleri filtrele';

  @override
  String get exerciseCatalogApplyFilters => 'Sonuçları göster';

  @override
  String get exerciseCatalogNoActiveFilters => 'Filtre yok';

  @override
  String exerciseCatalogActiveFilterCount(int filterCount) {
    return '$filterCount filtre';
  }

  @override
  String exerciseCatalogResultsTrend(int totalCount) {
    return '$totalCount içinden';
  }

  @override
  String get exerciseCatalogAddToProgram => 'Programa ekle';

  @override
  String exerciseCatalogAddedToProgram(String exerciseName, String dayName) {
    return '$exerciseName, $dayName gününe eklendi.';
  }

  @override
  String exerciseCatalogCreatedDraftAndAdded(
    String exerciseName,
    String dayName,
  ) {
    return 'Taslak oluşturuldu. $exerciseName, $dayName gününe eklendi.';
  }

  @override
  String exerciseCatalogAlreadyInProgram(String exerciseName, String dayName) {
    return '$exerciseName, $dayName gününde zaten var.';
  }

  @override
  String get exerciseCatalogAnimationAvailable => 'Animasyon hazır';

  @override
  String get exerciseCatalogThumbnailOnly => 'Görsel rehber';

  @override
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount) {
    return '$visibleCount/$totalCount egzersiz';
  }

  @override
  String get exerciseCatalogLoading => 'Katalog yükleniyor...';

  @override
  String get exerciseCatalogLoadError => 'Katalog yüklenemedi.';

  @override
  String get exerciseCatalogEmptyTitle => 'Eşleşme yok';

  @override
  String get exerciseCatalogEmptyMessage => 'Aramayı veya filtreleri değiştir.';

  @override
  String get exerciseCatalogMovementFilter => 'Hareket';

  @override
  String get exerciseCatalogMuscleFilter => 'Kas';

  @override
  String get exerciseCatalogEquipmentFilter => 'Ekipman';

  @override
  String get exerciseCatalogLevelFilter => 'Seviye';

  @override
  String get exerciseCatalogLateralityFilter => 'Yön';

  @override
  String get exerciseCatalogTypeFilter => 'Tip';

  @override
  String get exerciseDetailTitle => 'Egzersiz detayı';

  @override
  String get exerciseDetailSetup => 'Hazırlık';

  @override
  String get exerciseDetailExecution => 'Uygulama';

  @override
  String get exerciseDetailFormCues => 'Form ipuçları';

  @override
  String get exerciseDetailCommonErrors => 'Kaçın';

  @override
  String get exerciseDetailSubstitutions => 'Alternatifler';

  @override
  String get exerciseDetailRegressions => 'Kolaylaştır';

  @override
  String get exerciseDetailPrimaryMuscles => 'Birincil';

  @override
  String get exerciseDetailSecondaryMuscles => 'İkincil';

  @override
  String get exerciseDetailStabilizerMuscles => 'Stabilizatörler';

  @override
  String get exerciseDetailEquipment => 'Ekipman';

  @override
  String get exerciseDetailLevel => 'Seviye';

  @override
  String get exerciseDetailLaterality => 'Taraf';

  @override
  String get exerciseDetailType => 'Tip';

  @override
  String get exerciseDetailNotFoundTitle => 'Egzersiz bulunamadı';

  @override
  String get exerciseDetailNotFoundMessage =>
      'Bu egzersiz yerel katalogda yok.';

  @override
  String get programHubSubtitle =>
      'Planı incele. Düzenlemek için odaklı rota aç.';

  @override
  String get programHubNoActiveProgramTitle => 'Aktif plan yok';

  @override
  String get programHubNoActiveProgramMessage =>
      'Antrenmanlardan önce plan oluştur veya yayınla.';

  @override
  String get programHubCreateDraft => 'Taslak oluştur';

  @override
  String programHubActiveVersionSummary(int versionNumber, int dayCount) {
    return 'Versiyon $versionNumber · $dayCount gün';
  }

  @override
  String programHubPlanMetric(int dayCount, int setCount) {
    return '${dayCount}g · $setCount set';
  }

  @override
  String get programHubActiveStatus => 'Aktif';

  @override
  String get programHubBuilderDescription =>
      'Günleri, sırayı, hedefleri ve yayını düzenle.';

  @override
  String get programHubCatalogDescription =>
      'Egzersiz bul ve hub’ı kalabalıklaştırmadan ekle.';

  @override
  String get programHubRecommendationInboxTitle => 'İnceleme kuyruğu';

  @override
  String get programHubRecommendationClearDescription =>
      'İnceleme isteyen öneri yok.';

  @override
  String get programHubRecommendationClearCount => '0 bekliyor';

  @override
  String get programHubRecommendationClearStatus => 'Temiz';

  @override
  String get programHubTrainingDaysTitle => 'Antrenman günleri';

  @override
  String get programHubTrainingDaysDescription =>
      'Düzenlemek için günü Builder’da aç.';

  @override
  String programHubTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount egzersiz · $setCount set';
  }

  @override
  String programHubMoreExercises(int exerciseCount) {
    return '+$exerciseCount daha';
  }

  @override
  String get programHubLoadError => 'Program yüklenemedi.';

  @override
  String get programWorkspaceBuilderTab => 'Builder';

  @override
  String get programWorkspaceCatalogTab => 'Katalog';

  @override
  String get programBuilderTitle => 'Builder';

  @override
  String get programBuilderEmptyTitle => 'Taslak başlat';

  @override
  String get programBuilderEmptyMessage =>
      'Ad ver, gün ekle, sonra egzersiz seç.';

  @override
  String get programBuilderCreateProgram => 'Oluştur';

  @override
  String get programBuilderDefaultProgramName => 'Yeni program';

  @override
  String programBuilderDefaultDayName(int dayNumber) {
    return 'Gün $dayNumber';
  }

  @override
  String get programBuilderProgramNameLabel => 'Program adı';

  @override
  String get programBuilderGuidedSubtitle =>
      'Ayar, günler, katalog, hedefler, kontrol.';

  @override
  String programBuilderStepProgress(int currentStep, int totalSteps) {
    return 'Adım $currentStep/$totalSteps';
  }

  @override
  String get programBuilderBackStep => 'Geri';

  @override
  String get programBuilderContinueStep => 'Devam';

  @override
  String get programBuilderStepComplete => 'Tamam';

  @override
  String get programBuilderStepOpen => 'Açık';

  @override
  String get programBuilderSetupStepTitle => 'Ayar';

  @override
  String get programBuilderSetupStepSubtitle => 'Önce taslağa ad ver.';

  @override
  String get programBuilderDaysStepTitle => 'Günler';

  @override
  String get programBuilderDaysStepSubtitle =>
      'Gün ekle, seç, adlandır veya sil.';

  @override
  String get programBuilderExercisesStepTitle => 'Egzersizler';

  @override
  String get programBuilderExercisesStepSubtitle =>
      'Ara, ekle ve bu günü sırala.';

  @override
  String get programBuilderPrescriptionStepTitle => 'Hedefler';

  @override
  String get programBuilderPrescriptionStepSubtitle =>
      'Set, tekrar, RIR, yük ve dinlenmeyi düzenle.';

  @override
  String get programBuilderReviewStepTitle => 'Kontrol';

  @override
  String get programBuilderReviewStepSubtitle =>
      'Kaydetmeden veya yayınlamadan önce kontrol et.';

  @override
  String get programBuilderPrescriptionEmpty =>
      'Hedef düzenlemek için önce egzersiz ekle.';

  @override
  String get programBuilderPrescriptionInlineHint =>
      'Hedefler egzersiz kartlarında kalır.';

  @override
  String programBuilderPrescriptionReady(int exerciseCount) {
    return '$exerciseCount hedef';
  }

  @override
  String get programBuilderPublishReviewMessage =>
      'Yayınla: aktif antrenman versiyonu olur. Düzenleyeceksen taslak kaydet.';

  @override
  String get programBuilderReviewNameReady => 'Ad hazır';

  @override
  String get programBuilderReviewNameMissing => 'Ad eksik';

  @override
  String programBuilderReviewExercisesReady(int exerciseCount) {
    return '$exerciseCount egzersiz hazır';
  }

  @override
  String get programBuilderReviewExercisesMissing => 'Egzersiz ekle';

  @override
  String get programBuilderPublishConfirmTitle => 'Versiyon yayınlansın mı?';

  @override
  String get programBuilderPublishConfirmMessage =>
      'Bu taslağı aktif antrenman versiyonu yap.';

  @override
  String get programBuilderPublishConfirmAction => 'Yayınla';

  @override
  String get programBuilderLocalDraftLabel => 'Yerel taslak';

  @override
  String get programBuilderScopeNote =>
      'Kaydet taslağı korur. Yayınla aktif antrenman versiyonu oluşturur.';

  @override
  String programBuilderSummary(int dayCount, int exerciseCount) {
    return '${dayCount}g · $exerciseCount egzersiz';
  }

  @override
  String get programBuilderTrainingDays => 'Antrenman günleri';

  @override
  String get programBuilderAddTrainingDay => 'Gün ekle';

  @override
  String get programBuilderSelectedDay => 'Seçili gün';

  @override
  String get programBuilderRenameDay => 'Günü adlandır';

  @override
  String get programBuilderDeleteDay => 'Günü sil';

  @override
  String get programBuilderRenameDayTitle => 'Antrenman gününü adlandır';

  @override
  String get programBuilderDayNameLabel => 'Gün adı';

  @override
  String get programBuilderSave => 'Kaydet';

  @override
  String get programBuilderCancel => 'İptal';

  @override
  String get programBuilderAddExercise => 'Egzersiz ekle';

  @override
  String get programBuilderExercisePickerTitle => 'Egzersiz ekle';

  @override
  String get programBuilderExercisePickerSearchLabel => 'Katalogda ara';

  @override
  String get programBuilderExercisePickerSearchHint =>
      'Ad, kas, ekipman veya ipucu';

  @override
  String get programBuilderExercisePickerEmpty => 'Eşleşen egzersiz yok.';

  @override
  String get programBuilderExerciseAlreadyAdded => 'Eklendi';

  @override
  String get programBuilderEmptyDayTitle => 'Henüz egzersiz yok';

  @override
  String get programBuilderEmptyDayMessage =>
      'Egzersiz ekle, sonra bu günü sırala.';

  @override
  String get programBuilderMoveExerciseUp => 'Yukarı taşı';

  @override
  String get programBuilderMoveExerciseDown => 'Aşağı taşı';

  @override
  String get programBuilderRemoveExercise => 'Kaldır';

  @override
  String get programBuilderSetCountLabel => 'Set';

  @override
  String get programBuilderFixedRepetitionMode => 'Sabit';

  @override
  String get programBuilderRangeRepetitionMode => 'Aralık';

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
      'RIR opsiyoneldir ve tekrardan bağımsızdır.';

  @override
  String get programBuilderTargetRirLabel => 'Hedef RIR';

  @override
  String get programBuilderLoadLabel => 'Yük';

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
  String get programBuilderRirOff => 'RIR kapalı';

  @override
  String get programBuilderLoadUnset => 'yük yok';

  @override
  String programBuilderPrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  ) {
    return '$setCount set · $repetitionTarget · $rirTarget · $loadTarget · $restSeconds sn';
  }

  @override
  String get programBuilderSaveDraft => 'Taslak kaydet';

  @override
  String get programBuilderPublishVersion => 'Yayınla';

  @override
  String get programBuilderCopyProgram => 'Kopyala';

  @override
  String get programBuilderArchiveProgram => 'Arşivle';

  @override
  String get programBuilderLifecycleStatusLocal => 'Taslak · kaydedilmedi';

  @override
  String programBuilderLifecycleStatusSaved(int versionNumber) {
    return 'Taslak v$versionNumber';
  }

  @override
  String programBuilderLifecycleStatusPublished(int versionNumber) {
    return 'Aktif v$versionNumber';
  }

  @override
  String programBuilderLifecycleStatusArchived(int versionNumber) {
    return 'Arşiv v$versionNumber';
  }

  @override
  String get programBuilderDraftSaved => 'Program taslağı kaydedildi.';

  @override
  String get programBuilderVersionPublished => 'Program versiyonu yayınlandı.';

  @override
  String get programBuilderProgramCopied => 'Program yeni taslağa kopyalandı.';

  @override
  String get programBuilderProgramArchived => 'Program arşivlendi.';

  @override
  String get programBuilderPersistenceFailed =>
      'Program kaydedilemedi. Taslağı kontrol edip tekrar dene.';

  @override
  String programBuilderCopiedProgramName(String programName) {
    return '$programName kopya';
  }

  @override
  String get todayScreenSubtitle =>
      'Aktif planından sıradaki antrenmanı başlat.';

  @override
  String get todayActiveWorkoutSubtitle => 'Önce mevcut seti kaydet.';

  @override
  String get todayCoachDashboardSubtitle =>
      'Sıradaki seans, seri ve inceleme kuyruğu.';

  @override
  String get todayCoachResumeTitle => 'Antrenman aktif';

  @override
  String todayCoachNextWorkoutTitle(String dayName) {
    return 'Sıradaki: $dayName';
  }

  @override
  String get todayCoachNextWorkoutDescription =>
      'Şimdi başlat veya günü değiştir.';

  @override
  String get todayCoachNoProgramTrend => 'Plan gerekli';

  @override
  String get todayCoachReadyStatus => 'Hazır';

  @override
  String get todayCoachSetupStatus => 'Önce plan';

  @override
  String get todayResumeWorkout => 'Devam et';

  @override
  String get todayQuickStartWorkout => 'Başlat';

  @override
  String get todayCreateProgram => 'Plan oluştur';

  @override
  String get todayOpenWorkoutDetails => 'Detay';

  @override
  String get todayStreakTitle => 'Seri';

  @override
  String todayStreakValue(int dayCount) {
    return '$dayCount günlük seri';
  }

  @override
  String get todayStreakEmptyDescription =>
      'Seri başlatmak için antrenman tamamla.';

  @override
  String get todayStreakActiveDescription =>
      'Tamamlanan antrenman günlerinden hesaplanır.';

  @override
  String get todayWeeklyConsistencyTitle => 'Haftalık tutarlılık';

  @override
  String todayWeeklyConsistencyPercent(int percent) {
    return '%$percent';
  }

  @override
  String todayWeeklyConsistencyValue(int completedCount, int targetCount) {
    return '$completedCount / $targetCount seans';
  }

  @override
  String get todayWeeklyConsistencyNoTarget =>
      'Haftalık hedef için plan oluştur.';

  @override
  String get todayPendingRecommendationTitle => 'İnceleme kuyruğu';

  @override
  String get todayPendingRecommendationActiveDescription =>
      'Gelecek yük değişiminden önce bu durumu incele.';

  @override
  String get todayPendingRecommendationNoProgramDescription =>
      'Öneriler için önce plan oluştur.';

  @override
  String get todayPendingRecommendationClearDescription =>
      'İnceleme isteyen öneri yok.';

  @override
  String todayPendingRecommendationPendingCount(int pendingCount) {
    return '$pendingCount bekliyor';
  }

  @override
  String get todayPendingRecommendationClearCount => '0 bekliyor';

  @override
  String get todayPendingRecommendationClearStatus => 'Temiz';

  @override
  String get todaySessionRestoredStatus => 'Geri yüklendi';

  @override
  String get todayNoActiveProgramTitle => 'Aktif plan yok';

  @override
  String get todayNoActiveProgramMessage =>
      'Başlamadan önce Program’da plan yayınla.';

  @override
  String get todayOpenProgramBuilder => 'Programı aç';

  @override
  String todayActiveProgramSummary(int versionNumber, int dayCount) {
    return 'Versiyon $versionNumber · $dayCount gün';
  }

  @override
  String get todayChooseTrainingDay => 'Gün seç';

  @override
  String todayTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount egzersiz · $setCount set';
  }

  @override
  String get todayStartWorkout => 'Başlat';

  @override
  String get todaySessionStarted => 'Antrenman başlatıldı.';

  @override
  String get todaySessionStartFailed => 'Antrenman başlatılamadı.';

  @override
  String get todayLoadError => 'Bugün yüklenemedi.';

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
    return '$setCount set · $repetitionTarget · $rirTarget · $loadTarget · $restSeconds sn';
  }

  @override
  String get todayNoExercisesTitle => 'Henüz egzersiz yok';

  @override
  String get todayNoExercisesMessage => 'Başlamadan önce egzersiz ekle.';

  @override
  String get todaySessionInProgressTitle => 'Antrenman aktif';

  @override
  String todaySessionInProgressSummary(int exerciseCount, int setCount) {
    return '$exerciseCount egzersiz · $setCount set';
  }

  @override
  String get todaySessionInProgressMessage => 'Her seti bitirdikçe kaydet.';

  @override
  String get todayCurrentSetTitle => 'Şu anki set';

  @override
  String todayCurrentSetSubtitle(String exerciseName, int setNumber) {
    return '$exerciseName · set $setNumber';
  }

  @override
  String get todayWorkoutQueueTitle => 'Sıradaki';

  @override
  String todayWorkoutQueueSetLabel(
    String exerciseName,
    int setNumber,
    String status,
  ) {
    return '$exerciseName · set $setNumber · $status';
  }

  @override
  String get todayWorkoutCompleteTitle => 'Antrenman kaydedildi';

  @override
  String get todayWorkoutCompleteMessage =>
      'Planlı setler kaydedildi. Çıkmadan önce kontrol et.';

  @override
  String get todaySessionRestoredMessage =>
      'Antrenman yerel kayıttan geri yüklendi.';

  @override
  String todaySessionStatusLabel(String status) {
    return 'Oturum: $status';
  }

  @override
  String todayExerciseStatusLabel(String status) {
    return 'Egzersiz: $status';
  }

  @override
  String todaySetStatusLabel(String status) {
    return 'Set: $status';
  }

  @override
  String get todayStatusPending => 'Bekliyor';

  @override
  String get todayStatusNotStarted => 'Başlamadı';

  @override
  String get todayStatusInProgress => 'Devam ediyor';

  @override
  String get todayStatusSuccessful => 'Tamam';

  @override
  String get todayStatusTargetMet => 'Hedef tamam';

  @override
  String get todayStatusNeedsReview => 'İnceleme gerekli';

  @override
  String get todayStatusPerformanceMiss => 'Hedef kaçtı';

  @override
  String get todayStatusInterrupted => 'Kesildi';

  @override
  String get todayStatusPainReported => 'Ağrı bildirildi';

  @override
  String get todayStatusNotComparable => 'Yalnızca kayıt';

  @override
  String todaySetProgressSummary(int completedSetCount, int setCount) {
    return '$completedSetCount/$setCount set';
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
  String get todayActualRepetitionsLabel => 'Tekrar';

  @override
  String get todayActualLoadLabel => 'Yük';

  @override
  String get todayActualRirLabel => 'RIR';

  @override
  String get todayOutcomeLabel => 'Sonuç';

  @override
  String get todayOutcomeNone => 'Limit yok';

  @override
  String get todayOutcomeStrengthLimitation => 'Güç';

  @override
  String get todayOutcomeTechniqueLimitation => 'Teknik';

  @override
  String get todayOutcomePain => 'Ağrı';

  @override
  String get todayOutcomeTimeLimitation => 'Zaman';

  @override
  String get todayOutcomeEquipmentLimitation => 'Ekipman';

  @override
  String get todayOutcomeExternalInterruption => 'Kesinti';

  @override
  String get todayCompleteSet => 'Seti tamamla';

  @override
  String todaySetPrescriptionSummary(
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
  ) {
    return 'Hedef: $repetitionTarget · $rirTarget · $loadTarget';
  }

  @override
  String get todaySetPrescriptionUnavailable => 'Hedef yok';

  @override
  String todayPreviousPerformanceSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  ) {
    return 'Önceki: $repetitionTarget · $loadTarget · $rirTarget · $outcomeTarget';
  }

  @override
  String get todayPreviousPerformanceUnavailable => 'Önceki: yok';

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
  String get todaySetLogInvalid => 'Geçerli tekrar, yük ve RIR gir.';

  @override
  String get todayQuickLoadDecrease => 'Yük azalt';

  @override
  String get todayQuickLoadIncrease => 'Yük artır';

  @override
  String get todayRestTimerTitle => 'Dinlenme';

  @override
  String todayRestTimerRunning(
    String exerciseName,
    int setNumber,
    String remainingTime,
  ) {
    return '$exerciseName set $setNumber sonrası: $remainingTime';
  }

  @override
  String get todayRestTimerComplete =>
      'Dinlenme tamamlandı. Sonraki sete başla.';

  @override
  String get todayRestTimerDismiss => 'Kapat';

  @override
  String get todayRestTimerNotificationTitle => 'Dinlenme tamamlandı';

  @override
  String get todayRestTimerNotificationBody => 'Sonraki sete başla.';

  @override
  String get todayRestTimerNotificationScheduled =>
      'Arka plan uyarısı zamanlandı.';

  @override
  String get todayRestTimerNotificationPermissionDenied =>
      'Arka plan dinlenme uyarısı için bildirimleri aç.';

  @override
  String get todayRestTimerNotificationUnsupported =>
      'Bu cihazda arka plan uyarısı yok.';

  @override
  String get todayRestTimerNotificationFailed =>
      'Arka plan uyarısı zamanlanamadı.';

  @override
  String get todayRestTimerNotificationSkipped =>
      'Dinlenme uyarısı gerekmiyor.';
}
