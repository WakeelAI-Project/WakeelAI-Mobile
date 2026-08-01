import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_api_client.dart';
import 'auth_state_provider.dart';

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
      await ref.read(tokenStorageProvider).saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
      ref.read(authProvider.notifier).setAuthenticated();
    });
  }
}
