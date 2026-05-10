import 'attempt_analysis.dart';

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
    this.recordingId,
    this.retryReason,
    this.analysis,
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
      recordingId: json['recording_id'] as String?,
      retryReason: json['retry_reason'] as String?,
      analysis: json['analysis'] is Map<String, dynamic>
          ? AttemptAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
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
  final String? recordingId;
  final String? retryReason;
  final AttemptAnalysis? analysis;
}
