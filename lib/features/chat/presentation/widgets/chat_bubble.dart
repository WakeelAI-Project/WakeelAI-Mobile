import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
    final timeString = DateFormat('h:mm a').format(message.timestamp);

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
                        DateFormat('h:mm a').format(message.timestamp),
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
                  MissingFieldsForm(
                    fields: message.missingFields!,
                    onSubmit: (fieldValues) async {
                      await ref.read(chatProvider.notifier).sendMessage('Providing requested details...', fieldValues: fieldValues);
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
}
