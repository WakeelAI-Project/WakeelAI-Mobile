import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/network/dio_client.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? fakeAccessToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}

  @override
  Future<String?> readAccessToken() async => fakeAccessToken;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> clearTokens() async {}
}

void main() {
  group('request timeouts', () {
    test('the default budget covers a cold backend rather than failing at 10s', () {
      // A sleeping MonsterASP.NET/Render host regularly needs more than ten
      // seconds to answer its first request; anything under that made the
      // app look dead on launch.
      expect(apiRequestTimeout, const Duration(seconds: 30));
      expect(apiRequestTimeout.inSeconds, greaterThan(10));
    });

    test('the slow-request hint fires well before the request gives up', () {
      expect(slowRequestHintDelay, lessThan(apiRequestTimeout));
    });
  });

  group('AuthInterceptor', () {
    late FakeTokenStorage tokenStorage;
    late AuthInterceptor interceptor;

    setUp(() {
      tokenStorage = FakeTokenStorage();
      interceptor = AuthInterceptor(tokenStorage, Dio(), (reason) async {});
    });

    test('should add Authorization header if token exists', () async {
      tokenStorage.fakeAccessToken = 'fake_jwt_token';
      
      // A dummy handler just to capture the state after onRequest
      bool nextCalled = false;
      
      // In Dio 5.x, you can't easily mock RequestInterceptorHandler without a mocking library,
      // but we can just use a real Dio instance and a custom interceptor to catch the result.
      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, handler) {
            expect(opts.headers['Authorization'], 'Bearer fake_jwt_token');
            nextCalled = true;
            handler.resolve(Response(requestOptions: opts, statusCode: 200));
          },
        ),
      );

      await dio.get('/foo');
      expect(nextCalled, isTrue);
    });

    test('should NOT add Authorization header if token is null', () async {
      tokenStorage.fakeAccessToken = null;
      
      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, handler) {
            expect(opts.headers.containsKey('Authorization'), isFalse);
            handler.resolve(Response(requestOptions: opts, statusCode: 200));
          },
        ),
      );

      await dio.get('/foo');
    });
    
    test('should NOT add Authorization header if token is empty', () async {
      tokenStorage.fakeAccessToken = '';
      
      final dio = Dio();
      dio.interceptors.add(interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, handler) {
            expect(opts.headers.containsKey('Authorization'), isFalse);
            handler.resolve(Response(requestOptions: opts, statusCode: 200));
          },
        ),
      );

      await dio.get('/foo');
    });
  });
}
