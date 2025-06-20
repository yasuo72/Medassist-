import 'package:flutter/material.dart';

/// Centralised theme definitions inspired by the provided Figma reference
/// (dark, glass-like cards, strong blue accents, rounded corners).
class AppTheme {
  AppTheme._();

  // Core brand colours
  static const Color _brandBlue = Color(0xFF1E6CFF); // slightly softer than #007AFF
  static const Color _backgroundDark = Color(0xFF0D1117);
  static const Color _cardDark = Color(0xFF161B22);

  /// Light scheme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _brandBlue,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(seedColor: _brandBlue),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _brandBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
    ),
  );

  /// Dark scheme resembling the neo-glass look of the bikes UI.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _brandBlue,
    scaffoldBackgroundColor: _backgroundDark,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(seedColor: _brandBlue, brightness: Brightness.dark),
    cardTheme: CardTheme(
      color: _cardDark.withOpacity(0.8),
      elevation: 6,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _brandBlue,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: _cardDark,
      elevation: 8,
    ),
  );
}
