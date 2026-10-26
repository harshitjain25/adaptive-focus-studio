import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/models/session_log.dart';
import 'package:adaptive_focus_studio/smart_helper/session_scout.dart';

void main() {
  group('SessionScout', () {
    test('returns median of 3 recent finished sessions with same mood', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20, 10),
          completedSeconds: 20 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21, 10),
          completedSeconds: 30 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22, 10),
          completedSeconds: 25 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, 25);
    });

    test('returns null when fewer than 3 matching finished sessions exist', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: 20 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 25 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, isNull);
    });

    test('ignores sessions with a different mood', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: 20 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 30 * 60,
          moodTagSnapshot: 'Calm',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22),
          completedSeconds: 25 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, isNull);
    });

    test('ignores unfinished sessions', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: 20 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 30 * 60,
          moodTagSnapshot: 'Focused',
          status: 'cancelled',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22),
          completedSeconds: 25 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, isNull);
    });

    test('clamps suggestion to minimum 10 minutes', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: 5 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 8 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22),
          completedSeconds: 9 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, 10);
    });

    test('clamps suggestion to maximum 60 minutes', () {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: 70 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 80 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22),
          completedSeconds: 90 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = SessionScout.suggestDuration(
        sessions: sessions,
        moodTag: 'Focused',
      );

      expect(result, 60);
    });
  });
}