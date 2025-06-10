import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // For a more accurate check when ThemeMode.system is active,
      // you'd typically check platform brightness.
      // For simplicity in this provider, if the mode is system,
      // we'll consider it not explicitly dark unless the user has set it to dark.
      return false; 
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  // Optional: Method to set theme explicitly, e.g., from stored preference
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Store ThemeMode as a string (e.g., 'system', 'light', 'dark')
    // Or as an int (e.g., ThemeMode.values.indexOf(_themeMode))
    await prefs.setInt(_themePrefKey, _themeMode.index); // Storing index is simpler
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.system; // Default if nothing saved or invalid
    }
    notifyListeners(); // Notify listeners after loading the theme
  }
}
