import 'chat_citation.dart';
import 'chat_missing_field.dart';
import 'chat_result_card.dart';

enum MessageRole { user, assistant }

enum MessageStatus { sending, sent, streaming, error }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final MessageStatus status;
  final List<ChatCitation>? citations;
  final List<ChatMissingField>? missingFields;
  final ChatResultCard? resultCard;
  final Map<String, dynamic>? submittedValues;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.status = MessageStatus.sent,
    this.citations,
    this.missingFields,
    this.resultCard,
    this.submittedValues,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? json['chat_id'] ?? DateTime.now().toIso8601String(),
      role: (json['role'] == 'user' || json['role'] == 'human') ? MessageRole.user : MessageRole.assistant,
      text: json['text'] ?? json['reply'] ?? json['message'] ?? json['content'] ?? '',
      status: MessageStatus.sent,
      citations: (json['sources'] as List<dynamic>?)
          ?.map((e) => ChatCitation.fromJson(e as Map<String, dynamic>))
          .toList(),
      missingFields: (json['missing_fields'] as List<dynamic>?)
          ?.map((e) => ChatMissingField.fromJson(e as Map<String, dynamic>))
          .toList(),
      resultCard: json['result_card'] != null
          ? ChatResultCard.fromJson(json['result_card'] as Map<String, dynamic>)
          : null,
      submittedValues: json['submitted_values'] as Map<String, dynamic>?,
      timestamp: (json['createdAt'] != null || json['created_at'] != null || json['timestamp'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['created_at'] ?? json['timestamp']).toString()) ?? DateTime.now()
          : DateTime.now()).toLocal(),
    );
  }

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? text,
    MessageStatus? status,
    List<ChatCitation>? citations,
    List<ChatMissingField>? missingFields,
    ChatResultCard? resultCard,
    Map<String, dynamic>? submittedValues,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      status: status ?? this.status,
      citations: citations ?? this.citations,
      missingFields: missingFields ?? this.missingFields,
      resultCard: resultCard ?? this.resultCard,
      submittedValues: submittedValues ?? this.submittedValues,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
