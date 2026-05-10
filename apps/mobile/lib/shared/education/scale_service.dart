import 'sax_foundation_models.dart';
import 'sax_foundation_repository.dart';

class ScaleNoteReference {
  const ScaleNoteReference({
    required this.label,
    this.note,
    this.referenceHint,
  });

  final String label;
  final FoundationNoteModel? note;
  final String? referenceHint;
}

class ScaleService {
  const ScaleService({
    this.repository = const SaxFoundationRepository(),
  });

  final SaxFoundationRepository repository;

  List<FoundationScaleLesson> getScaleLessons() {
    return repository.getScales();
  }

  FoundationScaleLesson getScaleLesson(String scaleId) {
    return repository.scaleById(scaleId);
  }

  List<ScaleNoteReference> getScaleNotes(String scaleId) {
    final scale = getScaleLesson(scaleId);
    return scale.noteSequence.map((label) {
      final note = repository.findNoteByWrittenNote(label);
      if (note != null) {
        return ScaleNoteReference(label: label, note: note);
      }
      return ScaleNoteReference(
        label: label,
        referenceHint:
            'فنجرة $label ستُضاف هنا لاحقًا. إلى أن تصل، ركّز على شكل السلم ببطء واستمع جيدًا لانتقال هذه النغمة داخل التسلسل.',
      );
    }).toList(growable: false);
  }

  List<FoundationPracticeExercise> getScaleExercises(String scaleId) {
    return repository.getExercisesForScale(scaleId);
  }
}
