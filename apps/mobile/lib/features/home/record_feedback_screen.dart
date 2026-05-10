import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart' as lesson_model;
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/lessons/note_lesson_screen.dart';
import 'package:saxpath_mobile/features/practice/practice_screen.dart';
import 'package:saxpath_mobile/features/progress/progress_screen.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class RecordFeedbackScreen extends StatelessWidget {
  const RecordFeedbackScreen({
    super.key,
    required this.apiClient,
    required this.dayPlan,
    required this.lessonsFuture,
  });

  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;
  final Future<List<lesson_model.Lesson>> lessonsFuture;

  @override
  Widget build(BuildContext context) {
    final practiceTask = dayPlan.tasks.firstWhere(
      (task) => task.type == 'practice',
      orElse: () => dayPlan.tasks.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('التسجيل والتقييم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: 'اليوم ${dayPlan.dayNumber}: ${practiceTask.title}',
            subtitle:
                'ابدأ من الدرس إذا احتجت مراجعة، أو ادخل مباشرة إلى التسجيل والتحليل.',
          ),
          const SizedBox(height: 16),
          _ActionStepCard(
            number: 1,
            title: 'راجع الدرس',
            description:
                'افتح درس النغمة والإيقاع قبل التسجيل إذا لم تكن الجملة مستقرة بعد.',
            icon: Icons.school_rounded,
            action: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteLessonScreen(
                      lessonsFuture: lessonsFuture,
                      apiClient: apiClient,
                      dayPlan: dayPlan,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ابدأ من الدرس'),
            ),
          ),
          const SizedBox(height: 12),
          _ActionStepCard(
            number: 2,
            title: 'سجّل محاولة اليوم',
            description:
                'ستستمع إلى النموذج، تضبط التيمبو، ثم تسجل محاولة حقيقية قبل إرسالها للتحليل.',
            icon: Icons.mic_rounded,
            action: PrimaryButton(
              label: 'افتح التسجيل الآن',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PracticeScreen(
                      apiClient: apiClient,
                      dayPlan: dayPlan,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ActionStepCard(
            number: 3,
            title: 'راجع النتائج السابقة',
            description:
                'افتح آخر المحاولات ومؤشرات التقدم حتى تعرف ما الذي يجب تحسينه في المحاولة التالية.',
            icon: Icons.insights_rounded,
            action: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProgressScreen(apiClient: apiClient),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('افتح التقدم'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStepCard extends StatelessWidget {
  const _ActionStepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });

  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(
                  '$number',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description),
          const SizedBox(height: 14),
          action,
        ],
      ),
    );
  }
}
