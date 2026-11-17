class ChatMessage {
  final String id;
  final String rideRequestId;
  final String senderId;
  final String messageBody;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? senderName;

  const ChatMessage({
    required this.id,
    required this.rideRequestId,
    required this.senderId,
    required this.messageBody,
    required this.createdAt,
    this.readAt,
    this.senderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ride_request_id': rideRequestId,
      'sender_id': senderId,
      'message_body': messageBody,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? senderName}) {
    return ChatMessage(
      id: map['id'] as String,
      rideRequestId: map['ride_request_id'] as String,
      senderId: map['sender_id'] as String,
      messageBody: map['message_body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at'] as String) : null,
      senderName: senderName ?? (map['profiles'] as Map<String, dynamic>?)?['display_name'] as String?,
    );
  }
}
