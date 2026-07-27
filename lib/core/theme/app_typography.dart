import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens (design system §3).
///
/// Heading font is Fraunces (Latin) / Cairo (Arabic) — Arabic uses one
/// family across heading and body since Arabic display/serif faces don't
/// hold up at UI sizes. Numeric figures (IDs, audit timestamps, currency)
/// always use [mono], regardless of locale.
abstract final class AppTypography {
  /// Arabic script needs ~10-15% extra line-height at every step.
  static const double _arabicLineHeightBoost = 1.125;

  /// Cairo doesn't carry a 600 weight the way Fraunces does; step Latin
  /// weights up to the nearest Arabic-available weight (400/500/700).
  static FontWeight _arabicWeight(FontWeight latinWeight) {
    if (latinWeight == FontWeight.w600) return FontWeight.w700;
    return latinWeight;
  }

  static TextStyle _heading(
    bool isArabic, {
    required double size,
    required double height,
    required FontWeight weight,
  }) {
    final lineHeight = isArabic ? height * _arabicLineHeightBoost : height;
    return isArabic
        ? GoogleFonts.cairo(fontSize: size, height: lineHeight, fontWeight: _arabicWeight(weight))
        : GoogleFonts.fraunces(fontSize: size, height: lineHeight, fontWeight: weight);
  }

  static TextStyle _body(
    bool isArabic, {
    required double size,
    required double height,
    required FontWeight weight,
  }) {
    final lineHeight = isArabic ? height * _arabicLineHeightBoost : height;
    return isArabic
        ? GoogleFonts.cairo(fontSize: size, height: lineHeight, fontWeight: _arabicWeight(weight))
        : GoogleFonts.publicSans(fontSize: size, height: lineHeight, fontWeight: weight);
  }

  /// Numeric / mono — IDs, audit timestamps, currency figures only (§3).
  static TextStyle mono({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) {
    return GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, height: 1.4, color: color);
  }

  // --- Raw design-system scale (§3, "Type scale" table) ---------------

  static TextStyle text3xl(bool isArabic) =>
      _heading(isArabic, size: 30, height: 1.2, weight: FontWeight.w600); // page title
  static TextStyle text2xl(bool isArabic) =>
      _heading(isArabic, size: 24, height: 1.25, weight: FontWeight.w600); // section header
  static TextStyle textXl(bool isArabic) =>
      _heading(isArabic, size: 20, height: 1.35, weight: FontWeight.w500); // card title
  static TextStyle textLg(bool isArabic) =>
      _body(isArabic, size: 18, height: 1.4, weight: FontWeight.w500); // emphasized body
  static TextStyle textBase(bool isArabic) =>
      _body(isArabic, size: 16, height: 1.5, weight: FontWeight.w400); // default body
  static TextStyle textSm(bool isArabic) =>
      _body(isArabic, size: 14, height: 1.45, weight: FontWeight.w500); // UI labels, table cells
  static TextStyle textXs(bool isArabic) =>
      _body(isArabic, size: 12, height: 1.4, weight: FontWeight.w500); // meta, captions, badges

  /// Builds a full Material [TextTheme] from the design-system scale so
  /// standard widgets (AppBar, ListTile, etc.) pick up the right fonts
  /// without every screen needing to reach for the raw scale above.
  static TextTheme buildTextTheme({
    required bool isArabic,
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: _heading(isArabic, size: 45, height: 1.15, weight: FontWeight.w600).copyWith(color: primary),
      displayMedium: _heading(isArabic, size: 36, height: 1.18, weight: FontWeight.w600).copyWith(color: primary),
      displaySmall: text3xl(isArabic).copyWith(color: primary),
      headlineLarge: text3xl(isArabic).copyWith(color: primary),
      headlineMedium: text2xl(isArabic).copyWith(color: primary),
      headlineSmall: textXl(isArabic).copyWith(color: primary),
      titleLarge: textXl(isArabic).copyWith(color: primary),
      titleMedium: textLg(isArabic).copyWith(color: primary),
      titleSmall: textSm(isArabic).copyWith(color: primary, fontWeight: FontWeight.w600),
      bodyLarge: textBase(isArabic).copyWith(color: primary),
      bodyMedium: textSm(isArabic).copyWith(color: primary, fontWeight: FontWeight.w400),
      bodySmall: textXs(isArabic).copyWith(color: secondary, fontWeight: FontWeight.w400),
      labelLarge: textSm(isArabic).copyWith(color: primary),
      labelMedium: textXs(isArabic).copyWith(color: secondary),
      labelSmall: textXs(isArabic).copyWith(color: secondary),
    );
  }
}
