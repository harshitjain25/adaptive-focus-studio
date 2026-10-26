import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/models/session_log.dart';
import 'package:adaptive_focus_studio/services/insights_service.dart';

void main() {
  group('InsightsService', () {
    final service = InsightsService();

    test('returns zero values when there are no sessions', () async {
      final result = await service.calculateInsights([]);

      expect(result.completedCount, 0);
      expect(result.averageMinutes, 0);
    });

    test('calculates average for finished sessions', () async {
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
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 22),
          completedSeconds: 25 * 60,
          moodTagSnapshot: 'Calm',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = await service.calculateInsights(sessions);

      expect(result.completedCount, 3);
      expect(result.averageMinutes, 25);
    });

    test('ignores unfinished sessions', () async {
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
          completedSeconds: 50 * 60,
          moodTagSnapshot: 'Focused',
          status: 'cancelled',
          source: 'timer',
        ),
      ];

      final result = await service.calculateInsights(sessions);

      expect(result.completedCount, 1);
      expect(result.averageMinutes, 20);
    });

    test('ignores negative completed duration', () async {
      final sessions = [
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 20),
          completedSeconds: -60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
        SessionLog(
          presetId: 1,
          startedAt: DateTime(2026, 10, 21),
          completedSeconds: 30 * 60,
          moodTagSnapshot: 'Focused',
          status: 'finished',
          source: 'timer',
        ),
      ];

      final result = await service.calculateInsights(sessions);

      expect(result.completedCount, 1);
      expect(result.averageMinutes, 30);
    });
  });
}