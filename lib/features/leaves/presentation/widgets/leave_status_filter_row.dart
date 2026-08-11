import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';
import '../../application/leave_providers.dart';

class LeaveStatusFilterRow extends ConsumerWidget {
  const LeaveStatusFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final currentFilter = ref.watch(leaveStatusFilterProvider);
    
    final filters = ['All', 'Draft', 'Pending', 'Approved', 'Rejected', 'Cancelled'];
    
    // Stub mapping, needs actual localization keys later
    String getLocalizedFilter(String filter) {
      return filter;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
      child: Row(
        children: filters.map((filter) {
          final isSelected = currentFilter == filter;
          return Padding(
            padding: EdgeInsets.only(
              right: isArabic ? 0 : AppSpacing.s2,
              left: isArabic ? AppSpacing.s2 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                ref.read(leaveStatusFilterProvider.notifier).state = filter;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
                decoration: BoxDecoration(
                  color: isSelected ? colors.brandPrimary : colors.bgCardRaised,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  getLocalizedFilter(filter),
                  style: AppTypography.textSm(isArabic).copyWith(
                    color: isSelected ? colors.onBrandPrimary : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
