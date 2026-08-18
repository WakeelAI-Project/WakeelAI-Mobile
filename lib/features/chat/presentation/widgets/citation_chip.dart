import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/seal_mark.dart';
import '../../domain/chat_citation.dart';

class CitationChip extends StatelessWidget {
  const CitationChip({super.key, required this.citation});

  final ChatCitation citation;

  Future<void> _launchUrl() async {
    if (citation.url.isNotEmpty) {
      final uri = Uri.parse(citation.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Citation: ${citation.title}, Section: ${citation.section}',
      button: citation.url.isNotEmpty,
      child: GestureDetector(
        onTap: citation.url.isNotEmpty ? _launchUrl : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colors.accent),
            borderRadius: BorderRadius.circular(9999), // --radius-full
            color: colors.bgCard,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SealMark.citation(
                ringColor: colors.accent,
                innerColor: colors.accent,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${citation.title} · ${citation.section}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
