import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wakeel_ai_app/app.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';
import 'package:wakeel_ai_app/features/auth/data/auth_api_client.dart';
import 'package:wakeel_ai_app/features/auth/domain/auth_exceptions.dart';

class _FakeAuthApiClient implements AuthApiClient {
  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    // Small delay so tests can observe the loading state mid-flight, like a real request.
    await Future.delayed(const Duration(milliseconds: 50));
    if (email == 'employee@company.com' && password == 'correct-password') {
      return const AuthTokens(accessToken: 'fake-access', refreshToken: 'fake-refresh');
    }
    throw const LoginFailure(LoginFailureReason.invalidCredentials);
  }
}

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

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WakeelApp()));
    await tester.pumpAndSettle();

    expect(find.text('Wakeel AI'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
  });

  testWidgets('Invalid credentials show an inline error after submit', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiClientProvider.overrideWithValue(_FakeAuthApiClient())],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'employee@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.textContaining('Invalid email or password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Valid credentials store the returned tokens', (WidgetTester tester) async {
    final tokenStorage = _FakeTokenStorage();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'employee@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'correct-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await tokenStorage.readAccessToken(), 'fake-access');
    expect(await tokenStorage.readRefreshToken(), 'fake-refresh');
  });
}
