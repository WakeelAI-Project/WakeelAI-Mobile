import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../application/chat_provider.dart';
import '../data/chat_api_client.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';

import 'widgets/chat_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatProvider.notifier).loadHistory();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSend(String text) async {
    try {
      await ref.read(chatProvider.notifier).sendMessage(text);
      _scrollToBottom();
    } on ChatRateLimitException catch (e) {
      _showErrorToast('Rate limited. Please retry in ${e.retryAfterSeconds} seconds.');
    } catch (e) {
      _showErrorToast('Failed to send message.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.bgPage,
      drawer: const ChatDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: colors.bgPage,
            border: Border(
              bottom: BorderSide(color: colors.borderDefault, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  color: colors.brandPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chatScreenTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty && !state.isLoadingHistory
                ? _buildEmptyState(colors, l10n)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: state.messages.length + (state.isLoadingHistory ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      // Since it's reversed, index 0 is the newest message
                      final message = state.messages[state.messages.length - 1 - index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          ChatComposer(
            onSend: _handleSend,
            isLoading: state.isAiResponding,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageSquareText, size: 48, color: colors.textSecondary),
          const SizedBox(height: 16),
          Text(
            l10n.chatEmptyStateTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _SamplePrompt(
            text: l10n.chatSamplePromptLeaveBalance,
            onTap: () => _handleSend(l10n.chatSamplePromptLeaveBalance),
          ),
        ],
      ),
    );
  }
}

class _SamplePrompt extends StatelessWidget {
  const _SamplePrompt({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.brandPrimary,
          ),
        ),
      ),
    );
  }
}
