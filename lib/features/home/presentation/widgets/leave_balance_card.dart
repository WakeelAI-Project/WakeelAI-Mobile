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
    final int used = leaveBalance.usedDays;
    final int? currentBalance = leaveBalance.balance;
    final bool isUnlimited = total == null || currentBalance == null;

    final double progress = !isUnlimited && total > 0 ? (currentBalance / total).clamp(0.0, 1.0) : 0.0;
    
    // Determine status badge
    AppStatus? badgeStatus;
    String? badgeLabel;
    
    if (isUnlimited) {
      badgeStatus = AppStatus.success;
      badgeLabel = l10n.homeLeaveUnlimited;
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

    final subtitleText = isUnlimited 
        ? l10n.homeLeaveSubtitleUnlimited(used) 
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
                    if (badgeStatus != null && badgeLabel != null)
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
                    value: isUnlimited ? 1.0 : progress,
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
