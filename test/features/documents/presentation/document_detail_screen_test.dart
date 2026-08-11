import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/documents/domain/wakeel_document.dart';
import 'package:wakeel_ai_app/features/documents/presentation/document_detail_screen.dart';

void main() {
  Widget createWidgetUnderTest(WakeelDocument document) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
      home: DocumentDetailScreen(
        document: document,
        // The real DocumentPdfPreview calls into pdfx's native PDF
        // renderer, which isn't available under `flutter test` — stub it
        // out so this test only exercises the Final/Draft UI states.
        pdfPreviewBuilder: (_) => const SizedBox.shrink(),
      ),
    );
  }

  final finalDocument = WakeelDocument(
    docId: 'doc-1',
    docType: DocumentType.contract,
    status: DocumentStatus.finalStatus,
    pdfUrl: 'asset:assets/sample_documents/sample_contract.pdf',
    createdAt: DateTime(2026, 1, 1),
  );

  final draftDocument = WakeelDocument(
    docId: 'doc-2',
    docType: DocumentType.warningLetter,
    status: DocumentStatus.draft,
    pdfUrl: null,
    createdAt: DateTime(2026, 2, 1),
  );

  testWidgets('Final document shows Download and Share actions', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(finalDocument));
    await tester.pump();

    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Being reviewed by HR'), findsNothing);
  });

  testWidgets('Draft document shows the reviewing state with no download action', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(draftDocument));
    await tester.pump();

    expect(find.text('Being reviewed by HR'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
    expect(find.text('Share'), findsNothing);
  });
}
