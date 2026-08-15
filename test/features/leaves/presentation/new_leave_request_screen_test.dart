import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/leaves/data/leave_api_client.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_type.dart';
import 'package:wakeel_ai_app/features/leaves/presentation/new_leave_request_screen.dart';

DioException _errorResponse(String errorCode, int statusCode) {
  final requestOptions = RequestOptions(path: '/api/leave-requests');
  return DioException(
    requestOptions: requestOptions,
    response: Response(requestOptions: requestOptions, statusCode: statusCode, data: {'error': errorCode}),
  );
}

class _FakeLeaveApiClient implements LeaveApiClient {
  _FakeLeaveApiClient({this.createResult, this.createError});

  CreateLeaveDraftResult? createResult;
  DioException? createError;
  bool createCalled = false;

  @override
  Future<LeaveRequestsPage> getLeaveRequests({String? status, int page = 1, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<void> submitDraft(String id) => throw UnimplementedError();

  @override
  Future<void> cancelDraft(String id) => throw UnimplementedError();

  @override
  Future<String> uploadAttachment(File file) => throw UnimplementedError();

  @override
  Future<CreateLeaveDraftResult> createLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    createCalled = true;
    if (createError != null) throw createError!;
    return createResult!;
  }
}

Widget _wrapPlain(LeaveApiClient client) {
  return ProviderScope(
    overrides: [leaveApiClientProvider.overrideWithValue(client)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
      home: const NewLeaveRequestScreen(),
    ),
  );
}

Widget _wrapWithRouter(LeaveApiClient client) {
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => Scaffold(
          body: ElevatedButton(onPressed: () => context.push('/new'), child: const Text('open')),
        ),
      ),
      GoRoute(path: '/new', builder: (context, state) => const NewLeaveRequestScreen()),
    ],
  );
  return ProviderScope(
    overrides: [leaveApiClientProvider.overrideWithValue(client)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
    ),
  );
}

Future<void> _confirmDatePicker(WidgetTester tester, String hint) async {
  await tester.tap(find.text(hint).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _selectSickLeaveType(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<LeaveType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sick').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('missing dates are blocked client-side', (tester) async {
    final client = _FakeLeaveApiClient();
    await tester.pumpWidget(_wrapPlain(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(client.createCalled, isFalse);
    expect(find.text('Select both a start and end date'), findsOneWidget);
  });

  testWidgets('Sick leave without an attachment is blocked client-side', (tester) async {
    final client = _FakeLeaveApiClient();
    await tester.pumpWidget(_wrapPlain(client));
    await tester.pumpAndSettle();

    await _selectSickLeaveType(tester);
    await _confirmDatePicker(tester, 'Select date'); // start
    await _confirmDatePicker(tester, 'Select date'); // end

    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(client.createCalled, isFalse);
    expect(find.text('Please attach a medical report for sick leave'), findsOneWidget);
  });

  testWidgets('successful submit calls the client and pops', (tester) async {
    final client = _FakeLeaveApiClient(
      createResult: const CreateLeaveDraftResult(requestId: 'req-1', status: 'Draft', daysRequested: 1),
    );
    await tester.pumpWidget(_wrapWithRouter(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await _confirmDatePicker(tester, 'Select date'); // start
    await _confirmDatePicker(tester, 'Select date'); // end

    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(client.createCalled, isTrue);
    // Popped back to the start screen.
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('server validation error surfaces its banner', (tester) async {
    final client = _FakeLeaveApiClient(createError: _errorResponse('validation_error', 400));
    await tester.pumpWidget(_wrapPlain(client));
    await tester.pumpAndSettle();

    await _confirmDatePicker(tester, 'Select date'); // start
    await _confirmDatePicker(tester, 'Select date'); // end
    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(find.text('Check the request details and try again.'), findsOneWidget);
  });

  testWidgets('server insufficient_leave_balance (422) surfaces its banner', (tester) async {
    // Annual leave needs no attachment, so this exercises a server error
    // that reaches the client-side-validation-clean path (the DoD's
    // "422 surfaced if it still reaches the server" requirement) — the
    // attachment_required 422 specifically can't be driven this way in a
    // headless widget test since file_picker needs a real OS dialog, so
    // client-side blocking always fires first for that one.
    final client = _FakeLeaveApiClient(createError: _errorResponse('insufficient_leave_balance', 422));
    await tester.pumpWidget(_wrapPlain(client));
    await tester.pumpAndSettle();

    await _confirmDatePicker(tester, 'Select date'); // start
    await _confirmDatePicker(tester, 'Select date'); // end
    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    expect(client.createCalled, isTrue);
    expect(find.text("Your remaining leave balance isn't enough to cover these dates."), findsOneWidget);
  });
}
