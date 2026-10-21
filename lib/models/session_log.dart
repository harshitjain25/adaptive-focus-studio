class SessionLog {
  final int? id;
  final int presetId;
  final DateTime startedAt;
  final int completedSeconds;
  final String moodTagSnapshot;
  final String status;
  final String source;
  final String? note;

  const SessionLog({
    this.id,
    required this.presetId,
    required this.startedAt,
    required this.completedSeconds,
    required this.moodTagSnapshot,
    required this.status,
    required this.source,
    this.note,
  });

  // Convert the model into a SQLite-compatible map.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'presetId': presetId,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'completedSeconds': completedSeconds,
      'moodTagSnapshot': moodTagSnapshot,
      'status': status,
      'source': source,
      'note': note,
    };
  }

  // Convert a SQLite row back into a SessionLog object.
  factory SessionLog.fromMap(Map<String, Object?> map) {
    return SessionLog(
      id: map['id'] as int?,
      presetId: map['presetId'] as int,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['startedAt'] as int),
      completedSeconds: map['completedSeconds'] as int,
      moodTagSnapshot: map['moodTagSnapshot'] as String,
      status: map['status'] as String,
      source: map['source'] as String,
      note: map['note'] as String?,
    );
  }

  // Create a modified copy while preserving existing values.
  SessionLog copyWith({
    int? id,
    int? presetId,
    DateTime? startedAt,
    int? completedSeconds,
    String? moodTagSnapshot,
    String? status,
    String? source,
    String? note,
  }) {
    return SessionLog(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      startedAt: startedAt ?? this.startedAt,
      completedSeconds: completedSeconds ?? this.completedSeconds,
      moodTagSnapshot: moodTagSnapshot ?? this.moodTagSnapshot,
      status: status ?? this.status,
      source: source ?? this.source,
      note: note ?? this.note,
    );
  }
}
