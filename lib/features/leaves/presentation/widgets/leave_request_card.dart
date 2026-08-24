import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../domain/leave_request.dart';
import '../../application/leave_providers.dart';

class LeaveRequestCard extends ConsumerWidget {
  const LeaveRequestCard({
    super.key,
    required this.request,
  });

  final LeaveRequest request;

  /// Opens the attachment (which may be a PDF, image, or any file type the
  /// leave request form accepts) in an external app rather than an in-app
  /// viewer, since the backend imposes no fixed type — the OS already knows
  /// how to preview whatever this URL actually points to.
  /// Confirms before withdrawing an already-submitted (Pending) request —
  /// same shape as [confirmLogout], the app's existing destructive-action
  /// confirmation.
  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        title: Text(
          l10n.leaveRequestWithdrawConfirmTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          l10n.leaveRequestWithdrawConfirmMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.leaveRequestWithdrawConfirmAction,
              style: TextStyle(color: colors.errorFg, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(leaveRequestsProvider.notifier).withdrawRequest(request.id);
    }
  }

  Future<void> _openAttachment(String attachmentUrl) async {
    final resolvedUrl = attachmentUrl.startsWith('http') ? attachmentUrl : '$apiBaseUrl$attachmentUrl';
    final uri = Uri.parse(resolvedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    AppStatus getStatusBadge(LeaveStatus status) {
      switch (status) {
        case LeaveStatus.approved:
          return AppStatus.success;
        case LeaveStatus.rejected:
          return AppStatus.error;
        case LeaveStatus.pending:
          return AppStatus.warning;
        case LeaveStatus.cancelled:
        case LeaveStatus.draft:
          return AppStatus.info;
      }
    }
    
    String translatedStatus = request.status.value; 
    
    final String rawLeaveType = request.leaveType;
    String displayLeaveType = rawLeaveType;
    if (rawLeaveType.toLowerCase() == 'annual') displayLeaveType = l10n.leaveTypeAnnual;
    if (rawLeaveType.toLowerCase() == 'sick') displayLeaveType = l10n.leaveTypeSick;
    if (rawLeaveType.toLowerCase() == 'unpaid') displayLeaveType = l10n.leaveTypeUnpaid;

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
          // There's no separate leave-detail screen — this card already
          // shows everything the API returns for a request. The one real
          // action available is opening the attachment, when present.
          onTap: request.attachmentUrl != null ? () => _openAttachment(request.attachmentUrl!) : null,
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
                        style: AppTypography.textBase(isArabic).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    StatusBadge(label: translatedStatus, status: getStatusBadge(request.status)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  '${AppDateFormat.dateFromApi(request.startDate, isArabic: isArabic)} — '
                  '${AppDateFormat.dateFromApi(request.endDate, isArabic: isArabic)} '
                  '(${request.daysRequested} Days)',
                  style: AppTypography.textSm(isArabic).copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                if (request.attachmentUrl != null) ...[
                  const SizedBox(height: AppSpacing.s3),
                  GestureDetector(
                    onTap: () => _openAttachment(request.attachmentUrl!),
                    child: Row(
                      children: [
                        Icon(Symbols.attach_file, size: 16, color: colors.brandPrimary),
                        const SizedBox(width: AppSpacing.s1),
                        Flexible(
                          child: Text(
                            Uri.parse(request.attachmentUrl!).pathSegments.isNotEmpty
                                ? Uri.parse(request.attachmentUrl!).pathSegments.last
                                : request.attachmentUrl!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textSm(isArabic).copyWith(
                              color: colors.brandPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (request.status == LeaveStatus.rejected && request.hrNote != null) ...[
                  const SizedBox(height: AppSpacing.s3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: colors.bgCardRaised,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Text(
                      request.hrNote!,
                      style: AppTypography.textSm(isArabic).copyWith(color: colors.textPrimary),
                    ),
                  ),
                ],
                if (request.status == LeaveStatus.draft) ...[
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    l10n.leaveRequestDraftNotSentHint,
                    style: AppTypography.textXs(isArabic).copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtonStyles.primary(context),
                          onPressed: () {
                            ref.read(leaveRequestsProvider.notifier).submitDraft(request.id);
                          },
                          child: Text(l10n.leaveRequestSubmitButton, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtonStyles.secondary(context),
                          onPressed: () {
                            ref.read(leaveRequestsProvider.notifier).cancelDraft(request.id);
                          },
                          child: Text(l10n.cancel, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ],
                // Only a request HR hasn't acted on yet can be pulled back;
                // Approved/Rejected/Cancelled cards deliberately offer no
                // action here.
                if (request.status == LeaveStatus.pending) ...[
                  const SizedBox(height: AppSpacing.s4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.secondary(context),
                      onPressed: () => _confirmWithdraw(context, ref),
                      child: Text(l10n.leaveRequestWithdrawButton, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
