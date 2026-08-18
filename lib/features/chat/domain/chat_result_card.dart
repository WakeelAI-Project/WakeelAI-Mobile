class ChatResultCard {
  final String type;
  final Map<String, dynamic> payload;

  ChatResultCard({
    required this.type,
    required this.payload,
  });

  factory ChatResultCard.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'unknown';
    return ChatResultCard(
      type: type,
      payload: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...payload,
      'type': type,
    };
  }
}
