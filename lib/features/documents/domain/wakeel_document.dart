/// `doc_type` values a document can carry. Named to match the filter chips
/// on the Documents screen (All/Contracts/Warning/Termination) rather than
/// the unrelated `POST /documents/generate` request shape (which is an
/// HR-only, already-implemented endpoint with its own `doc_type` strings) —
/// there is no employee-facing `GET /documents` contract deployed yet, so
/// this enum reflects the story's UI spec, not a live API.
enum DocumentType {
  contract,
  warningLetter,
  termination;

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentType.contract,
    );
  }
}

enum DocumentStatus {
  draft,
  finalStatus;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentStatus.draft,
    );
  }
}

class WakeelDocument {
  final String docId;
  final DocumentType docType;
  final DocumentStatus status;

  /// Null while [status] is [DocumentStatus.draft] — HR hasn't finalized
  /// (and therefore hasn't generated a PDF for) the document yet.
  final String? pdfUrl;
  final DateTime createdAt;

  const WakeelDocument({
    required this.docId,
    required this.docType,
    required this.status,
    required this.pdfUrl,
    required this.createdAt,
  });

  factory WakeelDocument.fromJson(Map<String, dynamic> json) {
    return WakeelDocument(
      docId: json['doc_id'] as String? ?? '',
      docType: DocumentType.fromString(json['doc_type'] as String? ?? 'contract'),
      status: DocumentStatus.fromString(json['status'] as String? ?? 'draft'),
      pdfUrl: json['pdf_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
