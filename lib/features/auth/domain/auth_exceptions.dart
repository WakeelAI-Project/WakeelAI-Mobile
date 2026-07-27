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
