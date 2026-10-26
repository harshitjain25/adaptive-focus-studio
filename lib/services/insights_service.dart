import 'package:flutter/foundation.dart';

import '../models/session_log.dart';

class SessionInsights {
  final int completedCount;
  final double averageMinutes;

  const SessionInsights({
    required this.completedCount,
    required this.averageMinutes,
  });
}

class InsightsService {
  Future<SessionInsights> calculateInsights(
    List<SessionLog> sessions,
  ) async {
    final sessionMaps = sessions.map((session) => session.toMap()).toList();

    final result = await compute(
      _calculateInsightsInBackground,
      sessionMaps,
    );

    return SessionInsights(
      completedCount: result['completedCount'] as int,
      averageMinutes: result['averageMinutes'] as double,
    );
  }
}

Map<String, Object> _calculateInsightsInBackground(
  List<Map<String, Object?>> sessions,
) {
  final finishedSessions = sessions.where((session) {
    final status = session['status'] as String;
    final completedSeconds = session['completedSeconds'] as int;

    return status.toLowerCase() == 'finished' &&
        completedSeconds >= 0;
  }).toList();

  if (finishedSessions.isEmpty) {
    return {
      'completedCount': 0,
      'averageMinutes': 0.0,
    };
  }

  final totalSeconds = finishedSessions.fold<int>(
    0,
    (total, session) =>
        total + (session['completedSeconds'] as int),
  );

  final averageSeconds =
      totalSeconds / finishedSessions.length;

  return {
    'completedCount': finishedSessions.length,
    'averageMinutes': averageSeconds / 60,
  };
}