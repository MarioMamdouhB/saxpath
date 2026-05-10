class LearnerProgress {
  const LearnerProgress({
    required this.completedDays,
    required this.completedDaysCount,
    required this.currentDayNumber,
    required this.totalDays,
    this.currentStreakDays = 0,
    this.lastCompletedAt,
  });

  factory LearnerProgress.fromJson(Map<String, dynamic> json) {
    return LearnerProgress(
      completedDays: (json['completed_days'] as List<dynamic>)
          .map((value) => value as int)
          .toList(),
      completedDaysCount: json['completed_days_count'] as int,
      currentDayNumber: json['current_day_number'] as int,
      totalDays: json['total_days'] as int,
      currentStreakDays: json['current_streak_days'] as int? ?? 0,
      lastCompletedAt: json['last_completed_at'] == null
          ? null
          : DateTime.parse(json['last_completed_at'] as String),
    );
  }

  final List<int> completedDays;
  final int completedDaysCount;
  final int currentDayNumber;
  final int totalDays;
  final int currentStreakDays;
  final DateTime? lastCompletedAt;
}
