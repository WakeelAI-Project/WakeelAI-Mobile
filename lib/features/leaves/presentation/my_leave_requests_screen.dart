import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_button_styles.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../application/leave_providers.dart';
import 'widgets/leave_status_filter_row.dart';
import 'widgets/leave_request_card.dart';

class MyLeaveRequestsScreen extends ConsumerStatefulWidget {
  const MyLeaveRequestsScreen({super.key});

  @override
  ConsumerState<MyLeaveRequestsScreen> createState() => _MyLeaveRequestsScreenState();
}

class _MyLeaveRequestsScreenState extends ConsumerState<MyLeaveRequestsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(leaveRequestsProvider.notifier).loadNextPage();
    }
  }

  Future<void> _openNewRequest() async {
    final created = await context.push<bool>('/leaves/new');
    if (created == true) {
      ref.read(leaveRequestsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final state = ref.watch(leaveRequestsProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'My Leave Requests', // l10n.leavesTitle
          style: AppTypography.text2xl(isArabic).copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRequest,
        icon: const Icon(Symbols.add),
        label: Text(l10n.myLeaveRequestsFabLabel),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const LeaveStatusFilterRow(),
            const SizedBox(height: AppSpacing.s2),
            Expanded(
              child: RefreshIndicator(
                color: colors.brandPrimary,
                onRefresh: () => ref.read(leaveRequestsProvider.notifier).refresh(),
                child: switch (state.status) {
                  LeaveRequestsLoadStatus.loading => ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      itemCount: 4,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                        height: 100,
                        decoration: BoxDecoration(
                          color: colors.borderDefault,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  LeaveRequestsLoadStatus.error => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Symbols.error, size: 48, color: colors.errorFg),
                              const SizedBox(height: AppSpacing.s3),
                              Text(
                                'Failed to load requests.',
                                style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.s4),
                              ElevatedButton(
                                style: AppButtonStyles.secondary(context),
                                onPressed: () => ref.read(leaveRequestsProvider.notifier).refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  LeaveRequestsLoadStatus.data => state.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.beach_access, size: 64, color: colors.borderDefault),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    'No leave requests found.',
                                    style: AppTypography.textBase(isArabic).copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  ElevatedButton.icon(
                                    style: AppButtonStyles.primary(context),
                                    onPressed: () => context.go('/chat'),
                                    icon: const Icon(Symbols.assistant),
                                    label: const Text('Ask the assistant to request leave'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          // Extra bottom inset so the floating "New Request"
                          // button (which the Scaffold layers on top of the
                          // body rather than reserving space for) doesn't
                          // sit over the last card's content.
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s4,
                            AppSpacing.s4,
                            AppSpacing.s4,
                            AppSpacing.s4 + AppSpacing.s16,
                          ),
                          itemCount: state.items.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return LeaveRequestCard(request: state.items[index]);
                          },
                        ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
