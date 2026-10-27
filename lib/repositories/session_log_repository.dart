import '../models/session_log.dart';

abstract class SessionLogRepository {
  // Save a new session log.
  Future<int> createSessionLog(SessionLog log);

  // Retrieve all session logs.
  Future<List<SessionLog>> getAllSessionLogs();

  // Retrieve a session log by its ID.
  Future<SessionLog?> getSessionLogById(int id);

  // Retrieve sessions belonging to a preset.
  Future<List<SessionLog>> getSessionsByPreset(int presetId);

  // Update an existing session log.
  Future<int> updateSessionLog(SessionLog log);

  // Delete a session log.
  Future<int> deleteSessionLog(int id);

  // Calculate the average completed duration in seconds.
  // Returns null if no valid finished sessions exist.
  Future<double?> getAverageCompletedSeconds({String? moodTag});

  // Count valid finished sessions.
  Future<int> getFinishedSessionCount({String? moodTag});

  // Retrieve the most recent finished sessions for a mood.
  Future<List<SessionLog>> getRecentFinishedSessions({
    required String moodTag,
    int limit = 3,
  });
}
