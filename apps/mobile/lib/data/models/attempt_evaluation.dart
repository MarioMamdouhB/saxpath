import 'attempt_analysis.dart';

class AttemptEvaluation {
  const AttemptEvaluation({
    required this.attemptId,
    required this.pitchAccuracy,
    required this.rhythmAccuracy,
    required this.completion,
    required this.feedbackAr,
    required this.nextRecommendation,
    this.recordingId,
    this.retryReason,
    this.analysis,
  });

  factory AttemptEvaluation.fromJson(Map<String, dynamic> json) {
    return AttemptEvaluation(
      attemptId: json['attempt_id'] as String,
      pitchAccuracy: json['pitch_accuracy'] as int,
      rhythmAccuracy: json['rhythm_accuracy'] as int,
      completion: json['completion'] as int,
      feedbackAr: json['feedback_ar'] as String,
      nextRecommendation: json['next_recommendation'] as String,
      recordingId: json['recording_id'] as String?,
      retryReason: json['retry_reason'] as String?,
      analysis: json['analysis'] is Map<String, dynamic>
          ? AttemptAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  final String attemptId;
  final int pitchAccuracy;
  final int rhythmAccuracy;
  final int completion;
  final String feedbackAr;
  final String nextRecommendation;
  final String? recordingId;
  final String? retryReason;
  final AttemptAnalysis? analysis;
}
