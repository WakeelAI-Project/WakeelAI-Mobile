import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Marks content as AI-generated, as opposed to authoritative/human
/// content (design system §1.2, §10). Uses [AppColors.accent] at a light
/// tint — the *only* place brass appears as a badge fill outside the
/// citation marker, reinforcing the navy = official / gold = AI system.
class AiBadge extends StatelessWidget {
  const AiBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppPalette.brass300 : AppPalette.brass900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
