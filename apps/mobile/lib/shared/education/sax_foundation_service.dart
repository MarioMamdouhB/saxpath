import 'sax_foundation_models.dart';
import 'sax_foundation_repository.dart';

class SaxFoundationService {
  const SaxFoundationService({
    this.repository = const SaxFoundationRepository(),
  });

  final SaxFoundationRepository repository;

  List<HandPositionGuide> loadHandPositionLessons() {
    return repository.getHandPositionLessons();
  }

  List<FoundationPracticeExercise> loadHandPositionExercises() {
    return repository.getHandPositionExercises();
  }

  List<FoundationNoteModel> loadNoteLessons() {
    return repository.getNotes();
  }

  NoteLessonFlow loadNoteLesson(String noteId) {
    final note = repository.noteById(noteId);
    final changeExercise = note.exerciseIds.length > 2
        ? repository.exerciseById(note.exerciseIds[2])
        : repository.exerciseById(note.exerciseIds.last);

    return NoteLessonFlow(
      noteId: note.id,
      title: 'Learn ${note.label}',
      goal: note.tonalGoal,
      explanation: note.description,
      steps: [
        NoteLessonStep(
          stage: NoteLessonStage.listen,
          title: 'Listen',
          description: 'استمع إلى ${note.label} أولاً قبل العزف.',
          exerciseId: note.exerciseIds.first,
        ),
        NoteLessonStep(
          stage: NoteLessonStage.understandFingering,
          title: 'Understand Fingering',
          description: 'راجع مفاتيح ${note.label} واعرف أي أصابع مضغوطة.',
        ),
        NoteLessonStep(
          stage: NoteLessonStage.placeFingers,
          title: 'Place Fingers',
          description: note.fingering.handPositionTip,
        ),
        NoteLessonStep(
          stage: NoteLessonStage.playLongTone,
          title: 'Play Long Tone',
          description: 'اعزف ${note.label} لمدة 4 beats وكررها بهدوء.',
          exerciseId: note.exerciseIds[1],
        ),
        NoteLessonStep(
          stage: NoteLessonStage.changeNotes,
          title: 'Change Notes',
          description: changeExercise.instructions,
          exerciseId: changeExercise.id,
        ),
        const NoteLessonStep(
          stage: NoteLessonStage.record,
          title: 'Record / Placeholder Record',
          description:
              'يمكنك التسجيل الآن لو كان الميكروفون متاحًا. الواجهة جاهزة حتى قبل ربط أي تحليل ذكي.',
        ),
        const NoteLessonStep(
          stage: NoteLessonStage.evaluate,
          title: 'Evaluate / Placeholder Feedback',
          description:
              'Recording analysis will be connected later. For now, mark the exercise as completed manually.',
        ),
      ],
    );
  }

  List<BeginnerPathLesson> loadBeginnerLessons() {
    return repository.getBeginnerPathLessons();
  }

  BeginnerPathLesson loadBeginnerLesson(String lessonId) {
    return repository.beginnerPathLessonById(lessonId);
  }
}
