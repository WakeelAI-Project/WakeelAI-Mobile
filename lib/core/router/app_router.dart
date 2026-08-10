import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state_provider.dart';
import '../../features/auth/application/pending_password_change_provider.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/employee_home_screen.dart';
import '../../features/shell/theme_showcase_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final pendingPasswordChange = ref.watch(pendingPasswordChangeProvider);

  return GoRouter(
    initialLocation: '/home',
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

      if (authState == AuthState.unauthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (authState == AuthState.authenticated && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(path: '/home', builder: (context, state) => const EmployeeHomeScreen()),
      GoRoute(path: '/design-system', builder: (context, state) => const ThemeShowcaseScreen()),
    ],
  );
});
