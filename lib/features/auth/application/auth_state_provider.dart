import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../chat/application/chat_provider.dart';
import '../../chat/application/conversation_provider.dart';
import '../../chat/data/chat_storage.dart';

enum AuthState { loading, authenticated, unauthenticated }

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return AuthState.loading;
  }

  Future<void> _init() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    state = (token != null && token.isNotEmpty) 
        ? AuthState.authenticated 
        : AuthState.unauthenticated;
  }

  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearTokens();
    
    try {
      await ref.read(chatStorageProvider).clearConversationId();
    } catch (_) {}
    
    ref.invalidate(chatProvider);
    ref.invalidate(conversationProvider);
    
    state = AuthState.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
