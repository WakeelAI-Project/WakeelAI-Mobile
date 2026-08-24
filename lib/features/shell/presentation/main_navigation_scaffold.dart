import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/logout_confirmation.dart';

class MainNavigationScaffold extends ConsumerWidget {
  const MainNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const int _logoutIndex = 4;

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    if (index == _logoutIndex) {
      confirmLogout(context, ref);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bgCard,
          boxShadow: shadows.md,
          border: shadows.md.isEmpty ? Border(top: BorderSide(color: colors.borderDefault)) : null,
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, ref, index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colors.brandPrimary,
          unselectedItemColor: colors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Symbols.home, fill: 0),
              activeIcon: const Icon(Symbols.home, fill: 1),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.forum, fill: 0),
              activeIcon: const Icon(Symbols.forum, fill: 1),
              label: l10n.navChat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.beach_access, fill: 0),
              activeIcon: const Icon(Symbols.beach_access, fill: 1),
              label: l10n.navLeaves,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.folder_open, fill: 0),
              activeIcon: const Icon(Symbols.folder_open, fill: 1),
              label: l10n.navDocs,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Symbols.logout, fill: 0),
              activeIcon: const Icon(Symbols.logout, fill: 1),
              label: l10n.logout,
            ),
          ],
        ),
      ),
    );
  }
}
