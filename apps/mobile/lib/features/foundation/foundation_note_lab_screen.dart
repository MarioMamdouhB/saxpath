import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/foundation/foundation_note_lesson_screen.dart';
import 'package:saxpath_mobile/features/foundation/widgets/foundation_exercise_card.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationNoteLabScreen extends StatefulWidget {
  const FoundationNoteLabScreen({
    super.key,
    required this.repository,
  });

  final SaxFoundationRepository repository;

  @override
  State<FoundationNoteLabScreen> createState() =>
      _FoundationNoteLabScreenState();
}

class _FoundationNoteLabScreenState extends State<FoundationNoteLabScreen> {
  late List<FoundationNoteModel> _notes;
  late FoundationNoteModel _selectedNote;

  @override
  void initState() {
    super.initState();
    _notes = widget.repository.getNotes();
    _selectedNote = _notes.first;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.repository.getExercisesForNote(_selectedNote.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Notes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Learn Notes + Fingering Chart',
            subtitle:
                'اختر نغمة واحدة، راقب مكانها، افهم فينجرينجها، ثم ادخل مباشرة إلى تمرين عملي عليها.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final note in _notes)
                ChoiceChip(
                  label: Text(note.label),
                  selected: _selectedNote.id == note.id,
                  onSelected: (_) {
                    setState(() {
                      _selectedNote = note;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.deepTeal,
                    AppColors.navyLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _selectedNote.arabicName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _selectedNote.label,
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedNote.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          NoteStaffCard(noteLabel: _selectedNote.label),
          const SizedBox(height: 16),
          SaxFingeringCard(
            noteLabel: _selectedNote.fingering.noteLabel,
            title: 'Fingering Chart',
            fingering: _selectedNote.fingering,
            summary:
                'Concert for Alto: ${_selectedNote.concertPitchForAlto} | Concert for Tenor: ${_selectedNote.concertPitchForTenor}',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Practical Focus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FoundationNoteLessonScreen(
                              note: _selectedNote,
                            ),
                          ),
                        );
                      },
                      child: const Text('Start note lesson'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_selectedNote.tonalGoal),
                const SizedBox(height: 10),
                Text(_selectedNote.fingering.handPositionTip),
                const SizedBox(height: 6),
                Text(_selectedNote.fingering.embouchureTip),
                const SizedBox(height: 6),
                Text(_selectedNote.fingering.airflowTip),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Note Exercises',
            subtitle:
                'كل نغمة في هذه الطبقة التأسيسية مرتبطة بتمارين قابلة للتشغيل والتسجيل مباشرة.',
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
                      note: _selectedNote,
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
