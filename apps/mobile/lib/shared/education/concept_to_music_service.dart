import 'jazz_curriculum_models.dart';

class ConceptToMusicService {
  const ConceptToMusicService();

  List<ConceptToMusicMap> mapsForPillar(JazzPillarId pillarId) {
    switch (pillarId) {
      case JazzPillarId.jazzTheoryCore:
        return const [
          _dominantFlatNineMap,
          _guideToneResolutionMap,
        ];
      case JazzPillarId.improvisationSystem:
        return const [
          _guideToneResolutionMap,
          _bebopApproachMap,
        ];
      case JazzPillarId.swingRhythmEngine:
        return const [
          _swingPlacementMap,
        ];
      default:
        return const [];
    }
  }

  List<ConceptToMusicMap> mapsForModule(String moduleId) {
    if (moduleId.contains('dominant') || moduleId.contains('chord-sound')) {
      return const [_dominantFlatNineMap];
    }
    if (moduleId.contains('guide') || moduleId.contains('linear')) {
      return const [_guideToneResolutionMap];
    }
    if (moduleId.contains('bebop')) {
      return const [_bebopApproachMap];
    }
    if (moduleId.contains('swing') || moduleId.contains('subdivision')) {
      return const [_swingPlacementMap];
    }

    return const [];
  }
}

const ConceptToMusicMap _dominantFlatNineMap = ConceptToMusicMap(
  id: 'concept-dominant-b9',
  conceptTitle: 'b9 on Dominant Chord',
  theory: 'G7b9 = G B D F Ab',
  soundTarget: 'Target B-F-Ab resolving to E-G',
  coreContext: 'Dm7 | G7b9 | Cmaj7',
  concertKey: 'C',
  writtenKeyForBbSax: 'D',
  writtenKeyForEbSax: 'A',
  sourceInspiration: [
    'The Jazz Theory Book — Mark Levine',
    'The Jazz Language — Dan Haerle',
  ],
  contexts: [
    ConceptToMusicContext(
      type: ConceptMusicContextType.blues,
      title: 'Blues',
      description:
          'ضع الـ b9 مرة واحدة فقط في bar 9 من jazz blues ثم حلّها نزولاً إلى 5 أو 3.',
      progression: 'Dm7 | G7b9 | Cmaj7',
      exerciseInstruction: 'استخدم الـ Ab مرة واحدة في كل chorus.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.iiVI,
      title: 'ii-V-I',
      description:
          'اسمع الـ 3rd والـ 7th أولاً، ثم أضف الـ b9 كتلوين قصير قبل الحل.',
      progression: 'Dm7 | G7b9 | Cmaj7',
      noteFocus: 'B-F-Ab → E-G',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.jazzStandardProgression,
      title: 'Jazz Standard-style Progression',
      description:
          'استخدمه في turnaround قصير حيث تظهر dominant ثانوية قبل الرجوع إلى tonic major.',
      progression: 'Em7 A7 | Dm7 G7b9 | Cmaj7 A7',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.bebopLine,
      title: 'Bebop Line',
      description:
          'ابنِ line قصيرة تصعد إلى b9 ثم تؤخر الحل نصف beat قبل landing على 3rd للوتر التالي.',
      noteFocus: 'F-Ab-G-E',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.saxEtude,
      title: 'Sax Etude',
      description:
          'اتود قصير يثبت شكل dominant altered داخل جملة legato مع accent في القمة.',
      etude: Etude(
        id: 'etude-b9-dominant-shape',
        title: 'Dominant b9 Resolution Etude',
        description: 'اتود أصلي قصير يركز على b9 ثم الحل الواضح.',
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
        targetConcepts: ['dominant 7', 'b9', 'resolution'],
        evaluationCriteria: [
          EvaluationCriterion(
            category: FeedbackCategory.chordToneTargeting,
            label: 'Resolution',
            description: 'هل حُلّت الـ b9 إلى chord tone مستقرة؟',
          ),
        ],
        bars: 4,
        meter: '4/4',
        swing: true,
        tempoRange: TempoRange(minBpm: 80, maxBpm: 110),
      ),
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.earTraining,
      title: 'Ear Training',
      description: 'غنِّ B-F أولاً، ثم أضف Ab واسمع التوتر قبل الحل إلى E.',
      transcriptionTask: TranscriptionTask(
        id: 'ear-b9-resolution',
        title: 'Hear the b9 Resolve',
        focus: 'b9 tension into major resolution',
        minutes: 6,
        instructions: [
          'اسمع tri-tone أولاً.',
          'أضف b9 بصوتك بدون آلة.',
          'حلّ النغمة إلى 3rd للوتر التالي.',
        ],
        expectedOutcome: 'تمييز توتر b9 وحله سمعيًا قبل العزف.',
      ),
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.backingTrack,
      title: 'Backing Track',
      description: 'طبّق الـ b9 فوق dominant واحدة في كل chorus فقط.',
      backingTrack: BackingTrack(
        id: 'concept-b9-iivi-track',
        title: 'ii-V-I Color Study',
        tempo: 96,
        timeSignature: '4/4',
        formDescription: 'Short ii-V-I loop',
        styleLabel: 'medium swing',
        form: 'ii_v_i_loop',
        concertKey: 'C',
        writtenKeyForBbSax: 'D',
        writtenKeyForEbSax: 'A',
        choruses: 6,
        hasCountIn: true,
      ),
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.rhythmExercise,
      title: 'Rhythm Exercise',
      description:
          'ضع الـ b9 على upbeat واحد فقط، ثم كرر نفس placement مع chord tone في الجملة التالية.',
      rhythmPattern: RhythmPattern(
        id: 'rhythm-b9-upbeat-placement',
        title: 'Single Upbeat Tension',
        description: 'placement واحد للـ b9 على upbeat ثم حل مباشر.',
        bars: 2,
        meter: '4/4',
        swing: true,
        tempoRange: TempoRange(minBpm: 88, maxBpm: 112),
        targetSkills: [SkillArea.rhythm, SkillArea.swing, SkillArea.theory],
        evaluationCriteria: [
          EvaluationCriterion(
            category: FeedbackCategory.rhythm,
            label: 'Upbeat Placement',
            description: 'هل placement واضح ومقصود؟',
          ),
        ],
        countPattern: ['1 + 2 3 4', '1 2 + 4'],
      ),
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.improvisationPrompt,
      title: 'Improvisation Prompt',
      description: 'ارتجل 4 bars، واستخدم الـ b9 مرة واحدة فقط في كل phrase.',
      improvisationPrompt: ImprovisationPrompt(
        id: 'prompt-b9-once-per-phrase',
        title: 'Use b9 Once Per Phrase',
        prompt:
            'ارتجل 4 bars واستخدم الـ b9 مرة واحدة فقط في كل phrase ثم حلها مباشرة.',
        targetSkills: [SkillArea.improvisation, SkillArea.theory],
        evaluationCriteria: [
          EvaluationCriterion(
            category: FeedbackCategory.chordToneTargeting,
            label: 'Controlled color tone',
            description: 'هل ظهر اللون مرة واحدة فقط ثم حُلّ بوضوح؟',
          ),
        ],
        requirements: [
          'مرة واحدة فقط لكل phrase',
          'حل واضح إلى chord tone',
          'لا تحول الفكرة إلى scale run',
        ],
        tempoRange: TempoRange(minBpm: 90, maxBpm: 120),
      ),
    ),
  ],
);

const ConceptToMusicMap _guideToneResolutionMap = ConceptToMusicMap(
  id: 'concept-guide-tones-iivi',
  conceptTitle: 'Guide Tones through ii-V-I',
  theory: 'Dm7 → G7 → Cmaj7 with 3rds and 7ths as the structural spine',
  soundTarget: 'F → F → E and C → B → B',
  coreContext: 'Dm7 | G7 | Cmaj7',
  concertKey: 'C',
  writtenKeyForBbSax: 'D',
  writtenKeyForEbSax: 'A',
  sourceInspiration: [
    'Connecting Chords with Linear Harmony — Bert Ligon',
    'The Jazz Theory Book — Mark Levine',
  ],
  contexts: [
    ConceptToMusicContext(
      type: ConceptMusicContextType.iiVI,
      title: 'ii-V-I',
      description: 'اعزف فقط 3rds و7ths ثم غيّر الإيقاع بدون إضافة نغمات أخرى.',
      progression: 'Dm7 | G7 | Cmaj7',
      noteFocus: 'F-F-E / C-B-B',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.bebopLine,
      title: 'Bebop Line',
      description:
          'أضف enclosure صغيرة حول E مع بقاء الـ guide tones هي العمود الفقري.',
      noteFocus: 'F-F-(F#-D#)-E',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.earTraining,
      title: 'Ear Training',
      description: 'غنّ guide tones فقط فوق loop harmony قبل أي عزف فعلي.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.improvisationPrompt,
      title: 'Improvisation Prompt',
      description:
          'ابنِ 2-bar phrase لا تحتوي إلا على guide tones وpassing tone واحدة.',
    ),
  ],
);

const ConceptToMusicMap _bebopApproachMap = ConceptToMusicMap(
  id: 'concept-bebop-approach-note',
  conceptTitle: 'Chromatic Approach Note',
  theory: 'Target note + upper/lower chromatic approach before landing',
  soundTarget:
      'Hear tension release into a stable chord tone, not random chromaticism',
  coreContext: 'ii-V-I or turnaround',
  concertKey: 'Bb',
  writtenKeyForBbSax: 'C',
  writtenKeyForEbSax: 'G',
  sourceInspiration: [
    'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
    'The Jazz Language — Dan Haerle',
  ],
  contexts: [
    ConceptToMusicContext(
      type: ConceptMusicContextType.bebopLine,
      title: 'Bebop Line',
      description:
          'اجعل الـ approach note قبل beat قوية مباشرة حتى يسمع الحل بوضوح.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.saxEtude,
      title: 'Sax Etude',
      description: 'اتود قصير يكرر approach notes على قمم phrases المختلفة.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.improvisationPrompt,
      title: 'Improvisation Prompt',
      description:
          'استخدم approach note واحدة فقط لكل bar مع نهاية phrase واضحة.',
    ),
  ],
);

const ConceptToMusicMap _swingPlacementMap = ConceptToMusicMap(
  id: 'concept-swing-placement',
  conceptTitle: 'Off-beat Swing Placement',
  theory: 'Off-beat eighths shift with tempo, style, and phrase shape',
  soundTarget:
      'Offbeats sit with the pulse, not ahead of it and not locked to a rigid triplet ratio',
  coreContext: 'One-note swing phrase over medium swing pulse',
  sourceInspiration: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Language — Dan Haerle',
  ],
  contexts: [
    ConceptToMusicContext(
      type: ConceptMusicContextType.rhythmExercise,
      title: 'Rhythm Exercise',
      description:
          'صفق ثم اعزف نفس pattern على نغمة واحدة مع metronome على 2 و4.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.backingTrack,
      title: 'Backing Track',
      description:
          'جرّب نفس phrase فوق medium swing loop ثم فوق fast swing loop.',
    ),
    ConceptToMusicContext(
      type: ConceptMusicContextType.improvisationPrompt,
      title: 'Improvisation Prompt',
      description: 'ارتجل 2 bars بنفس rhythm ثم غيّر pitches فقط.',
    ),
  ],
);
