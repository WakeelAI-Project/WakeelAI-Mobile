import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Semantic color tokens (design system §2.3).
///
/// Every widget in the app must read colors through
/// `Theme.of(context).extension<AppColors>()!`, never through
/// [AppPalette] directly and never through hardcoded hex values.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgPage,
    required this.bgCard,
    required this.bgCardRaised,
    required this.bgSidebar,
    required this.brandPrimary,
    required this.onBrandPrimary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnNavy,
    required this.borderDefault,
    required this.borderFocus,
    required this.successFg,
    required this.successBg,
    required this.warningFg,
    required this.warningBg,
    required this.errorFg,
    required this.errorBg,
    required this.infoFg,
    required this.infoBg,
  });

  final Color bgPage;
  final Color bgCard;
  final Color bgCardRaised;

  /// Navy in both light and dark — the one constant brand anchor (§12).
  final Color bgSidebar;

  final Color brandPrimary;

  /// Text/icon color for content placed on top of [brandPrimary]. Not the
  /// same as [textOnNavy] — dark mode flips `brand-primary` to a *light*
  /// color (§2.3), so text on top of it must flip to dark too.
  final Color onBrandPrimary;

  /// The only accent color. Reserved for "AI touched this" (§1.2).
  final Color accent;

  final Color textPrimary;
  final Color textSecondary;

  /// Text color for content placed on navy surfaces (sidebar, seal mark).
  final Color textOnNavy;

  final Color borderDefault;

  /// Also used as the focus ring color — the one place brass appears as a
  /// functional (not decorative) signal (§10, Input).
  final Color borderFocus;

  final Color successFg;
  final Color successBg;
  final Color warningFg;
  final Color warningBg;
  final Color errorFg;
  final Color errorBg;
  final Color infoFg;
  final Color infoBg;

  static const AppColors light = AppColors(
    bgPage: AppPalette.neutral50,
    bgCard: Colors.white,
    bgCardRaised: AppPalette.neutral100,
    bgSidebar: AppPalette.navy950,
    brandPrimary: AppPalette.navy900,
    onBrandPrimary: AppPalette.neutral50,
    accent: AppPalette.brass500,
    textPrimary: AppPalette.navy950,
    textSecondary: AppPalette.neutral700,
    textOnNavy: AppPalette.neutral50,
    borderDefault: AppPalette.neutral100,
    borderFocus: AppPalette.brass500,
    successFg: AppPalette.successFg,
    successBg: AppPalette.successBg,
    warningFg: AppPalette.warningFg,
    warningBg: AppPalette.warningBg,
    errorFg: AppPalette.errorFg,
    errorBg: AppPalette.errorBg,
    infoFg: AppPalette.infoFg,
    infoBg: AppPalette.infoBg,
  );

  static AppColors dark = AppColors(
    bgPage: AppPalette.navy950,
    bgCard: AppPalette.navy900,
    bgCardRaised: AppPalette.navy700,
    bgSidebar: AppPalette.navy950,
    brandPrimary: AppPalette.neutral100,
    onBrandPrimary: AppPalette.navy950,
    accent: AppPalette.brass500ReducedSaturation,
    textPrimary: AppPalette.neutral50,
    textSecondary: AppPalette.neutral300,
    textOnNavy: AppPalette.neutral50,
    borderDefault: AppPalette.navy700,
    borderFocus: AppPalette.brass500,
    successFg: AppPalette.successFg,
    successBg: AppPalette.successBg,
    warningFg: AppPalette.warningFg,
    warningBg: AppPalette.warningBg,
    errorFg: AppPalette.errorFg,
    errorBg: AppPalette.errorBg,
    infoFg: AppPalette.infoFg,
    infoBg: AppPalette.infoBg,
  );

  /// High-contrast light: borders/text pushed to stronger primitive steps,
  /// accent left unchanged (§2.3, §12 — already sufficiently distinct).
  static const AppColors lightHighContrast = AppColors(
    bgPage: AppPalette.neutral50,
    bgCard: Colors.white,
    bgCardRaised: AppPalette.neutral100,
    bgSidebar: AppPalette.navy950,
    brandPrimary: AppPalette.navy950,
    onBrandPrimary: AppPalette.neutral50,
    accent: AppPalette.brass500,
    textPrimary: AppPalette.navy950,
    textSecondary: AppPalette.neutral900,
    textOnNavy: AppPalette.neutral50,
    borderDefault: AppPalette.neutral500,
    borderFocus: AppPalette.brass700HighContrast,
    successFg: AppPalette.successFg,
    successBg: AppPalette.successBg,
    warningFg: AppPalette.warningFg,
    warningBg: AppPalette.warningBg,
    errorFg: AppPalette.errorFg,
    errorBg: AppPalette.errorBg,
    infoFg: AppPalette.infoFg,
    infoBg: AppPalette.infoBg,
  );

  static AppColors darkHighContrast = AppColors(
    bgPage: AppPalette.navy950,
    bgCard: AppPalette.navy900,
    bgCardRaised: AppPalette.navy700,
    bgSidebar: AppPalette.navy950,
    brandPrimary: AppPalette.neutral50,
    onBrandPrimary: AppPalette.navy950,
    accent: AppPalette.brass500ReducedSaturation,
    textPrimary: AppPalette.neutral50,
    textSecondary: AppPalette.neutral100,
    textOnNavy: AppPalette.neutral50,
    borderDefault: AppPalette.navy300,
    borderFocus: AppPalette.brass700HighContrast,
    successFg: AppPalette.successFg,
    successBg: AppPalette.successBg,
    warningFg: AppPalette.warningFg,
    warningBg: AppPalette.warningBg,
    errorFg: AppPalette.errorFg,
    errorBg: AppPalette.errorBg,
    infoFg: AppPalette.infoFg,
    infoBg: AppPalette.infoBg,
  );

  @override
  AppColors copyWith({
    Color? bgPage,
    Color? bgCard,
    Color? bgCardRaised,
    Color? bgSidebar,
    Color? brandPrimary,
    Color? onBrandPrimary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnNavy,
    Color? borderDefault,
    Color? borderFocus,
    Color? successFg,
    Color? successBg,
    Color? warningFg,
    Color? warningBg,
    Color? errorFg,
    Color? errorBg,
    Color? infoFg,
    Color? infoBg,
  }) {
    return AppColors(
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgCardRaised: bgCardRaised ?? this.bgCardRaised,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      onBrandPrimary: onBrandPrimary ?? this.onBrandPrimary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnNavy: textOnNavy ?? this.textOnNavy,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocus: borderFocus ?? this.borderFocus,
      successFg: successFg ?? this.successFg,
      successBg: successBg ?? this.successBg,
      warningFg: warningFg ?? this.warningFg,
      warningBg: warningBg ?? this.warningBg,
      errorFg: errorFg ?? this.errorFg,
      errorBg: errorBg ?? this.errorBg,
      infoFg: infoFg ?? this.infoFg,
      infoBg: infoBg ?? this.infoBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardRaised: Color.lerp(bgCardRaised, other.bgCardRaised, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      onBrandPrimary: Color.lerp(onBrandPrimary, other.onBrandPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textOnNavy: Color.lerp(textOnNavy, other.textOnNavy, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      errorFg: Color.lerp(errorFg, other.errorFg, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      infoFg: Color.lerp(infoFg, other.infoFg, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
    );
  }
}
