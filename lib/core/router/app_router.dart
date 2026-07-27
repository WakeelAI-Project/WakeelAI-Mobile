import 'package:go_router/go_router.dart';

import '../../features/shell/theme_showcase_screen.dart';

/// Root app router. Only one route exists so far — the design-system
/// showcase — until the first real user story/task defines actual
/// screens (auth, chat, dashboard, ...).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ThemeShowcaseScreen()),
  ],
);
