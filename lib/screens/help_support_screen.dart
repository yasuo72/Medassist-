import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Frequently Asked Questions',
              style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const _FaqTile(
            question: 'How do I create my Emergency ID?',
            answer:
                'Navigate to Settings > Configure Emergency ID, enter your desired ID and current password to save.',
          ),
          const _FaqTile(
            question: 'QR code is not scanning. What can I do?',
            answer:
                'Ensure the entire QR code is visible and well-lit. If problems persist, increase the code size or clean your camera lens.',
          ),
          const _FaqTile(
            question: 'How do I update my medical information?',
            answer:
                'Open Profile, edit the fields you want, then tap Save. The changes are immediately synced to the cloud.',
          ),
          const _FaqTile(
            question: 'Is my data secure?',
            answer:
                'Yes. MedAssist+ encrypts all sensitive data in transit (TLS) and at rest. Emergency IDs are protected by your password.',
          ),
          const SizedBox(height: 24),
          Text('Contact Us', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@medassist.app'),
                  onTap: () => _launchUrl('mailto:support@medassist.app?subject=Support%20Request'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.phone_in_talk_outlined),
                  title: const Text('Call Hotline'),
                  subtitle: const Text('+1 (555) 010-1234'),
                  onTap: () => _launchUrl('tel:+15550101234'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Visit Knowledge Base'),
                  subtitle: const Text('help.medassist.app'),
                  onTap: () => _launchUrl('https://help.medassist.app'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('App Version: 1.0.0', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Text('Build: 42', style: theme.textTheme.bodySmall),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontFamily: 'Poppins')),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [Text(answer, style: const TextStyle(fontFamily: 'Poppins'))],
      ),
    );
  }
}
