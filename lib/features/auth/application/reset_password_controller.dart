import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_api_client.dart';

final resetPasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(
  ResetPasswordController.new,
);

/// Drives the OTP + new-password screen: calls
/// `POST /api/Auth/reset-password` with the code emailed by
/// `POST /api/Auth/forgot-password`.
class ResetPasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String otp, required String newPassword}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authApiClientProvider).resetPassword(email: email, otp: otp, newPassword: newPassword);
    });
  }
}
