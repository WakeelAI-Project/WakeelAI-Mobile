import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/documents_repository.dart';
import '../domain/wakeel_document.dart';

enum DocumentsLoadStatus { loading, data, error }

const documentsPageSize = 10;

class DocumentsState {
  const DocumentsState({
    required this.status,
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.isStale,
    required this.filter,
    this.error,
  });

  final DocumentsLoadStatus status;
  final List<WakeelDocument> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  /// True once a refresh or next-page fetch has failed while we still have
  /// a previously-loaded list to show — the list "survives" by staying on
  /// screen instead of being replaced with an error view.
  final bool isStale;
  final DocumentType? filter;
  final Object? error;

  static const initial = DocumentsState(
    status: DocumentsLoadStatus.loading,
    items: [],
    page: 0,
    hasMore: true,
    isLoadingMore: false,
    isRefreshing: false,
    isStale: false,
    filter: null,
  );
}

/// Drives the Documents list: initial load, filter-by-type, infinite-scroll
/// pagination, pull-to-refresh, and the stale indicator. Backed by
/// [documentsRepositoryProvider], which is currently an in-memory fixture
/// (see that file for why) rather than a live network call.
class DocumentsNotifier extends AutoDisposeNotifier<DocumentsState> {
  @override
  DocumentsState build() {
    Future.microtask(_loadFirstPage);
    return DocumentsState.initial;
  }

  Future<void> _loadFirstPage() async {
    final repo = ref.read(documentsRepositoryProvider);
    final filter = state.filter;
    try {
      final result = await repo.fetchDocuments(page: 1, limit: documentsPageSize, type: filter);
      state = DocumentsState(
        status: DocumentsLoadStatus.data,
        items: result.items,
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
        isStale: false,
        filter: filter,
      );
    } catch (e) {
      state = DocumentsState(
        status: DocumentsLoadStatus.error,
        items: const [],
        page: 0,
        hasMore: false,
        isLoadingMore: false,
        isRefreshing: false,
        isStale: false,
        filter: filter,
        error: e,
      );
    }
  }

  Future<void> setFilter(DocumentType? type) async {
    if (state.filter == type) return;
    state = DocumentsState(
      status: DocumentsLoadStatus.loading,
      items: const [],
      page: 0,
      hasMore: true,
      isLoadingMore: false,
      isRefreshing: false,
      isStale: false,
      filter: type,
    );
    await _loadFirstPage();
  }

  /// Pull-to-refresh. On failure, keeps the last-known list on screen and
  /// flags it stale instead of replacing it with an error state.
  Future<void> refresh() async {
    if (state.status == DocumentsLoadStatus.error) {
      await _loadFirstPage();
      return;
    }

    state = DocumentsState(
      status: state.status,
      items: state.items,
      page: state.page,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      isRefreshing: true,
      isStale: state.isStale,
      filter: state.filter,
    );

    final repo = ref.read(documentsRepositoryProvider);
    try {
      final result = await repo.fetchDocuments(page: 1, limit: documentsPageSize, type: state.filter);
      state = DocumentsState(
        status: DocumentsLoadStatus.data,
        items: result.items,
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
        isStale: false,
        filter: state.filter,
      );
    } catch (_) {
      state = DocumentsState(
        status: state.status,
        items: state.items,
        page: state.page,
        hasMore: state.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
        isStale: true,
        filter: state.filter,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.status != DocumentsLoadStatus.data) return;
    if (state.isLoadingMore || !state.hasMore) return;

    state = DocumentsState(
      status: state.status,
      items: state.items,
      page: state.page,
      hasMore: state.hasMore,
      isLoadingMore: true,
      isRefreshing: state.isRefreshing,
      isStale: state.isStale,
      filter: state.filter,
    );

    final repo = ref.read(documentsRepositoryProvider);
    try {
      final result = await repo.fetchDocuments(page: state.page + 1, limit: documentsPageSize, type: state.filter);
      state = DocumentsState(
        status: DocumentsLoadStatus.data,
        items: [...state.items, ...result.items],
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        isRefreshing: false,
        isStale: state.isStale,
        filter: state.filter,
      );
    } catch (_) {
      // Keep what's already loaded; just stop the footer spinner and flag
      // the list stale so the user knows the tail may be incomplete.
      state = DocumentsState(
        status: state.status,
        items: state.items,
        page: state.page,
        hasMore: state.hasMore,
        isLoadingMore: false,
        isRefreshing: state.isRefreshing,
        isStale: true,
        filter: state.filter,
      );
    }
  }
}

final documentsProvider = AutoDisposeNotifierProvider<DocumentsNotifier, DocumentsState>(DocumentsNotifier.new);
