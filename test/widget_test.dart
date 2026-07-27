import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wakeel_ai_app/app.dart';

void main() {
  testWidgets('App boots and shows the design-system showcase', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WakeelApp()));
    await tester.pumpAndSettle();

    expect(find.text('Wakeel AI'), findsOneWidget);
    expect(find.text('Design System'), findsOneWidget);
  });
}
