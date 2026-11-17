import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database?> get instance async {
    if (kIsWeb) return null; // Web uses local browser storage & Supabase direct
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  static Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;

    try {
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final directory = await getApplicationDocumentsDirectory();
      final dbPath = p.join(directory.path, 'bahar_chale_cache.db');

      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Local cached rides for offline browsing
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_cached_rides (
              id TEXT PRIMARY KEY,
              owner_id TEXT NOT NULL,
              ride_category TEXT NOT NULL,
              vehicle_type TEXT,
              origin_city TEXT NOT NULL,
              origin_area TEXT,
              destination_city TEXT NOT NULL,
              destination_area TEXT,
              travel_date TEXT NOT NULL,
              travel_time TEXT,
              is_time_flexible INTEGER NOT NULL DEFAULT 1,
              total_seats INTEGER NOT NULL DEFAULT 1,
              available_seats INTEGER NOT NULL DEFAULT 1,
              contribution_amount REAL,
              notes TEXT,
              status TEXT NOT NULL DEFAULT 'open',
              updated_at TEXT NOT NULL
            );
          ''');

          // Local Sync Outbox for resilient offline actions
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_sync_outbox (
              id TEXT PRIMARY KEY,
              entity_type TEXT NOT NULL,
              entity_id TEXT NOT NULL,
              operation TEXT NOT NULL,
              payload TEXT NOT NULL,
              idempotency_key TEXT NOT NULL UNIQUE,
              attempts INTEGER DEFAULT 0,
              status TEXT DEFAULT 'PENDING',
              last_error TEXT,
              created_at TEXT NOT NULL
            );
          ''');
        },
      );
    } catch (_) {
      return null;
    }
  }
}
