import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/network/dio_client.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';

class _FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {}
}

class _FakeRequestHandler extends RequestInterceptorHandler {
  // Capture the options passed to next()
  RequestOptions? options;

  @override
  void next(RequestOptions options) {
    this.options = options;
    super.next(options);
  }
}

void main() {
  group('AuthInterceptor', () {
    test('attaches Authorization header when token is present', () async {
      // Arrange
      final fakeStorage = _FakeTokenStorage()..accessToken = 'fake-jwt-token';
      final interceptor = AuthInterceptor(fakeStorage, Dio(), (reason) async {});
      
      final options = RequestOptions(path: '/test-endpoint');
      final handler = _FakeRequestHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      expect(handler.options?.headers['Authorization'], 'Bearer fake-jwt-token');
    });

    test('does not attach Authorization header when token is null', () async {
      // Arrange
      final fakeStorage = _FakeTokenStorage()..accessToken = null;
      final interceptor = AuthInterceptor(fakeStorage, Dio(), (reason) async {});
      
      final options = RequestOptions(path: '/test-endpoint');
      final handler = _FakeRequestHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      expect(handler.options?.headers.containsKey('Authorization'), isFalse);
    });

    test('does not attach Authorization header when token is empty', () async {
      // Arrange
      final fakeStorage = _FakeTokenStorage()..accessToken = '';
      final interceptor = AuthInterceptor(fakeStorage, Dio(), (reason) async {});
      
      final options = RequestOptions(path: '/test-endpoint');
      final handler = _FakeRequestHandler();

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      expect(handler.options?.headers.containsKey('Authorization'), isFalse);
    });
  });
}
