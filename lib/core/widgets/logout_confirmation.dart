import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_state_provider.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Shows the shared "are you sure you want to log out" dialog and, if
/// confirmed, runs the real logout flow (clears the stored token — the
/// router redirect to `/login` then follows from the resulting
/// [AuthState.unauthenticated] change).
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = Theme.of(context).extension<AppColors>()!;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      title: Text(
        l10n.logoutConfirmationTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.textPrimary),
      ),
      content: Text(
        l10n.logoutConfirmationDesc,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      ),
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
    await ref.read(authProvider.notifier).logout();
  }
}
