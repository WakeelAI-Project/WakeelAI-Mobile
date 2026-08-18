import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../domain/chat_conversation.dart';

class ConversationState {
  final List<ChatConversation> conversations;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  ConversationState({
    this.conversations = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ConversationState copyWith({
    List<ChatConversation>? conversations,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final ChatRepository _repository;

  ConversationNotifier(this._repository) : super(ConversationState()) {
    loadConversations();
  }

  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      state = ConversationState(isLoading: true);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    try {
      final newConversations = await _repository.getConversations(page: state.currentPage);
      
      state = state.copyWith(
        conversations: [...state.conversations, ...newConversations],
        hasMore: newConversations.isNotEmpty,
        currentPage: state.currentPage + 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final conversationProvider = StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(ref.watch(chatRepositoryProvider));
});
