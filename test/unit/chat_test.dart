import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/chat/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage Model', () {
    test('ChatMessage parsing with sender profile name', () {
      final map = {
        'id': 'msg-1',
        'ride_request_id': 'req-1',
        'sender_id': 'user-1',
        'message_body': 'नमस्ते, हम 8 बजे मिल सकते हैं?',
        'created_at': '2026-11-17T12:30:00Z',
        'profiles': {
          'display_name': 'राहुल शर्मा',
        },
      };

      final msg = ChatMessage.fromMap(map);
      expect(msg.id, 'msg-1');
      expect(msg.messageBody, 'नमस्ते, हम 8 बजे मिल सकते हैं?');
      expect(msg.senderName, 'राहुल शर्मा');

      final serialized = msg.toMap();
      expect(serialized['ride_request_id'], 'req-1');
      expect(serialized['message_body'], 'नमस्ते, हम 8 बजे मिल सकते हैं?');
    });
  });
}
