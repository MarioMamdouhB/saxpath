import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_note_lesson_screen.dart';
import 'package:saxpath_mobile/shared/education/fingering_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationFingeringChartScreen extends StatelessWidget {
  const FoundationFingeringChartScreen({
    super.key,
    this.repository = const SaxFoundationRepository(),
    this.fingeringService = const FingeringService(),
  });

  final SaxFoundationRepository repository;
  final FingeringService fingeringService;

  @override
  Widget build(BuildContext context) {
    final notes = repository.getFirstNotes();

    return Scaffold(
      appBar: AppBar(title: const Text('Fingering Chart')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Fingering Chart',
            subtitle:
                'ابدأ بالنوت الأساسية B, A, G, F, E, D, C. كل card هنا يعرض الفينجرينج من data ويقود مباشرة إلى التدريب.',
          ),
          const SizedBox(height: 16),
          for (final note in notes) ...[
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.label,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softMint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          note.register.label,
                          style: const TextStyle(
                            color: AppColors.deepTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fingering summary: ${fingeringService.getFingeringSummary(note.fingering)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SaxFingeringCard(
                    noteLabel: note.label,
                    fingering: note.fingering,
                    title: 'Interactive fingering diagram',
                    summary:
                        'If a finger state is true, the key appears pressed. If false, it appears unpressed.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Common mistakes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final mistake in note.commonMistakes) ...[
                    Text('• $mistake'),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Start practice',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FoundationNoteLessonScreen(
                            note: note,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
