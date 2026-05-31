import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';

/// Shared top app bar matching the Stitch design (glassmorphic blur).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppTopBar({
    super.key,
    this.title = 'MUSIC GNH',
    this.leading,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: cs.surface.withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: cs.onSurface,
                      )
                    else if (leading != null)
                      leading!
                    else
                      Image.asset(
                        'assets/images/logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    ...?actions,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
