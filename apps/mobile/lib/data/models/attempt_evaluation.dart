import 'attempt_analysis.dart';

class MasteryDelta {
  const MasteryDelta({
    required this.skill,
    required this.previousScore,
    required this.newScore,
    required this.delta,
  });

  factory MasteryDelta.fromJson(Map<String, dynamic> json) {
    return MasteryDelta(
      skill: json['skill'] as String? ?? '',
      previousScore: json['previous_score'] as int? ?? 0,
      newScore: json['new_score'] as int? ?? 0,
      delta: json['delta'] as int? ?? 0,
    );
  }

  final String skill;
  final int previousScore;
  final int newScore;
  final int delta;
}

class TeacherReview {
  const TeacherReview({
    required this.status,
    required this.aiSummaryAr,
    required this.teacherPromptAr,
    required this.queueEtaAr,
    required this.focusPointsAr,
    required this.source,
  });

  factory TeacherReview.fromJson(Map<String, dynamic> json) {
    return TeacherReview(
      status: json['status'] as String? ?? 'available',
      aiSummaryAr: json['ai_summary_ar'] as String? ?? '',
      teacherPromptAr: json['teacher_prompt_ar'] as String? ?? '',
      queueEtaAr: json['queue_eta_ar'] as String? ?? '',
      focusPointsAr: (json['focus_points_ar'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      source: json['source'] as String? ?? 'ai_teacher_bridge_v1',
    );
  }

  TeacherReview copyWith({
    String? status,
    String? aiSummaryAr,
    String? teacherPromptAr,
    String? queueEtaAr,
    List<String>? focusPointsAr,
    String? source,
  }) {
    return TeacherReview(
      status: status ?? this.status,
      aiSummaryAr: aiSummaryAr ?? this.aiSummaryAr,
      teacherPromptAr: teacherPromptAr ?? this.teacherPromptAr,
      queueEtaAr: queueEtaAr ?? this.queueEtaAr,
      focusPointsAr: focusPointsAr ?? this.focusPointsAr,
      source: source ?? this.source,
    );
  }

  final String status;
  final String aiSummaryAr;
  final String teacherPromptAr;
  final String queueEtaAr;
  final List<String> focusPointsAr;
  final String source;
}

class AttemptEvaluation {
  const AttemptEvaluation({
    required this.attemptId,
    required this.pitchAccuracy,
    required this.rhythmAccuracy,
    required this.completion,
    required this.feedbackAr,
    required this.nextRecommendation,
    this.masteryDelta = const <MasteryDelta>[],
    this.confidenceLabel = 'medium',
    this.recordingId,
    this.retryReason,
    this.analysis,
    this.recommendedRetryBlock,
    this.teacherReview,
  });

  factory AttemptEvaluation.fromJson(Map<String, dynamic> json) {
    return AttemptEvaluation(
      attemptId: json['attempt_id'] as String,
      pitchAccuracy: json['pitch_accuracy'] as int,
      rhythmAccuracy: json['rhythm_accuracy'] as int,
      completion: json['completion'] as int,
      feedbackAr: json['feedback_ar'] as String,
      nextRecommendation: json['next_recommendation'] as String,
      masteryDelta: (json['mastery_delta'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MasteryDelta.fromJson)
          .toList(),
      confidenceLabel: json['confidence_label'] as String? ?? 'medium',
      recordingId: json['recording_id'] as String?,
      retryReason: json['retry_reason'] as String?,
      analysis: json['analysis'] is Map<String, dynamic>
          ? AttemptAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      recommendedRetryBlock: json['recommended_retry_block'] as String?,
      teacherReview: json['teacher_review'] is Map<String, dynamic>
          ? TeacherReview.fromJson(
              json['teacher_review'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  AttemptEvaluation copyWith({
    String? attemptId,
    int? pitchAccuracy,
    int? rhythmAccuracy,
    int? completion,
    String? feedbackAr,
    String? nextRecommendation,
    List<MasteryDelta>? masteryDelta,
    String? confidenceLabel,
    String? recordingId,
    String? retryReason,
    AttemptAnalysis? analysis,
    String? recommendedRetryBlock,
    TeacherReview? teacherReview,
  }) {
    return AttemptEvaluation(
      attemptId: attemptId ?? this.attemptId,
      pitchAccuracy: pitchAccuracy ?? this.pitchAccuracy,
      rhythmAccuracy: rhythmAccuracy ?? this.rhythmAccuracy,
      completion: completion ?? this.completion,
      feedbackAr: feedbackAr ?? this.feedbackAr,
      nextRecommendation: nextRecommendation ?? this.nextRecommendation,
      masteryDelta: masteryDelta ?? this.masteryDelta,
      confidenceLabel: confidenceLabel ?? this.confidenceLabel,
      recordingId: recordingId ?? this.recordingId,
      retryReason: retryReason ?? this.retryReason,
      analysis: analysis ?? this.analysis,
      recommendedRetryBlock:
          recommendedRetryBlock ?? this.recommendedRetryBlock,
      teacherReview: teacherReview ?? this.teacherReview,
    );
  }

  final String attemptId;
  final int pitchAccuracy;
  final int rhythmAccuracy;
  final int completion;
  final String feedbackAr;
  final String nextRecommendation;
  final List<MasteryDelta> masteryDelta;
  final String confidenceLabel;
  final String? recordingId;
  final String? retryReason;
  final AttemptAnalysis? analysis;
  final String? recommendedRetryBlock;
  final TeacherReview? teacherReview;
}
