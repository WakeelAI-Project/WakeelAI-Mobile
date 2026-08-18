import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ChatStorage {
  Future<void> saveConversationId(String conversationId);
  Future<String?> readConversationId();
  Future<void> clearConversationId();
}

class SecureChatStorage implements ChatStorage {
  SecureChatStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _conversationIdKey = 'active_conversation_id';

  @override
  Future<void> saveConversationId(String conversationId) async {
    await _storage.write(key: _conversationIdKey, value: conversationId);
  }

  @override
  Future<String?> readConversationId() async {
    final val = await _storage.read(key: _conversationIdKey);
    if (val != null && val.isEmpty) return null;
    return val;
  }

  @override
  Future<void> clearConversationId() async {
    await _storage.delete(key: _conversationIdKey);
    // Workaround for flutter_secure_storage where delete() silently fails on some Android devices.
    await _storage.write(key: _conversationIdKey, value: '');
  }
}

final chatStorageProvider = Provider<ChatStorage>((ref) {
  return SecureChatStorage(const FlutterSecureStorage());
});
