import 'package:flutter/material.dart';

import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/foundation/widgets/foundation_exercise_card.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_service.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationHandPositionScreen extends StatelessWidget {
  const FoundationHandPositionScreen({
    super.key,
    this.foundationService = const SaxFoundationService(),
  });

  final SaxFoundationService foundationService;

  @override
  Widget build(BuildContext context) {
    final lessons = foundationService.loadHandPositionLessons();
    final exercises = foundationService.loadHandPositionExercises();

    return Scaffold(
      appBar: AppBar(title: const Text('Hand Position')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Hand Position',
            subtitle:
                'ابدأ من وضع الجسم والأصابع قبل النغمات. كل نقطة هنا تقود مباشرة إلى تمرين عملي.',
          ),
          const SizedBox(height: 16),
          for (final lesson in lessons) ...[
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.cue,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(lesson.detail),
                  const SizedBox(height: 12),
                  for (final checkpoint in lesson.checkpoints) ...[
                    Text('• $checkpoint'),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SectionTitle(
            title: 'Hand Position Exercises',
            subtitle:
                'نفّذ التمارين التالية من غير استعجال. كل تمرين هنا يبني عادة حركية ستحتاجها داخل كل note lesson لاحقًا.',
          ),
          const SizedBox(height: 12),
          for (final exercise in exercises) ...[
            FoundationExerciseCard(
              exercise: exercise,
              onStart: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoundationExercisePlayerScreen(
                      exercise: exercise,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
