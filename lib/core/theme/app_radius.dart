import 'package:flutter/material.dart';

/// Corner radius scale (design system §5).
///
/// A bold corporate/legal direction reads more credible with slightly
/// *tighter* radii than a consumer-SaaS look — prefer [sm]/[md] for most
/// controls, reserve [xl]/[xxl] for the AI chat surfaces specifically.
abstract final class AppRadius {
  static const double xs = 4; // checkboxes, small badges
  static const double sm = 6; // buttons (sm), inputs
  static const double md = 8; // buttons (default), popovers
  static const double lg = 12; // cards
  static const double xl = 16; // modals, large panels
  static const double xxl = 24; // chat bubble container, pill chat input
  static const double full = 9999; // avatars, FAB, badges

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}
