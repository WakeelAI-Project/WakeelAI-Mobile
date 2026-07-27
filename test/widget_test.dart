import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wakeel_ai_app/app.dart';

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
    await tester.pumpWidget(const ProviderScope(child: WakeelApp()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'employee@company.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));

    // Loading state appears immediately after submit.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // The stub submit rejects every attempt for now (see LoginController).
    await tester.pumpAndSettle();
    expect(find.textContaining('Invalid email or password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
