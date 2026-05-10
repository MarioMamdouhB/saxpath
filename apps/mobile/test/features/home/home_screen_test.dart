import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/data/models/analytics_event.dart';
import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/home/home_screen.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_controller.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('unlocked day can start the current session', (tester) async {
    final controller = AppProgressController(
      totalDays: 7,
      completedDays: const [],
    );

    await tester.pumpWidget(
      _buildTestApp(
        controller: controller,
        child: HomeScreen(
          apiClient: _FakeHomeApiClient(
            dailyPlan: _buildDailyPlan(dayNumber: 1),
            lessons: _buildLessons(dayNumber: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اليوم 1'), findsOneWidget);
    expect(find.text('ابدأ جلسة اليوم'), findsOneWidget);
    expect(
      find.textContaining('هذا اليوم ما زال مغلقاً'),
      findsNothing,
    );

    final startButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'ابدأ جلسة اليوم'),
    );
    expect(startButton.onPressed, isNotNull);
  });

  testWidgets('locked day redirects home focus to the current unlocked day',
      (tester) async {
    final controller = AppProgressController(
      totalDays: 7,
      completedDays: const [1],
    );

    await tester.pumpWidget(
      _buildTestApp(
        controller: controller,
        child: HomeScreen(
          apiClient: _FakeHomeApiClient(
            dailyPlan: _buildDailyPlan(dayNumber: 3),
            lessons: _buildLessons(dayNumber: 3),
          ),
          dayNumber: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اليوم 2'), findsOneWidget);
    expect(find.text('اليوم 3'), findsNothing);

    final startButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'ابدأ جلسة اليوم'),
    );
    expect(startButton.onPressed, isNotNull);
  });
}

Widget _buildTestApp({
  required AppProgressController controller,
  required Widget child,
}) {
  return AppProgressScope(
    controller: controller,
    child: MaterialApp(home: child),
  );
}

DailyPlan _buildDailyPlan({required int dayNumber}) {
  return DailyPlan(
    userName: 'أحمد',
    dayNumber: dayNumber,
    totalMinutes: 25,
    progressPercent: 0,
    tasks: [
      DailyTask(
        id: 'task_day_${dayNumber.toString().padLeft(2, '0')}_note',
        type: 'note_lesson',
        title: 'نغمة اليوم',
        durationMinutes: 5,
        status: 'next',
      ),
      DailyTask(
        id: 'task_day_${dayNumber.toString().padLeft(2, '0')}_rhythm',
        type: 'rhythm_lesson',
        title: 'إيقاع اليوم',
        durationMinutes: 7,
        status: 'locked',
      ),
      DailyTask(
        id: 'task_day_${dayNumber.toString().padLeft(2, '0')}_practice',
        type: 'practice',
        title: 'تمرين G A B A',
        durationMinutes: 10,
        status: 'locked',
        expectedNotes: const ['G', 'A', 'B', 'A'],
      ),
    ],
  );
}

List<Lesson> _buildLessons({required int dayNumber}) {
  return [
    Lesson(
      id: 'lesson_day_${dayNumber.toString().padLeft(2, '0')}_note',
      dayNumber: dayNumber,
      type: 'note_lesson',
      title: 'نغمة G / صول',
      descriptionAr: 'درس النغمة',
      durationMinutes: 5,
      note: 'G',
      arabicName: 'صول',
    ),
    Lesson(
      id: 'lesson_day_${dayNumber.toString().padLeft(2, '0')}_rhythm',
      dayNumber: dayNumber,
      type: 'rhythm_lesson',
      title: 'Quarter Note / نوار',
      descriptionAr: 'درس الإيقاع',
      durationMinutes: 7,
      rhythm: 'quarter_note',
    ),
  ];
}

class _FakeHomeApiClient extends SaxPathApiClient {
  _FakeHomeApiClient({
    required this.dailyPlan,
    required this.lessons,
  });

  final DailyPlan dailyPlan;
  final List<Lesson> lessons;

  @override
  Future<List<AnalyticsEvent>> getAnalyticsEvents({int limit = 10}) async {
    return const [];
  }

  @override
  Future<List<AttemptHistoryEntry>> getAttemptHistory({int limit = 5}) async {
    return const [];
  }

  @override
  Future<DailyPlan> getDailyPlan(int dayNumber) async {
    if (dayNumber == dailyPlan.dayNumber) {
      return dailyPlan;
    }

    return _buildDailyPlan(dayNumber: dayNumber);
  }

  @override
  Future<List<Lesson>> getLessons({int? dayNumber}) async {
    if (dayNumber == null || dayNumber == dailyPlan.dayNumber) {
      return lessons;
    }

    return _buildLessons(dayNumber: dayNumber);
  }
}
