import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../../core/storage/token_storage.dart';
import '../../chat/application/chat_provider.dart';
import '../../chat/application/conversation_provider.dart';
import '../../chat/data/chat_storage.dart';
import '../../home/data/employee_api_client.dart';

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
    if (state == AuthState.authenticated) _syncTimeZone();
  }

  void setAuthenticated() {
    state = AuthState.authenticated;
    _syncTimeZone();
  }

  /// Reports the device's current IANA time zone to the backend so
  /// date-sensitive calculations (e.g. the home screen's "on leave" elapsed
  /// day count) use the employee's own local day boundary instead of UTC.
  /// Runs on every fresh login and every app start with a valid session —
  /// unconditionally, since the write is idempotent and cheap, so there's no
  /// local state to keep in sync or risk drifting. Best-effort: a failure
  /// here (offline, plugin unavailable, etc.) must never block auth.
  Future<void> _syncTimeZone() async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      await ref.read(employeeApiClientProvider).updateTimeZone(timeZone.identifier);
    } catch (_) {
      // Best-effort — next login/app-start tries again.
    }
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
