import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/auth_exceptions.dart';

/// Access + refresh JWT pair returned by `POST /auth/login`.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.mustChangePassword,
  });
  final String accessToken;
  final String refreshToken;

  /// True when this employee has never changed their temp password. The
  /// backend still issues a fully valid [accessToken]/[refreshToken] pair —
  /// nothing is blocked server-side, so the app must redirect to the
  /// change-password screen itself instead of proceeding to `/home`.
  final bool mustChangePassword;
}

/// Abstract so widget/unit tests can supply a fake instead of hitting Dio.
abstract class AuthApiClient {
  Future<AuthTokens> login({required String email, required String password});

  /// `POST /api/account/change-password`. [accessToken] is passed explicitly
  /// (rather than read from [TokenStorage]) because the first-login token
  /// this is called with is never persisted to secure storage.
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });

  /// `POST /api/Auth/forgot-password`. Always resolves on a 200 — the
  /// backend intentionally returns the same generic response whether or not
  /// [email] is registered, so callers should show a generic "check your
  /// email" message regardless of outcome. Triggers a one-time 6-digit OTP
  /// emailed to [email], which [resetPassword] then consumes.
  Future<void> forgotPassword({required String email});

  /// `POST /api/Auth/reset-password`. Verifies [otp] (issued by
  /// [forgotPassword]) and, if valid, sets the account's password to
  /// [newPassword] in one step.
  Future<void> resetPassword({required String email, required String otp, required String newPassword});
}

class DioAuthApiClient implements AuthApiClient {
  DioAuthApiClient(this._dio);

  final Dio _dio;

  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/Auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final accessToken = data?['access_token'] as String?;
      final refreshToken = data?['refresh_token'] as String?;
      if (accessToken == null || refreshToken == null) {
        throw const LoginFailure(LoginFailureReason.unknown);
      }
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        mustChangePassword: data?['must_change_password'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw LoginFailure(_reasonFor(e));
    }
  }

  LoginFailureReason _reasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'invalid_credentials':
        return LoginFailureReason.invalidCredentials;
      case 'account_inactive':
        return LoginFailureReason.accountInactive;
      default:
        return LoginFailureReason.unknown;
    }
  }

  @override
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/api/account/change-password',
        data: {'current_password': currentPassword, 'new_password': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw ChangePasswordFailure(_changePasswordReasonFor(e));
    }
  }

  ChangePasswordFailureReason _changePasswordReasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'invalid_current_password':
        return ChangePasswordFailureReason.invalidCurrentPassword;
      case 'user_not_found':
        return ChangePasswordFailureReason.userNotFound;
      default:
        return ChangePasswordFailureReason.unknown;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post<void>(
        '/api/Auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ForgotPasswordFailure(_forgotPasswordReasonFor(e));
    }
  }

  ForgotPasswordFailureReason _forgotPasswordReasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'too_many_requests':
        return ForgotPasswordFailureReason.tooManyRequests;
      default:
        return ForgotPasswordFailureReason.unknown;
    }
  }

  @override
  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      await _dio.post<void>(
        '/api/Auth/reset-password',
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw ResetPasswordFailure(_resetPasswordReasonFor(e));
    }
  }

  ResetPasswordFailureReason _resetPasswordReasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'invalid_otp':
        return ResetPasswordFailureReason.invalidOtp;
      case 'otp_expired':
        return ResetPasswordFailureReason.otpExpired;
      case 'too_many_attempts':
        return ResetPasswordFailureReason.tooManyAttempts;
      case 'validation_error':
        return ResetPasswordFailureReason.validationError;
      default:
        return ResetPasswordFailureReason.unknown;
    }
  }
}

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return DioAuthApiClient(ref.watch(dioClientProvider));
});
