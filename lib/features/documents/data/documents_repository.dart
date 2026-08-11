import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/wakeel_document.dart';

class DocumentsPage {
  const DocumentsPage({required this.items, required this.page, required this.hasMore});

  final List<WakeelDocument> items;
  final int page;
  final bool hasMore;
}

abstract class DocumentsRepository {
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentType? type});
}

/// Stands in for `GET /documents` (employee-scoped, paginated) until that
/// endpoint is deployed — as of this writing the live API only exposes
/// `POST /documents/generate` (HR-only) and nothing for an employee to list
/// their own documents (see wakeel-ai-api-documentation.md §4.4 and the live
/// swagger.json, which has no `/documents` path at all). This generates a
/// fixed in-memory dataset and simulates request latency so the screen
/// behaves like a real paginated list; swap this for a Dio-backed
/// implementation once the backend ships the endpoint.
class SampleDocumentsRepository implements DocumentsRepository {
  static final List<WakeelDocument> _all = _generateSampleDocuments();

  static List<WakeelDocument> _generateSampleDocuments() {
    final types = DocumentType.values;
    return List.generate(27, (i) {
      final type = types[i % types.length];
      // Every third document is still a draft (no PDF yet).
      final isDraft = i % 3 == 0;
      return WakeelDocument(
        docId: 'doc-${i + 1}',
        docType: type,
        status: isDraft ? DocumentStatus.draft : DocumentStatus.finalStatus,
        pdfUrl: isDraft ? null : 'asset:assets/sample_documents/sample_contract.pdf',
        createdAt: DateTime(2026, 1, 1).add(Duration(days: i * 3)),
      );
    }).reversed.toList(); // newest first
  }

  @override
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentType? type}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final filtered = type == null ? _all : _all.where((d) => d.docType == type).toList();
    final start = (page - 1) * limit;
    if (start >= filtered.length) {
      return DocumentsPage(items: const [], page: page, hasMore: false);
    }
    final end = (start + limit).clamp(0, filtered.length);
    return DocumentsPage(items: filtered.sublist(start, end), page: page, hasMore: end < filtered.length);
  }
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return SampleDocumentsRepository();
});
