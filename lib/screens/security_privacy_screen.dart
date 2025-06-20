import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_lock_provider.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  void _launch(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lockProv = context.watch<AppLockProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Security & Privacy', style: TextStyle(fontFamily: 'Poppins'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile.adaptive(
              value: lockProv.enabled,
              title: const Text('Require fingerprint on app open', style: TextStyle(fontFamily: 'Poppins')),
              subtitle: Text(lockProv.enabled ? 'Enabled' : 'Disabled', style: const TextStyle(fontFamily: 'Poppins')),
              onChanged: (v) async {
                final granted = v ? await lockProv.authenticate() : true;
                if (granted) await lockProv.toggle(v);
              },
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Emergency-ID Password', style: TextStyle(fontFamily: 'Poppins')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/settings'), // reuse existing flow
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy', style: TextStyle(fontFamily: 'Poppins')),
            onTap: () => _launch('https://medassist.app/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service', style: TextStyle(fontFamily: 'Poppins')),
            onTap: () => _launch('https://medassist.app/terms'),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('App Version 1.0.0', style: theme.textTheme.bodySmall),
          )
        ],
      ),
    );
  }
}
