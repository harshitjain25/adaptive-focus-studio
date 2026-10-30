import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/models/session_log.dart';
import 'package:adaptive_focus_studio/smart_helper/session_scout.dart';

void main() {
  group('Session Scout held-out evaluation', () {
    test('compare Session Scout with fixed 25-minute baseline', () {
      // Fixed held-out evaluation cases.
      // Each case contains 3 previous sessions used for prediction
      // and a 4th value that is treated as the unseen actual next session.
      //
      // These cases are separate from the normal Session Scout unit-test
      // examples and are not used to change/tune the algorithm.

      final cases = [
        {
          'previous': [18, 22, 20],
          'actual': 21,
        },
        {
          'previous': [32, 38, 35],
          'actual': 36,
        },
        {
          'previous': [42, 50, 46],
          'actual': 44,
        },
        {
          'previous': [12, 16, 14],
          'actual': 15,
        },
        {
          'previous': [25, 30, 28],
          'actual': 27,
        },
      ];

      const baselinePrediction = 25;

      double totalScoutError = 0;
      double totalBaselineError = 0;

      print('');
      print('SESSION SCOUT HELD-OUT EVALUATION');
      print('---------------------------------');

      for (var i = 0; i < cases.length; i++) {
        final previous = cases[i]['previous'] as List<int>;
        final actual = cases[i]['actual'] as int;

        final sessions = List.generate(
          previous.length,
          (index) => SessionLog(
            presetId: 1,
            startedAt: DateTime(2026, 11, 1 + index),
            completedSeconds: previous[index] * 60,
            moodTagSnapshot: 'Focused',
            status: 'finished',
            source: 'timer',
          ),
        );

        final scoutPrediction = SessionScout.suggestDuration(
          sessions: sessions,
          moodTag: 'Focused',
        );

        expect(scoutPrediction, isNotNull);

        final scoutError = (actual - scoutPrediction!).abs();
        final baselineError = (actual - baselinePrediction).abs();

        totalScoutError += scoutError;
        totalBaselineError += baselineError;

        print('Case ${i + 1}');
        print('Previous sessions: $previous');
        print('Actual next session: $actual min');
        print('Session Scout prediction: $scoutPrediction min');
        print('25-min baseline prediction: $baselinePrediction min');
        print('Session Scout error: $scoutError min');
        print('Baseline error: $baselineError min');
        print('');
      }

      final scoutMae = totalScoutError / cases.length;
      final baselineMae = totalBaselineError / cases.length;

      print('---------------------------------');
      print('Number of held-out cases: ${cases.length}');
      print('Session Scout MAE: ${scoutMae.toStringAsFixed(2)} min');
      print('25-min Baseline MAE: ${baselineMae.toStringAsFixed(2)} min');
      print('---------------------------------');

      expect(cases.length, 5);
    });
  });
}