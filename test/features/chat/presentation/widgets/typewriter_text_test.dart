import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/chat/presentation/widgets/typewriter_text.dart';

void main() {
  Future<void> pumpTypewriterText(WidgetTester tester, String text) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: Scaffold(
          body: TypewriterText(text: text),
        ),
      ),
    );
  }

  testWidgets('renders block LaTeX (\\[...\\]) as typeset math, not raw source', (tester) async {
    const text = r'بما أن عدد السنوات = 0، فإن:'
        '\n\n'
        r'\[ \text{مكافأة النهاية} = 0.5 \times 20{,}000 = \mathbf{0} \text{ جنيه} \]';

    await pumpTypewriterText(tester, text);
    await tester.pumpAndSettle();

    expect(find.byType(Math), findsOneWidget);
    expect(find.textContaining(r'\text'), findsNothing);
    expect(find.textContaining(r'\times'), findsNothing);
  });

  testWidgets('renders inline LaTeX (\\(...\\)) inside a sentence as typeset math', (tester) async {
    const text = r'الناتج هو \(0.5 \times 20{,}000\) جنيه.';

    await pumpTypewriterText(tester, text);
    await tester.pumpAndSettle();

    expect(find.byType(Math), findsOneWidget);
    expect(find.textContaining(r'\times'), findsNothing);
  });

  testWidgets('does not misparse a plain dollar amount as math', (tester) async {
    const text = r'The fee is $100 and the deposit is $200.';

    await pumpTypewriterText(tester, text);
    await tester.pumpAndSettle();

    expect(find.byType(Math), findsNothing);
    expect(find.textContaining(r'$100'), findsOneWidget);
  });
}
