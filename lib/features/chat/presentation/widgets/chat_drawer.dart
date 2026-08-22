import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/widgets/seal_mark.dart';
import '../../application/chat_provider.dart';
import '../../application/conversation_provider.dart';


class ChatDrawer extends ConsumerWidget {
  const ChatDrawer({super.key});

  String _getGroupName(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return l10n.chatDrawerToday;
    } else if (itemDate == yesterday) {
      return l10n.chatDrawerYesterday;
    } else if (now.difference(itemDate).inDays <= 7) {
      return l10n.chatDrawerPrevious7Days;
    } else {
      return l10n.chatDrawerOlder;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final conversationState = ref.watch(conversationProvider);

    // Sidebar uses bgSidebar which is dark Navy-950 in both themes.
    // So text must be textOnNavy, and we'll use a slightly dimmed version for secondary text.
    final primaryTextColor = colors.textOnNavy;
    final secondaryTextColor = colors.textOnNavy.withValues(alpha: 0.7);
    final dividerColor = colors.textOnNavy.withValues(alpha: 0.1);

    return Drawer(
      backgroundColor: colors.bgSidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with SealMark
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  SealMark.logomark(
                    ringColor: primaryTextColor,
                    innerColor: colors.accent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(chatProvider.notifier).startNewChat();
                  Navigator.of(context).pop(); // Close drawer
                },
                icon: const Icon(LucideIcons.plus),
                label: Text(l10n.chatDrawerNewChat, maxLines: 1, overflow: TextOverflow.ellipsis),
                style: AppButtonStyles.primary(context).copyWith(
                  // We explicitly set the background to a lighter color on the dark sidebar
                  // or use secondary which might look better. Let's use brandPrimary logic
                  // but ensure text is visible.
                  backgroundColor: WidgetStateProperty.all(colors.brandPrimary),
                  foregroundColor: WidgetStateProperty.all(colors.onBrandPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                l10n.chatDrawerRecentConversations,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: conversationState.isLoading && conversationState.conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : conversationState.conversations.isEmpty
                      ? Center(
                          child: Text(
                            l10n.chatDrawerNoPreviousChats,
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: conversationState.conversations.length + (conversationState.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == conversationState.conversations.length) {
                              // Load more trigger
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref.read(conversationProvider.notifier).loadConversations();
                              });
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final conversation = conversationState.conversations[index];
                            final timeString = DateFormat('MMM d, yyyy').format(conversation.updatedAt);
                            
                            final currentGroup = _getGroupName(conversation.updatedAt, l10n);
                            final previousGroup = index > 0 
                                ? _getGroupName(conversationState.conversations[index - 1].updatedAt, l10n)
                                : null;
                            
                            final showHeader = currentGroup != previousGroup;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 4.0),
                                    child: Text(
                                      currentGroup,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ListTile(
                                  leading: Icon(LucideIcons.messageSquareText, color: secondaryTextColor, size: 20),
                                  title: Text(
                                    conversation.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    timeString,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  onTap: () {
                                    ref.read(chatProvider.notifier).switchConversation(conversation.id);
                                    Navigator.of(context).pop(); // Close drawer
                                  },
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
