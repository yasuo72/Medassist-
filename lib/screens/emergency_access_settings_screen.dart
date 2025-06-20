import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_access_settings_provider.dart';

class EmergencyAccessSettingsScreen extends StatelessWidget {
  const EmergencyAccessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<EmergencyAccessSettingsProvider>(context);
    final theme = Theme.of(context);

    Widget buildSwitch({required String title, required bool value, required void Function(bool) onChanged, required IconData icon}) {
      return SwitchListTile(
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins')),
        secondary: Icon(icon, color: theme.colorScheme.primary),
        value: value,
        onChanged: onChanged,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Access Settings', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: ListView(
        children: [
          buildSwitch(
            title: 'Basic Info (ID, Blood Group)',
            value: settings.includeBasicInfo,
            onChanged: settings.toggleBasicInfo,
            icon: MdiIcons.cardAccountDetailsStar,
          ),
          buildSwitch(
            title: 'Allergies',
            value: settings.includeAllergies,
            onChanged: settings.toggleAllergies,
            icon: MdiIcons.alertRhombusOutline,
          ),
          buildSwitch(
            title: 'Conditions',
            value: settings.includeConditions,
            onChanged: settings.toggleConditions,
            icon: MdiIcons.heartPulse,
          ),
          buildSwitch(
            title: 'Medications',
            value: settings.includeMedications,
            onChanged: settings.toggleMedications,
            icon: MdiIcons.pill,
          ),
          buildSwitch(
            title: 'Emergency Contacts',
            value: settings.includeContacts,
            onChanged: settings.toggleContacts,
            icon: MdiIcons.accountMultiple,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
              },
              icon: const Icon(Icons.save),
              label: const Text('Save & Regenerate QR'),
            ),
          ),
        ],
      ),
    );
  }
}
