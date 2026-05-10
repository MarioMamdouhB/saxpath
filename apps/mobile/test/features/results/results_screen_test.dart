import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saxpath_mobile/data/models/attempt_analysis.dart';
import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/features/results/results_screen.dart';

void main() {
  testWidgets('results screen highlights next-day unlock clearly',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: ResultsScreen(
          evaluation: _successfulEvaluation(),
          apiClient: _FakeResultsApiClient(),
          dayNumber: 1,
          exerciseId: 'task_day_01_practice_ggaa',
          recording: const MockRecording(
            audioUrl: 'C:/recordings/day_01.wav',
            durationSeconds: 8,
            label: 'day_01.wav',
            isRealRecording: true,
            recordingId: 'rec_day_01',
            playbackUrl: '/api/v1/recordings/rec_day_01/file',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('جاهز للمتابعة'), findsOneWidget);
    expect(find.text('أنت جاهز لفتح اليوم 2'), findsOneWidget);
    expect(find.textContaining('سيتم فتح اليوم 2'), findsOneWidget);
  });

  testWidgets('results screen highlights retry state for fallback recording',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: ResultsScreen(
          evaluation: _successfulEvaluation(),
          apiClient: _FakeResultsApiClient(),
          dayNumber: 1,
          exerciseId: 'task_day_01_practice_ggaa',
          recording: const MockRecording(
            audioUrl: 'mock://day_01.wav',
            durationSeconds: 8,
            label: 'fallback_day_01.wav',
            isRealRecording: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مراجعة فقط'), findsOneWidget);
    expect(find.text('شاهد النتيجة ثم أعد التسجيل الحقيقي'), findsOneWidget);
    expect(find.textContaining('محاولة تجريبية صالحة للمراجعة فقط'), findsOneWidget);
  });
}

Widget _buildTestApp({required Widget child}) {
  return AppProgressScope(
    controller: AppProgressController(totalDays: 7),
    child: MaterialApp(home: child),
  );
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

class _FakeResultsApiClient extends SaxPathApiClient {}
