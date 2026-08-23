import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// The Wakeel AI "W" brand mark.
///
/// Matches the logo used across the rest of the Wakeel AI product suite —
/// see WakeelAI-Frontend's `public/wakeel-logo.svg`. Used everywhere the app
/// shows its logo next to the "Wakeel AI" name (auth screens, chat drawer).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.fillColor, this.strokeColor});

  final double size;

  /// Defaults to [AppColors.textOnNavy] — safe on the mark's most common
  /// background (the navy sidebar/drawer). Pass [AppColors.brandPrimary]
  /// explicitly on light-page contexts (it flips with theme, unlike a fixed
  /// navy surface).
  final Color? fillColor;

  /// Defaults to [AppColors.accent] — the mark's thin outline.
  final Color? strokeColor;

  static const _path = 'M8 12h10l6 27 6-19h4l6 19 6-27h10L46 52h-9l-5-17-5 17h-9L8 12Z';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final fill = fillColor ?? colors.textOnNavy;
    final stroke = strokeColor ?? colors.accent;
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
      '<path fill="${_toHex(fill)}" stroke="${_toHex(stroke)}" '
      'stroke-width="1.5" stroke-linejoin="miter" d="$_path"/></svg>',
      width: size,
      height: size,
    );
  }

  static String _toHex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
