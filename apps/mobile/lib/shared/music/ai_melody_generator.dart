import 'dart:math';

class AiMelodyGenerator {
  static const List<String> _beginnerNotes = ['G4', 'A4', 'B4', 'C5', 'D5'];
  static const List<String> _intermediateNotes = ['D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'F5'];

  static String generateDailyChallenge({bool isPro = false}) {
    final random = Random(DateTime.now().day + DateTime.now().month); // Deterministic for the day
    final source = isPro ? _intermediateNotes : _beginnerNotes;

    List<String> melody = [];
    for (int i = 0; i < 8; i++) {
      melody.add(source[random.nextInt(source.length)]);
    }

    return melody.join(' ');
  }
}
