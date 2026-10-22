import '../database/database_helper.dart';
import '../models/focus_preset.dart';
import 'focus_preset_repository.dart';

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
  Future<FocusPreset?> getPresetById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<int> updatePreset(FocusPreset preset) {
    throw UnimplementedError();
  }

  @override
  Future<int> deletePreset(int id) {
    throw UnimplementedError();
  }
}
