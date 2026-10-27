import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/focus_preset_repository.dart';
import '../repositories/session_log_repository.dart';

import '../repositories/sqlite_focus_preset_repository.dart';
import '../repositories/sqlite_session_log_repository.dart';

// Provides the FocusPreset repository to Riverpod consumers.
final focusPresetRepositoryProvider = Provider<FocusPresetRepository>((ref) {
  return SQLiteFocusPresetRepository();
});

// Provides the SessionLog repository to Riverpod consumers.
final sessionLogRepositoryProvider = Provider<SessionLogRepository>((ref) {
  return SQLiteSessionLogRepository();
});
