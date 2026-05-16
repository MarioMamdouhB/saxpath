import 'package:flutter_test/flutter_test.dart';

import 'package:saxpath_mobile/data/models/attempt_analysis.dart';
import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/results/results_completion.dart';

void main() {
  test('fallback recording keeps completion locked', () {
    final state = buildResultsCompletionState(
      evaluation: _successfulEvaluation(),
      recording: const MockRecording(
        audioUrl: 'mock://day_01.wav',
        durationSeconds: 8,
        label: 'fallback_day_01.wav',
        isRealRecording: false,
      ),
      dayNumber: 1,
      totalDays: 7,
    );

    expect(state.canCompleteDay, isFalse);
    expect(state.primaryActionLabel, 'أعد التسجيل');
    expect(state.message, contains('محاولة تجريبية'));
  });

  test('real successful recording unlocks next day action', () {
    final state = buildResultsCompletionState(
      evaluation: _successfulEvaluation(),
      recording: const MockRecording(
        audioUrl: 'C:/recordings/day_01.wav',
        durationSeconds: 8,
        label: 'day_01.wav',
        isRealRecording: true,
        recordingId: 'rec_day_01',
        playbackUrl: '/api/v1/recordings/rec_day_01/file',
      ),
      dayNumber: 1,
      totalDays: 7,
    );

    expect(state.canCompleteDay, isTrue);
    expect(state.nextDayNumber, 2);
    expect(state.primaryActionLabel, 'فتح اليوم 2');
    expect(state.message, contains('سيتم فتح اليوم 2'));
  });

  test('retry reason blocks completion even with real recording', () {
    final state = buildResultsCompletionState(
      evaluation: _successfulEvaluation().copyWith(
        retryReason: 'rhythm_needs_work',
      ),
      recording: const MockRecording(
        audioUrl: 'C:/recordings/day_01.wav',
        durationSeconds: 8,
        label: 'day_01.wav',
        isRealRecording: true,
      ),
      dayNumber: 1,
      totalDays: 7,
    );

    expect(state.canCompleteDay, isFalse);
    expect(state.primaryActionLabel, 'أعد التسجيل');
    expect(state.message, contains('التوقيت يحتاج تمرين إيقاعي'));
  });
}

AttemptEvaluation _successfulEvaluation() {
  return const AttemptEvaluation(
    attemptId: 'attempt_day_01_008',
    pitchAccuracy: 86,
    rhythmAccuracy: 82,
    completion: 84,
    feedbackAr: 'أداء قوي.',
    nextRecommendation: 'كرر الجملة بثبات.',
    recordingId: 'rec_day_01',
    analysis: AttemptAnalysis(
      pitchScore: 86,
      rhythmScore: 82,
      detectedNotes: [
        DetectedNote(
          note: 'G',
          frequencyHz: 196,
          confidence: 0.92,
        ),
      ],
      timingErrors: [],
      confidence: 0.91,
      source: 'audio_engine',
    ),
  );
}
