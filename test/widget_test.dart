import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wakeel_ai_app/app.dart';
import 'package:wakeel_ai_app/core/providers/app_settings_providers.dart';
import 'package:wakeel_ai_app/core/storage/token_storage.dart';
import 'package:wakeel_ai_app/features/auth/data/auth_api_client.dart';
import 'package:wakeel_ai_app/features/auth/domain/auth_exceptions.dart';

/// Builds a well-formed (but unsigned) JWT string carrying [claims] in its
/// payload segment — LoginController decodes the real access token's `role`
/// claim to reject non-Employee accounts, so fake tokens need to look like a
/// real JWT for that check to see what the test intends.
String _fakeJwt(Map<String, dynamic> claims) {
  String segment(Object value) => base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment({
        'alg': 'none'
      })}.${segment(claims)}.signature';
}

final String _employeeAccessToken = _fakeJwt({'role': 'Employee'});
final String _firstLoginAccessToken = _fakeJwt({'role': 'Employee', 'sub': 'first-login'});
final String _hrAccessToken = _fakeJwt({'role': 'HR_Manager'});

class _FakeAuthApiClient implements AuthApiClient {
  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    // Small delay so tests can observe the loading state mid-flight, like a real request.
    await Future.delayed(const Duration(milliseconds: 50));
    if (email == 'employee@company.com' && password == 'correct-password') {
      return AuthTokens(
        accessToken: _employeeAccessToken,
        refreshToken: 'fake-refresh',
        mustChangePassword: false,
      );
    }
    if (email == 'newhire@company.com' && password == 'temp-password') {
      return AuthTokens(
        accessToken: _firstLoginAccessToken,
        refreshToken: 'fake-first-login-refresh',
        mustChangePassword: true,
      );
    }
    if (email == 'hr@company.com' && password == 'correct-password') {
      return AuthTokens(
        accessToken: _hrAccessToken,
        refreshToken: 'fake-hr-refresh',
        mustChangePassword: false,
      );
    }
    throw const LoginFailure(LoginFailureReason.invalidCredentials);
  }

  @override
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (accessToken != _firstLoginAccessToken || currentPassword != 'temp-password') {
      throw const ChangePasswordFailure(ChangePasswordFailureReason.invalidCurrentPassword);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (otp != '123456') {
      throw const VerifyOtpFailure(VerifyOtpFailureReason.invalidOtp);
    }
  }

  @override
  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (otp != '123456') {
      throw const ResetPasswordFailure(ResetPasswordFailureReason.invalidOtp);
    }
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
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wakeel AI'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
  });

  testWidgets('Invalid credentials show an inline error after submit', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
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
          sharedPreferencesProvider.overrideWithValue(prefs),
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
    expect(await tokenStorage.readAccessToken(), _employeeAccessToken);
    expect(await tokenStorage.readRefreshToken(), 'fake-refresh');
  });

  testWidgets('An HR/Owner account is rejected without persisting tokens', (WidgetTester tester) async {
    final tokenStorage = _FakeTokenStorage();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'hr@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'correct-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('employees only'), findsOneWidget);
    expect(await tokenStorage.readAccessToken(), isNull);
    expect(await tokenStorage.readRefreshToken(), isNull);
  });

  testWidgets('First-login employee is routed to change-password without persisting tokens', (
    WidgetTester tester,
  ) async {
    final tokenStorage = _FakeTokenStorage();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'newhire@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'temp-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Set your password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
    expect(await tokenStorage.readAccessToken(), isNull);
    expect(await tokenStorage.readRefreshToken(), isNull);
  });

  testWidgets(
    'Completing the forced password change discards tokens and returns to login with a success message',
    (WidgetTester tester) async {
      final tokenStorage = _FakeTokenStorage();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
            tokenStorageProvider.overrideWithValue(tokenStorage),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const WakeelApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'newhire@company.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'temp-password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Current password'), 'temp-password');
      await tester.enterText(find.widgetWithText(TextFormField, 'New password'), 'new-strong-password');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm new password'),
        'new-strong-password',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Set password'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.textContaining('Password changed'), findsOneWidget);
      expect(await tokenStorage.readAccessToken(), isNull);
      expect(await tokenStorage.readRefreshToken(), isNull);
    },
  );

  testWidgets('Wrong current password on the change-password screen shows an inline error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiClientProvider.overrideWithValue(_FakeAuthApiClient()),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const WakeelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'newhire@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'temp-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Current password'), 'wrong-temp-password');
    await tester.enterText(find.widgetWithText(TextFormField, 'New password'), 'new-strong-password');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm new password'),
      'new-strong-password',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set password'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Set your password'), findsOneWidget);
    expect(find.textContaining('temporary password is no longer valid'), findsOneWidget);
  });
}
