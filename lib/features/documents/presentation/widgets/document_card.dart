import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../domain/wakeel_document.dart';

IconData iconForDocumentType(DocumentType type) {
  switch (type) {
    case DocumentType.contract:
      return Symbols.description;
    case DocumentType.warningLetter:
      return Symbols.warning;
    case DocumentType.termination:
      return Symbols.person_remove;
  }
}

// Stub labels — same convention as LeaveStatusFilterRow/leave type labels
// elsewhere, needs actual localization keys later.
String labelForDocumentType(DocumentType type) {
  switch (type) {
    case DocumentType.contract:
      return 'Contract';
    case DocumentType.warningLetter:
      return 'Warning Letter';
    case DocumentType.termination:
      return 'Termination Letter';
  }
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.document, required this.onTap});

  final WakeelDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final isDraft = document.status == DocumentStatus.draft;

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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.bgCardRaised,
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(iconForDocumentType(document.docType), color: colors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelForDocumentType(document.docType),
                        style: AppTypography.textBase(isArabic).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(document.createdAt),
                        style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                StatusBadge(
                  label: isDraft ? 'Being reviewed' : 'Final',
                  status: isDraft ? AppStatus.warning : AppStatus.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
