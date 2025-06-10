import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageCodePrefKey = 'languageCode';
  static const String _countryCodePrefKey = 'countryCode';

  Locale _appLocale = const Locale('en'); // Default to English

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Locale get appLocale => _appLocale;

  List<Locale> get supportedLocales => const [
    Locale('en', ''), // English, no country code
    Locale('es', ''), // Spanish, no country code
    Locale('hi', ''), // Hindi, no country code
    Locale('fr', ''), // French, no country code
    Locale('de', ''), // German, no country code
    // Add other supported locales here
  ];

  Future<void> changeLanguage(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) return; // Only allow supported locales

    if (_appLocale == newLocale) return; // Don't do anything if locale is already set

    _appLocale = newLocale;
    print('[LanguageProvider] Changing language to: ${_appLocale.toLanguageTag()}'); // Debug print
    await _saveLanguagePreference(newLocale);
    notifyListeners();
    print('[LanguageProvider] Listeners notified.'); // Debug print
  }

  Future<void> _saveLanguagePreference(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodePrefKey, locale.languageCode);
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      await prefs.setString(_countryCodePrefKey, locale.countryCode!);
    } else {
      await prefs.remove(_countryCodePrefKey); // Remove if no country code
    }
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodePrefKey);
    final countryCode = prefs.getString(_countryCodePrefKey);

    if (languageCode != null) {
      _appLocale = Locale(languageCode, countryCode);
    } else {
      _appLocale = const Locale('en'); // Default to English if nothing saved
    }
    // No need to check against supportedLocales here, changeLanguage does that.
    // We simply load what was saved or default.
    notifyListeners(); // Notify listeners after loading the language
  }
}
