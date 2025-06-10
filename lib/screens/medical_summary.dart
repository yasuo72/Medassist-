import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MedicalSummaryScreen extends StatefulWidget {
  const MedicalSummaryScreen({super.key});

  @override
  State<MedicalSummaryScreen> createState() => _MedicalSummaryScreenState();
}

class _MedicalSummaryScreenState extends State<MedicalSummaryScreen> {
  // Placeholder data - this would come from a database or state management
  final String _aiSummary = "Rohit appears to be generally healthy but should monitor blood pressure. Recent reports show slightly elevated cholesterol levels. Key conditions include mild Asthma. Current medications: Albuterol Inhaler (as needed). Allergies: Penicillin.";
  final List<Map<String, dynamic>> _conditions = [
    {'name': 'Mild Asthma', 'severity': 'Mild', 'icon': MdiIcons.lungs, 'color': Colors.blue},
    {'name': 'Hypertension (Monitor)', 'severity': 'Pre-Hypertension', 'icon': MdiIcons.heartPulse, 'color': Colors.orange},
  ];
  final List<Map<String, dynamic>> _medications = [
    {'name': 'Albuterol Inhaler', 'dosage': 'As needed for Asthma', 'icon': MdiIcons.medication}, // Changed from MdiIcons.inhaler
    {'name': 'Lisinopril (Trial)', 'dosage': '5mg daily (Monitor BP)', 'icon': MdiIcons.pill},
  ];
  final List<Map<String, dynamic>> _riskAlerts = [
    {'alert': 'Elevated Cholesterol', 'details': 'LDL: 140 mg/dL. Recommend dietary changes and follow-up.', 'icon': MdiIcons.alertOctagonOutline, 'color': Colors.redAccent},
    {'alert': 'Sedentary Lifestyle Risk', 'details': 'Advise regular physical activity.', 'icon': MdiIcons.seatOutline, 'color': Colors.amber},
  ];

  void _exportSummary() {
    // TODO: Implement PDF generation and sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting summary (Simulated)...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Summary', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.shareVariantOutline),
            onPressed: _exportSummary,
            tooltip: 'Export/Share Summary',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSectionCard(
              theme,
              title: 'AI-Generated Health Insights',
              icon: MdiIcons.brain,
              iconColor: theme.colorScheme.primary,
              content: Text(
                _aiSummary,
                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            _buildTitledSection(
              theme,
              title: 'Key Conditions',
              icon: MdiIcons.clipboardPulseOutline,
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                final condition = _conditions[index];
                return _buildInfoTile(
                  theme,
                  icon: condition['icon'],
                  iconColor: condition['color'],
                  title: condition['name'],
                  subtitle: condition['severity'],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildTitledSection(
              theme,
              title: 'Current Medications',
              icon: MdiIcons.pillMultiple,
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final medication = _medications[index];
                return _buildInfoTile(
                  theme,
                  icon: medication['icon'],
                  iconColor: theme.colorScheme.tertiary, // Example color
                  title: medication['name'],
                  subtitle: medication['dosage'],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildTitledSection(
              theme,
              title: 'Risk Alerts & Recommendations',
              icon: MdiIcons.alertOutline,
              itemCount: _riskAlerts.length,
              itemBuilder: (context, index) {
                final alert = _riskAlerts[index];
                return _buildInfoTile(
                  theme,
                  icon: alert['icon'],
                  iconColor: alert['color'],
                  title: alert['alert'],
                  subtitle: alert['details'],
                  isAlert: true,
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(MdiIcons.fileEditOutline),
              label: const Text('Request AI Re-Summary'),
              onPressed: () {
                // TODO: Implement AI re-summary logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Re-Summary Requested (Simulated)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, {required String title, required IconData icon, Color? iconColor, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: iconColor ?? theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTitledSection(ThemeData theme, {required String title, required IconData icon, required int itemCount, required IndexedWidgetBuilder itemBuilder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (itemCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No information available.', style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
      ],
    );
  }

  Widget _buildInfoTile(ThemeData theme, {required IconData icon, Color? iconColor, required String title, required String subtitle, bool isAlert = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (iconColor ?? theme.colorScheme.primary).withOpacity(isAlert ? 0.2 : 0.1),
        child: Icon(icon, size: 22, color: iconColor ?? theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: isAlert ? iconColor : null)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Poppins', color: theme.colorScheme.onSurfaceVariant)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    );
  }
}
