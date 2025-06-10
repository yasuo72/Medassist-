import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/theme_provider.dart';
import 'package:medassist_plus/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Placeholder for theme service/provider
// class ThemeProvider extends ChangeNotifier { ... }
// class AppLocalizations { ... } // For localization

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _toggleTheme(bool value) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
    // The SnackBar can be removed or updated if you prefer direct visual feedback from the theme change
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Dark mode ${value ? "enabled" : "disabled"}')),
    // );
  }

  void _changeLanguage(String? languageCode) {
    if (languageCode != null) {
      Provider.of<LanguageProvider>(context, listen: false).changeLanguage(Locale(languageCode));
      // SnackBar for feedback (optional)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Language changed to $languageCode')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSectionTitle(theme, loc.appearanceSectionTitle),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: Text(loc.darkMode, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins')),
              subtitle: Text(loc.darkModeSubtitle, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Poppins')),
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: _toggleTheme,
              secondary: Icon(MdiIcons.themeLightDark, color: theme.colorScheme.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, loc.languageRegionSectionTitle),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: loc.appLanguageDropdownTitle,
                  labelStyle: TextStyle(fontFamily: 'Poppins', color: theme.colorScheme.primary),
                  border: InputBorder.none, // Remove border to blend with card
                  prefixIcon: Icon(MdiIcons.translate, color: theme.colorScheme.primary),
                ),
                value: languageProvider.appLocale.languageCode,
                icon: Icon(MdiIcons.chevronDown, color: theme.colorScheme.secondary),
                style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins'),
                dropdownColor: theme.cardColor,
                items: languageProvider.supportedLocales.map((locale) {
                  // For user-friendly names, you'd typically have a map or a method
                  // to get the display name for a locale. For now, using language code.
                  String displayName = locale.languageCode;
                  if (locale.languageCode == 'en') displayName = 'English';
                  if (locale.languageCode == 'es') displayName = 'Español';
                  if (locale.languageCode == 'fr') displayName = 'Français';
                  if (locale.languageCode == 'de') displayName = 'Deutsch';
                  if (locale.languageCode == 'hi') displayName = 'हिन्दी';
                  return DropdownMenuItem<String>(
                    value: locale.languageCode,
                    child: Text(displayName, style: const TextStyle(fontFamily: 'Poppins')),
                  );
                }).toList(),
                onChanged: _changeLanguage,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Account'),
          _buildSettingsTile(
            theme,
            icon: MdiIcons.accountEditOutline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _buildSettingsTile(
            theme,
            icon: MdiIcons.shieldLockOutline,
            title: 'Security & Privacy',
            subtitle: 'Manage login methods and data sharing',
            onTap: () { /* TODO: Navigate to Security/Privacy Screen */ },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'About'),
          _buildSettingsTile(
            theme,
            icon: MdiIcons.informationOutline,
            title: 'About MedAssist+',
            subtitle: 'Version 1.0.0 (Build 1)', // Placeholder version
            onTap: () { /* TODO: Show About Dialog or Screen */ },
          ),
          _buildSettingsTile(
            theme,
            icon: MdiIcons.helpCircleOutline,
            title: 'Help & Support',
            onTap: () { /* TODO: Navigate to Help/Support Screen or URL */ },
          ),
          _buildSettingsTile(
            theme,
            icon: MdiIcons.logout,
            title: 'Logout',
            titleColor: theme.colorScheme.error,
            iconColor: theme.colorScheme.error,
            onTap: () {
              // TODO: Implement logout logic
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully (Simulated)')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(ThemeData theme, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap, Color? titleColor, Color? iconColor}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.secondary, size: 28),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Poppins')) : null,
        trailing: onTap != null ? Icon(MdiIcons.chevronRight, color: theme.colorScheme.onSurfaceVariant) : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
