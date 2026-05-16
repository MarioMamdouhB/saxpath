import '../audio/generated_audio.dart';
import 'sax_foundation_models.dart';

class MethodBookRepository {
  const MethodBookRepository();

  List<FoundationPracticeExercise> getRubankLessons() {
    return _rubankExercises;
  }

  List<FoundationPracticeExercise> getDeVilleLessons() {
    return _deVilleExercises;
  }

  FoundationPracticeExercise exerciseById(String id) {
    return [..._rubankExercises, ..._deVilleExercises].firstWhere((e) => e.id == id);
  }
}

const _rubankExercises = [
  FoundationPracticeExercise(
    id: 'rubank_l1_1',
    title: 'Rubank Lesson 1: First Notes',
    summary: 'تدريب على نغمات B, A, G باستخدام النوار (Quarter Notes).',
    instructions: 'اعزف النوتات الموضحة بتركيز على تساوي الزمن ونظافة الصوت.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G A B',
    recommendedBpm: 60,
    durationMinutes: 5,
    checkpoints: ['اللسان يلمس الريشة بخفة', 'النفس مستمر'],
  ),
  FoundationPracticeExercise(
    id: 'rubank_l1_2',
    title: 'Rubank Lesson 1: Crossing Hands',
    summary: 'الانتقال بين اليد اليسرى واليمنى (G إلى F).',
    instructions: 'انتبه للحظة نزول السبابة اليمنى، يجب أن تكون متزامنة تماماً مع الإيقاع.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G F G F G',
    recommendedBpm: 56,
    durationMinutes: 5,
  ),
];

const _deVilleExercises = [
  FoundationPracticeExercise(
    id: 'deville_art_1',
    title: 'DeVille: Basic Articulation',
    summary: 'التفريق بين الـ Legato والـ Staccato.',
    instructions: 'اعزف النغمات متصلة أولاً، ثم كررها منفصلة بضربات لسان واضحة.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.rhythm,
    playbackKey: 'quarter_note',
    recommendedBpm: 66,
    durationMinutes: 4,
  ),
];
