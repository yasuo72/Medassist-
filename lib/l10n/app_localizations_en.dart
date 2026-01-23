// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Enable or disable dark theme';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get languageRegionSectionTitle => 'Language & Region';

  @override
  String get appLanguageDropdownTitle => 'App Language';

  @override
  String get homeAppBarTitle => 'MedAssist+';

  @override
  String get profileTooltip => 'Profile';

  @override
  String homeGreeting(String userName) {
    return 'Hi, $userName 👋';
  }

  @override
  String get homeSectionTitleKeyStats => 'Your Key Stats';

  @override
  String get statLabelBloodType => 'Blood Type';

  @override
  String get statLabelAllergies => 'Allergies';

  @override
  String get statLabelMedication => 'Medication';

  @override
  String get statLabelConditions => 'Conditions';

  @override
  String get homeSectionTitleQuickActions => 'Quick Actions';

  @override
  String get actionLabelMedicalSummary => 'Medical Summary';

  @override
  String get actionLabelFamilyManagement => 'Family Management';

  @override
  String get actionLabelEmergencyContacts => 'Emergency Contacts';

  @override
  String get actionLabelAppSettings => 'App Settings';

  @override
  String get homeFabLabelEmergencyId => 'Emergency ID';

  @override
  String get profileUpdated => 'Profile Updated!';

  @override
  String get notSet => 'Not Set';

  @override
  String get featureComingSoon => 'Feature Coming Soon!';

  @override
  String get statLabelMedicalReports => 'Medical Reports';

  @override
  String get filesSuffix => 'files';
}
