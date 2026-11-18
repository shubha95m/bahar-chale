import 'package:flutter_test/flutter_test.dart';
import 'package:bahar_chale/features/notifications/domain/entities/app_notification.dart';

void main() {
  group('AppNotification Model & Logic', () {
    test('Correctly identifies unread notification when readAt is null', () {
      final notif = AppNotification(
        id: 'notif-1',
        recipientId: 'user-1',
        notificationType: 'ride_offer',
        title: 'सवारी प्रस्ताव',
        body: 'एक चालक ने सवारी प्रस्तुत की है',
        referenceId: 'req-123',
        readAt: null,
        createdAt: DateTime.now(),
      );

      expect(notif.isUnread, isTrue);
    });

    test('Correctly identifies read notification when readAt is present', () {
      final notif = AppNotification(
        id: 'notif-2',
        recipientId: 'user-1',
        notificationType: 'ride_accepted',
        title: 'स्वीकृत',
        body: 'अनुरोध स्वीकृत हुआ',
        referenceId: 'req-123',
        readAt: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(notif.isUnread, isFalse);
    });

    test('Serialization round-trip parses correctly', () {
      final map = {
        'id': 'notif-abc',
        'recipient_id': 'user-xyz',
        'notification_type': 'ride_request',
        'reference_id': 'ref-999',
        'title': 'नया अनुरोध',
        'body': 'यात्री ने अनुरोध किया',
        'read_at': null,
        'created_at': '2026-11-18T10:00:00.000Z',
      };

      final notif = AppNotification.fromMap(map);
      expect(notif.id, equals('notif-abc'));
      expect(notif.recipientId, equals('user-xyz'));
      expect(notif.notificationType, equals('ride_request'));
      expect(notif.referenceId, equals('ref-999'));
      expect(notif.title, equals('नया अनुरोध'));
      expect(notif.body, equals('यात्री ने अनुरोध किया'));
      expect(notif.isUnread, isTrue);

      final serialized = notif.toMap();
      expect(serialized['id'], equals('notif-abc'));
      expect(serialized['recipient_id'], equals('user-xyz'));
      expect(serialized['read_at'], isNull);
    });
  });
}
