import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // A single shared instance of DatabaseHelper.
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Future<Database>? _databaseFuture;

  static const String databaseName = 'adaptive_focus_studio.db';
  static const int databaseVersion = 1;

  // Return the existing database or open it once.
  Future<Database> get database {
    return _databaseFuture ??= _openDatabaseSafely();
  }

  Future<Database> _openDatabaseSafely() async {
    try {
      return await _initializeDatabase();
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  // Open the SQLite database stored on the device.
  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        // Create the parent table for reusable focus presets.
        await db.execute('''
    CREATE TABLE FocusPreset (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      label TEXT NOT NULL CHECK(length(trim(label)) > 0),
      moodTag TEXT NOT NULL,
      plannedSeconds INTEGER NOT NULL CHECK(plannedSeconds > 0)
    )
  ''');

        // Create the child table for session history.
        await db.execute('''
    CREATE TABLE SessionLog (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      presetId INTEGER NOT NULL,
      startedAt INTEGER NOT NULL,
      completedSeconds INTEGER NOT NULL CHECK(completedSeconds >= 0),
      moodTagSnapshot TEXT NOT NULL,
      status TEXT NOT NULL,
      source TEXT NOT NULL,
      note TEXT,
      FOREIGN KEY (presetId)
        REFERENCES FocusPreset(id)
        ON DELETE RESTRICT
    )
  ''');
      },
    );
  }
}
