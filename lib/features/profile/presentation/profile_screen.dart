import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/logout_confirmation.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/employee_provider.dart';
import 'widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
  }

  static String _formatHireDate(String isoDate, bool isArabic) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(parsed);
  }

  static String _formatSalary(int salary, bool isArabic) {
    return NumberFormat.currency(
      locale: isArabic ? 'ar' : 'en',
      symbol: 'EGP ',
      decimalDigits: 0,
    ).format(salary);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final profileAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          l10n.profileTitle,
          style: AppTypography.textXl(isArabic).copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => ListView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            children: [
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      photoUrl: profile.photoUrl,
                      initials: _getInitials(profile.fullName),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      profile.fullName,
                      style: AppTypography.text2xl(isArabic).copyWith(color: colors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      profile.jobTitle,
                      style: AppTypography.textBase(isArabic).copyWith(color: colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s1),
                      decoration: BoxDecoration(
                        color: colors.bgCardRaised,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.apartment, size: 16, color: colors.textSecondary),
                          const SizedBox(width: AppSpacing.s1),
                          Text(
                            profile.department,
                            style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Container(
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: AppRadius.lgRadius,
                  boxShadow: shadows.md,
                  border: shadows.md.isEmpty ? Border.all(color: colors.borderDefault) : null,
                ),
                child: Column(
                  children: [
                    _ProfileDetailRow(
                      icon: Symbols.mail,
                      label: l10n.profileEmailLabel,
                      value: profile.email,
                      isArabic: isArabic,
                    ),
                    Divider(height: 1, color: colors.borderDefault),
                    _ProfileDetailRow(
                      icon: Symbols.calendar_month,
                      label: l10n.profileHireDateLabel,
                      value: _formatHireDate(profile.hireDate, isArabic),
                      isArabic: isArabic,
                    ),
                    Divider(height: 1, color: colors.borderDefault),
                    _ProfileDetailRow(
                      icon: Symbols.payments,
                      label: l10n.profileSalaryLabel,
                      value: _formatSalary(profile.salary, isArabic),
                      isArabic: isArabic,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              ElevatedButton(
                style: AppButtonStyles.danger(context),
                onPressed: () => confirmLogout(context, ref),
                child: Text(l10n.logout),
              ),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
          loading: () => const _ProfileSkeleton(),
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.error, size: 48, color: colors.errorFg),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    l10n.profileFailedToLoad,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
                  ),
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        e.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.errorFg),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s4),
                  ElevatedButton(
                    style: AppButtonStyles.secondary(context),
                    onPressed: () => ref.invalidate(employeeProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isArabic,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              label,
              style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textBase(isArabic).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: colors.borderDefault, shape: BoxShape.circle),
              ),
              const SizedBox(height: AppSpacing.s3),
              Container(width: 160, height: 24, color: colors.borderDefault),
              const SizedBox(height: AppSpacing.s2),
              Container(width: 100, height: 16, color: colors.borderDefault),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          height: 180,
          decoration: BoxDecoration(color: colors.borderDefault, borderRadius: AppRadius.lgRadius),
        ),
      ],
    );
  }
}
