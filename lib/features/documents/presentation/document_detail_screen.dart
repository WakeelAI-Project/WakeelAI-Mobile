import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

import '../domain/wakeel_document.dart';
import 'widgets/document_card.dart' show iconForDocumentType, labelForDocumentType;
import 'widgets/document_pdf_preview.dart';

typedef PdfPreviewBuilder = Widget Function(String assetPath);

Widget _defaultPdfPreviewBuilder(String assetPath) => DocumentPdfPreview(assetPath: assetPath);

class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({
    super.key,
    required this.document,
    this.pdfPreviewBuilder = _defaultPdfPreviewBuilder,
  });

  final WakeelDocument document;

  /// Overridable so tests can substitute a stub instead of the real
  /// [DocumentPdfPreview] — that widget calls into pdfx's native PDF
  /// renderer, which isn't available under `flutter test`.
  final PdfPreviewBuilder pdfPreviewBuilder;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool _isWorking = false;
  String? _localFilePath;

  /// Sample data encodes bundled assets as `asset:<path>` since there's no
  /// real `pdf_url` to download from yet (see documents_repository.dart).
  String get _assetPath {
    final url = widget.document.pdfUrl!;
    return url.startsWith('asset:') ? url.substring('asset:'.length) : url;
  }

  String get _fileName => '${widget.document.docId}.pdf';

  Future<String> _ensureLocalCopy() async {
    final cached = _localFilePath;
    if (cached != null) return cached;
    final data = await rootBundle.load(_assetPath);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    _localFilePath = file.path;
    return file.path;
  }

  Future<void> _download() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      await _ensureLocalCopy();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to your device.')),
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

  Future<void> _share() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      final path = await _ensureLocalCopy();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], fileNameOverrides: [_fileName]),
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
    final document = widget.document;
    final isDraft = document.status == DocumentStatus.draft;

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          labelForDocumentType(document.docType),
          style: AppTypography.textXl(isArabic).copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
              child: Row(
                children: [
                  Icon(iconForDocumentType(document.docType), color: colors.textSecondary),
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
                  : widget.pdfPreviewBuilder(_assetPath),
            ),
            if (!isDraft)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s4),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: AppButtonStyles.secondary(context),
                        onPressed: _isWorking ? null : _share,
                        icon: const Icon(Symbols.share),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: AppButtonStyles.primary(context),
                        onPressed: _isWorking ? null : _download,
                        icon: _isWorking
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                              )
                            : const Icon(Symbols.download),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
              ),
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
