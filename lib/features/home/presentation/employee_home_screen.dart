import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../profile/presentation/widgets/profile_avatar.dart';
import '../application/employee_provider.dart';
import 'widgets/current_leave_card.dart';
import 'widgets/leave_balance_card.dart';
import 'widgets/quick_action_card.dart';
import 'package:go_router/go_router.dart';

class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  String _getGreeting(BuildContext context, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.homeGreetingMorning;
    } else if (hour < 17) {
      return l10n.homeGreetingAfternoon;
    } else {
      return l10n.homeGreetingEvening;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final profileAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeeProfileProvider);
          },
          color: colors.brandPrimary,
          child: CustomScrollView(
            slivers: [
              // Greeting Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: profileAsync.when(
                    data: (profile) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting(context, l10n)}${Directionality.of(context) == TextDirection.rtl ? '،' : ','}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textBase(isArabic).copyWith(
                                      color: colors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.s1),
                              Text(
                                profile.fullName.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.text2xl(isArabic).copyWith(
                                      color: colors.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfileAvatar(
                              photoUrl: profile.photoUrl,
                              initials: _getInitials(profile.fullName),
                              radius: 24,
                              showEditBadge: false,
                              onTap: () => context.push('/profile'),
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            IconButton(
                              iconSize: 28,
                              onPressed: () {
                                context.push('/settings');
                              },
                              icon: Icon(Symbols.settings, color: colors.textSecondary, fill: 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const _GreetingSkeleton(),
                    error: (e, st) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting(context, l10n)}${Directionality.of(context) == TextDirection.rtl ? '،' : ','}',
                              style: AppTypography.textBase(isArabic).copyWith(
                                    color: colors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            Text(
                              'Wakeel AI',
                              style: AppTypography.text2xl(isArabic).copyWith(
                                    color: colors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: colors.borderDefault,
                              child: Icon(Symbols.account_circle, color: colors.textSecondary),
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            IconButton(
                              iconSize: 28,
                              onPressed: null, // Disabled in error state
                              icon: Icon(Symbols.settings, color: colors.borderDefault, fill: 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Current Leave Section — only shown while a leave is actually in progress today.
              SliverToBoxAdapter(
                child: profileAsync.maybeWhen(
                  data: (profile) => profile.currentLeave == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                          child: CurrentLeaveCard(currentLeave: profile.currentLeave!),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),

              // Leave Balances Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
                  child: Text(
                    l10n.homeLeaveBalances,
                    style: AppTypography.textSm(isArabic).copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                sliver: profileAsync.when(
                  data: (profile) => SliverList.builder(
                    itemCount: profile.leaveBalances.length,
                    itemBuilder: (context, index) {
                      final balance = profile.leaveBalances[index];
                      return LeaveBalanceCard(
                        leaveBalance: balance,
                        onTap: () {},
                      );
                    },
                  ),
                  loading: () => SliverList.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => const _LeaveBalanceCardSkeleton(),
                  ),
                  error: (e, st) => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Symbols.error, size: 48, color: colors.errorFg),
                            const SizedBox(height: AppSpacing.s3),
                            Text('Failed to load data', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.textPrimary)),
                            if (kDebugMode)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                                child: Text(
                                  e.toString(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.errorFg),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: AppSpacing.s4),
                            ElevatedButton(
                              style: AppButtonStyles.secondary(context),
                              onPressed: () => ref.invalidate(employeeProfileProvider),
                              child: const Text('Retry'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Actions Section
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s4)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
                  child: Text(
                    l10n.homeQuickActions,
                    style: AppTypography.textSm(isArabic).copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.s3,
                  crossAxisSpacing: AppSpacing.s3,
                  childAspectRatio: 1.2,
                  children: [
                    QuickActionCard(
                      title: l10n.quickActionChat,
                      icon: LucideIcons.bot,
                      onTap: () {},
                    ),
                    QuickActionCard(
                      title: l10n.quickActionLeaves,
                      icon: LucideIcons.calendarDays,
                      onTap: () {
                        context.go('/leaves');
                      },
                    ),
                    QuickActionCard(
                      title: l10n.quickActionDocs,
                      icon: LucideIcons.fileText,
                      onTap: () {
                        context.go('/docs');
                      },
                    ),
                    QuickActionCard(
                      title: l10n.quickActionProfile,
                      icon: LucideIcons.circleUserRound,
                      onTap: () {
                        context.push('/profile');
                      },
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 16, color: colors.borderDefault),
            const SizedBox(height: 8),
            Container(width: 150, height: 28, color: colors.borderDefault),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.borderDefault, shape: BoxShape.circle)),
            const SizedBox(width: AppSpacing.s2),
            Container(width: 48, height: 48, decoration: BoxDecoration(color: colors.borderDefault, shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }
}

class _LeaveBalanceCardSkeleton extends StatelessWidget {
  const _LeaveBalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      decoration: BoxDecoration(
        color: colors.borderDefault,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
