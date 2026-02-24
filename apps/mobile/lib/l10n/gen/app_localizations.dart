// dart format off
// coverage:ignore-file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_my.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('my'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Collectra'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSwitchToGrid.
  ///
  /// In en, this message translates to:
  /// **'Switch to grid'**
  String get actionSwitchToGrid;

  /// No description provided for @actionSwitchToList.
  ///
  /// In en, this message translates to:
  /// **'Switch to list'**
  String get actionSwitchToList;

  /// No description provided for @actionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get actionUpdate;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsSectionDeveloper;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsExportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Export to JSON'**
  String get settingsExportJsonTitle;

  /// No description provided for @settingsExportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all data as JSON file'**
  String get settingsExportJsonSubtitle;

  /// No description provided for @settingsExportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get settingsExportCsvTitle;

  /// No description provided for @settingsExportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export items as CSV spreadsheet'**
  String get settingsExportCsvSubtitle;

  /// No description provided for @settingsImportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get settingsImportJsonTitle;

  /// No description provided for @settingsImportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from JSON file'**
  String get settingsImportJsonSubtitle;

  /// No description provided for @settingsCloudSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get settingsCloudSyncTitle;

  /// No description provided for @settingsCloudSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get settingsCloudSyncSubtitle;

  /// No description provided for @settingsManageTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get settingsManageTagsTitle;

  /// No description provided for @settingsManageTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename, merge, and delete tags'**
  String get settingsManageTagsSubtitle;

  /// No description provided for @settingsLoanTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan Tracking'**
  String get settingsLoanTrackingTitle;

  /// No description provided for @settingsLoanTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track borrowed items and return dates'**
  String get settingsLoanTrackingSubtitle;

  /// No description provided for @settingsVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersionTitle;

  /// No description provided for @settingsPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicyTitle;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsTitle;

  /// No description provided for @settingsAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get settingsAnalyticsTitle;

  /// No description provided for @settingsAnalyticsSummaryEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsAnalyticsSummaryEnabled;

  /// No description provided for @settingsAnalyticsSummaryDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsAnalyticsSummaryDisabled;

  /// No description provided for @settingsAnalyticsSummaryPending.
  ///
  /// In en, this message translates to:
  /// **'Consent required'**
  String get settingsAnalyticsSummaryPending;

  /// No description provided for @settingsAnalyticsSummaryDenied.
  ///
  /// In en, this message translates to:
  /// **'Consent declined'**
  String get settingsAnalyticsSummaryDenied;

  /// No description provided for @settingsAnalyticsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics Preferences'**
  String get settingsAnalyticsSheetTitle;

  /// No description provided for @settingsAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Control anonymous usage analytics and data sharing preferences.'**
  String get settingsAnalyticsDescription;

  /// No description provided for @settingsAnalyticsToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable analytics'**
  String get settingsAnalyticsToggleTitle;

  /// No description provided for @settingsAnalyticsToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow anonymous app usage events to be collected.'**
  String get settingsAnalyticsToggleSubtitle;

  /// No description provided for @settingsAnalyticsConsentStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent status'**
  String get settingsAnalyticsConsentStatusTitle;

  /// No description provided for @settingsAnalyticsConsentStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get settingsAnalyticsConsentStatusGranted;

  /// No description provided for @settingsAnalyticsConsentStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get settingsAnalyticsConsentStatusDenied;

  /// No description provided for @settingsAnalyticsConsentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get settingsAnalyticsConsentStatusPending;

  /// No description provided for @settingsAnalyticsReviewConsentAction.
  ///
  /// In en, this message translates to:
  /// **'Review Consent'**
  String get settingsAnalyticsReviewConsentAction;

  /// No description provided for @settingsAnalyticsRevokeConsentAction.
  ///
  /// In en, this message translates to:
  /// **'Revoke Consent'**
  String get settingsAnalyticsRevokeConsentAction;

  /// No description provided for @settingsAnalyticsConsentAccepted.
  ///
  /// In en, this message translates to:
  /// **'Analytics consent accepted.'**
  String get settingsAnalyticsConsentAccepted;

  /// No description provided for @settingsAnalyticsConsentDeclined.
  ///
  /// In en, this message translates to:
  /// **'Analytics consent declined.'**
  String get settingsAnalyticsConsentDeclined;

  /// No description provided for @analyticsConsentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Improve Collectra'**
  String get analyticsConsentDialogTitle;

  /// No description provided for @analyticsConsentDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Can we collect anonymous usage analytics to improve app quality and features? You can change this anytime in Settings.'**
  String get analyticsConsentDialogMessage;

  /// No description provided for @analyticsConsentAllowAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get analyticsConsentAllowAction;

  /// No description provided for @analyticsConsentDeclineAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get analyticsConsentDeclineAction;

  /// No description provided for @settingsCrashlyticsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Crashlytics'**
  String get settingsCrashlyticsTestTitle;

  /// No description provided for @settingsCrashlyticsTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Intentionally crash the app to verify crash reporting'**
  String get settingsCrashlyticsTestSubtitle;

  /// No description provided for @settingsCrashlyticsTestConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger test crash?'**
  String get settingsCrashlyticsTestConfirmTitle;

  /// No description provided for @settingsCrashlyticsTestConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will crash immediately. Re-open the app to verify the crash in Firebase Crashlytics.'**
  String get settingsCrashlyticsTestConfirmMessage;

  /// No description provided for @settingsCrashlyticsTestConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Crash Now'**
  String get settingsCrashlyticsTestConfirmAction;

  /// No description provided for @settingsCrashlyticsTestTriggered.
  ///
  /// In en, this message translates to:
  /// **'Triggering test crash...'**
  String get settingsCrashlyticsTestTriggered;

  /// No description provided for @settingsCrashlyticsTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to trigger crash test: {error}'**
  String settingsCrashlyticsTestFailed(String error);

  /// No description provided for @settingsFirebaseRuntimeConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase Runtime Config'**
  String get settingsFirebaseRuntimeConfigTitle;

  /// No description provided for @settingsFirebaseRuntimeConfigSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inspect and refresh runtime feature flags'**
  String get settingsFirebaseRuntimeConfigSubtitle;

  /// No description provided for @settingsMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata & Autofill'**
  String get settingsMetadataTitle;

  /// No description provided for @settingsMetadataSummaryEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled with automatic barcode lookup'**
  String get settingsMetadataSummaryEnabled;

  /// No description provided for @settingsMetadataSummaryManual.
  ///
  /// In en, this message translates to:
  /// **'Enabled with manual lookup'**
  String get settingsMetadataSummaryManual;

  /// No description provided for @settingsMetadataSummaryDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsMetadataSummaryDisabled;

  /// No description provided for @settingsMetadataSummaryFeatureDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled by runtime feature flag'**
  String get settingsMetadataSummaryFeatureDisabled;

  /// No description provided for @settingsMetadataEnableToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable metadata assistance'**
  String get settingsMetadataEnableToggleTitle;

  /// No description provided for @settingsMetadataEnableToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow metadata search and barcode-based autofill in item forms.'**
  String get settingsMetadataEnableToggleSubtitle;

  /// No description provided for @settingsMetadataAutoFetchToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetch from barcode scan'**
  String get settingsMetadataAutoFetchToggleTitle;

  /// No description provided for @settingsMetadataAutoFetchToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After scanning a barcode, fetch metadata automatically.'**
  String get settingsMetadataAutoFetchToggleSubtitle;

  /// No description provided for @settingsMetadataFillEmptyOnlyToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill empty fields only'**
  String get settingsMetadataFillEmptyOnlyToggleTitle;

  /// No description provided for @settingsMetadataFillEmptyOnlyToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do not overwrite existing title or description when metadata is found.'**
  String get settingsMetadataFillEmptyOnlyToggleSubtitle;

  /// No description provided for @settingsMetadataSourcesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get settingsMetadataSourcesSectionTitle;

  /// No description provided for @settingsMetadataSourceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get settingsMetadataSourceAvailable;

  /// No description provided for @settingsMetadataSourceNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get settingsMetadataSourceNotConfigured;

  /// No description provided for @settingsMetadataSourceManualOnly.
  ///
  /// In en, this message translates to:
  /// **'Manual only'**
  String get settingsMetadataSourceManualOnly;

  /// No description provided for @settingsMetadataManualCollectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Comics, Music, and Custom'**
  String get settingsMetadataManualCollectionsLabel;

  /// No description provided for @settingsMetadataFeatureDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Metadata assistance is disabled by runtime configuration.'**
  String get settingsMetadataFeatureDisabledMessage;

  /// No description provided for @settingsFirebaseRuntimeConfigSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase Runtime Config'**
  String get settingsFirebaseRuntimeConfigSheetTitle;

  /// No description provided for @settingsFirebaseRuntimeConfigDescription.
  ///
  /// In en, this message translates to:
  /// **'Values are fetched from Firebase Remote Config and applied at runtime.'**
  String get settingsFirebaseRuntimeConfigDescription;

  /// No description provided for @settingsFirebaseRuntimeConfigSummary.
  ///
  /// In en, this message translates to:
  /// **'{enabledCount} of 3 signals enabled'**
  String settingsFirebaseRuntimeConfigSummary(int enabledCount);

  /// No description provided for @settingsFirebaseRuntimeConfigAnalyticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Analytics collection'**
  String get settingsFirebaseRuntimeConfigAnalyticsLabel;

  /// No description provided for @settingsFirebaseRuntimeConfigCrashlyticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Crashlytics collection'**
  String get settingsFirebaseRuntimeConfigCrashlyticsLabel;

  /// No description provided for @settingsFirebaseRuntimeConfigPerformanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance collection'**
  String get settingsFirebaseRuntimeConfigPerformanceLabel;

  /// No description provided for @settingsFirebaseRuntimeConfigFetchStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Last fetch status'**
  String get settingsFirebaseRuntimeConfigFetchStatusTitle;

  /// No description provided for @settingsFirebaseRuntimeConfigLastFetchTitle.
  ///
  /// In en, this message translates to:
  /// **'Last fetch time'**
  String get settingsFirebaseRuntimeConfigLastFetchTitle;

  /// No description provided for @settingsFirebaseRuntimeConfigValueEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsFirebaseRuntimeConfigValueEnabled;

  /// No description provided for @settingsFirebaseRuntimeConfigValueDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsFirebaseRuntimeConfigValueDisabled;

  /// No description provided for @settingsFirebaseRuntimeConfigFetchStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get settingsFirebaseRuntimeConfigFetchStatusSuccess;

  /// No description provided for @settingsFirebaseRuntimeConfigFetchStatusFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get settingsFirebaseRuntimeConfigFetchStatusFailure;

  /// No description provided for @settingsFirebaseRuntimeConfigFetchStatusThrottled.
  ///
  /// In en, this message translates to:
  /// **'Throttled'**
  String get settingsFirebaseRuntimeConfigFetchStatusThrottled;

  /// No description provided for @settingsFirebaseRuntimeConfigFetchStatusNoFetch.
  ///
  /// In en, this message translates to:
  /// **'No fetch yet'**
  String get settingsFirebaseRuntimeConfigFetchStatusNoFetch;

  /// No description provided for @settingsFirebaseRuntimeConfigRefreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh config'**
  String get settingsFirebaseRuntimeConfigRefreshAction;

  /// No description provided for @settingsFirebaseRuntimeConfigRefreshingAction.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get settingsFirebaseRuntimeConfigRefreshingAction;

  /// No description provided for @settingsFirebaseRuntimeConfigRefreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Firebase runtime config refreshed.'**
  String get settingsFirebaseRuntimeConfigRefreshSuccess;

  /// No description provided for @settingsFirebaseRuntimeConfigRefreshNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Firebase runtime config is already up to date.'**
  String get settingsFirebaseRuntimeConfigRefreshNoChanges;

  /// No description provided for @settingsFirebaseRuntimeConfigRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh config: {error}'**
  String settingsFirebaseRuntimeConfigRefreshFailed(String error);

  /// No description provided for @settingsExportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get settingsExportingData;

  /// No description provided for @settingsDataExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get settingsDataExportSuccess;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @settingsImportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get settingsImportDataTitle;

  /// No description provided for @settingsImportDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will import collections and items from a JSON file. Existing data will not be deleted.\n\nContinue?'**
  String get settingsImportDataMessage;

  /// No description provided for @settingsImportingData.
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get settingsImportingData;

  /// No description provided for @settingsDataImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully!'**
  String get settingsDataImportSuccess;

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailed(String error);

  /// No description provided for @settingsThemeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeModeTitle;

  /// No description provided for @settingsThemeColorVariantTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Variant'**
  String get settingsThemeColorVariantTitle;

  /// No description provided for @settingsAmoledTitle.
  ///
  /// In en, this message translates to:
  /// **'Amoled Mode (Pure Black)'**
  String get settingsAmoledTitle;

  /// No description provided for @settingsAmoledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduces battery consumption on OLED screens'**
  String get settingsAmoledSubtitle;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChineseSimplified;

  /// No description provided for @languageBurmese.
  ///
  /// In en, this message translates to:
  /// **'မြန်မာ'**
  String get languageBurmese;

  /// No description provided for @collectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get collectionsTitle;

  /// No description provided for @collectionsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsCountLabel;

  /// No description provided for @collectionsNewButton.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get collectionsNewButton;

  /// No description provided for @collectionsActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection actions'**
  String get collectionsActionsTooltip;

  /// No description provided for @collectionsOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open Collection'**
  String get collectionsOpenAction;

  /// No description provided for @collectionsEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get collectionsEditAction;

  /// No description provided for @collectionsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Collection'**
  String get collectionsDeleteTitle;

  /// No description provided for @collectionsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and {itemCount} items in this collection?'**
  String collectionsDeleteMessage(String name, int itemCount);

  /// No description provided for @collectionsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String collectionsDeleted(String name);

  /// No description provided for @collectionsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading collections: {error}'**
  String collectionsErrorLoading(String error);

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// No description provided for @itemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsCountLabel;

  /// No description provided for @itemsCountWithValue.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCountWithValue(int count);

  /// No description provided for @itemsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get itemsSearchHint;

  /// No description provided for @itemsNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get itemsNoMatchesTitle;

  /// No description provided for @itemsNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or keywords.'**
  String get itemsNoMatchesMessage;

  /// No description provided for @itemsNoItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get itemsNoItemsTitle;

  /// No description provided for @itemsNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first item.'**
  String get itemsNoItemsMessage;

  /// No description provided for @itemsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get itemsAddButton;

  /// No description provided for @itemsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading items...'**
  String get itemsLoadingMessage;

  /// No description provided for @itemsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading items: {error}'**
  String itemsErrorLoading(String error);

  /// No description provided for @itemsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get itemsDeleteTitle;

  /// No description provided for @itemsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String itemsDeleteMessage(String name);

  /// No description provided for @itemsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String itemsDeleted(String name);

  /// No description provided for @itemsOverviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsOverviewCount(int count);

  /// No description provided for @itemsSortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sorted by {sortLabel}'**
  String itemsSortedBy(String sortLabel);

  /// No description provided for @itemsCollectionDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection details'**
  String get itemsCollectionDetailsTooltip;

  /// No description provided for @itemsFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get itemsFiltersTooltip;

  /// No description provided for @itemsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Items'**
  String get itemsFilterTitle;

  /// No description provided for @itemsSortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get itemsSortByTitle;

  /// No description provided for @itemsFilterFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get itemsFilterFavoritesOnly;

  /// No description provided for @itemsFilterWishlistOnly.
  ///
  /// In en, this message translates to:
  /// **'Wishlist only'**
  String get itemsFilterWishlistOnly;

  /// No description provided for @itemsFilterConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get itemsFilterConditionsTitle;

  /// No description provided for @itemsTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get itemsTagsTitle;

  /// No description provided for @itemsQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String itemsQuantityLabel(int quantity);

  /// No description provided for @itemsQuantityShort.
  ///
  /// In en, this message translates to:
  /// **'x{quantity}'**
  String itemsQuantityShort(int quantity);

  /// No description provided for @itemSortCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom order'**
  String get itemSortCustom;

  /// No description provided for @itemSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get itemSortTitle;

  /// No description provided for @itemSortCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get itemSortCreatedAt;

  /// No description provided for @itemSortPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get itemSortPurchaseDate;

  /// No description provided for @itemSortCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get itemSortCurrentValue;

  /// No description provided for @itemSortQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemSortQuantity;

  /// No description provided for @itemConditionMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get itemConditionMint;

  /// No description provided for @itemConditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get itemConditionGood;

  /// No description provided for @itemConditionFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get itemConditionFair;

  /// No description provided for @itemConditionPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get itemConditionPoor;

  /// No description provided for @itemDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get itemDetailNotFoundTitle;

  /// No description provided for @itemDetailNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get itemDetailNotFoundMessage;

  /// No description provided for @itemDetailFavorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get itemDetailFavorited;

  /// No description provided for @itemDetailFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get itemDetailFavorite;

  /// No description provided for @itemDetailInWishlist.
  ///
  /// In en, this message translates to:
  /// **'In Wishlist'**
  String get itemDetailInWishlist;

  /// No description provided for @itemDetailPriceTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Price tracking'**
  String get itemDetailPriceTrackingTitle;

  /// No description provided for @itemDetailNoValueMessage.
  ///
  /// In en, this message translates to:
  /// **'No current value available'**
  String get itemDetailNoValueMessage;

  /// No description provided for @itemDetailNoHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'No price history yet'**
  String get itemDetailNoHistoryMessage;

  /// No description provided for @itemDetailPriceHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load price history'**
  String get itemDetailPriceHistoryError;

  /// No description provided for @itemDetailDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get itemDetailDetailsTitle;

  /// No description provided for @itemDetailBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get itemDetailBarcodeLabel;

  /// No description provided for @itemDetailConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get itemDetailConditionLabel;

  /// No description provided for @itemDetailQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemDetailQuantityLabel;

  /// No description provided for @itemDetailLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get itemDetailLocationLabel;

  /// No description provided for @itemDetailPurchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get itemDetailPurchasePriceLabel;

  /// No description provided for @itemDetailCurrentValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get itemDetailCurrentValueLabel;

  /// No description provided for @itemDetailPurchaseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get itemDetailPurchaseDateLabel;

  /// No description provided for @itemDetailNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemDetailNotesTitle;

  /// No description provided for @itemDetailLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading item details...'**
  String get itemDetailLoadingMessage;

  /// No description provided for @itemDetailErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading item details: {error}'**
  String itemDetailErrorLoading(String error);

  /// No description provided for @itemDetailUpdateValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Update current value'**
  String get itemDetailUpdateValueTitle;

  /// No description provided for @itemDetailCurrentValueUpdated.
  ///
  /// In en, this message translates to:
  /// **'Current value updated'**
  String get itemDetailCurrentValueUpdated;

  /// No description provided for @itemDetailUpdateValueFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update value: {error}'**
  String itemDetailUpdateValueFailed(String error);

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemTitle;

  /// No description provided for @addItemSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemSubmit;

  /// No description provided for @addItemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., The Lord of the Rings'**
  String get addItemTitleHint;

  /// No description provided for @addItemFetchingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Fetching metadata...'**
  String get addItemFetchingMetadata;

  /// No description provided for @addItemMatchedMetadata.
  ///
  /// In en, this message translates to:
  /// **'Matched {source} metadata'**
  String addItemMatchedMetadata(String source);

  /// No description provided for @addItemTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Rare, Completed Set'**
  String get addItemTagsHint;

  /// No description provided for @addItemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item added successfully'**
  String get addItemSuccess;

  /// No description provided for @addItemError.
  ///
  /// In en, this message translates to:
  /// **'Error adding item: {error}'**
  String addItemError(String error);

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItemTitle;

  /// No description provided for @editItemLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading item...'**
  String get editItemLoading;

  /// No description provided for @editItemError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String editItemError(String error);

  /// No description provided for @editItemSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editItemSaveChanges;

  /// No description provided for @editItemTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Signed, First Edition'**
  String get editItemTagsHint;

  /// No description provided for @editItemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully'**
  String get editItemSuccess;

  /// No description provided for @editItemUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating item: {error}'**
  String editItemUpdateError(String error);

  /// No description provided for @itemFormTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get itemFormTitleLabel;

  /// No description provided for @itemFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get itemFormTitleRequired;

  /// No description provided for @itemFormBarcodeLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get itemFormBarcodeLabelOptional;

  /// No description provided for @itemFormBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'ISBN, UPC, etc.'**
  String get itemFormBarcodeHint;

  /// No description provided for @itemFormDescriptionLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get itemFormDescriptionLabelOptional;

  /// No description provided for @itemFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get itemFormDescriptionHint;

  /// No description provided for @itemFormTagsLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get itemFormTagsLabelOptional;

  /// No description provided for @itemFormPurchaseDateLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date (optional)'**
  String get itemFormPurchaseDateLabelOptional;

  /// No description provided for @itemFormConditionLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Condition (optional)'**
  String get itemFormConditionLabelOptional;

  /// No description provided for @itemFormQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get itemFormQuantityRequired;

  /// No description provided for @itemFormQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get itemFormQuantityInvalid;

  /// No description provided for @itemFormLocationLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get itemFormLocationLabelOptional;

  /// No description provided for @itemFormLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Shelf A, Box 3'**
  String get itemFormLocationHint;

  /// No description provided for @itemFormNotesLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get itemFormNotesLabelOptional;

  /// No description provided for @itemFormInvalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get itemFormInvalidPrice;

  /// No description provided for @itemFormMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be positive'**
  String get itemFormMustBePositive;

  /// No description provided for @itemTagsEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get itemTagsEditorHint;

  /// No description provided for @itemTagsEditorAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get itemTagsEditorAddTooltip;

  /// No description provided for @itemTagsEditorEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add tags to organize items faster.'**
  String get itemTagsEditorEmptyMessage;

  /// No description provided for @itemTagsEditorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Tags must be 50 characters or less'**
  String get itemTagsEditorTooLong;

  /// No description provided for @globalItemsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading items...'**
  String get globalItemsLoading;

  /// No description provided for @globalItemsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String globalItemsErrorLoading(String error);

  /// No description provided for @globalItemsNoFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite items yet'**
  String get globalItemsNoFavoritesTitle;

  /// No description provided for @globalItemsNoFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark items as favorite to see them here.'**
  String get globalItemsNoFavoritesMessage;

  /// No description provided for @globalItemsNoWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get globalItemsNoWishlistTitle;

  /// No description provided for @globalItemsNoWishlistMessage.
  ///
  /// In en, this message translates to:
  /// **'Save items to wishlist and access them here.'**
  String get globalItemsNoWishlistMessage;

  /// No description provided for @metadataSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search {collectionType} by title'**
  String metadataSearchFieldLabel(String collectionType);

  /// No description provided for @metadataSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get metadataSearchEmptyTitle;

  /// No description provided for @metadataSearchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a title to search.'**
  String get metadataSearchEmptyMessage;

  /// No description provided for @metadataSearchLoading.
  ///
  /// In en, this message translates to:
  /// **'Searching metadata...'**
  String get metadataSearchLoading;

  /// No description provided for @metadataSearchError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String metadataSearchError(String error);

  /// No description provided for @metadataSearchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get metadataSearchNoResultsTitle;

  /// No description provided for @metadataSearchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No metadata found for this title.'**
  String get metadataSearchNoResultsMessage;

  /// No description provided for @metadataSearchSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get metadataSearchSuggestionTitle;

  /// No description provided for @metadataSearchSuggestionMessage.
  ///
  /// In en, this message translates to:
  /// **'Start typing to look up metadata.'**
  String get metadataSearchSuggestionMessage;

  /// No description provided for @metadataSearchDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Metadata search is unavailable for this collection type or currently disabled.'**
  String get metadataSearchDisabledHint;

  /// No description provided for @metadataNoMatchForBarcode.
  ///
  /// In en, this message translates to:
  /// **'No metadata match found for this barcode.'**
  String get metadataNoMatchForBarcode;

  /// No description provided for @metadataSearchUnavailableForType.
  ///
  /// In en, this message translates to:
  /// **'Metadata search is unavailable for {collectionType}.'**
  String metadataSearchUnavailableForType(String collectionType);

  /// No description provided for @tagItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag: {tag}'**
  String tagItemsTitle(String tag);

  /// No description provided for @tagItemsSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get tagItemsSortTooltip;

  /// No description provided for @tagItemsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Sort: Newest'**
  String get tagItemsSortNewest;

  /// No description provided for @tagItemsSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Sort: Oldest'**
  String get tagItemsSortOldest;

  /// No description provided for @tagItemsSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort: Title'**
  String get tagItemsSortTitle;

  /// No description provided for @tagItemsLoadingCollections.
  ///
  /// In en, this message translates to:
  /// **'Loading collections...'**
  String get tagItemsLoadingCollections;

  /// No description provided for @tagItemsLoadingItems.
  ///
  /// In en, this message translates to:
  /// **'Loading tagged items...'**
  String get tagItemsLoadingItems;

  /// No description provided for @tagItemsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String tagItemsError(String error);

  /// No description provided for @tagItemsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get tagItemsEmptyTitle;

  /// No description provided for @tagItemsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No collection items currently use this tag.'**
  String get tagItemsEmptyMessage;

  /// No description provided for @tagItemsUnknownCollection.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get tagItemsUnknownCollection;

  /// No description provided for @tagItemsOpenCollectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open collection'**
  String get tagItemsOpenCollectionTooltip;

  /// No description provided for @tagItemsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String tagItemsDeleteFailed(String error);

  /// No description provided for @tagManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get tagManagementTitle;

  /// No description provided for @tagManagementSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String tagManagementSelectedCount(int count);

  /// No description provided for @tagManagementCancelSelectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get tagManagementCancelSelectionTooltip;

  /// No description provided for @tagManagementSelectTagsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select tags'**
  String get tagManagementSelectTagsTooltip;

  /// No description provided for @tagManagementSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tags...'**
  String get tagManagementSearchHint;

  /// No description provided for @tagManagementEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tags created yet'**
  String get tagManagementEmptyTitle;

  /// No description provided for @tagManagementNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tags match \"{query}\"'**
  String tagManagementNoMatch(String query);

  /// No description provided for @tagManagementSelectVisible.
  ///
  /// In en, this message translates to:
  /// **'Select visible'**
  String get tagManagementSelectVisible;

  /// No description provided for @tagManagementSelectAllMatches.
  ///
  /// In en, this message translates to:
  /// **'Select all matches'**
  String get tagManagementSelectAllMatches;

  /// No description provided for @tagManagementClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get tagManagementClearSelection;

  /// No description provided for @tagManagementScrollMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load {remaining} more tags'**
  String tagManagementScrollMore(int remaining);

  /// No description provided for @tagManagementUsedInOne.
  ///
  /// In en, this message translates to:
  /// **'Used in 1 item'**
  String get tagManagementUsedInOne;

  /// No description provided for @tagManagementUsedInMany.
  ///
  /// In en, this message translates to:
  /// **'Used in {count} items'**
  String tagManagementUsedInMany(int count);

  /// No description provided for @tagManagementRenameAction.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tagManagementRenameAction;

  /// No description provided for @tagManagementMergeAction.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get tagManagementMergeAction;

  /// No description provided for @tagManagementMergeIntoAction.
  ///
  /// In en, this message translates to:
  /// **'Merge Into...'**
  String get tagManagementMergeIntoAction;

  /// No description provided for @tagManagementLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tags: {error}'**
  String tagManagementLoadError(String error);

  /// No description provided for @tagManagementRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Tag'**
  String get tagManagementRenameTitle;

  /// No description provided for @tagManagementNewNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get tagManagementNewNameLabel;

  /// No description provided for @tagManagementRenameSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{oldName}\" renamed to \"{newName}\"'**
  String tagManagementRenameSuccess(String oldName, String newName);

  /// No description provided for @tagManagementMergeSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge Selected Tags'**
  String get tagManagementMergeSelectedTitle;

  /// No description provided for @tagManagementChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination tag:'**
  String get tagManagementChooseDestination;

  /// No description provided for @tagManagementMergeSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Merged {count} tags into \"{destination}\"'**
  String tagManagementMergeSelectedSuccess(int count, String destination);

  /// No description provided for @tagManagementDeleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Tags'**
  String get tagManagementDeleteSelectedTitle;

  /// No description provided for @tagManagementDeleteSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected tags from all items?\n\nThis cannot be undone.'**
  String tagManagementDeleteSelectedMessage(int count);

  /// No description provided for @tagManagementDeleteSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} tags'**
  String tagManagementDeleteSelectedSuccess(int count);

  /// No description provided for @tagManagementMergeIntoTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge Into'**
  String get tagManagementMergeIntoTitle;

  /// No description provided for @tagManagementMergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{source}\" merged into \"{target}\"'**
  String tagManagementMergeSuccess(String source, String target);

  /// No description provided for @tagManagementDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get tagManagementDeleteTitle;

  /// No description provided for @tagManagementDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{tagName}\" from all items?\n\nThis cannot be undone.'**
  String tagManagementDeleteMessage(String tagName);

  /// No description provided for @tagManagementDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{tagName}\" deleted'**
  String tagManagementDeleteSuccess(String tagName);

  /// No description provided for @tagManagementMutationError.
  ///
  /// In en, this message translates to:
  /// **'Tag update failed: {error}'**
  String tagManagementMutationError(String error);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get statisticsEmptyTitle;

  /// No description provided for @statisticsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add collections and items to see insights.'**
  String get statisticsEmptyMessage;

  /// No description provided for @statisticsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get statisticsLoadingMessage;

  /// No description provided for @statisticsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String statisticsErrorLoading(String error);

  /// No description provided for @statisticsPortfolioValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio value'**
  String get statisticsPortfolioValueTitle;

  /// No description provided for @statisticsAveragePricedItem.
  ///
  /// In en, this message translates to:
  /// **'Avg priced item: {value}'**
  String statisticsAveragePricedItem(String value);

  /// No description provided for @statisticsPricedItemsBadge.
  ///
  /// In en, this message translates to:
  /// **'Priced items: {priced}/{total}'**
  String statisticsPricedItemsBadge(int priced, int total);

  /// No description provided for @statisticsQuantityTitle.
  ///
  /// In en, this message translates to:
  /// **'Total quantity'**
  String get statisticsQuantityTitle;

  /// No description provided for @statisticsFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get statisticsFavoritesTitle;

  /// No description provided for @statisticsPercentOfItems.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of items'**
  String statisticsPercentOfItems(String percent);

  /// No description provided for @statisticsInventoryHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory health'**
  String get statisticsInventoryHealthTitle;

  /// No description provided for @statisticsValuationCoverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Valuation coverage'**
  String get statisticsValuationCoverageLabel;

  /// No description provided for @statisticsPricedCaption.
  ///
  /// In en, this message translates to:
  /// **'{priced} of {total} items have prices'**
  String statisticsPricedCaption(int priced, int total);

  /// No description provided for @statisticsFavoritesCoverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites coverage'**
  String get statisticsFavoritesCoverageLabel;

  /// No description provided for @statisticsFavoritesCaption.
  ///
  /// In en, this message translates to:
  /// **'{favorites} of {total} items are favorites'**
  String statisticsFavoritesCaption(int favorites, int total);

  /// No description provided for @statisticsWishlistCoverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Wishlist coverage'**
  String get statisticsWishlistCoverageLabel;

  /// No description provided for @statisticsWishlistCaption.
  ///
  /// In en, this message translates to:
  /// **'{wishlist} of {total} items are on wishlist'**
  String statisticsWishlistCaption(int wishlist, int total);

  /// No description provided for @statisticsItemsByTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Items by type'**
  String get statisticsItemsByTypeTitle;

  /// No description provided for @statisticsItemsByConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Items by condition'**
  String get statisticsItemsByConditionTitle;

  /// No description provided for @statisticsTopValuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Top valued collections'**
  String get statisticsTopValuedTitle;

  /// No description provided for @statisticsLargestCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Largest collection'**
  String get statisticsLargestCollectionTitle;

  /// No description provided for @statisticsRecentlyCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently created'**
  String get statisticsRecentlyCreatedTitle;

  /// No description provided for @statisticsRecentCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{itemCount} items • {createdAt}'**
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt);

  /// No description provided for @statisticsNoChartData.
  ///
  /// In en, this message translates to:
  /// **'No chart data available'**
  String get statisticsNoChartData;

  /// No description provided for @statisticsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statisticsTotalLabel;

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String relativeDaysAgo(int days);

  /// No description provided for @relativeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String relativeWeeksAgo(int weeks);

  /// No description provided for @relativeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String relativeMonthsAgo(int months);

  /// No description provided for @relativeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{years} years ago'**
  String relativeYearsAgo(int years);

  /// No description provided for @collectionDetailsNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection not found'**
  String get collectionDetailsNotFoundTitle;

  /// No description provided for @collectionDetailsNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected collection is not available.'**
  String get collectionDetailsNotFoundMessage;

  /// No description provided for @collectionDetailsCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get collectionDetailsCreatedLabel;

  /// No description provided for @collectionDetailsUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get collectionDetailsUpdatedLabel;

  /// No description provided for @collectionDetailsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading collection...'**
  String get collectionDetailsLoading;

  /// No description provided for @collectionTypeBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get collectionTypeBooks;

  /// No description provided for @collectionTypeGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get collectionTypeGames;

  /// No description provided for @collectionTypeMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get collectionTypeMovies;

  /// No description provided for @collectionTypeComics.
  ///
  /// In en, this message translates to:
  /// **'Comics'**
  String get collectionTypeComics;

  /// No description provided for @collectionTypeMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get collectionTypeMusic;

  /// No description provided for @collectionTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get collectionTypeCustom;

  /// No description provided for @loanTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan Tracking'**
  String get loanTrackingTitle;

  /// No description provided for @loanTrackingNewLoan.
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get loanTrackingNewLoan;

  /// No description provided for @loanTrackingFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loanTrackingFilterActive;

  /// No description provided for @loanTrackingFilterHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get loanTrackingFilterHistory;

  /// No description provided for @loanTrackingEmptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No returned loans yet'**
  String get loanTrackingEmptyHistoryTitle;

  /// No description provided for @loanTrackingEmptyHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Returned items will appear here.'**
  String get loanTrackingEmptyHistoryMessage;

  /// No description provided for @loanTrackingEmptyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No active loans'**
  String get loanTrackingEmptyActiveTitle;

  /// No description provided for @loanTrackingEmptyActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a loan to start tracking borrowed items.'**
  String get loanTrackingEmptyActiveMessage;

  /// No description provided for @loanTrackingLoadingLoans.
  ///
  /// In en, this message translates to:
  /// **'Loading loans...'**
  String get loanTrackingLoadingLoans;

  /// No description provided for @loanTrackingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load loans: {error}'**
  String loanTrackingLoadFailed(String error);

  /// No description provided for @loanTrackingMarkReturnedConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as returned?'**
  String get loanTrackingMarkReturnedConfirmTitle;

  /// No description provided for @loanTrackingMarkReturnedConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm return for \"{itemTitle}\".'**
  String loanTrackingMarkReturnedConfirmMessage(String itemTitle);

  /// No description provided for @loanTrackingMarkReturnedAction.
  ///
  /// In en, this message translates to:
  /// **'Mark Returned'**
  String get loanTrackingMarkReturnedAction;

  /// No description provided for @loanTrackingMarkedReturnedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Loan marked as returned.'**
  String get loanTrackingMarkedReturnedSuccess;

  /// No description provided for @loanTrackingMarkReturnedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark return: {error}'**
  String loanTrackingMarkReturnedFailed(String error);

  /// No description provided for @loanTrackingDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete loan record?'**
  String get loanTrackingDeleteConfirmTitle;

  /// No description provided for @loanTrackingDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete loan record for \"{itemTitle}\".'**
  String loanTrackingDeleteConfirmMessage(String itemTitle);

  /// No description provided for @loanTrackingDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Loan deleted.'**
  String get loanTrackingDeleteSuccess;

  /// No description provided for @loanTrackingDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete loan: {error}'**
  String loanTrackingDeleteFailed(String error);

  /// No description provided for @loanTrackingSummaryActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get loanTrackingSummaryActiveLabel;

  /// No description provided for @loanTrackingSummaryOverdueLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get loanTrackingSummaryOverdueLabel;

  /// No description provided for @loanTrackingSummaryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load loan summary.'**
  String get loanTrackingSummaryLoadFailed;

  /// No description provided for @loanTrackingFieldBorrower.
  ///
  /// In en, this message translates to:
  /// **'Borrower'**
  String get loanTrackingFieldBorrower;

  /// No description provided for @loanTrackingFieldContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get loanTrackingFieldContact;

  /// No description provided for @loanTrackingFieldLoaned.
  ///
  /// In en, this message translates to:
  /// **'Loaned'**
  String get loanTrackingFieldLoaned;

  /// No description provided for @loanTrackingFieldDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get loanTrackingFieldDue;

  /// No description provided for @loanTrackingFieldReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get loanTrackingFieldReturned;

  /// No description provided for @loanTrackingStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get loanTrackingStatusReturned;

  /// No description provided for @loanTrackingStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get loanTrackingStatusOverdue;

  /// No description provided for @loanTrackingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loanTrackingStatusActive;

  /// No description provided for @loanTrackingCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Loan'**
  String get loanTrackingCreateTitle;

  /// No description provided for @loanTrackingCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Track who borrowed an item and when it should be returned.'**
  String get loanTrackingCreateDescription;

  /// No description provided for @loanTrackingCreateNoItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No available items'**
  String get loanTrackingCreateNoItemsTitle;

  /// No description provided for @loanTrackingCreateNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'All items are currently loaned or there are no items yet.'**
  String get loanTrackingCreateNoItemsMessage;

  /// No description provided for @loanTrackingCreateItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get loanTrackingCreateItemLabel;

  /// No description provided for @loanTrackingCreateBorrowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrower name'**
  String get loanTrackingCreateBorrowerLabel;

  /// No description provided for @loanTrackingCreateBorrowerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get loanTrackingCreateBorrowerHint;

  /// No description provided for @loanTrackingCreateContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact (optional)'**
  String get loanTrackingCreateContactLabel;

  /// No description provided for @loanTrackingCreateContactHint.
  ///
  /// In en, this message translates to:
  /// **'Phone, email, or @username'**
  String get loanTrackingCreateContactHint;

  /// No description provided for @loanTrackingCreateNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get loanTrackingCreateNotesLabel;

  /// No description provided for @loanTrackingCreateNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Extra details for this loan'**
  String get loanTrackingCreateNotesHint;

  /// No description provided for @loanTrackingCreateSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get loanTrackingCreateSubmitting;

  /// No description provided for @loanTrackingCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create Loan'**
  String get loanTrackingCreateAction;

  /// No description provided for @loanTrackingLoadingItems.
  ///
  /// In en, this message translates to:
  /// **'Loading items...'**
  String get loanTrackingLoadingItems;

  /// No description provided for @loanTrackingLoadItemsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load items: {error}'**
  String loanTrackingLoadItemsFailed(String error);

  /// No description provided for @loanTrackingBorrowerRequired.
  ///
  /// In en, this message translates to:
  /// **'Borrower name is required.'**
  String get loanTrackingBorrowerRequired;

  /// No description provided for @loanTrackingCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Loan created successfully.'**
  String get loanTrackingCreateSuccess;

  /// No description provided for @loanTrackingCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create loan: {error}'**
  String loanTrackingCreateFailed(String error);

  /// No description provided for @loanTrackingNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get loanTrackingNoDueDate;

  /// No description provided for @loanTrackingPickDateAction.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get loanTrackingPickDateAction;

  /// No description provided for @loanTrackingClearDateAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get loanTrackingClearDateAction;

  /// No description provided for @loanTrackingDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get loanTrackingDueDateLabel;

  /// No description provided for @authTitleAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authTitleAccount;

  /// No description provided for @authCreateAccountHeading.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountHeading;

  /// No description provided for @authSignInHeading.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInHeading;

  /// No description provided for @authCreateAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to sync your collections across devices.'**
  String get authCreateAccountDescription;

  /// No description provided for @authSignInDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to enable cloud sync and account features.'**
  String get authSignInDescription;

  /// No description provided for @authSignInChoice.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInChoice;

  /// No description provided for @authRegisterChoice.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterChoice;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authEmailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequiredError;

  /// No description provided for @authEmailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get authEmailInvalidError;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 chars, A-Z, a-z, 0-9'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequiredError;

  /// No description provided for @authPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authPasswordLengthError;

  /// No description provided for @authPasswordPolicyError.
  ///
  /// In en, this message translates to:
  /// **'Password must include uppercase, lowercase, and number.'**
  String get authPasswordPolicyError;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name (optional)'**
  String get authDisplayNameLabel;

  /// No description provided for @authDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we call you?'**
  String get authDisplayNameHint;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountAction;

  /// No description provided for @authNotNowAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get authNotNowAction;

  /// No description provided for @authUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication is currently unavailable.'**
  String get authUnavailableMessage;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created and signed in.'**
  String get authRegisterSuccess;

  /// No description provided for @authSignInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get authSignInSuccess;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String authSignInFailed(String error);

  /// No description provided for @authSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get authSignedOut;

  /// No description provided for @authFinalConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get authFinalConfirmationTitle;

  /// No description provided for @authFinalConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Submit account deletion request now? You will be signed out immediately from this device.'**
  String get authFinalConfirmationMessage;

  /// No description provided for @authBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBackAction;

  /// No description provided for @authSubmitRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get authSubmitRequestAction;

  /// No description provided for @authDeletionRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Account deletion request submitted. You have been signed out.'**
  String get authDeletionRequestSubmitted;

  /// No description provided for @authDeletionEndpointMissing.
  ///
  /// In en, this message translates to:
  /// **'Deletion request endpoint is not configured on backend yet.'**
  String get authDeletionEndpointMissing;

  /// No description provided for @authDeletionImpactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Before requesting account deletion'**
  String get authDeletionImpactDialogTitle;

  /// No description provided for @authDeletionImpactReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please review the impact carefully.'**
  String get authDeletionImpactReviewPrompt;

  /// No description provided for @authIrreversibleRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Irreversible request'**
  String get authIrreversibleRequestTitle;

  /// No description provided for @authImpactLineSessionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your account session is revoked immediately on request.'**
  String get authImpactLineSessionRevoked;

  /// No description provided for @authImpactLineCloudDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Synced cloud data linked to this account may be permanently deleted during processing.'**
  String get authImpactLineCloudDataDeleted;

  /// No description provided for @authImpactLineCannotRestore.
  ///
  /// In en, this message translates to:
  /// **'Deleted account data cannot be restored once processed.'**
  String get authImpactLineCannotRestore;

  /// No description provided for @authUnderstandAction.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get authUnderstandAction;

  /// No description provided for @authPasswordPolicySuffix.
  ///
  /// In en, this message translates to:
  /// **'Use English keyboard letters and digits (A-Z, a-z, 0-9).'**
  String get authPasswordPolicySuffix;

  /// No description provided for @authAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get authAccountConnected;

  /// No description provided for @authSignedInReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Signed in and ready for cloud sync'**
  String get authSignedInReadySubtitle;

  /// No description provided for @authActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authActiveStatus;

  /// No description provided for @authSessionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get authSessionDetailsTitle;

  /// No description provided for @authUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get authUserIdLabel;

  /// No description provided for @authDeviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get authDeviceIdLabel;

  /// No description provided for @authUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get authUnknownValue;

  /// No description provided for @authDeletionNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deletion notice'**
  String get authDeletionNoticeTitle;

  /// No description provided for @authDeletionNoticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion requests are irreversible once processed.'**
  String get authDeletionNoticeSubtitle;

  /// No description provided for @authDeletionNoticeLineProfileSessions.
  ///
  /// In en, this message translates to:
  /// **'Account profile and active sessions will be removed from cloud access.'**
  String get authDeletionNoticeLineProfileSessions;

  /// No description provided for @authDeletionNoticeLineSyncedData.
  ///
  /// In en, this message translates to:
  /// **'Synced collections, items, tags, and loans may be permanently deleted.'**
  String get authDeletionNoticeLineSyncedData;

  /// No description provided for @authRequestDeletionAction.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion'**
  String get authRequestDeletionAction;

  /// No description provided for @authSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOutAction;

  /// No description provided for @authDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get authDoneAction;

  /// No description provided for @authHeaderCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authHeaderCreateTitle;

  /// No description provided for @authHeaderWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authHeaderWelcomeTitle;

  /// No description provided for @authHeaderCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts are optional, but required for cloud sync and multi-device access.'**
  String get authHeaderCreateSubtitle;

  /// No description provided for @authHeaderSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access cloud sync and account-based features.'**
  String get authHeaderSignInSubtitle;

  /// No description provided for @authUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication unavailable'**
  String get authUnavailableTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'id', 'ja', 'ko', 'my', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'id': return AppLocalizationsId();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'my': return AppLocalizationsMy();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
