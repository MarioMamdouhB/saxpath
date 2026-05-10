class DailyTask {
  const DailyTask({
    required this.id,
    required this.type,
    required this.title,
    required this.durationMinutes,
    required this.status,
    this.level,
    this.expectedNotes = const <String>[],
    this.rhythmTarget,
    this.lockedReason,
    this.retryReason,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String,
      level: json['level'] as String?,
      expectedNotes: (json['expected_notes'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      rhythmTarget: json['rhythm_target'] as String?,
      lockedReason: json['locked_reason'] as String?,
      retryReason: json['retry_reason'] as String?,
    );
  }

  DailyTask copyWith({
    String? id,
    String? type,
    String? title,
    int? durationMinutes,
    String? status,
    String? level,
    List<String>? expectedNotes,
    String? rhythmTarget,
    String? lockedReason,
    String? retryReason,
  }) {
    return DailyTask(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      level: level ?? this.level,
      expectedNotes: expectedNotes ?? this.expectedNotes,
      rhythmTarget: rhythmTarget ?? this.rhythmTarget,
      lockedReason: lockedReason ?? this.lockedReason,
      retryReason: retryReason ?? this.retryReason,
    );
  }

  final String id;
  final String type;
  final String title;
  final int durationMinutes;
  final String status;
  final String? level;
  final List<String> expectedNotes;
  final String? rhythmTarget;
  final String? lockedReason;
  final String? retryReason;
}

class DailyPlan {
  const DailyPlan({
    required this.userName,
    required this.dayNumber,
    required this.totalMinutes,
    required this.progressPercent,
    required this.tasks,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>;

    return DailyPlan(
      userName: json['user_name'] as String,
      dayNumber: json['day_number'] as int,
      totalMinutes: json['total_minutes'] as int,
      progressPercent: json['progress_percent'] as int,
      tasks: tasksJson
          .map((taskJson) =>
              DailyTask.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
    );
  }

  DailyPlan copyWith({
    String? userName,
    int? dayNumber,
    int? totalMinutes,
    int? progressPercent,
    List<DailyTask>? tasks,
  }) {
    return DailyPlan(
      userName: userName ?? this.userName,
      dayNumber: dayNumber ?? this.dayNumber,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
      tasks: tasks ?? this.tasks,
    );
  }

  final String userName;
  final int dayNumber;
  final int totalMinutes;
  final int progressPercent;
  final List<DailyTask> tasks;
}

class WeekDaySummary {
  const WeekDaySummary({
    required this.dayNumber,
    required this.focusTitle,
    required this.totalMinutes,
    required this.status,
    required this.progressPercent,
  });

  factory WeekDaySummary.fromJson(Map<String, dynamic> json) {
    return WeekDaySummary(
      dayNumber: json['day_number'] as int,
      focusTitle: json['focus_title'] as String,
      totalMinutes: json['total_minutes'] as int,
      status: json['status'] as String,
      progressPercent: json['progress_percent'] as int,
    );
  }

  WeekDaySummary copyWith({
    int? dayNumber,
    String? focusTitle,
    int? totalMinutes,
    String? status,
    int? progressPercent,
  }) {
    return WeekDaySummary(
      dayNumber: dayNumber ?? this.dayNumber,
      focusTitle: focusTitle ?? this.focusTitle,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  final int dayNumber;
  final String focusTitle;
  final int totalMinutes;
  final String status;
  final int progressPercent;
}

class WeekOverview {
  const WeekOverview({
    required this.currentDayNumber,
    required this.totalDays,
    required this.completedDays,
    required this.days,
  });

  factory WeekOverview.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as List<dynamic>;

    return WeekOverview(
      currentDayNumber: json['current_day_number'] as int,
      totalDays: json['total_days'] as int,
      completedDays: json['completed_days'] as int,
      days: daysJson
          .map((dayJson) =>
              WeekDaySummary.fromJson(dayJson as Map<String, dynamic>))
          .toList(),
    );
  }

  final int currentDayNumber;
  final int totalDays;
  final int completedDays;
  final List<WeekDaySummary> days;
}
