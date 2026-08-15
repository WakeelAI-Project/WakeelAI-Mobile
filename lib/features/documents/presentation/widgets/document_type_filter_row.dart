import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../application/documents_provider.dart';
import '../../domain/wakeel_document.dart';

class DocumentTypeFilterRow extends ConsumerWidget {
  const DocumentTypeFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final currentFilter = ref.watch(documentsProvider).filter;

    // Stub labels — same convention as LeaveStatusFilterRow, needs actual
    // localization keys later.
    const filters = <DocumentTypeCategory?>[
      null,
      DocumentTypeCategory.contract,
      DocumentTypeCategory.warningLetter,
      DocumentTypeCategory.termination,
    ];
    String labelFor(DocumentTypeCategory? type) {
      switch (type) {
        case null:
          return 'All';
        case DocumentTypeCategory.contract:
          return 'Contracts';
        case DocumentTypeCategory.warningLetter:
          return 'Warning';
        case DocumentTypeCategory.termination:
          return 'Termination';
        case DocumentTypeCategory.other:
          return 'Other';
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
      child: Row(
        children: filters.map((type) {
          final isSelected = currentFilter == type;
          return Padding(
            padding: EdgeInsets.only(
              right: isArabic ? 0 : AppSpacing.s2,
              left: isArabic ? AppSpacing.s2 : 0,
            ),
            child: GestureDetector(
              onTap: () => ref.read(documentsProvider.notifier).setFilter(type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
                decoration: BoxDecoration(
                  color: isSelected ? colors.brandPrimary : colors.bgCardRaised,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  labelFor(type),
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
