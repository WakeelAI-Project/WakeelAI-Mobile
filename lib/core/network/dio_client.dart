import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wakeel_ai_app/core/navigation/session_expired_dialog.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';
import 'package:wakeel_ai_app/features/auth/application/auth_state_provider.dart';

/// Base URL for the backend API (wakeel-ai-api-documentation.md §Overview).
///
/// Override at build/run time with `--dart-define=API_BASE_URL=...` to
/// point at a locally-run backend during development.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://wakeel-ai-api.runasp.net',
);

/// Why [AuthInterceptor] forced a logout, so the caller can react
/// differently — e.g. only a genuinely expired session should interrupt the
/// user with an explanatory dialog before redirecting to `/login`.
enum ForceLogoutReason { sessionExpired, accountInactive }

/// Interceptor to attach the JWT access token and handle 401/403 errors.
///
/// The backend rotates refresh tokens on every use (each `/api/Auth/refresh`
/// call revokes the presented refresh token and issues a new one alongside
/// the new access token), so both values returned by a refresh must always
/// be persisted together — saving only the new access token leaves a
/// revoked refresh token in storage, which fails the *next* refresh and
/// forces an unnecessary logout.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokenStorage, this._dioForRefresh, this._onForceLogout);

  final TokenStorage _tokenStorage;
  final Dio _dioForRefresh;
  final Future<void> Function(ForceLogoutReason reason) _onForceLogout;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && err.requestOptions.headers.containsKey('Authorization')) {
      // A 401 with no Authorization header attached in the first place (e.g.
      // `/api/Auth/login` rejecting wrong credentials) has nothing to do
      // with an expired session — there was no session on this request to
      // begin with. Let it fall straight through to the caller's own error
      // handling (e.g. LoginController's "invalid_credentials" mapping)
      // instead of treating it as a refresh-worthy auth failure.

      // Onward requests are handled one 401 at a time (QueuedInterceptor),
      // so if a sibling request's 401 was already refreshed just before
      // this one ran, storage will hold a newer access token than the one
      // this request was sent with — reuse it instead of burning another
      // /api/Auth/refresh call.
      final failedAuthHeader = err.requestOptions.headers['Authorization'] as String?;
      final currentAccessToken = await _tokenStorage.readAccessToken();
      if (currentAccessToken != null &&
          currentAccessToken.isNotEmpty &&
          'Bearer $currentAccessToken' != failedAuthHeader) {
        final retried = await _retryWithToken(err.requestOptions, currentAccessToken);
        if (retried != null) return handler.resolve(retried);
        // The "fresher" token didn't work either — fall through to a real refresh.
      }

      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _onForceLogout(ForceLogoutReason.sessionExpired);
        return handler.next(err);
      }

      try {
        final response = await _dioForRefresh.post<Map<String, dynamic>>(
          '/api/Auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final data = response.data;
        final newAccessToken = data?['access_token'] as String?;
        final newRefreshToken = data?['refresh_token'] as String?;

        if (newAccessToken != null &&
            newAccessToken.isNotEmpty &&
            newRefreshToken != null &&
            newRefreshToken.isNotEmpty) {
          await _tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          final retried = await _retryWithToken(err.requestOptions, newAccessToken);
          if (retried != null) return handler.resolve(retried);
          return handler.next(err);
        } else {
          await _onForceLogout(ForceLogoutReason.sessionExpired);
          return handler.next(err);
        }
      } on DioException catch (refreshError) {
        if (_isNetworkError(refreshError)) {
          // Couldn't even reach the refresh endpoint — this says nothing
          // about whether the session is actually still valid, so preserve
          // it and let the original error surface as retryable instead of
          // logging the user out over a connectivity blip.
          return handler.next(err);
        }
        // A genuine rejection from the refresh endpoint (expired/invalid
        // refresh token) — the session really is over.
        await _onForceLogout(ForceLogoutReason.sessionExpired);
        return handler.next(err);
      } catch (e) {
        await _onForceLogout(ForceLogoutReason.sessionExpired);
        return handler.next(err);
      }
    } else if (err.response?.statusCode == 403) {
      final data = err.response?.data;
      if (data is Map && data['error'] == 'account_inactive') {
        await _onForceLogout(ForceLogoutReason.accountInactive);
      }
      return handler.next(err);
    }

    return handler.next(err);
  }

  /// Retries [options] with [accessToken] attached. Returns `null` (instead
  /// of throwing) on failure so callers can decide how to fall back.
  Future<Response<dynamic>?> _retryWithToken(RequestOptions options, String accessToken) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    try {
      return await _dioForRefresh.fetch(options);
    } on DioException {
      return null;
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }
}

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final dioForRefresh = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(AuthInterceptor(
    ref.watch(tokenStorageProvider),
    dioForRefresh,
    (reason) async {
      // Only a genuinely expired session interrupts the user with a
      // dialog — account-deactivation is a different (and today, silent)
      // story handled entirely server-side via subsequent login attempts.
      if (reason == ForceLogoutReason.sessionExpired) {
        await showSessionExpiredDialog();
      }
      await ref.read(authProvider.notifier).logout();
    },
  ));

  // Trust the ASP.NET dev-cert's self-signed HTTPS certificate when pointed
  // at a local backend during development. Never applies to release builds.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ));

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) =>
            host == '10.0.2.2' || host == 'localhost' || host == '127.0.0.1';
        return client;
      };
    }
  }

  return dio;
});
