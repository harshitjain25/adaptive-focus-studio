import '../models/session_log.dart';

class SessionScout {
  static const int baselineMinutes = 25;
  static const int minimumMinutes = 10;
  static const int maximumMinutes = 60;

  static int? suggestDuration({
    required List<SessionLog> sessions,
    required String moodTag,
  }) {
    final matchingSessions = sessions
        .where(
          (session) =>
              session.status.toLowerCase() == 'finished' &&
              session.moodTagSnapshot == moodTag &&
              session.completedSeconds >= 0,
        )
        .toList();

    matchingSessions.sort(
      (a, b) => b.startedAt.compareTo(a.startedAt),
    );

    if (matchingSessions.length < 3) {
      return null;
    }

    final recentThree = matchingSessions.take(3).toList();

    final minutes = recentThree
        .map((session) => session.completedSeconds ~/ 60)
        .toList()
      ..sort();

    final median = minutes[1];

    return median.clamp(
      minimumMinutes,
      maximumMinutes,
    );
  }
}