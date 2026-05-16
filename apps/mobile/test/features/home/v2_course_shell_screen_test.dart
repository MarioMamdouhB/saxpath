import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/models/skill_mastery.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/home/v2_course_shell_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('v2 course shell shows the main entry paths', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: V2CourseShellScreen(
          apiClient: _NoopApiClient(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SaxPath V2'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Choose Your Course'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Choose Your Course'), findsOneWidget);
    expect(find.text('Beginner Course'), findsOneWidget);
    expect(find.text('Experienced Path'), findsOneWidget);
    expect(find.text('Theory Intro'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Quick Access'), 300);
    await tester.pumpAndSettle();
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Continue Daily Flow'), findsOneWidget);
  });
}

class _NoopApiClient extends SaxPathApiClient {
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
      weakSkill: 'rhythm',
      recommendedFocusAr: 'تركيز اليوم: ثبات الإيقاع',
      source: 'rule_based_v2',
      blocks: [
        PracticeBlock(
          id: 'warm_up',
          title: 'Warm-up',
          blockType: 'warm_up',
          durationMinutes: 2,
          status: 'ready',
          focusHintAr: 'ابدأ بهدوء.',
          taskIds: ['task_day_01_note_g'],
          skillTags: ['tone'],
          loopTarget: 2,
          supportsWaitMode: false,
          visualFocusNotes: ['G'],
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
          score: 42,
          status: 'developing',
          focusLabel: 'ثبات الإيقاع',
        ),
      ],
    );
  }
}
