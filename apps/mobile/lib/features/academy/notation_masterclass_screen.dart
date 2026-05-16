import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/academy/widgets/notation_step_card.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class NotationMasterclassScreen extends StatelessWidget {
  const NotationMasterclassScreen({
    super.key,
    this.repository = const SaxFoundationRepository(),
  });

  final SaxFoundationRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مختبر النوتة (Notation Lab)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'تعلم قراءة الموسيقى من الصفر',
            subtitle:
                'منهج عملي يحول النوتة الصامتة في الكتب إلى تمارين تفاعلية تسمعها وتعزفها.',
          ),
          const SizedBox(height: 16),
          NotationStepCard(
            title: '1. لغة المدرج الموسيقي',
            description:
                'تعرف على الخطوط الخمسة، المسافات، ومفتاح صول (Treble Clef) وكيف يقرأ الساكسفون هذه الرموز.',
            onStart: () => _openExercise(context, 'silent_finger_placement'),
          ),
          const SizedBox(height: 12),
          NotationStepCard(
            title: '2. نغمة صول (G) - أول لقاء',
            description: 'شاهد نغمة صول على المدرج، اسمع ترددها الحقيقي، وحاول مطابقتها بآلتك.',
            noteLabel: 'G',
            onStart: () => _openExercise(context, 'g_long_tone'),
          ),
          const SizedBox(height: 12),
          const NotationStepCard(
            title: '3. الإيقاع الأول: النوار (Quarter Note)',
            description: 'تعلم كيف تقرأ الرمز الذي يستغرق نبضة واحدة. تدرب على التصفيق مع الميترونوم قبل العزف.',
          ),
          const SizedBox(height: 12),
          NotationStepCard(
            title: '4. تمرين النغمات الثلاث (B-A-G)',
            description:
                'أول تمرين من "Universal Method". اقرأ النوتات الثلاث المتتالية واعزفها مع المرجع الصوتي.',
            noteLabel: 'B A G',
            onStart: () => _openExercise(context, 'b_a_g_pattern'),
          ),
          const SizedBox(height: 24),
          const _BookLinkCard(),
        ],
      ),
    );
  }

  void _openExercise(BuildContext context, String exerciseId) {
    final exercise = repository.exerciseById(exerciseId);
    final note = repository.findNoteByWrittenNote(exercise.playbackKey.split(' ').first);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoundationExercisePlayerScreen(
          exercise: exercise,
          note: note,
        ),
      ),
    );
  }
}

class _BookLinkCard extends StatelessWidget {
  const _BookLinkCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 40,
            color: AppColors.deepTeal,
          ),
          SizedBox(height: 12),
          Text(
            'مستوحى من مناهج عالمية',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'تم تصميم هذه التمارين بناءً على كتب Rubank Elementary Method و DeVille Universal Method.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
