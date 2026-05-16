class StageSummary {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isExam;
  final int dayCount;

  StageSummary({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = true,
    this.isCompleted = false,
    this.isExam = false,
    required this.dayCount,
  });

  factory StageSummary.fromJson(Map<String, dynamic> json) {
    return StageSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isUnlocked: json['is_unlocked'] as bool? ?? true,
      isCompleted: json['is_completed'] as bool? ?? false,
      isExam: json['is_exam'] as bool? ?? false,
      dayCount: json['day_count'] as int,
    );
  }
}

class Track {
  final String id;
  final String title;
  final String description;
  final List<StageSummary> stages;

  Track({
    required this.id,
    required this.title,
    required this.description,
    required this.stages,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      stages: (json['stages'] as List<dynamic>)
          .map((s) => StageSummary.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
