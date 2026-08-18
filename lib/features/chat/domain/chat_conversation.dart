class ChatConversation {
  final String id;
  final String title;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: (json['id'] ?? json['conversation_id'] ?? json['conversationId'] ?? json['_id'] ?? json['chat_id'] ?? json['chatId'] ?? json['sessionId'] ?? json['session_id'] ?? '').toString(),
      title: json['title'] ?? 'New Chat',
      updatedAt: (json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.tryParse((json['updatedAt'] ?? json['updated_at']).toString()) ?? DateTime.now()
          : DateTime.now()).toLocal(),
    );
  }
}
