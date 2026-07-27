import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_typography.dart';

/// Builds the app [ThemeData] from the design-system tokens.
///
/// Call sites should never construct [ThemeData] ad hoc — always go
/// through [AppTheme.build] so light/dark/high-contrast stay in sync.
abstract final class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required bool highContrast,
    required bool isArabic,
  }) {
    final isDark = brightness == Brightness.dark;
    final AppColors colors = isDark
        ? (highContrast ? AppColors.darkHighContrast : AppColors.dark)
        : (highContrast ? AppColors.lightHighContrast : AppColors.light);
    final AppShadows shadows = isDark ? AppShadows.dark : AppShadows.light;

    final textTheme = AppTypography.buildTextTheme(
      isArabic: isArabic,
      primary: colors.textPrimary,
      secondary: colors.textSecondary,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brandPrimary,
      onPrimary: colors.onBrandPrimary,
      secondary: colors.accent,
      onSecondary: colors.textOnNavy,
      error: colors.errorFg,
      onError: Colors.white,
      surface: colors.bgCard,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.bgPage,
      textTheme: textTheme,
      fontFamily: textTheme.bodyLarge?.fontFamily,
      splashFactory: InkRipple.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors, shadows],
      dividerColor: colors.borderDefault,
      dividerTheme: DividerThemeData(color: colors.borderDefault, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: colors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgRadius,
          side: isDark ? BorderSide(color: colors.borderDefault) : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgPage,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colors.bgCardRaised;
            if (states.contains(WidgetState.pressed)) {
              return Color.lerp(colors.brandPrimary, Colors.black, 0.12);
            }
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
              return Color.lerp(colors.brandPrimary, Colors.white, 0.06);
            }
            return colors.brandPrimary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled) ? colors.textSecondary : colors.onBrandPrimary;
          }),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.mdRadius)),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: AppMotion.fast,
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: colors.borderDefault)),
          foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return colors.bgCardRaised;
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
              return colors.bgCardRaised.withValues(alpha: 0.6);
            }
            return Colors.transparent;
          }),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.mdRadius)),
          animationDuration: AppMotion.fast,
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.textSecondary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return colors.bgCardRaised;
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
              return colors.bgCardRaised.withValues(alpha: 0.6);
            }
            return Colors.transparent;
          }),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.mdRadius)),
          animationDuration: AppMotion.fast,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgCard,
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors.errorFg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors.errorFg, width: 2),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.errorFg),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: colors.brandPrimary, borderRadius: AppRadius.smRadius),
        textStyle: textTheme.bodySmall?.copyWith(color: colors.textOnNavy),
      ),
      focusColor: colors.borderFocus.withValues(alpha: 0.24),
      splashColor: colors.accent.withValues(alpha: 0.12),
      highlightColor: colors.bgCardRaised,
    );
  }
}
