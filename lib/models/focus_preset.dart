class FocusPreset {
  final int? id;
  final String label;
  final String moodTag;
  final int plannedSeconds;

  const FocusPreset({
    this.id,
    required this.label,
    required this.moodTag,
    required this.plannedSeconds,
  });

  // Convert a FocusPreset into a SQLite-compatible map.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'moodTag': moodTag,
      'plannedSeconds': plannedSeconds,
    };
  }

  // Create a FocusPreset from a SQLite database row.
  factory FocusPreset.fromMap(Map<String, Object?> map) {
    return FocusPreset(
      id: map['id'] as int?,
      label: map['label'] as String,
      moodTag: map['moodTag'] as String,
      plannedSeconds: map['plannedSeconds'] as int,
    );
  }

  // Return a new object with selected fields changed.
  FocusPreset copyWith({
    int? id,
    String? label,
    String? moodTag,
    int? plannedSeconds,
  }) {
    return FocusPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      moodTag: moodTag ?? this.moodTag,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
    );
  }
}
