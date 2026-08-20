import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/home/application/employee_provider.dart';
import 'package:wakeel_ai_app/features/home/domain/employee_profile.dart';
import 'package:wakeel_ai_app/features/home/presentation/employee_home_screen.dart';
import 'package:wakeel_ai_app/features/home/presentation/widgets/current_leave_card.dart';
import 'package:wakeel_ai_app/features/home/presentation/widgets/leave_balance_card.dart';
import 'package:wakeel_ai_app/features/profile/presentation/widgets/profile_avatar.dart';

void main() {
  Widget createWidgetUnderTest(AsyncValue<EmployeeProfile> state) {
    return ProviderScope(
      overrides: [
        employeeProfileProvider.overrideWith((ref) {
          return state.when(
            data: (data) => Future.value(data),
            loading: () => Completer<EmployeeProfile>().future,
            error: (e, st) => Future.error(e, st),
          );
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: const EmployeeHomeScreen(),
      ),
    );
  }

  testWidgets('loading state renders skeletons', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AsyncValue.loading()));
    // wait for first frame
    await tester.pump();
    
    // Expect skeletons (we can look for some empty texts or just verify it doesn't throw)
    expect(find.byType(EmployeeHomeScreen), findsOneWidget);
    // RefreshIndicator is present
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('error state renders error text and retry button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.error(Exception('Failed'), StackTrace.empty)));
    // wait for Future to resolve
    await tester.pumpAndSettle();

    expect(find.text('Failed to load data'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('success state renders balances and greeting', (tester) async {
    final profile = EmployeeProfile(
      userId: 'u1',
      recordId: 'r1',
      fullName: 'Ahmed Youssef',
      email: 'ahmed@acme.com',
      departmentId: 'd1',
      department: 'Engineering',
      nationalId: '1234567890',
      jobTitle: 'Dev',
      salary: 1000,
      hireDate: '2026-01-01',
      contractType: 'Full-time',
      employmentStatus: 'Active',
      leaveBalances: [
        LeaveBalance(leaveType: 'Annual', totalDays: 21, usedDays: 5, balance: 16, year: 2026),
        LeaveBalance(leaveType: 'Unpaid', totalDays: null, usedDays: 2, balance: null, year: 2026),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    expect(find.text('Ahmed'), findsOneWidget); // First name
    expect(find.text('AY'), findsOneWidget); // Initials
    
    expect(find.byType(LeaveBalanceCard), findsWidgets);
    expect(find.text('Annual'), findsOneWidget);
    expect(find.byType(CurrentLeaveCard), findsNothing);
  });

  testWidgets('success state with a profile photo shows it in a read-only avatar', (tester) async {
    final profile = EmployeeProfile(
      userId: 'u1',
      recordId: 'r1',
      fullName: 'Ahmed Youssef',
      email: 'ahmed@acme.com',
      departmentId: 'd1',
      department: 'Engineering',
      nationalId: '1234567890',
      jobTitle: 'Dev',
      salary: 1000,
      hireDate: '2026-01-01',
      contractType: 'Full-time',
      employmentStatus: 'Active',
      leaveBalances: const [],
      photoUrl: '/uploads/photos/u1.jpg',
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    final avatar = tester.widget<ProfileAvatar>(find.byType(ProfileAvatar));
    expect(avatar.photoUrl, '/uploads/photos/u1.jpg');
    expect(avatar.showEditBadge, isFalse);
    // The edit-pen badge (and the sheet it opens) only belongs on the profile page.
    expect(find.byIcon(LucideIcons.pencil), findsNothing);
  });

  testWidgets('an active approved leave renders the current-leave progress card', (tester) async {
    final profile = EmployeeProfile(
      userId: 'u1',
      recordId: 'r1',
      fullName: 'Ahmed Youssef',
      email: 'ahmed@acme.com',
      departmentId: 'd1',
      department: 'Engineering',
      nationalId: '1234567890',
      jobTitle: 'Dev',
      salary: 1000,
      hireDate: '2026-01-01',
      contractType: 'Full-time',
      employmentStatus: 'Active',
      leaveBalances: const [],
      currentLeave: CurrentLeave(
        leaveType: 'Annual',
        startDate: '2026-08-17',
        endDate: '2026-08-21',
        totalDays: 5,
        elapsedDays: 3,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    expect(find.byType(CurrentLeaveCard), findsOneWidget);
    expect(find.text('Annual — Day 3 of 5'), findsOneWidget);
  });

  testWidgets('pull-to-refresh triggers a refetch (smoke test)', (tester) async {
    final profile = EmployeeProfile(
      userId: 'u1',
      recordId: 'r1',
      fullName: 'Ahmed Youssef',
      email: 'ahmed@acme.com',
      departmentId: 'd1',
      department: 'Engineering',
      nationalId: '1234567890',
      jobTitle: 'Dev',
      salary: 1000,
      hireDate: '2026-01-01',
      contractType: 'Full-time',
      employmentStatus: 'Active',
      leaveBalances: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    // Swipe down to trigger refresh
    await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();
    
    // We just verify it doesn't crash since the mock provider always returns the same mock data
    expect(find.text('Ahmed'), findsOneWidget);
  });
}
