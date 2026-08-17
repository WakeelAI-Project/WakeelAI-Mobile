import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_api_client.dart';

final verifyOtpControllerProvider = AsyncNotifierProvider.autoDispose<VerifyOtpController, void>(
  VerifyOtpController.new,
);

/// Drives the standalone "enter code" screen: calls
/// `POST /api/Auth/verify-otp` to confirm the code before the user is asked
/// for a new password.
class VerifyOtpController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String otp}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authApiClientProvider).verifyOtp(email: email, otp: otp);
    });
  }
}
