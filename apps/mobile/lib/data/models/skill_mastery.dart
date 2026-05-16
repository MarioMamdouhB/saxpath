class SkillMasteryEntry {
  const SkillMasteryEntry({
    required this.skill,
    required this.score,
    required this.status,
    required this.focusLabel,
    this.trendLabel = 'waiting_for_signal',
    this.recommendedNextDrillAr = '',
    this.recentDeltas = const <int>[],
    this.lastUpdatedAt,
  });

  factory SkillMasteryEntry.fromJson(Map<String, dynamic> json) {
    return SkillMasteryEntry(
      skill: json['skill'] as String,
      score: json['score'] as int? ?? 0,
      status: json['status'] as String? ?? 'starting',
      focusLabel: json['focus_label'] as String? ?? '',
      trendLabel: json['trend_label'] as String? ?? 'waiting_for_signal',
      recommendedNextDrillAr:
          json['recommended_next_drill_ar'] as String? ?? '',
      recentDeltas: (json['recent_deltas'] as List<dynamic>? ?? [])
          .whereType<int>()
          .toList(),
      lastUpdatedAt: json['last_updated_at'] == null
          ? null
          : DateTime.tryParse(json['last_updated_at'] as String),
    );
  }

  final String skill;
  final int score;
  final String status;
  final String focusLabel;
  final String trendLabel;
  final String recommendedNextDrillAr;
  final List<int> recentDeltas;
  final DateTime? lastUpdatedAt;
}

class SkillMasterySnapshot {
  const SkillMasterySnapshot({
    required this.skills,
    this.weakSkill,
    this.updatedAt,
  });

  factory SkillMasterySnapshot.fromJson(Map<String, dynamic> json) {
    return SkillMasterySnapshot(
      weakSkill: json['weak_skill'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SkillMasteryEntry.fromJson)
          .toList(),
    );
  }

  final String? weakSkill;
  final DateTime? updatedAt;
  final List<SkillMasteryEntry> skills;
}
