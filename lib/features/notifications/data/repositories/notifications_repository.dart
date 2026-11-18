import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsRepository {
  final SupabaseClient _client;

  NotificationsRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Fetches recent notifications for a user
  Future<List<AppNotification>> getNotifications(String userId, {int limit = 20}) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((row) => AppNotification.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Gets unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .filter('read_at', 'is', null);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting unread notification count: $e');
      return 0;
    }
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Marks all notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('recipient_id', userId)
          .filter('read_at', 'is', null);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Subscribes to real-time notification events for a specific user
  RealtimeChannel subscribeToUserNotifications({
    required String userId,
    required void Function() onChange,
  }) {
    final channel = _client.channel('public:notifications:$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: userId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();

    return channel;
  }

  /// Creates a notification for a user
  Future<void> sendNotification({
    required String recipientId,
    required String notificationType,
    required String title,
    required String body,
    String? referenceId,
  }) async {
    try {
      await _client.from('notifications').insert({
        'recipient_id': recipientId,
        'notification_type': notificationType,
        'title': title,
        'body': body,
        'reference_id': referenceId,
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
