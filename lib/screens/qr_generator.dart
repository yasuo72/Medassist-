import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Placeholder for QR code generation
import 'package:flutter_animate/flutter_animate.dart'; // For animations

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  // Placeholder data for the QR code - in a real app, this would be dynamic user data
  final String _qrData = "medassistplus://user?id=12345&name=Rohit&emergency_contact=9876543210";
  bool _showNfcOptions = false;

  void _writeToNfcTag() {
    // TODO: Implement NFC writing functionality (e.g., using nfc_manager package)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NFC Tag writing initiated (Simulated)...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency QR & NFC', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Emergency Medical ID',
              style: theme.textTheme.headlineSmall?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Present this QR code or use an NFC-enabled device in case of an emergency for quick access to your vital medical information.',
              style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Center(
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 250.0,
                gapless: false,
                embeddedImage: const AssetImage('assets/images/medassist_logo_small.png'), // Optional: Add your app logo
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(50, 50),
                ),
                errorStateBuilder: (cxt, err) {
                  return const Center(
                    child: Text(
                      'Uh oh! Something went wrong generating the QR code.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .shimmer(delay: 400.ms, duration: 1800.ms, color: theme.colorScheme.primary.withOpacity(0.3)), // Shimmer animation
            ),
            const SizedBox(height: 24),
            Text(
              'Scan this code with any QR scanner.',
              style: theme.textTheme.labelLarge?.copyWith(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 32),
            Divider(thickness: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(MdiIcons.nfcVariant, size: 30, color: theme.colorScheme.secondary),
              title: Text('NFC Tag Options', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              trailing: Switch(
                value: _showNfcOptions,
                onChanged: (value) {
                  setState(() {
                    _showNfcOptions = value;
                  });
                },
              ),
            ),
            if (_showNfcOptions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Tap an NFC tag to your device to write your emergency ID. Ensure NFC is enabled on your device.',
                      style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(MdiIcons.cellphoneNfc),
                      label: const Text('Write to NFC Tag'),
                      onPressed: _writeToNfcTag,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ).animate().fadeIn(), 
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: Icon(MdiIcons.shieldLockOutline, color: theme.colorScheme.error),
              label: Text('Emergency Access Settings', style: TextStyle(color: theme.colorScheme.error, fontFamily: 'Poppins')),
              onPressed: () {
                // TODO: Navigate to a screen to configure what data is shared via QR/NFC
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to Emergency Access Settings (Not Implemented)')),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
