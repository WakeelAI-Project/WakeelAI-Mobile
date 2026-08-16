import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_api_client.dart';

final forgotPasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ForgotPasswordController, void>(
  ForgotPasswordController.new,
);

/// Drives the "forgot password" screen: calls
/// `POST /api/Auth/forgot-password`. An [AsyncData] state means the request
/// was accepted, not that the email was necessarily registered — the
/// backend intentionally doesn't distinguish the two to avoid account
/// enumeration.
class ForgotPasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authApiClientProvider).forgotPassword(email: email);
    });
  }
}
