// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get darkModeSubtitle => 'डार्क थीम सक्षम या अक्षम करें';

  @override
  String get appearanceSectionTitle => 'दिखावट';

  @override
  String get languageRegionSectionTitle => 'भाषा और क्षेत्र';

  @override
  String get appLanguageDropdownTitle => 'ऐप की भाषा';

  @override
  String get homeAppBarTitle => 'मेडअसिस्ट+';

  @override
  String get profileTooltip => 'प्रोफ़ाइल';

  @override
  String homeGreeting(String userName) {
    return 'नमस्ते, $userName 👋';
  }

  @override
  String get homeSectionTitleKeyStats => 'आपके प्रमुख आँकड़े';

  @override
  String get statLabelBloodType => 'रक्त प्रकार';

  @override
  String get statLabelAllergies => 'एलर्जी';

  @override
  String get statLabelMedication => 'दवा';

  @override
  String get statLabelConditions => 'स्वास्थ्य स्थितियाँ';

  @override
  String get homeSectionTitleQuickActions => 'त्वरित कार्रवाइयां';

  @override
  String get actionLabelMedicalSummary => 'चिकित्सा सारांश';

  @override
  String get actionLabelFamilyManagement => 'परिवार प्रबंधन';

  @override
  String get actionLabelEmergencyContacts => 'आपातकालीन संपर्क';

  @override
  String get actionLabelAppSettings => 'ऐप सेटिंग्स';

  @override
  String get homeFabLabelEmergencyId => 'आपातकालीन आईडी';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई!';

  @override
  String get notSet => 'निर्धारित नहीं है';

  @override
  String get featureComingSoon => 'सुविधा जल्द ही आ रही है!';

  @override
  String get statLabelMedicalReports => 'चिकित्सा रिपोर्ट';

  @override
  String get filesSuffix => 'फ़ाइलें';
}
