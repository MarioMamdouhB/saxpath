import '../../data/models/attempt_evaluation.dart';
import '../../features/practice/models/mock_recording.dart';
import 'audio_feedback_logic.dart';
import 'jazz_curriculum_models.dart';

class FeedbackService {
  const FeedbackService({
    AudioFeedbackAnalyzer? analyzer,
  }) : analyzer = analyzer ?? const HeuristicAudioFeedbackAnalyzer();

  final AudioFeedbackAnalyzer analyzer;

  Future<AudioFeedbackResult> generate({
    required String exerciseId,
    required int dayNumber,
    required MockRecording recording,
    required AttemptEvaluation evaluation,
    int? targetTempoBpm,
    List<String> targetConcepts = const [],
  }) {
    return analyzer.analyze(
      AudioAnalysisRequest(
        exerciseId: exerciseId,
        dayNumber: dayNumber,
        recording: recording,
        evaluation: evaluation,
        targetTempoBpm: targetTempoBpm,
        targetConcepts: targetConcepts,
      ),
    );
  }

  AudioFeedbackResult generateSync({
    required String exerciseId,
    required int dayNumber,
    required MockRecording recording,
    required AttemptEvaluation evaluation,
    int? targetTempoBpm,
    List<String> targetConcepts = const [],
  }) {
    final request = AudioAnalysisRequest(
      exerciseId: exerciseId,
      dayNumber: dayNumber,
      recording: recording,
      evaluation: evaluation,
      targetTempoBpm: targetTempoBpm,
      targetConcepts: targetConcepts,
    );

    if (analyzer is HeuristicAudioFeedbackAnalyzer) {
      return (analyzer as HeuristicAudioFeedbackAnalyzer).analyzeSync(request);
    }

    throw StateError(
      'The configured analyzer does not support synchronous analysis yet.',
    );
  }
}
