import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_api_client.dart';
import 'auth_state_provider.dart';
import 'pending_password_change_provider.dart';

final loginControllerProvider = AsyncNotifierProvider.autoDispose<LoginController, void>(
  LoginController.new,
);

/// Drives the login screen's idle/loading/error states: calls
/// `POST /auth/login` and persists the returned access + refresh tokens.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final tokens = await ref.read(authApiClientProvider).login(email: email, password: password);

      if (tokens.mustChangePassword) {
        // Don't persist these tokens or mark the session authenticated —
        // the temp-password session ends the moment the new password is
        // set (see ChangePasswordController). The router redirects to
        // /change-password whenever this is non-null.
        ref.read(pendingPasswordChangeProvider.notifier).state = PendingPasswordChange(
          accessToken: tokens.accessToken,
        );
        return;
      }

      await ref.read(tokenStorageProvider).saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
      ref.read(authProvider.notifier).setAuthenticated();
    });
  }
}
