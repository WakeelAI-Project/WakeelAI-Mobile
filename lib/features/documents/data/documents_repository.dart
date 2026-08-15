import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/wakeel_document.dart';

class DocumentsPage {
  const DocumentsPage({required this.items, required this.page, required this.hasMore});

  final List<WakeelDocument> items;
  final int page;
  final bool hasMore;
}

abstract class DocumentsRepository {
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentTypeCategory? category});

  Future<WakeelDocument> fetchDocument(String id);

  /// Downloads a document's `pdf_url` (relative to the API host) to
  /// [savePath]. Routed through the repository — rather than the detail
  /// screen reaching for [dioClientProvider] directly — so widget tests can
  /// fake it instead of making a real network call.
  Future<void> downloadPdf({required String pdfUrl, required String savePath});
}

/// Backs `GET /api/Documents` (server-scoped to the caller's own documents
/// when the JWT role is Employee — see DocumentsController.GetDocuments in
/// the backend) and `GET /api/Documents/{doc_id}`.
class DioDocumentsRepository implements DocumentsRepository {
  DioDocumentsRepository(this._dio);
  final Dio _dio;

  /// How many raw items to pull per server round-trip when filtering by
  /// [DocumentTypeCategory] client-side (see [_fetchByCategory]). An
  /// employee's own document count is small in practice, so one batch this
  /// size covers realistic cases without needing to walk multiple server
  /// pages.
  static const _categoryFilterFetchLimit = 200;

  Future<DocumentsPage> _fetchRawPage({required int page, required int limit}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/Documents',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data ?? const {};
    final items = (data['data'] as List<dynamic>? ?? const [])
        .map((json) => WakeelDocument.fromJson(json as Map<String, dynamic>))
        .toList();
    final total = data['total'] as int? ?? items.length;
    final hasMore = page * limit < total;
    return DocumentsPage(items: items, page: page, hasMore: hasMore);
  }

  /// The backend's `type` query filter does an exact match against the raw
  /// `document_type` string, and there's no canonical value the filter
  /// chips can rely on (see [DocumentTypeCategory]) — so category filtering
  /// happens here instead of on the server: pull a batch of raw items and
  /// bucket them by keyword.
  Future<DocumentsPage> _fetchByCategory({
    required int page,
    required int limit,
    required DocumentTypeCategory category,
  }) async {
    final raw = await _fetchRawPage(page: 1, limit: _categoryFilterFetchLimit);
    final matched = raw.items.where((d) => d.category == category).toList();
    final start = ((page - 1) * limit).clamp(0, matched.length);
    final end = (start + limit).clamp(0, matched.length);
    return DocumentsPage(items: matched.sublist(start, end), page: page, hasMore: end < matched.length);
  }

  @override
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentTypeCategory? category}) {
    if (category == null) return _fetchRawPage(page: page, limit: limit);
    return _fetchByCategory(page: page, limit: limit, category: category);
  }

  @override
  Future<WakeelDocument> fetchDocument(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/Documents/$id');
    return WakeelDocument.fromJson(response.data ?? const {});
  }

  @override
  Future<void> downloadPdf({required String pdfUrl, required String savePath}) async {
    final fullUrl = pdfUrl.startsWith('http') ? pdfUrl : '${_dio.options.baseUrl}$pdfUrl';
    await _dio.download(fullUrl, savePath);
  }
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DioDocumentsRepository(ref.watch(dioClientProvider));
});
