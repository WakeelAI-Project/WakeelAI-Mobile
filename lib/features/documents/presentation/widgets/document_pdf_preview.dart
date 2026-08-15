import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

/// In-app PDF preview with pinch-zoom over a locally-downloaded copy of
/// `pdf_url` (see `DocumentDetailScreen._ensureLocalCopy`).
///
/// Loading is delegated to [PdfControllerPinch]/[PdfViewPinch] themselves —
/// on failure (e.g. no native PDF renderer available, as under `flutter
/// test`) [onDocumentError] fires and we fall back to a static panel
/// instead of crashing.
class DocumentPdfPreview extends StatefulWidget {
  const DocumentPdfPreview({super.key, required this.filePath});

  final String filePath;

  @override
  State<DocumentPdfPreview> createState() => _DocumentPdfPreviewState();
}

class _DocumentPdfPreviewState extends State<DocumentPdfPreview> {
  late final PdfControllerPinch _controller;
  bool _failedToLoad = false;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(document: PdfDocument.openFile(widget.filePath));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    if (_failedToLoad) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.picture_as_pdf, size: 48, color: colors.borderDefault),
            const SizedBox(height: AppSpacing.s3),
            Text(
              'Preview unavailable',
              style: AppTypography.textBase(isArabic).copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return PdfViewPinch(
      controller: _controller,
      onDocumentError: (error) {
        if (mounted) setState(() => _failedToLoad = true);
      },
    );
  }
}
