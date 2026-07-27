import 'package:flutter/material.dart';

/// Raw primitive color scales from the Wakeel AI design system (§2.1–2.2).
///
/// Nothing in the app should reference these directly — widgets must go
/// through [AppColors] (the semantic token layer) instead. This file only
/// exists so the semantic layer has a single, auditable source of truth.
abstract final class AppPalette {
  // Navy — the brand color.
  static const Color navy950 = Color(0xFF0A1729);
  static const Color navy900 = Color(0xFF101F3D);
  static const Color navy700 = Color(0xFF1B3050);
  static const Color navy500 = Color(0xFF3E5A82);
  static const Color navy300 = Color(0xFF9FB2C9);
  static const Color navy100 = Color(0xFFDDE4EC);
  static const Color navy50 = Color(0xFFF1F4F8);

  // Brass gold — the *only* accent. Reserved for "AI touched this".
  static const Color brass900 = Color(0xFF7A5B2E);
  static const Color brass700 = Color(0xFF9C7640);
  static const Color brass500 = Color(0xFFB8935B);
  static const Color brass300 = Color(0xFFD9C299);
  static const Color brass100 = Color(0xFFF0E6D3);
  static const Color brass50 = Color(0xFFF8F2E8);

  // Neutral — paper/slate, used for everything that isn't navy or brass.
  static const Color neutral950 = Color(0xFF14161B);
  static const Color neutral900 = Color(0xFF20232B);
  static const Color neutral700 = Color(0xFF4A505C);
  static const Color neutral500 = Color(0xFF7A818F);
  static const Color neutral300 = Color(0xFFC7CCD3);
  static const Color neutral100 = Color(0xFFE8EAED);
  static const Color neutral50 = Color(0xFFF8F7F3);

  // Status — deliberately muted/brick-toned so they never compete with brass.
  static const Color successFg = Color(0xFF2F6B4F);
  static const Color successBg = Color(0x1A2F6B4F); // ~10% opacity
  static const Color warningFg = Color(0xFF8A5A1E);
  static const Color warningBg = Color(0x1A8A5A1E);
  static const Color errorFg = Color(0xFF8C3229);
  static const Color errorBg = Color(0x1A8C3229);
  static const Color infoFg = Color(0xFF2E5480);
  static const Color infoBg = Color(0x1A2E5480);

  /// Dark-mode accent per §12: "same hue, slightly reduced saturation to
  /// avoid glow". Derived rather than hand-picked so it always tracks
  /// [brass500] if that value ever changes.
  static Color get brass500ReducedSaturation {
    final hsl = HSLColor.fromColor(brass500);
    return hsl.withSaturation((hsl.saturation * 0.82).clamp(0.0, 1.0)).toColor();
  }

  /// High-contrast variant of brass-700, used only for the accent color in
  /// high-contrast mode per §2.3.
  static const Color brass700HighContrast = brass700;
}
