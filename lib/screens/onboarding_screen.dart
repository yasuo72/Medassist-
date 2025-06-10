import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OnboardingFlow extends StatefulWidget {
  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _current = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      imagePath: 'assets/images/onboarding_face_fingerprint.png', // Placeholder - ensure this image exists or use an icon
      icon: MdiIcons.faceRecognition, // Fallback icon
      title: 'Secure Registration',
      desc: 'Register your face & fingerprint securely for quick access.',
    ),
    _SlideData(
      imagePath: 'assets/images/onboarding_ai_summary.png', // Placeholder
      icon: MdiIcons.fileChartOutline, // Fallback icon
      title: 'AI Health Summary',
      desc: 'Upload reports, let AI summarize your health insights.',
    ),
    _SlideData(
      imagePath: 'assets/images/onboarding_qr_nfc.png', // Placeholder
      icon: MdiIcons.qrcodeScan, // Fallback icon
      title: 'Instant Emergency Access',
      desc: 'Generate QR/NFC for your vital medical information.',
    ),
  ];

  // Ensure you have these images in assets/images/ or use appropriate MDI Icons.
  // For example, if you don't have images yet:
  // const _SlideData(icon: MdiIcons.faceRecognition, title: 'Secure Registration', desc: '...'),

  void _next() {
    if (_current < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _prev() {
    if (_current > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (_, i) => _buildSlide(_slides[i], context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Consistent rounded corners
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: _current == 0 ? Colors.grey : colorScheme.primary,
                    onPressed: _current == 0 ? null : _prev,
                  ),
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.primary.withOpacity(0.3),
                      paintStyle: PaintingStyle.fill,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: colorScheme.primary,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide, BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use slide.imagePath if available and valid, otherwise fallback to icon
          // For now, let's assume we are using icons primarily until images are confirmed.
          Icon(slide.icon, size: 120, color: colorScheme.primary),
          const SizedBox(height: 48),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.desc,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String? imagePath; // Optional image path
  final IconData icon; // Fallback or primary icon
  final String title;
  final String desc;

  const _SlideData({
    this.imagePath,
    required this.icon,
    required this.title,
    required this.desc,
  });
}
