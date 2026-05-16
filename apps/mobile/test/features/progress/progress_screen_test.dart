import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/data/models/analytics_event.dart';
import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/models/skill_mastery.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/progress/progress_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders week overview and updates current day from dev tools',
      (tester) async {
    final controller = AppProgressController(
      totalDays: 7,
      completedDays: const [1, 2],
    );

    await tester.pumpWidget(
      _buildTestApp(
        controller: controller,
        apiClient: _FakeSaxPathApiClient(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('خطة 30 يوم'), findsOneWidget);
    expect(find.text('اليوم الحالي: 3'), findsOneWidget);
    expect(find.text('الأيام المكتملة: 2 من 7'), findsOneWidget);
    expect(find.text('Skill Mastery'), findsOneWidget);
    expect(find.textContaining('ثبات الإيقاع'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mastery Timeline'), 250);
    await tester.pumpAndSettle();
    expect(find.text('Mastery Timeline'), findsOneWidget);
    expect(find.textContaining('Recommended Next Drill:'), findsWidgets);
    await tester.scrollUntilVisible(find.text('المسار الموجه الآن'), 300);
    await tester.pumpAndSettle();
    expect(find.text('المسار الموجه الآن'), findsOneWidget);
    expect(find.text('AI + Teacher Review'), findsWidgets);
  });

  testWidgets('reset progress returns the learner to day one', (tester) async {
    final controller = AppProgressController(
      totalDays: 7,
      completedDays: const [1, 2, 3],
    );

    await tester.pumpWidget(
      _buildTestApp(
        controller: controller,
        apiClient: _FakeSaxPathApiClient(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اليوم الحالي: 4'), findsOneWidget);
    expect(find.text('الأيام المكتملة: 3 من 7'), findsOneWidget);

    await tester.tap(find.text('إعادة ضبط التقدم'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    expect(find.text('اليوم الحالي: 1'), findsOneWidget);
    expect(find.text('الأيام المكتملة: 0 من 7'), findsOneWidget);
    expect(
      find.text('تمت إعادة ضبط التقدم ومزامنته مع الخادم.'),
      findsOneWidget,
    );
  });

  testWidgets('manual sync refreshes progress from the server', (tester) async {
    final controller = AppProgressController(
      totalDays: 7,
      completedDays: const [1],
    );
    final apiClient = _MutableFakeSaxPathApiClient(
      progress: const LearnerProgress(
        completedDays: [1, 2, 3],
        completedDaysCount: 3,
        currentDayNumber: 4,
        totalDays: 7,
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        controller: controller,
        apiClient: apiClient,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اليوم الحالي: 2'), findsOneWidget);
    expect(find.text('الأيام المكتملة: 1 من 7'), findsOneWidget);

    await tester.tap(find.text('تحديث من الخادم'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('اليوم الحالي: 4'), findsOneWidget);
    expect(find.text('الأيام المكتملة: 3 من 7'), findsOneWidget);
    expect(find.text('تم تحديث التقدم من الخادم.'), findsOneWidget);
  });
}

Widget _buildTestApp({
  required AppProgressController controller,
  required SaxPathApiClient apiClient,
}) {
  return AppProgressScope(
    controller: controller,
    child: MaterialApp(
      home: ProgressScreen(apiClient: apiClient),
    ),
  );
}

class _FakeSaxPathApiClient extends SaxPathApiClient {
  @override
  Future<List<AnalyticsEvent>> getAnalyticsEvents({int limit = 10}) async {
    return [
      AnalyticsEvent(
        eventId: 'event_1',
        eventName: 'practice_finish',
        dayNumber: 3,
        taskId: 'task_day_03_practice_gaba',
        attemptId: 'attempt_day_03_010',
        metadata: const {'completion': 82},
        createdAt: DateTime(2026, 5, 7),
      ),
    ];
  }

  @override
  Future<List<AttemptHistoryEntry>> getAttemptHistory({int limit = 5}) async {
    return [
      AttemptHistoryEntry(
        attemptId: 'attempt_day_03_010',
        exerciseId: 'task_day_03_practice_gaba',
        dayNumber: 3,
        durationSeconds: 10,
        audioUrl: 'mock://recordings/day_03.wav',
        pitchAccuracy: 72,
        rhythmAccuracy: 68,
        completion: 82,
        feedbackAr: 'ممتاز',
        nextRecommendation: 'أعد التمرين',
        confidenceLabel: 'medium',
        recommendedRetryBlock: 'rhythm_call_response',
        teacherReview: const TeacherReview(
          status: 'available',
          aiSummaryAr: 'هناك فرصة جيدة لتحسين الإيقاع قبل رفع السرعة.',
          teacherPromptAr: 'راجع الاستجابة بعد السماع واقترح drill واحد.',
          queueEtaAr: 'يمكن طلب مراجعة مدرس لاحقاً.',
          focusPointsAr: ['ثبّت العد الداخلي'],
          source: 'ai_teacher_bridge_v1',
        ),
        createdAt: DateTime(2026, 5, 7),
      ),
    ];
  }

  @override
  Future<LearnerProgress> getLearnerProgress() async {
    return const LearnerProgress(
      completedDays: [1, 2],
      completedDaysCount: 2,
      currentDayNumber: 3,
      totalDays: 7,
    );
  }

  @override
  Future<LearnerProgress> resetProgress() async {
    return const LearnerProgress(
      completedDays: [],
      completedDaysCount: 0,
      currentDayNumber: 1,
      totalDays: 7,
    );
  }

  @override
  Future<WeekOverview> getWeekOverview() async {
    return const WeekOverview(
      currentDayNumber: 1,
      totalDays: 7,
      completedDays: 0,
      days: [
        WeekDaySummary(
          dayNumber: 1,
          focusTitle: 'النغمة G',
          totalMinutes: 12,
          status: 'completed',
          progressPercent: 100,
        ),
        WeekDaySummary(
          dayNumber: 2,
          focusTitle: 'النغمة A',
          totalMinutes: 14,
          status: 'completed',
          progressPercent: 100,
        ),
        WeekDaySummary(
          dayNumber: 3,
          focusTitle: 'النبض الربع',
          totalMinutes: 16,
          status: 'current',
          progressPercent: 0,
        ),
        WeekDaySummary(
          dayNumber: 4,
          focusTitle: 'جملة قصيرة',
          totalMinutes: 18,
          status: 'planned',
          progressPercent: 0,
        ),
        WeekDaySummary(
          dayNumber: 5,
          focusTitle: 'تنفس وإيقاع',
          totalMinutes: 20,
          status: 'planned',
          progressPercent: 0,
        ),
        WeekDaySummary(
          dayNumber: 6,
          focusTitle: 'انتقالات بسيطة',
          totalMinutes: 20,
          status: 'planned',
          progressPercent: 0,
        ),
        WeekDaySummary(
          dayNumber: 7,
          focusTitle: 'مراجعة الأسبوع',
          totalMinutes: 22,
          status: 'planned',
          progressPercent: 0,
        ),
      ],
    );
  }

  @override
  Future<SkillMasterySnapshot> getSkillMastery() async {
    return const SkillMasterySnapshot(
      weakSkill: 'rhythm',
      skills: [
        SkillMasteryEntry(
          skill: 'rhythm',
          score: 48,
          status: 'developing',
          focusLabel: 'ثبات الإيقاع',
        ),
        SkillMasteryEntry(
          skill: 'tone',
          score: 61,
          status: 'steady',
          focusLabel: 'ثبات الصوت',
        ),
      ],
    );
  }

  @override
  Future<PracticeSession> getTodayPracticeSession({
    String track = 'beginner',
  }) async {
    return const PracticeSession(
      track: 'beginner',
      dayNumber: 3,
      totalMinutes: 10,
      stageId: 'first_sound',
      stageTitle: 'Stage 1: First Sound',
      stageSubtitleAr: 'تثبيت النفس والوضعية وأول انتقالات بين النغمات.',
      stageProgressPercent: 66,
      guidedPathLabel: 'ابدأ بالصوت ثم ابنِ أول جملة قصيرة.',
      weakSkill: 'rhythm',
      recommendedFocusAr: 'ثبات الإيقاع',
      source: 'rule_based_v2',
      blocks: [
        PracticeBlock(
          id: 'rhythm_call_response',
          title: 'Rhythm / Call-and-Response',
          blockType: 'rhythm_call_response',
          durationMinutes: 3,
          status: 'ready',
          focusHintAr: 'عدّ ثم رد.',
          taskIds: ['task_day_03_practice_gaba'],
          skillTags: ['rhythm'],
          loopTarget: 3,
          supportsWaitMode: true,
          visualFocusNotes: ['G', 'A', 'B'],
        ),
      ],
    );
  }
}

class _MutableFakeSaxPathApiClient extends _FakeSaxPathApiClient {
  _MutableFakeSaxPathApiClient({
    required LearnerProgress progress,
  }) : _progress = progress;

  final LearnerProgress _progress;

  @override
  Future<LearnerProgress> getLearnerProgress() async => _progress;
}
