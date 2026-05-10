import 'package:flutter_test/flutter_test.dart';
import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/services/feedback_service.dart';

void main() {
  const service = FeedbackService();

  test('day-one foundation feedback stays beginner-focused', () {
    final result = service.generateSync(
      exerciseId: 'task_day_01_practice_ggaa',
      dayNumber: 1,
      recording: const MockRecording(
        audioUrl: 'mock://day_01.wav',
        durationSeconds: 8,
        label: 'day_01.wav',
        isRealRecording: false,
      ),
      evaluation: const AttemptEvaluation(
        attemptId: 'attempt_foundation_01',
        pitchAccuracy: 62,
        rhythmAccuracy: 58,
        completion: 69,
        feedbackAr: 'جرّب مرة أخرى',
        nextRecommendation: 'ثبت النغمة والعد',
      ),
    );

    final suggestedExercises = result.insights
        .map((insight) => insight.nextExerciseId)
        .whereType<String>()
        .toList(growable: false);

    expect(
      result.insights.any(
        (insight) =>
            insight.category == FeedbackCategory.improvisationLogic ||
            insight.category == FeedbackCategory.chordToneTargeting,
      ),
      isFalse,
    );
    expect(
      suggestedExercises.any(
        (id) =>
            id.contains('swing') ||
            id.contains('blues') ||
            id.contains('bebop') ||
            id.contains('improv'),
      ),
      isFalse,
    );
    expect(result.summary, isNot(contains('guide tones')));
    expect(result.nextStep, contains('drone'));
  });

  test('jazz exercises still surface improvisation recommendations', () {
    final result = service.generateSync(
      exerciseId: 'blues-guide-tone-line',
      dayNumber: 32,
      recording: const MockRecording(
        audioUrl: 'mock://blues.wav',
        durationSeconds: 11,
        label: 'blues.wav',
        isRealRecording: true,
      ),
      evaluation: const AttemptEvaluation(
        attemptId: 'attempt_blues_01',
        pitchAccuracy: 84,
        rhythmAccuracy: 83,
        completion: 74,
        feedbackAr: 'كويس',
        nextRecommendation: 'طوّر الفكرة',
      ),
    );

    final suggestedExercises = result.insights
        .map((insight) => insight.nextExerciseId)
        .whereType<String>()
        .toList(growable: false);

    expect(
      result.insights.any(
        (insight) =>
            insight.category == FeedbackCategory.improvisationLogic,
      ),
      isTrue,
    );
    expect(
      result.insights.any(
        (insight) =>
            insight.category == FeedbackCategory.chordToneTargeting,
      ),
      isTrue,
    );
    expect(
      suggestedExercises.any(
        (id) => id.contains('improv') || id.contains('blues'),
      ),
      isTrue,
    );
  });
}
