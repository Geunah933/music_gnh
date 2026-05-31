import 'package:flutter/material.dart';

/// Color tokens extracted from the Stitch "Music GNH Manager" project.
/// Follows Material 3 color scheme conventions.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // DARK MODE (Primary — from Stitch design)
  // ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0E150E);
  static const Color darkSurface = Color(0xFF0E150E);
  static const Color darkSurfaceDim = Color(0xFF0E150E);
  static const Color darkSurfaceBright = Color(0xFF333B33);
  static const Color darkSurfaceContainerLowest = Color(0xFF091009);
  static const Color darkSurfaceContainerLow = Color(0xFF161D16);
  static const Color darkSurfaceContainer = Color(0xFF1A211A);
  static const Color darkSurfaceContainerHigh = Color(0xFF242C24);
  static const Color darkSurfaceContainerHighest = Color(0xFF2F372E);
  static const Color darkSurfaceVariant = Color(0xFF2F372E);
  static const Color darkOnSurface = Color(0xFFDDE5D9);
  static const Color darkOnSurfaceVariant = Color(0xFFBCCBB9);
  static const Color darkInverseSurface = Color(0xFFDDE5D9);
  static const Color darkInverseOnSurface = Color(0xFF2B322A);
  static const Color darkOutline = Color(0xFF869585);
  static const Color darkOutlineVariant = Color(0xFF3D4A3D);
  static const Color darkSurfaceTint = Color(0xFF53E076);

  static const Color darkPrimary = Color(0xFF53E076);
  static const Color darkPrimaryContainer = Color(0xFF1DB954);
  static const Color darkOnPrimary = Color(0xFF003914);
  static const Color darkOnPrimaryContainer = Color(0xFF004118);
  static const Color darkInversePrimary = Color(0xFF006E2D);
  static const Color darkPrimaryFixed = Color(0xFF72FE8F);
  static const Color darkPrimaryFixedDim = Color(0xFF53E076);

  static const Color darkSecondary = Color(0xFFDEB7FF);
  static const Color darkSecondaryContainer = Color(0xFF8B00E7);
  static const Color darkOnSecondary = Color(0xFF4A007F);
  static const Color darkOnSecondaryContainer = Color(0xFFEACEFF);

  static const Color darkTertiary = Color(0xFFFFB3B3);
  static const Color darkTertiaryContainer = Color(0xFFFF767B);
  static const Color darkOnTertiary = Color(0xFF680114);
  static const Color darkOnTertiaryContainer = Color(0xFF730A1B);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  // ──────────────────────────────────────────────
  // LIGHT MODE (Derived from inverse tokens)
  // ──────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5FBF0);
  static const Color lightSurface = Color(0xFFF5FBF0);
  static const Color lightSurfaceDim = Color(0xFFD5DCD1);
  static const Color lightSurfaceBright = Color(0xFFF5FBF0);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFEFF6EA);
  static const Color lightSurfaceContainer = Color(0xFFE9F0E5);
  static const Color lightSurfaceContainerHigh = Color(0xFFE4EADF);
  static const Color lightSurfaceContainerHighest = Color(0xFFDDE5D9);
  static const Color lightSurfaceVariant = Color(0xFFDDE5D9);
  static const Color lightOnSurface = Color(0xFF181D17);
  static const Color lightOnSurfaceVariant = Color(0xFF414941);
  static const Color lightInverseSurface = Color(0xFF2D332C);
  static const Color lightInverseOnSurface = Color(0xFFEDF3E8);
  static const Color lightOutline = Color(0xFF717970);
  static const Color lightOutlineVariant = Color(0xFFC0C9BD);
  static const Color lightSurfaceTint = Color(0xFF006E2D);

  static const Color lightPrimary = Color(0xFF006E2D);
  static const Color lightPrimaryContainer = Color(0xFF53E076);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF004118);
  static const Color lightInversePrimary = Color(0xFF53E076);
  static const Color lightPrimaryFixed = Color(0xFF72FE8F);
  static const Color lightPrimaryFixedDim = Color(0xFF53E076);

  static const Color lightSecondary = Color(0xFF7B00CC);
  static const Color lightSecondaryContainer = Color(0xFFEACEFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSecondaryContainer = Color(0xFF4A007F);

  static const Color lightTertiary = Color(0xFF9A2530);
  static const Color lightTertiaryContainer = Color(0xFFFFDAD9);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightOnTertiaryContainer = Color(0xFF730A1B);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightOnErrorContainer = Color(0xFF410002);

  // ──────────────────────────────────────────────
  // Color Schemes
  // ──────────────────────────────────────────────
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        primaryFixed: darkPrimaryFixed,
        primaryFixedDim: darkPrimaryFixedDim,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnTertiary,
        tertiaryContainer: darkTertiaryContainer,
        onTertiaryContainer: darkOnTertiaryContainer,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnErrorContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceDim: darkSurfaceDim,
        surfaceBright: darkSurfaceBright,
        surfaceContainerLowest: darkSurfaceContainerLowest,
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceContainerHigh,
        surfaceContainerHighest: darkSurfaceContainerHighest,
        onSurfaceVariant: darkOnSurfaceVariant,
        inverseSurface: darkInverseSurface,
        onInverseSurface: darkInverseOnSurface,
        inversePrimary: darkInversePrimary,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        surfaceTint: darkSurfaceTint,
        shadow: Colors.black,
        scrim: Colors.black,
      );

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        primaryFixed: lightPrimaryFixed,
        primaryFixedDim: lightPrimaryFixedDim,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        tertiary: lightTertiary,
        onTertiary: lightOnTertiary,
        tertiaryContainer: lightTertiaryContainer,
        onTertiaryContainer: lightOnTertiaryContainer,
        error: lightError,
        onError: lightOnError,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightOnErrorContainer,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceDim: lightSurfaceDim,
        surfaceBright: lightSurfaceBright,
        surfaceContainerLowest: lightSurfaceContainerLowest,
        surfaceContainerLow: lightSurfaceContainerLow,
        surfaceContainer: lightSurfaceContainer,
        surfaceContainerHigh: lightSurfaceContainerHigh,
        surfaceContainerHighest: lightSurfaceContainerHighest,
        onSurfaceVariant: lightOnSurfaceVariant,
        inverseSurface: lightInverseSurface,
        onInverseSurface: lightInverseOnSurface,
        inversePrimary: lightInversePrimary,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
        surfaceTint: lightSurfaceTint,
        shadow: Colors.black,
        scrim: Colors.black,
      );
}
