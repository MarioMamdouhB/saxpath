class ExpectedEvent {
  const ExpectedEvent({
    required this.note,
    required this.onsetSeconds,
    required this.durationSeconds,
  });

  factory ExpectedEvent.fromJson(Map<String, dynamic> json) {
    return ExpectedEvent(
      note: json['note'] as String? ?? '-',
      onsetSeconds: (json['onset_seconds'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0,
    );
  }

  final String note;
  final double onsetSeconds;
  final double durationSeconds;
}

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
    this.skillTags = const <String>[],
    this.blockType,
    this.targetBpm,
    this.referenceAudioUrl,
    this.fingeringHintId,
    this.expectedEventTimeline = const <ExpectedEvent>[],
    this.recommendedLoopTarget,
    this.supportsWaitMode = false,
    this.adaptationReasonAr,
    this.isFocusTask = false,
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
      skillTags: (json['skill_tags'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      blockType: json['block_type'] as String?,
      targetBpm: json['target_bpm'] as int?,
      referenceAudioUrl: json['reference_audio_url'] as String?,
      fingeringHintId: json['fingering_hint_id'] as String?,
      expectedEventTimeline:
          (json['expected_event_timeline'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(ExpectedEvent.fromJson)
              .toList(),
      recommendedLoopTarget: json['recommended_loop_target'] as int?,
      supportsWaitMode: json['supports_wait_mode'] as bool? ?? false,
      adaptationReasonAr: json['adaptation_reason_ar'] as String?,
      isFocusTask: json['is_focus_task'] as bool? ?? false,
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
    List<String>? skillTags,
    String? blockType,
    int? targetBpm,
    String? referenceAudioUrl,
    String? fingeringHintId,
    List<ExpectedEvent>? expectedEventTimeline,
    int? recommendedLoopTarget,
    bool? supportsWaitMode,
    String? adaptationReasonAr,
    bool? isFocusTask,
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
      skillTags: skillTags ?? this.skillTags,
      blockType: blockType ?? this.blockType,
      targetBpm: targetBpm ?? this.targetBpm,
      referenceAudioUrl: referenceAudioUrl ?? this.referenceAudioUrl,
      fingeringHintId: fingeringHintId ?? this.fingeringHintId,
      expectedEventTimeline:
          expectedEventTimeline ?? this.expectedEventTimeline,
      recommendedLoopTarget:
          recommendedLoopTarget ?? this.recommendedLoopTarget,
      supportsWaitMode: supportsWaitMode ?? this.supportsWaitMode,
      adaptationReasonAr: adaptationReasonAr ?? this.adaptationReasonAr,
      isFocusTask: isFocusTask ?? this.isFocusTask,
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
  final List<String> skillTags;
  final String? blockType;
  final int? targetBpm;
  final String? referenceAudioUrl;
  final String? fingeringHintId;
  final List<ExpectedEvent> expectedEventTimeline;
  final int? recommendedLoopTarget;
  final bool supportsWaitMode;
  final String? adaptationReasonAr;
  final bool isFocusTask;
}

class DailyPlan {
  const DailyPlan({
    required this.userName,
    required this.dayNumber,
    required this.totalMinutes,
    required this.progressPercent,
    required this.tasks,
    this.stageId,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>;

    return DailyPlan(
      userName: json['user_name'] as String,
      dayNumber: json['day_number'] as int,
      totalMinutes: json['total_minutes'] as int,
      progressPercent: json['progress_percent'] as int,
      stageId: json['stage_id'] as String?,
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
    String? stageId,
  }) {
    return DailyPlan(
      userName: userName ?? this.userName,
      dayNumber: dayNumber ?? this.dayNumber,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
      tasks: tasks ?? this.tasks,
      stageId: stageId ?? this.stageId,
    );
  }

  final String userName;
  final int dayNumber;
  final int totalMinutes;
  final int progressPercent;
  final List<DailyTask> tasks;
  final String? stageId;
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
