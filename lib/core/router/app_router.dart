import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/employee_home_screen.dart';
import '../../features/shell/theme_showcase_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (authState == AuthState.loading) return '/splash';
      
      final isGoingToLogin = state.uri.path == '/login';
      
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
      GoRoute(path: '/home', builder: (context, state) => const EmployeeHomeScreen()),
      GoRoute(path: '/design-system', builder: (context, state) => const ThemeShowcaseScreen()),
    ],
  );
});
