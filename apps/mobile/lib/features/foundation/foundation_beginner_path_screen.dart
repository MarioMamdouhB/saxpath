import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_beginner_path_lesson_screen.dart';
import 'package:saxpath_mobile/shared/education/beginner_practice_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationBeginnerPathScreen extends StatelessWidget {
  const FoundationBeginnerPathScreen({
    super.key,
    this.repository = const SaxFoundationRepository(),
    this.practiceService = const BeginnerPracticeService(),
  });

  final SaxFoundationRepository repository;
  final BeginnerPracticeService practiceService;

  @override
  Widget build(BuildContext context) {
    final lessons = repository.getBeginnerPathLessons();

    return Scaffold(
      appBar: AppBar(title: const Text('First 5 Notes')),
      body: FutureBuilder<Set<String>>(
        future: practiceService.loadCompletedExerciseIds(),
        builder: (context, snapshot) {
          final completed = snapshot.data ?? const <String>{};

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'First 5 Notes Beginner Path',
                subtitle:
                    'Day 1 B, Day 2 A, Day 3 G, Day 4 B-A-G, Day 5 F, Day 6 E, Day 7 First 5-note melody.',
              ),
              const SizedBox(height: 16),
              for (final lesson in lessons) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FoundationBeginnerPathLessonScreen(
                          lesson: lesson,
                          repository: repository,
                          practiceService: practiceService,
                        ),
                      ),
                    );
                  },
                  child: SaxCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: completed.contains(lesson.completionKey)
                                    ? AppColors.deepTeal
                                    : AppColors.softMint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                completed.contains(lesson.completionKey)
                                    ? 'Completed'
                                    : 'In Progress',
                                style: TextStyle(
                                  color:
                                      completed.contains(lesson.completionKey)
                                          ? Colors.white
                                          : AppColors.deepTeal,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(lesson.goal),
                        const SizedBox(height: 8),
                        Text(
                          lesson.rhythmVariation,
                          style: const TextStyle(
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}
