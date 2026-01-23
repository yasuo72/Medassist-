import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('hi'),
  ];

  /// Title for the Settings Screen AppBar
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @languageRegionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get languageRegionSectionTitle;

  /// No description provided for @appLanguageDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageDropdownTitle;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'MedAssist+'**
  String get homeAppBarTitle;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// Greeting message on the home screen
  ///
  /// In en, this message translates to:
  /// **'Hi, {userName} 👋'**
  String homeGreeting(String userName);

  /// No description provided for @homeSectionTitleKeyStats.
  ///
  /// In en, this message translates to:
  /// **'Your Key Stats'**
  String get homeSectionTitleKeyStats;

  /// No description provided for @statLabelBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get statLabelBloodType;

  /// No description provided for @statLabelAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get statLabelAllergies;

  /// No description provided for @statLabelMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get statLabelMedication;

  /// No description provided for @statLabelConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get statLabelConditions;

  /// No description provided for @homeSectionTitleQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeSectionTitleQuickActions;

  /// No description provided for @actionLabelMedicalSummary.
  ///
  /// In en, this message translates to:
  /// **'Medical Summary'**
  String get actionLabelMedicalSummary;

  /// No description provided for @actionLabelFamilyManagement.
  ///
  /// In en, this message translates to:
  /// **'Family Management'**
  String get actionLabelFamilyManagement;

  /// No description provided for @actionLabelEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get actionLabelEmergencyContacts;

  /// No description provided for @actionLabelAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get actionLabelAppSettings;

  /// No description provided for @homeFabLabelEmergencyId.
  ///
  /// In en, this message translates to:
  /// **'Emergency ID'**
  String get homeFabLabelEmergencyId;

  /// Snackbar message shown after profile is successfully updated
  ///
  /// In en, this message translates to:
  /// **'Profile Updated!'**
  String get profileUpdated;

  /// Generic placeholder for a value that has not been set by the user
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// Snackbar message for features that are not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Feature Coming Soon!'**
  String get featureComingSoon;

  /// Label for the medical reports statistic on the home dashboard
  ///
  /// In en, this message translates to:
  /// **'Medical Reports'**
  String get statLabelMedicalReports;

  /// Suffix for the number of files, e.g., '3 files'
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get filesSuffix;
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
      <String>['en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
