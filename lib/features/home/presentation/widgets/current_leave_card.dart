import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/employee_profile.dart';

class CurrentLeaveCard extends StatelessWidget {
  const CurrentLeaveCard({super.key, required this.currentLeave});

  final CurrentLeave currentLeave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    final rawLeaveType = currentLeave.leaveType.toLowerCase();
    String displayLeaveType = currentLeave.leaveType;
    if (rawLeaveType == 'annual') displayLeaveType = l10n.leaveTypeAnnual;
    if (rawLeaveType == 'sick') displayLeaveType = l10n.leaveTypeSick;
    if (rawLeaveType == 'unpaid') displayLeaveType = l10n.leaveTypeUnpaid;

    final total = currentLeave.totalDays;
    final elapsed = currentLeave.elapsedDays.clamp(0, total);
    final progress = total > 0 ? elapsed / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.infoBg,
        borderRadius: AppRadius.lgRadius,
        boxShadow: shadows.md,
        border: shadows.md.isEmpty ? Border.all(color: colors.borderDefault) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendarClock, color: colors.infoFg, size: 20),
              const SizedBox(width: AppSpacing.s2),
              Text(
                l10n.homeCurrentLeaveTitle,
                style: AppTypography.textLg(isArabic).copyWith(
                      color: colors.infoFg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            l10n.homeCurrentLeaveSubtitle(displayLeaveType, elapsed, total),
            style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          ClipRRect(
            borderRadius: AppRadius.fullRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.borderDefault,
              valueColor: AlwaysStoppedAnimation<Color>(colors.infoFg),
            ),
          ),
        ],
      ),
    );
  }
}
