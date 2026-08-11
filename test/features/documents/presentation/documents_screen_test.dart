import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/documents/data/documents_repository.dart';
import 'package:wakeel_ai_app/features/documents/domain/wakeel_document.dart';
import 'package:wakeel_ai_app/features/documents/presentation/documents_screen.dart';
import 'package:wakeel_ai_app/features/documents/presentation/widgets/document_card.dart';

class _FakeDocumentsRepository implements DocumentsRepository {
  _FakeDocumentsRepository({required this.total, this.shouldThrow = false});

  final int total;
  final bool shouldThrow;
  final List<int> requestedPages = [];

  late final List<WakeelDocument> _all = List.generate(
    total,
    (i) => WakeelDocument(
      docId: 'doc-$i',
      docType: DocumentType.contract,
      status: DocumentStatus.finalStatus,
      pdfUrl: 'asset:assets/sample_documents/sample_contract.pdf',
      createdAt: DateTime(2026, 1, 1).add(Duration(days: i)),
    ),
  );

  @override
  Future<DocumentsPage> fetchDocuments({required int page, required int limit, DocumentType? type}) async {
    requestedPages.add(page);
    if (shouldThrow) throw Exception('Simulated failure');

    final start = (page - 1) * limit;
    if (start >= _all.length) {
      return DocumentsPage(items: const [], page: page, hasMore: false);
    }
    final end = (start + limit).clamp(0, _all.length);
    return DocumentsPage(items: _all.sublist(start, end), page: page, hasMore: end < _all.length);
  }
}

void main() {
  Widget createWidgetUnderTest(DocumentsRepository repository) {
    return ProviderScope(
      overrides: [documentsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: const DocumentsScreen(),
      ),
    );
  }

  testWidgets('loading state renders without crashing', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeDocumentsRepository(total: 3)));
    await tester.pump();

    expect(find.byType(DocumentsScreen), findsOneWidget);
  });

  testWidgets('error state renders error text and retry button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeDocumentsRepository(total: 0, shouldThrow: true)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load documents.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('empty state renders empty message', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeDocumentsRepository(total: 0)));
    await tester.pumpAndSettle();

    expect(find.text('No documents found.'), findsOneWidget);
  });

  testWidgets('success state renders a card per document', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(_FakeDocumentsRepository(total: 3)));
    await tester.pumpAndSettle();

    expect(find.byType(DocumentCard), findsNWidgets(3));
  });

  testWidgets('scrolling to the bottom triggers a next-page load', (tester) async {
    // ListView.builder only ever constructs the items that fit near the
    // current viewport, so this asserts on the pagination signal itself
    // (which page the repository was asked for) rather than a
    // viewport-dependent widget count.
    final repo = _FakeDocumentsRepository(total: 15); // page size is 10 -> 2 pages
    await tester.pumpWidget(createWidgetUnderTest(repo));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, [1]);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(repo.requestedPages, contains(2));
  });

  testWidgets('pull-to-refresh triggers a refetch (smoke test)', (tester) async {
    final repo = _FakeDocumentsRepository(total: 3);
    await tester.pumpWidget(createWidgetUnderTest(repo));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    // We just verify it doesn't crash, matching the convention in
    // employee_home_screen_test.dart's pull-to-refresh smoke test.
    expect(find.byType(DocumentCard), findsWidgets);
  });
}
