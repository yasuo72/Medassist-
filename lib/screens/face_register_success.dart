import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FaceRegisterSuccessScreen extends StatelessWidget {
  const FaceRegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated success icon
              Icon(MdiIcons.checkCircleOutline,
                      size: 140, color: colorScheme.primary)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .then()
                  .shake(duration: 300.ms, hz: 4),
              const SizedBox(height: 24),
              Text(
                'Face Registered!',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Your biometric profile has been securely saved. You're all set!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // or navigate to home/profile as needed
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Dashboard'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
