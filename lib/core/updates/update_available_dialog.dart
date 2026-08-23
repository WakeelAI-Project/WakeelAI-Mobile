import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../navigation/navigator_key.dart';
import 'update_checker_service.dart';
import 'update_provider.dart';

/// Shows a dismissible "a new version is available" dialog over whatever
/// screen the user is currently on. Downloading opens [updateDownloadUrl]
/// (the public GitHub Release link) in the browser — this app has no way to
/// silently self-update outside the Play Store, so the user re-installs by
/// hand. Dismissing records [versionCode] via [dismissUpdate] so this exact
/// version doesn't prompt again on the next app start.
Future<void> showUpdateAvailableDialog(WidgetRef ref, int versionCode) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    debugPrint('showUpdateAvailableDialog: rootNavigatorKey has no attached context yet, skipping.');
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).extension<AppColors>()!;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      title: Text(
        l10n.updateAvailableTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary),
      ),
      content: Text(
        l10n.updateAvailableMessage,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () {
            dismissUpdate(ref, versionCode);
            Navigator.of(ctx).pop();
          },
          child: Text(l10n.updateAvailableLater),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            launchUrl(Uri.parse(updateDownloadUrl), mode: LaunchMode.externalApplication);
          },
          child: Text(l10n.updateAvailableDownload),
        ),
      ],
    ),
  );
}
