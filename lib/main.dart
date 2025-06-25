import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/theme_provider.dart';
import 'package:medassist_plus/app_theme.dart';
// import 'package:medassist_plus/screens/success_error_states.dart'; // Commented out as unused for now // New profile screen
import 'package:medassist_plus/screens/family_member_profile_screen.dart'; // New profile screen
// family_management_screen.dart is imported to access FamilyMember model for route arguments
import 'package:medassist_plus/models/family_member.dart';
import 'package:medassist_plus/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart'; // Import UserProfileProvider
import 'package:medassist_plus/providers/emergency_id_provider.dart';
import 'package:medassist_plus/providers/auth_provider.dart'; // new auth provider
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart'; // Import the actual HomeDashboard screen
import 'screens/profile_creation_screen.dart'; // Import the new ProfileCreationScreen
import 'screens/medical_summary_screen.dart'; // Import the new MedicalSummaryScreen
import 'screens/qr_nfc_screen.dart';
import 'screens/face_register_success.dart';
import 'screens/help_support_screen.dart';
import 'providers/app_lock_provider.dart';
import 'app_lock_gate.dart';
import 'screens/security_privacy_screen.dart';
import 'screens/medical_records_screen.dart';
import 'providers/medical_record_provider.dart';
import 'package:medassist_plus/screens/settings_screen.dart'; // Import the new SettingsScreen
import 'screens/emergency_access_screen.dart';
import 'screens/emergency_contacts_screen.dart'; // New screen for emergency contacts
import 'screens/family_management_screen.dart';
import 'screens/crash_detection_screen.dart';
import 'screens/face_scan_screen.dart'; // Import FaceScanScreen
import 'screens/fingerprint_scan_screen.dart'; // Import FingerprintScanScreen
import 'providers/emergency_access_settings_provider.dart';
import 'screens/emergency_access_settings_screen.dart';
// import 'background_service.dart'; // Disabled background service per user request
import 'screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initializeService() disabled; background service removed per user request

  // Load saved auth token (if any)
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('auth_token');

  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();
  final userProfileProvider =
      UserProfileProvider(); // Create UserProfileProvider instance

  // Preferences are loaded in the constructors of ThemeProvider and LanguageProvider.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(token: savedToken)),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(
          value: userProfileProvider,
        ), // Add UserProfileProvider
        ChangeNotifierProvider(create: (_) => AppLockProvider()..init()),
        ChangeNotifierProvider(create: (_) => EmergencyIdProvider()..init()),
        ChangeNotifierProvider(
          create: (_) => EmergencyAccessSettingsProvider(),
        ),
        // MedicalRecordProvider depends on AuthProvider for the JWT
        ChangeNotifierProxyProvider<AuthProvider, MedicalRecordProvider>(
          create: (_) => MedicalRecordProvider(),
          update: (_, auth, prev) {
            final prov = prev ?? MedicalRecordProvider();
            if (auth.token != null)
              prov.setAuthToken(auth.token!, silent: true);
            return prov;
          },
        ),
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
    print(
      '[MedAssistPlusApp build] Current appLocale from provider: ${languageProvider.appLocale.toLanguageTag()}',
    ); // Debug print

    return MaterialApp(
      title: 'MedAssist+',
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Localization settings
      locale: languageProvider.appLocale,
      supportedLocales:
          AppLocalizations.supportedLocales, // Use generated supported locales
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add our app-specific delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Temporarily disabled AppLockGate to skip fingerprint on app open
      // To re-enable, restore: home: const AppLockGate(child: SplashScreen()),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding':
            (context) =>
                OnboardingFlow(), // Uses OnboardingFlow class from onboarding_screen.dart
        '/login': (context) => LoginScreen(),
        '/home':
            (context) =>
                HomeDashboard(), // This should now point to the imported HomeDashboard
        '/profile':
            (context) => const ProfileCreationScreen(), // Use the new screen
        '/medical':
            (context) =>
                const MedicalSummaryScreen(), // Uses MedicalSummaryScreen from medical_summary_screen.dart
        '/qr':
            (context) =>
                const QrGeneratorScreen(), // Uses QrGeneratorScreen from qr_nfc_screen.dart
        '/records': (context) => const MedicalRecordsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/family-member-profile': (context) {
          final member =
              ModalRoute.of(context)!.settings.arguments as FamilyMember;
          return FamilyMemberProfileScreen(member: member);
        }, // Use the new screen
        '/emergency':
            (context) =>
                const EmergencyContactsScreen(), // New screen for managing emergency contacts
        '/emergency-access-settings':
            (context) =>
                const EmergencyAccessSettingsScreen(), // New screen for emergency access settings
        '/emergency-access':
            (context) =>
                EmergencyAccess(), // Doctor view / emergency data access screen
        '/family':
            (context) =>
                FamilyManagementScreen(), // Uses FamilyManagementScreen from screens/family_management_screen.dart
        '/crash':
            (context) =>
                CrashDetectionSettings(), // Uses CrashDetectionSettings from crash_detection_screen.dart
        // '/crash-detection': (context) => const CrashDetectionScreen(), // Old placeholder, can be removed or kept commented
        '/face-scan': (context) => const FaceScanScreen(),
        '/fingerprint-scan': (context) => const FingerprintScanScreen(),
        '/register': (context) => const RegisterScreen(),
        '/face-success': (context) => const FaceRegisterSuccessScreen(),
        '/success-error':
            (context) =>
                const SuccessErrorStatesScreen(), // Placeholder, implement as needed
        '/help-support': (context) => const HelpSupportScreen(),
        '/security-privacy': (context) => const SecurityPrivacyScreen(),
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
