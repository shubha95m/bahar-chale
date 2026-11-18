import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/configuration/supabase_config.dart';
import '../../domain/entities/chat_message.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  /// Fetches historical messages for a ride request conversation
  Future<List<ChatMessage>> getMessages(String requestId) async {
    final response = await _client
        .from('ride_messages')
        .select('*, profiles:sender_id(display_name)')
        .eq('ride_request_id', requestId)
        .order('created_at', ascending: true);

    return (response as List).map((row) => ChatMessage.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Sends a new message in the conversation
  Future<ChatMessage> sendMessage({
    required String requestId,
    required String senderId,
    required String body,
  }) async {
    final response = await _client
        .from('ride_messages')
        .insert({
          'ride_request_id': requestId,
          'sender_id': senderId,
          'message_body': body.trim(),
        })
        .select('*, profiles:sender_id(display_name)')
        .single();

    return ChatMessage.fromMap(response);
  }

  /// Subscribes to Realtime messages for this conversation
  RealtimeChannel subscribeToMessages({
    required String requestId,
    required void Function(Map<String, dynamic> payload) onInsert,
  }) {
    final channel = _client.channel('chat:$requestId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ride_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ride_request_id',
            value: requestId,
          ),
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  /// Marks all incoming messages for this conversation as read
  Future<void> markMessagesAsRead({
    required String requestId,
    required String currentUserId,
  }) async {
    try {
      await _client
          .from('ride_messages')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('ride_request_id', requestId)
          .neq('sender_id', currentUserId)
          .filter('read_at', 'is', null);
    } catch (_) {}
  }

  /// Calculates the count of distinct conversations that have unread incoming messages
  Future<int> getUnreadConversationsCount(String userId) async {
    try {
      final asRider = await _client
          .from('ride_requests')
          .select('id')
          .eq('requester_id', userId);
      final asDriver = await _client
          .from('ride_requests')
          .select('id, rides!inner(owner_id)')
          .eq('rides.owner_id', userId);

      final Set<String> requestIds = {};
      for (final row in (asRider as List)) {
        final id = row['id']?.toString();
        if (id != null) requestIds.add(id);
      }
      for (final row in (asDriver as List)) {
        final id = row['id']?.toString();
        if (id != null) requestIds.add(id);
      }

      if (requestIds.isEmpty) return 0;

      final unreadMessages = await _client
          .from('ride_messages')
          .select('ride_request_id')
          .inFilter('ride_request_id', requestIds.toList())
          .neq('sender_id', userId)
          .filter('read_at', 'is', null);

      final Set<String> unreadConversationIds = {};
      for (final m in (unreadMessages as List)) {
        final reqId = m['ride_request_id']?.toString();
        if (reqId != null) unreadConversationIds.add(reqId);
      }

      return unreadConversationIds.length;
    } catch (_) {
      return 0;
    }
  }

  /// Subscribes to global realtime message changes to track unread count dynamically
  RealtimeChannel subscribeToUnreadMessages({
    required void Function() onChange,
  }) {
    final channel = _client.channel('public:ride_messages_unread');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ride_messages',
          callback: (_) => onChange(),
        )
        .subscribe();

    return channel;
  }
}
