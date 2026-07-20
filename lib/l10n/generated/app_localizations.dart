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
