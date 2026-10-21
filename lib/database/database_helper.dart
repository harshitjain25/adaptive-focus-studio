import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // A single shared instance of DatabaseHelper.
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  static const String databaseName = 'adaptive_focus_studio.db';
  static const int databaseVersion = 1;

  // Return the existing database or open it once.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
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
        // Table creation will be added in the next step.
      },
    );
  }
}
