import '../database/database_helper.dart';
import '../models/focus_preset.dart';
import 'focus_preset_repository.dart';

import 'package:sqflite/sqflite.dart';

class SQLiteFocusPresetRepository implements FocusPresetRepository {
  final DatabaseHelper _databaseHelper;

  SQLiteFocusPresetRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  // Create a new FocusPreset in SQLite.
  @override
  Future<int> createPreset(FocusPreset preset) async {
    final db = await _databaseHelper.database;

    if (preset.label.trim().isEmpty) {
      throw ArgumentError('Preset label cannot be empty.');
    }

    if (preset.plannedSeconds <= 0) {
      throw ArgumentError('Planned duration must be greater than zero.');
    }

    final data = preset.toMap();
    data.remove('id');

    return await db.insert('FocusPreset', data);
  }

  // Retrieve all saved FocusPresets.
  @override
  Future<List<FocusPreset>> getAllPresets() async {
    final db = await _databaseHelper.database;

    final results = await db.query('FocusPreset', orderBy: 'id DESC');

    return results.map((row) => FocusPreset.fromMap(row)).toList();
  }

  // These methods will be implemented in the next step.

  @override
  Future<FocusPreset?> getPresetById(int id) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'FocusPreset',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return FocusPreset.fromMap(results.first);
  }

  @override
  Future<int> updatePreset(FocusPreset preset) async {
    if (preset.id == null) {
      throw ArgumentError('Preset ID is required for updating.');
    }

    if (preset.label.trim().isEmpty) {
      throw ArgumentError('Preset label cannot be empty.');
    }

    if (preset.plannedSeconds <= 0) {
      throw ArgumentError('Planned duration must be greater than zero.');
    }

    final db = await _databaseHelper.database;

    final data = preset.toMap();
    data.remove('id');

    return db.update(
      'FocusPreset',
      data,
      where: 'id = ?',
      whereArgs: [preset.id],
    );
  }

  @override
  Future<int> deletePreset(int id) async {
    final db = await _databaseHelper.database;

    // Check whether the preset has linked session history.
    final linkedLogs = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM SessionLog WHERE presetId = ?',
      [id],
    );

    final count = Sqflite.firstIntValue(linkedLogs) ?? 0;

    if (count > 0) {
      throw StateError(
        'Cannot delete this preset because it has '
        'existing session history. Delete the linked '
        'session logs first.',
      );
    }

    return db.delete('FocusPreset', where: 'id = ?', whereArgs: [id]);
  }
}
