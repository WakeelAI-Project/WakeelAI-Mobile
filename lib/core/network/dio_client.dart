import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wakeel_ai_app/core/storage/token_storage.dart';

/// Base URL for the backend API (wakeel-ai-api-documentation.md §Overview).
///
/// Override at build/run time with `--dart-define=API_BASE_URL=...` to
/// point at a locally-run backend during development.
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://wakeel-ai-api.runasp.net',
);

/// Interceptor to attach the JWT access token to every outgoing API request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
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

  dio.interceptors.add(AuthInterceptor(ref.watch(tokenStorageProvider)));

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
