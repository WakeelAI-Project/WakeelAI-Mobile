import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_message.dart';
import '../domain/chat_conversation.dart';
import 'chat_api_client.dart';
import 'chat_storage.dart';

class ChatRepository {
  final ChatApiClient _apiClient;
  final ChatStorage _storage;

  ChatRepository(this._apiClient, this._storage);

  Future<ChatMessage> sendMessage({
    required String message,
    String? language,
    Map<String, dynamic>? fieldValues,
  }) async {
    final conversationId = await _storage.readConversationId();
    final response = await _apiClient.sendMessage(
      message: message,
      conversationId: conversationId,
      language: language,
      fieldValues: fieldValues,
    );
    
    if (response.conversationId != null && response.conversationId != conversationId) {
      await _storage.saveConversationId(response.conversationId!);
    }
    
    return response.message;
  }

  Future<List<ChatMessage>> getHistory({int page = 1, int limit = 20}) async {
    final conversationId = await _storage.readConversationId();
    if (conversationId == null) {
      return [];
    }

    final data = await _apiClient.getHistory(
      conversationId: conversationId,
      page: page,
      limit: limit,
    );

    List<dynamic> messagesJson = [];
    if (data is List) {
      messagesJson = data;
    } else if (data is Map) {
      messagesJson = (data['messages'] ?? data['data'] ?? data['history'] ?? data['chat_history'] ?? data['chatHistory'] ?? data['conversation_history'] ?? []) as List<dynamic>;
    }

    return messagesJson
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatConversation>> getConversations({int page = 1, int limit = 20}) async {
    final data = await _apiClient.getConversations(page: page, limit: limit);
    
    List<dynamic> conversationsJson = [];
    if (data is List) {
      conversationsJson = data;
    } else if (data is Map) {
      conversationsJson = (data['conversations'] ?? data['data'] ?? []) as List<dynamic>;
    }
    
    return conversationsJson
        .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearConversation() async {
    await _storage.clearConversationId();
  }

  Future<void> setConversation(String id) async {
    await _storage.saveConversationId(id);
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(chatApiClientProvider),
    ref.watch(chatStorageProvider),
  );
});
