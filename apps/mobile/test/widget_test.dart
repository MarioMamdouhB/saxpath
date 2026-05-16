import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/app.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/models/skill_mastery.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SaxPathApp starts with a real app shell', (tester) async {
    await tester.pumpWidget(
      SaxPathApp(apiClient: _StartupOnlyApiClient()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('ما هو حلمك مع الساكسفون؟'), findsOneWidget);
    expect(find.text('سنقوم بتخصيص دروسك بناءً على هدفك'), findsOneWidget);
  });
}

class _StartupOnlyApiClient extends SaxPathApiClient {
  @override
  Future<LearnerProgress> getLearnerProgress() async {
    return const LearnerProgress(
      completedDays: [],
      completedDaysCount: 0,
      currentDayNumber: 1,
      totalDays: 7,
    );
  }

  @override
  Future<PracticeSession> getTodayPracticeSession({
    String track = 'beginner',
  }) async {
    return const PracticeSession(
      track: 'beginner',
      dayNumber: 1,
      totalMinutes: 10,
      stageId: 'first_sound',
      stageTitle: 'Stage 1: First Sound',
      stageSubtitleAr: 'تثبيت النفس والوضعية.',
      stageProgressPercent: 33,
      guidedPathLabel: 'ابدأ بالصوت ثم ابنِ أول جملة قصيرة.',
      recommendedFocusAr: 'تركيز اليوم: ثبات الإيقاع',
      source: 'rule_based_v2',
      blocks: [],
    );
  }

  @override
  Future<SkillMasterySnapshot> getSkillMastery() async {
    return const SkillMasterySnapshot(skills: []);
  }
}
