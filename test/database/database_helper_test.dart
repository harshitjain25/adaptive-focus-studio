import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io';

import 'package:adaptive_focus_studio/database/database_helper.dart';

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    testDirectory = await Directory.systemTemp.createTemp(
      'database_helper_tests_',
    );

    await databaseFactory.setDatabasesPath(testDirectory.path);
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

  test('Rejects preset with invalid duration', () async {
    final db = await DatabaseHelper.instance.database;

    expect(
      () async => db.insert('FocusPreset', {
        'label': 'Invalid Preset',
        'moodTag': 'Calm',
        'plannedSeconds': -10,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('Rejects session with invalid preset reference', () async {
    final db = await DatabaseHelper.instance.database;

    expect(
      () async => db.insert('SessionLog', {
        'presetId': -999,
        'startedAt': DateTime.now().millisecondsSinceEpoch,
        'completedSeconds': 1200,
        'moodTagSnapshot': 'Calm',
        'status': 'finished',
        'source': 'timer',
        'note': null,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('Prevents deleting preset with linked sessions', () async {
    final db = await DatabaseHelper.instance.database;

    final presetId = await db.insert('FocusPreset', {
      'label': 'Study Session',
      'moodTag': 'Focused',
      'plannedSeconds': 1500,
    });

    await db.insert('SessionLog', {
      'presetId': presetId,
      'startedAt': DateTime.now().millisecondsSinceEpoch,
      'completedSeconds': 1200,
      'moodTagSnapshot': 'Focused',
      'status': 'finished',
      'source': 'timer',
      'note': null,
    });

    expect(
      () async =>
          db.delete('FocusPreset', where: 'id = ?', whereArgs: [presetId]),
      throwsA(isA<DatabaseException>()),
    );

    // Verify that the parent record still exists.
    final presets = await db.query(
      'FocusPreset',
      where: 'id = ?',
      whereArgs: [presetId],
    );

    expect(presets.length, 1);
  });
}
