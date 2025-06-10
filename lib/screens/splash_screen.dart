import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Lottie import removed as it's currently unused
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; // For MDI Icons

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // _isLoading is no longer used

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // setState(() {}); // No state needs to be changed here before navigation
      if (mounted) { // Check if the widget is still in the tree
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Option 1: Lottie Animation (if you have one)
              // Lottie.asset(
              //   'assets/animations/splash_animation.json', // Replace with your animation file
              //   width: 200,
              //   height: 200,
              //   repeat: true, // Or false if it's a one-shot animation
              // ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),

              // Option 2: Image Logo (if you have one)
              // Image.asset(
              //   'assets/images/medassist_logo.png', // Replace with your logo file
              //   width: 150,
              //   height: 150,
              // ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),

              // Option 3: Placeholder Icon Logo (if no image/Lottie yet)
              Icon(
                MdiIcons.heartPulse, // Example: A relevant icon
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms).then(delay: 200.ms).shimmer(duration: 1200.ms, color: Theme.of(context).colorScheme.secondary),

              const SizedBox(height: 24),
              Text(
                'MedAssist+',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slide(begin: const Offset(0, 0.2), end: Offset.zero),
              const SizedBox(height: 12),
              Text(
                'Your Health, One Scan Away',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Medium weight
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slide(begin: const Offset(0, 0.3), end: Offset.zero),
            ],
          ),
        ),
      ),
    );
  }
}

