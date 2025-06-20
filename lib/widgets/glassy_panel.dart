import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable frosted-glass container that automatically adapts
/// its translucency to the current theme.
class GlassyPanel extends StatelessWidget {
  const GlassyPanel({super.key, required this.child, this.radius = 28});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(isDark ? 0.08 : 0.28),
                Colors.white.withOpacity(isDark ? 0.03 : 0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
