import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// The four muted status meanings (design system §2.2), rendered as a
/// tinted pill (§10, Badge / status pill) — never a solid saturated fill.
enum AppStatus { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.status});

  final String label;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (Color fg, Color bg) = switch (status) {
      AppStatus.success => (colors.successFg, colors.successBg),
      AppStatus.warning => (colors.warningFg, colors.warningBg),
      AppStatus.error => (colors.errorFg, colors.errorBg),
      AppStatus.info => (colors.infoFg, colors.infoBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullRadius),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
