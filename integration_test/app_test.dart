import 'package:adaptive_focus_studio/main.dart';
import 'package:adaptive_focus_studio/models/focus_preset.dart';
import 'package:adaptive_focus_studio/models/session_log.dart';
import 'package:adaptive_focus_studio/providers/repository_providers.dart';
import 'package:adaptive_focus_studio/repositories/focus_preset_repository.dart';
import 'package:adaptive_focus_studio/repositories/session_log_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class FakeFocusPresetRepository
    implements FocusPresetRepository {
  final List<FocusPreset> _presets = [];

  int _nextId = 1;

  @override
  Future<int> createPreset(FocusPreset preset) async {
    final id = _nextId++;

    _presets.add(
      FocusPreset(
        id: id,
        label: preset.label,
        moodTag: preset.moodTag,
        plannedSeconds: preset.plannedSeconds,
      ),
    );

    return id;
  }

  @override
  Future<List<FocusPreset>> getAllPresets() async {
    return List.unmodifiable(_presets);
  }

  @override
  Future<FocusPreset?> getPresetById(int id) async {
    for (final preset in _presets) {
      if (preset.id == id) {
        return preset;
      }
    }

    return null;
  }

  @override
  Future<int> updatePreset(FocusPreset preset) async {
    final index = _presets.indexWhere(
      (item) => item.id == preset.id,
    );

    if (index == -1) {
      return 0;
    }

    _presets[index] = preset;

    return 1;
  }

  @override
  Future<int> deletePreset(int id) async {
    final before = _presets.length;

    _presets.removeWhere(
      (preset) => preset.id == id,
    );

    return before == _presets.length ? 0 : 1;
  }
}

class FakeSessionLogRepository
    implements SessionLogRepository {
  final List<SessionLog> logs = [];

  int _nextId = 1;

  @override
  Future<int> createSessionLog(SessionLog log) async {
    final id = _nextId++;

    logs.add(
      SessionLog(
        id: id,
        presetId: log.presetId,
        startedAt: log.startedAt,
        completedSeconds: log.completedSeconds,
        moodTagSnapshot: log.moodTagSnapshot,
        status: log.status,
        source: log.source,
        note: log.note,
      ),
    );

    return id;
  }

  @override
  Future<List<SessionLog>> getAllSessionLogs() async {
    return List.unmodifiable(logs);
  }

  @override
  Future<SessionLog?> getSessionLogById(int id) async {
    for (final log in logs) {
      if (log.id == id) {
        return log;
      }
    }

    return null;
  }

  @override
  Future<List<SessionLog>> getSessionsByPreset(
    int presetId,
  ) async {
    return logs
        .where(
          (log) => log.presetId == presetId,
        )
        .toList();
  }

  @override
  Future<int> updateSessionLog(SessionLog log) async {
    final index = logs.indexWhere(
      (item) => item.id == log.id,
    );

    if (index == -1) {
      return 0;
    }

    logs[index] = log;

    return 1;
  }

  @override
  Future<int> deleteSessionLog(int id) async {
    final before = logs.length;

    logs.removeWhere(
      (log) => log.id == id,
    );

    return before == logs.length ? 0 : 1;
  }

  @override
  Future<double?> getAverageCompletedSeconds({
    String? moodTag,
  }) async {
    final finished = logs.where((log) {
      final matchesStatus =
          log.status.toLowerCase() == 'finished';

      final matchesMood =
          moodTag == null ||
          log.moodTagSnapshot == moodTag;

      return matchesStatus && matchesMood;
    }).toList();

    if (finished.isEmpty) {
      return null;
    }

    final total = finished.fold<int>(
      0,
      (sum, log) => sum + log.completedSeconds,
    );

    return total / finished.length;
  }

  @override
  Future<int> getFinishedSessionCount({
    String? moodTag,
  }) async {
    return logs.where((log) {
      final matchesStatus =
          log.status.toLowerCase() == 'finished';

      final matchesMood =
          moodTag == null ||
          log.moodTagSnapshot == moodTag;

      return matchesStatus && matchesMood;
    }).length;
  }

  @override
  Future<List<SessionLog>> getRecentFinishedSessions({
    required String moodTag,
    int limit = 3,
  }) async {
    final matching = logs.where((log) {
      return log.status.toLowerCase() == 'finished' &&
          log.moodTagSnapshot == moodTag;
    }).toList();

    matching.sort(
      (a, b) => b.startedAt.compareTo(a.startedAt),
    );

    return matching.take(limit).toList();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'create preset, finish session, and view history',
    (tester) async {
      final presetRepository =
          FakeFocusPresetRepository();

      final sessionRepository =
          FakeSessionLogRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            focusPresetRepositoryProvider.overrideWithValue(
              presetRepository,
            ),
            sessionLogRepositoryProvider.overrideWithValue(
              sessionRepository,
            ),
          ],
          child: const AdaptiveFocusStudioApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Your Focus Dashboard'),
        findsOneWidget,
      );

      // CREATE PRESET
      await tester.scrollUntilVisible(
        find.text('Create Preset'),
        300,
      );

      await tester.tap(
        find.text('Create Preset'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Create Focus Preset'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'Integration Test Focus',
      );

      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Focused').last,
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Save Preset'),
      );

      await tester.pumpAndSettle();

      // VERIFY PRESET CREATED
      expect(
        presetRepository._presets.length,
        1,
      );

      expect(
        presetRepository._presets.first.label,
        'Integration Test Focus',
      );

      expect(
        presetRepository._presets.first.moodTag,
        'Focused',
      );

      // DASHBOARD SHOULD SHOW PRESET
      expect(
        find.text('Integration Test Focus'),
        findsOneWidget,
      );

      // OPEN FOCUS SESSION
      await tester.tap(
        find.text('Integration Test Focus'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Integration Test Focus'),
        findsOneWidget,
      );

      expect(
        find.text('Mood: Focused'),
        findsOneWidget,
      );

      // START SESSION
      await tester.tap(
        find.text('Start'),
      );

      await tester.pump(
        const Duration(seconds: 2),
      );

      // FINISH SESSION
      await tester.tap(
        find.text('Finish'),
      );

      await tester.pumpAndSettle();

      // VERIFY SESSION WAS SAVED
      expect(
        sessionRepository.logs.length,
        1,
      );

      expect(
        sessionRepository.logs.first.moodTagSnapshot,
        'Focused',
      );

      expect(
        sessionRepository.logs.first.status,
        'finished',
      );

      expect(
        sessionRepository.logs.first.presetId,
        1,
      );

      expect(
        find.text('Session finished'),
        findsOneWidget,
      );

      // RETURN TO DASHBOARD
      await tester.pageBack();

      await tester.pumpAndSettle();

      expect(
        find.text('Your Focus Dashboard'),
        findsOneWidget,
      );

      // OPEN HISTORY
      await tester.scrollUntilVisible(
        find.text('History & Insights'),
        300,
      );

      await tester.tap(
        find.text('History & Insights'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Your Progress'),
        findsOneWidget,
      );

      // VERIFY REAL HISTORY DATA
      expect(
        find.text('Focused'),
        findsWidgets,
      );

      expect(
        find.text('Sample count: 1'),
        findsOneWidget,
      );
    },
  );
}