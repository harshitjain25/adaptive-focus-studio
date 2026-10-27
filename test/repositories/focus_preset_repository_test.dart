import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io';

import 'package:adaptive_focus_studio/database/database_helper.dart';
import 'package:adaptive_focus_studio/models/focus_preset.dart';
import 'package:adaptive_focus_studio/repositories/sqlite_focus_preset_repository.dart';

void main() {
  late SQLiteFocusPresetRepository repository;
  late Database db;
  late Directory testDirectory;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Each test suite receives a unique database directory.
    testDirectory = await Directory.systemTemp.createTemp(
      'focus_preset_tests_',
    );

    await databaseFactory.setDatabasesPath(testDirectory.path);
  });

  setUp(() async {
    repository = SQLiteFocusPresetRepository();
    db = await DatabaseHelper.instance.database;

    // Clear previous test data.
    await db.delete('SessionLog');
    await db.delete('FocusPreset');
  });

  test('Creates a valid FocusPreset', () async {
    final preset = FocusPreset(
      label: 'Math Study',
      moodTag: 'Focused',
      plannedSeconds: 1500,
    );

    final id = await repository.createPreset(preset);

    expect(id, greaterThan(0));
  });

  test('Reads a FocusPreset by ID', () async {
    final id = await repository.createPreset(
      FocusPreset(
        label: 'Python Practice',
        moodTag: 'Calm',
        plannedSeconds: 1800,
      ),
    );

    final result = await repository.getPresetById(id);

    expect(result, isNotNull);
    expect(result!.label, 'Python Practice');
    expect(result.plannedSeconds, 1800);
  });

  test('Reads all saved FocusPresets', () async {
    await repository.createPreset(
      FocusPreset(label: 'Reading', moodTag: 'Calm', plannedSeconds: 1200),
    );

    await repository.createPreset(
      FocusPreset(label: 'Coding', moodTag: 'Focused', plannedSeconds: 2400),
    );

    final results = await repository.getAllPresets();

    expect(results.length, 2);
  });

  test('Updates an existing FocusPreset', () async {
    final id = await repository.createPreset(
      FocusPreset(label: 'Old Preset', moodTag: 'Calm', plannedSeconds: 1500),
    );

    final updatedPreset = FocusPreset(
      id: id,
      label: 'Updated Preset',
      moodTag: 'Focused',
      plannedSeconds: 2100,
    );

    final affectedRows = await repository.updatePreset(updatedPreset);
    final result = await repository.getPresetById(id);

    expect(affectedRows, 1);
    expect(result!.label, 'Updated Preset');
    expect(result.plannedSeconds, 2100);
  });

  test('Deletes a FocusPreset without session history', () async {
    final id = await repository.createPreset(
      FocusPreset(label: 'Temporary', moodTag: 'Calm', plannedSeconds: 900),
    );

    final deletedRows = await repository.deletePreset(id);
    final result = await repository.getPresetById(id);

    expect(deletedRows, 1);
    expect(result, isNull);
  });

  test('Rejects an empty preset label', () async {
    final preset = FocusPreset(
      label: '   ',
      moodTag: 'Calm',
      plannedSeconds: 1500,
    );

    await expectLater(repository.createPreset(preset), throwsArgumentError);
  });

  test('Rejects invalid planned duration', () async {
    final preset = FocusPreset(
      label: 'Invalid Duration',
      moodTag: 'Focused',
      plannedSeconds: -100,
    );

    await expectLater(repository.createPreset(preset), throwsArgumentError);
  });
}
