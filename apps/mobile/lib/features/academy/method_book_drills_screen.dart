import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/foundation/widgets/foundation_exercise_card.dart';
import 'package:saxpath_mobile/shared/education/method_book_repository.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class MethodBookDrillsScreen extends StatelessWidget {
  const MethodBookDrillsScreen({
    super.key,
    this.repository = const MethodBookRepository(),
    this.foundationRepo = const SaxFoundationRepository(),
  });

  final MethodBookRepository repository;
  final SaxFoundationRepository foundationRepo;

  @override
  Widget build(BuildContext context) {
    final rubank = repository.getRubankLessons();
    final deville = repository.getDeVilleLessons();

    return Scaffold(
      appBar: AppBar(title: const Text('المناهج العالمية (Method Books)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'تمارين من الكتب العالمية',
            subtitle: 'حولنا أشهر كتب تعليم الساكسفون إلى تدريبات تفاعلية تسمعها وتجربها فوراً.',
          ),
          const SizedBox(height: 16),
          _buildBookSection(context, 'Rubank Elementary Method', rubank),
          const SizedBox(height: 24),
          _buildBookSection(context, 'Universal Method (Paul DeVille)', deville),
        ],
      ),
    );
  }

  Widget _buildBookSection(BuildContext context, String bookTitle, List exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bookTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepTeal),
        ),
        const SizedBox(height: 12),
        for (final exercise in exercises) ...[
          FoundationExerciseCard(
            exercise: exercise,
            onStart: () {
              // We need a dummy note for the player or update the player to handle book exercises
              final dummyNote = foundationRepo.getNotes().first;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoundationExercisePlayerScreen(
                    exercise: exercise,
                    note: dummyNote,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
