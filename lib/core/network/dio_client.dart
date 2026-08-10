import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wakeel_ai_app/core/storage/token_storage.dart';
import 'package:wakeel_ai_app/features/auth/application/auth_state_provider.dart';

/// Base URL for the backend API (wakeel-ai-api-documentation.md §Overview).
///
/// Override at build/run time with `--dart-define=API_BASE_URL=...` to
/// point at a locally-run backend during development.
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://wakeel-ai-api.runasp.net',
);

/// Interceptor to attach the JWT access token and handle 401/403 errors.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokenStorage, this._dioForRefresh, this._onForceLogout);

  final TokenStorage _tokenStorage;
  final Dio _dioForRefresh;
  final Future<void> Function() _onForceLogout;

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
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        return handler.next(err);
      }

      try {
        final response = await _dioForRefresh.post<Map<String, dynamic>>(
          '/api/Auth/refresh',
          data: {'refresh_token': refreshToken},
        );
        
        final data = response.data;
        final newAccessToken = data?['access_token'] as String?;
        if (newAccessToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await _dioForRefresh.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } else {
          await _forceLogout();
          return handler.next(err);
        }
      } catch (e) {
        await _forceLogout();
        return handler.next(err);
      }
    } else if (err.response?.statusCode == 403) {
      final data = err.response?.data;
      if (data is Map && data['error'] == 'account_inactive') {
        await _forceLogout();
      }
      return handler.next(err);
    }
    
    return handler.next(err);
  }

  Future<void> _forceLogout() async {
    await _onForceLogout();
  }
}

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final dioForRefresh = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(AuthInterceptor(
    ref.watch(tokenStorageProvider), 
    dioForRefresh, 
    () => ref.read(authProvider.notifier).logout(),
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
