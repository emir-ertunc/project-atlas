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
  /// **'Track streaks, records, trends, and body changes.'**
  String get progressScreenSubtitle;

  /// Title for the compact Progress dashboard path card
  ///
  /// In en, this message translates to:
  /// **'Progress path'**
  String get progressDashboardPathTitle;

  /// Description for the compact Progress dashboard path card
  ///
  /// In en, this message translates to:
  /// **'Train, log, compare, repeat.'**
  String get progressDashboardPathDescription;

  /// Compact completed-workout streak value
  ///
  /// In en, this message translates to:
  /// **'{dayCount}d'**
  String progressDashboardStreakValue(int dayCount);

  /// Status chip shown when there is no local workout streak
  ///
  /// In en, this message translates to:
  /// **'Start streak'**
  String get progressDashboardStreakEmpty;

  /// Status chip for a current local workout streak
  ///
  /// In en, this message translates to:
  /// **'Streak {streakValue}'**
  String progressDashboardStreakStatus(String streakValue);

  /// Status chip for completed workout days in the last seven days
  ///
  /// In en, this message translates to:
  /// **'Week {completedCount}/7d'**
  String progressDashboardWeekStatus(int completedCount);

  /// Local non-social achievement feedback when no workout streak exists
  ///
  /// In en, this message translates to:
  /// **'Start the loop'**
  String get progressDashboardLocalFeedbackStart;

  /// Local non-social achievement feedback when a workout streak is active
  ///
  /// In en, this message translates to:
  /// **'Local momentum'**
  String get progressDashboardLocalFeedbackStreak;

  /// Local non-social achievement feedback when the current seven-day rhythm milestone is active
  ///
  /// In en, this message translates to:
  /// **'Week on track'**
  String get progressDashboardLocalFeedbackWeek;

  /// Local non-social achievement feedback when every local milestone is complete
  ///
  /// In en, this message translates to:
  /// **'Milestones complete'**
  String get progressDashboardLocalFeedbackComplete;

  /// Local non-social achievement feedback pointing to the next incomplete milestone
  ///
  /// In en, this message translates to:
  /// **'Next: {milestoneLabel}'**
  String progressDashboardLocalFeedbackNext(String milestoneLabel);

  /// Compact completed milestone count for the Progress dashboard
  ///
  /// In en, this message translates to:
  /// **'{completedCount}/{totalCount} milestones'**
  String progressDashboardMilestoneSummary(int completedCount, int totalCount);

  /// Title for the compact Progress dashboard milestone card
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get progressDashboardMilestonesTitle;

  /// Milestone label for completing the first workout
  ///
  /// In en, this message translates to:
  /// **'First workout'**
  String get progressDashboardMilestoneFirstWorkout;

  /// Milestone label for completing two workout days in the current seven-day window
  ///
  /// In en, this message translates to:
  /// **'2 days this week'**
  String get progressDashboardMilestoneWeekRhythm;

  /// Milestone label for earning the first personal record
  ///
  /// In en, this message translates to:
  /// **'First record'**
  String get progressDashboardMilestoneFirstRecord;

  /// Milestone label for having enough measurements to compare body changes
  ///
  /// In en, this message translates to:
  /// **'Body comparison'**
  String get progressDashboardMilestoneBodyComparison;

  /// Title for the compact Progress dashboard personal-record preview
  ///
  /// In en, this message translates to:
  /// **'Top records'**
  String get progressDashboardRecordBoardTitle;

  /// Compact personal-record count for the Progress dashboard
  ///
  /// In en, this message translates to:
  /// **'{recordCount} tracked'**
  String progressDashboardRecordBoardSummary(int recordCount);

  /// Empty helper text for the Progress dashboard record preview
  ///
  /// In en, this message translates to:
  /// **'Log clean sets to build records.'**
  String get progressDashboardRecordBoardEmpty;

  /// Empty helper text for the Progress dashboard trend preview
  ///
  /// In en, this message translates to:
  /// **'Log two data points to show a trend.'**
  String get progressDashboardTrendEmpty;

  /// Empty helper text for the Progress dashboard measurement comparison preview
  ///
  /// In en, this message translates to:
  /// **'Save two measurements to compare.'**
  String get progressDashboardMeasurementEmpty;

  /// Compact measurement comparison count for the Progress dashboard
  ///
  /// In en, this message translates to:
  /// **'{comparisonCount} comparisons'**
  String progressDashboardMeasurementComparisonCount(int comparisonCount);

  /// Button label for opening Progress history and records
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get progressDashboardOpenRecords;

  /// Button label for opening Progress trends
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get progressDashboardOpenTrends;

  /// Button label for opening Progress measurement comparison
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get progressDashboardOpenMeasurements;

  /// Title for workout history section
  ///
  /// In en, this message translates to:
  /// **'Workout history'**
  String get progressHistoryTitle;

  /// Title shown when there are no workout sessions
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get progressHistoryEmptyTitle;

  /// Message shown when there are no workout sessions
  ///
  /// In en, this message translates to:
  /// **'Complete a set from Today to start history.'**
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
  /// **'Select a history set to inspect results.'**
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
  /// **'Save a correction as a new revision; earlier logs stay preserved.'**
  String get progressCorrectionDescription;

  /// Message shown when a selected set cannot receive a correction
  ///
  /// In en, this message translates to:
  /// **'Only completed logged sets can be corrected.'**
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
  /// **'Log clean sets with reps or load to start records.'**
  String get progressPersonalRecordsEmpty;

  /// Title for measurement and training trend section
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get progressTrendsTitle;

  /// Description for measurement and training trends
  ///
  /// In en, this message translates to:
  /// **'Built locally from measurements and clean set logs. Strength is an estimate.'**
  String get progressTrendsDescription;

  /// Title for measurement trends
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get progressMeasurementTrendsTitle;

  /// Title for training trends
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get progressTrainingTrendsTitle;

  /// Title for measurement history comparison and export section
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get progressMeasurementHistoryTitle;

  /// Description for measurement history comparison and export section
  ///
  /// In en, this message translates to:
  /// **'Compare saved measurements or copy an export when needed.'**
  String get progressMeasurementHistoryDescription;

  /// Title for first-to-latest measurement comparisons
  ///
  /// In en, this message translates to:
  /// **'First vs latest'**
  String get progressMeasurementComparisonTitle;

  /// One first-to-latest measurement comparison row
  ///
  /// In en, this message translates to:
  /// **'{metric}: {baseline} -> {latest} ({change})'**
  String progressMeasurementComparisonLine(
    String metric,
    String baseline,
    String latest,
    String change,
  );

  /// Title for latest left/right measurement comparisons
  ///
  /// In en, this message translates to:
  /// **'Latest side comparison'**
  String get progressMeasurementSideComparisonTitle;

  /// One latest left/right body measurement comparison row
  ///
  /// In en, this message translates to:
  /// **'{pair}: left {left} / right {right} ({difference}, {percent}%)'**
  String progressMeasurementSideComparisonLine(
    String pair,
    String left,
    String right,
    String difference,
    String percent,
  );

  /// Left/right measurement pair label
  ///
  /// In en, this message translates to:
  /// **'Upper arm'**
  String get progressMeasurementPairUpperArm;

  /// Left/right measurement pair label
  ///
  /// In en, this message translates to:
  /// **'Forearm'**
  String get progressMeasurementPairForearm;

  /// Left/right measurement pair label
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get progressMeasurementPairThigh;

  /// Left/right measurement pair label
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get progressMeasurementPairCalf;

  /// Title for measurement history export actions
  ///
  /// In en, this message translates to:
  /// **'Measurement export'**
  String get progressMeasurementExportTitle;

  /// Privacy warning for copying measurement export text
  ///
  /// In en, this message translates to:
  /// **'Exports contain personal measurement data. Store them only where you trust.'**
  String get progressMeasurementExportDescription;

  /// Number of measurement records included in export
  ///
  /// In en, this message translates to:
  /// **'{recordCount} measurement records available'**
  String progressMeasurementExportCount(int recordCount);

  /// Button label for copying measurement history CSV
  ///
  /// In en, this message translates to:
  /// **'Copy CSV'**
  String get progressMeasurementExportCopyCsv;

  /// Button label for copying measurement history JSON
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get progressMeasurementExportCopyJson;

  /// Snack bar after measurement CSV is copied
  ///
  /// In en, this message translates to:
  /// **'Measurement CSV copied.'**
  String get progressMeasurementExportCopiedCsv;

  /// Snack bar after measurement JSON is copied
  ///
  /// In en, this message translates to:
  /// **'Measurement JSON copied.'**
  String get progressMeasurementExportCopiedJson;

  /// One trend summary line
  ///
  /// In en, this message translates to:
  /// **'{metric}: {latest} ({change}, {pointCount} points)'**
  String progressTrendLine(
    String metric,
    String latest,
    String change,
    int pointCount,
  );

  /// Trend change text when latest and first values are equal
  ///
  /// In en, this message translates to:
  /// **'no change'**
  String get progressTrendNoChange;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get progressTrendHeight;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get progressTrendWeight;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Torso length'**
  String get progressTrendTorsoLength;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get progressTrendChest;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get progressTrendWaist;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get progressTrendHips;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Left upper arm'**
  String get progressTrendLeftUpperArm;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Right upper arm'**
  String get progressTrendRightUpperArm;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Left forearm'**
  String get progressTrendLeftForearm;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Right forearm'**
  String get progressTrendRightForearm;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Left thigh'**
  String get progressTrendLeftThigh;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Right thigh'**
  String get progressTrendRightThigh;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Left calf'**
  String get progressTrendLeftCalf;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Right calf'**
  String get progressTrendRightCalf;

  /// Measurement trend metric label
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get progressTrendBodyFat;

  /// Training trend metric label
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get progressTrendVolume;

  /// Training trend metric label
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get progressTrendLoad;

  /// Training trend metric label
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get progressTrendRepetitions;

  /// Training trend metric label for estimated one-repetition strength
  ///
  /// In en, this message translates to:
  /// **'Estimated strength'**
  String get progressTrendEstimatedStrength;

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
  /// **'Profile'**
  String get settingsNavigationLabel;

  /// Title for the adaptive programming onboarding section
  ///
  /// In en, this message translates to:
  /// **'Planner setup'**
  String get onboardingTitle;

  /// Description for the adaptive programming onboarding section
  ///
  /// In en, this message translates to:
  /// **'Save local inputs before plan recommendations.'**
  String get onboardingDescription;

  /// Label for selecting the primary training goal
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get onboardingGoalLabel;

  /// Label for selecting training experience
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get onboardingExperienceLabel;

  /// Label for selecting available equipment
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get onboardingEquipmentLabel;

  /// Label for selecting preferred workout duration
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get onboardingSessionLengthLabel;

  /// Label for selecting preferred training weekdays
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get onboardingWeekdaysLabel;

  /// Button label for saving onboarding preferences
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get onboardingSaveButton;

  /// Snack bar shown after onboarding preferences are saved
  ///
  /// In en, this message translates to:
  /// **'Setup saved.'**
  String get onboardingSavedMessage;

  /// Snack bar shown when onboarding preferences fail to save
  ///
  /// In en, this message translates to:
  /// **'Setup could not be saved.'**
  String get onboardingSaveFailed;

  /// Message shown when onboarding preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'Setup could not load.'**
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

  /// Title for the compact guided setup wizard
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupWizardTitle;

  /// Description for the compact guided setup wizard
  ///
  /// In en, this message translates to:
  /// **'Answer five quick steps for local planning.'**
  String get setupWizardDescription;

  /// Current setup wizard step count
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String setupWizardStepCounter(int current, int total);

  /// Button label for returning to the previous setup wizard step
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get setupWizardBackButton;

  /// Button label for continuing to the next setup wizard step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get setupWizardNextButton;

  /// Button label for opening the setup wizard review step
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get setupWizardReviewButton;

  /// Button label for saving the guided setup wizard
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get setupWizardSaveButton;

  /// Snack bar shown after the guided setup wizard is saved
  ///
  /// In en, this message translates to:
  /// **'Setup saved.'**
  String get setupWizardSavedMessage;

  /// Status title shown after setup is saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get setupWizardSavedStatus;

  /// Description shown after setup is saved
  ///
  /// In en, this message translates to:
  /// **'Goal, gear, days, and availability stay local.'**
  String get setupWizardSavedDescription;

  /// Status label for the selected setup wizard option
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get setupWizardSelectedStatus;

  /// Title for the goal step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick goal'**
  String get setupWizardGoalStepTitle;

  /// Short label for the goal step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get setupWizardGoalStepShort;

  /// Description for the goal step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Set the first planning bias; change it later.'**
  String get setupWizardGoalStepDescription;

  /// Title for the experience step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick level'**
  String get setupWizardExperienceStepTitle;

  /// Short label for the experience step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get setupWizardExperienceStepShort;

  /// Description for the experience step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Level sets the conservative starting volume.'**
  String get setupWizardExperienceStepDescription;

  /// Title for the equipment step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick gear'**
  String get setupWizardEquipmentStepTitle;

  /// Short label for the equipment step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get setupWizardEquipmentStepShort;

  /// Description for the equipment step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Choose gear you can use most weeks.'**
  String get setupWizardEquipmentStepDescription;

  /// Title for the availability step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick training days'**
  String get setupWizardAvailabilityStepTitle;

  /// Short label for the availability step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get setupWizardAvailabilityStepShort;

  /// Description for the availability step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick days, then mark each window fixed or flexible.'**
  String get setupWizardAvailabilityStepDescription;

  /// Helper text for availability window type selection
  ///
  /// In en, this message translates to:
  /// **'Flexible gives room; fixed protects appointments.'**
  String get setupWizardAvailabilityWindowHint;

  /// Availability summary in setup wizard review
  ///
  /// In en, this message translates to:
  /// **'{dayCount} days, {minutes} min default'**
  String setupWizardAvailabilityReview(int dayCount, int minutes);

  /// Title for the measurement preference step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Pick measurement flow'**
  String get setupWizardMeasurementsStepTitle;

  /// Short label for the measurement preference step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get setupWizardMeasurementsStepShort;

  /// Description for the measurement preference step in setup wizard
  ///
  /// In en, this message translates to:
  /// **'Choose how much guidance you want first.'**
  String get setupWizardMeasurementsStepDescription;

  /// Measurement preference option title
  ///
  /// In en, this message translates to:
  /// **'Guided entry'**
  String get setupWizardMeasurementGuidedTitle;

  /// Measurement preference option description
  ///
  /// In en, this message translates to:
  /// **'Use body-area steps for the best estimate.'**
  String get setupWizardMeasurementGuidedDescription;

  /// Measurement preference option title
  ///
  /// In en, this message translates to:
  /// **'Essentials first'**
  String get setupWizardMeasurementEssentialsTitle;

  /// Measurement preference option description
  ///
  /// In en, this message translates to:
  /// **'Start with height, weight, and key circumferences.'**
  String get setupWizardMeasurementEssentialsDescription;

  /// Measurement preference option title
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get setupWizardMeasurementLaterTitle;

  /// Measurement preference option description
  ///
  /// In en, this message translates to:
  /// **'Skip prompts for now and keep the estimate generic.'**
  String get setupWizardMeasurementLaterDescription;

  /// Privacy note for measurement preference setup step
  ///
  /// In en, this message translates to:
  /// **'No measurement value is saved in this step.'**
  String get setupWizardMeasurementPrivacyNote;

  /// Title for setup wizard review step
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get setupWizardReviewStepTitle;

  /// Short label for setup wizard review step
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get setupWizardReviewStepShort;

  /// Description for setup wizard review step
  ///
  /// In en, this message translates to:
  /// **'Confirm inputs before planning.'**
  String get setupWizardReviewStepDescription;

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
  /// **'Draft planner'**
  String get generatedProgramTitle;

  /// Description of the program draft planner
  ///
  /// In en, this message translates to:
  /// **'Build an editable draft from setup, availability, gear, recovery, and volume rules.'**
  String get generatedProgramDescription;

  /// Message shown when no saved availability windows exist
  ///
  /// In en, this message translates to:
  /// **'Save availability before building a draft.'**
  String get generatedProgramAvailabilityRequired;

  /// Message shown when the exercise catalog cannot be loaded for program planning
  ///
  /// In en, this message translates to:
  /// **'Catalog could not load, so the draft cannot build.'**
  String get generatedProgramCatalogLoadError;

  /// Message shown when no exercises can be selected for a generated program
  ///
  /// In en, this message translates to:
  /// **'No plan matches saved gear. Add equipment or update availability.'**
  String get generatedProgramNoPlan;

  /// Summary for a generated program plan
  ///
  /// In en, this message translates to:
  /// **'{sessionsPerWeek}/wk · {weeklySetTarget} sets · max {maxExercisesPerSession}/session · RIR {minimumRir}+'**
  String generatedProgramSummary(
    int sessionsPerWeek,
    int weeklySetTarget,
    int maxExercisesPerSession,
    int minimumRir,
  );

  /// Summary for one generated program day
  ///
  /// In en, this message translates to:
  /// **'{weekday} · {windowType} {startTime}-{endTime} · {exerciseCount} exercises · {setCount} sets'**
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
  /// **'{setCount} sets · {minimumRepetitions}-{maximumRepetitions} reps · RIR {targetRir} · {restSeconds} sec'**
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
  /// **'Use draft'**
  String get generatedProgramApplyDraft;

  /// Snack bar shown after applying a generated plan to the local draft
  ///
  /// In en, this message translates to:
  /// **'Draft applied. Open Program to edit, save, or publish.'**
  String get generatedProgramAppliedMessage;

  /// Confirmation dialog title before replacing an existing local program draft
  ///
  /// In en, this message translates to:
  /// **'Replace draft?'**
  String get generatedProgramReplaceDraftTitle;

  /// Confirmation dialog body before replacing an existing local program draft
  ///
  /// In en, this message translates to:
  /// **'This replaces the unsaved Program draft. Saved versions stay unchanged.'**
  String get generatedProgramReplaceDraftMessage;

  /// Cancel button for generated program draft replacement
  ///
  /// In en, this message translates to:
  /// **'Keep draft'**
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
  /// **'Anatomy viewer'**
  String get anatomyRendererTitle;

  /// Short explanation of the current anatomy renderer state
  ///
  /// In en, this message translates to:
  /// **'Android builds use the native viewer; assets ship at the bundling checkpoint.'**
  String get anatomyRendererDescription;

  /// Interaction help text shown above the anatomy renderer
  ///
  /// In en, this message translates to:
  /// **'Drag, pinch, or tap a region. Heatmaps use muscle IDs until GLB ships.'**
  String get anatomyInteractionInstructions;

  /// Compact anatomy viewport overlay chip reminding that the body view is an estimate
  ///
  /// In en, this message translates to:
  /// **'Visual estimate'**
  String get anatomyOverlayVisualEstimate;

  /// Compact anatomy viewport overlay chip explaining the tap-to-inspect interaction
  ///
  /// In en, this message translates to:
  /// **'Tap a region'**
  String get anatomyOverlayTapToInspect;

  /// Compact Anatomy prompt title shown when no body measurements are saved
  ///
  /// In en, this message translates to:
  /// **'Add measurements'**
  String get anatomyMeasurementPromptTitle;

  /// Compact Anatomy prompt body shown when no body measurements are saved
  ///
  /// In en, this message translates to:
  /// **'Add guided measurements before relying on shape changes.'**
  String get anatomyMeasurementPromptDescription;

  /// Button label for opening visual-estimate or measurement guidance from Anatomy
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get anatomyMeasurementPromptAction;

  /// Disclosure title for personalized anatomy estimates
  ///
  /// In en, this message translates to:
  /// **'Visual estimate, not a medical scan'**
  String get anatomyVisualEstimateLabel;

  /// Disclosure body explaining that anatomy personalization is not diagnostic
  ///
  /// In en, this message translates to:
  /// **'Built from saved measurements and training data. It cannot diagnose health, injury, disease, or body composition.'**
  String get anatomyVisualEstimateDescription;

  /// Disclosure note directing the user to review measurement inputs
  ///
  /// In en, this message translates to:
  /// **'Use it for trends; re-check saved inputs if it looks wrong.'**
  String get anatomyVisualEstimateInputNote;

  /// Accessibility label for the visual estimate disclosure icon
  ///
  /// In en, this message translates to:
  /// **'Visual estimate information'**
  String get anatomyVisualEstimateIconLabel;

  /// Accessibility label passed to the native Android renderer view
  ///
  /// In en, this message translates to:
  /// **'Interactive anatomy renderer'**
  String get anatomyRendererContentDescription;

  /// Fallback message shown outside Android
  ///
  /// In en, this message translates to:
  /// **'The native viewer runs on Android builds. This environment shows a safe fallback.'**
  String get anatomyRendererAndroidOnly;

  /// Fallback message shown when the native anatomy renderer is disabled by the performance policy
  ///
  /// In en, this message translates to:
  /// **'Safe preview is active until assets and device metrics pass.'**
  String get anatomyRendererPerformanceFallback;

  /// Status shown while renderer capabilities are loading
  ///
  /// In en, this message translates to:
  /// **'Checking viewer...'**
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
  /// **'Reset view'**
  String get anatomyRendererResetCamera;

  /// Button label for applying a sample anatomy heatmap
  ///
  /// In en, this message translates to:
  /// **'Preview heatmap'**
  String get anatomyRendererPreviewHeatmap;

  /// Status text when no anatomy muscle region is selected
  ///
  /// In en, this message translates to:
  /// **'Tap a muscle region'**
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

  /// Title for training-derived anatomy heatmaps
  ///
  /// In en, this message translates to:
  /// **'Muscle heatmaps'**
  String get anatomyTrainingHeatmapTitle;

  /// Description for training-derived anatomy heatmaps
  ///
  /// In en, this message translates to:
  /// **'Review trained muscles, volume, or fatigue from the last 7 days.'**
  String get anatomyTrainingHeatmapDescription;

  /// Button label for the trained-muscle heatmap
  ///
  /// In en, this message translates to:
  /// **'Trained muscles'**
  String get anatomyTrainingHeatmapTrainedMuscle;

  /// Button label for the weekly-volume heatmap
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get anatomyTrainingHeatmapWeeklyVolume;

  /// Button label for the fatigue heatmap
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get anatomyTrainingHeatmapFatigue;

  /// Message shown while training heatmaps are loading
  ///
  /// In en, this message translates to:
  /// **'Loading heatmaps...'**
  String get anatomyTrainingHeatmapLoading;

  /// Message shown when training heatmaps fail to load
  ///
  /// In en, this message translates to:
  /// **'Heatmaps could not load.'**
  String get anatomyTrainingHeatmapLoadError;

  /// Empty state for training heatmaps
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to show 7-day heatmaps.'**
  String get anatomyTrainingHeatmapEmpty;

  /// Summary for the selected training heatmap
  ///
  /// In en, this message translates to:
  /// **'{regionCount} regions - strongest {topRegionId}'**
  String anatomyTrainingHeatmapSummary(int regionCount, String topRegionId);

  /// Title for the exercise catalog screen
  ///
  /// In en, this message translates to:
  /// **'Exercise catalog'**
  String get exerciseCatalogTitle;

  /// Subtitle for the redesigned exercise catalog search header
  ///
  /// In en, this message translates to:
  /// **'Search, filter, and add to your draft.'**
  String get exerciseCatalogSubtitle;

  /// Label for the exercise catalog search field
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get exerciseCatalogSearchLabel;

  /// Hint for the exercise catalog search field
  ///
  /// In en, this message translates to:
  /// **'Name, muscle, gear, or cue'**
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

  /// Button label for opening compact exercise catalog filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exerciseCatalogFilterButton;

  /// Title for the exercise catalog filter bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Filter exercises'**
  String get exerciseCatalogFilterSheetTitle;

  /// Button label for closing the filter sheet after selecting filters
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get exerciseCatalogApplyFilters;

  /// Status chip label when no catalog filters are active
  ///
  /// In en, this message translates to:
  /// **'No filters'**
  String get exerciseCatalogNoActiveFilters;

  /// Button label showing active exercise catalog filter count
  ///
  /// In en, this message translates to:
  /// **'{filterCount} filters'**
  String exerciseCatalogActiveFilterCount(int filterCount);

  /// Small trend text below the visible exercise count
  ///
  /// In en, this message translates to:
  /// **'of {totalCount}'**
  String exerciseCatalogResultsTrend(int totalCount);

  /// Button label for adding a catalog exercise to the current program draft
  ///
  /// In en, this message translates to:
  /// **'Add to program'**
  String get exerciseCatalogAddToProgram;

  /// Snack bar shown after adding an exercise to an existing draft
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} to {dayName}.'**
  String exerciseCatalogAddedToProgram(String exerciseName, String dayName);

  /// Snack bar shown after creating a draft from the catalog add action
  ///
  /// In en, this message translates to:
  /// **'Draft created. Added {exerciseName} to {dayName}.'**
  String exerciseCatalogCreatedDraftAndAdded(
    String exerciseName,
    String dayName,
  );

  /// Snack bar shown when the selected exercise already exists in the selected day
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} is already on {dayName}.'**
  String exerciseCatalogAlreadyInProgram(String exerciseName, String dayName);

  /// Media status shown when an exercise has a local animation binding
  ///
  /// In en, this message translates to:
  /// **'Animation ready'**
  String get exerciseCatalogAnimationAvailable;

  /// Media status shown when an exercise has only a procedural thumbnail
  ///
  /// In en, this message translates to:
  /// **'Image guide'**
  String get exerciseCatalogThumbnailOnly;

  /// Summary of visible exercise catalog results
  ///
  /// In en, this message translates to:
  /// **'{visibleCount}/{totalCount} exercises'**
  String exerciseCatalogResultsSummary(int visibleCount, int totalCount);

  /// Status shown while the exercise catalog is loading
  ///
  /// In en, this message translates to:
  /// **'Loading catalog...'**
  String get exerciseCatalogLoading;

  /// Error shown when the exercise catalog cannot load
  ///
  /// In en, this message translates to:
  /// **'Catalog could not load.'**
  String get exerciseCatalogLoadError;

  /// Title shown when catalog filters produce no results
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get exerciseCatalogEmptyTitle;

  /// Helper text shown when catalog filters produce no results
  ///
  /// In en, this message translates to:
  /// **'Change search or filters.'**
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
  /// **'Side'**
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
  /// **'Avoid'**
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
  /// **'Primary'**
  String get exerciseDetailPrimaryMuscles;

  /// Exercise detail section label for secondary muscle regions
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
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
  /// **'This exercise is not in the local catalog.'**
  String get exerciseDetailNotFoundMessage;

  /// Subtitle for the modern Program hub
  ///
  /// In en, this message translates to:
  /// **'Review the plan. Open focused routes to edit.'**
  String get programHubSubtitle;

  /// Title for the Program hub empty state when no active program exists
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get programHubNoActiveProgramTitle;

  /// Message for the Program hub empty state when no active program exists
  ///
  /// In en, this message translates to:
  /// **'Create or publish a plan before workouts can use it.'**
  String get programHubNoActiveProgramMessage;

  /// Primary action in the Program hub empty state
  ///
  /// In en, this message translates to:
  /// **'Create draft'**
  String get programHubCreateDraft;

  /// Summary for the active program overview card
  ///
  /// In en, this message translates to:
  /// **'Version {versionNumber} · {dayCount} days'**
  String programHubActiveVersionSummary(int versionNumber, int dayCount);

  /// Metric for the active program overview card
  ///
  /// In en, this message translates to:
  /// **'{dayCount}d · {setCount} sets'**
  String programHubPlanMetric(int dayCount, int setCount);

  /// Status chip label for an active program
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get programHubActiveStatus;

  /// Description for the Program hub builder route card
  ///
  /// In en, this message translates to:
  /// **'Edit days, order, targets, and publish state.'**
  String get programHubBuilderDescription;

  /// Description for the Program hub catalog route card
  ///
  /// In en, this message translates to:
  /// **'Find exercises and add them without crowding the hub.'**
  String get programHubCatalogDescription;

  /// Title for the Program recommendation inbox entry
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get programHubRecommendationInboxTitle;

  /// Description when the Program recommendation inbox has no pending items
  ///
  /// In en, this message translates to:
  /// **'No recommendations need review.'**
  String get programHubRecommendationClearDescription;

  /// Metric when the Program recommendation inbox has no pending items
  ///
  /// In en, this message translates to:
  /// **'0 pending'**
  String get programHubRecommendationClearCount;

  /// Status when the Program recommendation inbox has no pending items
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get programHubRecommendationClearStatus;

  /// Section title for active program training-day cards
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get programHubTrainingDaysTitle;

  /// Helper text for active program training-day cards
  ///
  /// In en, this message translates to:
  /// **'Tap a day to edit in Builder.'**
  String get programHubTrainingDaysDescription;

  /// Summary for one active program training day
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises · {setCount} sets'**
  String programHubTrainingDaySummary(int exerciseCount, int setCount);

  /// Overflow label when a Program hub training-day card has more exercises than the preview shows
  ///
  /// In en, this message translates to:
  /// **'+{exerciseCount} more'**
  String programHubMoreExercises(int exerciseCount);

  /// Error message when the Program hub read model cannot load
  ///
  /// In en, this message translates to:
  /// **'Program hub could not be loaded.'**
  String get programHubLoadError;

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
  /// **'Builder'**
  String get programBuilderTitle;

  /// Empty state title before a local program draft exists
  ///
  /// In en, this message translates to:
  /// **'Start a draft'**
  String get programBuilderEmptyTitle;

  /// Empty state body before a local program draft exists
  ///
  /// In en, this message translates to:
  /// **'Name it, add a day, then add exercises.'**
  String get programBuilderEmptyMessage;

  /// Button label for creating a local program draft
  ///
  /// In en, this message translates to:
  /// **'Create'**
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

  /// Subtitle for the guided program builder header
  ///
  /// In en, this message translates to:
  /// **'Setup, days, catalog, targets, review.'**
  String get programBuilderGuidedSubtitle;

  /// Step progress label for the guided program builder
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep}/{totalSteps}'**
  String programBuilderStepProgress(int currentStep, int totalSteps);

  /// Back button label for guided program builder steps
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get programBuilderBackStep;

  /// Continue button label for guided program builder steps
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get programBuilderContinueStep;

  /// Status chip label for a completed guided builder step
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get programBuilderStepComplete;

  /// Status chip label for an open guided builder step
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get programBuilderStepOpen;

  /// Guided builder setup step title
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get programBuilderSetupStepTitle;

  /// Guided builder setup step subtitle
  ///
  /// In en, this message translates to:
  /// **'Name the draft first.'**
  String get programBuilderSetupStepSubtitle;

  /// Guided builder training-day step title
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get programBuilderDaysStepTitle;

  /// Guided builder training-day step subtitle
  ///
  /// In en, this message translates to:
  /// **'Add, select, rename, or remove days.'**
  String get programBuilderDaysStepSubtitle;

  /// Guided builder exercise catalog and ordering step title
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get programBuilderExercisesStepTitle;

  /// Guided builder exercise catalog and ordering step subtitle
  ///
  /// In en, this message translates to:
  /// **'Search, add, and order this day.'**
  String get programBuilderExercisesStepSubtitle;

  /// Guided builder prescription step title
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get programBuilderPrescriptionStepTitle;

  /// Guided builder prescription step subtitle
  ///
  /// In en, this message translates to:
  /// **'Edit sets, reps, RIR, load, and rest.'**
  String get programBuilderPrescriptionStepSubtitle;

  /// Guided builder review step title
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get programBuilderReviewStepTitle;

  /// Guided builder review step subtitle
  ///
  /// In en, this message translates to:
  /// **'Check the draft before saving or publishing.'**
  String get programBuilderReviewStepSubtitle;

  /// Empty state for the guided builder prescription step
  ///
  /// In en, this message translates to:
  /// **'Add an exercise before editing targets.'**
  String get programBuilderPrescriptionEmpty;

  /// Hint explaining where prescription fields are edited
  ///
  /// In en, this message translates to:
  /// **'Targets stay on each exercise card.'**
  String get programBuilderPrescriptionInlineHint;

  /// Status chip for prescription target readiness
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} targets'**
  String programBuilderPrescriptionReady(int exerciseCount);

  /// Review copy before saving or publishing a program
  ///
  /// In en, this message translates to:
  /// **'Publish to make this the active workout version. Save draft to keep editing.'**
  String get programBuilderPublishReviewMessage;

  /// Review checklist item when the program name is present
  ///
  /// In en, this message translates to:
  /// **'Name ready'**
  String get programBuilderReviewNameReady;

  /// Review checklist item when the program name is missing
  ///
  /// In en, this message translates to:
  /// **'Name missing'**
  String get programBuilderReviewNameMissing;

  /// Review checklist item when exercises exist
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises ready'**
  String programBuilderReviewExercisesReady(int exerciseCount);

  /// Review checklist item when no exercises exist
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get programBuilderReviewExercisesMissing;

  /// Confirmation dialog title before publishing a program version
  ///
  /// In en, this message translates to:
  /// **'Publish version?'**
  String get programBuilderPublishConfirmTitle;

  /// Confirmation dialog body before publishing a program version
  ///
  /// In en, this message translates to:
  /// **'Make this draft the active workout version.'**
  String get programBuilderPublishConfirmMessage;

  /// Confirmation dialog action for publishing a program version
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get programBuilderPublishConfirmAction;

  /// Label for the local-only program draft status
  ///
  /// In en, this message translates to:
  /// **'Local draft'**
  String get programBuilderLocalDraftLabel;

  /// Scope note shown in the P3-07 builder
  ///
  /// In en, this message translates to:
  /// **'Save keeps the draft. Publish creates the active workout version.'**
  String get programBuilderScopeNote;

  /// Program builder summary for days and exercises
  ///
  /// In en, this message translates to:
  /// **'{dayCount}d · {exerciseCount} exercises'**
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
  /// **'Name, muscle, gear, or cue'**
  String get programBuilderExercisePickerSearchHint;

  /// Empty state inside the exercise picker
  ///
  /// In en, this message translates to:
  /// **'No exercises match.'**
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
  /// **'Add exercises, then order this day.'**
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
  /// **'RIR is optional and independent from reps.'**
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
  /// **'Publish'**
  String get programBuilderPublishVersion;

  /// Button label for copying the current program into a new local draft
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get programBuilderCopyProgram;

  /// Button label for archiving the current persisted program
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get programBuilderArchiveProgram;

  /// Status text for an unsaved local program draft
  ///
  /// In en, this message translates to:
  /// **'Draft · unsaved'**
  String get programBuilderLifecycleStatusLocal;

  /// Status text for a saved draft snapshot
  ///
  /// In en, this message translates to:
  /// **'Draft v{versionNumber}'**
  String programBuilderLifecycleStatusSaved(int versionNumber);

  /// Status text for a published active program version
  ///
  /// In en, this message translates to:
  /// **'Active v{versionNumber}'**
  String programBuilderLifecycleStatusPublished(int versionNumber);

  /// Status text for an archived program
  ///
  /// In en, this message translates to:
  /// **'Archived v{versionNumber}'**
  String programBuilderLifecycleStatusArchived(int versionNumber);

  /// Snack bar message after saving a draft snapshot
  ///
  /// In en, this message translates to:
  /// **'Program draft saved.'**
  String get programBuilderDraftSaved;

  /// Snack bar message after publishing a program version
  ///
  /// In en, this message translates to:
  /// **'Program version published.'**
  String get programBuilderVersionPublished;

  /// Snack bar message after copying the current program
  ///
  /// In en, this message translates to:
  /// **'Program copied to a new draft.'**
  String get programBuilderProgramCopied;

  /// Snack bar message after archiving a program
  ///
  /// In en, this message translates to:
  /// **'Program archived.'**
  String get programBuilderProgramArchived;

  /// Generic persistence failure message in the program builder
  ///
  /// In en, this message translates to:
  /// **'Program could not be saved. Check the draft and retry.'**
  String get programBuilderPersistenceFailed;

  /// Default name for a copied program draft
  ///
  /// In en, this message translates to:
  /// **'{programName} copy'**
  String programBuilderCopiedProgramName(String programName);

  /// Subtitle for the Today screen active workout entry point
  ///
  /// In en, this message translates to:
  /// **'Start the next workout from your active plan.'**
  String get todayScreenSubtitle;

  /// Subtitle for the focused active workout route
  ///
  /// In en, this message translates to:
  /// **'Log the current set first.'**
  String get todayActiveWorkoutSubtitle;

  /// Subtitle for the modern Today coach dashboard
  ///
  /// In en, this message translates to:
  /// **'Next session, streak, and review queue.'**
  String get todayCoachDashboardSubtitle;

  /// Title for the Today dashboard hero when a workout is in progress
  ///
  /// In en, this message translates to:
  /// **'Workout active'**
  String get todayCoachResumeTitle;

  /// Title for the next workout mission on Today
  ///
  /// In en, this message translates to:
  /// **'Next: {dayName}'**
  String todayCoachNextWorkoutTitle(String dayName);

  /// Description for the next workout mission on Today
  ///
  /// In en, this message translates to:
  /// **'Start now or change the day.'**
  String get todayCoachNextWorkoutDescription;

  /// Trend text when Today has no active program
  ///
  /// In en, this message translates to:
  /// **'Plan needed'**
  String get todayCoachNoProgramTrend;

  /// Status chip for a Today dashboard that can start a workout
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get todayCoachReadyStatus;

  /// Status chip when Today needs a program first
  ///
  /// In en, this message translates to:
  /// **'Setup first'**
  String get todayCoachSetupStatus;

  /// Primary action for resuming an active workout from Today
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get todayResumeWorkout;

  /// Primary action for starting the selected workout from Today
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get todayQuickStartWorkout;

  /// Primary action for opening Program when Today has no active plan
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get todayCreateProgram;

  /// Secondary action for opening the focused Today workout route
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get todayOpenWorkoutDetails;

  /// Title for the local workout streak card on Today
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get todayStreakTitle;

  /// Workout streak metric on Today
  ///
  /// In en, this message translates to:
  /// **'{dayCount} day streak'**
  String todayStreakValue(int dayCount);

  /// Streak card helper when there is no current streak
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to start a streak.'**
  String get todayStreakEmptyDescription;

  /// Streak card helper when a current streak exists
  ///
  /// In en, this message translates to:
  /// **'Built from completed workout days.'**
  String get todayStreakActiveDescription;

  /// Title for weekly consistency on Today
  ///
  /// In en, this message translates to:
  /// **'Weekly consistency'**
  String get todayWeeklyConsistencyTitle;

  /// Weekly consistency percentage on Today
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String todayWeeklyConsistencyPercent(int percent);

  /// Completed workouts compared to weekly target
  ///
  /// In en, this message translates to:
  /// **'{completedCount} of {targetCount} sessions'**
  String todayWeeklyConsistencyValue(int completedCount, int targetCount);

  /// Weekly consistency helper when no active program exists
  ///
  /// In en, this message translates to:
  /// **'Create a plan to set the weekly target.'**
  String get todayWeeklyConsistencyNoTarget;

  /// Title for the pending recommendation card on Today
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get todayPendingRecommendationTitle;

  /// Pending recommendation card text when a workout needs review
  ///
  /// In en, this message translates to:
  /// **'Review this status before future load changes.'**
  String get todayPendingRecommendationActiveDescription;

  /// Pending recommendation card text when no active program exists
  ///
  /// In en, this message translates to:
  /// **'Create a plan before recommendations appear.'**
  String get todayPendingRecommendationNoProgramDescription;

  /// Pending recommendation card text when there is no review
  ///
  /// In en, this message translates to:
  /// **'No recommendation needs review.'**
  String get todayPendingRecommendationClearDescription;

  /// Count of pending recommendation reviews
  ///
  /// In en, this message translates to:
  /// **'{pendingCount} pending'**
  String todayPendingRecommendationPendingCount(int pendingCount);

  /// Pending recommendation metric when queue is clear
  ///
  /// In en, this message translates to:
  /// **'0 pending'**
  String get todayPendingRecommendationClearCount;

  /// Status chip when recommendation queue is clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get todayPendingRecommendationClearStatus;

  /// Status chip when an active workout was restored locally
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get todaySessionRestoredStatus;

  /// Title shown when Today has no active published program
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get todayNoActiveProgramTitle;

  /// Message shown when Today has no active published program
  ///
  /// In en, this message translates to:
  /// **'Publish a plan in Program before starting.'**
  String get todayNoActiveProgramMessage;

  /// Button that opens the Program branch from Today
  ///
  /// In en, this message translates to:
  /// **'Open Program'**
  String get todayOpenProgramBuilder;

  /// Summary for the active program shown on Today
  ///
  /// In en, this message translates to:
  /// **'Version {versionNumber} · {dayCount} days'**
  String todayActiveProgramSummary(int versionNumber, int dayCount);

  /// Section title for selecting a training day on Today
  ///
  /// In en, this message translates to:
  /// **'Pick day'**
  String get todayChooseTrainingDay;

  /// Summary for a selected training day plan
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises · {setCount} sets'**
  String todayTrainingDaySummary(int exerciseCount, int setCount);

  /// Button label for starting the selected workout session
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get todayStartWorkout;

  /// Snack bar shown after creating a workout session plan
  ///
  /// In en, this message translates to:
  /// **'Workout started.'**
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
  /// **'No exercises yet'**
  String get todayNoExercisesTitle;

  /// Message shown when the selected active training day has no exercises
  ///
  /// In en, this message translates to:
  /// **'Add exercises before starting.'**
  String get todayNoExercisesMessage;

  /// Title for an already active workout session on Today
  ///
  /// In en, this message translates to:
  /// **'Workout active'**
  String get todaySessionInProgressTitle;

  /// Summary for the active workout session on Today
  ///
  /// In en, this message translates to:
  /// **'{exerciseCount} exercises · {setCount} sets'**
  String todaySessionInProgressSummary(int exerciseCount, int setCount);

  /// Instructional message for logging sets during an active workout
  ///
  /// In en, this message translates to:
  /// **'Log each set as you finish.'**
  String get todaySessionInProgressMessage;

  /// Title for the focused current set card in the active workout route
  ///
  /// In en, this message translates to:
  /// **'Current set'**
  String get todayCurrentSetTitle;

  /// Subtitle for the focused current set card
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} · set {setNumber}'**
  String todayCurrentSetSubtitle(String exerciseName, int setNumber);

  /// Title for the compact remaining and completed set queue in the active workout route
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get todayWorkoutQueueTitle;

  /// Compact label for a non-focused set in the active workout queue
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} · set {setNumber} · {status}'**
  String todayWorkoutQueueSetLabel(
    String exerciseName,
    int setNumber,
    String status,
  );

  /// Title shown when every set in the active workout has a logged result
  ///
  /// In en, this message translates to:
  /// **'Workout logged'**
  String get todayWorkoutCompleteTitle;

  /// Message shown when every set in the active workout has a logged result
  ///
  /// In en, this message translates to:
  /// **'All planned sets have results. Review before leaving.'**
  String get todayWorkoutCompleteMessage;

  /// Message shown when an active workout is restored after the app process restarts
  ///
  /// In en, this message translates to:
  /// **'Workout restored from local storage.'**
  String get todaySessionRestoredMessage;

  /// Session-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Session: {status}'**
  String todaySessionStatusLabel(String status);

  /// Exercise-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Exercise: {status}'**
  String todayExerciseStatusLabel(String status);

  /// Set-level calculated status on Today
  ///
  /// In en, this message translates to:
  /// **'Set: {status}'**
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
  /// **'Done'**
  String get todayStatusSuccessful;

  /// Calculated status for a logged set that met its prescription
  ///
  /// In en, this message translates to:
  /// **'Hit target'**
  String get todayStatusTargetMet;

  /// Calculated status when one or more performance misses exist
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get todayStatusNeedsReview;

  /// Calculated status for a set that missed reps, load, strength, or technique target
  ///
  /// In en, this message translates to:
  /// **'Missed target'**
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
  /// **'Logged only'**
  String get todayStatusNotComparable;

  /// Progress summary for completed sets during an active workout
  ///
  /// In en, this message translates to:
  /// **'{completedSetCount}/{setCount} sets'**
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
  /// **'Reps'**
  String get todayActualRepetitionsLabel;

  /// Input label for the completed load value
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get todayActualLoadLabel;

  /// Input label for the completed reps-in-reserve value
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get todayActualRirLabel;

  /// Input label for the set outcome selector
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get todayOutcomeLabel;

  /// Outcome selector option when no limitation or interruption occurred
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get todayOutcomeNone;

  /// Outcome selector option for strength-limited sets
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get todayOutcomeStrengthLimitation;

  /// Outcome selector option for technique-limited sets
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get todayOutcomeTechniqueLimitation;

  /// Outcome selector option for pain reports
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get todayOutcomePain;

  /// Outcome selector option for time-limited sets
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get todayOutcomeTimeLimitation;

  /// Outcome selector option for equipment-limited sets
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get todayOutcomeEquipmentLimitation;

  /// Outcome selector option for externally interrupted sets
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
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
  /// **'No target'**
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
  /// **'Previous: none yet'**
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
  /// **'Set could not save.'**
  String get todaySetLogFailed;

  /// Snack bar shown when set logging inputs are invalid
  ///
  /// In en, this message translates to:
  /// **'Enter valid reps, load, and RIR values.'**
  String get todaySetLogInvalid;

  /// Tooltip for decreasing the active set load by one quick step
  ///
  /// In en, this message translates to:
  /// **'Load down'**
  String get todayQuickLoadDecrease;

  /// Tooltip for increasing the active set load by one quick step
  ///
  /// In en, this message translates to:
  /// **'Load up'**
  String get todayQuickLoadIncrease;

  /// Title for the active workout rest timer panel
  ///
  /// In en, this message translates to:
  /// **'Rest'**
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
  /// **'Rest complete. Start the next set.'**
  String get todayRestTimerComplete;

  /// Button label for dismissing or cancelling the active rest timer
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get todayRestTimerDismiss;

  /// Android notification title for completed rest timers
  ///
  /// In en, this message translates to:
  /// **'Rest complete'**
  String get todayRestTimerNotificationTitle;

  /// Android notification body for completed rest timers
  ///
  /// In en, this message translates to:
  /// **'Start the next set.'**
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
