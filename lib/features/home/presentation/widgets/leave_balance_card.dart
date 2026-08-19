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

    final int? total = leaveBalance.totalDays;
    final int? currentBalance = leaveBalance.balance;
    // No entitlement granted for this leave type (e.g. Unpaid before HR
    // grants an allotment) — total/remaining are 0 or, for legacy data
    // predating that default, still null.
    final bool isUnavailable = total == null || currentBalance == null || total == 0;

    final double progress = !isUnavailable ? (currentBalance / total).clamp(0.0, 1.0) : 0.0;

    // Determine status badge — every branch below assigns both, so these
    // are never actually null by the time they're used.
    AppStatus badgeStatus;
    String badgeLabel;

    if (isUnavailable) {
      badgeStatus = AppStatus.info;
      badgeLabel = l10n.homeLeaveNotAvailable;
    } else if (currentBalance == 0) {
      badgeStatus = AppStatus.error;
      badgeLabel = l10n.homeLeaveNoneLeft;
    } else if (progress <= 0.3) {
      badgeStatus = AppStatus.warning;
      badgeLabel = l10n.homeLeaveLowBalance;
    } else {
      badgeStatus = AppStatus.success;
      badgeLabel = l10n.homeLeaveAvailable;
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

    final subtitleText = isUnavailable
        ? l10n.homeLeaveSubtitleNotAvailable
        : l10n.homeLeaveSubtitle(currentBalance, total);

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
                    Text(
                      displayLeaveType,
                      style: AppTypography.textLg(isArabic).copyWith(
                            color: colors.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
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
