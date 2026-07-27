import 'package:flutter/material.dart';

/// Motion tokens (design system §8).
///
/// Keep motion restrained: hover/focus feedback, tab/accordion/dropdown
/// transitions, and the one signature moment (sidebar active-item
/// highlight). Do not add spring/scale animation to every button.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120); // hover, focus
  static const Duration base = Duration(milliseconds: 200); // tabs, accordion
  static const Duration slow = Duration(milliseconds: 300); // signature moment

  static const Curve fastCurve = Curves.easeOut;
  static const Curve baseCurve = Curves.easeInOut;

  /// Light spring feel for the one deliberate signature motion moment —
  /// the sidebar active-item highlight (shared-element style animation).
  static const Curve signatureSpringCurve = Curves.easeOutBack;
}
