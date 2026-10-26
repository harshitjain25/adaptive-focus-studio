import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _defaultDurationKey = 'default_duration';
  static const String _reducedMotionKey = 'reduced_motion';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _remindersEnabledKey = 'reminders_enabled';

  Future<int> getDefaultDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultDurationKey) ?? 25;
  }

  Future<void> setDefaultDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultDurationKey, minutes);
  }

  Future<bool> getReducedMotion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reducedMotionKey) ?? false;
  }

  Future<void> setReducedMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, value);
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? false;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<bool> getRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersEnabledKey) ?? false;
  }

  Future<void> setRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersEnabledKey, value);
  }
}