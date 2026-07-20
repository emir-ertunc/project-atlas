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
      'Review workout history, inspect set results, and track personal records.';

  @override
  String get progressHistoryTitle => 'Workout history';

  @override
  String get progressHistoryEmptyTitle => 'No workout history yet';

  @override
  String get progressHistoryEmptyMessage =>
      'Complete sets from the Today tab to build your local history.';

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
      'Select a set from workout history to inspect its result.';

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
      'Saving a correction adds a new revision. Earlier logs stay preserved.';

  @override
  String get progressCorrectionUnavailable =>
      'Only completed sets with a logged result can be corrected.';

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
      'No personal records yet. Complete clean sets with reps or load to start tracking records.';

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

  @override
  String get exerciseCatalogTitle => 'Exercise catalog';

  @override
  String get exerciseCatalogSearchLabel => 'Search exercises';

  @override
  String get exerciseCatalogSearchHint =>
      'Search by exercise, muscle, equipment, or cue';

  @override
  String get exerciseCatalogFiltersTitle => 'Filters';

  @override
  String get exerciseCatalogClearFilters => 'Clear';

  @override
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount) {
    return 'Showing $visibleCount of $totalCount exercises';
  }

  @override
  String get exerciseCatalogLoading => 'Loading exercise catalog...';

  @override
  String get exerciseCatalogLoadError =>
      'Exercise catalog could not be loaded.';

  @override
  String get exerciseCatalogEmptyTitle => 'No exercises match';

  @override
  String get exerciseCatalogEmptyMessage =>
      'Adjust search or filters to see exercises.';

  @override
  String get exerciseCatalogMovementFilter => 'Movement';

  @override
  String get exerciseCatalogMuscleFilter => 'Muscle';

  @override
  String get exerciseCatalogEquipmentFilter => 'Equipment';

  @override
  String get exerciseCatalogLevelFilter => 'Level';

  @override
  String get exerciseCatalogLateralityFilter => 'Laterality';

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
  String get exerciseDetailCommonErrors => 'Common errors';

  @override
  String get exerciseDetailSubstitutions => 'Substitutions';

  @override
  String get exerciseDetailRegressions => 'Regressions';

  @override
  String get exerciseDetailPrimaryMuscles => 'Primary muscles';

  @override
  String get exerciseDetailSecondaryMuscles => 'Secondary muscles';

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
      'This exercise is not available in the local catalog.';

  @override
  String get programWorkspaceBuilderTab => 'Builder';

  @override
  String get programWorkspaceCatalogTab => 'Catalog';

  @override
  String get programBuilderTitle => 'Program builder';

  @override
  String get programBuilderEmptyTitle => 'Create a program draft';

  @override
  String get programBuilderEmptyMessage =>
      'Start with a name and one training day, then add exercises and prescription targets.';

  @override
  String get programBuilderCreateProgram => 'Create program';

  @override
  String get programBuilderDefaultProgramName => 'New program';

  @override
  String programBuilderDefaultDayName(int dayNumber) {
    return 'Day $dayNumber';
  }

  @override
  String get programBuilderProgramNameLabel => 'Program name';

  @override
  String get programBuilderLocalDraftLabel => 'Local draft';

  @override
  String get programBuilderScopeNote =>
      'This draft keeps days, exercise order, and local prescription targets. Persistence and versioning are later checklist items.';

  @override
  String programBuilderSummary(int dayCount, int exerciseCount) {
    return '$dayCount days · $exerciseCount exercises';
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
      'Search by exercise, muscle, equipment, or cue';

  @override
  String get programBuilderExercisePickerEmpty =>
      'No exercises match this search.';

  @override
  String get programBuilderExerciseAlreadyAdded => 'Added';

  @override
  String get programBuilderEmptyDayTitle => 'No exercises yet';

  @override
  String get programBuilderEmptyDayMessage =>
      'Add catalog exercises, then order them for this training day.';

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
      'RIR is optional and independent from fixed or ranged repetitions.';

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
  String get programBuilderPublishVersion => 'Publish version';

  @override
  String get programBuilderCopyProgram => 'Copy program';

  @override
  String get programBuilderArchiveProgram => 'Archive program';

  @override
  String get programBuilderLifecycleStatusLocal =>
      'Local draft · not saved yet';

  @override
  String programBuilderLifecycleStatusSaved(int versionNumber) {
    return 'Saved draft · version $versionNumber';
  }

  @override
  String programBuilderLifecycleStatusPublished(int versionNumber) {
    return 'Published · active version $versionNumber';
  }

  @override
  String programBuilderLifecycleStatusArchived(int versionNumber) {
    return 'Archived · last version $versionNumber';
  }

  @override
  String get programBuilderDraftSaved => 'Program draft saved.';

  @override
  String get programBuilderVersionPublished =>
      'Immutable program version published.';

  @override
  String get programBuilderProgramCopied =>
      'Program copied as a new local draft.';

  @override
  String get programBuilderProgramArchived => 'Program archived.';

  @override
  String get programBuilderPersistenceFailed =>
      'Program could not be saved. Check the local draft and try again.';

  @override
  String programBuilderCopiedProgramName(String programName) {
    return '$programName copy';
  }

  @override
  String get todayScreenSubtitle =>
      'Start the next local workout from your active program.';

  @override
  String get todayNoActiveProgramTitle => 'No active program yet';

  @override
  String get todayNoActiveProgramMessage =>
      'Publish a program version in the Program tab before starting a workout.';

  @override
  String get todayOpenProgramBuilder => 'Open Program';

  @override
  String todayActiveProgramSummary(int versionNumber, int dayCount) {
    return 'Active version $versionNumber · $dayCount training days';
  }

  @override
  String get todayChooseTrainingDay => 'Choose training day';

  @override
  String todayTrainingDaySummary(int exerciseCount, int setCount) {
    return '$exerciseCount exercises · $setCount planned sets';
  }

  @override
  String get todayStartWorkout => 'Start workout';

  @override
  String get todaySessionStarted => 'Workout session started.';

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
  String get todayNoExercisesTitle => 'No exercises on this day';

  @override
  String get todayNoExercisesMessage =>
      'Add exercises to this training day before starting a session.';

  @override
  String get todaySessionInProgressTitle => 'Session in progress';

  @override
  String todaySessionInProgressSummary(int exerciseCount, int setCount) {
    return '$exerciseCount exercises · $setCount planned sets';
  }

  @override
  String get todaySessionInProgressMessage =>
      'Record each set as you finish it. Completed sets are saved locally with their actual result.';

  @override
  String get todaySessionRestoredMessage =>
      'This in-progress workout was restored from local storage.';

  @override
  String todaySessionStatusLabel(String status) {
    return 'Session status: $status';
  }

  @override
  String todayExerciseStatusLabel(String status) {
    return 'Exercise status: $status';
  }

  @override
  String todaySetStatusLabel(String status) {
    return 'Set status: $status';
  }

  @override
  String get todayStatusPending => 'Pending';

  @override
  String get todayStatusNotStarted => 'Not started';

  @override
  String get todayStatusInProgress => 'In progress';

  @override
  String get todayStatusSuccessful => 'Successful';

  @override
  String get todayStatusTargetMet => 'Target met';

  @override
  String get todayStatusNeedsReview => 'Needs review';

  @override
  String get todayStatusPerformanceMiss => 'Performance miss';

  @override
  String get todayStatusInterrupted => 'Interrupted';

  @override
  String get todayStatusPainReported => 'Pain reported';

  @override
  String get todayStatusNotComparable => 'Logged, not comparable';

  @override
  String todaySetProgressSummary(int completedSetCount, int setCount) {
    return '$completedSetCount of $setCount sets completed';
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
  String get todayActualRepetitionsLabel => 'Actual reps';

  @override
  String get todayActualLoadLabel => 'Actual load';

  @override
  String get todayActualRirLabel => 'Actual RIR';

  @override
  String get todayOutcomeLabel => 'Outcome';

  @override
  String get todayOutcomeNone => 'No limitation';

  @override
  String get todayOutcomeStrengthLimitation => 'Strength limitation';

  @override
  String get todayOutcomeTechniqueLimitation => 'Technique limitation';

  @override
  String get todayOutcomePain => 'Pain';

  @override
  String get todayOutcomeTimeLimitation => 'Time limitation';

  @override
  String get todayOutcomeEquipmentLimitation => 'Equipment limitation';

  @override
  String get todayOutcomeExternalInterruption => 'External interruption';

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
  String get todaySetPrescriptionUnavailable => 'Target unavailable';

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
  String get todayPreviousPerformanceUnavailable =>
      'Previous: no logged set yet';

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
  String get todaySetLogFailed => 'Set could not be logged.';

  @override
  String get todaySetLogInvalid => 'Enter valid reps, load, and RIR values.';

  @override
  String get todayQuickLoadDecrease => 'Decrease load';

  @override
  String get todayQuickLoadIncrease => 'Increase load';

  @override
  String get todayRestTimerTitle => 'Rest timer';

  @override
  String todayRestTimerRunning(
    String exerciseName,
    int setNumber,
    String remainingTime,
  ) {
    return 'Rest after $exerciseName set $setNumber: $remainingTime';
  }

  @override
  String get todayRestTimerComplete =>
      'Rest complete. Start the next set when ready.';

  @override
  String get todayRestTimerDismiss => 'Dismiss';

  @override
  String get todayRestTimerNotificationTitle => 'Rest complete';

  @override
  String get todayRestTimerNotificationBody => 'Time for your next set.';

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
