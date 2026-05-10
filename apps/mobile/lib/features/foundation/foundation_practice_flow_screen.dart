import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_note_lesson_screen.dart';
import 'package:saxpath_mobile/shared/education/beginner_practice_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationPracticeFlowScreen extends StatefulWidget {
  const FoundationPracticeFlowScreen({
    super.key,
    required this.repository,
    this.practiceService = const BeginnerPracticeService(),
  });

  final SaxFoundationRepository repository;
  final BeginnerPracticeService practiceService;

  @override
  State<FoundationPracticeFlowScreen> createState() =>
      _FoundationPracticeFlowScreenState();
}

class _FoundationPracticeFlowScreenState
    extends State<FoundationPracticeFlowScreen> {
  late final List<BeginnerPracticeStep> _steps;
  final Set<String> _completedSteps = <String>{};
  Set<String> _knownNoteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _steps = widget.repository.getTrack().beginnerFlow;
    widget.practiceService.loadKnownNoteIds().then((known) {
      if (!mounted) {
        return;
      }
      setState(() {
        _knownNoteIds = known;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final generatedPlan = widget.practiceService.generateBeginnerDailyPractice(
      knownNoteIds: _knownNoteIds,
    );
    final totalMinutes = generatedPlan.items.fold<int>(
      0,
      (sum, item) => sum + item.durationMinutes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Beginner Practice Flow')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Beginner Practice Flow',
            subtitle:
                'مسار يومي واضح للمبتدئ: وضعية، أول خمس نغمات، سلالم قصيرة، ثم تسجيل ومراجعة ذاتية.',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مدة الجلسة المقترحة: $totalMinutes دقيقة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'الهدف من هذا التدفق أن تتحول النغمة والسلم إلى ممارسة يومية قابلة للقياس، لا مجرد معلومات نظرية.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'إعادة ضبط التحقق',
                  onPressed: () {
                    setState(_completedSteps.clear);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skip basics if already known',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final note in widget.repository.getFirstNotes())
                      FilterChip(
                        label: Text('I know ${note.label}'),
                        selected: _knownNoteIds.contains(note.id),
                        onSelected: (selected) async {
                          await widget.practiceService.setKnownNote(
                            note.id,
                            selected,
                          );
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            if (selected) {
                              _knownNoteIds.add(note.id);
                            } else {
                              _knownNoteIds.remove(note.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  generatedPlan.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (final item in generatedPlan.items) ...[
                  Text(
                    '${item.title} - ${item.durationMinutes} min',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(item.description),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final step in _steps) ...[
            _FlowStepCard(
              step: step,
              exercises: widget.repository.getExercisesForFlowStep(step),
              isCompleted: _completedSteps.contains(step.id),
              onToggleComplete: () {
                setState(() {
                  if (_completedSteps.contains(step.id)) {
                    _completedSteps.remove(step.id);
                  } else {
                    _completedSteps.add(step.id);
                  }
                });
              },
              onOpenExercise: (exercise) {
                final relatedNote = exercise.relatedNoteIds.isNotEmpty
                    ? widget.repository.noteById(exercise.relatedNoteIds.first)
                    : null;
                final relatedScale = exercise.relatedScaleIds.isNotEmpty
                    ? widget.repository
                        .scaleById(exercise.relatedScaleIds.first)
                    : null;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoundationExercisePlayerScreen(
                      exercise: exercise,
                      note: relatedNote,
                      scale: relatedScale,
                    ),
                  ),
                );
              },
              onOpenNoteLesson: (noteId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoundationNoteLessonScreen(
                      note: widget.repository.noteById(noteId),
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

class _FlowStepCard extends StatelessWidget {
  const _FlowStepCard({
    required this.step,
    required this.exercises,
    required this.isCompleted,
    required this.onToggleComplete,
    required this.onOpenExercise,
    required this.onOpenNoteLesson,
  });

  final BeginnerPracticeStep step;
  final List<FoundationPracticeExercise> exercises;
  final bool isCompleted;
  final VoidCallback onToggleComplete;
  final ValueChanged<FoundationPracticeExercise> onOpenExercise;
  final ValueChanged<String> onOpenNoteLesson;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isCompleted,
                activeColor: AppColors.deepTeal,
                onChanged: (_) => onToggleComplete(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'الوقت المقترح: ${step.recommendedMinutes} د',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (step.id == 'flow_note_b' || step.id == 'flow_note_a') ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => onOpenNoteLesson(
                  step.id == 'flow_note_b' ? 'note_b' : 'note_a'),
              child: const Text('Open note lesson'),
            ),
          ],
          const SizedBox(height: 12),
          for (final exercise in exercises) ...[
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onOpenExercise(exercise),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            exercise.summary,
                            style: const TextStyle(
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.deepTeal,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
