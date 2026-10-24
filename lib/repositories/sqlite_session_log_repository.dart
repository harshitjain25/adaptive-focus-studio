import '../database/database_helper.dart';
import '../models/session_log.dart';
import 'session_log_repository.dart';

class SQLiteSessionLogRepository implements SessionLogRepository {
  final DatabaseHelper _databaseHelper;

  SQLiteSessionLogRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  // Create a new session log.
  @override
  Future<int> createSessionLog(SessionLog log) async {
    if (log.presetId <= 0) {
      throw ArgumentError('A valid preset ID is required.');
    }

    if (log.completedSeconds < 0) {
      throw ArgumentError('Completed seconds cannot be negative.');
    }

    if (log.moodTagSnapshot.trim().isEmpty) {
      throw ArgumentError('Mood tag cannot be empty.');
    }

    final db = await _databaseHelper.database;

    final data = log.toMap();
    data.remove('id');

    // SQLite checks that presetId references an existing preset.
    return db.insert('SessionLog', data);
  }

  // Retrieve all saved session logs.
  @override
  Future<List<SessionLog>> getAllSessionLogs() async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'SessionLog',
      orderBy: 'startedAt DESC, id DESC',
    );

    return results.map((row) => SessionLog.fromMap(row)).toList();
  }

  @override
  Future<SessionLog?> getSessionLogById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<SessionLog>> getSessionsByPreset(int presetId) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateSessionLog(SessionLog log) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteSessionLog(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<SessionLog>> getRecentFinishedSessions({
    required String moodTag,
    int limit = 3,
  }) {
    throw UnimplementedError();
  }
}
