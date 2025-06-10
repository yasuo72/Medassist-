import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:local_auth/local_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // For pulse animation

class FingerprintScanScreen extends StatefulWidget {
  const FingerprintScanScreen({super.key});

  @override
  State<FingerprintScanScreen> createState() => _FingerprintScanScreenState();
}

class _FingerprintScanScreenState extends State<FingerprintScanScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  String _statusText = "Place your finger on the scanner to proceed";
  bool _isScanning = false;
  bool _scanCompleted = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      debugPrint('Error checking biometrics: ${e.message}');
      if (!mounted) return;
      setState(() {
        _statusText = "Error: ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    if (!canCheckBiometrics) {
      setState(() {
        _statusText = "Biometrics not available on this device.";
      });
      return;
    }
    // Optionally, you can check for specific biometric types like fingerprint
    // List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
    // if (!mounted) return;
    // if (availableBiometrics.isEmpty || !availableBiometrics.contains(BiometricType.fingerprint)) {
    //   setState(() {
    //     _statusText = "Fingerprint biometric not available or not configured.";
    //   });
    // }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanCompleted = false;
      _statusText = "Reading fingerprint...";
    });

    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep dialog open until success or explicit cancel
          biometricOnly: true, // Only allow biometrics, no device PIN/Pattern
        ),
      );
    } on PlatformException catch (e) {
      print(e); // Log platform errors
      setState(() {
        _statusText = "Error during authentication: ${e.message}";
        _isScanning = false;
        _scanCompleted = true;
        _verified = false;
      });
      return;
    }
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _scanCompleted = true;
      _verified = authenticated;
      _statusText = authenticated ? "✅ Verified – Medical Profile Unlocked" : "❌ Authentication Failed";
    });

    if (authenticated) {
      HapticFeedback.lightImpact(); // Success feedback
      // Set enrollment status in provider
      try {
        await Provider.of<UserProfileProvider>(context, listen: false).setFingerprintEnrolled(true);
      } catch (e) {
        // Handle potential errors if provider is not found, though unlikely here
        debugPrint('Error updating fingerprint enrollment: $e');
        // Optionally show a message to the user
      }
      // Pop with true to indicate success
      if (Navigator.canPop(context)) Navigator.pop(context, true);
      
    } else {
      HapticFeedback.heavyImpact(); // Failure feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch to Scan Fingerprint'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.helpCircleOutline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Fingerprint Scan Help'),
                  content: const Text('Use any finger that you have registered with your device\'s biometric security. Your fingerprint data is managed by your device\'s secure enclave and is not directly accessed by this app.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // TODO: Add pulsing animation to this icon using flutter_animate
            Icon(
              MdiIcons.fingerprint,
              size: 120,
              color: _scanCompleted 
                  ? (_verified ? Colors.greenAccent : Colors.redAccent) 
                  : (_isScanning ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 30),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 50),
            if (!_isScanning && !_scanCompleted)
              ElevatedButton.icon(
                icon: Icon(MdiIcons.fingerprint),
                label: const Text('Scan Fingerprint'),
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            if (_scanCompleted && !_verified)
              ElevatedButton.icon(
                icon: Icon(MdiIcons.refresh),
                label: const Text('Try Again'),
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('Use Face Scan Instead'),
              onPressed: () {
                // Navigate to Face Scan screen, replacing current route if appropriate
                // or just pushing if part of a setup flow
                Navigator.pushReplacementNamed(context, '/face-scan');
              },
            ),
            TextButton(
              child: const Text('Switch to QR/NFC Access'),
              onPressed: () {
                // Navigate to QR/NFC screen
                Navigator.pushNamed(context, '/qr'); // Assuming '/qr' is your QR/NFC route
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.shieldCheckOutline, size: 16, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 8),
                  Text(
                    'Biometric data encrypted and device-local only',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
