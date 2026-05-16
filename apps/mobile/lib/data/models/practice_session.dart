class PracticeBlock {
  const PracticeBlock({
    required this.id,
    required this.title,
    required this.blockType,
    required this.durationMinutes,
    required this.status,
    required this.focusHintAr,
    required this.taskIds,
    required this.skillTags,
    required this.loopTarget,
    required this.supportsWaitMode,
    required this.visualFocusNotes,
    this.recommendedBpm,
    this.adaptationReasonAr,
    this.recommendedNextDrillAr,
  });

  factory PracticeBlock.fromJson(Map<String, dynamic> json) {
    return PracticeBlock(
      id: json['id'] as String,
      title: json['title'] as String,
      blockType: json['block_type'] as String,
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String,
      focusHintAr: json['focus_hint_ar'] as String? ?? '',
      taskIds: (json['task_ids'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      skillTags: (json['skill_tags'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      loopTarget: json['loop_target'] as int? ?? 2,
      supportsWaitMode: json['supports_wait_mode'] as bool? ?? false,
      visualFocusNotes: (json['visual_focus_notes'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      recommendedBpm: json['recommended_bpm'] as int?,
      adaptationReasonAr: json['adaptation_reason_ar'] as String?,
      recommendedNextDrillAr: json['recommended_next_drill_ar'] as String?,
    );
  }

  final String id;
  final String title;
  final String blockType;
  final int durationMinutes;
  final String status;
  final String focusHintAr;
  final List<String> taskIds;
  final List<String> skillTags;
  final int loopTarget;
  final bool supportsWaitMode;
  final List<String> visualFocusNotes;
  final int? recommendedBpm;
  final String? adaptationReasonAr;
  final String? recommendedNextDrillAr;
}

class PracticeSession {
  const PracticeSession({
    required this.track,
    required this.dayNumber,
    required this.totalMinutes,
    required this.stageId,
    required this.stageTitle,
    required this.stageSubtitleAr,
    required this.stageProgressPercent,
    required this.guidedPathLabel,
    required this.recommendedFocusAr,
    required this.source,
    required this.blocks,
    this.recommendedNextDrillAr,
    this.adaptationReasonAr,
    this.weakSkill,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      track: json['track'] as String? ?? 'beginner',
      dayNumber: json['day_number'] as int? ?? 1,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      stageId: json['stage_id'] as String? ?? 'first_sound',
      stageTitle: json['stage_title'] as String? ?? '',
      stageSubtitleAr: json['stage_subtitle_ar'] as String? ?? '',
      stageProgressPercent: json['stage_progress_percent'] as int? ?? 0,
      guidedPathLabel: json['guided_path_label'] as String? ?? '',
      weakSkill: json['weak_skill'] as String?,
      recommendedFocusAr: json['recommended_focus_ar'] as String? ?? '',
      recommendedNextDrillAr: json['recommended_next_drill_ar'] as String?,
      adaptationReasonAr: json['adaptation_reason_ar'] as String?,
      source: json['source'] as String? ?? 'rule_based_v2',
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PracticeBlock.fromJson)
          .toList(),
    );
  }

  final String track;
  final int dayNumber;
  final int totalMinutes;
  final String stageId;
  final String stageTitle;
  final String stageSubtitleAr;
  final int stageProgressPercent;
  final String guidedPathLabel;
  final String? weakSkill;
  final String recommendedFocusAr;
  final String? recommendedNextDrillAr;
  final String? adaptationReasonAr;
  final String source;
  final List<PracticeBlock> blocks;
}
