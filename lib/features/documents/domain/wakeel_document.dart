enum DocumentStatus {
  draft,
  finalized;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentStatus.draft,
    );
  }
}

/// Broad bucket used only to pick a filter-chip icon/label. The backend's
/// `document_type` is a free-form string set by whoever created the
/// template (HR) — there is no canonical enum shared across the .NET and AI
/// services, still an open cross-team gap. Matching by keyword rather than
/// exact value lets the UI degrade gracefully instead of silently
/// mismatching HR's naming.
enum DocumentTypeCategory {
  contract,
  warningLetter,
  termination,
  other;

  static DocumentTypeCategory fromRaw(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('terminat')) return DocumentTypeCategory.termination;
    if (value.contains('warn')) return DocumentTypeCategory.warningLetter;
    if (value.contains('contract') || value.contains('offer')) return DocumentTypeCategory.contract;
    return DocumentTypeCategory.other;
  }
}

/// Mirrors `DocumentSummary`/`DocumentDetail` from the .NET backend
/// (Wakeel.Application.DTOs.Documents). `GET /api/Documents` (list) only
/// populates the summary fields — [contentHtml], [pdfUrl], [templateId], and
/// [finalizedAt] stay null until the item is re-fetched individually via
/// `GET /api/Documents/{doc_id}`.
class WakeelDocument {
  final String id;
  final String documentType;
  final String title;
  final DocumentStatus status;

  /// Only present on the detail response, and only while [status] is
  /// [DocumentStatus.draft] — the backend clears it once finalized.
  final String? contentHtml;

  /// Relative path (e.g. `/uploads/documents/xxx.pdf`) served from the
  /// backend's wwwroot — callers must prefix it with the API base URL.
  /// Only present on the detail response, and only once [status] is
  /// [DocumentStatus.finalized].
  final String? pdfUrl;

  final String? employeeId;
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finalizedAt;

  DocumentTypeCategory get category => DocumentTypeCategory.fromRaw(documentType);

  const WakeelDocument({
    required this.id,
    required this.documentType,
    required this.title,
    required this.status,
    this.contentHtml,
    this.pdfUrl,
    this.employeeId,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
    this.finalizedAt,
  });

  factory WakeelDocument.fromJson(Map<String, dynamic> json) {
    return WakeelDocument(
      id: json['id'] as String? ?? '',
      documentType: json['document_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: DocumentStatus.fromString(json['status'] as String? ?? 'draft'),
      contentHtml: json['content_html'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      employeeId: json['employee_id'] as String?,
      templateId: json['template_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      finalizedAt: json['finalized_at'] != null ? DateTime.tryParse(json['finalized_at'] as String) : null,
    );
  }
}
