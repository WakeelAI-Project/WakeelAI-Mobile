import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../application/documents_provider.dart';
import 'widgets/document_card.dart';
import 'widgets/document_type_filter_row.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
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
      ref.read(documentsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final state = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          l10n.quickActionDocs,
          style: AppTypography.textXl(isArabic).copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DocumentTypeFilterRow(),
            if (state.isStale)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
                  decoration: BoxDecoration(
                    color: colors.warningBg,
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.cloud_off, size: 18, color: colors.warningFg),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: Text(
                          'Showing saved documents — pull to refresh for updates.',
                          style: AppTypography.textSm(isArabic).copyWith(color: colors.warningFg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.s2),
            Expanded(
              child: RefreshIndicator(
                color: colors.brandPrimary,
                onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
                child: switch (state.status) {
                  DocumentsLoadStatus.loading => ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      itemCount: 4,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                        height: 84,
                        decoration: BoxDecoration(
                          color: colors.borderDefault,
                          borderRadius: AppRadius.lgRadius,
                        ),
                      ),
                    ),
                  DocumentsLoadStatus.error => ListView(
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
                                'Failed to load documents.',
                                style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary),
                              ),
                              if (kDebugMode)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                                  child: Text(
                                    state.error.toString(),
                                    style: AppTypography.textSm(isArabic).copyWith(color: colors.errorFg),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.s4),
                              ElevatedButton(
                                style: AppButtonStyles.secondary(context),
                                onPressed: () => ref.read(documentsProvider.notifier).refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  DocumentsLoadStatus.data => state.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.folder_open, size: 64, color: colors.borderDefault),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    'No documents found.',
                                    style: AppTypography.textBase(isArabic).copyWith(color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.s4),
                          itemCount: state.items.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final document = state.items[index];
                            return DocumentCard(
                              document: document,
                              onTap: () => context.push('/documents/${document.id}'),
                            );
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
