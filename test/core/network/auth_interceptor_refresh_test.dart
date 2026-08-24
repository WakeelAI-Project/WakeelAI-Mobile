import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/network/dio_client.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';

class _FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

/// Captures what [AuthInterceptor.onError] does with the handler without
/// going through Dio's real completer-based pipeline.
class _FakeErrorHandler extends ErrorInterceptorHandler {
  Response<dynamic>? resolvedResponse;
  DioException? forwardedError;

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }

  @override
  void next(DioException err) {
    forwardedError = err;
  }
}

DioException _unauthorized(RequestOptions options) {
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 401),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('AuthInterceptor.onError — token refresh', () {
    test('passes a 401 straight through when the failed request never carried an Authorization '
        'header (e.g. wrong-credentials on /api/Auth/login)', () async {
      final storage = _FakeTokenStorage();
      var refreshCalled = false;
      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          refreshCalled = true;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      // No Authorization header at all — this is what a login attempt with
      // the wrong password looks like: a 401 unrelated to any session.
      final originalOptions = RequestOptions(path: '/api/Auth/login');
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      expect(refreshCalled, isFalse);
      expect(loggedOutReason, isNull);
      expect(handler.forwardedError, isNotNull);
      expect(handler.resolvedResponse, isNull);
    });

    test('persists both the new access token and new refresh token on a successful refresh', () async {
      final storage = _FakeTokenStorage()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';

      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/api/Auth/refresh') {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'access_token': 'new-access', 'refresh_token': 'new-refresh'},
            ));
          } else {
            handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'ok': true}));
          }
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer old-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      // The bug: this used to stay 'old-refresh', a token the backend had
      // already revoked by rotating it — breaking the *next* refresh.
      expect(storage.accessToken, 'new-access');
      expect(storage.refreshToken, 'new-refresh');
      expect(handler.resolvedResponse, isNotNull);
      expect(loggedOutReason, isNull);
    });

    test('retries with a fresher token already in storage instead of calling refresh again', () async {
      final storage = _FakeTokenStorage()
        ..accessToken = 'already-refreshed-access'
        ..refreshToken = 'already-refreshed-refresh';

      var refreshCallCount = 0;
      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/api/Auth/refresh') {
            refreshCallCount++;
          }
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'ok': true}));
        },
      ));

      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {});

      // Sent with a token storage has since moved past — simulates a sibling
      // 401 handler (queued ahead of this one) having already refreshed.
      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer stale-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      expect(refreshCallCount, 0);
      expect(handler.resolvedResponse, isNotNull);
      expect(originalOptions.headers['Authorization'], 'Bearer already-refreshed-access');
    });

    test('preserves the session when the refresh call fails due to a network error', () async {
      final storage = _FakeTokenStorage()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';

      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'offline',
          ));
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer old-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      expect(loggedOutReason, isNull);
      expect(storage.accessToken, 'old-access');
      expect(storage.refreshToken, 'old-refresh');
      expect(handler.forwardedError, isNotNull);
    });

    test('preserves the session when the refresh call times out (cold backend)', () async {
      final storage = _FakeTokenStorage()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';

      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ));
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer old-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      // A timeout says nothing about whether the session is still valid, so
      // it must surface as a retryable error rather than a forced logout.
      expect(loggedOutReason, isNull);
      expect(storage.refreshToken, 'old-refresh');
      expect(handler.forwardedError, isNotNull);
    });

    test('forces a session-expired logout when the refresh endpoint rejects the refresh token', () async {
      final storage = _FakeTokenStorage()
        ..accessToken = 'old-access'
        ..refreshToken = 'old-refresh';

      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'error': 'invalid_refresh_token'},
            ),
          ));
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer old-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      expect(loggedOutReason, ForceLogoutReason.sessionExpired);
    });

    test('forces a session-expired logout immediately when no refresh token is stored', () async {
      final storage = _FakeTokenStorage();
      var refreshCalled = false;
      final dioForRefresh = Dio();
      dioForRefresh.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          refreshCalled = true;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(
        path: '/some-endpoint',
        headers: {'Authorization': 'Bearer expired-access'},
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(_unauthorized(originalOptions), handler);

      expect(refreshCalled, isFalse);
      expect(loggedOutReason, ForceLogoutReason.sessionExpired);
    });

    test('forces an account-inactive logout on a 403 account_inactive response', () async {
      final storage = _FakeTokenStorage();
      final dioForRefresh = Dio();

      ForceLogoutReason? loggedOutReason;
      final interceptor = AuthInterceptor(storage, dioForRefresh, (reason) async {
        loggedOutReason = reason;
      });

      final originalOptions = RequestOptions(path: '/some-endpoint');
      final err = DioException(
        requestOptions: originalOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: originalOptions,
          statusCode: 403,
          data: {'error': 'account_inactive'},
        ),
      );
      final handler = _FakeErrorHandler();

      await interceptor.onError(err, handler);

      expect(loggedOutReason, ForceLogoutReason.accountInactive);
    });
  });
}
