import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/crash_detection_service.dart';

class CrashDetectionSettings extends StatefulWidget {
  const CrashDetectionSettings({Key? key}) : super(key: key);

  @override
  State<CrashDetectionSettings> createState() => _CrashDetectionSettingsState();
}

class _CrashDetectionSettingsState extends State<CrashDetectionSettings> {
  bool _enabled = false;
  final _prefsFuture = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await _prefsFuture;
    setState(() => _enabled = prefs.getBool('crash_detection_enabled') ?? false);
    if (_enabled) {
      CrashDetectionService().start(context: context);
    }
  }

  Future<void> _toggle(bool value) async {
    final prefs = await _prefsFuture;
    await prefs.setBool('crash_detection_enabled', value);
    setState(() => _enabled = value);
    if (value) {
      CrashDetectionService().start(context: context);
    } else {
      CrashDetectionService().stop();
    }
  }

  Future<void> _testCrash() async {
    await CrashDetectionService().simulateCrash();
  }

  Future<void> _addNumber() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Primary Emergency Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+1 123 456 7890'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await _prefsFuture;
              await prefs.setString('primary_emergency_number', controller.text);
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crash Detection Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable Crash & Fall Detection'),
            value: _enabled,
            onChanged: _toggle,
          ),
          ListTile(
            title: const Text('Test Crash Trigger'),
            trailing: ElevatedButton(
              onPressed: _testCrash,
              child: const Text('Test'),
            ),
          ),
          ListTile(
            title: const Text('Set Primary Emergency Number'),
            trailing: ElevatedButton(
              onPressed: _addNumber,
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }
}



