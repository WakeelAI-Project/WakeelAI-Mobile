import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/documents/data/documents_repository.dart';
import 'package:wakeel_ai_app/features/documents/domain/wakeel_document.dart';
import 'package:wakeel_ai_app/features/documents/presentation/document_detail_screen.dart';

class _FakeDocumentsRepository implements DocumentsRepository {
  _FakeDocumentsRepository(this.document);
  final WakeelDocument document;

  @override
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentTypeCategory? category}) {
    throw UnimplementedError();
  }

  @override
  Future<WakeelDocument> fetchDocument(String id) async => document;

  @override
  Future<void> downloadPdf({required String pdfUrl, required String savePath}) async {
    // No-op — the widget test stubs out DocumentPdfPreview via
    // pdfPreviewBuilder, so nothing ever reads the downloaded file.
  }

  @override
  String resolvePdfUrl(String pdfUrl) => 'https://example.test$pdfUrl';
}

void main() {
  Widget createWidgetUnderTest(WakeelDocument document) {
    return ProviderScope(
      overrides: [documentsRepositoryProvider.overrideWithValue(_FakeDocumentsRepository(document))],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: DocumentDetailScreen(
          documentId: document.id,
          // The real DocumentPdfPreview calls into pdfx's native PDF
          // renderer, which isn't available under `flutter test` — stub it
          // out so this test only exercises the Final/Draft UI states.
          pdfPreviewBuilder: (_) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  final finalDocument = WakeelDocument(
    id: 'doc-1',
    documentType: 'employment_contract',
    title: 'Employment Contract',
    status: DocumentStatus.finalized,
    pdfUrl: '/uploads/documents/doc-1.pdf',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final draftDocument = WakeelDocument(
    id: 'doc-2',
    documentType: 'warning_letter',
    title: 'Warning Letter',
    status: DocumentStatus.draft,
    pdfUrl: null,
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 1),
  );

  testWidgets('Final document shows Download and Share actions', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(finalDocument));
    await tester.pumpAndSettle();

    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Being reviewed by HR'), findsNothing);
  });

  testWidgets('Draft document shows the reviewing state with no download action', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(draftDocument));
    await tester.pumpAndSettle();

    expect(find.text('Being reviewed by HR'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
    expect(find.text('Share'), findsNothing);
  });
}
