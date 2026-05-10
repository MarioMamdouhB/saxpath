import 'package:flutter/material.dart';

import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/education/beginner_practice_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationBeginnerPathLessonScreen extends StatefulWidget {
  const FoundationBeginnerPathLessonScreen({
    super.key,
    required this.lesson,
    required this.repository,
    required this.practiceService,
  });

  final BeginnerPathLesson lesson;
  final SaxFoundationRepository repository;
  final BeginnerPracticeService practiceService;

  @override
  State<FoundationBeginnerPathLessonScreen> createState() =>
      _FoundationBeginnerPathLessonScreenState();
}

class _FoundationBeginnerPathLessonScreenState
    extends State<FoundationBeginnerPathLessonScreen> {
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final exercises =
        widget.repository.getExercisesByIds(widget.lesson.exerciseIds);
    final firstNote = widget.lesson.noteIds.isEmpty
        ? null
        : widget.repository.noteById(widget.lesson.noteIds.first);

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: widget.lesson.title,
            subtitle: widget.lesson.subtitle,
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
                Text(widget.lesson.goal),
                const SizedBox(height: 12),
                Text(widget.lesson.explanation),
              ],
            ),
          ),
          if (firstNote != null) ...[
            const SizedBox(height: 16),
            SaxFingeringCard(
              noteLabel: firstNote.label,
              fingering: firstNote.fingering,
              title: 'Fingering',
            ),
          ],
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('1. Hand position check'),
                const SizedBox(height: 6),
                Text('2. ${widget.lesson.listenStep}'),
                const SizedBox(height: 6),
                Text('3. ${widget.lesson.playStep}'),
                const SizedBox(height: 6),
                Text('4. ${widget.lesson.rhythmVariation}'),
                const SizedBox(height: 6),
                const Text('5. Mark complete'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (firstNote != null)
            MockPlaybackCard(
              title: 'Listen step',
              caption: widget.lesson.listenStep,
              accentLabel: firstNote.label,
              pattern: PlaybackPattern.note,
              patternKey: firstNote.label,
              durationSeconds: 8,
            ),
          const SizedBox(height: 16),
          for (final exercise in exercises) ...[
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(exercise.summary),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Start practice exercise',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FoundationExercisePlayerScreen(
                            exercise: exercise,
                            note: firstNote,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completion state',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(_completed ? 'Marked complete.' : 'Not completed yet.'),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _completed ? 'Completed' : 'Mark complete',
                  onPressed: _completed
                      ? null
                      : () async {
                          await widget.practiceService.markExerciseCompleted(
                              widget.lesson.completionKey);
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _completed = true;
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
