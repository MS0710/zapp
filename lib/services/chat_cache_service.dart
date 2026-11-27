import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat/chat_message.dart';

class ChatCacheService {
  static const String _dbName = 'chat_cache.db';
  static const String _tableName = 'chat_room_cache';

  static Database? _db;
  static Future<Database>? _opening;

  Future<List<ChatMessage>> readRoomMessages(int roomId) async {
    final db = await _open();
    final rows = await db.query(
      _tableName,
      columns: ['messages_json'],
      where: 'room_id = ?',
      whereArgs: [roomId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return const <ChatMessage>[];
    }

    final raw = (rows.first['messages_json'] ?? '').toString();
    if (raw.trim().isEmpty) {
      return const <ChatMessage>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <ChatMessage>[];
    }

    return decoded.map((e) {
      if (e is! Map<String, dynamic>) {
        return null;
      }
      return ChatMessage.fromJson(Map<String, dynamic>.from(e));
    }).whereType<ChatMessage>().toList();
  }

  Future<void> writeRoomMessages(int roomId, List<ChatMessage> messages) async {
    final db = await _open();
    final existingOffset = await readScrollOffset(roomId);
    final payload = messages
        .where((m) => !m.isPending)
        .map((e) => e.toJson())
        .toList();

    await db.insert(
      _tableName,
      <String, Object?>{
        'room_id': roomId,
        'messages_json': jsonEncode(payload),
        'scroll_offset': existingOffset,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> readScrollOffset(int roomId) async {
    final db = await _open();
    final rows = await db.query(
      _tableName,
      columns: ['scroll_offset'],
      where: 'room_id = ?',
      whereArgs: [roomId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first['scroll_offset'];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}');
  }

  Future<void> writeScrollOffset(int roomId, double offset) async {
    final db = await _open();
    final rows = await db.query(
      _tableName,
      columns: ['messages_json'],
      where: 'room_id = ?',
      whereArgs: [roomId],
      limit: 1,
    );

    final messagesJson = rows.isEmpty
        ? '[]'
        : (rows.first['messages_json'] ?? '[]').toString();

    await db.insert(
      _tableName,
      <String, Object?>{
        'room_id': roomId,
        'messages_json': messagesJson,
        'scroll_offset': offset,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Database> _open() async {
    if (_db != null) {
      return _db!;
    }

    if (_opening != null) {
      return _opening!;
    }

    _opening = _openInternal();
    _db = await _opening!;
    _opening = null;
    return _db!;
  }

  Future<Database> _openInternal() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            room_id INTEGER PRIMARY KEY,
            messages_json TEXT NOT NULL DEFAULT '[]',
            scroll_offset REAL,
            updated_at TEXT
          )
        ''');
      },
    );
  }
}
