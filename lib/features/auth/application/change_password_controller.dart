import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_api_client.dart';
import 'pending_password_change_provider.dart';

final changePasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ChangePasswordController, void>(
  ChangePasswordController.new,
);

/// Drives the forced "set your password" screen: calls
/// `POST /api/account/change-password` with the temp access token from the
/// first login, then discards it entirely — the employee must log in again
/// with the new password to get a real session.
class ChangePasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String currentPassword, required String newPassword}) async {
    final pending = ref.read(pendingPasswordChangeProvider);
    if (pending == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authApiClientProvider).changePassword(
            accessToken: pending.accessToken,
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      ref.read(pendingPasswordChangeProvider.notifier).state = null;
      ref.read(passwordJustChangedProvider.notifier).state = true;
    });
  }
}
