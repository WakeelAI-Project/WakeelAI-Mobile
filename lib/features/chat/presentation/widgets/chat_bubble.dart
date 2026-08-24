import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../domain/chat_message.dart';
import 'citation_chip.dart';
import 'missing_fields_form.dart';
import 'result_card_renderer.dart';
import 'typewriter_text.dart';
import 'typing_indicator.dart';
import '../../application/chat_provider.dart';

class ChatBubble extends ConsumerWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isUser)
            _buildUserBubble(context, colors, ref)
          else
            _buildAssistantStack(context, colors, ref),
          if (message.status == MessageStatus.error) ...[
            const SizedBox(height: 4),
            Text(
              l10n.chatBubbleFailedToSend,
              style: TextStyle(color: Colors.red[800], fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildUserBubble(BuildContext context, AppColors colors, WidgetRef ref) {
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    final timeString = AppDateFormat.time(message.timestamp, isArabic: isArabic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.brandPrimary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onBrandPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (message.status == MessageStatus.error) {
                    ref.read(chatProvider.notifier).deleteMessage(message.id);
                  }
                  ref.read(chatProvider.notifier).sendMessage(message.text);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    LucideIcons.refreshCw,
                    size: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                timeString,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssistantStack(BuildContext context, AppColors colors, WidgetRef ref) {
    final hasCitations = message.citations != null && message.citations!.isNotEmpty;
    final hasResultCard = message.resultCard != null;
    final hasMissingFields = message.missingFields != null && message.missingFields!.isNotEmpty;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: message.status == MessageStatus.sending ? 0.0 : 4.0, 
            end: 8.0,
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: colors.brandPrimary,
            child: Icon(
              LucideIcons.bot,
              size: 18,
              color: colors.onBrandPrimary,
            ),
          ),
        ),
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.text.isNotEmpty || message.status == MessageStatus.sending) ...[
                  Container(
                    padding: message.status == MessageStatus.sending
                        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.borderDefault),
                    ),
                    child: message.status == MessageStatus.sending
                      ? TypingIndicator(dotColor: colors.textSecondary)
                      : TypewriterText(
                          text: message.text,
                          isStreaming: message.status == MessageStatus.streaming,
                          onComplete: () {
                            ref.read(chatProvider.notifier).markMessageAsSent(message.id);
                          },
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                  ),
                  if (message.status != MessageStatus.sending) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        AppDateFormat.time(message.timestamp, isArabic: AppLocalizations.of(context)!.localeName == 'ar'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
                if (hasCitations) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.citations!.map((c) => CitationChip(citation: c)).toList(),
                  ),
                ],
                if (hasResultCard) ...[
                  const SizedBox(height: 8),
                  ResultCardRenderer(card: message.resultCard!, messageId: message.id),
                ],
                if (hasMissingFields) ...[
                  const SizedBox(height: 8),
                  if (message.submittedValues != null)
                    _buildSubmittedConfirmation(context, colors)
                  else
                    MissingFieldsForm(
                      fields: message.missingFields!,
                      onSubmit: (fieldValues) async {
                        final labelMap = { for (var f in message.missingFields!) f.name : f.label };
                        final details = fieldValues.entries.map((e) {
                          final label = labelMap[e.key] ?? e.key;
                          return '$label (${e.key}): ${e.value}';
                        }).join('\n');
                        
                        final msg = 'Providing requested details:\n$details';
                        
                        await ref.read(chatProvider.notifier).submitForm(message.id, msg, fieldValues);
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmittedConfirmation(BuildContext context, AppColors colors) {
    final values = message.submittedValues!;
    final labelMap = { for (var f in message.missingFields!) f.name : f.label };
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';

    // 1. Combine Date Range
    DateTime? startDate;
    DateTime? endDate;
    
    for (var entry in values.entries) {
      if (entry.value == null || entry.value.toString().trim().isEmpty) continue;
      
      if (entry.key.toLowerCase().contains('start') && (entry.value is DateTime || DateTime.tryParse(entry.value.toString()) != null)) {
        startDate = entry.value is DateTime ? entry.value : DateTime.parse(entry.value.toString());
      } else if (entry.key.toLowerCase().contains('end') && (entry.value is DateTime || DateTime.tryParse(entry.value.toString()) != null)) {
        endDate = entry.value is DateTime ? entry.value : DateTime.parse(entry.value.toString());
      }
    }

    String? dateRangeString;
    if (startDate != null) {
      final startStr = AppDateFormat.date(startDate, isArabic: isArabic);
      if (endDate != null) {
        final duration = endDate.difference(startDate).inDays + 1; // inclusive
        if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
           dateRangeString = startStr;
        } else {
           final endStr = AppDateFormat.date(endDate, isArabic: isArabic);
           final durationStr = isArabic 
               ? (duration == 1 ? 'يوم واحد' : duration == 2 ? 'يومين' : duration <= 10 ? '$duration أيام' : '$duration يوماً') 
               : '$duration days';
           dateRangeString = '$startStr – $endStr ($durationStr)';
        }
      } else {
        dateRangeString = startStr;
      }
    }

    // 2. Filter out empty fields and start/end dates
    final displayEntries = <MapEntry<String, String>>[];
    for (var entry in values.entries) {
      if (entry.value == null || entry.value.toString().trim().isEmpty) continue;
      
      final keyLower = entry.key.toLowerCase();
      if (dateRangeString != null && (keyLower.contains('start') || keyLower.contains('end'))) {
        continue;
      }

      String label = labelMap[entry.key] ?? entry.key;
      if (label.toLowerCase().contains('reason')) label = isArabic ? 'السبب' : 'Reason';
      if (label.toLowerCase().contains('medical report') || label.toLowerCase().contains('report')) label = isArabic ? 'التقرير الطبي' : 'Medical Report';

      String displayValue = entry.value.toString();
      
      if (displayValue.startsWith('http')) {
        displayValue = isArabic ? 'مستند مرفق' : 'Attached Document';
      } else if (displayValue.startsWith('File:')) {
        displayValue = displayValue.replaceAll(RegExp(r"^File:\s*'?|'?$"), '').split('/').last.split('\\').last;
      } else if (DateTime.tryParse(displayValue) != null) {
         final d = DateTime.tryParse(displayValue);
         if (d != null && d.year > 2000) {
            displayValue = AppDateFormat.date(d, isArabic: isArabic);
         }
      }

      displayEntries.add(MapEntry(label, displayValue));
    }
    
    final submittedTime = AppDateFormat.time(message.timestamp, isArabic: isArabic);
    final submittedDate = AppDateFormat.date(message.timestamp, isArabic: isArabic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: colors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'تم الحفظ' : 'Saved',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$submittedDate, $submittedTime',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dateRangeString != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'تواريخ الإجازة' : 'Leave Dates',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateRangeString,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ...displayEntries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    e.value,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
