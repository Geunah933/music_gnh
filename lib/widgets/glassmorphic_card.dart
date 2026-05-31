import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable glassmorphic container matching the Stitch design system.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurAmount;
  final double opacity;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.blurAmount = 20,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
