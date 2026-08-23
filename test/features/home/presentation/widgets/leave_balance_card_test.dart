import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/home/domain/employee_profile.dart';
import 'package:wakeel_ai_app/features/home/presentation/widgets/leave_balance_card.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

/// FIX-01: totalDays == null must render as "Unlimited", never as 0, "null",
/// or a crash - and must stay clearly distinct from a genuine 0-day
/// entitlement ("Not available").
void main() {
  Widget wrap(LeaveBalance balance) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
      home: Scaffold(
        body: LeaveBalanceCard(leaveBalance: balance, onTap: () {}),
      ),
    );
  }

  testWidgets('uncapped balance (totalDays null) renders Unlimited, not 0 or null', (tester) async {
    await tester.pumpWidget(wrap(
      LeaveBalance(leaveType: 'Unpaid', totalDays: null, usedDays: 3, balance: null, year: 2026),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.textContaining('3 days used'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('zero-entitlement balance (totalDays 0) renders Not available, distinct from Unlimited', (tester) async {
    await tester.pumpWidget(wrap(
      LeaveBalance(leaveType: 'Annual', totalDays: 0, usedDays: 0, balance: 0, year: 2026),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Unlimited'), findsNothing);
  });

  testWidgets('normal capped balance renders the days-remaining subtitle', (tester) async {
    await tester.pumpWidget(wrap(
      LeaveBalance(leaveType: 'Annual', totalDays: 21, usedDays: 5, balance: 16, year: 2026),
    ));
    await tester.pumpAndSettle();

    expect(find.text('16 of 21 days left'), findsOneWidget);
    expect(find.text('Unlimited'), findsNothing);
  });
}
