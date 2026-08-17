import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'navigator_key.dart';

/// Shows a blocking "your session has expired" dialog over whatever screen
/// the user is currently on, then resolves once dismissed.
///
/// Called from the Dio auth interceptor, which has no [BuildContext] of its
/// own — hence going through [rootNavigatorKey] — so the forced logout
/// (and the router's resulting redirect to `/login`) only happens *after*
/// the user acknowledges, instead of silently dropping them on the login
/// screen with no explanation.
Future<void> showSessionExpiredDialog() async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).extension<AppColors>()!;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      title: Text(
        l10n.sessionExpiredTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary),
      ),
      content: Text(
        l10n.sessionExpiredMessage,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.sessionExpiredOk),
        ),
      ],
    ),
  );
}
