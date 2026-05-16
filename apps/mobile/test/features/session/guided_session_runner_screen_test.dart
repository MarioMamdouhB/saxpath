import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/session/guided_session_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('runner starts from the focus block and shows session flow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GuidedSessionRunnerScreen(
          apiClient: _FakeRunnerApiClient(),
          dayPlan: _buildDailyPlan(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Session Runner'), findsNothing);
    expect(find.text('مسار الجلسة'), findsOneWidget);
    expect(find.textContaining('Block 1/4'), findsOneWidget);
    expect(find.text('Done 0/4'), findsOneWidget);
    expect(find.text('الاستجابة الأولى'), findsOneWidget);
    expect(find.text('إيقاع اليوم'), findsWidgets);
    expect(find.textContaining('Next drill:'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('علّم كمكتمل'));
    await tester.pumpAndSettle();

    expect(find.text('مكتمل'), findsOneWidget);
  });
}

DailyPlan _buildDailyPlan() {
  return const DailyPlan(
    userName: 'أحمد',
    dayNumber: 2,
    totalMinutes: 24,
    progressPercent: 0,
    tasks: [
      DailyTask(
        id: 'warmup_2',
        type: 'warmup',
        title: 'تهيئة النفس',
        durationMinutes: 4,
        status: 'next',
        blockType: 'warm_up',
      ),
      DailyTask(
        id: 'note_2',
        type: 'note_lesson',
        title: 'نغمة G',
        durationMinutes: 5,
        status: 'next',
        blockType: 'note_fingering',
        expectedNotes: ['G'],
      ),
      DailyTask(
        id: 'rhythm_2',
        type: 'rhythm_lesson',
        title: 'إيقاع اليوم',
        durationMinutes: 6,
        status: 'focus',
        blockType: 'rhythm_call_response',
        supportsWaitMode: true,
        isFocusTask: true,
      ),
      DailyTask(
        id: 'practice_2',
        type: 'practice',
        title: 'تمرين G A B A',
        durationMinutes: 9,
        status: 'next',
        blockType: 'record_check',
        expectedNotes: ['G', 'A', 'B', 'A'],
        recommendedLoopTarget: 3,
      ),
    ],
  );
}

List<Lesson> _buildLessons() {
  return const [
    Lesson(
      id: 'note_lesson_2',
      dayNumber: 2,
      type: 'note_lesson',
      title: 'نغمة G',
      descriptionAr: 'ثبّت النغمة قبل الانتقال.',
      durationMinutes: 5,
      note: 'G',
      arabicName: 'صول',
    ),
    Lesson(
      id: 'rhythm_lesson_2',
      dayNumber: 2,
      type: 'rhythm_lesson',
      title: 'Quarter Note',
      descriptionAr: 'استمع ثم رد على المرجع.',
      durationMinutes: 6,
      rhythm: 'quarter_note',
    ),
  ];
}

PracticeSession _buildSession() {
  return const PracticeSession(
    track: 'beginner',
    dayNumber: 2,
    totalMinutes: 24,
    stageId: 'first_response',
    stageTitle: 'الاستجابة الأولى',
    stageSubtitleAr: 'نبني أول رد إيقاعي واضح.',
    stageProgressPercent: 40,
    guidedPathLabel: 'Beginner Course',
    recommendedFocusAr: 'ابدأ اليوم من بلوك الاستجابة الإيقاعية.',
    recommendedNextDrillAr: 'Call-and-response بطيء على 50-56 BPM مع 3 loops نظيفة قبل التسجيل.',
    adaptationReasonAr: 'آخر محاولة احتاجت ضبطًا أفضل للتوقيت.',
    source: 'adaptive_rule_engine_v1',
    weakSkill: 'rhythm',
    blocks: [
      PracticeBlock(
        id: 'warmup',
        title: 'Warm-up',
        blockType: 'warm_up',
        durationMinutes: 4,
        status: 'next',
        focusHintAr: 'ثبّت النفس والصوت.',
        taskIds: ['warmup_2'],
        skillTags: ['breath'],
        loopTarget: 1,
        supportsWaitMode: false,
        visualFocusNotes: ['G'],
      ),
      PracticeBlock(
        id: 'note',
        title: 'نغمة اليوم',
        blockType: 'note_fingering',
        durationMinutes: 5,
        status: 'next',
        focusHintAr: 'ثبّت النغمة قبل الإيقاع.',
        taskIds: ['note_2'],
        skillTags: ['note_accuracy'],
        loopTarget: 2,
        supportsWaitMode: false,
        visualFocusNotes: ['G'],
      ),
      PracticeBlock(
        id: 'rhythm',
        title: 'إيقاع اليوم',
        blockType: 'rhythm_call_response',
        durationMinutes: 6,
        status: 'focus',
        focusHintAr: 'اسمع ثم رد قبل التكرار.',
        taskIds: ['rhythm_2'],
        skillTags: ['rhythm'],
        loopTarget: 3,
        supportsWaitMode: true,
        visualFocusNotes: ['1', '&'],
        recommendedBpm: 56,
        adaptationReasonAr: 'ابدأ من الإيقاع لأن آخر محاولة كانت متأخرة.',
        recommendedNextDrillAr: 'Call-and-response بطيء على 50-56 BPM مع 3 loops نظيفة قبل التسجيل.',
      ),
      PracticeBlock(
        id: 'record',
        title: 'Record Check',
        blockType: 'record_check',
        durationMinutes: 9,
        status: 'next',
        focusHintAr: 'سجّل محاولة واحدة نظيفة.',
        taskIds: ['practice_2'],
        skillTags: ['response_imitation'],
        loopTarget: 3,
        supportsWaitMode: true,
        visualFocusNotes: ['G', 'A', 'B', 'A'],
        recommendedBpm: 58,
        recommendedNextDrillAr: 'اسمع مرجعًا قصيرًا مرة، ثم رد عليه مباشرة بدون تشغيل مستمر.',
      ),
    ],
  );
}

class _FakeRunnerApiClient extends SaxPathApiClient {
  @override
  Future<List<Lesson>> getLessons({int? dayNumber}) async {
    return _buildLessons();
  }

  @override
  Future<PracticeSession> getPracticeSessionForDay(
    int dayNumber, {
    String track = 'beginner',
  }) async {
    return _buildSession();
  }
}
