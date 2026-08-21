import 'dart:io' as io;
import 'dart:convert' as convert;

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
    try {
      final file = io.File('C:\\Users\\USER\\Desktop\\WakeelAI-Mobile\\missing_fields_log.txt');
      file.writeAsStringSync('${convert.jsonEncode(json)}\n', mode: io.FileMode.append);
    } catch (_) {}

    // 1. Fallback for input_type
    String t = json['input_type'] ?? json['type'] ?? 'text';

    // 2. Fallback for field_name
    final nameVal = json['field_name'] ?? json['name'] ?? '';
    final nameLower = nameVal.toString().toLowerCase();
    final labelLower = (json['label']?.toString().toLowerCase() ?? '');

    // ... [Keep existing type inference logic] ...
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
      name: nameVal, // <-- Use the newly extracted nameVal
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
