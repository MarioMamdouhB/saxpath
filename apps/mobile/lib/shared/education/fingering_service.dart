import 'sax_foundation_models.dart';
import 'sax_foundation_repository.dart';

class FingeringService {
  const FingeringService({
    this.repository = const SaxFoundationRepository(),
  });

  final SaxFoundationRepository repository;

  SaxFingering getFingeringByNote(String noteId) {
    return repository.noteById(noteId).fingering;
  }

  List<FoundationNoteModel> getFirstNotes() {
    return repository.getFirstNotes();
  }

  List<String> getCommonMistakes(String noteId) {
    return repository.noteById(noteId).commonMistakes;
  }

  String getFingeringSummary(SaxFingering fingering) {
    final parts = <String>[];
    if (fingering.octaveKey) {
      parts.add('Octave');
    }
    if (fingering.leftIndex) {
      parts.add('L1');
    }
    if (fingering.leftMiddle) {
      parts.add('L2');
    }
    if (fingering.leftRing) {
      parts.add('L3');
    }
    if (fingering.rightIndex) {
      parts.add('R1');
    }
    if (fingering.rightMiddle) {
      parts.add('R2');
    }
    if (fingering.rightRing) {
      parts.add('R3');
    }
    if (fingering.sideKeys) {
      parts.add('Side');
    }
    if (fingering.palmKeys) {
      parts.add('Palm');
    }
    if (fingering.lowKeys) {
      parts.add('Low');
    }
    return parts.isEmpty ? 'Open / relaxed' : parts.join(' + ');
  }
}
