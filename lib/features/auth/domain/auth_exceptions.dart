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
