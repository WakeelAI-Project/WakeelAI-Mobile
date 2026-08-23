import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'dart:io';

import 'package:wakeel_ai_app/core/storage/token_storage.dart';
import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/home/application/employee_provider.dart';
import 'package:wakeel_ai_app/features/home/data/employee_api_client.dart';
import 'package:wakeel_ai_app/features/home/domain/employee_profile.dart';
import 'package:wakeel_ai_app/features/profile/presentation/profile_screen.dart';
import 'package:wakeel_ai_app/features/profile/presentation/widgets/full_screen_photo_viewer.dart';

class _FakeEmployeeApiClient implements EmployeeApiClient {
  _FakeEmployeeApiClient(this.profile);

  EmployeeProfile profile;
  bool removeCalled = false;
  bool uploadCalled = false;

  @override
  Future<EmployeeProfile> getEmployeeProfile() async => profile;

  @override
  Future<EmployeeProfile> removePhoto() async {
    removeCalled = true;
    profile = EmployeeProfile(
      userId: profile.userId,
      recordId: profile.recordId,
      fullName: profile.fullName,
      email: profile.email,
      departmentId: profile.departmentId,
      department: profile.department,
      nationalId: profile.nationalId,
      jobTitle: profile.jobTitle,
      salary: profile.salary,
      hireDate: profile.hireDate,
      contractType: profile.contractType,
      employmentStatus: profile.employmentStatus,
      leaveBalances: profile.leaveBalances,
      photoUrl: null,
    );
    return profile;
  }

  @override
  Future<EmployeeProfile> uploadPhoto(File file) async {
    uploadCalled = true;
    return profile;
  }

  @override
  Future<EmployeeProfile> updateTimeZone(String timeZoneId) async => profile;
}

class _FakeTokenStorage implements TokenStorage {
  bool cleared = false;
  String? _accessToken = 'fake-access-token';

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
  }

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => 'fake-refresh-token';

  @override
  Future<void> clearTokens() async {
    cleared = true;
    _accessToken = null;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  final profile = EmployeeProfile(
    userId: 'u1',
    recordId: 'r1',
    fullName: 'Ahmed Youssef',
    email: 'ahmed@acme.com',
    departmentId: 'd1',
    department: 'Engineering',
    nationalId: '1234567890',
    jobTitle: 'Software Engineer',
    salary: 15000,
    hireDate: '2023-03-15',
    contractType: 'Full-time',
    employmentStatus: 'Active',
    leaveBalances: [],
  );

  late _FakeTokenStorage fakeTokenStorage;

  Widget createWidgetUnderTest(AsyncValue<EmployeeProfile> state) {
    fakeTokenStorage = _FakeTokenStorage();
    return ProviderScope(
      overrides: [
        employeeProfileProvider.overrideWith((ref) {
          return state.when(
            data: (data) => Future.value(data),
            loading: () => Completer<EmployeeProfile>().future,
            error: (e, st) => Future.error(e, st),
          );
        }),
        tokenStorageProvider.overrideWithValue(fakeTokenStorage),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: const ProfileScreen(),
      ),
    );
  }

  testWidgets('loading state renders skeleton, not the profile fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AsyncValue.loading()));
    await tester.pump();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Ahmed Youssef'), findsNothing);
  });

  testWidgets('error state renders error message and retry button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.error(Exception('Failed'), StackTrace.empty)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load profile'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders full name, email, job title, department, hire date, and salary from GET /me', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Youssef'), findsOneWidget);
    expect(find.text('AY'), findsOneWidget); // avatar initials
    expect(find.text('Software Engineer'), findsOneWidget);
    expect(find.text('Engineering'), findsOneWidget);
    expect(find.text('ahmed@acme.com'), findsOneWidget);
    expect(find.textContaining('EGP'), findsOneWidget);
    expect(find.textContaining('15,000'), findsOneWidget);
    expect(find.textContaining('2023'), findsOneWidget);
  });

  testWidgets('logout button shows a confirmation dialog before clearing the token', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(fakeTokenStorage.cleared, isFalse);
  });

  testWidgets('cancelling the confirmation dialog does not clear the token', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(fakeTokenStorage.cleared, isFalse);
    expect(find.text('Are you sure you want to log out?'), findsNothing);
  });

  testWidgets('confirming logout clears the stored token', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AsyncValue.data(profile)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    // Two "Log out" texts exist now: the page button (obscured behind the
    // dialog barrier) and the dialog's confirm action — tap the latter.
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();

    expect(fakeTokenStorage.cleared, isTrue);
  });

  group('profile photo', () {
    Widget createWidgetUnderTestWithClient(_FakeEmployeeApiClient client) {
      return ProviderScope(
        overrides: [
          employeeApiClientProvider.overrideWithValue(client),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
          home: const ProfileScreen(),
        ),
      );
    }

    testWidgets('with no photo, the sheet offers Take Photo / Choose from Gallery but not Remove', (tester) async {
      final client = _FakeEmployeeApiClient(profile);
      await tester.pumpWidget(createWidgetUnderTestWithClient(client));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.pencil));
      await tester.pumpAndSettle();

      expect(find.text('Add Profile Photo'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Remove Profile Photo'), findsNothing);
    });

    testWidgets('with a photo, the sheet offers Remove Profile Photo, which calls removePhoto', (tester) async {
      final withPhoto = EmployeeProfile(
        userId: profile.userId,
        recordId: profile.recordId,
        fullName: profile.fullName,
        email: profile.email,
        departmentId: profile.departmentId,
        department: profile.department,
        nationalId: profile.nationalId,
        jobTitle: profile.jobTitle,
        salary: profile.salary,
        hireDate: profile.hireDate,
        contractType: profile.contractType,
        employmentStatus: profile.employmentStatus,
        leaveBalances: profile.leaveBalances,
        photoUrl: '/uploads/profile-photos/avatar.jpg',
      );
      final client = _FakeEmployeeApiClient(withPhoto);
      await tester.pumpWidget(createWidgetUnderTestWithClient(client));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.pencil));
      await tester.pumpAndSettle();

      expect(find.text('Remove Profile Photo'), findsOneWidget);

      await tester.tap(find.text('Remove Profile Photo'));
      await tester.pumpAndSettle();

      expect(client.removeCalled, isTrue);
    });

    testWidgets('tapping the photo (not the pen) opens the full-screen viewer', (tester) async {
      final withPhoto = EmployeeProfile(
        userId: profile.userId,
        recordId: profile.recordId,
        fullName: profile.fullName,
        email: profile.email,
        departmentId: profile.departmentId,
        department: profile.department,
        nationalId: profile.nationalId,
        jobTitle: profile.jobTitle,
        salary: profile.salary,
        hireDate: profile.hireDate,
        contractType: profile.contractType,
        employmentStatus: profile.employmentStatus,
        leaveBalances: profile.leaveBalances,
        photoUrl: '/uploads/profile-photos/avatar.jpg',
      );
      final client = _FakeEmployeeApiClient(withPhoto);
      await tester.pumpWidget(createWidgetUnderTestWithClient(client));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      expect(find.byType(FullScreenPhotoViewer), findsOneWidget);
    });
  });
}
