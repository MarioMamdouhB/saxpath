import '../audio/generated_audio.dart';

enum SaxType {
  altoEb,
  tenorBb,
  sopranoBb,
  baritoneEb,
}

enum NoteName {
  c,
  cSharp,
  d,
  eFlat,
  e,
  f,
  fSharp,
  g,
  aFlat,
  a,
  bFlat,
  b,
}

enum Register {
  low,
  middle,
  upper,
  palm,
  altissimo,
}

enum FingerState {
  pressed,
  released,
  optional,
}

enum FoundationExerciseCategory {
  warmup,
  noteFocus,
  scaleFlow,
  coordination,
}

enum NoteLessonStage {
  listen,
  understandFingering,
  placeFingers,
  playLongTone,
  changeNotes,
  record,
  evaluate,
}

extension SaxTypeLabel on SaxType {
  String get label {
    switch (this) {
      case SaxType.altoEb:
        return 'Alto Eb';
      case SaxType.tenorBb:
        return 'Tenor Bb';
      case SaxType.sopranoBb:
        return 'Soprano Bb';
      case SaxType.baritoneEb:
        return 'Baritone Eb';
    }
  }
}

extension NoteNameLabel on NoteName {
  String get label {
    switch (this) {
      case NoteName.c:
        return 'C';
      case NoteName.cSharp:
        return 'C#';
      case NoteName.d:
        return 'D';
      case NoteName.eFlat:
        return 'Eb';
      case NoteName.e:
        return 'E';
      case NoteName.f:
        return 'F';
      case NoteName.fSharp:
        return 'F#';
      case NoteName.g:
        return 'G';
      case NoteName.aFlat:
        return 'Ab';
      case NoteName.a:
        return 'A';
      case NoteName.bFlat:
        return 'Bb';
      case NoteName.b:
        return 'B';
    }
  }
}

extension RegisterLabel on Register {
  String get label {
    switch (this) {
      case Register.low:
        return 'Low';
      case Register.middle:
        return 'Middle';
      case Register.upper:
        return 'Upper';
      case Register.palm:
        return 'Palm';
      case Register.altissimo:
        return 'Altissimo';
    }
  }
}

NoteName noteNameFromLabel(String label) {
  switch (label.toUpperCase()) {
    case 'C':
      return NoteName.c;
    case 'C#':
    case 'DB':
      return NoteName.cSharp;
    case 'D':
      return NoteName.d;
    case 'EB':
    case 'D#':
      return NoteName.eFlat;
    case 'E':
      return NoteName.e;
    case 'F':
      return NoteName.f;
    case 'F#':
    case 'GB':
      return NoteName.fSharp;
    case 'G':
      return NoteName.g;
    case 'AB':
    case 'G#':
      return NoteName.aFlat;
    case 'A':
      return NoteName.a;
    case 'BB':
    case 'A#':
      return NoteName.bFlat;
    case 'B':
      return NoteName.b;
    default:
      return NoteName.g;
  }
}

class HandPositionLesson {
  const HandPositionLesson({
    required this.title,
    required this.cue,
    required this.detail,
    this.id = '',
    this.saxType = SaxType.altoEb,
    this.checkpoints = const <String>[],
  });

  final String id;
  final String title;
  final String cue;
  final String detail;
  final SaxType saxType;
  final List<String> checkpoints;
}

class SaxFingering {
  const SaxFingering({
    required this.octaveKey,
    required this.leftIndex,
    required this.leftMiddle,
    required this.leftRing,
    required this.leftPinky,
    required this.rightIndex,
    required this.rightMiddle,
    required this.rightRing,
    required this.rightPinky,
    this.sideKeys = false,
    this.palmKeys = false,
    this.lowKeys = false,
  });

  final bool octaveKey;
  final bool leftIndex;
  final bool leftMiddle;
  final bool leftRing;
  final bool leftPinky;
  final bool rightIndex;
  final bool rightMiddle;
  final bool rightRing;
  final bool rightPinky;
  final bool sideKeys;
  final bool palmKeys;
  final bool lowKeys;

  FingerState stateForToken(String token) {
    switch (token) {
      case 'octave':
        return octaveKey ? FingerState.pressed : FingerState.released;
      case 'p1':
        return leftIndex ? FingerState.pressed : FingerState.released;
      case 'p2':
        return leftMiddle ? FingerState.pressed : FingerState.released;
      case 'p3':
        return leftRing ? FingerState.pressed : FingerState.released;
      case 'p4':
        return rightIndex ? FingerState.pressed : FingerState.released;
      case 'p5':
        return rightMiddle ? FingerState.pressed : FingerState.released;
      case 'p6':
        return rightRing ? FingerState.pressed : FingerState.released;
      case 'side1':
      case 'side2':
        return sideKeys ? FingerState.pressed : FingerState.released;
      case 'palmD':
      case 'palmE':
      case 'palmF':
        return palmKeys ? FingerState.pressed : FingerState.released;
      case 'lowD':
        return lowKeys ? FingerState.pressed : FingerState.released;
      default:
        return FingerState.optional;
    }
  }
}

class NoteExercise {
  const NoteExercise({
    required this.id,
    required this.title,
    required this.summary,
    required this.instructions,
    required this.category,
    required this.playbackPattern,
    required this.playbackKey,
    required this.recommendedBpm,
    required this.durationMinutes,
    this.relatedNoteIds = const <String>[],
    this.relatedScaleIds = const <String>[],
    this.checkpoints = const <String>[],
  });

  final String id;
  final String title;
  final String summary;
  final String instructions;
  final FoundationExerciseCategory category;
  final PlaybackPattern playbackPattern;
  final String playbackKey;
  final int recommendedBpm;
  final int durationMinutes;
  final List<String> relatedNoteIds;
  final List<String> relatedScaleIds;
  final List<String> checkpoints;
}

class NoteLessonStep {
  const NoteLessonStep({
    required this.stage,
    required this.title,
    required this.description,
    this.exerciseId,
  });

  final NoteLessonStage stage;
  final String title;
  final String description;
  final String? exerciseId;
}

class NoteLessonFlow {
  const NoteLessonFlow({
    required this.noteId,
    required this.title,
    required this.goal,
    required this.explanation,
    required this.steps,
  });

  final String noteId;
  final String title;
  final String goal;
  final String explanation;
  final List<NoteLessonStep> steps;
}

class ScalePhrasePrompt {
  const ScalePhrasePrompt({
    required this.title,
    required this.prompt,
  });

  final String title;
  final String prompt;
}

class SaxNote {
  const SaxNote({
    required this.id,
    required this.noteName,
    required this.writtenNote,
    required this.concertPitchForAlto,
    required this.concertPitchForTenor,
    required this.register,
    required this.fingering,
    required this.description,
    required this.commonMistakes,
    required this.exercises,
    this.arabicName = '',
    this.tonalGoal = '',
    this.anchorScaleIds = const <String>[],
  });

  final String id;
  final NoteName noteName;
  final String writtenNote;
  final String concertPitchForAlto;
  final String concertPitchForTenor;
  final Register register;
  final SaxFingering fingering;
  final String description;
  final List<String> commonMistakes;
  final List<NoteExercise> exercises;
  final String arabicName;
  final String tonalGoal;
  final List<String> anchorScaleIds;
}

class ScaleLesson {
  const ScaleLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.noteSequence,
    required this.tonalCenter,
    required this.purpose,
    required this.transferGoal,
    required this.relatedNoteIds,
    required this.exerciseIds,
    this.formula = '',
    this.slowPractice = '',
    this.metronomePractice = '',
    this.ascendingPractice = '',
    this.descendingPractice = '',
    this.rhythmVariation = '',
    this.simplePhraseApplication = '',
    this.backingTrackPlaceholder = '',
    this.phrasePrompts = const <ScalePhrasePrompt>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> noteSequence;
  final String tonalCenter;
  final String purpose;
  final String transferGoal;
  final List<String> relatedNoteIds;
  final List<String> exerciseIds;
  final String formula;
  final String slowPractice;
  final String metronomePractice;
  final String ascendingPractice;
  final String descendingPractice;
  final String rhythmVariation;
  final String simplePhraseApplication;
  final String backingTrackPlaceholder;
  final List<ScalePhrasePrompt> phrasePrompts;
}

class BeginnerPathLesson {
  const BeginnerPathLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.recommendedMinutes,
    required this.exerciseIds,
    this.dayNumber = 0,
    this.goal = '',
    this.explanation = '',
    this.noteIds = const <String>[],
    this.listenStep = '',
    this.playStep = '',
    this.practiceExerciseId,
    this.rhythmVariation = '',
    this.completionKey = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final int recommendedMinutes;
  final List<String> exerciseIds;
  final int dayNumber;
  final String goal;
  final String explanation;
  final List<String> noteIds;
  final String listenStep;
  final String playStep;
  final String? practiceExerciseId;
  final String rhythmVariation;
  final String completionKey;
}

class BeginnerPracticeItem {
  const BeginnerPracticeItem({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.exerciseId,
    this.noteId,
    this.skippable = false,
    this.description = '',
  });

  final String id;
  final String title;
  final int durationMinutes;
  final String? exerciseId;
  final String? noteId;
  final bool skippable;
  final String description;
}

class BeginnerPracticePlan {
  const BeginnerPracticePlan({
    required this.title,
    required this.items,
  });

  final String title;
  final List<BeginnerPracticeItem> items;
}

class HandPositionGuide extends HandPositionLesson {
  const HandPositionGuide({
    required super.title,
    required super.cue,
    required super.detail,
    super.id,
    super.saxType,
    super.checkpoints,
  });
}

class NoteFingeringModel extends SaxFingering {
  const NoteFingeringModel({
    required this.noteLabel,
    required this.pressedKeyIds,
    required this.handPositionTip,
    required this.embouchureTip,
    required this.airflowTip,
    required super.octaveKey,
    required super.leftIndex,
    required super.leftMiddle,
    required super.leftRing,
    super.leftPinky = false,
    super.rightIndex = false,
    super.rightMiddle = false,
    super.rightRing = false,
    super.rightPinky = false,
    super.sideKeys = false,
    super.palmKeys = false,
    super.lowKeys = false,
  });

  final String noteLabel;
  final List<String> pressedKeyIds;
  final String handPositionTip;
  final String embouchureTip;
  final String airflowTip;
}

class FoundationPracticeExercise extends NoteExercise {
  const FoundationPracticeExercise({
    required super.id,
    required super.title,
    required super.summary,
    required super.instructions,
    required super.category,
    required super.playbackPattern,
    required super.playbackKey,
    required super.recommendedBpm,
    required super.durationMinutes,
    super.relatedNoteIds,
    super.relatedScaleIds,
    super.checkpoints,
  });
}

class FoundationNoteModel extends SaxNote {
  const FoundationNoteModel({
    required super.id,
    required String label,
    required super.arabicName,
    required super.noteName,
    required super.concertPitchForAlto,
    required super.concertPitchForTenor,
    required super.register,
    required super.description,
    required super.tonalGoal,
    required super.anchorScaleIds,
    required NoteFingeringModel super.fingering,
    required this.exerciseIds,
    super.commonMistakes = const <String>[],
    super.exercises = const <NoteExercise>[],
  })  : _fingering = fingering,
        super(
          writtenNote: label,
        );

  final List<String> exerciseIds;
  final NoteFingeringModel _fingering;

  String get label => writtenNote;

  @override
  NoteFingeringModel get fingering => _fingering;
}

class FoundationScaleLesson extends ScaleLesson {
  const FoundationScaleLesson({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.noteSequence,
    required super.tonalCenter,
    required super.purpose,
    required super.transferGoal,
    required super.relatedNoteIds,
    required super.exerciseIds,
    super.formula,
    super.slowPractice,
    super.metronomePractice,
    super.ascendingPractice,
    super.descendingPractice,
    super.rhythmVariation,
    super.simplePhraseApplication,
    super.backingTrackPlaceholder,
    super.phrasePrompts,
  });
}

class FirstFivePathStage {
  const FirstFivePathStage({
    required this.noteId,
    required this.title,
    required this.focus,
    required this.nextMove,
  });

  final String noteId;
  final String title;
  final String focus;
  final String nextMove;
}

class BeginnerPracticeStep extends BeginnerPathLesson {
  const BeginnerPracticeStep({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.recommendedMinutes,
    required super.exerciseIds,
  });
}

class SaxFoundationTrack {
  const SaxFoundationTrack({
    required this.handPositionGuides,
    required this.notes,
    required this.scales,
    required this.firstFivePath,
    required this.beginnerFlow,
    this.beginnerPathLessons = const <BeginnerPathLesson>[],
  });

  final List<HandPositionGuide> handPositionGuides;
  final List<FoundationNoteModel> notes;
  final List<FoundationScaleLesson> scales;
  final List<FirstFivePathStage> firstFivePath;
  final List<BeginnerPracticeStep> beginnerFlow;
  final List<BeginnerPathLesson> beginnerPathLessons;
}
