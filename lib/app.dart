import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_settings_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/updates/update_available_dialog.dart';
import 'core/updates/update_provider.dart';
import 'l10n/app_localizations.dart';

class WakeelApp extends ConsumerWidget {
  const WakeelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final highContrast = ref.watch(highContrastProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    // Best-effort, once per cold start: silently does nothing if the check
    // fails, the app is already current, or this version was dismissed.
    ref.listen<AsyncValue<int?>>(updateAvailableVersionCodeProvider, (previous, next) {
      final versionCode = next.valueOrNull;
      if (versionCode != null) showUpdateAvailableDialog(ref, versionCode);
    });

    return MaterialApp.router(
      title: 'Wakeel AI',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      themeMode: themeMode,
      theme: AppTheme.build(brightness: Brightness.light, highContrast: highContrast, isArabic: isArabic),
      darkTheme: AppTheme.build(brightness: Brightness.dark, highContrast: highContrast, isArabic: isArabic),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
