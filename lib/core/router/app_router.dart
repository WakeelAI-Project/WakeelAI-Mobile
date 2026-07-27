import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/shell/theme_showcase_screen.dart';

/// Root app router. `/login` is the real product entry point; `/design-system`
/// stays reachable for reference while more feature screens land.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/design-system', builder: (context, state) => const ThemeShowcaseScreen()),
  ],
);
