import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/providers/app_settings_providers.dart';
import '../../core/theme/app_button_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/ai_badge.dart';
import '../../core/widgets/seal_mark.dart';
import '../../core/widgets/status_badge.dart';
import '../../l10n/app_localizations.dart';

/// Internal screen exercising every design-system token end to end.
///
/// This is scaffolding, not a real product screen — it exists so the
/// theme can be verified visually before real feature screens are built
/// on top of it (auth, chat, dashboard, ...).
class ThemeShowcaseScreen extends ConsumerWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final t = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final themeMode = ref.watch(themeModeProvider);
    final highContrast = ref.watch(highContrastProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(colors: colors, appName: t.appName, tagline: t.appTagline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s6),
                children: [
                  _SectionTitle(t.themeShowcaseTitle),
                  const SizedBox(height: AppSpacing.s4),
                  Wrap(
                    spacing: AppSpacing.s3,
                    runSpacing: AppSpacing.s3,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => ref.read(themeModeProvider.notifier).state = switch (themeMode) {
                          ThemeMode.light => ThemeMode.dark,
                          ThemeMode.dark => ThemeMode.system,
                          ThemeMode.system => ThemeMode.light,
                        },
                        icon: Icon(switch (themeMode) {
                          ThemeMode.light => LucideIcons.sun,
                          ThemeMode.dark => LucideIcons.moon,
                          ThemeMode.system => LucideIcons.monitor,
                        }, size: 20),
                        label: Text(t.toggleThemeMode),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => ref.read(localeProvider.notifier).state =
                            isArabic ? const Locale('en') : const Locale('ar'),
                        icon: const Icon(LucideIcons.languages, size: 20),
                        label: Text(t.toggleLanguage),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: highContrast,
                            onChanged: (v) => ref.read(highContrastProvider.notifier).state = v,
                          ),
                          const SizedBox(width: AppSpacing.s2),
                          Text(t.toggleContrast),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Typography'),
                  const SizedBox(height: AppSpacing.s3),
                  Text('Text 3XL — Page title', style: AppTypography.text3xl(isArabic)),
                  Text('Text 2XL — Section header', style: AppTypography.text2xl(isArabic)),
                  Text('Text XL — Card title', style: AppTypography.textXl(isArabic)),
                  Text('Text LG — Emphasized body', style: AppTypography.textLg(isArabic)),
                  Text('Text Base — Default body', style: AppTypography.textBase(isArabic)),
                  Text('Text SM — UI labels, table cells', style: AppTypography.textSm(isArabic)),
                  Text('Text XS — Meta, captions, badges', style: AppTypography.textXs(isArabic)),
                  Text('EGP 24,383.00 · 2026-07-27', style: AppTypography.mono(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Buttons'),
                  const SizedBox(height: AppSpacing.s3),
                  Wrap(
                    spacing: AppSpacing.s3,
                    runSpacing: AppSpacing.s3,
                    children: [
                      ElevatedButton(style: AppButtonStyles.primary(context), onPressed: () {}, child: const Text('Primary')),
                      ElevatedButton(style: AppButtonStyles.secondary(context), onPressed: () {}, child: const Text('Secondary')),
                      ElevatedButton(style: AppButtonStyles.aiAccent(context), onPressed: () {}, child: const Text('AI-accent')),
                      ElevatedButton(style: AppButtonStyles.ghost(context), onPressed: () {}, child: const Text('Ghost')),
                      ElevatedButton(style: AppButtonStyles.danger(context), onPressed: () {}, child: const Text('Danger')),
                      const ElevatedButton(onPressed: null, child: Text('Disabled')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Inputs'),
                  const SizedBox(height: AppSpacing.s3),
                  const TextField(decoration: InputDecoration(labelText: 'Employee name', hintText: 'e.g. Ahmed Mostafa')),
                  const SizedBox(height: AppSpacing.s3),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Monthly salary',
                      errorText: 'Salary must be greater than zero',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Badges'),
                  const SizedBox(height: AppSpacing.s3),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      const StatusBadge(label: 'Approved', status: AppStatus.success),
                      const StatusBadge(label: 'Pending', status: AppStatus.warning),
                      const StatusBadge(label: 'Rejected', status: AppStatus.error),
                      const StatusBadge(label: 'Info', status: AppStatus.info),
                      AiBadge(label: t.aiGeneratedLabel),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Citation marker (seal)'),
                  const SizedBox(height: AppSpacing.s3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SealMark.citation(),
                      const SizedBox(width: AppSpacing.s2),
                      Flexible(
                        child: Text(
                          t.citationExample,
                          style: AppTypography.textSm(isArabic).copyWith(color: colors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  _SectionTitle('Card / elevation'),
                  const SizedBox(height: AppSpacing.s3),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: AppRadius.lgRadius,
                      boxShadow: shadows.md,
                      border: shadows.md.isEmpty ? Border.all(color: colors.borderDefault) : null,
                    ),
                    child: Text('This is a card surface using --shadow-md.', style: AppTypography.textBase(isArabic)),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors, required this.appName, required this.tagline});

  final AppColors colors;
  final String appName;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: colors.bgSidebar,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s4),
      child: Row(
        children: [
          const SealMark.logomark(),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.textOnNavy)),
                Text(tagline, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textOnNavy.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}
