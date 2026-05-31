import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds complete ThemeData for dark and light modes.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _buildTheme(AppColors.darkColorScheme);
  static ThemeData get lightTheme => _buildTheme(AppColors.lightColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        thickness: 1,
        space: 0,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        labelStyle: AppTextStyles.labelCaps,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        side: BorderSide.none,
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTextStyles.headlineMedium,
        unselectedLabelStyle: AppTextStyles.headlineMedium,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurfaceContainer;
          }
          return colorScheme.onSurface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant;
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
