import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thrown when a login attempt is rejected.
class LoginFailure implements Exception {
  const LoginFailure();
}

final loginControllerProvider = AsyncNotifierProvider.autoDispose<LoginController, void>(
  LoginController.new,
);

/// Drives the login screen's idle/loading/error states.
///
/// TODO(auth-api): [_submit] is a stub — replace with a real call to the
/// backend login endpoint once it exists, and persist the returned JWT
/// (flutter_secure_storage) as part of that follow-up task. There is no
/// post-login destination screen yet, so a success path isn't wired here.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _submit(email, password));
  }

  Future<void> _submit(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900));
    throw const LoginFailure();
  }
}
