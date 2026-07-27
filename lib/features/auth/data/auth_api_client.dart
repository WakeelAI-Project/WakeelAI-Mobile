import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/auth_exceptions.dart';

/// Access + refresh JWT pair returned by `POST /auth/login`.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Abstract so widget/unit tests can supply a fake instead of hitting Dio.
abstract class AuthApiClient {
  Future<AuthTokens> login({required String email, required String password});
}

class DioAuthApiClient implements AuthApiClient {
  DioAuthApiClient(this._dio);

  final Dio _dio;

  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final accessToken = data?['access_token'] as String?;
      final refreshToken = data?['refresh_token'] as String?;
      if (accessToken == null || refreshToken == null) {
        throw const LoginFailure(LoginFailureReason.unknown);
      }
      return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
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
}

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return DioAuthApiClient(ref.watch(dioClientProvider));
});
