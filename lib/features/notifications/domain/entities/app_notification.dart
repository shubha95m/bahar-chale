class AppNotification {
  final String id;
  final String recipientId;
  final String notificationType;
  final String? referenceId;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.notificationType,
    this.referenceId,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      recipientId: map['recipient_id'] as String,
      notificationType: (map['notification_type'] as String?) ?? 'general',
      referenceId: map['reference_id'] as String?,
      title: (map['title'] as String?) ?? 'सूचना',
      body: (map['body'] as String?) ?? '',
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at'] as String) : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'notification_type': notificationType,
      'reference_id': referenceId,
      'title': title,
      'body': body,
      'read_at': readAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
