import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SessionExportService {
  Future<File> exportSummary({
    required int totalSessions,
    required int averageMinutes,
    required String selectedMood,
    required int scoutBaselineMinutes,
  }) async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/adaptive_focus_summary.txt',
    );

    final content = '''
Adaptive Focus Studio
Session Summary

Total completed sessions: $totalSessions
Average completed duration: $averageMinutes minutes
Selected mood: $selectedMood
Session Scout baseline: $scoutBaselineMinutes minutes
Generated: ${DateTime.now().toIso8601String()}
''';

    try {
      return await file.writeAsString(content);
    } catch (error) {
      throw Exception('Unable to export session summary: $error');
    }
  }

  Future<String?> readExistingSummary() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/adaptive_focus_summary.txt',
    );

    if (!await file.exists()) {
      return null;
    }

    try {
      return await file.readAsString();
    } catch (error) {
      throw Exception('Unable to read session summary: $error');
    }
  }
}