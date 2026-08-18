class ChatMissingField {
  final String name;
  final String label;
  final String type; // text, number, dropdown, date, file
  final bool required;
  final List<String>? options;

  ChatMissingField({
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    this.options,
  });

  factory ChatMissingField.fromJson(Map<String, dynamic> json) {
    String t = json['type'] ?? 'text';
    final nameLower = (json['name']?.toString().toLowerCase() ?? '');
    final labelLower = (json['label']?.toString().toLowerCase() ?? '');
    
    // Fallback: AI sometimes provides type "string" for documents/reports and dates.
    if (t == 'string' || t == 'text') {
      if (nameLower.contains('file') || nameLower.contains('document') || nameLower.contains('report') || nameLower.contains('certificate') ||
          labelLower.contains('file') || labelLower.contains('document') || labelLower.contains('report') || labelLower.contains('certificate')) {
        t = 'file';
      } else if (nameLower.contains('date') || labelLower.contains('date')) {
        t = 'date';
      }
    }

    return ChatMissingField(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: t,
      required: json['required'] ?? false,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'required': required,
      if (options != null) 'options': options,
    };
  }
}
