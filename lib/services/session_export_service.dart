import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repositories/session_log_repository.dart';

class SessionExportService {
  final SessionLogRepository repository;

  SessionExportService(this.repository);

  // Escape values that may contain commas, quotes, or newlines.
  String _csvValue(String value) {
    final safeValue = value.startsWith(RegExp(r'[=+\-@\t\r]'))
        ? "'$value"
        : value;

    return '"${safeValue.replaceAll('"', '""')}"';
  }

  // Export finished sessions as a CSV file.
  Future<File> exportFinishedSessions() async {
    final sessions = await repository.getAllSessionLogs();

    final finished = sessions.where(
      (session) => session.status == 'finished' && session.completedSeconds > 0,
    );

    final lines = <String>[
      'Session ID,Preset ID,Date,Duration (Minutes),Mood,Status,Source,Note',
    ];

    for (final session in finished) {
      final values = [
        session.id?.toString() ?? '',
        session.presetId.toString(),
        session.startedAt.toUtc().toIso8601String(),
        (session.completedSeconds / 60).toStringAsFixed(2),
        session.moodTagSnapshot,
        session.status,
        session.source,
        session.note ?? '',
      ];

      lines.add(values.map(_csvValue).join(','));
    }

    final directory = await getApplicationDocumentsDirectory();

    final exportDirectory = Directory(p.join(directory.path, 'exports'));

    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    final file = File(
      p.join(exportDirectory.path, 'session_summary_$timestamp.csv'),
    );

    return file.writeAsString(lines.join('\r\n'));
  }
}
