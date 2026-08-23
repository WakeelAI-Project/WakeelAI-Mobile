import 'package:flutter/material.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/employee_profile.dart';

class LeaveBalanceCard extends StatelessWidget {
  const LeaveBalanceCard({
    super.key,
    required this.leaveBalance,
    required this.onTap,
  });

  final LeaveBalance leaveBalance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    
    final String rawLeaveType = leaveBalance.leaveType;
    String displayLeaveType = rawLeaveType;
    if (rawLeaveType.toLowerCase() == 'annual') displayLeaveType = l10n.leaveTypeAnnual;
    if (rawLeaveType.toLowerCase() == 'sick') displayLeaveType = l10n.leaveTypeSick;
    if (rawLeaveType.toLowerCase() == 'unpaid') displayLeaveType = l10n.leaveTypeUnpaid;

    final int? totalRaw = leaveBalance.totalDays;
    final int? currentBalanceRaw = leaveBalance.balance;
    // A null total_days means this leave type is genuinely uncapped (Sick,
    // Unpaid) — never coerced to 0, and never treated the same as "no
    // entitlement granted yet" (a real 0, e.g. Annual before 6 months of
    // service).
    final bool isUncapped = totalRaw == null;

    double progress = 0.0;
    AppStatus badgeStatus;
    String badgeLabel;
    String subtitleText;

    if (isUncapped) {
      badgeStatus = AppStatus.success;
      badgeLabel = l10n.homeLeaveUnlimited;
      subtitleText = l10n.homeLeaveSubtitleUnlimited(leaveBalance.usedDays);
    } else if (currentBalanceRaw == null || totalRaw == 0) {
      badgeStatus = AppStatus.info;
      badgeLabel = l10n.homeLeaveNotAvailable;
      subtitleText = l10n.homeLeaveSubtitleNotAvailable;
    } else {
      // Both promoted to non-null int here by the checks above.
      final int total = totalRaw;
      final int currentBalance = currentBalanceRaw;
      progress = (currentBalance / total).clamp(0.0, 1.0);
      subtitleText = l10n.homeLeaveSubtitle(currentBalance, total);

      if (currentBalance == 0) {
        badgeStatus = AppStatus.error;
        badgeLabel = l10n.homeLeaveNoneLeft;
      } else if (progress <= 0.3) {
        badgeStatus = AppStatus.warning;
        badgeLabel = l10n.homeLeaveLowBalance;
      } else {
        badgeStatus = AppStatus.success;
        badgeLabel = l10n.homeLeaveAvailable;
      }
    }

    // Determine progress color
    Color progressColor;
    if (rawLeaveType.toLowerCase().contains('annual')) {
      progressColor = colors.brandPrimary;
    } else if (rawLeaveType.toLowerCase().contains('sick')) {
      progressColor = colors.warningFg;
    } else if (rawLeaveType.toLowerCase().contains('unpaid')) {
      progressColor = colors.errorFg;
    } else {
      progressColor = colors.brandPrimary; // Default
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: AppRadius.lgRadius,
        boxShadow: shadows.md,
        border: shadows.md.isEmpty ? Border.all(color: colors.borderDefault) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        displayLeaveType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textLg(isArabic).copyWith(
                              color: colors.brandPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    StatusBadge(label: badgeLabel, status: badgeStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  subtitleText,
                  style: AppTypography.textSm(isArabic).copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.s3),
                ClipRRect(
                  borderRadius: AppRadius.fullRadius,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.borderDefault,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
