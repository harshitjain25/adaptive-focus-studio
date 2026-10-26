import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';

class AppSettings {
  final int defaultDuration;
  final bool reducedMotion;
  final bool soundEnabled;
  final bool remindersEnabled;

  const AppSettings({
    required this.defaultDuration,
    required this.reducedMotion,
    required this.soundEnabled,
    required this.remindersEnabled,
  });

  AppSettings copyWith({
    int? defaultDuration,
    bool? reducedMotion,
    bool? soundEnabled,
    bool? remindersEnabled,
  }) {
    return AppSettings(
      defaultDuration: defaultDuration ?? this.defaultDuration,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SettingsService _service;

  @override
  Future<AppSettings> build() async {
    _service = ref.read(settingsServiceProvider);

    final defaultDuration = await _service.getDefaultDuration();
    final reducedMotion = await _service.getReducedMotion();
    final soundEnabled = await _service.getSoundEnabled();
    final remindersEnabled = await _service.getRemindersEnabled();

    return AppSettings(
      defaultDuration: defaultDuration,
      reducedMotion: reducedMotion,
      soundEnabled: soundEnabled,
      remindersEnabled: remindersEnabled,
    );
  }

  Future<void> setDefaultDuration(int minutes) async {
    final current = state.value;

    if (current == null) return;

    await _service.setDefaultDuration(minutes);

    state = AsyncData(
      current.copyWith(defaultDuration: minutes),
    );
  }

  Future<void> setReducedMotion(bool value) async {
    final current = state.value;

    if (current == null) return;

    await _service.setReducedMotion(value);

    state = AsyncData(
      current.copyWith(reducedMotion: value),
    );
  }

  Future<void> setSoundEnabled(bool value) async {
    final current = state.value;

    if (current == null) return;

    await _service.setSoundEnabled(value);

    state = AsyncData(
      current.copyWith(soundEnabled: value),
    );
  }

  Future<void> setRemindersEnabled(bool value) async {
    final current = state.value;

    if (current == null) return;

    await _service.setRemindersEnabled(value);

    state = AsyncData(
      current.copyWith(remindersEnabled: value),
    );
  }
}