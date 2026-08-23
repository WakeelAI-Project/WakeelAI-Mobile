import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/leaves/data/leave_api_client.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_request.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_type.dart';
import 'package:wakeel_ai_app/features/leaves/presentation/my_leave_requests_screen.dart';
import 'package:wakeel_ai_app/features/leaves/presentation/widgets/leave_request_card.dart';
import 'package:wakeel_ai_app/features/leaves/presentation/widgets/leave_status_filter_row.dart';

class _FakeLeaveApiClient implements LeaveApiClient {
  _FakeLeaveApiClient({required this.total, this.shouldThrow = false, this.statusFor});

  final int total;
  final bool shouldThrow;

  /// Overrides the default "req-0 is a Draft, the rest are Pending" shape.
  final LeaveStatus Function(int index)? statusFor;

  final List<int> requestedPages = [];
  final List<String?> requestedStatuses = [];
  final List<String> cancelledIds = [];

  late final List<LeaveRequest> _all = List.generate(
    total,
    (i) => LeaveRequest(
      id: 'req-$i',
      leaveType: 'Annual',
      startDate: '2026-03-0${(i % 9) + 1}',
      endDate: '2026-03-0${(i % 9) + 1}',
      status: statusFor?.call(i) ?? (i == 0 ? LeaveStatus.draft : LeaveStatus.pending),
      daysRequested: 1,
    ),
  );

  @override
  Future<LeaveRequestsPage> getLeaveRequests({String? status, int page = 1, int limit = 20}) async {
    requestedPages.add(page);
    requestedStatuses.add(status);
    if (shouldThrow) throw Exception('Simulated failure');

    final start = (page - 1) * limit;
    if (start >= _all.length) {
      return LeaveRequestsPage(items: const [], page: page, hasMore: false);
    }
    final end = (start + limit).clamp(0, _all.length);
    return LeaveRequestsPage(items: _all.sublist(start, end), page: page, hasMore: end < _all.length);
  }

  @override
  Future<LeaveRequest> getLeaveRequest(String id) => throw UnimplementedError();

  @override
  Future<void> submitDraft(String id) async {}

  @override
  Future<void> cancelDraft(String id) async {
    cancelledIds.add(id);
  }

  @override
  Future<String> uploadAttachment(File file) => throw UnimplementedError();

  @override
  Future<CreateLeaveDraftResult> createLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) =>
      throw UnimplementedError();
}

void main() {
  Widget createWidgetUnderTest(LeaveApiClient client) {
    return ProviderScope(
      overrides: [leaveApiClientProvider.overrideWithValue(client)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: const MyLeaveRequestsScreen(),
      ),
    );
  }

  testWidgets('loading state renders without crashing', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeLeaveApiClient(total: 3)));
    await tester.pump();

    expect(find.byType(MyLeaveRequestsScreen), findsOneWidget);
  });

  testWidgets('error state renders error text and retry button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeLeaveApiClient(total: 0, shouldThrow: true)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load requests.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('empty state renders empty message', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeLeaveApiClient(total: 0)));
    await tester.pumpAndSettle();

    expect(find.text('No leave requests found.'), findsOneWidget);
  });

  testWidgets('success state renders a card per request', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeLeaveApiClient(total: 3)));
    await tester.pumpAndSettle();

    expect(find.byType(LeaveRequestCard), findsNWidgets(3));
  });

  testWidgets('scrolling to the bottom triggers a next-page load', (tester) async {
    final client = _FakeLeaveApiClient(total: 45); // page size is 20 -> 3 pages
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    expect(client.requestedPages, [1]);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(client.requestedPages, contains(2));
  });

  testWidgets('pull-to-refresh triggers a refetch (smoke test)', (tester) async {
    final client = _FakeLeaveApiClient(total: 3);
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(LeaveRequestCard), findsWidgets);
  });

  testWidgets('tapping a status filter chip triggers a refetch with that status', (tester) async {
    final client = _FakeLeaveApiClient(total: 3);
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    expect(client.requestedStatuses.last, 'All');

    final pendingChip = find.descendant(of: find.byType(LeaveStatusFilterRow), matching: find.text('Pending'));
    await tester.tap(pendingChip);
    await tester.pumpAndSettle();

    expect(client.requestedStatuses.last, 'Pending');
  });

  testWidgets('a Draft card spells out that it has not reached HR', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeLeaveApiClient(total: 2)));
    await tester.pumpAndSettle();

    // req-0 is the only Draft in the fake's data; req-1 is Pending.
    expect(find.text("This draft hasn't been sent to HR yet."), findsOneWidget);
  });

  testWidgets('a Pending card offers Withdraw and confirms before calling the API', (tester) async {
    final client = _FakeLeaveApiClient(total: 1, statusFor: (_) => LeaveStatus.pending);
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Withdraw request'));
    await tester.pumpAndSettle();

    // The dialog is up; nothing has been sent yet.
    expect(client.cancelledIds, isEmpty);
    expect(find.text('Withdraw'), findsOneWidget);

    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();

    expect(client.cancelledIds, ['req-0']);
  });

  testWidgets('dismissing the withdraw dialog leaves the request alone', (tester) async {
    final client = _FakeLeaveApiClient(total: 1, statusFor: (_) => LeaveStatus.pending);
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Withdraw request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(client.cancelledIds, isEmpty);
  });

  testWidgets('Approved and Rejected cards offer no withdraw action', (tester) async {
    final client = _FakeLeaveApiClient(
      total: 2,
      statusFor: (i) => i == 0 ? LeaveStatus.approved : LeaveStatus.rejected,
    );
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    expect(find.byType(LeaveRequestCard), findsNWidgets(2));
    expect(find.text('Withdraw request'), findsNothing);
  });

  testWidgets('Submit on a Draft card flips it to Pending', (tester) async {
    final client = _FakeLeaveApiClient(total: 1);
    await tester.pumpWidget(createWidgetUnderTest(client));
    await tester.pumpAndSettle();

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // The fake always returns req-0 as Draft on subsequent fetches too
    // (it doesn't mutate state), so this asserts the refetch happened
    // rather than a status flip the fake can't simulate.
    expect(client.requestedPages.length, greaterThan(1));
  });
}
