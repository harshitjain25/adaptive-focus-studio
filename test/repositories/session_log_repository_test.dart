import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/database/database_helper.dart';
import 'package:adaptive_focus_studio/models/focus_preset.dart';
import 'package:adaptive_focus_studio/models/session_log.dart';
import 'package:adaptive_focus_studio/repositories/sqlite_focus_preset_repository.dart';
import 'package:adaptive_focus_studio/repositories/sqlite_session_log_repository.dart';

void main() {
  late SQLiteFocusPresetRepository presetRepository;
  late SQLiteSessionLogRepository sessionRepository;
  late Database db;
  late Directory testDirectory;
  late int presetId;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    testDirectory = await Directory.systemTemp.createTemp('session_log_tests_');

    await databaseFactory.setDatabasesPath(testDirectory.path);

    db = await DatabaseHelper.instance.database;
    presetRepository = SQLiteFocusPresetRepository();
    sessionRepository = SQLiteSessionLogRepository();
  });

  setUp(() async {
    // Delete child records before parent records.
    await db.delete('SessionLog');
    await db.delete('FocusPreset');

    presetId = await presetRepository.createPreset(
      const FocusPreset(
        label: 'Computer Science',
        moodTag: 'Focused',
        plannedSeconds: 1500,
      ),
    );
  });

  SessionLog makeLog({
    int? id,
    int? preset,
    int seconds = 1200,
    String mood = 'Focused',
    String status = 'finished',
    DateTime? startedAt,
  }) {
    return SessionLog(
      id: id,
      presetId: preset ?? presetId,
      startedAt: startedAt ?? DateTime.utc(2026, 10, 20),
      completedSeconds: seconds,
      moodTagSnapshot: mood,
      status: status,
      source: 'timer',
      note: null,
    );
  }

  test('Creates a valid SessionLog', () async {
    final id = await sessionRepository.createSessionLog(makeLog());

    expect(id, greaterThan(0));

    final saved = await sessionRepository.getSessionLogById(id);
    expect(saved, isNotNull);
    expect(saved!.completedSeconds, 1200);
  });

  test('Reads all saved session logs', () async {
    await sessionRepository.createSessionLog(makeLog(seconds: 900));
    await sessionRepository.createSessionLog(makeLog(seconds: 1800));

    final logs = await sessionRepository.getAllSessionLogs();

    expect(logs.length, 2);
  });

  test('Reads session log by ID', () async {
    final id = await sessionRepository.createSessionLog(makeLog(seconds: 1500));

    final log = await sessionRepository.getSessionLogById(id);

    expect(log, isNotNull);
    expect(log!.id, id);
    expect(log.completedSeconds, 1500);
  });

  test('Filters sessions by preset', () async {
    final otherPresetId = await presetRepository.createPreset(
      const FocusPreset(label: 'Math', moodTag: 'Calm', plannedSeconds: 1800),
    );

    await sessionRepository.createSessionLog(makeLog());

    await sessionRepository.createSessionLog(
      makeLog(preset: otherPresetId, mood: 'Calm'),
    );

    final logs = await sessionRepository.getSessionsByPreset(presetId);

    expect(logs.length, 1);
    expect(logs.first.presetId, presetId);
  });

  test('Updates an existing SessionLog', () async {
    final id = await sessionRepository.createSessionLog(makeLog());

    final updated = makeLog(id: id, seconds: 2100);

    final affectedRows = await sessionRepository.updateSessionLog(updated);

    final saved = await sessionRepository.getSessionLogById(id);

    expect(affectedRows, 1);
    expect(saved!.completedSeconds, 2100);
  });

  test('Deletes a SessionLog', () async {
    final id = await sessionRepository.createSessionLog(makeLog());

    final deleted = await sessionRepository.deleteSessionLog(id);
    final result = await sessionRepository.getSessionLogById(id);

    expect(deleted, 1);
    expect(result, isNull);
  });

  test('Rejects negative completed duration', () async {
    await expectLater(
      sessionRepository.createSessionLog(makeLog(seconds: -10)),
      throwsArgumentError,
    );
  });

  test('Rejects nonexistent preset reference', () async {
    await expectLater(
      sessionRepository.createSessionLog(makeLog(preset: 999999)),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('Session Scout returns three most recent finished sessions', () async {
    final base = DateTime.utc(2026, 10, 20);

    Future<void> add(
      int seconds,
      int day, {
      String status = 'finished',
      String mood = 'Focused',
    }) async {
      await sessionRepository.createSessionLog(
        makeLog(
          seconds: seconds,
          startedAt: base.add(Duration(days: day)),
          status: status,
          mood: mood,
        ),
      );
    }

    await add(600, 0);
    await add(1200, 1);
    await add(1800, 2);
    await add(2400, 3);
    await add(3600, 4, status: 'cancelled');
    await add(900, 5, mood: 'Calm');
    await add(0, 6);

    final results = await sessionRepository.getRecentFinishedSessions(
      moodTag: 'Focused',
    );

    expect(results.length, 3);
    expect(results.map((log) => log.completedSeconds).toList(), [
      2400,
      1800,
      1200,
    ]);
  });
}
