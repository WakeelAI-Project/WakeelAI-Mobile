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
