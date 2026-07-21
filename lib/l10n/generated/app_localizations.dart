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

  /// Subtitle for the Progress screen
  ///
  /// In en, this message translates to:
  /// **'Review workout history, inspect set results, and track personal records.'**
  String get progressScreenSubtitle;

  /// Title for workout history section
  ///
  /// In en, this message translates to:
  /// **'Workout history'**
  String get progressHistoryTitle;

  /// Title shown when there are no workout sessions
  ///
  /// In en, this message translates to:
  /// **'No workout history yet'**
  String get progressHistoryEmptyTitle;

  /// Message shown when there are no workout sessions
  ///
  /// In en, this message translates to:
  /// **'Complete sets from the Today tab to build your local history.'**
  String get progressHistoryEmptyMessage;

  /// Error message shown when Progress cannot load workout history
  ///
  /// In en, this message translates to:
  /// **'Workout history could not load.'**
  String get progressHistoryLoadError;

  /// Fallback title for a workout session without notes
  ///
  /// In en, this message translates to:
  /// **'Workout session'**
  String get progressUnnamedSession;

  /// Summary for one historical workout session
  ///
  /// In en, this message translates to:
  /// **'{status} · {completedSetCount} of {setCount} sets logged'**
  String progressSessionSummary(
    String status,
    int completedSetCount,
    int setCount,
  );

  /// Button label for selecting a set detail from workout history
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} set {setNumber}'**
  String progressSetButtonLabel(String exerciseName, int setNumber);

  /// Title for selected set details
  ///
  /// In en, this message translates to:
  /// **'Set details'**
  String get progressSetDetailsTitle;

  /// Empty state for selected set details
  ///
  /// In en, this message translates to:
  /// **'Select a set from workout history to inspect its result.'**
  String get progressSetDetailsEmpty;

  /// Session context for selected set details
  ///
  /// In en, this message translates to:
  /// **'{sessionName} · {dateTime}'**
  String progressSetDetailSession(String sessionName, String dateTime);

  /// Calculated status row in set details
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String progressSetDetailStatus(String status);

  /// Target prescription row in set details
  ///
  /// In en, this message translates to:
  /// **'{target}'**
  String progressSetDetailTarget(String target);

  /// Latest actual log row in set details
  ///
  /// In en, this message translates to:
  /// **'{latest}'**
  String progressSetDetailLatest(String latest);

  /// Revision count for selected set details
  ///
  /// In en, this message translates to:
  /// **'{revisionCount} revisions'**
  String progressSetDetailRevisionCount(int revisionCount);

  /// Fallback text for set details without an actual log
  ///
  /// In en, this message translates to:
  /// **'No actual result logged'**
  String get progressNoActualLog;

  /// Title for the selected set actual-log revision history
  ///
  /// In en, this message translates to:
  /// **'Revision history'**
  String get progressRevisionHistoryTitle;

  /// One actual-log revision row in the selected set detail
  ///
  /// In en, this message translates to:
  /// **'Revision {revision}: {result}'**
  String progressRevisionRow(int revision, String result);

  /// Reference to the previous actual log revision superseded by a correction
  ///
  /// In en, this message translates to:
  /// **'Supersedes {logId}'**
  String progressRevisionSupersedes(String logId);

  /// Title for the historical set correction form
  ///
  /// In en, this message translates to:
  /// **'Correct logged result'**
  String get progressCorrectionTitle;

  /// Explanation that historical corrections are append-only
  ///
  /// In en, this message translates to:
  /// **'Saving a correction adds a new revision. Earlier logs stay preserved.'**
  String get progressCorrectionDescription;

  /// Message shown when a selected set cannot receive a correction
  ///
  /// In en, this message translates to:
  /// **'Only completed sets with a logged result can be corrected.'**
  String get progressCorrectionUnavailable;

  /// Input label for corrected actual repetitions
  ///
  /// In en, this message translates to:
  /// **'Corrected reps'**
  String get progressCorrectionRepetitionsLabel;

  /// Input label for corrected actual load
  ///
  /// In en, this message translates to:
  /// **'Corrected load'**
  String get progressCorrectionLoadLabel;

  /// Input label for corrected actual RIR
  ///
  /// In en, this message translates to:
  /// **'Corrected RIR'**
  String get progressCorrectionRirLabel;

  /// Dropdown label for corrected actual outcome
  ///
  /// In en, this message translates to:
  /// **'Corrected outcome'**
  String get progressCorrectionOutcomeLabel;

  /// Button label for saving a historical set correction
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get progressCorrectionSave;

  /// Snack bar shown after a historical correction is appended
  ///
  /// In en, this message translates to:
  /// **'Correction saved as a new revision.'**
  String get progressCorrectionSaved;

  /// Snack bar shown when a historical correction fails
  ///
  /// In en, this message translates to:
  /// **'Correction could not be saved.'**
  String get progressCorrectionFailed;

  /// Snack bar shown when correction inputs are invalid
  ///
  /// In en, this message translates to:
  /// **'Enter valid reps, load, and RIR values.'**
  String get progressCorrectionInvalid;

  /// Title for personal records section
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get progressPersonalRecordsTitle;

  /// Empty state for personal records
  ///
  /// In en, this message translates to:
  /// **'No personal records yet. Complete clean sets with reps or load to start tracking records.'**
  String get progressPersonalRecordsEmpty;

  /// Personal record row for best load
  ///
  /// In en, this message translates to:
  /// **'Best load: {load}'**
  String progressBestLoad(String load);

  /// Personal record row for best repetitions
  ///
  /// In en, this message translates to:
  /// **'Best reps: {repetitions}'**
  String progressBestRepetitions(int repetitions);

  /// Personal record row for best volume
  ///
  /// In en, this message translates to:
  /// **'Best volume: {volume}'**
  String progressBestVolume(String volume);

  /// Label for the Settings primary navigation destination
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavigationLabel;

  /// Title for the adaptive programming onboarding section
  ///
  /// In en, this message translates to:
  /// **'Adaptive onboarding'**
  String get onboardingTitle;

  /// Description for the adaptive programming onboarding section
  ///
  /// In en, this message translates to:
  /// **'Set the inputs the planner will use before generating recommendations. These choices stay local to this device.'**
  String get onboardingDescription;

  /// Label for selecting the primary training goal
  ///
  /// In en, this message translates to:
  /// **'Primary goal'**
  String get onboardingGoalLabel;

  /// Label for selecting training experience
  ///
  /// In en, this message translates to:
  /// **'Training experience'**
  String get onboardingExperienceLabel;

  /// Label for selecting available equipment
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get onboardingEquipmentLabel;

  /// Label for selecting preferred workout duration
  ///
  /// In en, this message translates to:
  /// **'Preferred session length'**
  String get onboardingSessionLengthLabel;

  /// Label for selecting preferred training weekdays
  ///
  /// In en, this message translates to:
  /// **'Preferred training days'**
  String get onboardingWeekdaysLabel;

  /// Button label for saving onboarding preferences
  ///
  /// In en, this message translates to:
  /// **'Save onboarding'**
  String get onboardingSaveButton;

  /// Snack bar shown after onboarding preferences are saved
  ///
  /// In en, this message translates to:
  /// **'Onboarding preferences saved.'**
  String get onboardingSavedMessage;

  /// Snack bar shown when onboarding preferences fail to save
  ///
  /// In en, this message translates to:
  /// **'Onboarding preferences could not be saved.'**
  String get onboardingSaveFailed;

  /// Message shown when onboarding preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'Onboarding preferences could not load.'**
  String get onboardingLoadError;

  /// Dropdown value for a preferred session duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String onboardingSessionLengthValue(int minutes);

  /// Summary shown after onboarding preferences have been saved
  ///
  /// In en, this message translates to:
  /// **'Saved: {goal}, {experience}, {minutes} minutes, {weekdays}. Equipment: {equipment}.'**
  String onboardingSavedSummary(
    String goal,
    String experience,
    int minutes,
    String weekdays,
    String equipment,
  );

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get onboardingGoalGeneralFitness;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get onboardingGoalHypertrophy;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Maximum strength'**
  String get onboardingGoalMaximumStrength;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Body recomposition'**
  String get onboardingGoalBodyRecomposition;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Muscular endurance'**
  String get onboardingGoalMuscularEndurance;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Athletic performance'**
  String get onboardingGoalAthleticPerformance;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get onboardingGoalMaintenance;

  /// Training experience label
  ///
  /// In en, this message translates to:
  /// **'New to training'**
  String get onboardingExperienceNewToTraining;

  /// Training experience label
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get onboardingExperienceBeginner;

  /// Training experience label
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get onboardingExperienceIntermediate;

  /// Training experience label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get onboardingExperienceAdvanced;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get onboardingEquipmentBodyweight;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get onboardingEquipmentDumbbells;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get onboardingEquipmentBarbell;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get onboardingEquipmentMachines;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Cable station'**
  String get onboardingEquipmentCableStation;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get onboardingEquipmentKettlebell;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Resistance bands'**
  String get onboardingEquipmentResistanceBands;

  /// Equipment label
  ///
  /// In en, this message translates to:
  /// **'Cardio equipment'**
  String get onboardingEquipmentCardio;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get onboardingWeekdayMonday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get onboardingWeekdayTuesday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get onboardingWeekdayWednesday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get onboardingWeekdayThursday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get onboardingWeekdayFriday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get onboardingWeekdaySaturday;

  /// Weekday label
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get onboardingWeekdaySunday;

  /// Title for the conservative calibration block preview
  ///
  /// In en, this message translates to:
  /// **'Conservative calibration block'**
  String get calibrationBlockTitle;

  /// Description of the conservative calibration block
  ///
  /// In en, this message translates to:
  /// **'Use this first block to find repeatable starting loads before recommendations change future training.'**
  String get calibrationBlockDescription;

  /// Summary of the conservative calibration block
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks - {sessionsPerWeek} sessions/week - keep at least RIR {minimumRir}'**
  String calibrationBlockSummary(
    int weeks,
    int sessionsPerWeek,
    int minimumRir,
  );

  /// Session length and weekday target for calibration
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute target sessions on {weekdays}'**
  String calibrationBlockSessionTarget(int minutes, String weekdays);

  /// Policy note that calibration does not increase load
  ///
  /// In en, this message translates to:
  /// **'No load increases during calibration; collect clean set evidence first.'**
  String get calibrationBlockNoProgression;

  /// One week row in the calibration block preview
  ///
  /// In en, this message translates to:
  /// **'Week {weekNumber}: {focus} - {volumePercent}% planned volume - RIR {minimumRir}+'**
  String calibrationWeekSummary(
    int weekNumber,
    String focus,
    int volumePercent,
    int minimumRir,
  );

  /// Exit requirements for leaving the calibration block
  ///
  /// In en, this message translates to:
  /// **'Advance only after: {requirements}.'**
  String calibrationExitRequirements(String requirements);

  /// Calibration week focus label
  ///
  /// In en, this message translates to:
  /// **'technique baseline'**
  String get calibrationFocusTechniqueBaseline;

  /// Calibration week focus label
  ///
  /// In en, this message translates to:
  /// **'repeatable execution'**
  String get calibrationFocusRepeatableExecution;

  /// Calibration week focus label
  ///
  /// In en, this message translates to:
  /// **'stable exposure'**
  String get calibrationFocusStableExposure;

  /// Calibration week focus label
  ///
  /// In en, this message translates to:
  /// **'prescription preview'**
  String get calibrationFocusPrescriptionPreview;

  /// Calibration exit requirement label
  ///
  /// In en, this message translates to:
  /// **'planned weeks are completed'**
  String get calibrationExitPlannedWeeksCompleted;

  /// Calibration exit requirement label
  ///
  /// In en, this message translates to:
  /// **'no pain reports'**
  String get calibrationExitNoPainReports;

  /// Calibration exit requirement label
  ///
  /// In en, this message translates to:
  /// **'no repeated performance misses'**
  String get calibrationExitNoRepeatedPerformanceMisses;

  /// Calibration exit requirement label
  ///
  /// In en, this message translates to:
  /// **'RIR evidence is stable'**
  String get calibrationExitStableRirEvidence;

  /// Title for the weekly availability editor
  ///
  /// In en, this message translates to:
  /// **'Weekly availability'**
  String get availabilityTitle;

  /// Description for fixed and flexible weekly availability windows
  ///
  /// In en, this message translates to:
  /// **'Choose when training can fit each week. Fixed periods are hard appointments; flexible periods give the planner room to place a session inside the window.'**
  String get availabilityDescription;

  /// Label for fixed availability windows
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get availabilityFixedPeriod;

  /// Label for flexible availability windows
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get availabilityFlexiblePeriod;

  /// Label for availability start time
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get availabilityStartTimeLabel;

  /// Label for availability end time
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get availabilityEndTimeLabel;

  /// Summary for one weekly availability window
  ///
  /// In en, this message translates to:
  /// **'{type} window from {startTime} to {endTime}'**
  String availabilityWindowSummary(
    String type,
    String startTime,
    String endTime,
  );

  /// Button label for saving weekly availability windows
  ///
  /// In en, this message translates to:
  /// **'Save availability'**
  String get availabilitySaveButton;

  /// Snack bar shown after weekly availability is saved
  ///
  /// In en, this message translates to:
  /// **'Weekly availability saved.'**
  String get availabilitySavedMessage;

  /// Snack bar shown when weekly availability fails to save
  ///
  /// In en, this message translates to:
  /// **'Weekly availability could not be saved.'**
  String get availabilitySaveFailed;

  /// Message shown when weekly availability fails to load
  ///
  /// In en, this message translates to:
  /// **'Weekly availability could not load.'**
  String get availabilityLoadError;

  /// Message shown while weekly availability is loading
  ///
  /// In en, this message translates to:
  /// **'Weekly availability loading...'**
  String get availabilityLoading;

  /// Title for the generated editable program draft preview
  ///
  /// In en, this message translates to:
  /// **'Program draft planner'**
  String get generatedProgramTitle;

  /// Description of the program draft planner
  ///
  /// In en, this message translates to:
  /// **'Build an editable local draft from onboarding, weekly availability, equipment, recovery spacing, and conservative volume rules.'**
  String get generatedProgramDescription;

  /// Message shown when no saved availability windows exist
  ///
  /// In en, this message translates to:
  /// **'Save weekly availability before building a program draft.'**
  String get generatedProgramAvailabilityRequired;

  /// Message shown when the exercise catalog cannot be loaded for program planning
  ///
  /// In en, this message translates to:
  /// **'The exercise catalog could not load, so the program draft cannot be built.'**
  String get generatedProgramCatalogLoadError;

  /// Message shown when no exercises can be selected for a generated program
  ///
  /// In en, this message translates to:
  /// **'No matching program could be built from the saved equipment. Add more equipment or update availability.'**
  String get generatedProgramNoPlan;

  /// Summary for a generated program plan
  ///
  /// In en, this message translates to:
  /// **'{sessionsPerWeek} sessions/week - {weeklySetTarget} working sets - up to {maxExercisesPerSession} exercises/session - RIR {minimumRir}+'**
  String generatedProgramSummary(
    int sessionsPerWeek,
    int weeklySetTarget,
    int maxExercisesPerSession,
    int minimumRir,
  );

  /// Summary for one generated program day
  ///
  /// In en, this message translates to:
  /// **'{weekday} - {windowType} {startTime}-{endTime} - {exerciseCount} exercises - {setCount} sets'**
  String generatedProgramDaySummary(
    String weekday,
    String windowType,
    String startTime,
    String endTime,
    int exerciseCount,
    int setCount,
  );

  /// Prescription summary for one generated exercise
  ///
  /// In en, this message translates to:
  /// **'{setCount} sets - {minimumRepetitions}-{maximumRepetitions} reps - RIR {targetRir} - {restSeconds} sec rest'**
  String generatedProgramExerciseSummary(
    int setCount,
    int minimumRepetitions,
    int maximumRepetitions,
    int targetRir,
    int restSeconds,
  );

  /// Button label for applying the generated plan to the editable local program draft
  ///
  /// In en, this message translates to:
  /// **'Apply as local draft'**
  String get generatedProgramApplyDraft;

  /// Snack bar shown after applying a generated plan to the local draft
  ///
  /// In en, this message translates to:
  /// **'Program draft applied locally. Open Program to edit, save, or publish it.'**
  String get generatedProgramAppliedMessage;

  /// Confirmation dialog title before replacing an existing local program draft
  ///
  /// In en, this message translates to:
  /// **'Replace local draft?'**
  String get generatedProgramReplaceDraftTitle;

  /// Confirmation dialog body before replacing an existing local program draft
  ///
  /// In en, this message translates to:
  /// **'Applying this plan replaces the current unsaved Program draft. Saved versions stay unchanged.'**
  String get generatedProgramReplaceDraftMessage;

  /// Cancel button for generated program draft replacement
  ///
  /// In en, this message translates to:
  /// **'Keep current draft'**
  String get generatedProgramReplaceDraftCancel;

  /// Confirm button for generated program draft replacement
  ///
  /// In en, this message translates to:
  /// **'Replace draft'**
  String get generatedProgramReplaceDraftConfirm;

  /// Name for a generated local program draft
  ///
  /// In en, this message translates to:
  /// **'{goal} draft'**
  String generatedProgramDraftName(String goal);

  /// Generated program day focus label
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get generatedProgramFocusFullBody;

  /// Generated program day focus label
  ///
  /// In en, this message translates to:
  /// **'Upper emphasis'**
  String get generatedProgramFocusUpperEmphasis;

  /// Generated program day focus label
  ///
  /// In en, this message translates to:
  /// **'Lower emphasis'**
  String get generatedProgramFocusLowerEmphasis;

  /// Generated program day focus label
  ///
  /// In en, this message translates to:
  /// **'Posterior chain'**
  String get generatedProgramFocusPosteriorChain;

  /// Generated program day focus label
  ///
  /// In en, this message translates to:
  /// **'Conditioning support'**
  String get generatedProgramFocusConditioningSupport;

  /// Title for the missed-session replacement preview
  ///
  /// In en, this message translates to:
  /// **'Missed-session replacement'**
  String get missedSessionReplacementTitle;

  /// Description of the missed-session replacement preview
  ///
  /// In en, this message translates to:
  /// **'Choose a missed planned day to preview the safest available replacement window. This does not move or publish any workout.'**
  String get missedSessionReplacementDescription;

  /// Message shown when availability is missing for missed-session replacement
  ///
  /// In en, this message translates to:
  /// **'Save weekly availability before previewing a replacement window.'**
  String get missedSessionReplacementAvailabilityRequired;

  /// Dropdown label for choosing the missed planned training day
  ///
  /// In en, this message translates to:
  /// **'Missed planned day'**
  String get missedSessionReplacementMissedDayLabel;

  /// Dropdown option for a generated training day
  ///
  /// In en, this message translates to:
  /// **'{dayName} - {weekday}'**
  String missedSessionReplacementDayOption(String dayName, String weekday);

  /// Summary of a safe missed-session replacement proposal
  ///
  /// In en, this message translates to:
  /// **'Suggested: {weekday}, {windowType} {startTime}-{endTime}. This is {dayOffset} days after the missed session and keeps at least {recoveryHours} hours between planned sessions.'**
  String missedSessionReplacementProposalSummary(
    String weekday,
    String windowType,
    String startTime,
    String endTime,
    int dayOffset,
    int recoveryHours,
  );

  /// Fallback when no safe replacement window exists
  ///
  /// In en, this message translates to:
  /// **'No safe replacement window is available from the saved weekly availability.'**
  String get missedSessionReplacementNoSafeWindow;

  /// Message when replacement windows are too short
  ///
  /// In en, this message translates to:
  /// **'No safe replacement window is available with enough time for the planned session.'**
  String get missedSessionReplacementNoSafeWindowWithDuration;

  /// Message when recovery spacing blocks replacement
  ///
  /// In en, this message translates to:
  /// **'No safe replacement window keeps the required {recoveryHours} hours of recovery around remaining planned sessions.'**
  String missedSessionReplacementNoSafeWindowWithRecovery(int recoveryHours);

  /// Message when a selected missed day cannot be found
  ///
  /// In en, this message translates to:
  /// **'The selected planned day is no longer available. Rebuild the program preview and try again.'**
  String get missedSessionReplacementMissingDay;

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

  /// Subtitle for the Today screen active workout entry point
  ///
  /// In en, this message translates to:
  /// **'Start the next local workout from your active program.'**
  String get todayScreenSubtitle;

  /// Title shown when Today has no active published program
  ///
  /// In en, this message translates to:
  /// **'No active program yet'**
  String get todayNoActiveProgramTitle;

  /// Message shown when Today has no active published program
  ///
  /// In en, this message translates to:
  /// **'Publish a program version in the Program tab before starting a workout.'**
  String get todayNoActiveProgramMessage;

  /// Button that opens the Program branch from Today
  ///
  /// In en, this message translates to:
  /// **'Open Program'**
  String get todayOpenProgramBuilder;

  /// Summary for the active program shown on Today
  ///
  /// In en, this message translates to:
  /// **'Active version {versionNumber} · {dayCount} training days'**
  String todayActiveProgramSummary(int versionNumber, int dayCount);

  /// Section title for selecting a training day on Today
  ///
  /// In en, this message translates to:
  /// **'Choose training day'**
  String get todayChooseTrainingDay;

  /// Summary for a selected training day plan
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises · {setCount} planned sets'**
  String todayTrainingDaySummary(int exerciseCount, int setCount);

  /// Button label for starting the selected workout session
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get todayStartWorkout;

  /// Snack bar shown after creating a workout session plan
  ///
  /// In en, this message translates to:
  /// **'Workout session started.'**
  String get todaySessionStarted;

  /// Snack bar shown when workout session creation fails
  ///
  /// In en, this message translates to:
  /// **'Workout could not be started.'**
  String get todaySessionStartFailed;

  /// Error message shown when the Today screen cannot load
  ///
  /// In en, this message translates to:
  /// **'Today could not load.'**
  String get todayLoadError;

  /// Button label for retrying Today screen loading
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get todayRetry;

  /// Fixed repetition target on Today
  ///
  /// In en, this message translates to:
  /// **'{repetitions} reps'**
  String todayFixedRepetitions(int repetitions);

  /// Ranged repetition target on Today
  ///
  /// In en, this message translates to:
  /// **'{minimumRepetitions}-{maximumRepetitions} reps'**
  String todayRangeRepetitions(int minimumRepetitions, int maximumRepetitions);

  /// Exercise prescription summary shown on Today
  ///
  /// In en, this message translates to:
  /// **'{setCount} sets · {repetitionTarget} · {rirTarget} · {loadTarget} · {restSeconds} sec rest'**
  String todayExercisePrescriptionSummary(
    int setCount,
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
    int restSeconds,
  );

  /// Title shown when the selected active training day has no exercises
  ///
  /// In en, this message translates to:
  /// **'No exercises on this day'**
  String get todayNoExercisesTitle;

  /// Message shown when the selected active training day has no exercises
  ///
  /// In en, this message translates to:
  /// **'Add exercises to this training day before starting a session.'**
  String get todayNoExercisesMessage;

  /// Title for an already active workout session on Today
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get todaySessionInProgressTitle;

  /// Summary for the active workout session on Today
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises · {setCount} planned sets'**
  String todaySessionInProgressSummary(int exerciseCount, int setCount);

  /// Instructional message for logging sets during an active workout
  ///
  /// In en, this message translates to:
  /// **'Record each set as you finish it. Completed sets are saved locally with their actual result.'**
  String get todaySessionInProgressMessage;

  /// Message shown when an active workout is restored after the app process restarts
  ///
  /// In en, this message translates to:
  /// **'This in-progress workout was restored from local storage.'**
  String get todaySessionRestoredMessage;

  /// Session-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Session status: {status}'**
  String todaySessionStatusLabel(String status);

  /// Exercise-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Exercise status: {status}'**
  String todayExerciseStatusLabel(String status);

  /// Set-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Set status: {status}'**
  String todaySetStatusLabel(String status);

  /// Calculated status for a set that has not been logged
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get todayStatusPending;

  /// Calculated status for an exercise or session with no logged sets
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get todayStatusNotStarted;

  /// Calculated status for partially logged workout work
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get todayStatusInProgress;

  /// Calculated status when all comparable targets are met
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get todayStatusSuccessful;

  /// Calculated status for a logged set that met its prescription
  ///
  /// In en, this message translates to:
  /// **'Target met'**
  String get todayStatusTargetMet;

  /// Calculated status when one or more performance misses exist
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get todayStatusNeedsReview;

  /// Calculated status for a set that missed reps, load, strength, or technique target
  ///
  /// In en, this message translates to:
  /// **'Performance miss'**
  String get todayStatusPerformanceMiss;

  /// Calculated status for time, equipment, external, or skipped interruptions
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
  String get todayStatusInterrupted;

  /// Calculated status when pain was reported
  ///
  /// In en, this message translates to:
  /// **'Pain reported'**
  String get todayStatusPainReported;

  /// Calculated status when a log cannot be compared to a prescription
  ///
  /// In en, this message translates to:
  /// **'Logged, not comparable'**
  String get todayStatusNotComparable;

  /// Progress summary for completed sets during an active workout
  ///
  /// In en, this message translates to:
  /// **'{completedSetCount} of {setCount} sets completed'**
  String todaySetProgressSummary(int completedSetCount, int setCount);

  /// Exercise-level set count in the active workout logger
  ///
  /// In en, this message translates to:
  /// **'{setCount} sets to log'**
  String todayExerciseActiveSetSummary(int setCount);

  /// Label for a set row in the active workout logger
  ///
  /// In en, this message translates to:
  /// **'Set {setNumber}'**
  String todaySessionSetLabel(int setNumber);

  /// Input label for the completed repetition count
  ///
  /// In en, this message translates to:
  /// **'Actual reps'**
  String get todayActualRepetitionsLabel;

  /// Input label for the completed load value
  ///
  /// In en, this message translates to:
  /// **'Actual load'**
  String get todayActualLoadLabel;

  /// Input label for the completed reps-in-reserve value
  ///
  /// In en, this message translates to:
  /// **'Actual RIR'**
  String get todayActualRirLabel;

  /// Input label for the set outcome selector
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get todayOutcomeLabel;

  /// Outcome selector option when no limitation or interruption occurred
  ///
  /// In en, this message translates to:
  /// **'No limitation'**
  String get todayOutcomeNone;

  /// Outcome selector option for strength-limited sets
  ///
  /// In en, this message translates to:
  /// **'Strength limitation'**
  String get todayOutcomeStrengthLimitation;

  /// Outcome selector option for technique-limited sets
  ///
  /// In en, this message translates to:
  /// **'Technique limitation'**
  String get todayOutcomeTechniqueLimitation;

  /// Outcome selector option for pain reports
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get todayOutcomePain;

  /// Outcome selector option for time-limited sets
  ///
  /// In en, this message translates to:
  /// **'Time limitation'**
  String get todayOutcomeTimeLimitation;

  /// Outcome selector option for equipment-limited sets
  ///
  /// In en, this message translates to:
  /// **'Equipment limitation'**
  String get todayOutcomeEquipmentLimitation;

  /// Outcome selector option for externally interrupted sets
  ///
  /// In en, this message translates to:
  /// **'External interruption'**
  String get todayOutcomeExternalInterruption;

  /// Button label for logging and completing one set
  ///
  /// In en, this message translates to:
  /// **'Complete set'**
  String get todayCompleteSet;

  /// Target summary shown above an active set logger
  ///
  /// In en, this message translates to:
  /// **'Target: {repetitionTarget} · {rirTarget} · {loadTarget}'**
  String todaySetPrescriptionSummary(
    String repetitionTarget,
    String rirTarget,
    String loadTarget,
  );

  /// Fallback text when a session set no longer has its original prescription
  ///
  /// In en, this message translates to:
  /// **'Target unavailable'**
  String get todaySetPrescriptionUnavailable;

  /// Previous set result shown beside the current prescription
  ///
  /// In en, this message translates to:
  /// **'Previous: {repetitionTarget} · {loadTarget} · {rirTarget} · {outcomeTarget}'**
  String todayPreviousPerformanceSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  );

  /// Fallback text when there is no previous set result for the current set slot
  ///
  /// In en, this message translates to:
  /// **'Previous: no logged set yet'**
  String get todayPreviousPerformanceUnavailable;

  /// Fallback text when an actual set log has no repetition value
  ///
  /// In en, this message translates to:
  /// **'reps not recorded'**
  String get todayRepetitionsNotRecorded;

  /// Actual set result shown after a set is completed
  ///
  /// In en, this message translates to:
  /// **'Logged: {repetitionTarget} · {loadTarget} · {rirTarget} · {outcomeTarget}'**
  String todaySetActualSummary(
    String repetitionTarget,
    String loadTarget,
    String rirTarget,
    String outcomeTarget,
  );

  /// Snack bar shown after a set is completed and logged
  ///
  /// In en, this message translates to:
  /// **'Set logged.'**
  String get todaySetLogSaved;

  /// Snack bar shown when set logging fails
  ///
  /// In en, this message translates to:
  /// **'Set could not be logged.'**
  String get todaySetLogFailed;

  /// Snack bar shown when set logging inputs are invalid
  ///
  /// In en, this message translates to:
  /// **'Enter valid reps, load, and RIR values.'**
  String get todaySetLogInvalid;

  /// Tooltip for decreasing the active set load by one quick step
  ///
  /// In en, this message translates to:
  /// **'Decrease load'**
  String get todayQuickLoadDecrease;

  /// Tooltip for increasing the active set load by one quick step
  ///
  /// In en, this message translates to:
  /// **'Increase load'**
  String get todayQuickLoadIncrease;

  /// Title for the active workout rest timer panel
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get todayRestTimerTitle;

  /// Running rest timer message after a completed set
  ///
  /// In en, this message translates to:
  /// **'Rest after {exerciseName} set {setNumber}: {remainingTime}'**
  String todayRestTimerRunning(
    String exerciseName,
    int setNumber,
    String remainingTime,
  );

  /// Message shown when the active rest timer reaches zero
  ///
  /// In en, this message translates to:
  /// **'Rest complete. Start the next set when ready.'**
  String get todayRestTimerComplete;

  /// Button label for dismissing or cancelling the active rest timer
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get todayRestTimerDismiss;

  /// Android notification title for completed rest timers
  ///
  /// In en, this message translates to:
  /// **'Rest complete'**
  String get todayRestTimerNotificationTitle;

  /// Android notification body for completed rest timers
  ///
  /// In en, this message translates to:
  /// **'Time for your next set.'**
  String get todayRestTimerNotificationBody;

  /// Status shown when the rest timer background notification is scheduled
  ///
  /// In en, this message translates to:
  /// **'Background alert scheduled.'**
  String get todayRestTimerNotificationScheduled;

  /// Status shown when notification permission was denied
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive rest alerts in the background.'**
  String get todayRestTimerNotificationPermissionDenied;

  /// Status shown when the platform has no notification bridge
  ///
  /// In en, this message translates to:
  /// **'Background alert unavailable on this device.'**
  String get todayRestTimerNotificationUnsupported;

  /// Status shown when the platform notification scheduler fails
  ///
  /// In en, this message translates to:
  /// **'Background alert could not be scheduled.'**
  String get todayRestTimerNotificationFailed;

  /// Status shown when a zero-duration rest timer skips notification scheduling
  ///
  /// In en, this message translates to:
  /// **'No rest alert needed.'**
  String get todayRestTimerNotificationSkipped;
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
