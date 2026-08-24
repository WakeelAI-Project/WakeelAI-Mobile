import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_result_card.dart';
import 'conversation_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoadingHistory;
  final bool hasMoreHistory;
  final int currentPage;

  ChatState({
    this.messages = const [],
    this.isLoadingHistory = false,
    this.hasMoreHistory = true,
    this.currentPage = 1,
  });

  bool get isAiResponding {
    return messages.any((m) => 
      m.role == MessageRole.assistant && 
      (m.status == MessageStatus.sending || m.status == MessageStatus.streaming)
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoadingHistory,
    bool? hasMoreHistory,
    int? currentPage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._repository, this._ref) : super(ChatState()) {
    loadHistory();
  }

  final ChatRepository _repository;
  final Ref _ref;

  Future<void> loadHistory() async {
    if (state.isLoadingHistory || !state.hasMoreHistory) return;

    state = state.copyWith(isLoadingHistory: true);
    
    try {
      final oldMessagesRaw = await _repository.getHistory(page: state.currentPage);
      final oldMessages = oldMessagesRaw;
      
      final existingIds = state.messages.map((m) => m.id).toSet();
      final existingSignatures = state.messages.map((m) => '${m.role.name}:${m.text.trim()}').toSet();
      
      final filteredOld = oldMessages.where((m) {
        if (existingIds.contains(m.id)) return false;
        if (existingSignatures.contains('${m.role.name}:${m.text.trim()}')) return false;
        return true;
      }).toList();

      final List<ChatMessage> processedOld = [];
      Map<String, dynamic>? pendingSubmittedValues;

      for (int i = filteredOld.length - 1; i >= 0; i--) {
        final m = filteredOld[i];
        if (m.role == MessageRole.user && m.text.trim().startsWith('Providing requested details:')) {
          pendingSubmittedValues = {};
          final lines = m.text.split('\n').skip(1);
          for (var line in lines) {
            final match = RegExp(r'\(([^)]+)\):\s*(.*)$').firstMatch(line);
            if (match != null) {
              pendingSubmittedValues[match.group(1)!] = match.group(2)!;
            }
          }
          continue;
        }

        if (m.role == MessageRole.assistant && m.missingFields != null && m.missingFields!.isNotEmpty && pendingSubmittedValues != null) {
          processedOld.insert(0, m.copyWith(submittedValues: pendingSubmittedValues));
          pendingSubmittedValues = null;
        } else {
          processedOld.insert(0, m);
        }
      }
      
      state = state.copyWith(
        messages: [...processedOld, ...state.messages],
        hasMoreHistory: processedOld.isNotEmpty && oldMessagesRaw.length >= 20,
        currentPage: state.currentPage + 1,
        isLoadingHistory: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingHistory: false);
      // Handle error gracefully if needed
    }
  }

  Future<void> startNewChat() async {
    await _repository.clearConversation();
    state = ChatState();
  }

  Future<void> switchConversation(String id) async {
    await _repository.setConversation(id);
    state = ChatState();
    await loadHistory();
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? fieldValues}) async {
    final tempUserId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';
    final tempAssistantId = 'temp_assistant_${DateTime.now().millisecondsSinceEpoch}';

    final userMessage = ChatMessage(
      id: tempUserId,
      role: MessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    );
    
    final assistantTypingMessage = ChatMessage(
      id: tempAssistantId,
      role: MessageRole.assistant,
      text: '',
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );

    // Optimistic update
    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantTypingMessage],
    );

    try {
      final response = await _repository.sendMessage(
        message: text,
        fieldValues: fieldValues,
      );
      
      // Update assistant message with the response, mark it as streaming so UI knows to animate
      final streamingResponse = response.copyWith(status: MessageStatus.streaming);
      
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == tempAssistantId) return streamingResponse;
          return m;
        }).toList(),
      );
      
      // Refresh conversation list so the drawer reflects the updated or newly created conversation
      _ref.read(conversationProvider.notifier).loadConversations(refresh: true);
    } catch (e) {
      // On error, remove the typing message and update the user message to error status
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == tempUserId) return m.copyWith(status: MessageStatus.error);
          return m;
        }).where((m) => m.id != tempAssistantId).toList(),
      );
      rethrow; // Rethrow to let UI show toast/banner
    }
  }
  
  Future<void> submitForm(String messageId, String text, Map<String, dynamic> fieldValues) async {
    // 1. Mark the form as submitted locally
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(submittedValues: fieldValues);
        }
        return m;
      }).toList(),
    );

    // 2. Send the message but don't show the user's optimistic text message
    final tempAssistantId = 'temp_assistant_${DateTime.now().millisecondsSinceEpoch}';

    final assistantTypingMessage = ChatMessage(
      id: tempAssistantId,
      role: MessageRole.assistant,
      text: '',
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, assistantTypingMessage],
    );

    try {
      final response = await _repository.sendMessage(
        message: text,
        fieldValues: fieldValues,
      );
      
      final streamingResponse = response.copyWith(status: MessageStatus.streaming);
      
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == tempAssistantId) return streamingResponse;
          return m;
        }).toList(),
      );
      
      _ref.read(conversationProvider.notifier).loadConversations(refresh: true);
    } catch (e) {
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempAssistantId).toList(),
      );
      rethrow;
    }
  }
  
  void markMessageAsSent(String id) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == id && m.status == MessageStatus.streaming) {
          return m.copyWith(status: MessageStatus.sent);
        }
        return m;
      }).toList(),
    );
  }

  void deleteMessage(String id) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != id).toList(),
    );
  }

  void markCardAsHandled(String id) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == id && m.resultCard != null) {
          final updatedPayload = Map<String, dynamic>.from(m.resultCard!.payload);
          updatedPayload['handled'] = true;
          return m.copyWith(
            resultCard: ChatResultCard(
              type: m.resultCard!.type,
              payload: updatedPayload,
            ),
          );
        }
        return m;
      }).toList(),
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider), ref);
});
