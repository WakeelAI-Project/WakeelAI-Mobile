import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/leave_request.dart';
import '../data/leave_api_client.dart';

final leaveStatusFilterProvider = StateProvider<String>((ref) => 'All');

enum LeaveRequestsLoadStatus { loading, data, error }

const leaveRequestsPageSize = 20;

class LeaveRequestsState {
  const LeaveRequestsState({
    required this.status,
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isRefreshing,
    this.error,
  });

  final LeaveRequestsLoadStatus status;
  final List<LeaveRequest> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final Object? error;

  static const initial = LeaveRequestsState(
    status: LeaveRequestsLoadStatus.loading,
    items: [],
    page: 0,
    hasMore: true,
    isLoadingMore: false,
    isRefreshing: false,
  );
}

/// Drives "My Leave Requests": initial load, infinite-scroll pagination,
/// pull-to-refresh, and Submit/Cancel on a draft. Backed by
/// [leaveApiClientProvider] (`GET /api/leave-requests`).
///
/// [leaveStatusFilterProvider] is watched (not folded into this state, as
/// the equivalent Documents/[filter] is) so [leave_status_filter_row.dart]
/// needs no changes — Riverpod re-runs [build] automatically whenever the
/// filter chip changes, which is exactly the reload-on-filter-change
/// behavior needed here.
class LeaveRequestsNotifier extends AutoDisposeNotifier<LeaveRequestsState> {
  @override
  LeaveRequestsState build() {
    final filter = ref.watch(leaveStatusFilterProvider);
    Future.microtask(() => _loadFirstPage(filter));
    return LeaveRequestsState.initial;
  }

  Future<void> _loadFirstPage(String filter) async {
    final client = ref.read(leaveApiClientProvider);
    try {
      final result = await client.getLeaveRequests(status: filter, page: 1, limit: leaveRequestsPageSize);
      state = LeaveRequestsState(
        status: LeaveRequestsLoadStatus.data,
        items: result.items,
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
      );
    } catch (e) {
      state = LeaveRequestsState(
        status: LeaveRequestsLoadStatus.error,
        items: const [],
        page: 0,
        hasMore: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: e,
      );
    }
  }

  /// Pull-to-refresh, and also used after Submit/Cancel to reflect the
  /// request's new status.
  Future<void> refresh() async {
    if (state.status == LeaveRequestsLoadStatus.error) {
      await _loadFirstPage(ref.read(leaveStatusFilterProvider));
      return;
    }

    state = LeaveRequestsState(
      status: state.status,
      items: state.items,
      page: state.page,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      isRefreshing: true,
    );

    final filter = ref.read(leaveStatusFilterProvider);
    final client = ref.read(leaveApiClientProvider);
    try {
      final result = await client.getLeaveRequests(status: filter, page: 1, limit: leaveRequestsPageSize);
      state = LeaveRequestsState(
        status: LeaveRequestsLoadStatus.data,
        items: result.items,
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
      );
    } catch (_) {
      state = LeaveRequestsState(
        status: state.status,
        items: state.items,
        page: state.page,
        hasMore: state.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.status != LeaveRequestsLoadStatus.data) return;
    if (state.isLoadingMore || !state.hasMore) return;

    state = LeaveRequestsState(
      status: state.status,
      items: state.items,
      page: state.page,
      hasMore: state.hasMore,
      isLoadingMore: true,
      isRefreshing: state.isRefreshing,
    );

    final filter = ref.read(leaveStatusFilterProvider);
    final client = ref.read(leaveApiClientProvider);
    try {
      final result = await client.getLeaveRequests(status: filter, page: state.page + 1, limit: leaveRequestsPageSize);
      state = LeaveRequestsState(
        status: LeaveRequestsLoadStatus.data,
        items: [...state.items, ...result.items],
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
      );
    } catch (_) {
      state = LeaveRequestsState(
        status: state.status,
        items: state.items,
        page: state.page,
        hasMore: state.hasMore,
        isLoadingMore: false,
        isRefreshing: state.isRefreshing,
      );
    }
  }

  Future<void> submitDraft(String id) async {
    final client = ref.read(leaveApiClientProvider);
    await client.submitDraft(id);
    await refresh();
  }

  Future<void> cancelDraft(String id) async {
    final client = ref.read(leaveApiClientProvider);
    await client.cancelDraft(id);
    await refresh();
  }

  /// Withdraws a request the employee has already submitted but HR hasn't
  /// reviewed yet. It hits the same `DELETE /api/leave-requests/{id}`
  /// endpoint as [cancelDraft] — the backend's cancel handler accepts
  /// Pending as well as Draft, releasing any reserved balance and notifying
  /// HR — so this exists purely to name the employee-facing action for what
  /// it is at the call site.
  Future<void> withdrawRequest(String id) => cancelDraft(id);
}

final leaveRequestsProvider = AutoDisposeNotifierProvider<LeaveRequestsNotifier, LeaveRequestsState>(
  LeaveRequestsNotifier.new,
);
