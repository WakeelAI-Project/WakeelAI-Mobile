import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/chat_message.dart';

class ChatRateLimitException implements Exception {
  final int retryAfterSeconds;
  ChatRateLimitException(this.retryAfterSeconds);
}

class ChatResponse {
  final ChatMessage message;
  final String? conversationId;

  ChatResponse({required this.message, this.conversationId});
}

class ChatApiClient {
  final Dio _dio;

  ChatApiClient(this._dio);

  Future<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
    String? language,
    Map<String, dynamic>? fieldValues,
  }) async {
    try {
      final data = <String, dynamic>{
        'message': message,
      };
      if (conversationId != null) {
        data['conversation_id'] = conversationId;
      }
      data['language'] = language ?? 'EN';
      data['field_values'] = (fieldValues != null && fieldValues.isNotEmpty) 
          ? fieldValues 
          : <String, dynamic>{};

      final response = await _dio.post(
        '/api/ai/chat', 
        data: data,
        options: Options(receiveTimeout: const Duration(seconds: 65)),
      );
      final responseData = (response.data is String) 
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      
      return ChatResponse(
        message: ChatMessage.fromJson(responseData),
        conversationId: responseData['conversation_id'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        final retryAfterStr = e.response?.headers.value('Retry-After');
        final retryAfter = int.tryParse(retryAfterStr ?? '60') ?? 60;
        throw ChatRateLimitException(retryAfter);
      }
      rethrow;
    }
  }

  Future<dynamic> getHistory({
    required String conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/ai/chat/history',
      queryParameters: {
        'conversation_id': conversationId,
        'chat_id': conversationId,
        'id': conversationId,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<dynamic> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/ai/chat/conversations',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }
}

final chatApiClientProvider = Provider<ChatApiClient>((ref) {
  return ChatApiClient(ref.watch(dioClientProvider));
});
