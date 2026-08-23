import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/theme/app_theme.dart';
import 'package:wakeel_ai_app/features/chat/data/chat_api_client.dart';
import 'package:wakeel_ai_app/features/chat/data/chat_repository.dart';
import 'package:wakeel_ai_app/features/chat/data/chat_storage.dart';
import 'package:wakeel_ai_app/features/chat/domain/chat_message.dart';
import 'package:wakeel_ai_app/features/chat/domain/chat_result_card.dart';
import 'package:wakeel_ai_app/features/chat/presentation/widgets/result_card_renderer.dart';

class _FakeChatStorage implements ChatStorage {
  @override
  Future<void> saveConversationId(String conversationId) async {}
  @override
  Future<String?> readConversationId() async => null;
  @override
  Future<void> clearConversationId() async {}
}

class _RecordingChatRepository extends ChatRepository {
  _RecordingChatRepository() : super(ChatApiClient(Dio()), _FakeChatStorage());

  final List<String> sentMessages = [];

  @override
  Future<List<ChatMessage>> getHistory({int page = 1, int limit = 20}) async => [];

  @override
  Future<ChatMessage> sendMessage({
    required String message,
    String? language,
    Map<String, dynamic>? fieldValues,
  }) async {
    sentMessages.add(message);
    return ChatMessage(
      id: 'reply-${sentMessages.length}',
      role: MessageRole.assistant,
      text: 'ok',
      timestamp: DateTime.now(),
    );
  }
}

/// FIX-05: the assistant chat can render an action-confirmation prompt and a
/// multi-choice disambiguation prompt without crashing or falling back to
/// raw/unparsed text - each button sends the user's reply as the next chat
/// turn, since resolution happens through conversation, not a direct call.
void main() {
  late _RecordingChatRepository repository;

  Widget wrap(ChatResultCard card) {
    repository = _RecordingChatRepository();
    return ProviderScope(
      overrides: [
        chatRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.build(brightness: Brightness.light, highContrast: false, isArabic: false),
        home: Scaffold(
          body: ResultCardRenderer(card: card, messageId: 'msg-1'),
        ),
      ),
    );
  }

  testWidgets('confirmation card renders the message and sends the confirm reply on tap', (tester) async {
    await tester.pumpWidget(wrap(ChatResultCard.fromJson({
      'type': 'confirmation',
      'message': 'Submit your Annual leave from 2026-03-01 to 2026-03-03?',
      'confirm_prompt': 'yes, confirm',
      'cancel_prompt': 'no, cancel',
    })));
    await tester.pumpAndSettle();

    expect(find.textContaining('Submit your Annual leave'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(repository.sentMessages, contains('yes, confirm'));
  });

  testWidgets('disambiguation card lists every option and sends its description on tap', (tester) async {
    await tester.pumpWidget(wrap(ChatResultCard.fromJson({
      'type': 'needs_disambiguation',
      'message': 'Which draft did you mean?',
      'options': [
        {'request_id': 'req-1', 'leave_type': 'Annual', 'start_date': '2026-03-01', 'end_date': '2026-03-03'},
        {'request_id': 'req-2', 'leave_type': 'Sick', 'start_date': '2026-04-01', 'end_date': '2026-04-02'},
      ],
    })));
    await tester.pumpAndSettle();

    expect(find.text('Which draft did you mean?'), findsOneWidget);
    expect(find.textContaining('Annual'), findsOneWidget);
    expect(find.textContaining('Sick'), findsOneWidget);

    await tester.tap(find.textContaining('Annual'));
    await tester.pumpAndSettle();

    expect(repository.sentMessages, hasLength(1));
    expect(repository.sentMessages.first, contains('Annual'));
  });

  testWidgets('unrecognized card type renders nothing rather than crashing', (tester) async {
    await tester.pumpWidget(wrap(ChatResultCard.fromJson({'type': 'something_new'})));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
