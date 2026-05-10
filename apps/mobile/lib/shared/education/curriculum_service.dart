import 'jazz_curriculum_models.dart';
import 'mvp_curriculum_models.dart';

class CurriculumService {
  const CurriculumService();

  MvpCurriculumProgram loadMvpProgram() {
    final days = [
      ..._week1Seeds,
      ..._week2Seeds,
      ..._week3Seeds,
      ..._week4Seeds,
    ].map(_buildDay).toList(growable: false);
    final incompleteLessons =
        days.where((day) => !day.isComplete).toList(growable: false);

    if (incompleteLessons.isNotEmpty) {
      throw StateError(
        'Every MVP lesson must answer the five product questions and include the full learning loop. Incomplete lessons: ${incompleteLessons.map((day) => day.lesson.id).join(', ')}',
      );
    }

    final weeks = List.generate(4, (index) {
      final weekNumber = index + 1;
      final title = switch (weekNumber) {
        1 => 'Week 1 · Sound and Time',
        2 => 'Week 2 · Blues Language',
        3 => 'Week 3 · Dominant and Guide Tones',
        _ => 'Week 4 · ii-V-I and First Solo',
      };
      final summary = switch (weekNumber) {
        1 =>
          'Tone basics, long tones, minor pentatonic, swing eighths, and rhythm on one note.',
        2 =>
          '12-bar blues, blues scale, call and response, phrase shape, space, and repetition.',
        3 =>
          'Dominant 7th sound, 3rds and 7ths, guide tones, jazz blues, and simple voice leading.',
        _ =>
          'ii-V-I, simple bebop approaches, first full chorus solo, record/evaluate, and a personal 2-bar phrase.',
      };

      return MvpCurriculumWeek(
        weekNumber: weekNumber,
        title: title,
        summary: summary,
        days: days
            .where((day) => day.weekNumber == weekNumber)
            .toList(growable: false),
      );
    });

    return MvpCurriculumProgram(
      id: 'mvp_30_day_curriculum',
      title: '30-Day Jazz Sax MVP Curriculum',
      summary:
          'A serious first-month path that keeps sound, swing, blues, ear training, theory, improvisation, and recording connected.',
      modules: _modules,
      weeks: weeks,
    );
  }

  MvpCurriculumDay? getDay(int dayNumber) =>
      loadMvpProgram().dayByNumber(dayNumber);

  List<MvpCurriculumDay> getIncompleteLessons() {
    return loadMvpProgram()
        .weeks
        .expand((week) => week.days)
        .where((day) => !day.isComplete)
        .toList(growable: false);
  }

  PracticePlan buildSamplePracticePlan({
    required DifficultyLevel level,
    required SaxType saxType,
    required int availableMinutes,
    SkillArea? weakness,
  }) {
    final program = loadMvpProgram();
    final preferredWeakness = weakness ?? SkillArea.rhythm;
    final candidateDays = program.weeks
        .expand((week) => week.days)
        .where((day) => day.lesson.skillAreas.contains(preferredWeakness))
        .take(3)
        .toList(growable: false);
    final selectedDays = candidateDays.isEmpty
        ? program.weeks
            .expand((week) => week.days)
            .take(3)
            .toList(growable: false)
        : candidateDays;
    final lessons =
        selectedDays.map((day) => day.lesson).toList(growable: false);
    final exercises = lessons
        .expand((lesson) => lesson.exercises)
        .take(6)
        .toList(growable: false);

    return PracticePlan(
      id: 'mvp_${level.name}_${preferredWeakness.name}_${saxType.name}',
      title: 'MVP Practice Plan',
      summary:
          'Generated from level ${level.name}, sax ${saxType.name}, and weakness ${preferredWeakness.name}.',
      difficulty: level,
      totalMinutes: availableMinutes,
      focusAreas: {
        preferredWeakness,
        ...lessons.expand((lesson) => lesson.skillAreas)
      }.take(4).toList(growable: false),
      lessons: lessons,
      exercises: exercises,
      backingTracks: exercises
          .map((exercise) => exercise.backingTrack)
          .whereType<BackingTrack>()
          .toSet()
          .toList(growable: false),
      progressMetrics: [
        ProgressMetric(
          id: 'practice_timing',
          label: 'Timing Focus',
          skillArea: preferredWeakness,
          currentValue: 65,
          targetValue: 85,
        ),
      ],
      sourceInspiration: _coreSources,
    );
  }
}

class _DaySeed {
  const _DaySeed({
    required this.dayNumber,
    required this.weekNumber,
    required this.title,
    required this.focus,
    required this.description,
    required this.skillAreas,
    required this.concepts,
    required this.moduleIds,
    required this.exerciseType,
    required this.level,
    required this.tempoRange,
    required this.whatDoIHear,
    required this.whatDoIPlay,
    required this.whyDoesItWork,
    required this.whereInRealJazz,
    required this.howDoIUseItInMySolo,
    required this.listeningAssignment,
    required this.improvisationAssignment,
    this.recordCheckpoint,
  });

  final int dayNumber;
  final int weekNumber;
  final String title;
  final String focus;
  final String description;
  final List<SkillArea> skillAreas;
  final List<String> concepts;
  final List<String> moduleIds;
  final ExerciseType exerciseType;
  final DifficultyLevel level;
  final TempoRange tempoRange;
  final String whatDoIHear;
  final String whatDoIPlay;
  final String whyDoesItWork;
  final String whereInRealJazz;
  final String howDoIUseItInMySolo;
  final String listeningAssignment;
  final String improvisationAssignment;
  final String? recordCheckpoint;
}

const List<String> _coreSources = [
  'Jamey Aebersold Jazz Handbook',
  'The Jazz Theory Book — Mark Levine',
  'The Jazz Language — Dan Haerle',
];

const List<SaxType> _allSaxTypes = [
  SaxType.altoEb,
  SaxType.tenorBb,
  SaxType.sopranoBb,
  SaxType.baritoneEb,
];

const List<MvpCurriculumModule> _modules = [
  MvpCurriculumModule(
    id: 'sax_setup_tone_basics',
    order: 1,
    title: 'Sax setup + tone basics',
    summary: 'Posture, breath, embouchure, long tones, and tone center.',
  ),
  MvpCurriculumModule(
    id: 'swing_rhythm_trainer',
    order: 2,
    title: 'Swing rhythm trainer',
    summary:
        'Quarter-note pulse, swing eighths, one-note rhythm, and placement.',
  ),
  MvpCurriculumModule(
    id: 'blues_course',
    order: 3,
    title: 'Blues course',
    summary:
        '12-bar form, blues scale, phrase logic, space, repetition, and response.',
  ),
  MvpCurriculumModule(
    id: 'ii_v_i_course',
    order: 4,
    title: 'ii-V-I course',
    summary:
        'Guide tones, dominant color, simple voice leading, and first lines.',
  ),
  MvpCurriculumModule(
    id: 'backing_tracks',
    order: 5,
    title: 'Backing tracks',
    summary:
        'Original loops for blues, swing pulse, jazz blues, and ii-V-I study.',
  ),
  MvpCurriculumModule(
    id: 'record_feedback',
    order: 6,
    title: 'Record & timing feedback',
    summary:
        'Record, hear, evaluate, retry slower, and save clear corrections.',
  ),
  MvpCurriculumModule(
    id: 'twelve_key_trainer',
    order: 7,
    title: '12-key pattern trainer',
    summary: 'Move simple cells through keys without losing tone or time.',
  ),
  MvpCurriculumModule(
    id: 'transposition_bb_eb',
    order: 8,
    title: 'Transposition for Bb/Eb sax',
    summary: 'Concert, tenor, and alto views of the same lesson material.',
  ),
  MvpCurriculumModule(
    id: 'daily_practice_generator',
    order: 9,
    title: 'Daily practice generator',
    summary:
        'Small, adaptive plans built from weakness, tempo, and current course.',
  ),
  MvpCurriculumModule(
    id: 'progress_dashboard',
    order: 10,
    title: 'Progress dashboard',
    summary:
        'Tone, timing, ear, theory, improvisation, repertoire, and streak.',
  ),
];

final List<_DaySeed> _week1Seeds = [
  const _DaySeed(
    dayNumber: 1,
    weekNumber: 1,
    title: 'Sax Setup and Tone Center',
    focus: 'Tone basics and instrument setup',
    description:
        'Build the first sound with posture, air, embouchure, and stable center.',
    skillAreas: [SkillArea.tone, SkillArea.technique],
    concepts: ['tone basics', 'air support', 'embouchure'],
    moduleIds: ['sax_setup_tone_basics', 'progress_dashboard'],
    exerciseType: ExerciseType.longTone,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 56, maxBpm: 66),
    whatDoIHear: 'A centered single note with no wobble and no pinched attack.',
    whatDoIPlay:
        'Long tones on one stable note with clean starts and relaxed air.',
    whyDoesItWork:
        'Because tone starts from air direction and voicing before finger movement.',
    whereInRealJazz:
        'Every strong jazz saxophonist carries this center even in soft ballads and medium swing.',
    howDoIUseItInMySolo:
        'I keep the same tone center when phrases get louder, softer, or more rhythmic.',
    listeningAssignment:
        'Listen for whether the note blooms or collapses after the attack.',
    improvisationAssignment:
        'Play one note with three dynamic shapes and make each one musical.',
  ),
  const _DaySeed(
    dayNumber: 2,
    weekNumber: 1,
    title: 'Long Tones with Dynamic Arc',
    focus: 'Long tones and dynamic control',
    description:
        'Expand one note from pp to ff and back without losing center.',
    skillAreas: [SkillArea.tone, SkillArea.feedback],
    concepts: ['long tones', 'dynamics', 'stability'],
    moduleIds: ['sax_setup_tone_basics', 'record_feedback'],
    exerciseType: ExerciseType.longTone,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 52, maxBpm: 62),
    whatDoIHear:
        'A note that stays in tune as the air gets wider and stronger.',
    whatDoIPlay: 'Sustained notes with crescendos and decrescendos.',
    whyDoesItWork:
        'Dynamic control teaches breath support and pitch stability at the same time.',
    whereInRealJazz:
        'Ballads, intros, and held notes at phrase endings need this control.',
    howDoIUseItInMySolo:
        'I shape phrase endings with controlled dynamics instead of just stopping the note.',
    listeningAssignment:
        'Notice whether the pitch rises at loud points or drops at soft points.',
    improvisationAssignment:
        'End two short phrases with a held note that swells then releases.',
    recordCheckpoint:
        'Record one long tone with dynamic arc and compare the start, middle, and release.',
  ),
  const _DaySeed(
    dayNumber: 3,
    weekNumber: 1,
    title: 'Basic Articulation Start',
    focus: 'Basic articulation',
    description:
        'Start notes with light tongue and connected air, not hard attacks.',
    skillAreas: [SkillArea.articulation, SkillArea.tone],
    concepts: ['basic articulation', 'tongue placement', 'connected air'],
    moduleIds: ['sax_setup_tone_basics', 'record_feedback'],
    exerciseType: ExerciseType.articulation,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 64, maxBpm: 78),
    whatDoIHear: 'A clear start with no click and no gap after the tongue.',
    whatDoIPlay:
        'Repeated articulated notes on one pitch, legato first then light detached.',
    whyDoesItWork:
        'The tongue releases the air; it should not replace the air stream.',
    whereInRealJazz: 'Even simple swing heads need clarity without harshness.',
    howDoIUseItInMySolo:
        'I choose lighter or firmer starts to shape phrase character.',
    listeningAssignment:
        'Listen for whether the note speaks immediately after the tongue or feels choked.',
    improvisationAssignment:
        'Play one tiny call-and-response using only articulation contrast.',
  ),
  const _DaySeed(
    dayNumber: 4,
    weekNumber: 1,
    title: 'Minor Pentatonic Shape 1',
    focus: 'Minor pentatonic foundation',
    description:
        'Learn one compact pentatonic sound and hear it as phrase material, not scale running.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation, SkillArea.theory],
    concepts: ['minor pentatonic', 'small cell', 'phrase shape'],
    moduleIds: ['blues_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.scale,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 68, maxBpm: 84),
    whatDoIHear:
        'A tight five-note sound with blues gravity and no extra clutter.',
    whatDoIPlay:
        'A small pentatonic cell ascending and descending with space between repeats.',
    whyDoesItWork:
        'A limited note set helps rhythm and sound become the focus.',
    whereInRealJazz:
        'Blues, funk, minor vamp contexts, and early improvisation language.',
    howDoIUseItInMySolo:
        'I take only 3–4 notes from the set and make a phrase instead of running all 5.',
    listeningAssignment:
        'Hear which note sounds like home and which one wants to push forward.',
    improvisationAssignment:
        'Improvise 2 bars using only three pentatonic notes.',
  ),
  const _DaySeed(
    dayNumber: 5,
    weekNumber: 1,
    title: 'Swing Eighth Feel',
    focus: 'Swing eighths',
    description:
        'Learn that swing is placement and feel, not a fixed triplet math formula.',
    skillAreas: [SkillArea.swing, SkillArea.rhythm],
    concepts: ['swing eighths', 'offbeat placement', 'pulse'],
    moduleIds: ['swing_rhythm_trainer', 'backing_tracks'],
    exerciseType: ExerciseType.swingSubdivision,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear:
        'Offbeats that sit inside the pulse instead of sounding stiff or straight.',
    whatDoIPlay:
        'Two-bar swing rhythms on one note, first clapped, then played.',
    whyDoesItWork:
        'Good swing comes from relation to pulse, not from memorizing a ratio.',
    whereInRealJazz: 'Medium swing phrasing, heads, riffs, and simple fills.',
    howDoIUseItInMySolo:
        'I keep the same rhythm and change only pitches once the placement feels right.',
    listeningAssignment:
        'Compare your offbeats against a metronome on 2 and 4.',
    improvisationAssignment:
        'Play one rhythmic cell three times with the same swing feel.',
  ),
  const _DaySeed(
    dayNumber: 6,
    weekNumber: 1,
    title: 'Rhythm on One Note',
    focus: 'Rhythm on one note',
    description:
        'Take pitch out of the problem and train time feel, articulation, and phrase shape.',
    skillAreas: [SkillArea.rhythm, SkillArea.articulation, SkillArea.swing],
    concepts: ['one-note rhythm', 'pulse consistency', 'phrase ending'],
    moduleIds: ['swing_rhythm_trainer', 'record_feedback'],
    exerciseType: ExerciseType.rhythmPlayback,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 96),
    whatDoIHear: 'Rhythm as the musical message even when pitch never changes.',
    whatDoIPlay:
        'Short rhythmic phrases on one note with clear starts and endings.',
    whyDoesItWork:
        'It isolates the real jazz engine: time, shape, and articulation.',
    whereInRealJazz:
        'Riffs, shout figures, repeated motifs, and early solo development.',
    howDoIUseItInMySolo:
        'I can keep one rhythmic idea and move it later to new notes.',
    listeningAssignment:
        'Listen for whether all attacks sit in the same pocket.',
    improvisationAssignment:
        'Improvise 4 bars on one note and make it feel intentional.',
  ),
  const _DaySeed(
    dayNumber: 7,
    weekNumber: 1,
    title: 'Week 1 Integration',
    focus: 'Tone + articulation + rhythm review',
    description:
        'Combine stable tone, light articulation, one-note rhythm, and minor pentatonic color.',
    skillAreas: [SkillArea.tone, SkillArea.rhythm, SkillArea.swing],
    concepts: ['integration', 'review', 'first mini solo'],
    moduleIds: [
      'sax_setup_tone_basics',
      'swing_rhythm_trainer',
      'progress_dashboard',
    ],
    exerciseType: ExerciseType.callAndResponse,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 92),
    whatDoIHear:
        'A simple phrase that still sounds musical because tone and time are organized.',
    whatDoIPlay: 'One-note rhythm first, then a tiny pentatonic answer.',
    whyDoesItWork:
        'Week 1 works only if sound and time stay connected from the first phrase.',
    whereInRealJazz:
        'Simple intros, student jam sessions, and early riff improvisation.',
    howDoIUseItInMySolo:
        'I build short phrases from rhythm first, then add just enough pitch motion.',
    listeningAssignment:
        'Listen back and ask whether the answer phrase really contrasts with the call.',
    improvisationAssignment: 'Create a 2-bar call and a 2-bar answer.',
    recordCheckpoint: 'Record the week-1 review and save it as your baseline.',
  ),
];

final List<_DaySeed> _week2Seeds = [
  const _DaySeed(
    dayNumber: 8,
    weekNumber: 2,
    title: '12-Bar Blues Map',
    focus: '12-bar blues form',
    description: 'Hear the structure before trying to fill it with notes.',
    skillAreas: [SkillArea.blues, SkillArea.theory, SkillArea.repertoire],
    concepts: ['12-bar blues', 'form', 'I7 IV7 V7'],
    moduleIds: ['blues_course', 'backing_tracks', 'transposition_bb_eb'],
    exerciseType: ExerciseType.bluesPhrase,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 94),
    whatDoIHear:
        'The home sound, the move to IV, and the energy shift in bars 9–10.',
    whatDoIPlay: 'Roots and simple guide points through the whole form.',
    whyDoesItWork: 'If the form is unclear, every lick loses meaning.',
    whereInRealJazz: 'Blues heads, jam sessions, riffs, and solo structures.',
    howDoIUseItInMySolo:
        'I mark key bars with rhythm and space instead of filling every measure.',
    listeningAssignment:
        'Clap bar 1, bar 5, and bar 9 while listening to the loop.',
    improvisationAssignment:
        'Play one note only, but show the form with your rhythm.',
  ),
  const _DaySeed(
    dayNumber: 9,
    weekNumber: 2,
    title: 'Blues Scale Sound',
    focus: 'Blues scale',
    description:
        'Use the blues scale as sound and color, not as a nonstop run.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation],
    concepts: ['blues scale', 'blue note', 'color tone'],
    moduleIds: ['blues_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.scale,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 96),
    whatDoIHear:
        'A strong blues color with the blue note acting like tension, not home base.',
    whatDoIPlay:
        'Short blues-scale cells in one key, then a second nearby key.',
    whyDoesItWork:
        'The blue note is expressive because of where and how you place it.',
    whereInRealJazz: 'Blues solos, funk lines, and simple crossover phrasing.',
    howDoIUseItInMySolo:
        'I touch the blue note briefly, then resolve or repeat it rhythmically.',
    listeningAssignment: 'Hear whether the blue note sounds placed or random.',
    improvisationAssignment:
        'Play two 2-bar ideas using the blue note once in each idea.',
  ),
  const _DaySeed(
    dayNumber: 10,
    weekNumber: 2,
    title: 'Call and Response in Blues',
    focus: 'Call and response',
    description:
        'Make short phrases talk to each other instead of sounding like separate licks.',
    skillAreas: [
      SkillArea.blues,
      SkillArea.improvisation,
      SkillArea.earTraining
    ],
    concepts: ['call and response', 'phrase length', 'contrast'],
    moduleIds: ['blues_course', 'record_feedback'],
    exerciseType: ExerciseType.callAndResponse,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 82, maxBpm: 98),
    whatDoIHear:
        'A first phrase asking something and a second phrase answering with shape or rhythm change.',
    whatDoIPlay: 'Two-bar call, two-bar response, then silence.',
    whyDoesItWork:
        'Conversation creates direction better than disconnected ideas.',
    whereInRealJazz:
        'Blues choruses, riff bands, and vocal-influenced sax phrasing.',
    howDoIUseItInMySolo:
        'I answer my own phrase with contrast in rhythm, space, or register.',
    listeningAssignment: 'Sing the answer before you play it.',
    improvisationAssignment:
        'Create three different responses to the same call.',
  ),
  const _DaySeed(
    dayNumber: 11,
    weekNumber: 2,
    title: 'Simple Blues Phrase 1',
    focus: 'Simple blues phrases',
    description:
        'Build one compact phrase with clear ending and repeat it in time.',
    skillAreas: [
      SkillArea.blues,
      SkillArea.articulation,
      SkillArea.improvisation
    ],
    concepts: ['simple phrase', 'phrase ending', 'repeatable idea'],
    moduleIds: ['blues_course', 'progress_dashboard'],
    exerciseType: ExerciseType.bluesPhrase,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 100),
    whatDoIHear:
        'A phrase short enough to remember but strong enough to repeat.',
    whatDoIPlay:
        'A 2-bar blues phrase with one clear contour and one clear ending.',
    whyDoesItWork:
        'Simple material becomes convincing when rhythm and ending are clear.',
    whereInRealJazz: 'Blues heads, beginner solos, and shout-style riffs.',
    howDoIUseItInMySolo:
        'I repeat the phrase with one small change instead of abandoning it.',
    listeningAssignment:
        'Check whether the phrase stops cleanly or fades weakly.',
    improvisationAssignment:
        'Repeat your phrase three times with one tiny change each time.',
  ),
  const _DaySeed(
    dayNumber: 12,
    weekNumber: 2,
    title: 'Space in Blues Soloing',
    focus: 'Space and pacing',
    description: 'Leave silence on purpose so the phrase can mean something.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation, SkillArea.rhythm],
    concepts: ['space', 'pacing', 'breath planning'],
    moduleIds: ['blues_course', 'record_feedback'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear: 'Silence as part of the phrase, not an empty mistake.',
    whatDoIPlay: 'One short phrase, one breath, then rest.',
    whyDoesItWork:
        'Space lets the listener hear shape, time, and response in the rhythm section.',
    whereInRealJazz:
        'Strong blues solos, ballad phrasing, and vocal-style lines.',
    howDoIUseItInMySolo:
        'I stop before I run out of ideas so the next phrase starts stronger.',
    listeningAssignment:
        'Hear whether the rest creates tension or just sounds accidental.',
    improvisationAssignment: 'Play only three short phrases in one chorus.',
  ),
  const _DaySeed(
    dayNumber: 13,
    weekNumber: 2,
    title: 'Repetition with Variation',
    focus: 'Repetition and development',
    description:
        'Repeat a phrase because it means something, then bend it slightly.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation],
    concepts: ['repetition', 'variation', 'motivic development'],
    moduleIds: ['blues_course', 'daily_practice_generator'],
    exerciseType: ExerciseType.bluesPhrase,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 98),
    whatDoIHear:
        'A recognizable idea coming back with one change in rhythm, ending, or register.',
    whatDoIPlay: 'The same blues idea three times with controlled variation.',
    whyDoesItWork: 'Repetition creates identity; variation creates motion.',
    whereInRealJazz:
        'Blues solos, riffs, and even bebop phrases at slower tempos.',
    howDoIUseItInMySolo:
        'I keep a motif alive across bars instead of inventing a new idea every second.',
    listeningAssignment:
        'See whether the listener can still recognize the idea after your variation.',
    improvisationAssignment: 'Take a 2-bar idea and state it three ways.',
  ),
  const _DaySeed(
    dayNumber: 14,
    weekNumber: 2,
    title: 'Week 2 Blues Chorus',
    focus: 'Blues integration',
    description:
        'Play one short blues chorus using form, space, response, and phrase memory.',
    skillAreas: [
      SkillArea.blues,
      SkillArea.improvisation,
      SkillArea.repertoire
    ],
    concepts: ['first blues chorus', 'form awareness', 'space and repetition'],
    moduleIds: [
      'blues_course',
      'backing_tracks',
      'record_feedback',
      'progress_dashboard',
    ],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 102),
    whatDoIHear:
        'A full chorus that still sounds organized because bars and phrase roles are clear.',
    whatDoIPlay: 'One complete 12-bar chorus over blues backing.',
    whyDoesItWork:
        'A full chorus teaches memory, pacing, and form at the same time.',
    whereInRealJazz:
        'Jam blues, simple solo spots, and ensemble trading sections.',
    howDoIUseItInMySolo:
        'I build a chorus from 2-bar ideas instead of random note strings.',
    listeningAssignment:
        'After recording, mark where your strongest and weakest bars happened.',
    improvisationAssignment:
        'Play one full chorus and keep one repeated idea alive for at least 4 bars.',
    recordCheckpoint:
        'Record your first blues chorus and save it for Week 4 comparison.',
  ),
];

final List<_DaySeed> _week3Seeds = [
  const _DaySeed(
    dayNumber: 15,
    weekNumber: 3,
    title: 'Dominant 7th Chord Sound',
    focus: 'Dominant 7th chords',
    description:
        'Hear dominant as tension wanting to move, not just as a scale label.',
    skillAreas: [
      SkillArea.theory,
      SkillArea.earTraining,
      SkillArea.improvisation
    ],
    concepts: ['dominant 7', '3rd and 7th', 'tension'],
    moduleIds: ['ii_v_i_course', 'transposition_bb_eb'],
    exerciseType: ExerciseType.chordToneSoloing,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 74, maxBpm: 90),
    whatDoIHear:
        'A chord that wants to resolve because of its 3rd and 7th pull.',
    whatDoIPlay: 'Root, 3rd, 5th, and 7th in slow rhythmic patterns.',
    whyDoesItWork:
        'Chord tones define the harmony before any scale color appears.',
    whereInRealJazz:
        'Blues, ii-V-I, turnarounds, and secondary dominants everywhere.',
    howDoIUseItInMySolo:
        'I target the 3rd or 7th first before adding color tones.',
    listeningAssignment:
        'Sing the 3rd and 7th alone and hear the pull without the root.',
    improvisationAssignment:
        'Improvise 2 bars using only dominant chord tones.',
  ),
  const _DaySeed(
    dayNumber: 16,
    weekNumber: 3,
    title: '3rds and 7ths First',
    focus: '3rds and 7ths',
    description: 'Make the 3rd and 7th your first map before any extra notes.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['3rds', '7ths', 'target notes'],
    moduleIds: ['ii_v_i_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear:
        'Only the notes that tell major, minor, and dominant quality immediately.',
    whatDoIPlay: '3rds-only and 7ths-only patterns over short progressions.',
    whyDoesItWork:
        'These tones outline function and resolution with minimal material.',
    whereInRealJazz: 'Comping logic, solos, and internal hearing of harmony.',
    howDoIUseItInMySolo: 'I start from guide points and then decorate them.',
    listeningAssignment:
        'Listen whether the chord quality is still clear when you remove roots and fifths.',
    improvisationAssignment: 'Play a 2-bar line using only 3rds and 7ths.',
  ),
  const _DaySeed(
    dayNumber: 17,
    weekNumber: 3,
    title: 'Guide Tones through Blues Motion',
    focus: 'Guide tones',
    description:
        'Move smoothly from one guide tone target to the next through blues harmony.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation, SkillArea.blues],
    concepts: ['guide tones', 'voice leading', 'blues harmony'],
    moduleIds: ['ii_v_i_course', 'blues_course'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 94),
    whatDoIHear:
        'Notes resolving by step or common tone instead of jumping randomly.',
    whatDoIPlay: 'Simple guide-tone lines through key bars of a blues.',
    whyDoesItWork:
        'Voice leading makes the line sound connected to the harmony.',
    whereInRealJazz:
        'Jazz blues, standard progressions, and inside bebop language.',
    howDoIUseItInMySolo:
        'I let the next chord pull the line instead of forcing patterns.',
    listeningAssignment:
        'Hear whether each note belongs to the next chord, not just the current one.',
    improvisationAssignment:
        'Connect four bars using only guide tones plus one passing tone.',
  ),
  const _DaySeed(
    dayNumber: 18,
    weekNumber: 3,
    title: 'Jazz Blues Changes',
    focus: 'Jazz blues',
    description:
        'Upgrade the basic blues form with movement, turnarounds, and stronger harmony.',
    skillAreas: [SkillArea.blues, SkillArea.theory, SkillArea.repertoire],
    concepts: ['jazz blues', 'turnaround', 'dominant movement'],
    moduleIds: ['blues_course', 'backing_tracks', 'ii_v_i_course'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 86, maxBpm: 104),
    whatDoIHear:
        'More movement than basic blues, especially in the turnaround areas.',
    whatDoIPlay: 'Short phrases that respect the added chord movement.',
    whyDoesItWork:
        'Jazz blues adds forward motion, which demands clearer targets.',
    whereInRealJazz:
        'Jam sessions, classic blues heads, and early bebop repertoire.',
    howDoIUseItInMySolo:
        'I simplify by hearing the strong targets instead of chasing every chord symbol.',
    listeningAssignment:
        'Listen for where the harmony speeds up and where it relaxes.',
    improvisationAssignment:
        'Play one chorus and mark bars 4, 8, and 11 with clear targets.',
  ),
  const _DaySeed(
    dayNumber: 19,
    weekNumber: 3,
    title: 'Simple Voice Leading',
    focus: 'Simple voice leading',
    description: 'Connect nearby notes smoothly through changing chords.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['voice leading', 'nearest note', 'resolution'],
    moduleIds: ['ii_v_i_course', 'daily_practice_generator'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 74, maxBpm: 90),
    whatDoIHear:
        'Lines moving with purpose because each target comes from the last one naturally.',
    whatDoIPlay: 'Nearest-note movement through short chord chains.',
    whyDoesItWork: 'Good lines feel inevitable when motion is economical.',
    whereInRealJazz:
        'Guide-tone lines, bebop phrases, and arranged sax soli writing.',
    howDoIUseItInMySolo:
        'I move to the closest important note instead of restarting from the root.',
    listeningAssignment:
        'Ask whether the line still sings if you play it slowly with no rhythm section.',
    improvisationAssignment:
        'Build a 4-note line that resolves twice without leaps.',
  ),
  const _DaySeed(
    dayNumber: 20,
    weekNumber: 3,
    title: 'Guide Tones in 3 Keys',
    focus: 'Guide tones in multiple keys',
    description: 'Move one small guide-tone cell through three practical keys.',
    skillAreas: [
      SkillArea.theory,
      SkillArea.improvisation,
      SkillArea.technique
    ],
    concepts: ['guide tones in keys', 'transposition', 'cell practice'],
    moduleIds: ['twelve_key_trainer', 'transposition_bb_eb'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear: 'The same harmonic function surviving a new key center.',
    whatDoIPlay: 'A two-note guide-tone cell in C, F, and Bb.',
    whyDoesItWork: 'Real fluency begins when the idea survives transposition.',
    whereInRealJazz:
        'Standards in different keys, rehearsals, and educational pattern work.',
    howDoIUseItInMySolo:
        'I carry the concept into a new key instead of starting over from scratch.',
    listeningAssignment:
        'Check whether the function still feels the same after transposing.',
    improvisationAssignment:
        'Play the same 2-bar guide-tone idea in three keys.',
  ),
  const _DaySeed(
    dayNumber: 21,
    weekNumber: 3,
    title: 'Week 3 Dominant Review',
    focus: 'Dominant and guide-tone review',
    description:
        'Combine dominant sound, 3rds/7ths, jazz blues awareness, and voice leading.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation, SkillArea.blues],
    concepts: ['dominant summary', 'guide tone control', 'inside line'],
    moduleIds: [
      'ii_v_i_course',
      'blues_course',
      'progress_dashboard',
      'record_feedback',
    ],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 82, maxBpm: 98),
    whatDoIHear:
        'A line that sounds connected to harmony even when rhythm is simple.',
    whatDoIPlay: 'One short chorus using guide tones as anchor points.',
    whyDoesItWork: 'Harmony sounds clear when target notes are deliberate.',
    whereInRealJazz: 'Early inside soloing on blues and standards.',
    howDoIUseItInMySolo:
        'I can now aim for targets and let rhythm shape the rest.',
    listeningAssignment:
        'Listen back and identify which bars had the clearest targets.',
    improvisationAssignment:
        'Build one chorus with one guide-tone idea returning twice.',
    recordCheckpoint: 'Record a guide-tone chorus over jazz blues and save it.',
  ),
];

final List<_DaySeed> _week4Seeds = [
  const _DaySeed(
    dayNumber: 22,
    weekNumber: 4,
    title: 'ii-V-I Chord Sound',
    focus: 'ii-V-I sound',
    description:
        'Hear ii-V-I as a complete motion, not three separate theory boxes.',
    skillAreas: [
      SkillArea.theory,
      SkillArea.earTraining,
      SkillArea.improvisation
    ],
    concepts: ['ii-V-I', 'function', 'resolution'],
    moduleIds: ['ii_v_i_course', 'backing_tracks'],
    exerciseType: ExerciseType.iiVI,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear:
        'Preparation, tension, and resolution as one musical sentence.',
    whatDoIPlay:
        'Roots, then guide tones, then chord tones through the cadence.',
    whyDoesItWork: 'Function explains why the line wants to go somewhere.',
    whereInRealJazz:
        'Standards, bebop tunes, turnarounds, and cadential phrases.',
    howDoIUseItInMySolo:
        'I outline the resolution first, then add approach tones later.',
    listeningAssignment:
        'Sing the resolution note before you play the V chord.',
    improvisationAssignment: 'Improvise 4 bars around one ii-V-I only.',
  ),
  const _DaySeed(
    dayNumber: 23,
    weekNumber: 4,
    title: 'ii-V-I Guide Tone Lesson',
    focus: 'ii-V-I guide tones',
    description:
        'Hear and play 3rds and 7ths resolving cleanly through the cadence.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['guide tones', 'ii-V-I', '3rds and 7ths'],
    moduleIds: ['ii_v_i_course', 'transposition_bb_eb'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 94),
    whatDoIHear: 'F → F → E and C → B → B as structural resolution.',
    whatDoIPlay: 'Guide-tone pairs over Dm7–G7–Cmaj7 and transposed versions.',
    whyDoesItWork:
        'Guide tones carry the function even before full chord tones arrive.',
    whereInRealJazz:
        'Inside jazz language, comping logic, and early bebop voice leading.',
    howDoIUseItInMySolo:
        'I start from guide tones, then add rhythm, passing tones, and enclosure later.',
    listeningAssignment: 'Sing both guide-tone lines before touching the horn.',
    improvisationAssignment:
        'Use only guide tones plus one passing tone in 4 bars.',
  ),
  const _DaySeed(
    dayNumber: 24,
    weekNumber: 4,
    title: 'Simple Bebop Approaches',
    focus: 'Simple bebop approaches',
    description:
        'Add one chromatic approach to a strong target instead of running a whole altered scale.',
    skillAreas: [
      SkillArea.improvisation,
      SkillArea.theory,
      SkillArea.articulation
    ],
    concepts: ['approach note', 'chromaticism', 'target note'],
    moduleIds: ['ii_v_i_course', 'record_feedback'],
    exerciseType: ExerciseType.iiVI,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 82, maxBpm: 96),
    whatDoIHear:
        'Tension that resolves immediately into a target, not random outside notes.',
    whatDoIPlay: 'One-note chromatic approaches into 3rds or 7ths.',
    whyDoesItWork:
        'Chromaticism sounds logical when the target is clear and the timing is strong.',
    whereInRealJazz: 'Bebop lines, turnarounds, and compact ii-V-I vocabulary.',
    howDoIUseItInMySolo:
        'I decorate one important target rather than filling every beat chromatically.',
    listeningAssignment:
        'Hear whether the approach note sounds intentional or just late.',
    improvisationAssignment: 'Use one approach note in each 2-bar phrase.',
  ),
  const _DaySeed(
    dayNumber: 25,
    weekNumber: 4,
    title: 'ii-V-I in 3 Keys',
    focus: 'Move ii-V-I through keys',
    description:
        'Carry the same guide-tone logic into three common practice keys.',
    skillAreas: [
      SkillArea.technique,
      SkillArea.theory,
      SkillArea.improvisation
    ],
    concepts: ['ii-V-I in keys', 'transposition', 'key transfer'],
    moduleIds: ['twelve_key_trainer', 'transposition_bb_eb'],
    exerciseType: ExerciseType.iiVI,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 90),
    whatDoIHear: 'The same cadence function independent of pitch height.',
    whatDoIPlay: 'One small ii-V-I cell in C, F, and Bb.',
    whyDoesItWork:
        'Key transfer is how a concept becomes usable beyond one exercise room key.',
    whereInRealJazz: 'Real tunes, rehearsals, and transposed study.',
    howDoIUseItInMySolo:
        'I can take a favorite 2-bar idea into nearby keys quickly.',
    listeningAssignment:
        'Check whether you still hear the resolution when the key changes.',
    improvisationAssignment:
        'Play the same cadence idea in 3 keys with steady time.',
  ),
  const _DaySeed(
    dayNumber: 26,
    weekNumber: 4,
    title: 'First Full Chorus Solo',
    focus: 'First full chorus solo',
    description:
        'Assemble tone, time, form, guide tones, blues color, and small bebop approaches into one chorus.',
    skillAreas: [
      SkillArea.improvisation,
      SkillArea.repertoire,
      SkillArea.swing
    ],
    concepts: ['full chorus', 'phrase pacing', 'form'],
    moduleIds: ['backing_tracks', 'ii_v_i_course', 'record_feedback'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 100),
    whatDoIHear:
        'A full chorus with phrases that relate to harmony and still breathe.',
    whatDoIPlay: 'One chorus over jazz blues or a short ii-V-I based loop.',
    whyDoesItWork:
        'The chorus becomes coherent when each phrase knows its role.',
    whereInRealJazz:
        'Any small solo spot where one chorus has to say something complete.',
    howDoIUseItInMySolo:
        'I start thinking in connected phrase blocks instead of separate licks.',
    listeningAssignment:
        'Mark where your phrase peaks and where you left useful space.',
    improvisationAssignment:
        'Build a full chorus using at least one repeated idea.',
  ),
  const _DaySeed(
    dayNumber: 27,
    weekNumber: 4,
    title: 'Record and Evaluate',
    focus: 'Record and evaluate',
    description:
        'Use recording as a teacher for timing, sound, phrase endings, and form.',
    skillAreas: [SkillArea.feedback, SkillArea.rhythm, SkillArea.tone],
    concepts: ['self-evaluation', 'timing feedback', 'retry slower'],
    moduleIds: ['record_feedback', 'progress_dashboard'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 96),
    whatDoIHear:
        'Whether your real time feel matches what you imagined while playing.',
    whatDoIPlay:
        'The same chorus twice: first natural, second after one clear correction.',
    whyDoesItWork:
        'Recording exposes timing, tone, and phrasing truth better than memory.',
    whereInRealJazz:
        'Practice rooms, lesson prep, remote submissions, and self-directed growth.',
    howDoIUseItInMySolo:
        'I turn one weak area into the next day’s first drill instead of guessing.',
    listeningAssignment:
        'Listen once for timing only and once for phrase shape only.',
    improvisationAssignment:
        'Retry the same chorus 10–15 BPM slower after one correction.',
    recordCheckpoint:
        'Save take 1 and take 2 and write one concrete improvement sentence.',
  ),
  const _DaySeed(
    dayNumber: 28,
    weekNumber: 4,
    title: 'Personal 2-Bar Phrase',
    focus: 'Create a personal 2-bar phrase',
    description: 'Design a phrase you can actually remember, repeat, and own.',
    skillAreas: [SkillArea.improvisation, SkillArea.saxLanguage],
    concepts: ['personal phrase', 'identity', 'motivic cell'],
    moduleIds: ['ii_v_i_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.etude,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 98),
    whatDoIHear:
        'A phrase that sounds like one complete thought rather than borrowed fragments.',
    whatDoIPlay: 'A 2-bar idea with clear beginning, peak, and ending.',
    whyDoesItWork:
        'Personal vocabulary grows from small phrases you understand deeply.',
    whereInRealJazz:
        'Signature licks, repeated motifs, and personal style beginnings.',
    howDoIUseItInMySolo:
        'I return to this phrase and reshape it in different places.',
    listeningAssignment:
        'Sing your phrase away from the horn; if you can’t, it is not yours yet.',
    improvisationAssignment:
        'State your 2-bar phrase, then answer it with a variation.',
  ),
  const _DaySeed(
    dayNumber: 29,
    weekNumber: 4,
    title: '12-Key Phrase Transfer',
    focus: '12-key pattern trainer',
    description:
        'Move your personal cell and one ii-V-I cell through practical keys without losing feel.',
    skillAreas: [
      SkillArea.technique,
      SkillArea.improvisation,
      SkillArea.theory
    ],
    concepts: ['12-key trainer', 'phrase transfer', 'consistency'],
    moduleIds: [
      'twelve_key_trainer',
      'transposition_bb_eb',
      'daily_practice_generator'
    ],
    exerciseType: ExerciseType.iiVI,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 72, maxBpm: 88),
    whatDoIHear:
        'The same idea keeping its function and shape while the key moves.',
    whatDoIPlay:
        'A personal 2-bar phrase and a guide-tone cell in several keys.',
    whyDoesItWork:
        'Transfer proves whether the idea is learned or only memorized.',
    whereInRealJazz: 'Warm-ups, technical drills, and real tune preparation.',
    howDoIUseItInMySolo:
        'I can pull the same phrase concept into new tunes faster.',
    listeningAssignment:
        'Listen for whether the swing feel survives the key change.',
    improvisationAssignment:
        'Take your phrase into 4 keys with identical rhythm.',
  ),
  const _DaySeed(
    dayNumber: 30,
    weekNumber: 4,
    title: 'MVP Capstone Review',
    focus: '30-day integration',
    description:
        'Close the first month by combining tone, swing, blues, guide tones, ii-V-I, recording, and personal phrase logic.',
    skillAreas: [
      SkillArea.tone,
      SkillArea.rhythm,
      SkillArea.blues,
      SkillArea.improvisation,
      SkillArea.feedback,
    ],
    concepts: ['capstone', 'integration', 'first month summary'],
    moduleIds: [
      'sax_setup_tone_basics',
      'swing_rhythm_trainer',
      'blues_course',
      'ii_v_i_course',
      'record_feedback',
      'progress_dashboard',
    ],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 102),
    whatDoIHear:
        'A player who now thinks in sound, pulse, phrase, and harmonic direction together.',
    whatDoIPlay:
        'One chorus plus one personal phrase reprise and one slow corrective take.',
    whyDoesItWork:
        'The month matters only if the parts connect into real playing.',
    whereInRealJazz:
        'Any serious practice routine moving toward real tunes and real solos.',
    howDoIUseItInMySolo:
        'I take the strongest ideas from this month and keep developing them in the next course block.',
    listeningAssignment:
        'Compare day 7, day 14, day 21, and day 30 recordings.',
    improvisationAssignment:
        'Play one chorus that includes one repeated motif and one clear cadence target.',
    recordCheckpoint:
        'Save your capstone take and write the next two weaknesses to address.',
  ),
];

MvpCurriculumDay _buildDay(_DaySeed seed) {
  final lesson = Lesson(
    id: 'mvp_day_${seed.dayNumber.toString().padLeft(2, '0')}',
    title: seed.title,
    description: seed.description,
    level: seed.level,
    skillAreas: seed.skillAreas,
    concepts: seed.concepts,
    sourceInspiration: _coreSources,
    saxTypes: _allSaxTypes,
    concertKey: _concertKeyForDay(seed),
    writtenKeyForBbSax: _writtenKeyForBb(seed),
    writtenKeyForEbSax: _writtenKeyForEb(seed),
    tempoRange: seed.tempoRange,
    steps: _buildLessonSteps(seed),
    exercises: [_buildExercise(seed)],
    backingTrackReferences: [
      if (_backingTrackForSeed(seed) != null) _backingTrackForSeed(seed)!.title,
    ],
    evaluationCriteria: _evaluationCriteria(seed.skillAreas),
    nextRecommendedLessons: [
      if (seed.dayNumber < 30)
        'mvp_day_${(seed.dayNumber + 1).toString().padLeft(2, '0')}',
    ],
    originalityNote:
        'Original MVP lesson for a serious jazz saxophone first month. Every lesson explicitly answers the five core product questions.',
  );

  return MvpCurriculumDay(
    dayNumber: seed.dayNumber,
    weekNumber: seed.weekNumber,
    title: seed.title,
    focus: seed.focus,
    moduleIds: seed.moduleIds,
    lesson: lesson,
    fiveQuestions: LessonFiveQuestions(
      whatDoIHear: seed.whatDoIHear,
      whatDoIPlay: seed.whatDoIPlay,
      whyDoesItWork: seed.whyDoesItWork,
      whereInRealJazz: seed.whereInRealJazz,
      howDoIUseItInMySolo: seed.howDoIUseItInMySolo,
    ),
    listeningAssignment: seed.listeningAssignment,
    improvisationAssignment: seed.improvisationAssignment,
    recordCheckpoint: seed.recordCheckpoint,
  );
}

List<LessonStep> _buildLessonSteps(_DaySeed seed) {
  return [
    LessonStep(
      type: LessonStepType.listen,
      title: 'What do I hear?',
      description: seed.whatDoIHear,
      minutes: 4,
      listenPrompt: seed.listeningAssignment,
    ),
    LessonStep(
      type: LessonStepType.understand,
      title: 'Why does it work?',
      description: seed.whyDoesItWork,
      minutes: 4,
    ),
    LessonStep(
      type: LessonStepType.sing,
      title: 'Sing it first',
      description: 'غنِّ الفكرة أو الـ pulse قبل العزف حتى ترتبط الأذن بالجسم.',
      minutes: 3,
      singPrompt: seed.whatDoIHear,
    ),
    LessonStep(
      type: LessonStepType.play,
      title: 'What do I play?',
      description: seed.whatDoIPlay,
      minutes: 8,
      playPrompt: seed.whatDoIPlay,
    ),
    LessonStep(
      type: LessonStepType.analyze,
      title: 'Where in real jazz?',
      description: seed.whereInRealJazz,
      minutes: 3,
    ),
    LessonStep(
      type: LessonStepType.improvise,
      title: 'How do I use it in my own solo?',
      description: seed.howDoIUseItInMySolo,
      minutes: 6,
      playPrompt: seed.improvisationAssignment,
    ),
    LessonStep(
      type: LessonStepType.record,
      title: 'Record',
      description: seed.recordCheckpoint ??
          'سجّل take قصيرة لهذه الفكرة وراجعها مباشرة.',
      minutes: 4,
    ),
    const LessonStep(
      type: LessonStepType.evaluate,
      title: 'Evaluate',
      description:
          'قيّم tone, timing, articulation, and phrase logic before adding new notes.',
      minutes: 3,
      evaluatePrompt:
          'هل حققت sound, time, and harmonic clarity أم ما زال أحدها أضعف؟',
    ),
    const LessonStep(
      type: LessonStepType.repeat,
      title: 'Repeat',
      description:
          'أعد المحاولة أبطأ أو بمادة أصغر إذا احتجت، ثم ارفع الصعوبة تدريجياً.',
      minutes: 2,
    ),
  ];
}

Exercise _buildExercise(_DaySeed seed) {
  final backingTrack = _backingTrackForSeed(seed);

  return Exercise(
    id: 'exercise_day_${seed.dayNumber.toString().padLeft(2, '0')}',
    title: '${seed.title} Exercise',
    type: seed.exerciseType,
    skillAreas: seed.skillAreas,
    difficulty: seed.level,
    goal: seed.focus,
    minutes: 12,
    steps: [
      LessonStep(
        type: LessonStepType.play,
        title: 'Core drill',
        description: seed.whatDoIPlay,
        minutes: 5,
      ),
      LessonStep(
        type: LessonStepType.improvise,
        title: 'Apply in phrase',
        description: seed.improvisationAssignment,
        minutes: 4,
      ),
      LessonStep(
        type: LessonStepType.record,
        title: 'Capture one take',
        description:
            seed.recordCheckpoint ?? 'سجّل take قصيرة ثم عدّل نقطة واحدة فقط.',
        minutes: 3,
      ),
    ],
    bars: _barsForExercise(seed.exerciseType),
    meter: '4/4',
    swing: _isSwingExercise(seed),
    concertKey: _concertKeyForDay(seed),
    writtenKeyForBbSax: _writtenKeyForBb(seed),
    writtenKeyForEbSax: _writtenKeyForEb(seed),
    tempoRange: seed.tempoRange,
    targetConcepts: seed.concepts,
    feedbackCategories: _feedbackCategories(seed.skillAreas),
    evaluationCriteria: _evaluationCriteria(seed.skillAreas),
    rhythmTrainerModes: seed.skillAreas.contains(SkillArea.rhythm)
        ? const [
            RhythmTrainerMode.clapBack,
            RhythmTrainerMode.playBackOneNote,
            RhythmTrainerMode.playRhythmUsingScale,
          ]
        : const [],
    feelNotes: _feelNotes(seed),
    suggestedSaxTypes: _allSaxTypes,
    backingTrack: backingTrack,
    sourceInspiration: _coreSources,
    originalityNote:
        'Original MVP exercise that keeps listening, explanation, singing, playing, improvising, recording, and evaluation connected.',
  );
}

List<FeedbackCategory> _feedbackCategories(List<SkillArea> areas) {
  final categories = <FeedbackCategory>{};
  if (areas.contains(SkillArea.tone)) {
    categories.add(FeedbackCategory.tone);
    categories.add(FeedbackCategory.intonation);
  }
  if (areas.contains(SkillArea.rhythm) || areas.contains(SkillArea.swing)) {
    categories.add(FeedbackCategory.rhythm);
    categories.add(FeedbackCategory.swingFeel);
  }
  if (areas.contains(SkillArea.articulation)) {
    categories.add(FeedbackCategory.articulation);
  }
  if (areas.contains(SkillArea.improvisation) ||
      areas.contains(SkillArea.blues)) {
    categories.add(FeedbackCategory.improvisationLogic);
    categories.add(FeedbackCategory.phraseShape);
  }
  if (areas.contains(SkillArea.theory)) {
    categories.add(FeedbackCategory.chordToneTargeting);
  }

  return categories.toList(growable: false);
}

List<EvaluationCriterion> _evaluationCriteria(List<SkillArea> areas) {
  final criteria = <EvaluationCriterion>[];
  if (areas.contains(SkillArea.tone)) {
    criteria.add(
      const EvaluationCriterion(
        category: FeedbackCategory.tone,
        label: 'Tone center',
        description: 'هل النغمة ثابتة ومفتوحة بدون collapse أو spread؟',
      ),
    );
  }
  if (areas.contains(SkillArea.rhythm) || areas.contains(SkillArea.swing)) {
    criteria.add(
      const EvaluationCriterion(
        category: FeedbackCategory.rhythm,
        label: 'Pulse and placement',
        description: 'هل الهجمات في pocket وهل النبض مستقر؟',
      ),
    );
  }
  if (areas.contains(SkillArea.articulation)) {
    criteria.add(
      const EvaluationCriterion(
        category: FeedbackCategory.articulation,
        label: 'Articulation',
        description: 'هل النطق خفيف ومقصود أم ثقيل ومقطوع؟',
      ),
    );
  }
  if (areas.contains(SkillArea.improvisation) ||
      areas.contains(SkillArea.blues)) {
    criteria.add(
      const EvaluationCriterion(
        category: FeedbackCategory.improvisationLogic,
        label: 'Phrase logic',
        description: 'هل الفكرة مفهومة ولها بداية ونهاية ومساحة؟',
      ),
    );
  }
  if (areas.contains(SkillArea.theory)) {
    criteria.add(
      const EvaluationCriterion(
        category: FeedbackCategory.chordToneTargeting,
        label: 'Target awareness',
        description: 'هل النغمات المهمة واضحة عند نقاط الحركة الهارمونية؟',
      ),
    );
  }
  return criteria;
}

BackingTrack? _backingTrackForSeed(_DaySeed seed) {
  if (seed.moduleIds.contains('blues_course')) {
    return BackingTrack(
      id: 'track_blues_${seed.dayNumber}',
      title: 'Bb Jazz Blues',
      tempo: seed.tempoRange.maxBpm,
      timeSignature: '4/4',
      formDescription: '12-bar jazz blues',
      styleLabel: 'medium swing',
      form: '12_bar_jazz_blues',
      concertKey: 'Bb',
      writtenKeyForBbSax: 'C',
      writtenKeyForEbSax: 'G',
      choruses: 6,
      hasCountIn: true,
    );
  }

  if (seed.moduleIds.contains('ii_v_i_course')) {
    return BackingTrack(
      id: 'track_iivi_${seed.dayNumber}',
      title: 'ii-V-I Study Loop',
      tempo: seed.tempoRange.maxBpm,
      timeSignature: '4/4',
      formDescription: 'Short ii-V-I loop',
      styleLabel: 'medium swing',
      form: 'ii_v_i_loop',
      concertKey: 'C',
      writtenKeyForBbSax: 'D',
      writtenKeyForEbSax: 'A',
      choruses: 8,
      hasCountIn: true,
    );
  }

  if (seed.moduleIds.contains('swing_rhythm_trainer')) {
    return BackingTrack(
      id: 'track_swing_${seed.dayNumber}',
      title: 'One-Note Swing Pulse',
      tempo: seed.tempoRange.maxBpm,
      timeSignature: '4/4',
      formDescription: 'Pulse loop',
      styleLabel: 'medium swing',
      form: 'swing_pulse_loop',
      concertKey: 'C',
      writtenKeyForBbSax: 'D',
      writtenKeyForEbSax: 'A',
      choruses: 10,
      hasCountIn: true,
    );
  }

  return null;
}

int? _barsForExercise(ExerciseType type) {
  switch (type) {
    case ExerciseType.rhythmPlayback:
    case ExerciseType.swingSubdivision:
      return 2;
    case ExerciseType.bluesPhrase:
      return 4;
    case ExerciseType.iiVI:
    case ExerciseType.backingTrackImprovisation:
      return 4;
    default:
      return null;
  }
}

bool _isSwingExercise(_DaySeed seed) {
  return seed.skillAreas.contains(SkillArea.swing) ||
      seed.skillAreas.contains(SkillArea.blues) ||
      seed.exerciseType == ExerciseType.backingTrackImprovisation ||
      seed.exerciseType == ExerciseType.swingSubdivision;
}

List<String> _feelNotes(_DaySeed seed) {
  if (seed.skillAreas.contains(SkillArea.swing)) {
    return const [
      'Keep the metronome on 2 and 4 when possible.',
      'Swing placement changes with tempo; do not freeze it into math only.',
    ];
  }
  if (seed.skillAreas.contains(SkillArea.blues)) {
    return const [
      'Leave space so the phrase can answer itself.',
      'Use repetition before adding more notes.',
    ];
  }
  return const [
    'Listen first, then play only what you can hear clearly.',
  ];
}

String? _concertKeyForDay(_DaySeed seed) {
  if (seed.skillAreas.contains(SkillArea.blues)) {
    return 'Bb';
  }
  if (seed.moduleIds.contains('ii_v_i_course')) {
    return 'C';
  }
  return 'C';
}

String? _writtenKeyForBb(_DaySeed seed) {
  final concertKey = _concertKeyForDay(seed);
  if (concertKey == 'Bb') {
    return 'C';
  }
  if (concertKey == 'C') {
    return 'D';
  }
  return null;
}

String? _writtenKeyForEb(_DaySeed seed) {
  final concertKey = _concertKeyForDay(seed);
  if (concertKey == 'Bb') {
    return 'G';
  }
  if (concertKey == 'C') {
    return 'A';
  }
  return null;
}
