import 'package:flutter/material.dart';

/// Elevation tokens (design system §6).
///
/// In dark mode, shadows barely read against a navy background — per the
/// spec, dark mode uses a 1px border (or a very subtle glow for `lg`)
/// instead of a shadow. [sm]/[md]/[lg] are therefore empty lists in the
/// dark variant; use [AppColors.borderDefault] for the border in that case.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({required this.sm, required this.md, required this.lg});

  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;

  static const AppShadows light = AppShadows(
    sm: [BoxShadow(color: Color(0x0F101F3D), blurRadius: 2, offset: Offset(0, 1))],
    md: [BoxShadow(color: Color(0x14101F3D), blurRadius: 12, offset: Offset(0, 4))],
    lg: [BoxShadow(color: Color(0x23101F3D), blurRadius: 32, offset: Offset(0, 12))],
  );

  static const AppShadows dark = AppShadows(sm: [], md: [], lg: []);

  @override
  AppShadows copyWith({List<BoxShadow>? sm, List<BoxShadow>? md, List<BoxShadow>? lg}) {
    return AppShadows(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      sm: BoxShadow.lerpList(sm, other.sm, t) ?? other.sm,
      md: BoxShadow.lerpList(md, other.md, t) ?? other.md,
      lg: BoxShadow.lerpList(lg, other.lg, t) ?? other.lg,
    );
  }
}
