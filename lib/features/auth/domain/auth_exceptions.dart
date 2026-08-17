/// Error codes from `POST /auth/login` (wakeel-ai-api-documentation.md §2.2).
enum LoginFailureReason {
  /// 401 `{"error": "invalid_credentials"}` — wrong email/password.
  invalidCredentials,

  /// 403 `{"error": "account_inactive"}` — deactivated by Owner/HR.
  accountInactive,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when a login attempt is rejected.
class LoginFailure implements Exception {
  const LoginFailure(this.reason);
  final LoginFailureReason reason;
}

/// Error codes from `POST /api/account/change-password`.
enum ChangePasswordFailureReason {
  /// 400 `{"error": "invalid_current_password"}` — the supplied temp/current
  /// password doesn't match.
  invalidCurrentPassword,

  /// 404 `{"error": "user_not_found"}`.
  userNotFound,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when a change-password attempt is rejected.
class ChangePasswordFailure implements Exception {
  const ChangePasswordFailure(this.reason);
  final ChangePasswordFailureReason reason;
}

/// Error codes from `POST /api/Auth/forgot-password`.
enum ForgotPasswordFailureReason {
  /// 429 `{"error": "too_many_requests"}` — too many reset attempts for this
  /// email/IP in a short window.
  tooManyRequests,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when a forgot-password request fails outright. The backend always
/// returns 200 with the same generic body whether or not the email is
/// registered (to avoid account enumeration), so this is only ever a
/// genuine failure — never "email not found".
class ForgotPasswordFailure implements Exception {
  const ForgotPasswordFailure(this.reason);
  final ForgotPasswordFailureReason reason;
}

/// Error codes from `POST /api/Auth/verify-otp`.
enum VerifyOtpFailureReason {
  /// 400 `{"error": "invalid_otp"}` — same enumeration-safe semantics as
  /// [ResetPasswordFailureReason.invalidOtp].
  invalidOtp,

  /// 400 `{"error": "otp_expired"}`.
  otpExpired,

  /// 429 `{"error": "too_many_attempts"}` — the code has been invalidated;
  /// the user must request a new one via forgot-password.
  tooManyAttempts,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when standalone OTP verification (before the new-password step)
/// is rejected.
class VerifyOtpFailure implements Exception {
  const VerifyOtpFailure(this.reason);
  final VerifyOtpFailureReason reason;
}

/// Error codes from `POST /api/Auth/reset-password`.
enum ResetPasswordFailureReason {
  /// 400 `{"error": "invalid_otp"}` — the code doesn't match what was sent
  /// (or no code was ever issued for this email, which is deliberately
  /// indistinguishable from a wrong code to avoid account enumeration).
  invalidOtp,

  /// 400 `{"error": "otp_expired"}` — the code was correct but is past its
  /// validity window.
  otpExpired,

  /// 429 `{"error": "too_many_attempts"}` — too many wrong codes submitted
  /// for this email; the code has been invalidated and a new one is needed.
  tooManyAttempts,

  /// 400 `{"error": "validation_error"}` — the new password fails the
  /// backend's policy (this app also validates client-side first).
  validationError,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when an OTP-based password reset attempt is rejected.
class ResetPasswordFailure implements Exception {
  const ResetPasswordFailure(this.reason);
  final ResetPasswordFailureReason reason;
}
