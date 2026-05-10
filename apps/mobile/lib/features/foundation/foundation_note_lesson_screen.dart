import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/practice/widgets/mock_recording_card.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/education/beginner_practice_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_service.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationNoteLessonScreen extends StatefulWidget {
  const FoundationNoteLessonScreen({
    super.key,
    required this.note,
    this.foundationService = const SaxFoundationService(),
    this.repository = const SaxFoundationRepository(),
    this.practiceService = const BeginnerPracticeService(),
  });

  final FoundationNoteModel note;
  final SaxFoundationService foundationService;
  final SaxFoundationRepository repository;
  final BeginnerPracticeService practiceService;

  @override
  State<FoundationNoteLessonScreen> createState() =>
      _FoundationNoteLessonScreenState();
}

class _FoundationNoteLessonScreenState
    extends State<FoundationNoteLessonScreen> {
  bool _markedComplete = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.foundationService.loadNoteLesson(widget.note.id);

    return Scaffold(
      appBar: AppBar(title: Text('Learn ${widget.note.label}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: lesson.title,
            subtitle:
                'Listen → Understand Fingering → Place Fingers → Play → Change Notes → Record → Evaluate',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(lesson.goal),
                const SizedBox(height: 12),
                Text(
                  lesson.explanation,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NoteStaffCard(noteLabel: widget.note.label),
          const SizedBox(height: 16),
          SaxFingeringCard(
            noteLabel: widget.note.label,
            title: 'Understand Fingering',
            fingering: widget.note.fingering,
            summary:
                'Concert for Alto: ${widget.note.concertPitchForAlto} | Concert for Tenor: ${widget.note.concertPitchForTenor}',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Common Mistakes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (final mistake in widget.note.commonMistakes) ...[
                  Text('• $mistake'),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final step in lesson.steps) ...[
            _LessonStepCard(
              step: step,
              note: widget.note,
              exercise: step.exerciseId == null
                  ? null
                  : widget.repository.exerciseById(step.exerciseId!),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          MockRecordingCard(
            exerciseId: 'lesson_${widget.note.id}',
            dayNumber: 1,
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evaluate / Placeholder Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Recording analysis will be connected later. For now, mark the exercise as completed manually.',
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _markedComplete
                      ? 'Lesson marked complete'
                      : 'Mark lesson complete',
                  onPressed: _markedComplete
                      ? null
                      : () async {
                          await widget.practiceService.markExerciseCompleted(
                              'lesson_${widget.note.id}');
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _markedComplete = true;
                          });
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonStepCard extends StatelessWidget {
  const _LessonStepCard({
    required this.step,
    required this.note,
    required this.exercise,
  });

  final NoteLessonStep step;
  final FoundationNoteModel note;
  final FoundationPracticeExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
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
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          if (step.stage == NoteLessonStage.listen) ...[
            const SizedBox(height: 12),
            MockPlaybackCard(
              title: 'Listen to ${note.label}',
              caption: 'استمع جيدًا قبل أول محاولة عزف.',
              accentLabel: note.label,
              pattern: PlaybackPattern.note,
              patternKey: note.label,
              durationSeconds: 8,
            ),
          ],
          if (step.stage == NoteLessonStage.placeFingers) ...[
            const SizedBox(height: 12),
            Text('• ${note.fingering.handPositionTip}'),
            const SizedBox(height: 6),
            Text('• ${note.fingering.embouchureTip}'),
            const SizedBox(height: 6),
            Text('• ${note.fingering.airflowTip}'),
          ],
          if (exercise != null) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Start ${exercise!.title}',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoundationExercisePlayerScreen(
                      exercise: exercise!,
                      note: note,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
