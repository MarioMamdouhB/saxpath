import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_beginner_path_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_fingering_chart_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_hand_position_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_note_lab_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_practice_flow_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_scale_lessons_screen.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class SaxFoundationScreen extends StatelessWidget {
  const SaxFoundationScreen({
    super.key,
    this.repository = const SaxFoundationRepository(),
  });

  final SaxFoundationRepository repository;

  @override
  Widget build(BuildContext context) {
    final track = repository.getTrack();
    final exerciseCount = {
      for (final note in track.notes) ...note.exerciseIds,
      for (final scale in track.scales) ...scale.exerciseIds,
    }.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Saxophone Foundation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Saxophone Foundation',
            subtitle:
                'المستخدم يفتح، يتعلم يمسك الساكس، يتعلم أول نوت، يشوف الفينجرينج، يعزف، يتدرب، يدخل على scales، ثم يصبح جاهزًا للـ blues والـ jazz.',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatTile(title: 'Notes', value: '${track.notes.length}'),
                _StatTile(title: 'Scales', value: '${track.scales.length}'),
                _StatTile(title: 'Exercises', value: '$exerciseCount'),
                const _StatTile(title: 'Category', value: 'Sax Basics'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Saxophone Basics',
            subtitle:
                'Hand Position, Fingering Chart, Learn Notes, First 5 Notes, Scales, and Beginner Practice all live here as one practical system.',
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'Hand Position',
            subtitle:
                'Left hand, right hand, and general posture with silent placement and finger-movement exercises.',
            actionLabel: 'Open Hand Position',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FoundationHandPositionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'Fingering Chart',
            subtitle:
                'B, A, G, F, E, D, C cards with note name, register, summary, common mistakes, and interactive data-driven diagrams.',
            actionLabel: 'Open Fingering Chart',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FoundationFingeringChartScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'Learn Notes',
            subtitle:
                'Each note follows: Listen → Understand Fingering → Place Fingers → Play Long Tone → Change Notes → Record → Evaluate.',
            actionLabel: 'Open Learn Notes',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoundationNoteLabScreen(
                    repository: repository,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'First 5 Notes',
            subtitle:
                'Day 1 B, Day 2 A, Day 3 G, Day 4 B-A-G, Day 5 F, Day 6 E, Day 7 First 5-note melody.',
            actionLabel: 'Open First 5 Notes',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoundationBeginnerPathScreen(
                    repository: repository,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'Scales',
            subtitle:
                'C Major, G Major, F Major, A Minor Pentatonic, and A Blues all move from scale to phrase to musical application.',
            actionLabel: 'Open Scales',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoundationScaleLessonsScreen(
                    repository: repository,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _FoundationModuleCard(
            title: 'Beginner Practice',
            subtitle:
                'Beginner Daily Practice with hand-position check, first notes, rhythm work, and skip-basics support if a note is already known.',
            actionLabel: 'Open Beginner Practice',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoundationPracticeFlowScreen(
                    repository: repository,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Text(
              'كل note تقود إلى exercise، وكل fingering تقود إلى playing، وكل scale تقود إلى phrase. هذا هو الجسر العملي قبل التوسع إلى البلوز والجاز.',
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundationModuleCard extends StatelessWidget {
  const _FoundationModuleCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: actionLabel,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.deepTeal,
            ),
          ),
        ],
      ),
    );
  }
}
