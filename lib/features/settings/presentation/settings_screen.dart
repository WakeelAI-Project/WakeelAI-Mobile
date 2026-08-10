import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_settings_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_motion.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n, AppColors colors) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        title: Text(l10n.logoutConfirmationTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary)),
        content: Text(l10n.logoutConfirmationDesc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout, style: TextStyle(color: colors.errorFg, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final currentThemeMode = ref.watch(themeModeProvider);
    final isHighContrast = ref.watch(highContrastProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
          children: [
            // Header
            Text(
              l10n.settingsTitle,
              style: AppTypography.text3xl(isArabic).copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s8),

            // Language Section
            Text(
              l10n.settingsLanguage,
              style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s2),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCardRaised,
                borderRadius: AppRadius.mdRadius,
              ),
              padding: const EdgeInsets.all(AppSpacing.s1),
              child: Row(
                children: [
                  Expanded(
                    child: _LanguageSegment(
                      title: 'EN',
                      isActive: !isArabic,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                      },
                    ),
                  ),
                  Expanded(
                    child: _LanguageSegment(
                      title: 'العربية',
                      isActive: isArabic,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),

            // Theme Section
            Text(
              l10n.settingsTheme,
              style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s2),
            _ThemeOptionCard(
              title: l10n.themeLight,
              isSelected: currentThemeMode == ThemeMode.light && !isHighContrast,
              onTap: () {
                ref.read(highContrastProvider.notifier).setHighContrast(false);
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              },
            ),
            const SizedBox(height: AppSpacing.s2),
            _ThemeOptionCard(
              title: l10n.themeDark,
              isSelected: currentThemeMode == ThemeMode.dark && !isHighContrast,
              onTap: () {
                ref.read(highContrastProvider.notifier).setHighContrast(false);
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              },
            ),
            const SizedBox(height: AppSpacing.s2),
            _ThemeOptionCard(
              title: l10n.themeHighContrast,
              isSelected: isHighContrast,
              onTap: () {
                ref.read(highContrastProvider.notifier).setHighContrast(true);
                // Usually high contrast implies a dark theme in some systems, but here it's an orthogonal toggle.
                // We'll set it to dark base + high contrast, or just enable high contrast flag.
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              },
            ),
            const SizedBox(height: AppSpacing.s12),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.danger(context),
                onPressed: () => _confirmLogout(context, ref, l10n, colors),
                child: Text(l10n.logout),
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
          ],
        ),
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageSegment({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.fastCurve,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
        decoration: BoxDecoration(
          color: isActive ? colors.bgCard : Colors.transparent,
          borderRadius: AppRadius.smRadius,
          boxShadow: isActive ? shadows.sm : [],
          border: isActive && shadows.sm.isEmpty 
              ? Border.all(color: colors.borderDefault) 
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.textSm(isArabic).copyWith(
                color: isActive ? colors.textPrimary : colors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s4),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: AppRadius.lgRadius,
          boxShadow: shadows.sm,
          border: shadows.sm.isEmpty ? Border.all(color: colors.borderDefault) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary),
            ),
            AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.fastCurve,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.brandPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? colors.brandPrimary : colors.borderDefault,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: colors.onBrandPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
