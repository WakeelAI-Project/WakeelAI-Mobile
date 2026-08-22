import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../application/documents_provider.dart';
import '../data/documents_repository.dart';
import '../domain/wakeel_document.dart';
import 'widgets/document_card.dart' show iconForDocumentType;
import 'widgets/document_pdf_preview.dart';

/// Takes the (not-yet-invoked) download step rather than a plain file path
/// so tests can override the whole loading+rendering pipeline — including
/// skipping the download — not just the final PDF-rendering widget.
typedef PdfPreviewBuilder = Widget Function(Future<String> Function() ensureLocalCopy);

Widget _defaultPdfPreviewBuilder(Future<String> Function() ensureLocalCopy) {
  return _PdfPreviewLoader(ensureLocalCopy: ensureLocalCopy);
}

/// Fetches the document fresh via `GET /api/Documents/{doc_id}` on entry
/// (see [documentDetailProvider]) rather than reusing the list item, since
/// the list endpoint omits `content_html`/`pdf_url`.
class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({
    super.key,
    required this.documentId,
    this.pdfPreviewBuilder = _defaultPdfPreviewBuilder,
  });

  final String documentId;

  /// Overridable so tests can substitute a stub instead of the real
  /// [DocumentPdfPreview] — that widget calls into pdfx's native PDF
  /// renderer, which isn't available under `flutter test`.
  final PdfPreviewBuilder pdfPreviewBuilder;

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _isWorking = false;
  String? _localFilePath;

  String _fileNameFor(WakeelDocument document) => '${document.id}.pdf';

  /// Downloads `pdf_url` (a path relative to the API host, e.g.
  /// `/uploads/documents/xxx.pdf`) into the app's documents directory the
  /// first time it's needed, then reuses the cached copy.
  Future<String> _ensureLocalCopy(WakeelDocument document) async {
    final cached = _localFilePath;
    if (cached != null) return cached;

    final pdfUrl = document.pdfUrl;
    if (pdfUrl == null) {
      throw StateError('Document ${document.id} has no pdf_url to download.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${_fileNameFor(document)}');
    if (await file.exists()) {
      _localFilePath = file.path;
      return file.path;
    }

    await ref.read(documentsRepositoryProvider).downloadPdf(pdfUrl: pdfUrl, savePath: file.path);
    _localFilePath = file.path;
    return file.path;
  }

  /// Saves a copy into the device's public Downloads folder — unlike
  /// [_ensureLocalCopy], which caches into this app's private sandbox
  /// storage (fine for in-app preview/share, but invisible to the user in
  /// Files/Downloads, and gone if the app is uninstalled).
  Future<void> _download(WakeelDocument document) async {
    if (_isWorking) return;
    final pdfUrl = document.pdfUrl;
    if (pdfUrl == null) return;
    setState(() => _isWorking = true);
    try {
      final fullUrl = ref.read(documentsRepositoryProvider).resolvePdfUrl(pdfUrl);
      final file = await FileDownloader.downloadFile(url: fullUrl, name: _fileNameFor(document));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(file != null ? 'Saved to your device.' : 'Download failed. Please try again.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _share(WakeelDocument document) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      final path = await _ensureLocalCopy(document);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], fileNameOverrides: [_fileNameFor(document)]),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final asyncDocument = ref.watch(documentDetailProvider(widget.documentId));

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          asyncDocument.valueOrNull?.title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textXl(isArabic).copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: switch (asyncDocument) {
          AsyncData(:final value) => _DocumentDetailBody(
              document: value,
              colors: colors,
              isArabic: isArabic,
              isWorking: _isWorking,
              onDownload: () => _download(value),
              onShare: () => _share(value),
              ensureLocalCopy: () => _ensureLocalCopy(value),
              pdfPreviewBuilder: widget.pdfPreviewBuilder,
            ),
          AsyncError(:final error) => _ErrorState(
              colors: colors,
              isArabic: isArabic,
              error: error,
              onRetry: () => ref.invalidate(documentDetailProvider(widget.documentId)),
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _DocumentDetailBody extends StatelessWidget {
  const _DocumentDetailBody({
    required this.document,
    required this.colors,
    required this.isArabic,
    required this.isWorking,
    required this.onDownload,
    required this.onShare,
    required this.ensureLocalCopy,
    required this.pdfPreviewBuilder,
  });

  final WakeelDocument document;
  final AppColors colors;
  final bool isArabic;
  final bool isWorking;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final Future<String> Function() ensureLocalCopy;
  final PdfPreviewBuilder pdfPreviewBuilder;

  @override
  Widget build(BuildContext context) {
    final isDraft = document.status == DocumentStatus.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
          child: Row(
            children: [
              Icon(iconForDocumentType(document.category), color: colors.textSecondary),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(document.createdAt),
                  style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
                ),
              ),
              StatusBadge(
                label: isDraft ? 'Being reviewed' : 'Final',
                status: isDraft ? AppStatus.warning : AppStatus.success,
              ),
            ],
          ),
        ),
        Expanded(
          child: isDraft
              ? _DraftReviewState(colors: colors, isArabic: isArabic)
              : document.pdfUrl == null
                  ? _ErrorState(
                      colors: colors,
                      isArabic: isArabic,
                      error: StateError('Finalized document is missing a pdf_url.'),
                      onRetry: null,
                    )
                  : pdfPreviewBuilder(ensureLocalCopy),
        ),
        if (!isDraft && document.pdfUrl != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: AppButtonStyles.secondary(context),
                    onPressed: isWorking ? null : onShare,
                    icon: const Icon(Symbols.share),
                    label: const Text('Share', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: ElevatedButton.icon(
                    style: AppButtonStyles.primary(context),
                    onPressed: isWorking ? null : onDownload,
                    icon: isWorking
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                          )
                        : const Icon(Symbols.download),
                    label: const Text('Download', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Production default for [PdfPreviewBuilder]: downloads the PDF once
/// (caching the local path for the life of this widget) before handing it
/// to [DocumentPdfPreview].
class _PdfPreviewLoader extends StatefulWidget {
  const _PdfPreviewLoader({required this.ensureLocalCopy});

  final Future<String> Function() ensureLocalCopy;

  @override
  State<_PdfPreviewLoader> createState() => _PdfPreviewLoaderState();
}

class _PdfPreviewLoaderState extends State<_PdfPreviewLoader> {
  late final Future<String> _localFile = widget.ensureLocalCopy();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _localFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final colors = Theme.of(context).extension<AppColors>()!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.picture_as_pdf, size: 48, color: colors.borderDefault),
                const SizedBox(height: AppSpacing.s3),
                Text('Preview unavailable', style: TextStyle(color: colors.textSecondary)),
              ],
            ),
          );
        }
        return DocumentPdfPreview(filePath: snapshot.data!);
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.colors, required this.isArabic, required this.error, required this.onRetry});

  final AppColors colors;
  final bool isArabic;
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.error, size: 48, color: colors.errorFg),
            const SizedBox(height: AppSpacing.s3),
            Text(
              'Failed to load document.',
              style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary),
            ),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  error.toString(),
                  style: AppTypography.textSm(isArabic).copyWith(color: colors.errorFg),
                  textAlign: TextAlign.center,
                ),
              ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.s4),
              ElevatedButton(
                style: AppButtonStyles.secondary(context),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DraftReviewState extends StatelessWidget {
  const _DraftReviewState({required this.colors, required this.isArabic});

  final AppColors colors;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.hourglass_top, size: 56, color: colors.warningFg),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Being reviewed by HR',
              style: AppTypography.textLg(isArabic).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              "This document is still being finalized. You'll be able to preview and download it once it's ready.",
              style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
