import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens extracted from the Stitch design.
/// All roles use Hanken Grotesk.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseFont => GoogleFonts.hankenGrotesk();

  // Display Large — 48px / w800 / -0.02em / 56px LH
  static TextStyle get displayLarge => _baseFont.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.96, // -0.02em * 48
        height: 56 / 48,
      );

  // Headline Large — 32px / w700 / -0.01em / 40px LH
  static TextStyle get headlineLarge => _baseFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32, // -0.01em * 32
        height: 40 / 32,
      );

  // Headline Large Mobile — 24px / w700 / 32px LH
  static TextStyle get headlineLargeMobile => _baseFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
      );

  // Headline Medium — 20px / w600 / 28px LH
  static TextStyle get headlineMedium => _baseFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  // Body Large — 16px / w400 / 24px LH
  static TextStyle get bodyLarge => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  // Body Medium — 14px / w400 / 20px LH
  static TextStyle get bodyMedium => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  // Label Caps — 12px / w700 / 0.05em / 16px LH
  static TextStyle get labelCaps => _baseFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6, // 0.05em * 12
        height: 16 / 12,
      );

  // Label Small — 11px / w500 / 14px LH
  static TextStyle get labelSmall => _baseFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
      );

  /// Builds the Material [TextTheme] from design tokens.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayLarge.copyWith(fontSize: 40, fontWeight: FontWeight.w700),
        displaySmall: headlineLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineLargeMobile,
        titleLarge: headlineMedium,
        titleMedium: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        titleSmall: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodyMedium.copyWith(fontSize: 12),
        labelLarge: labelCaps,
        labelMedium: labelCaps.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
        labelSmall: labelSmall,
      );
}
