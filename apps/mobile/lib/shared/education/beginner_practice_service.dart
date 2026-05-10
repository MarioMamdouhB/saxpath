import 'package:shared_preferences/shared_preferences.dart';

import 'sax_foundation_models.dart';
import 'sax_foundation_repository.dart';

class BeginnerPracticeService {
  const BeginnerPracticeService({
    this.repository = const SaxFoundationRepository(),
  });

  static const _completedExercisesKey =
      'foundation_beginner_completed_exercises';
  static const _knownNotesKey = 'foundation_beginner_known_notes';

  final SaxFoundationRepository repository;

  Future<Set<String>> loadCompletedExerciseIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedExercisesKey) ?? const <String>[])
        .toSet();
  }

  Future<void> markExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await loadCompletedExerciseIds()
      ..add(exerciseId);
    await prefs.setStringList(_completedExercisesKey, items.toList()..sort());
  }

  Future<Set<String>> loadKnownNoteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_knownNotesKey) ?? const <String>[]).toSet();
  }

  Future<void> setKnownNote(String noteId, bool known) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await loadKnownNoteIds();
    if (known) {
      notes.add(noteId);
    } else {
      notes.remove(noteId);
    }
    await prefs.setStringList(_knownNotesKey, notes.toList()..sort());
  }

  BeginnerPracticePlan generateBeginnerDailyPractice({
    Set<String> knownNoteIds = const <String>{},
  }) {
    final items = <BeginnerPracticeItem>[
      const BeginnerPracticeItem(
        id: 'practice_hand_position',
        title: 'Hand position check',
        durationMinutes: 2,
        exerciseId: 'silent_finger_placement',
        description: 'راجع thumb rest, thumb hook, وتقوس الأصابع.',
      ),
    ];

    if (!knownNoteIds.contains('note_b')) {
      items.addAll(const [
        BeginnerPracticeItem(
          id: 'practice_note_b',
          title: 'Learn note B',
          durationMinutes: 5,
          noteId: 'note_b',
          exerciseId: 'b_long_tone',
          skippable: true,
          description: 'استمع إلى B ثم اثبتها كـ long tone.',
        ),
        BeginnerPracticeItem(
          id: 'practice_b_hold',
          title: 'Play B long tone',
          durationMinutes: 5,
          noteId: 'note_b',
          exerciseId: 'b_metronome_hold',
          skippable: true,
          description: 'نفذ B مع metronome بطيء.',
        ),
      ]);
    }

    if (!knownNoteIds.contains('note_a')) {
      items.add(
        const BeginnerPracticeItem(
          id: 'practice_note_a',
          title: 'Learn note A',
          durationMinutes: 5,
          noteId: 'note_a',
          exerciseId: 'a_long_tone',
          skippable: true,
          description: 'أضف الإصبع الأوسط وراجع الانتقال من B إلى A.',
        ),
      );
    }

    items.add(
      const BeginnerPracticeItem(
        id: 'practice_b_a_rhythm',
        title: 'Play B-A rhythm',
        durationMinutes: 5,
        exerciseId: 'b_a_change',
        description: 'حوّل أول نغمتين إلى pattern إيقاعي بسيط.',
      ),
    );

    return BeginnerPracticePlan(
      title: 'Beginner Daily Practice',
      items: items,
    );
  }
}
