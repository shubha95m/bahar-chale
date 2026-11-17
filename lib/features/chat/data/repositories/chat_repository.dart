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
}
