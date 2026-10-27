import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/main.dart';
import 'package:adaptive_focus_studio/models/focus_preset.dart';
import 'package:adaptive_focus_studio/providers/repository_providers.dart';
import 'package:adaptive_focus_studio/repositories/focus_preset_repository.dart';

class FakeFocusPresetRepository implements FocusPresetRepository {
  @override
  Future<int> createPreset(FocusPreset preset) async {
    return 1;
  }

  @override
  Future<List<FocusPreset>> getAllPresets() async {
    return [
      const FocusPreset(
        id: 1,
        label: 'Test Study',
        moodTag: 'Focused',
        plannedSeconds: 25 * 60,
      ),
    ];
  }

  @override
  Future<FocusPreset?> getPresetById(int id) async {
    return const FocusPreset(
      id: 1,
      label: 'Test Study',
      moodTag: 'Focused',
      plannedSeconds: 25 * 60,
    );
  }

  @override
  Future<int> updatePreset(FocusPreset preset) async {
    return 1;
  }

  @override
  Future<int> deletePreset(int id) async {
    return 1;
  }
}

void main() {
  testWidgets(
    'Dashboard loads successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            focusPresetRepositoryProvider.overrideWithValue(
              FakeFocusPresetRepository(),
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

      expect(
        find.text('Session Scout'),
        findsOneWidget,
      );

      expect(
        find.text('Test Study'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Create Preset'),
        300,
      );

      expect(
        find.text('Create Preset'),
        findsOneWidget,
      );

      expect(
        find.text('History & Insights'),
        findsOneWidget,
      );
    },
  );
}