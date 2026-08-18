class ChatCitation {
  final String title;
  final String type;
  final String section;
  final String url;

  ChatCitation({
    required this.title,
    required this.type,
    required this.section,
    required this.url,
  });

  factory ChatCitation.fromJson(Map<String, dynamic> json) {
    return ChatCitation(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      section: json['section'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'section': section,
      'url': url,
    };
  }
}
