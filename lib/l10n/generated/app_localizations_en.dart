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
  String get progressScreenSubtitle =>
      'Track streaks, records, trends, and body changes.';

  @override
  String get progressDashboardPathTitle => 'Progress path';

  @override
  String get progressDashboardPathDescription => 'Train, log, compare, repeat.';

  @override
  String progressDashboardStreakValue(int dayCount) {
    return '${dayCount}d';
  }

  @override
  String get progressDashboardStreakEmpty => 'Start streak';

  @override
  String progressDashboardStreakStatus(String streakValue) {
    return 'Streak $streakValue';
  }

  @override
  String progressDashboardWeekStatus(int completedCount) {
    return 'Week $completedCount/7d';
  }

  @override
  String get progressDashboardLocalFeedbackStart => 'Start the loop';

  @override
  String get progressDashboardLocalFeedbackStreak => 'Local momentum';

  @override
  String get progressDashboardLocalFeedbackWeek => 'Week on track';

  @override
  String get progressDashboardLocalFeedbackComplete => 'Milestones complete';

  @override
  String progressDashboardLocalFeedbackNext(String milestoneLabel) {
    return 'Next: $milestoneLabel';
  }

  @override
  String progressDashboardMilestoneSummary(int completedCount, int totalCount) {
    return '$completedCount/$totalCount milestones';
  }

  @override
  String get progressDashboardMilestonesTitle => 'Milestones';

  @override
  String get progressDashboardMilestoneFirstWorkout => 'First workout';

  @override
  String get progressDashboardMilestoneWeekRhythm => '2 days this week';

  @override
  String get progressDashboardMilestoneFirstRecord => 'First record';

  @override
  String get progressDashboardMilestoneBodyComparison => 'Body comparison';

  @override
  String get progressDashboardRecordBoardTitle => 'Top records';

  @override
  String progressDashboardRecordBoardSummary(int recordCount) {
    return '$recordCount tracked';
  }

  @override
  String get progressDashboardRecordBoardEmpty =>
      'Log clean sets to build records.';

  @override
  String get progressDashboardTrendEmpty =>
      'Log two data points to show a trend.';

  @override
  String get progressDashboardMeasurementEmpty =>
      'Save two measurements to compare.';

  @override
  String progressDashboardMeasurementComparisonCount(int comparisonCount) {
    return '$comparisonCount comparisons';
  }

  @override
  String get progressDashboardOpenRecords => 'Records';

  @override
  String get progressDashboardOpenTrends => 'Trends';

  @override
  String get progressDashboardOpenMeasurements => 'Compare';

  @override
  String get progressHistoryTitle => 'Workout history';

  @override
  String get progressHistoryEmptyTitle => 'No history yet';

  @override
  String get progressHistoryEmptyMessage =>
      'Complete a set from Today to start history.';

  @override
  String get progressHistoryLoadError => 'Workout history could not load.';

  @override
  String get progressUnnamedSession => 'Workout session';

  @override
  String progressSessionSummary(
    String status,
    int completedSetCount,
    int setCount,
  ) {
    return '$status · $completedSetCount of $setCount sets logged';
  }

  @override
  String progressSetButtonLabel(String exerciseName, int setNumber) {
    return '$exerciseName set $setNumber';
  }

  @override
  String get progressSetDetailsTitle => 'Set details';

  @override
  String get progressSetDetailsEmpty =>
      'Select a history set to inspect results.';

  @override
  String progressSetDetailSession(String sessionName, String dateTime) {
    return '$sessionName · $dateTime';
  }

  @override
  String progressSetDetailStatus(String status) {
    return 'Status: $status';
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
    return '$revisionCount revisions';
  }

  @override
  String get progressNoActualLog => 'No actual result logged';

  @override
  String get progressRevisionHistoryTitle => 'Revision history';

  @override
  String progressRevisionRow(int revision, String result) {
    return 'Revision $revision: $result';
  }

  @override
  String progressRevisionSupersedes(String logId) {
    return 'Supersedes $logId';
  }

  @override
  String get progressCorrectionTitle => 'Correct logged result';

  @override
  String get progressCorrectionDescription =>
      'Save a correction as a new revision; earlier logs stay preserved.';

  @override
  String get progressCorrectionUnavailable =>
      'Only completed logged sets can be corrected.';

  @override
  String get progressCorrectionRepetitionsLabel => 'Corrected reps';

  @override
  String get progressCorrectionLoadLabel => 'Corrected load';

  @override
  String get progressCorrectionRirLabel => 'Corrected RIR';

  @override
  String get progressCorrectionOutcomeLabel => 'Corrected outcome';

  @override
  String get progressCorrectionSave => 'Save correction';

  @override
  String get progressCorrectionSaved => 'Correction saved as a new revision.';

  @override
  String get progressCorrectionFailed => 'Correction could not be saved.';

  @override
  String get progressCorrectionInvalid =>
      'Enter valid reps, load, and RIR values.';

  @override
  String get progressPersonalRecordsTitle => 'Personal records';

  @override
  String get progressPersonalRecordsEmpty =>
      'Log clean sets with reps or load to start records.';

  @override
  String get progressTrendsTitle => 'Trends';

  @override
  String get progressTrendsDescription =>
      'Built locally from measurements and clean set logs. Strength is an estimate.';

  @override
  String get progressMeasurementTrendsTitle => 'Measurements';

  @override
  String get progressTrainingTrendsTitle => 'Training';

  @override
  String get progressMeasurementHistoryTitle => 'Measurements';

  @override
  String get progressMeasurementHistoryDescription =>
      'Compare saved measurements or copy an export when needed.';

  @override
  String get progressMeasurementComparisonTitle => 'First vs latest';

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
  String get progressMeasurementSideComparisonTitle => 'Latest side comparison';

  @override
  String progressMeasurementSideComparisonLine(
    String pair,
    String left,
    String right,
    String difference,
    String percent,
  ) {
    return '$pair: left $left / right $right ($difference, $percent%)';
  }

  @override
  String get progressMeasurementPairUpperArm => 'Upper arm';

  @override
  String get progressMeasurementPairForearm => 'Forearm';

  @override
  String get progressMeasurementPairThigh => 'Thigh';

  @override
  String get progressMeasurementPairCalf => 'Calf';

  @override
  String get progressMeasurementExportTitle => 'Measurement export';

  @override
  String get progressMeasurementExportDescription =>
      'Exports contain personal measurement data. Store them only where you trust.';

  @override
  String progressMeasurementExportCount(int recordCount) {
    return '$recordCount measurement records available';
  }

  @override
  String get progressMeasurementExportCopyCsv => 'Copy CSV';

  @override
  String get progressMeasurementExportCopyJson => 'Copy JSON';

  @override
  String get progressMeasurementExportCopiedCsv => 'Measurement CSV copied.';

  @override
  String get progressMeasurementExportCopiedJson => 'Measurement JSON copied.';

  @override
  String progressTrendLine(
    String metric,
    String latest,
    String change,
    int pointCount,
  ) {
    return '$metric: $latest ($change, $pointCount points)';
  }

  @override
  String get progressTrendNoChange => 'no change';

  @override
  String get progressTrendHeight => 'Height';

  @override
  String get progressTrendWeight => 'Weight';

  @override
  String get progressTrendTorsoLength => 'Torso length';

  @override
  String get progressTrendChest => 'Chest';

  @override
  String get progressTrendWaist => 'Waist';

  @override
  String get progressTrendHips => 'Hips';

  @override
  String get progressTrendLeftUpperArm => 'Left upper arm';

  @override
  String get progressTrendRightUpperArm => 'Right upper arm';

  @override
  String get progressTrendLeftForearm => 'Left forearm';

  @override
  String get progressTrendRightForearm => 'Right forearm';

  @override
  String get progressTrendLeftThigh => 'Left thigh';

  @override
  String get progressTrendRightThigh => 'Right thigh';

  @override
  String get progressTrendLeftCalf => 'Left calf';

  @override
  String get progressTrendRightCalf => 'Right calf';

  @override
  String get progressTrendBodyFat => 'Body fat';

  @override
  String get progressTrendVolume => 'Volume';

  @override
  String get progressTrendLoad => 'Load';

  @override
  String get progressTrendRepetitions => 'Repetitions';

  @override
  String get progressTrendEstimatedStrength => 'Estimated strength';

  @override
  String progressBestLoad(String load) {
    return 'Best load: $load';
  }

  @override
  String progressBestRepetitions(int repetitions) {
    return 'Best reps: $repetitions';
  }

  @override
  String progressBestVolume(String volume) {
    return 'Best volume: $volume';
  }

  @override
  String get settingsNavigationLabel => 'Profile';

  @override
  String get onboardingTitle => 'Planner setup';

  @override
  String get onboardingDescription =>
      'Save local inputs before plan recommendations.';

  @override
  String get onboardingGoalLabel => 'Goal';

  @override
  String get onboardingExperienceLabel => 'Experience';

  @override
  String get onboardingEquipmentLabel => 'Equipment';

  @override
  String get onboardingSessionLengthLabel => 'Session length';

  @override
  String get onboardingWeekdaysLabel => 'Training days';

  @override
  String get onboardingSaveButton => 'Save';

  @override
  String get onboardingSavedMessage => 'Setup saved.';

  @override
  String get onboardingSaveFailed => 'Setup could not be saved.';

  @override
  String get onboardingLoadError => 'Setup could not load.';

  @override
  String onboardingSessionLengthValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String onboardingSavedSummary(
    String goal,
    String experience,
    int minutes,
    String weekdays,
    String equipment,
  ) {
    return 'Saved: $goal, $experience, $minutes minutes, $weekdays. Equipment: $equipment.';
  }

  @override
  String get setupWizardTitle => 'Setup';

  @override
  String get setupWizardDescription =>
      'Answer five quick steps for local planning.';

  @override
  String setupWizardStepCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String get setupWizardBackButton => 'Back';

  @override
  String get setupWizardNextButton => 'Continue';

  @override
  String get setupWizardReviewButton => 'Review';

  @override
  String get setupWizardSaveButton => 'Save';

  @override
  String get setupWizardSavedMessage => 'Setup saved.';

  @override
  String get setupWizardSavedStatus => 'Saved';

  @override
  String get setupWizardSavedDescription =>
      'Goal, gear, days, and availability stay local.';

  @override
  String get setupWizardSelectedStatus => 'Selected';

  @override
  String get setupWizardGoalStepTitle => 'Pick goal';

  @override
  String get setupWizardGoalStepShort => 'Goal';

  @override
  String get setupWizardGoalStepDescription =>
      'Set the first planning bias; change it later.';

  @override
  String get setupWizardExperienceStepTitle => 'Pick level';

  @override
  String get setupWizardExperienceStepShort => 'Level';

  @override
  String get setupWizardExperienceStepDescription =>
      'Level sets the conservative starting volume.';

  @override
  String get setupWizardEquipmentStepTitle => 'Pick gear';

  @override
  String get setupWizardEquipmentStepShort => 'Gear';

  @override
  String get setupWizardEquipmentStepDescription =>
      'Choose gear you can use most weeks.';

  @override
  String get setupWizardAvailabilityStepTitle => 'Pick training days';

  @override
  String get setupWizardAvailabilityStepShort => 'Days';

  @override
  String get setupWizardAvailabilityStepDescription =>
      'Pick days, then mark each window fixed or flexible.';

  @override
  String get setupWizardAvailabilityWindowHint =>
      'Flexible gives room; fixed protects appointments.';

  @override
  String setupWizardAvailabilityReview(int dayCount, int minutes) {
    return '$dayCount days, $minutes min default';
  }

  @override
  String get setupWizardMeasurementsStepTitle => 'Pick measurement flow';

  @override
  String get setupWizardMeasurementsStepShort => 'Measure';

  @override
  String get setupWizardMeasurementsStepDescription =>
      'Choose how much guidance you want first.';

  @override
  String get setupWizardMeasurementGuidedTitle => 'Guided entry';

  @override
  String get setupWizardMeasurementGuidedDescription =>
      'Use body-area steps for the best estimate.';

  @override
  String get setupWizardMeasurementEssentialsTitle => 'Essentials first';

  @override
  String get setupWizardMeasurementEssentialsDescription =>
      'Start with height, weight, and key circumferences.';

  @override
  String get setupWizardMeasurementLaterTitle => 'Later';

  @override
  String get setupWizardMeasurementLaterDescription =>
      'Skip prompts for now and keep the estimate generic.';

  @override
  String get setupWizardMeasurementPrivacyNote =>
      'No measurement value is saved in this step.';

  @override
  String get setupWizardReviewStepTitle => 'Review';

  @override
  String get setupWizardReviewStepShort => 'Review';

  @override
  String get setupWizardReviewStepDescription =>
      'Confirm inputs before planning.';

  @override
  String get onboardingGoalGeneralFitness => 'General fitness';

  @override
  String get onboardingGoalHypertrophy => 'Hypertrophy';

  @override
  String get onboardingGoalMaximumStrength => 'Maximum strength';

  @override
  String get onboardingGoalBodyRecomposition => 'Body recomposition';

  @override
  String get onboardingGoalMuscularEndurance => 'Muscular endurance';

  @override
  String get onboardingGoalAthleticPerformance => 'Athletic performance';

  @override
  String get onboardingGoalMaintenance => 'Maintenance';

  @override
  String get onboardingExperienceNewToTraining => 'New to training';

  @override
  String get onboardingExperienceBeginner => 'Beginner';

  @override
  String get onboardingExperienceIntermediate => 'Intermediate';

  @override
  String get onboardingExperienceAdvanced => 'Advanced';

  @override
  String get onboardingEquipmentBodyweight => 'Bodyweight';

  @override
  String get onboardingEquipmentDumbbells => 'Dumbbells';

  @override
  String get onboardingEquipmentBarbell => 'Barbell';

  @override
  String get onboardingEquipmentMachines => 'Machines';

  @override
  String get onboardingEquipmentCableStation => 'Cable station';

  @override
  String get onboardingEquipmentKettlebell => 'Kettlebell';

  @override
  String get onboardingEquipmentResistanceBands => 'Resistance bands';

  @override
  String get onboardingEquipmentCardio => 'Cardio equipment';

  @override
  String get onboardingWeekdayMonday => 'Monday';

  @override
  String get onboardingWeekdayTuesday => 'Tuesday';

  @override
  String get onboardingWeekdayWednesday => 'Wednesday';

  @override
  String get onboardingWeekdayThursday => 'Thursday';

  @override
  String get onboardingWeekdayFriday => 'Friday';

  @override
  String get onboardingWeekdaySaturday => 'Saturday';

  @override
  String get onboardingWeekdaySunday => 'Sunday';

  @override
  String get calibrationBlockTitle => 'Conservative calibration block';

  @override
  String get calibrationBlockDescription =>
      'Use this first block to find repeatable starting loads before recommendations change future training.';

  @override
  String calibrationBlockSummary(
    int weeks,
    int sessionsPerWeek,
    int minimumRir,
  ) {
    return '$weeks weeks - $sessionsPerWeek sessions/week - keep at least RIR $minimumRir';
  }

  @override
  String calibrationBlockSessionTarget(int minutes, String weekdays) {
    return '$minutes minute target sessions on $weekdays';
  }

  @override
  String get calibrationBlockNoProgression =>
      'No load increases during calibration; collect clean set evidence first.';

  @override
  String calibrationWeekSummary(
    int weekNumber,
    String focus,
    int volumePercent,
    int minimumRir,
  ) {
    return 'Week $weekNumber: $focus - $volumePercent% planned volume - RIR $minimumRir+';
  }

  @override
  String calibrationExitRequirements(String requirements) {
    return 'Advance only after: $requirements.';
  }

  @override
  String get calibrationFocusTechniqueBaseline => 'technique baseline';

  @override
  String get calibrationFocusRepeatableExecution => 'repeatable execution';

  @override
  String get calibrationFocusStableExposure => 'stable exposure';

  @override
  String get calibrationFocusPrescriptionPreview => 'prescription preview';

  @override
  String get calibrationExitPlannedWeeksCompleted =>
      'planned weeks are completed';

  @override
  String get calibrationExitNoPainReports => 'no pain reports';

  @override
  String get calibrationExitNoRepeatedPerformanceMisses =>
      'no repeated performance misses';

  @override
  String get calibrationExitStableRirEvidence => 'RIR evidence is stable';

  @override
  String get availabilityTitle => 'Weekly availability';

  @override
  String get availabilityDescription =>
      'Choose when training can fit each week. Fixed periods are hard appointments; flexible periods give the planner room to place a session inside the window.';

  @override
  String get availabilityFixedPeriod => 'Fixed';

  @override
  String get availabilityFlexiblePeriod => 'Flexible';

  @override
  String get availabilityStartTimeLabel => 'Start';

  @override
  String get availabilityEndTimeLabel => 'End';

  @override
  String availabilityWindowSummary(
    String type,
    String startTime,
    String endTime,
  ) {
    return '$type window from $startTime to $endTime';
  }

  @override
  String get availabilitySaveButton => 'Save availability';

  @override
  String get availabilitySavedMessage => 'Weekly availability saved.';

  @override
  String get availabilitySaveFailed =>
      'Weekly availability could not be saved.';

  @override
  String get availabilityLoadError => 'Weekly availability could not load.';

  @override
  String get availabilityLoading => 'Weekly availability loading...';

  @override
  String get generatedProgramTitle => 'Draft planner';

  @override
  String get generatedProgramDescription =>
      'Build an editable draft from setup, availability, gear, recovery, and volume rules.';

  @override
  String get generatedProgramAvailabilityRequired =>
      'Save availability before building a draft.';

  @override
  String get generatedProgramCatalogLoadError =>
      'Catalog could not load, so the draft cannot build.';

  @override
  String get generatedProgramNoPlan =>
      'No plan matches saved gear. Add equipment or update availability.';

  @override
  String generatedProgramSummary(
    int sessionsPerWeek,
    int weeklySetTarget,
    int maxExercisesPerSession,
    int minimumRir,
  ) {
    return '$sessionsPerWeek/wk · $weeklySetTarget sets · max $maxExercisesPerSession/session · RIR $minimumRir+';
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
    return '$weekday · $windowType $startTime-$endTime · $exerciseCount exercises · $setCount sets';
  }

  @override
  String generatedProgramExerciseSummary(
    int setCount,
    int minimumRepetitions,
    int maximumRepetitions,
    int targetRir,
    int restSeconds,
  ) {
    return '$setCount sets · $minimumRepetitions-$maximumRepetitions reps · RIR $targetRir · $restSeconds sec';
  }

  @override
  String get generatedProgramApplyDraft => 'Use draft';

  @override
  String get generatedProgramAppliedMessage =>
      'Draft applied. Open Program to edit, save, or publish.';

  @override
  String get generatedProgramReplaceDraftTitle => 'Replace draft?';

  @override
  String get generatedProgramReplaceDraftMessage =>
      'This replaces the unsaved Program draft. Saved versions stay unchanged.';

  @override
  String get generatedProgramReplaceDraftCancel => 'Keep draft';

  @override
  String get generatedProgramReplaceDraftConfirm => 'Replace draft';

  @override
  String generatedProgramDraftName(String goal) {
    return '$goal draft';
  }

  @override
  String get generatedProgramFocusFullBody => 'Full body';

  @override
  String get generatedProgramFocusUpperEmphasis => 'Upper emphasis';

  @override
  String get generatedProgramFocusLowerEmphasis => 'Lower emphasis';

  @override
  String get generatedProgramFocusPosteriorChain => 'Posterior chain';

  @override
  String get generatedProgramFocusConditioningSupport => 'Conditioning support';

  @override
  String get missedSessionReplacementTitle => 'Missed-session replacement';

  @override
  String get missedSessionReplacementDescription =>
      'Choose a missed planned day to preview the safest available replacement window. This does not move or publish any workout.';

  @override
  String get missedSessionReplacementAvailabilityRequired =>
      'Save weekly availability before previewing a replacement window.';

  @override
  String get missedSessionReplacementMissedDayLabel => 'Missed planned day';

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
    return 'Suggested: $weekday, $windowType $startTime-$endTime. This is $dayOffset days after the missed session and keeps at least $recoveryHours hours between planned sessions.';
  }

  @override
  String get missedSessionReplacementNoSafeWindow =>
      'No safe replacement window is available from the saved weekly availability.';

  @override
  String get missedSessionReplacementNoSafeWindowWithDuration =>
      'No safe replacement window is available with enough time for the planned session.';

  @override
  String missedSessionReplacementNoSafeWindowWithRecovery(int recoveryHours) {
    return 'No safe replacement window keeps the required $recoveryHours hours of recovery around remaining planned sessions.';
  }

  @override
  String get missedSessionReplacementMissingDay =>
      'The selected planned day is no longer available. Rebuild the program preview and try again.';

  @override
  String get anatomyRendererTitle => 'Anatomy viewer';

  @override
  String get anatomyRendererDescription =>
      'Android builds use the native viewer; assets ship at the bundling checkpoint.';

  @override
  String get anatomyInteractionInstructions =>
      'Drag, pinch, or tap a region. Heatmaps use muscle IDs until GLB ships.';

  @override
  String get anatomyOverlayVisualEstimate => 'Visual estimate';

  @override
  String get anatomyOverlayTapToInspect => 'Tap a region';

  @override
  String get anatomyMeasurementPromptTitle => 'Add measurements';

  @override
  String get anatomyMeasurementPromptDescription =>
      'Add guided measurements before relying on shape changes.';

  @override
  String get anatomyMeasurementPromptAction => 'Guide';

  @override
  String get anatomyVisualEstimateLabel =>
      'Visual estimate, not a medical scan';

  @override
  String get anatomyVisualEstimateDescription =>
      'Built from saved measurements and training data. It cannot diagnose health, injury, disease, or body composition.';

  @override
  String get anatomyVisualEstimateInputNote =>
      'Use it for trends; re-check saved inputs if it looks wrong.';

  @override
  String get anatomyVisualEstimateIconLabel => 'Visual estimate information';

  @override
  String get anatomyRendererContentDescription =>
      'Interactive anatomy renderer';

  @override
  String get anatomyRendererAndroidOnly =>
      'The native viewer runs on Android builds. This environment shows a safe fallback.';

  @override
  String get anatomyRendererPerformanceFallback =>
      'Safe preview is active until assets and device metrics pass.';

  @override
  String get anatomyRendererStatusLoading => 'Checking viewer...';

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
  String get anatomyRendererResetCamera => 'Reset view';

  @override
  String get anatomyRendererPreviewHeatmap => 'Preview heatmap';

  @override
  String get anatomyRendererNoRegionSelected => 'Tap a muscle region';

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

  @override
  String get anatomyTrainingHeatmapTitle => 'Muscle heatmaps';

  @override
  String get anatomyTrainingHeatmapDescription =>
      'Review trained muscles, volume, or fatigue from the last 7 days.';

  @override
  String get anatomyTrainingHeatmapTrainedMuscle => 'Trained muscles';

  @override
  String get anatomyTrainingHeatmapWeeklyVolume => 'Weekly volume';

  @override
  String get anatomyTrainingHeatmapFatigue => 'Fatigue';

  @override
  String get anatomyTrainingHeatmapLoading => 'Loading heatmaps...';

  @override
  String get anatomyTrainingHeatmapLoadError => 'Heatmaps could not load.';

  @override
  String get anatomyTrainingHeatmapEmpty =>
      'Complete workouts to show 7-day heatmaps.';

  @override
  String anatomyTrainingHeatmapSummary(int regionCount, String topRegionId) {
    return '$regionCount regions - strongest $topRegionId';
  }

  @override
  String get exerciseCatalogTitle => 'Exercise catalog';

  @override
  String get exerciseCatalogSubtitle =>
      'Search, filter, and add to your draft.';

  @override
  String get exerciseCatalogSearchLabel => 'Search exercises';

  @override
  String get exerciseCatalogSearchHint => 'Name, muscle, gear, or cue';

  @override
  String get exerciseCatalogFiltersTitle => 'Filters';

  @override
  String get exerciseCatalogClearFilters => 'Clear';

  @override
  String get exerciseCatalogFilterButton => 'Filters';

  @override
  String get exerciseCatalogFilterSheetTitle => 'Filter exercises';

  @override
  String get exerciseCatalogApplyFilters => 'Show results';

  @override
  String get exerciseCatalogNoActiveFilters => 'No filters';

  @override
  String exerciseCatalogActiveFilterCount(int filterCount) {
    return '$filterCount filters';
  }

  @override
  String exerciseCatalogResultsTrend(int totalCount) {
    return 'of $totalCount';
  }

  @override
  String get exerciseCatalogAddToProgram => 'Add to program';

  @override
  String exerciseCatalogAddedToProgram(String exerciseName, String dayName) {
    return 'Added $exerciseName to $dayName.';
  }

  @override
  String exerciseCatalogCreatedDraftAndAdded(
    String exerciseName,
    String dayName,
  ) {
    return 'Draft created. Added $exerciseName to $dayName.';
  }

  @override
  String exerciseCatalogAlreadyInProgram(String exerciseName, String dayName) {
    return '$exerciseName is already on $dayName.';
  }

  @override
  String get exerciseCatalogAnimationAvailable => 'Animation ready';

  @override
  String get exerciseCatalogThumbnailOnly => 'Image guide';

  @override
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount) {
    return '$visibleCount/$totalCount exercises';
  }

  @override
  String get exerciseCatalogLoading => 'Loading catalog...';

  @override
  String get exerciseCatalogLoadError => 'Catalog could not load.';

  @override
  String get exerciseCatalogEmptyTitle => 'No matches';

  @override
  String get exerciseCatalogEmptyMessage => 'Change search or filters.';

  @override
  String get exerciseCatalogMovementFilter => 'Movement';

  @override
  String get exerciseCatalogMuscleFilter => 'Muscle';

  @override
  String get exerciseCatalogEquipmentFilter => 'Equipment';

  @override
  String get exerciseCatalogLevelFilter => 'Level';

  @override
  String get exerciseCatalogLateralityFilter => 'Side';

  @override
  String get exerciseCatalogTypeFilter => 'Type';

  @override
  String get exerciseDetailTitle => 'Exercise detail';

  @override
  String get exerciseDetailSetup => 'Setup';

  @override
  String get exerciseDetailExecution => 'Execution';

  @override
  String get exerciseDetailFormCues => 'Form cues';

  @override
  String get exerciseDetailCommonErrors => 'Avoid';

  @override
  String get exerciseDetailSubstitutions => 'Substitutions';

  @override
  String get exerciseDetailRegressions => 'Regressions';

  @override
  String get exerciseDetailPrimaryMuscles => 'Primary';

  @override
  String get exerciseDetailSecondaryMuscles => 'Secondary';

  @override
  String get exerciseDetailStabilizerMuscles => 'Stabilizers';

  @override
  String get exerciseDetailEquipment => 'Equipment';

  @override
  String get exerciseDetailLevel => 'Level';

  @override
  String get exerciseDetailLaterality => 'Laterality';

  @override
  String get exerciseDetailType => 'Type';

  @override
  String get exerciseDetailNotFoundTitle => 'Exercise not found';

  @override
  String get exerciseDetailNotFoundMessage =>
      'This exercise is not in the local catalog.';

  @override
  String get programHubSubtitle =>
      'Review the plan. Open focused routes to edit.';

  @override
  String get programHubNoActiveProgramTitle => 'No active plan';

  @override
  String get programHubNoActiveProgramMessage =>
      'Create or publish a plan before workouts can use it.';

  @override
  String get programHubCreateDraft => 'Create draft';

  @override
  String programHubActiveVersionSummary(int versionNumber, int dayCount) {
    return 'Version $versionNumber · $dayCount days';
  }

  @override
  String programHubPlanMetric(int dayCount, int setCount) {
    return '${dayCount}d · $setCount sets';
  }

  @override
  String get programHubActiveStatus => 'Active';

  @override
  String get programHubBuilderDescription =>
      'Edit days, order, targets, and publish state.';

  @override
  String get programHubCatalogDescription =>
      'Find exercises and add them without crowding the hub.';

  @override
  String get programHubRecommendationInboxTitle => 'Review queue';

  @override
  String get programHubRecommendationClearDescription =>
      'No recommendations need review.';

  @override
  String get programHubRecommendationClearCount => '0 pending';

  @override
  String get programHubRecommendationClearStatus => 'Clear';

  @override
  String get programHubTrainingDaysTitle => 'Training days';

  @override
  String get programHubTrainingDaysDescription =>
      'Tap a day to edit in Builder.';

  @override
  String programHubTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount exercises · $setCount sets';
  }

  @override
  String programHubMoreExercises(int exerciseCount) {
    return '+$exerciseCount more';
  }

  @override
  String get programHubLoadError => 'Program hub could not be loaded.';

  @override
  String get programWorkspaceBuilderTab => 'Builder';

  @override
  String get programWorkspaceCatalogTab => 'Catalog';

  @override
  String get programBuilderTitle => 'Builder';

  @override
  String get programBuilderEmptyTitle => 'Start a draft';

  @override
  String get programBuilderEmptyMessage =>
      'Name it, add a day, then add exercises.';

  @override
  String get programBuilderCreateProgram => 'Create';

  @override
  String get programBuilderDefaultProgramName => 'New program';

  @override
  String programBuilderDefaultDayName(int dayNumber) {
    return 'Day $dayNumber';
  }

  @override
  String get programBuilderProgramNameLabel => 'Program name';

  @override
  String get programBuilderGuidedSubtitle =>
      'Setup, days, catalog, targets, review.';

  @override
  String programBuilderStepProgress(int currentStep, int totalSteps) {
    return 'Step $currentStep/$totalSteps';
  }

  @override
  String get programBuilderBackStep => 'Back';

  @override
  String get programBuilderContinueStep => 'Continue';

  @override
  String get programBuilderStepComplete => 'Done';

  @override
  String get programBuilderStepOpen => 'Open';

  @override
  String get programBuilderSetupStepTitle => 'Setup';

  @override
  String get programBuilderSetupStepSubtitle => 'Name the draft first.';

  @override
  String get programBuilderDaysStepTitle => 'Days';

  @override
  String get programBuilderDaysStepSubtitle =>
      'Add, select, rename, or remove days.';

  @override
  String get programBuilderExercisesStepTitle => 'Exercises';

  @override
  String get programBuilderExercisesStepSubtitle =>
      'Search, add, and order this day.';

  @override
  String get programBuilderPrescriptionStepTitle => 'Targets';

  @override
  String get programBuilderPrescriptionStepSubtitle =>
      'Edit sets, reps, RIR, load, and rest.';

  @override
  String get programBuilderReviewStepTitle => 'Review';

  @override
  String get programBuilderReviewStepSubtitle =>
      'Check the draft before saving or publishing.';

  @override
  String get programBuilderPrescriptionEmpty =>
      'Add an exercise before editing targets.';

  @override
  String get programBuilderPrescriptionInlineHint =>
      'Targets stay on each exercise card.';

  @override
  String programBuilderPrescriptionReady(int exerciseCount) {
    return '$exerciseCount targets';
  }

  @override
  String get programBuilderPublishReviewMessage =>
      'Publish to make this the active workout version. Save draft to keep editing.';

  @override
  String get programBuilderReviewNameReady => 'Name ready';

  @override
  String get programBuilderReviewNameMissing => 'Name missing';

  @override
  String programBuilderReviewExercisesReady(int exerciseCount) {
    return '$exerciseCount exercises ready';
  }

  @override
  String get programBuilderReviewExercisesMissing => 'Add exercises';

  @override
  String get programBuilderPublishConfirmTitle => 'Publish version?';

  @override
  String get programBuilderPublishConfirmMessage =>
      'Make this draft the active workout version.';

  @override
  String get programBuilderPublishConfirmAction => 'Publish';

  @override
  String get programBuilderLocalDraftLabel => 'Local draft';

  @override
  String get programBuilderScopeNote =>
      'Save keeps the draft. Publish creates the active workout version.';

  @override
  String programBuilderSummary(int dayCount, int exerciseCount) {
    return '${dayCount}d · $exerciseCount exercises';
  }

  @override
  String get programBuilderTrainingDays => 'Training days';

  @override
  String get programBuilderAddTrainingDay => 'Add day';

  @override
  String get programBuilderSelectedDay => 'Selected day';

  @override
  String get programBuilderRenameDay => 'Rename day';

  @override
  String get programBuilderDeleteDay => 'Delete day';

  @override
  String get programBuilderRenameDayTitle => 'Rename training day';

  @override
  String get programBuilderDayNameLabel => 'Day name';

  @override
  String get programBuilderSave => 'Save';

  @override
  String get programBuilderCancel => 'Cancel';

  @override
  String get programBuilderAddExercise => 'Add exercise';

  @override
  String get programBuilderExercisePickerTitle => 'Add exercise';

  @override
  String get programBuilderExercisePickerSearchLabel => 'Search catalog';

  @override
  String get programBuilderExercisePickerSearchHint =>
      'Name, muscle, gear, or cue';

  @override
  String get programBuilderExercisePickerEmpty => 'No exercises match.';

  @override
  String get programBuilderExerciseAlreadyAdded => 'Added';

  @override
  String get programBuilderEmptyDayTitle => 'No exercises yet';

  @override
  String get programBuilderEmptyDayMessage =>
      'Add exercises, then order this day.';

  @override
  String get programBuilderMoveExerciseUp => 'Move up';

  @override
  String get programBuilderMoveExerciseDown => 'Move down';

  @override
  String get programBuilderRemoveExercise => 'Remove';

  @override
  String get programBuilderSetCountLabel => 'Sets';

  @override
  String get programBuilderFixedRepetitionMode => 'Fixed';

  @override
  String get programBuilderRangeRepetitionMode => 'Range';

  @override
  String get programBuilderFixedRepsLabel => 'Reps';

  @override
  String get programBuilderMinimumRepsLabel => 'Min reps';

  @override
  String get programBuilderMaximumRepsLabel => 'Max reps';

  @override
  String get programBuilderTargetRirEnabled => 'Track RIR';

  @override
  String get programBuilderTargetRirDescription =>
      'RIR is optional and independent from reps.';

  @override
  String get programBuilderTargetRirLabel => 'Target RIR';

  @override
  String get programBuilderLoadLabel => 'Load';

  @override
  String get programBuilderRestSecondsLabel => 'Rest';

  @override
  String get programBuilderSecondsSuffix => 'sec';

  @override
  String programBuilderFixedRepsSummary(int repetitions) {
    return '$repetitions reps';
  }

  @override
  String programBuilderRangeRepsSummary(
    int minimumRepetitions,
    int maximumRepetitions,
  ) {
    return '$minimumRepetitions-$maximumRepetitions reps';
  }

  @override
  String programBuilderRirSummary(int targetRir) {
    return 'RIR $targetRir';
  }

  @override
  String get programBuilderRirOff => 'RIR off';

  @override
  String get programBuilderLoadUnset => 'no load';

  @override
  String programBuilderPrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  ) {
    return '$setCount sets · $repetitionTarget · $rirTarget · $loadTarget · $restSeconds sec';
  }

  @override
  String get programBuilderSaveDraft => 'Save draft';

  @override
  String get programBuilderPublishVersion => 'Publish';

  @override
  String get programBuilderCopyProgram => 'Copy';

  @override
  String get programBuilderArchiveProgram => 'Archive';

  @override
  String get programBuilderLifecycleStatusLocal => 'Draft · unsaved';

  @override
  String programBuilderLifecycleStatusSaved(int versionNumber) {
    return 'Draft v$versionNumber';
  }

  @override
  String programBuilderLifecycleStatusPublished(int versionNumber) {
    return 'Active v$versionNumber';
  }

  @override
  String programBuilderLifecycleStatusArchived(int versionNumber) {
    return 'Archived v$versionNumber';
  }

  @override
  String get programBuilderDraftSaved => 'Program draft saved.';

  @override
  String get programBuilderVersionPublished => 'Program version published.';

  @override
  String get programBuilderProgramCopied => 'Program copied to a new draft.';

  @override
  String get programBuilderProgramArchived => 'Program archived.';

  @override
  String get programBuilderPersistenceFailed =>
      'Program could not be saved. Check the draft and retry.';

  @override
  String programBuilderCopiedProgramName(String programName) {
    return '$programName copy';
  }

  @override
  String get todayScreenSubtitle =>
      'Start the next workout from your active plan.';

  @override
  String get todayActiveWorkoutSubtitle => 'Log the current set first.';

  @override
  String get todayCoachDashboardSubtitle =>
      'Next session, streak, and review queue.';

  @override
  String get todayCoachResumeTitle => 'Workout active';

  @override
  String todayCoachNextWorkoutTitle(String dayName) {
    return 'Next: $dayName';
  }

  @override
  String get todayCoachNextWorkoutDescription => 'Start now or change the day.';

  @override
  String get todayCoachNoProgramTrend => 'Plan needed';

  @override
  String get todayCoachReadyStatus => 'Ready';

  @override
  String get todayCoachSetupStatus => 'Setup first';

  @override
  String get todayResumeWorkout => 'Resume';

  @override
  String get todayQuickStartWorkout => 'Start';

  @override
  String get todayCreateProgram => 'Create plan';

  @override
  String get todayOpenWorkoutDetails => 'Details';

  @override
  String get todayStreakTitle => 'Streak';

  @override
  String todayStreakValue(int dayCount) {
    return '$dayCount day streak';
  }

  @override
  String get todayStreakEmptyDescription =>
      'Complete a workout to start a streak.';

  @override
  String get todayStreakActiveDescription =>
      'Built from completed workout days.';

  @override
  String get todayWeeklyConsistencyTitle => 'Weekly consistency';

  @override
  String todayWeeklyConsistencyPercent(int percent) {
    return '$percent%';
  }

  @override
  String todayWeeklyConsistencyValue(int completedCount, int targetCount) {
    return '$completedCount of $targetCount sessions';
  }

  @override
  String get todayWeeklyConsistencyNoTarget =>
      'Create a plan to set the weekly target.';

  @override
  String get todayPendingRecommendationTitle => 'Review queue';

  @override
  String get todayPendingRecommendationActiveDescription =>
      'Review this status before future load changes.';

  @override
  String get todayPendingRecommendationNoProgramDescription =>
      'Create a plan before recommendations appear.';

  @override
  String get todayPendingRecommendationClearDescription =>
      'No recommendation needs review.';

  @override
  String todayPendingRecommendationPendingCount(int pendingCount) {
    return '$pendingCount pending';
  }

  @override
  String get todayPendingRecommendationClearCount => '0 pending';

  @override
  String get todayPendingRecommendationClearStatus => 'Clear';

  @override
  String get todaySessionRestoredStatus => 'Restored';

  @override
  String get todayNoActiveProgramTitle => 'No active plan';

  @override
  String get todayNoActiveProgramMessage =>
      'Publish a plan in Program before starting.';

  @override
  String get todayOpenProgramBuilder => 'Open Program';

  @override
  String todayActiveProgramSummary(int versionNumber, int dayCount) {
    return 'Version $versionNumber · $dayCount days';
  }

  @override
  String get todayChooseTrainingDay => 'Pick day';

  @override
  String todayTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount exercises · $setCount sets';
  }

  @override
  String get todayStartWorkout => 'Start';

  @override
  String get todaySessionStarted => 'Workout started.';

  @override
  String get todaySessionStartFailed => 'Workout could not be started.';

  @override
  String get todayLoadError => 'Today could not load.';

  @override
  String get todayRetry => 'Retry';

  @override
  String todayFixedRepetitions(int repetitions) {
    return '$repetitions reps';
  }

  @override
  String todayRangeRepetitions(int minimumRepetitions, int maximumRepetitions) {
    return '$minimumRepetitions-$maximumRepetitions reps';
  }

  @override
  String todayExercisePrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  ) {
    return '$setCount sets · $repetitionTarget · $rirTarget · $loadTarget · $restSeconds sec rest';
  }

  @override
  String get todayNoExercisesTitle => 'No exercises yet';

  @override
  String get todayNoExercisesMessage => 'Add exercises before starting.';

  @override
  String get todaySessionInProgressTitle => 'Workout active';

  @override
  String todaySessionInProgressSummary(int exerciseCount, int setCount) {
    return '$exerciseCount exercises · $setCount sets';
  }

  @override
  String get todaySessionInProgressMessage => 'Log each set as you finish.';

  @override
  String get todayCurrentSetTitle => 'Current set';

  @override
  String todayCurrentSetSubtitle(String exerciseName, int setNumber) {
    return '$exerciseName · set $setNumber';
  }

  @override
  String get todayWorkoutQueueTitle => 'Up next';

  @override
  String todayWorkoutQueueSetLabel(
    String exerciseName,
    int setNumber,
    String status,
  ) {
    return '$exerciseName · set $setNumber · $status';
  }

  @override
  String get todayWorkoutCompleteTitle => 'Workout logged';

  @override
  String get todayWorkoutCompleteMessage =>
      'All planned sets have results. Review before leaving.';

  @override
  String get todaySessionRestoredMessage =>
      'Workout restored from local storage.';

  @override
  String todaySessionStatusLabel(String status) {
    return 'Session: $status';
  }

  @override
  String todayExerciseStatusLabel(String status) {
    return 'Exercise: $status';
  }

  @override
  String todaySetStatusLabel(String status) {
    return 'Set: $status';
  }

  @override
  String get todayStatusPending => 'Pending';

  @override
  String get todayStatusNotStarted => 'Not started';

  @override
  String get todayStatusInProgress => 'In progress';

  @override
  String get todayStatusSuccessful => 'Done';

  @override
  String get todayStatusTargetMet => 'Hit target';

  @override
  String get todayStatusNeedsReview => 'Needs review';

  @override
  String get todayStatusPerformanceMiss => 'Missed target';

  @override
  String get todayStatusInterrupted => 'Interrupted';

  @override
  String get todayStatusPainReported => 'Pain reported';

  @override
  String get todayStatusNotComparable => 'Logged only';

  @override
  String todaySetProgressSummary(int completedSetCount, int setCount) {
    return '$completedSetCount/$setCount sets';
  }

  @override
  String todayExerciseActiveSetSummary(int setCount) {
    return '$setCount sets to log';
  }

  @override
  String todaySessionSetLabel(int setNumber) {
    return 'Set $setNumber';
  }

  @override
  String get todayActualRepetitionsLabel => 'Reps';

  @override
  String get todayActualLoadLabel => 'Load';

  @override
  String get todayActualRirLabel => 'RIR';

  @override
  String get todayOutcomeLabel => 'Outcome';

  @override
  String get todayOutcomeNone => 'No limit';

  @override
  String get todayOutcomeStrengthLimitation => 'Strength';

  @override
  String get todayOutcomeTechniqueLimitation => 'Technique';

  @override
  String get todayOutcomePain => 'Pain';

  @override
  String get todayOutcomeTimeLimitation => 'Time';

  @override
  String get todayOutcomeEquipmentLimitation => 'Equipment';

  @override
  String get todayOutcomeExternalInterruption => 'Interrupted';

  @override
  String get todayCompleteSet => 'Complete set';

  @override
  String todaySetPrescriptionSummary(
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
  ) {
    return 'Target: $repetitionTarget · $rirTarget · $loadTarget';
  }

  @override
  String get todaySetPrescriptionUnavailable => 'No target';

  @override
  String todayPreviousPerformanceSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  ) {
    return 'Previous: $repetitionTarget · $loadTarget · $rirTarget · $outcomeTarget';
  }

  @override
  String get todayPreviousPerformanceUnavailable => 'Previous: none yet';

  @override
  String get todayRepetitionsNotRecorded => 'reps not recorded';

  @override
  String todaySetActualSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  ) {
    return 'Logged: $repetitionTarget · $loadTarget · $rirTarget · $outcomeTarget';
  }

  @override
  String get todaySetLogSaved => 'Set logged.';

  @override
  String get todaySetLogFailed => 'Set could not save.';

  @override
  String get todaySetLogInvalid => 'Enter valid reps, load, and RIR values.';

  @override
  String get todayQuickLoadDecrease => 'Load down';

  @override
  String get todayQuickLoadIncrease => 'Load up';

  @override
  String get todayRestTimerTitle => 'Rest';

  @override
  String todayRestTimerRunning(
    String exerciseName,
    int setNumber,
    String remainingTime,
  ) {
    return 'Rest after $exerciseName set $setNumber: $remainingTime';
  }

  @override
  String get todayRestTimerComplete => 'Rest complete. Start the next set.';

  @override
  String get todayRestTimerDismiss => 'Close';

  @override
  String get todayRestTimerNotificationTitle => 'Rest complete';

  @override
  String get todayRestTimerNotificationBody => 'Start the next set.';

  @override
  String get todayRestTimerNotificationScheduled =>
      'Background alert scheduled.';

  @override
  String get todayRestTimerNotificationPermissionDenied =>
      'Enable notifications to receive rest alerts in the background.';

  @override
  String get todayRestTimerNotificationUnsupported =>
      'Background alert unavailable on this device.';

  @override
  String get todayRestTimerNotificationFailed =>
      'Background alert could not be scheduled.';

  @override
  String get todayRestTimerNotificationSkipped => 'No rest alert needed.';
}
