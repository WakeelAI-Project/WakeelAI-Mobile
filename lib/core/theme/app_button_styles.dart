import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_radius.dart';

/// The five button variants from the design system (§10, Button).
///
/// Flutter only ships three button widgets (Elevated/Outlined/Text), so
/// [primary]/[secondary]/[ghost] are wired into the corresponding
/// `*ButtonTheme`s in [AppTheme.build], while [aiAccent] and [danger] are
/// applied explicitly wherever those variants are needed
/// (`ElevatedButton(style: AppButtonStyles.aiAccent(context), ...)`).
abstract final class AppButtonStyles {
  static Color _lighten(Color c, double amount) => Color.lerp(c, Colors.white, amount)!;
  static Color _darken(Color c, double amount) => Color.lerp(c, Colors.black, amount)!;

  static ButtonStyle _variant({
    required Color background,
    required Color foreground,
    required Color disabledBackground,
    required Color disabledForeground,
    BorderSide? borderSide,
    double hoverLighten = 0.06,
    double activeDarken = 0.12,
  }) {
    Color resolve(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return disabledBackground;
      if (states.contains(WidgetState.pressed)) return _darken(background, activeDarken);
      if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
        return _lighten(background, hoverLighten);
      }
      return background;
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(resolve),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled) ? disabledForeground : foreground;
      }),
      side: borderSide == null
          ? null
          : WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return borderSide;
              return borderSide;
            }),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: AppRadius.mdRadius)),
      animationDuration: AppMotion.fast,
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  static ButtonStyle primary(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _variant(
      background: colors.brandPrimary,
      foreground: colors.onBrandPrimary,
      disabledBackground: colors.bgCardRaised,
      disabledForeground: colors.textSecondary,
    );
  }

  static ButtonStyle secondary(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _variant(
      background: Colors.transparent,
      foreground: colors.textPrimary,
      disabledBackground: Colors.transparent,
      disabledForeground: colors.textSecondary,
      borderSide: BorderSide(color: colors.borderDefault),
      hoverLighten: 0,
      activeDarken: 0,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return colors.bgCardRaised.withValues(alpha: 1);
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return colors.bgCardRaised.withValues(alpha: 0.6);
        }
        return Colors.transparent;
      }),
    );
  }

  static ButtonStyle aiAccent(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _variant(
      background: colors.accent,
      foreground: colors.textOnNavy,
      disabledBackground: colors.bgCardRaised,
      disabledForeground: colors.textSecondary,
    );
  }

  static ButtonStyle ghost(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _variant(
      background: Colors.transparent,
      foreground: colors.textSecondary,
      disabledBackground: Colors.transparent,
      disabledForeground: colors.textSecondary,
      hoverLighten: 0,
      activeDarken: 0,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return colors.bgCardRaised;
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return colors.bgCardRaised.withValues(alpha: 0.6);
        }
        return Colors.transparent;
      }),
    );
  }

  static ButtonStyle danger(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return _variant(
      background: colors.errorFg,
      foreground: Colors.white,
      disabledBackground: colors.bgCardRaised,
      disabledForeground: colors.textSecondary,
      hoverLighten: 0,
      activeDarken: 0.14,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return colors.bgCardRaised;
        if (states.contains(WidgetState.pressed)) return _darken(colors.errorFg, 0.14);
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return _darken(colors.errorFg, 0.08);
        }
        return colors.errorFg;
      }),
    );
  }
}
