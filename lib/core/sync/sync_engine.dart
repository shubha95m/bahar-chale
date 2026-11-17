import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/local_database.dart';

enum OutboxOperation { create, update, delete }
enum SyncStatus { pending, syncing, synced, failed }

class SyncOutboxItem {
  final String id;
  final String entityType;
  final String entityId;
  final OutboxOperation operation;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final int attempts;
  final SyncStatus status;
  final String? lastError;
  final DateTime createdAt;

  SyncOutboxItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    this.attempts = 0,
    this.status = SyncStatus.pending,
    this.lastError,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation.name.toUpperCase(),
      'payload': jsonEncode(payload),
      'idempotency_key': idempotencyKey,
      'attempts': attempts,
      'status': status.name.toUpperCase(),
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  final _uuid = const Uuid();

  /// Enqueue an operation into local transactional outbox
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required OutboxOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = await LocalDatabase.instance;
    if (db == null) return;

    final item = SyncOutboxItem(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      idempotencyKey: '${entityType}_${entityId}_${operation.name}_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    await db.insert(
      'local_sync_outbox',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
