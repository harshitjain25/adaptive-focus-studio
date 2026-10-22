import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/database/database_helper.dart';

void main() {
  setUpAll(() {
    // Initialize SQLite for desktop testing.
    sqfliteFfiInit();

    // Use the FFI implementation instead of platform plugins.
    databaseFactory = databaseFactoryFfi;
  });

  test('Database creates FocusPreset and SessionLog tables', () async {
    // Open the database using our actual DatabaseHelper.
    final db = await DatabaseHelper.instance.database;

    // Read table names from SQLite's schema.
    final tables = await db.rawQuery('''
      SELECT name FROM sqlite_master
      WHERE type = 'table'
    ''');

    final tableNames = tables.map((table) => table['name'] as String).toList();

    expect(tableNames, contains('FocusPreset'));
    expect(tableNames, contains('SessionLog'));
  });

  test('SQLite foreign keys are enabled', () async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('PRAGMA foreign_keys');

    expect(result.first['foreign_keys'], 1);
  });
}
