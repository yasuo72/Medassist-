import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/theme_provider.dart';
// import 'package:medassist_plus/screens/success_error_states.dart'; // Commented out as unused for now // New profile screen
import 'package:medassist_plus/screens/family_member_profile_screen.dart'; // New profile screen
// family_management_screen.dart is imported to access FamilyMember model for route arguments
import 'package:medassist_plus/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart'; // Import UserProfileProvider
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart'; // Import the actual HomeDashboard screen
import 'screens/profile_creation_screen.dart'; // Import the new ProfileCreationScreen
import 'screens/medical_summary_screen.dart'; // Import the new MedicalSummaryScreen
import 'screens/qr_nfc_screen.dart'; // Import the new QrGeneratorScreen
import 'package:medassist_plus/screens/settings_screen.dart'; // Import the new SettingsScreen
import 'screens/emergency_access_screen.dart';
import 'screens/emergency_contacts_screen.dart'; // New screen for emergency contacts
import 'screens/family_management_screen.dart';
import 'screens/crash_detection_screen.dart';
import 'screens/face_scan_screen.dart'; // Import FaceScanScreen
import 'screens/fingerprint_scan_screen.dart'; // Import FingerprintScanScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();
  final userProfileProvider = UserProfileProvider(); // Create UserProfileProvider instance

  // Preferences are loaded in the constructors of ThemeProvider and LanguageProvider.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: userProfileProvider), // Add UserProfileProvider
      ],
      child: const MedAssistPlusApp(),
    ),
  );
}

class MedAssistPlusApp extends StatelessWidget {
  const MedAssistPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    print('[MedAssistPlusApp build] Current appLocale from provider: ${languageProvider.appLocale.toLanguageTag()}'); // Debug print

    return MaterialApp(
      title: 'MedAssist+',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // A modern, trustworthy blue (Apple Blue as an example)
          // You can further customize if needed:
          // primary: const Color(0xFF007AFF),
          // secondary: const Color(0xFF5856D6), // A complementary purple or another accent
          // surface: const Color(0xFFF2F2F7),
          // background: const Color(0xFFFFFFFF),
          // error: const Color(0xFFFF3B30),
          brightness: Brightness.light, // For light theme
        ),
        useMaterial3: true,
        fontFamily: 'Poppins', // Set Poppins as the default font
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF007AFF), // Match with seedColor or primary
          foregroundColor: Colors.white, // For title and icons
          elevation: 2,
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600, // SemiBold for AppBar titles
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color(0xFF007AFF), // Example: Use primary color for buttons
            // foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // You can add more theme customizations here (e.g., cardTheme, inputDecorationTheme)
      ),
      // Localization settings
      locale: languageProvider.appLocale,
      supportedLocales: AppLocalizations.supportedLocales, // Use generated supported locales
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add our app-specific delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.dark,
          // Consider adjusting dark theme specific colors if needed
          // primary: const Color(0xFF0A84FF), // Slightly brighter blue for dark mode
          // secondary: const Color(0xFF64D2FF),
          // surface: const Color(0xFF1C1C1E),
          // background: const Color(0xFF000000),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1C1C1E), // Darker AppBar for dark mode
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Add other dark theme specific customizations
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingFlow(), // Uses OnboardingFlow class from onboarding_screen.dart
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeDashboard(), // This should now point to the imported HomeDashboard
        '/profile': (context) => const ProfileCreationScreen(), // Use the new screen
        '/medical': (context) => const MedicalSummaryScreen(), // Uses MedicalSummaryScreen from medical_summary_screen.dart
        '/qr': (context) => const QrGeneratorScreen(), // Uses QrGeneratorScreen from qr_nfc_screen.dart
        '/settings': (context) => const SettingsScreen(),
        '/family-member-profile': (context) {
          final member = ModalRoute.of(context)!.settings.arguments as FamilyMember;
          return FamilyMemberProfileScreen(member: member);
        }, // Use the new screen
        '/emergency': (context) => const EmergencyContactsScreen(), // New screen for managing emergency contacts
        '/emergency-access': (context) => EmergencyAccess(), // Doctor view / emergency data access screen
        '/family': (context) => FamilyManagementScreen(), // Uses FamilyManagementScreen from screens/family_management_screen.dart
        '/crash': (context) => CrashDetectionSettings(), // Uses CrashDetectionSettings from crash_detection_screen.dart
        // '/crash-detection': (context) => const CrashDetectionScreen(), // Old placeholder, can be removed or kept commented
        '/face-scan': (context) => const FaceScanScreen(),
        '/fingerprint-scan': (context) => const FingerprintScanScreen(),
        // '/success-error': (context) => const SuccessErrorStatesScreen(), // Placeholder, implement as needed
      },
    );
  }
}

// Placeholder ProfileCreation class removed as it's replaced by ProfileCreationScreen

// Placeholder MedicalSummary class removed as it's replaced by MedicalSummaryScreen

// Placeholder QRGenerator class removed as it's replaced by QrGeneratorScreen

// Placeholder SettingsScreen class removed as it's replaced by the new SettingsScreen

// Original EmergencyAccess placeholder class removed as functionality is now imported
// from screens/emergency_access_screen.dart.

// Original CrashDetection placeholder class removed as functionality is now imported
// from screens/crash_detection_screen.dart (which contains CrashDetectionSettings).

class SuccessErrorStatesScreen extends StatelessWidget {
  const SuccessErrorStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: const Center(child: Text('Success/Error Screen Placeholder')),
    );
  }
}

// Placeholder widgets for each screen
