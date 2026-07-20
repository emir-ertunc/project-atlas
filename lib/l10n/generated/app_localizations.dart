import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Temporary product name shown in the application shell
  ///
  /// In en, this message translates to:
  /// **'Project Atlas'**
  String get appTitle;

  /// Label for the Today primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayNavigationLabel;

  /// Label for the Program primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get programNavigationLabel;

  /// Label for the Anatomy primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Anatomy'**
  String get anatomyNavigationLabel;

  /// Label for the Progress primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressNavigationLabel;

  /// Label for the Settings primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavigationLabel;

  /// Title for the anatomy renderer panel
  ///
  /// In en, this message translates to:
  /// **'3D anatomy renderer'**
  String get anatomyRendererTitle;

  /// Short explanation of the current anatomy renderer state
  ///
  /// In en, this message translates to:
  /// **'Android builds use a native Filament surface. GLB anatomy assets remain external until the bundling checkpoint.'**
  String get anatomyRendererDescription;

  /// Interaction help text shown above the anatomy renderer
  ///
  /// In en, this message translates to:
  /// **'Drag to rotate, pinch to zoom, and tap a region to select it. Heatmap preview uses semantic muscle IDs until the runtime GLB is bundled.'**
  String get anatomyInteractionInstructions;

  /// Accessibility label passed to the native Android renderer view
  ///
  /// In en, this message translates to:
  /// **'Interactive anatomy renderer'**
  String get anatomyRendererContentDescription;

  /// Fallback message shown outside Android
  ///
  /// In en, this message translates to:
  /// **'The native Filament renderer is available on Android builds. This environment shows a safe fallback.'**
  String get anatomyRendererAndroidOnly;

  /// Fallback message shown when the native anatomy renderer is disabled by the performance policy
  ///
  /// In en, this message translates to:
  /// **'Performance-safe semantic preview is active. The native renderer stays off until bundled assets and mid-range device metrics meet the threshold.'**
  String get anatomyRendererPerformanceFallback;

  /// Status shown while renderer capabilities are loading
  ///
  /// In en, this message translates to:
  /// **'Checking renderer bridge...'**
  String get anatomyRendererStatusLoading;

  /// Renderer capability summary
  ///
  /// In en, this message translates to:
  /// **'Renderer: {backend}; GLB: {glbStatus}; Asset: {assetStatus}'**
  String anatomyRendererStatus(
    String backend,
    String glbStatus,
    String assetStatus,
  );

  /// Renderer status text for supported GLB loading
  ///
  /// In en, this message translates to:
  /// **'supported'**
  String get anatomyRendererGlbSupported;

  /// Renderer status text for unavailable GLB loading
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get anatomyRendererGlbUnavailable;

  /// Renderer status text when the anatomy GLB is bundled
  ///
  /// In en, this message translates to:
  /// **'bundled'**
  String get anatomyRendererAssetBundled;

  /// Renderer status text when the anatomy GLB remains outside the application bundle
  ///
  /// In en, this message translates to:
  /// **'external'**
  String get anatomyRendererAssetExternal;

  /// Status text describing the active renderer performance policy
  ///
  /// In en, this message translates to:
  /// **'Performance policy: {mode}; LOD: {lodTier}'**
  String anatomyRendererPolicyStatus(String mode, String lodTier);

  /// Renderer mode label for the static semantic fallback
  ///
  /// In en, this message translates to:
  /// **'semantic fallback'**
  String get anatomyRendererModeStaticFallback;

  /// Renderer mode label for the low-detail native renderer
  ///
  /// In en, this message translates to:
  /// **'interactive lite'**
  String get anatomyRendererModeInteractiveLite;

  /// Button label for resetting the anatomy renderer camera
  ///
  /// In en, this message translates to:
  /// **'Reset camera'**
  String get anatomyRendererResetCamera;

  /// Button label for applying a sample anatomy heatmap
  ///
  /// In en, this message translates to:
  /// **'Preview heatmap'**
  String get anatomyRendererPreviewHeatmap;

  /// Status text when no anatomy muscle region is selected
  ///
  /// In en, this message translates to:
  /// **'No muscle region selected'**
  String get anatomyRendererNoRegionSelected;

  /// Status text for the selected anatomy muscle region
  ///
  /// In en, this message translates to:
  /// **'Selected region: {regionId}'**
  String anatomyRendererSelectedRegion(String regionId);

  /// Current anatomy renderer camera state
  ///
  /// In en, this message translates to:
  /// **'Camera: yaw {yaw}, pitch {pitch}, zoom {zoom}'**
  String anatomyRendererCameraState(String yaw, String pitch, String zoom);

  /// Label shown before active anatomy heatmap chips
  ///
  /// In en, this message translates to:
  /// **'Active heatmap regions'**
  String get anatomyRendererHeatmapLegend;

  /// Label shown when no anatomy heatmap is active
  ///
  /// In en, this message translates to:
  /// **'No heatmap applied'**
  String get anatomyRendererHeatmapEmpty;

  /// Title for the exercise catalog screen
  ///
  /// In en, this message translates to:
  /// **'Exercise catalog'**
  String get exerciseCatalogTitle;

  /// Label for the exercise catalog search field
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get exerciseCatalogSearchLabel;

  /// Hint for the exercise catalog search field
  ///
  /// In en, this message translates to:
  /// **'Search by exercise, muscle, equipment, or cue'**
  String get exerciseCatalogSearchHint;

  /// Heading shown above exercise catalog filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exerciseCatalogFiltersTitle;

  /// Button label for clearing exercise catalog search and filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get exerciseCatalogClearFilters;

  /// Summary of visible exercise catalog results
  ///
  /// In en, this message translates to:
  /// **'Showing {visibleCount} of {totalCount} exercises'**
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount);

  /// Status shown while the exercise catalog is loading
  ///
  /// In en, this message translates to:
  /// **'Loading exercise catalog...'**
  String get exerciseCatalogLoading;

  /// Error shown when the exercise catalog cannot load
  ///
  /// In en, this message translates to:
  /// **'Exercise catalog could not be loaded.'**
  String get exerciseCatalogLoadError;

  /// Title shown when catalog filters produce no results
  ///
  /// In en, this message translates to:
  /// **'No exercises match'**
  String get exerciseCatalogEmptyTitle;

  /// Helper text shown when catalog filters produce no results
  ///
  /// In en, this message translates to:
  /// **'Adjust search or filters to see exercises.'**
  String get exerciseCatalogEmptyMessage;

  /// Filter group label for movement patterns
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get exerciseCatalogMovementFilter;

  /// Filter group label for broad muscle regions
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get exerciseCatalogMuscleFilter;

  /// Filter group label for exercise equipment
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseCatalogEquipmentFilter;

  /// Filter group label for difficulty level
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get exerciseCatalogLevelFilter;

  /// Filter group label for unilateral or bilateral designation
  ///
  /// In en, this message translates to:
  /// **'Laterality'**
  String get exerciseCatalogLateralityFilter;

  /// Filter group label for exercise type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseCatalogTypeFilter;

  /// Fallback title for the exercise detail screen
  ///
  /// In en, this message translates to:
  /// **'Exercise detail'**
  String get exerciseDetailTitle;

  /// Exercise detail section label for setup instructions
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get exerciseDetailSetup;

  /// Exercise detail section label for execution instructions
  ///
  /// In en, this message translates to:
  /// **'Execution'**
  String get exerciseDetailExecution;

  /// Exercise detail section label for form cues
  ///
  /// In en, this message translates to:
  /// **'Form cues'**
  String get exerciseDetailFormCues;

  /// Exercise detail section label for common errors
  ///
  /// In en, this message translates to:
  /// **'Common errors'**
  String get exerciseDetailCommonErrors;

  /// Exercise detail section label for substitution exercises
  ///
  /// In en, this message translates to:
  /// **'Substitutions'**
  String get exerciseDetailSubstitutions;

  /// Exercise detail section label for regression exercises
  ///
  /// In en, this message translates to:
  /// **'Regressions'**
  String get exerciseDetailRegressions;

  /// Exercise detail section label for primary muscle regions
  ///
  /// In en, this message translates to:
  /// **'Primary muscles'**
  String get exerciseDetailPrimaryMuscles;

  /// Exercise detail section label for secondary muscle regions
  ///
  /// In en, this message translates to:
  /// **'Secondary muscles'**
  String get exerciseDetailSecondaryMuscles;

  /// Exercise detail section label for stabilizer muscle regions
  ///
  /// In en, this message translates to:
  /// **'Stabilizers'**
  String get exerciseDetailStabilizerMuscles;

  /// Exercise detail metadata label for equipment
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseDetailEquipment;

  /// Exercise detail metadata label for level
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get exerciseDetailLevel;

  /// Exercise detail metadata label for laterality
  ///
  /// In en, this message translates to:
  /// **'Laterality'**
  String get exerciseDetailLaterality;

  /// Exercise detail metadata label for exercise type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseDetailType;

  /// Title shown when an exercise detail route references an unknown exercise
  ///
  /// In en, this message translates to:
  /// **'Exercise not found'**
  String get exerciseDetailNotFoundTitle;

  /// Body shown when an exercise detail route references an unknown exercise
  ///
  /// In en, this message translates to:
  /// **'This exercise is not available in the local catalog.'**
  String get exerciseDetailNotFoundMessage;

  /// Tab label for the manual program builder
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get programWorkspaceBuilderTab;

  /// Tab label for the exercise catalog inside the Program branch
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get programWorkspaceCatalogTab;

  /// Title shown inside the manual program builder
  ///
  /// In en, this message translates to:
  /// **'Program builder'**
  String get programBuilderTitle;

  /// Empty state title before a local program draft exists
  ///
  /// In en, this message translates to:
  /// **'Create a program draft'**
  String get programBuilderEmptyTitle;

  /// Empty state body before a local program draft exists
  ///
  /// In en, this message translates to:
  /// **'Start with a name and one training day, then add exercises and prescription targets.'**
  String get programBuilderEmptyMessage;

  /// Button label for creating a local program draft
  ///
  /// In en, this message translates to:
  /// **'Create program'**
  String get programBuilderCreateProgram;

  /// Default local name for a newly created program draft
  ///
  /// In en, this message translates to:
  /// **'New program'**
  String get programBuilderDefaultProgramName;

  /// Default name for a newly created training day
  ///
  /// In en, this message translates to:
  /// **'Day {dayNumber}'**
  String programBuilderDefaultDayName(int dayNumber);

  /// Text field label for the program draft name
  ///
  /// In en, this message translates to:
  /// **'Program name'**
  String get programBuilderProgramNameLabel;

  /// Label for the local-only program draft status
  ///
  /// In en, this message translates to:
  /// **'Local draft'**
  String get programBuilderLocalDraftLabel;

  /// Scope note shown in the P3-07 builder
  ///
  /// In en, this message translates to:
  /// **'This draft keeps days, exercise order, and local prescription targets. Persistence and versioning are later checklist items.'**
  String get programBuilderScopeNote;

  /// Program builder summary for days and exercises
  ///
  /// In en, this message translates to:
  /// **'{dayCount} days · {exerciseCount} exercises'**
  String programBuilderSummary(int dayCount, int exerciseCount);

  /// Section title for training-day editing
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get programBuilderTrainingDays;

  /// Button label for adding a training day
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get programBuilderAddTrainingDay;

  /// Label for the currently selected training day
  ///
  /// In en, this message translates to:
  /// **'Selected day'**
  String get programBuilderSelectedDay;

  /// Tooltip and button label for renaming the selected training day
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get programBuilderRenameDay;

  /// Tooltip and button label for deleting the selected training day
  ///
  /// In en, this message translates to:
  /// **'Delete day'**
  String get programBuilderDeleteDay;

  /// Dialog title for renaming a training day
  ///
  /// In en, this message translates to:
  /// **'Rename training day'**
  String get programBuilderRenameDayTitle;

  /// Text field label for a training-day name
  ///
  /// In en, this message translates to:
  /// **'Day name'**
  String get programBuilderDayNameLabel;

  /// Generic save action in the program builder
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get programBuilderSave;

  /// Generic cancel action in the program builder
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get programBuilderCancel;

  /// Button label for adding an exercise to the selected training day
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get programBuilderAddExercise;

  /// Bottom sheet title for picking an exercise
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get programBuilderExercisePickerTitle;

  /// Search field label inside the program-builder exercise picker
  ///
  /// In en, this message translates to:
  /// **'Search catalog'**
  String get programBuilderExercisePickerSearchLabel;

  /// Search hint inside the program-builder exercise picker
  ///
  /// In en, this message translates to:
  /// **'Search by exercise, muscle, equipment, or cue'**
  String get programBuilderExercisePickerSearchHint;

  /// Empty state inside the exercise picker
  ///
  /// In en, this message translates to:
  /// **'No exercises match this search.'**
  String get programBuilderExercisePickerEmpty;

  /// Status text for an exercise already added to the selected day
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get programBuilderExerciseAlreadyAdded;

  /// Title shown when the selected training day has no exercises
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get programBuilderEmptyDayTitle;

  /// Body shown when the selected training day has no exercises
  ///
  /// In en, this message translates to:
  /// **'Add catalog exercises, then order them for this training day.'**
  String get programBuilderEmptyDayMessage;

  /// Tooltip for moving an exercise earlier in the selected day
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get programBuilderMoveExerciseUp;

  /// Tooltip for moving an exercise later in the selected day
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get programBuilderMoveExerciseDown;

  /// Tooltip for removing an exercise from the selected day
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get programBuilderRemoveExercise;

  /// Text field label for the prescribed set count
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get programBuilderSetCountLabel;

  /// Segment label for fixed-repetition prescriptions
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get programBuilderFixedRepetitionMode;

  /// Segment label for ranged-repetition prescriptions
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get programBuilderRangeRepetitionMode;

  /// Text field label for fixed repetitions
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get programBuilderFixedRepsLabel;

  /// Text field label for minimum repetitions in a range
  ///
  /// In en, this message translates to:
  /// **'Min reps'**
  String get programBuilderMinimumRepsLabel;

  /// Text field label for maximum repetitions in a range
  ///
  /// In en, this message translates to:
  /// **'Max reps'**
  String get programBuilderMaximumRepsLabel;

  /// Switch label for enabling target repetitions in reserve
  ///
  /// In en, this message translates to:
  /// **'Track RIR'**
  String get programBuilderTargetRirEnabled;

  /// Helper text explaining that RIR can be toggled separately from repetition mode
  ///
  /// In en, this message translates to:
  /// **'RIR is optional and independent from fixed or ranged repetitions.'**
  String get programBuilderTargetRirDescription;

  /// Text field label for target repetitions in reserve
  ///
  /// In en, this message translates to:
  /// **'Target RIR'**
  String get programBuilderTargetRirLabel;

  /// Text field label for prescribed load
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get programBuilderLoadLabel;

  /// Text field label for prescribed rest duration
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get programBuilderRestSecondsLabel;

  /// Short suffix for seconds
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get programBuilderSecondsSuffix;

  /// Summary text for fixed repetitions
  ///
  /// In en, this message translates to:
  /// **'{repetitions} reps'**
  String programBuilderFixedRepsSummary(int repetitions);

  /// Summary text for ranged repetitions
  ///
  /// In en, this message translates to:
  /// **'{minimumRepetitions}-{maximumRepetitions} reps'**
  String programBuilderRangeRepsSummary(
    int minimumRepetitions,
    int maximumRepetitions,
  );

  /// Summary text for target repetitions in reserve
  ///
  /// In en, this message translates to:
  /// **'RIR {targetRir}'**
  String programBuilderRirSummary(int targetRir);

  /// Summary text when target repetitions in reserve is disabled
  ///
  /// In en, this message translates to:
  /// **'RIR off'**
  String get programBuilderRirOff;

  /// Summary text when prescribed load is not set
  ///
  /// In en, this message translates to:
  /// **'no load'**
  String get programBuilderLoadUnset;

  /// Compact summary of an exercise prescription
  ///
  /// In en, this message translates to:
  /// **'{setCount} sets · {repetitionTarget} · {rirTarget} · {loadTarget} · {restSeconds} sec'**
  String programBuilderPrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  );

  /// Button label for saving a program draft snapshot
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get programBuilderSaveDraft;

  /// Button label for publishing an immutable active program version
  ///
  /// In en, this message translates to:
  /// **'Publish version'**
  String get programBuilderPublishVersion;

  /// Button label for copying the current program into a new local draft
  ///
  /// In en, this message translates to:
  /// **'Copy program'**
  String get programBuilderCopyProgram;

  /// Button label for archiving the current persisted program
  ///
  /// In en, this message translates to:
  /// **'Archive program'**
  String get programBuilderArchiveProgram;

  /// Status text for an unsaved local program draft
  ///
  /// In en, this message translates to:
  /// **'Local draft · not saved yet'**
  String get programBuilderLifecycleStatusLocal;

  /// Status text for a saved draft snapshot
  ///
  /// In en, this message translates to:
  /// **'Saved draft · version {versionNumber}'**
  String programBuilderLifecycleStatusSaved(int versionNumber);

  /// Status text for a published active program version
  ///
  /// In en, this message translates to:
  /// **'Published · active version {versionNumber}'**
  String programBuilderLifecycleStatusPublished(int versionNumber);

  /// Status text for an archived program
  ///
  /// In en, this message translates to:
  /// **'Archived · last version {versionNumber}'**
  String programBuilderLifecycleStatusArchived(int versionNumber);

  /// Snack bar message after saving a draft snapshot
  ///
  /// In en, this message translates to:
  /// **'Program draft saved.'**
  String get programBuilderDraftSaved;

  /// Snack bar message after publishing a program version
  ///
  /// In en, this message translates to:
  /// **'Immutable program version published.'**
  String get programBuilderVersionPublished;

  /// Snack bar message after copying the current program
  ///
  /// In en, this message translates to:
  /// **'Program copied as a new local draft.'**
  String get programBuilderProgramCopied;

  /// Snack bar message after archiving a program
  ///
  /// In en, this message translates to:
  /// **'Program archived.'**
  String get programBuilderProgramArchived;

  /// Generic persistence failure message in the program builder
  ///
  /// In en, this message translates to:
  /// **'Program could not be saved. Check the local draft and try again.'**
  String get programBuilderPersistenceFailed;

  /// Default name for a copied program draft
  ///
  /// In en, this message translates to:
  /// **'{programName} copy'**
  String programBuilderCopiedProgramName(String programName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
