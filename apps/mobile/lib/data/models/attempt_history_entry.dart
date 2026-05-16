import 'attempt_analysis.dart';
import 'attempt_evaluation.dart';

class AttemptHistoryEntry {
  const AttemptHistoryEntry({
    required this.attemptId,
    required this.exerciseId,
    required this.dayNumber,
    required this.durationSeconds,
    required this.audioUrl,
    required this.pitchAccuracy,
    required this.rhythmAccuracy,
    required this.completion,
    required this.feedbackAr,
    required this.nextRecommendation,
    required this.createdAt,
    this.masteryDelta = const <MasteryDelta>[],
    this.confidenceLabel = 'medium',
    this.recordingId,
    this.retryReason,
    this.analysis,
    this.recommendedRetryBlock,
    this.teacherReview,
  });

  factory AttemptHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AttemptHistoryEntry(
      attemptId: json['attempt_id'] as String,
      exerciseId: json['exercise_id'] as String,
      dayNumber: json['day_number'] as int,
      durationSeconds: json['duration_seconds'] as int,
      audioUrl: json['audio_url'] as String? ?? '',
      pitchAccuracy: json['pitch_accuracy'] as int,
      rhythmAccuracy: json['rhythm_accuracy'] as int,
      completion: json['completion'] as int,
      feedbackAr: json['feedback_ar'] as String,
      nextRecommendation: json['next_recommendation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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

  final String attemptId;
  final String exerciseId;
  final int dayNumber;
  final int durationSeconds;
  final String audioUrl;
  final int pitchAccuracy;
  final int rhythmAccuracy;
  final int completion;
  final String feedbackAr;
  final String nextRecommendation;
  final DateTime createdAt;
  final List<MasteryDelta> masteryDelta;
  final String confidenceLabel;
  final String? recordingId;
  final String? retryReason;
  final AttemptAnalysis? analysis;
  final String? recommendedRetryBlock;
  final TeacherReview? teacherReview;
}
