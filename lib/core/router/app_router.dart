import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../navigation/navigator_key.dart';
import '../../features/auth/application/auth_state_provider.dart';
import '../../features/auth/application/pending_password_change_provider.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/verify_otp_screen.dart';
import '../../features/home/presentation/employee_home_screen.dart';
import '../../features/shell/theme_showcase_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/leaves/presentation/my_leave_requests_screen.dart';
import '../../features/leaves/presentation/new_leave_request_screen.dart';

import '../../features/documents/presentation/documents_screen.dart';
import '../../features/documents/presentation/document_detail_screen.dart';
import '../../features/shell/presentation/main_navigation_scaffold.dart';
import '../../features/chat/presentation/chat_screen.dart';

Page<dynamic> _buildSlideTransitionPage(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // start from left
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final pendingPasswordChange = ref.watch(pendingPasswordChangeProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      if (authState == AuthState.loading) return '/splash';

      final path = state.uri.path;

      // A first-login employee is stuck here until they set a new password —
      // takes priority over the normal authenticated/unauthenticated split
      // since these tokens are deliberately never persisted (see
      // PendingPasswordChange).
      if (pendingPasswordChange != null) {
        return path == '/change-password' ? null : '/change-password';
      }

      final isGoingToLogin = path == '/login';

      // Settings (theme/locale) and the forgot/verify-otp/new-password flow
      // are reachable pre-login too, so they're exempt from the
      // unauthenticated bounce-to-login below.
      final isGoingToSettings = path == '/settings';
      final isGoingToForgotPassword = path == '/forgot-password';
      final isGoingToVerifyOtp = path == '/verify-otp';
      final isGoingToNewPassword = path == '/new-password';

      if (authState == AuthState.unauthenticated &&
          !isGoingToLogin &&
          !isGoingToSettings &&
          !isGoingToForgotPassword &&
          !isGoingToVerifyOtp &&
          !isGoingToNewPassword) {
        return '/login';
      }

      if (authState == AuthState.authenticated && (isGoingToLogin || path == '/splash')) {
        return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context, 
          state, 
          const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ),
      GoRoute(
        path: '/login', 
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const ChangePasswordScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/verify-otp',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context,
          state,
          VerifyOtpScreen(email: state.extra as String),
        ),
      ),
      GoRoute(
        path: '/new-password',
        pageBuilder: (context, state) {
          final args = state.extra as ({String email, String otp});
          return _buildSlideTransitionPage(
            context,
            state,
            NewPasswordScreen(email: args.email, otp: args.otp),
          );
        },
      ),
      GoRoute(
        path: '/welcome', 
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const WelcomeScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/leaves/new',
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const NewLeaveRequestScreen()),
      ),
      GoRoute(
        path: '/documents/:docId',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context,
          state,
          DocumentDetailScreen(documentId: state.pathParameters['docId']!),
        ),
      ),
      GoRoute(
        path: '/design-system', 
        pageBuilder: (context, state) => _buildSlideTransitionPage(context, state, const ThemeShowcaseScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(child: EmployeeHomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaves',
                pageBuilder: (context, state) => const NoTransitionPage(child: MyLeaveRequestsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/docs',
                pageBuilder: (context, state) => const NoTransitionPage(child: DocumentsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
