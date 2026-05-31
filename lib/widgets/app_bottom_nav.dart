import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';

/// Shared bottom navigation bar matching the Stitch design.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 80 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.home,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                color: cs.primary,
                inactiveColor: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: l10n.search,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                color: cs.primary,
                inactiveColor: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              _NavItem(
                icon: Icons.library_music_rounded,
                label: l10n.library,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                color: cs.primary,
                inactiveColor: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Icon(icon, color: color, size: 28),
                )
              else
                Icon(icon, color: inactiveColor, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : inactiveColor,
                  height: 14 / 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
