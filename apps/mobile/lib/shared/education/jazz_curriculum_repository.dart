import '../../data/models/attempt_history_entry.dart';
import '../../data/models/learner_progress.dart';
import 'concept_to_music_service.dart';
import 'jazz_curriculum_models.dart';

const String _originalCurriculumGuardrail =
    'All lesson and exercise material in this app is original product-authored content. It is inspired by respected jazz education traditions, but it does not reproduce copyrighted melodies, published etudes, lead sheets, or book exercises.';

const List<String> _coreJazzSources = [
  'Jamey Aebersold Jazz Handbook',
  'The Jazz Theory Book — Mark Levine',
  'The Jazz Language — Dan Haerle',
  'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
  'Connecting Chords with Linear Harmony — Bert Ligon',
];

const ConceptToMusicService _conceptToMusicService = ConceptToMusicService();

const Map<JazzPillarId, List<String>> _pillarSourceMap = {
  JazzPillarId.saxophoneFoundation: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Language — Dan Haerle',
  ],
  JazzPillarId.jazzTheoryCore: [
    'The Jazz Theory Book — Mark Levine',
    'Connecting Chords with Linear Harmony — Bert Ligon',
  ],
  JazzPillarId.swingRhythmEngine: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Language — Dan Haerle',
  ],
  JazzPillarId.bluesCurriculum: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Language — Dan Haerle',
  ],
  JazzPillarId.improvisationSystem: [
    'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
    'Connecting Chords with Linear Harmony — Bert Ligon',
  ],
  JazzPillarId.repertoireTuneStudy: [
    'Jamey Aebersold Jazz Handbook',
    'Real Book-style repertoire study tradition (without copyrighted lead sheets)',
    'The Jazz Theory Book — Mark Levine',
    'Connecting Chords with Linear Harmony — Bert Ligon',
  ],
  JazzPillarId.saxophoneJazzLanguage: [
    'The Jazz Language — Dan Haerle',
    'Bob Mintzer-style saxophone etude logic (original, non-copied content)',
  ],
  JazzPillarId.listeningTranscription: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Language — Dan Haerle',
  ],
  JazzPillarId.practiceEngine: [
    'Jamey Aebersold Jazz Handbook',
    'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
  ],
  JazzPillarId.aiAudioFeedback: [
    'Jamey Aebersold Jazz Handbook',
    'The Jazz Theory Book — Mark Levine',
  ],
  JazzPillarId.libraryReference: _coreJazzSources,
  JazzPillarId.progressTracking: [
    'Jamey Aebersold Jazz Handbook',
    'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
  ],
  JazzPillarId.dailyPracticeGenerator: [
    'Jamey Aebersold Jazz Handbook',
    'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
    'Connecting Chords with Linear Harmony — Bert Ligon',
  ],
};

class JazzCurriculumRepository {
  const JazzCurriculumRepository();

  List<JazzPillarTrack> getPillars() =>
      _pillars.map(_decoratePillarWithSourceMetadata).toList(growable: false);

  JazzPillarTrack getPillar(JazzPillarId id) =>
      getPillars().firstWhere((pillar) => pillar.id == id);

  SkillTreeSnapshot buildSkillTree({
    required LearnerProgress progress,
    AttemptHistoryEntry? latestAttempt,
  }) {
    final currentLevel = _currentSkillTreeLevel(
      progress: progress,
      latestAttempt: latestAttempt,
    );
    final levels = _skillTreeBlueprint.map((blueprint) {
      final unlocked = _isSkillTreeLevelUnlocked(
        blueprint.level,
        progress: progress,
        latestAttempt: latestAttempt,
      );
      final nodes = blueprint.nodes.map((node) {
        final status = _skillTreeNodeStatus(
          node.level,
          node.title,
          progress: progress,
          latestAttempt: latestAttempt,
          unlocked: unlocked,
        );
        return SkillTreeNode(
          id: node.id,
          title: node.title,
          level: node.level,
          skillAreas: node.skillAreas,
          status: status,
          progressPercent: _skillTreeNodeProgressPercent(
            status,
            progress: progress,
            latestAttempt: latestAttempt,
          ),
        );
      }).toList(growable: false);

      final masteredCount = nodes
          .where((node) => node.status == SkillTreeNodeStatus.mastered)
          .length;
      final progressPercent = nodes.isEmpty
          ? 0
          : (nodes.fold<int>(0, (sum, node) => sum + node.progressPercent) /
                  nodes.length)
              .round();

      return SkillTreeLevel(
        level: blueprint.level,
        title: blueprint.title,
        summary: blueprint.summary,
        nodes: nodes,
        unlocked: unlocked,
        masteredCount: masteredCount,
        progressPercent: progressPercent,
      );
    }).toList(growable: false);

    final totalNodes =
        levels.fold<int>(0, (sum, level) => sum + level.nodes.length);
    final masteredNodes =
        levels.fold<int>(0, (sum, level) => sum + level.masteredCount);
    final overallProgressPercent = totalNodes == 0
        ? 0
        : (levels.fold<int>(0, (sum, level) => sum + level.progressPercent) /
                levels.length)
            .round();

    return SkillTreeSnapshot(
      levels: levels,
      currentLevel: currentLevel,
      totalNodes: totalNodes,
      masteredNodes: masteredNodes,
      overallProgressPercent: overallProgressPercent,
    );
  }

  PracticeEngineInput buildPracticeEngineInput({
    required LearnerProgress progress,
    AttemptHistoryEntry? latestAttempt,
    required SaxType saxType,
    required int availableMinutes,
    PracticeGoal? goal,
  }) {
    final weakAreas = <SkillArea>{
      if ((latestAttempt?.pitchAccuracy ?? 100) < 80) SkillArea.tone,
      if ((latestAttempt?.rhythmAccuracy ?? 100) < 70) SkillArea.rhythm,
      if ((latestAttempt?.rhythmAccuracy ?? 100) < 75) SkillArea.swing,
    }.toList(growable: false);

    final level = progress.completedDaysCount >= 5
        ? DifficultyLevel.intermediate
        : progress.completedDaysCount >= 2
            ? DifficultyLevel.earlyIntermediate
            : DifficultyLevel.beginner;

    final inferredGoal = weakAreas.contains(SkillArea.swing) ||
            weakAreas.contains(SkillArea.rhythm)
        ? PracticeGoal.betterSwing
        : progress.currentDayNumber >= 4
            ? PracticeGoal.betterBluesImprovisation
            : PracticeGoal.balancedDevelopment;

    return PracticeEngineInput(
      level: level,
      saxType: saxType,
      goal: goal ?? inferredGoal,
      availableMinutes: availableMinutes,
      weakAreas: weakAreas,
      currentCourse: 'Current Day ${progress.currentDayNumber}',
      upcomingLessons: progress.currentDayNumber < progress.totalDays
          ? ['Day ${progress.currentDayNumber + 1}']
          : const [],
      conceptMasteryCount: latestAttempt != null &&
              latestAttempt.pitchAccuracy >= 85 &&
              latestAttempt.rhythmAccuracy >= 85
          ? {latestAttempt.exerciseId: 3}
          : const {},
      repeatedFailureCount: latestAttempt != null &&
              (latestAttempt.pitchAccuracy < 70 ||
                  latestAttempt.rhythmAccuracy < 70)
          ? {latestAttempt.exerciseId: 2}
          : const {},
    );
  }

  DailyPracticeProgram buildDailyProgram({
    required LearnerProgress progress,
    AttemptHistoryEntry? latestAttempt,
    required PracticeEngineInput input,
  }) {
    final engineInput = input;
    final weakAreas = engineInput.weakAreas.toSet();
    final pitchAccuracy = latestAttempt?.pitchAccuracy ?? 100;
    final rhythmAccuracy = latestAttempt?.rhythmAccuracy ?? 100;
    final articulationWeak = weakAreas.contains(SkillArea.articulation);
    final timingWeak = weakAreas.contains(SkillArea.rhythm) ||
        weakAreas.contains(SkillArea.swing) ||
        rhythmAccuracy < 70;
    final pitchWeak = weakAreas.contains(SkillArea.tone) || pitchAccuracy < 80;
    final repeatedFailures = engineInput.repeatedFailureCount.values.any(
      (count) => count >= 2,
    );
    final masteredConcept = engineInput.conceptMasteryCount.values.any(
      (count) => count >= 3,
    );
    final canIncreaseComplexity =
        masteredConcept && pitchAccuracy >= 80 && rhythmAccuracy >= 75;
    final tempoDelta = rhythmAccuracy < 70 ? -15 : 0;
    final baseTempo = _goalBaseTempo(engineInput.goal);
    final workingTempo = (baseTempo + tempoDelta).clamp(52, 240);

    final adaptationDecisions = <PracticeAdaptationDecision>[
      if (pitchAccuracy < 80)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.repeatTomorrow,
          title: 'Repeat Tomorrow',
          description:
              'Pitch accuracy أقل من 80%، لذلك سيُعاد نفس التمرين الأساسي غدًا قبل فتح variation جديدة.',
          relatedSkillArea: SkillArea.tone,
        ),
      if (rhythmAccuracy < 70)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.reduceTempo,
          title: 'Reduce Tempo',
          description:
              'Rhythm accuracy أقل من 70%، لذلك سننزل التيمبو 15 BPM ونثبت placement أولًا.',
          relatedSkillArea: SkillArea.rhythm,
          tempoAdjustmentBpm: -15,
        ),
      if (articulationWeak)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.articulationVariation,
          title: 'Articulation Variation',
          description:
              'فيه ضعف في articulation، لذلك أضفنا variation تركّز على النطق والghosting والاتصال.',
          relatedSkillArea: SkillArea.articulation,
        ),
      if (repeatedFailures)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.reduceComplexity,
          title: 'Reduce Complexity',
          description:
              'بسبب تكرار التعثر، الخطة اليوم تبسط المادة: tempo أبطأ، notes أقل، one-note rhythm، phrase أصغر، ومفتاح أسهل.',
        ),
      if (canIncreaseComplexity)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.unlockHarderVariation,
          title: 'Unlock Harder Variation',
          description:
              'المفهوم أتقن 3 مرات أو أكثر مع استقرار جيد، لذلك سنفتح variation أصعب اليوم.',
        ),
      if (canIncreaseComplexity)
        const PracticeAdaptationDecision(
          type: PracticeAdaptationType.increaseComplexity,
          title: 'Increase Complexity',
          description:
              'النجاح المستمر يسمح بإضافة tempo أسرع، مفاتيح أكثر، form أطول، backing track، ومهمة improvisation أعمق.',
        ),
    ];

    final candidateBlocks = <DailyPracticeBlock>[
      DailyPracticeBlock(
        title: pitchWeak ? 'Tone Centering' : 'Tone Maintenance',
        minutes: 5,
        pillarId: JazzPillarId.saxophoneFoundation,
        stage: LearningLoopStage.play,
        instructions: pitchWeak
            ? 'اشتغل على long tones وair support وtone core قبل أي توسع لغوي. لو الـ pitch أقل من 80% كرر نفس التمرين غدًا.'
            : '5 دقائق tone maintenance للحفاظ على المركز الصوتي قبل العمل الهارموني والإيقاعي.',
        skillAreas: const [SkillArea.tone],
        targetTempoBpm: 60,
        targetExerciseId: 'foundation-tone-longtones',
        adaptationNote: pitchWeak
            ? 'Repeat this same exercise tomorrow if pitch remains below 80%.'
            : null,
        recommendedSaxType: engineInput.saxType,
      ),
      DailyPracticeBlock(
        title: articulationWeak
            ? 'Articulation Reset'
            : 'Articulation Calibration',
        minutes: 5,
        pillarId: JazzPillarId.saxophoneJazzLanguage,
        stage: LearningLoopStage.play,
        instructions: articulationWeak
            ? 'ركز على doo-dat feel أو legato touch حسب goal اليوم، مع variation مخصصة للنطق.'
            : 'راجع articulation خفيفة وسريعة حتى تبقى اللغة واضحة عند زيادة الصعوبة.',
        skillAreas: const [SkillArea.articulation],
        targetTempoBpm: workingTempo,
        targetExerciseId: articulationWeak
            ? 'language-swing-doo-dat'
            : 'language-bebop-touch',
        adaptationNote: articulationWeak
            ? 'Articulation-focused variation recommended today.'
            : null,
        recommendedSaxType: engineInput.saxType,
      ),
      DailyPracticeBlock(
        title: timingWeak ? 'Rhythm on One Note' : 'Rhythm Flow',
        minutes: 5,
        pillarId: JazzPillarId.swingRhythmEngine,
        stage: LearningLoopStage.play,
        instructions: timingWeak
            ? 'اعزف rhythm على note واحدة فقط. انزل $workingTempo BPM وركّز على pulse وplacement قبل النغمات الكثيرة.'
            : 'اشتغل على swing subdivision وmetronome على 2 و4 مع نفس الnote-set الأساسية.',
        skillAreas: const [SkillArea.rhythm, SkillArea.swing],
        targetTempoBpm: workingTempo,
        targetExerciseId: 'swing-pulse-and-metronome',
        adaptationNote: timingWeak
            ? 'Reduced by 15 BPM because rhythm accuracy is below 70%.'
            : null,
        recommendedSaxType: engineInput.saxType,
      ),
      DailyPracticeBlock(
        title: _goalScaleBlockTitle(engineInput.goal),
        minutes: 5,
        pillarId: engineInput.goal == PracticeGoal.betterBluesImprovisation
            ? JazzPillarId.bluesCurriculum
            : JazzPillarId.saxophoneFoundation,
        stage: LearningLoopStage.play,
        instructions: _goalScaleBlockInstructions(
          goal: engineInput.goal,
          reducedComplexity: repeatedFailures,
          increasedComplexity: canIncreaseComplexity,
        ),
        skillAreas: _goalScaleBlockAreas(engineInput.goal),
        targetTempoBpm: workingTempo,
        targetExerciseId:
            engineInput.goal == PracticeGoal.betterBluesImprovisation
                ? 'blues-level-1-basic'
                : 'foundation-technique-map',
        adaptationNote: repeatedFailures
            ? 'Reduced complexity: fewer notes, easier key, shorter phrase.'
            : canIncreaseComplexity
                ? 'Increased complexity: more keys and faster tempo.'
                : null,
        recommendedSaxType: engineInput.saxType,
      ),
      DailyPracticeBlock(
        title: engineInput.goal == PracticeGoal.betterBluesImprovisation
            ? 'Guide Tones over Blues'
            : 'Guide Tones and Chord Targets',
        minutes: 5,
        pillarId: engineInput.goal == PracticeGoal.betterBluesImprovisation
            ? JazzPillarId.bluesCurriculum
            : JazzPillarId.improvisationSystem,
        stage: LearningLoopStage.improvise,
        instructions: engineInput.goal == PracticeGoal.betterBluesImprovisation
            ? 'اشتغل على guide tones فوق blues form. إذا كنت متعثرًا، استخدم one-note rhythm version أولًا ثم أضف 3rds و7ths.'
            : 'اربط 3rds و7ths داخل progression الحالية، ثم وسّعها إلى chord-tone soloing بسيط.',
        skillAreas: const [
          SkillArea.improvisation,
          SkillArea.blues,
          SkillArea.theory
        ],
        targetTempoBpm: workingTempo,
        targetExerciseId:
            engineInput.goal == PracticeGoal.betterBluesImprovisation
                ? 'blues-level-2-jazz'
                : 'improv-guide-tone-lines',
        adaptationNote: repeatedFailures
            ? 'Use a smaller phrase and fewer target notes first.'
            : canIncreaseComplexity
                ? 'Add more keys or a longer form today.'
                : null,
        recommendedSaxType: engineInput.saxType,
      ),
      DailyPracticeBlock(
        title: 'Record + Feedback',
        minutes: 5,
        pillarId: JazzPillarId.aiAudioFeedback,
        stage: LearningLoopStage.record,
        instructions: engineInput.goal == PracticeGoal.betterBluesImprovisation
            ? 'سجّل blues improvisation قصيرة وراجع timing, swing feel, phrase endings، ثم طبّق feedback فورًا.'
            : 'سجّل take قصيرة وراجع weak areas الحالية، ثم نفّذ recommendation واحدة فقط في إعادة سريعة.',
        skillAreas: weakAreas.isEmpty
            ? const [SkillArea.feedback]
            : weakAreas.toList(growable: false),
        targetTempoBpm: workingTempo,
        targetExerciseId: latestAttempt?.exerciseId,
        adaptationNote: pitchAccuracy < 80
            ? 'Tomorrow starts with this same core recording target again.'
            : null,
        recommendedSaxType: engineInput.saxType,
      ),
    ];

    final selectedBlocks = _selectBlocksForAvailableTime(
      candidateBlocks,
      engineInput.availableMinutes,
    );
    final adjustedBlocks = _applyMinuteDistribution(
      selectedBlocks,
      engineInput.availableMinutes,
    );
    final totalMinutes =
        adjustedBlocks.fold<int>(0, (sum, block) => sum + block.minutes);

    return DailyPracticeProgram(
      title: 'Adaptive Practice Engine',
      summary:
          'خطة اليوم مبنية على level=${engineInput.level.name}, sax=${saxTypeDisplayLabel(engineInput.saxType)}, goal=${practiceGoalLabel(engineInput.goal)}, الوقت المتاح=${engineInput.availableMinutes} دقيقة، weak areas=${_skillAreaSummary(weakAreas)}، وآخر أداء محفوظ.',
      totalMinutes: totalMinutes,
      blocks: adjustedBlocks,
      nextRecommendation: _buildPracticeNextRecommendation(
        latestAttempt: latestAttempt,
        timingWeak: timingWeak,
        pitchWeak: pitchWeak,
        repeatedFailures: repeatedFailures,
        canIncreaseComplexity: canIncreaseComplexity,
      ),
      inputProfile: engineInput,
      adaptationDecisions: adaptationDecisions,
      sourceInspiration: _pillarSourceMap[JazzPillarId.dailyPracticeGenerator]!,
      originalityNote: _originalCurriculumGuardrail,
      isOriginalContent: true,
    );
  }
}

class _SkillTreeLevelBlueprint {
  const _SkillTreeLevelBlueprint({
    required this.level,
    required this.title,
    required this.summary,
    required this.nodes,
  });

  final DifficultyLevel level;
  final String title;
  final String summary;
  final List<_SkillTreeNodeBlueprint> nodes;
}

class _SkillTreeNodeBlueprint {
  const _SkillTreeNodeBlueprint({
    required this.id,
    required this.title,
    required this.level,
    required this.skillAreas,
  });

  final String id;
  final String title;
  final DifficultyLevel level;
  final List<SkillArea> skillAreas;
}

const List<_SkillTreeLevelBlueprint> _skillTreeBlueprint = [
  _SkillTreeLevelBlueprint(
    level: DifficultyLevel.beginner,
    title: 'Beginner',
    summary:
        'ابدأ بالصوت، الـ blues foundations، basic swing، والارتجال البسيط قبل التوسع الهارموني.',
    nodes: [
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-tone-basics',
        title: 'Tone Basics',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.tone],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-major-scales',
        title: 'Major Scales',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.technique, SkillArea.theory],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-minor-pentatonic',
        title: 'Minor Pentatonic',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.blues, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-blues-scale',
        title: 'Blues Scale',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.blues, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-12-bar-blues',
        title: '12-Bar Blues',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.blues, SkillArea.repertoire],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-basic-swing',
        title: 'Basic Swing',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.swing, SkillArea.rhythm],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-call-response',
        title: 'Call and Response',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.improvisation, SkillArea.earTraining],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-beginner-simple-improv',
        title: 'Simple Improvisation',
        level: DifficultyLevel.beginner,
        skillAreas: [SkillArea.improvisation],
      ),
    ],
  ),
  _SkillTreeLevelBlueprint(
    level: DifficultyLevel.earlyIntermediate,
    title: 'Early Intermediate',
    summary:
        'وسّع الأساس إلى كل المفاتيح، dominant colors، guide tones، والـ standard framework البسيطة.',
    nodes: [
      _SkillTreeNodeBlueprint(
        id: 'skill-early-all-major-scales',
        title: 'All Major Scales',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.technique, SkillArea.theory],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-dominant-7th',
        title: 'Dominant 7th Chords',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.theory],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-dorian',
        title: 'Dorian',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-mixolydian',
        title: 'Mixolydian',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-iivi',
        title: 'ii-V-I',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-guide-tones',
        title: 'Guide Tones',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.improvisation, SkillArea.earTraining],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-jazz-blues',
        title: 'Jazz Blues',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.blues, SkillArea.repertoire],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-early-standards-framework',
        title: 'Simple Standards Framework',
        level: DifficultyLevel.earlyIntermediate,
        skillAreas: [SkillArea.repertoire],
      ),
    ],
  ),
  _SkillTreeLevelBlueprint(
    level: DifficultyLevel.intermediate,
    title: 'Intermediate',
    summary:
        'ادخل منطقة bebop language, motivic development, minor cadences، والـ transcription والetudes بشكل جاد.',
    nodes: [
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-bebop-dominant',
        title: 'Bebop Dominant',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-approach-notes',
        title: 'Approach Notes',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.saxLanguage, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-enclosures',
        title: 'Enclosures',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.saxLanguage, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-minor-iivi',
        title: 'Minor ii-V-i',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-rhythm-changes',
        title: 'Rhythm Changes Intro',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.repertoire, SkillArea.theory],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-transcription',
        title: 'Transcription',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.transcription, SkillArea.earTraining],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-etudes',
        title: 'Etudes',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.repertoire, SkillArea.saxLanguage],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-intermediate-motivic',
        title: 'Motivic Development',
        level: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.improvisation],
      ),
    ],
  ),
  _SkillTreeLevelBlueprint(
    level: DifficultyLevel.advanced,
    title: 'Advanced',
    summary:
        'هنا ندخل altered / diminished dominant / tritone subs / fast tempos / advanced transcription / performance simulation.',
    nodes: [
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-altered',
        title: 'Altered Scale',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-diminished-dominant',
        title: 'Diminished Dominant',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-tritone',
        title: 'Tritone Substitution',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.theory, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-coltrane-movement',
        title: 'Coltrane-style Harmonic Movement',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.repertoire, SkillArea.theory],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-fast-tempos',
        title: 'Fast Tempos',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.swing, SkillArea.rhythm],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-transcription',
        title: 'Advanced Transcription',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.transcription, SkillArea.earTraining],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-vocabulary',
        title: 'Personal Vocabulary',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.saxLanguage, SkillArea.improvisation],
      ),
      _SkillTreeNodeBlueprint(
        id: 'skill-advanced-performance',
        title: 'Performance Simulation',
        level: DifficultyLevel.advanced,
        skillAreas: [SkillArea.feedback, SkillArea.repertoire],
      ),
    ],
  ),
];

DifficultyLevel _currentSkillTreeLevel({
  required LearnerProgress progress,
  required AttemptHistoryEntry? latestAttempt,
}) {
  final rhythm = latestAttempt?.rhythmAccuracy ?? 0;
  final pitch = latestAttempt?.pitchAccuracy ?? 0;

  if (progress.completedDaysCount >= 6 && rhythm >= 85 && pitch >= 85) {
    return DifficultyLevel.advanced;
  }
  if (progress.completedDaysCount >= 4 && rhythm >= 75 && pitch >= 75) {
    return DifficultyLevel.intermediate;
  }
  if (progress.completedDaysCount >= 2) {
    return DifficultyLevel.earlyIntermediate;
  }
  return DifficultyLevel.beginner;
}

bool _isSkillTreeLevelUnlocked(
  DifficultyLevel level, {
  required LearnerProgress progress,
  required AttemptHistoryEntry? latestAttempt,
}) {
  final current = _currentSkillTreeLevel(
    progress: progress,
    latestAttempt: latestAttempt,
  );
  return level.index <= current.index;
}

SkillTreeNodeStatus _skillTreeNodeStatus(
  DifficultyLevel level,
  String title, {
  required LearnerProgress progress,
  required AttemptHistoryEntry? latestAttempt,
  required bool unlocked,
}) {
  if (!unlocked) {
    return SkillTreeNodeStatus.locked;
  }

  final current = _currentSkillTreeLevel(
    progress: progress,
    latestAttempt: latestAttempt,
  );
  final qualityStrong = (latestAttempt?.pitchAccuracy ?? 0) >= 85 &&
      (latestAttempt?.rhythmAccuracy ?? 0) >= 80 &&
      (latestAttempt?.completion ?? 0) >= 85;
  final qualityMedium = (latestAttempt?.pitchAccuracy ?? 0) >= 72 &&
      (latestAttempt?.rhythmAccuracy ?? 0) >= 68;

  if (level.index < current.index && qualityStrong) {
    return SkillTreeNodeStatus.mastered;
  }
  if (level == current && qualityStrong) {
    return title == 'Performance Simulation'
        ? SkillTreeNodeStatus.available
        : SkillTreeNodeStatus.inProgress;
  }
  if (level == current && qualityMedium) {
    return SkillTreeNodeStatus.inProgress;
  }
  return SkillTreeNodeStatus.available;
}

int _skillTreeNodeProgressPercent(
  SkillTreeNodeStatus status, {
  required LearnerProgress progress,
  required AttemptHistoryEntry? latestAttempt,
}) {
  switch (status) {
    case SkillTreeNodeStatus.locked:
      return 0;
    case SkillTreeNodeStatus.available:
      return 20;
    case SkillTreeNodeStatus.inProgress:
      return (((latestAttempt?.completion ?? 50) +
                  (latestAttempt?.pitchAccuracy ?? 50) +
                  (latestAttempt?.rhythmAccuracy ?? 50)) /
              3)
          .round()
          .clamp(45, 89);
    case SkillTreeNodeStatus.mastered:
      return 100;
  }
}

int _goalBaseTempo(PracticeGoal goal) {
  switch (goal) {
    case PracticeGoal.betterSwing:
      return 112;
    case PracticeGoal.betterBluesImprovisation:
      return 104;
    case PracticeGoal.strongerTone:
      return 60;
    case PracticeGoal.cleanerArticulation:
      return 96;
    case PracticeGoal.transcriptionGrowth:
      return 88;
    case PracticeGoal.repertoireFluency:
      return 124;
    case PracticeGoal.balancedDevelopment:
      return 100;
  }
}

String _goalScaleBlockTitle(PracticeGoal goal) {
  switch (goal) {
    case PracticeGoal.betterBluesImprovisation:
      return 'Blues Scale in 3 Keys';
    case PracticeGoal.betterSwing:
      return 'Swing Scale and Cell Motion';
    case PracticeGoal.strongerTone:
      return 'Tone + Overtone Extension';
    case PracticeGoal.cleanerArticulation:
      return 'Articulation Cells in 3 Keys';
    case PracticeGoal.transcriptionGrowth:
      return 'Phrase Transfer in 2 Keys';
    case PracticeGoal.repertoireFluency:
      return 'Repertoire Cell in 3 Keys';
    case PracticeGoal.balancedDevelopment:
      return 'Scale and Language Maintenance';
  }
}

List<SkillArea> _goalScaleBlockAreas(PracticeGoal goal) {
  switch (goal) {
    case PracticeGoal.betterBluesImprovisation:
      return const [SkillArea.blues, SkillArea.improvisation];
    case PracticeGoal.betterSwing:
      return const [SkillArea.swing, SkillArea.rhythm];
    case PracticeGoal.strongerTone:
      return const [SkillArea.tone, SkillArea.technique];
    case PracticeGoal.cleanerArticulation:
      return const [SkillArea.articulation, SkillArea.technique];
    case PracticeGoal.transcriptionGrowth:
      return const [SkillArea.transcription, SkillArea.earTraining];
    case PracticeGoal.repertoireFluency:
      return const [SkillArea.repertoire, SkillArea.improvisation];
    case PracticeGoal.balancedDevelopment:
      return const [SkillArea.technique, SkillArea.improvisation];
  }
}

String _goalScaleBlockInstructions({
  required PracticeGoal goal,
  required bool reducedComplexity,
  required bool increasedComplexity,
}) {
  final complexityNote = reducedComplexity
      ? 'اليوم سنبسط المهمة: tempo أبطأ، notes أقل، ومفتاح أسهل.'
      : increasedComplexity
          ? 'اليوم سنوسع المهمة: tempo أسرع، مفاتيح أكثر، وإضافة improvisation بعد التمرين.'
          : 'اليوم حافظ على النسخة الأساسية مع تركيز على الثبات والوضوح.';

  switch (goal) {
    case PracticeGoal.betterBluesImprovisation:
      return 'اعزف blues scale أو blues cell في 3 مفاتيح مع نفس rhythm الأساسية. $complexityNote';
    case PracticeGoal.betterSwing:
      return 'حرّك swing cell أو scale fragment مع metronome على 2 و4. $complexityNote';
    case PracticeGoal.strongerTone:
      return 'امد tone work إلى overtone أو dynamic variation بسيطة. $complexityNote';
    case PracticeGoal.cleanerArticulation:
      return 'استخدم نفس note set مع legato/staccato/ghosted contrast. $complexityNote';
    case PracticeGoal.transcriptionGrowth:
      return 'انقل phrase قصيرة إلى مفاتيح جديدة مع الحفاظ على rhythm identity. $complexityNote';
    case PracticeGoal.repertoireFluency:
      return 'اشتغل على repertoire cell أو turnaround fragment في أكثر من مفتاح. $complexityNote';
    case PracticeGoal.balancedDevelopment:
      return 'راجع scale أو language cell مختصرة ثم طبّقها سريعًا في جملة عملية. $complexityNote';
  }
}

List<DailyPracticeBlock> _selectBlocksForAvailableTime(
  List<DailyPracticeBlock> blocks,
  int availableMinutes,
) {
  if (availableMinutes <= 15) {
    return blocks.take(3).toList(growable: false);
  }
  if (availableMinutes <= 20) {
    return blocks.take(4).toList(growable: false);
  }
  if (availableMinutes <= 25) {
    return blocks.take(5).toList(growable: false);
  }
  return blocks.take(6).toList(growable: false);
}

List<DailyPracticeBlock> _applyMinuteDistribution(
  List<DailyPracticeBlock> blocks,
  int availableMinutes,
) {
  if (blocks.isEmpty) {
    return const [];
  }

  final base = ((availableMinutes / blocks.length).floor()).clamp(1, 10);
  var remaining = availableMinutes;
  final adjusted = <DailyPracticeBlock>[];

  for (var index = 0; index < blocks.length; index++) {
    final isLast = index == blocks.length - 1;
    final suggestedMinutes = isLast ? remaining : base;
    final minutes = suggestedMinutes < 1 ? 1 : suggestedMinutes;
    remaining -= minutes;
    final block = blocks[index];
    adjusted.add(
      DailyPracticeBlock(
        title: block.title,
        minutes: minutes,
        pillarId: block.pillarId,
        stage: block.stage,
        instructions: block.instructions,
        skillAreas: block.skillAreas,
        targetTempoBpm: block.targetTempoBpm,
        targetExerciseId: block.targetExerciseId,
        adaptationNote: block.adaptationNote,
        recommendedSaxType: block.recommendedSaxType,
      ),
    );
  }

  return adjusted;
}

String _skillAreaSummary(Set<SkillArea> weakAreas) {
  if (weakAreas.isEmpty) {
    return 'none flagged';
  }

  return weakAreas.map((item) => item.name).join(', ');
}

String _buildPracticeNextRecommendation({
  required AttemptHistoryEntry? latestAttempt,
  required bool timingWeak,
  required bool pitchWeak,
  required bool repeatedFailures,
  required bool canIncreaseComplexity,
}) {
  if (latestAttempt == null) {
    return 'ابدأ بالخطة الأساسية اليوم، ثم سجّل take قصيرة حتى تبدأ الخطة القادمة في التخصيص على أساس بيانات حقيقية.';
  }
  if (repeatedFailures) {
    return 'الخطوة التالية: استمر يومًا إضافيًا على النسخة المبسطة قبل توسيع عدد النغمات أو المفاتيح.';
  }
  if (timingWeak) {
    return 'الخطوة التالية: ثبّت time feel أولًا. أبقِ metronome أبطأ 15 BPM وكرر one-note rhythm version غدًا.';
  }
  if (pitchWeak) {
    return 'الخطوة التالية: كرر نفس تمرين tone/pitch الأساسي غدًا حتى تتجاوز 80% قبل فتح variation جديدة.';
  }
  if (canIncreaseComplexity) {
    return 'الخطوة التالية: افتح variation أصعب غدًا: tempo أسرع، مفاتيح أكثر، أو form أطول مع backing track.';
  }
  return latestAttempt.nextRecommendation;
}

JazzPillarTrack _decoratePillarWithSourceMetadata(JazzPillarTrack pillar) {
  final sources = _pillarSourceMap[pillar.id] ?? _coreJazzSources;
  final pillarConceptMaps = _conceptToMusicService.mapsForPillar(pillar.id);

  return pillar.copyWith(
    sourceInspiration: sources,
    originalityNote: _originalCurriculumGuardrail,
    isOriginalContent: true,
    conceptToMusicMaps: pillar.conceptToMusicMaps.isEmpty
        ? pillarConceptMaps
        : pillar.conceptToMusicMaps,
    modules: pillar.modules
        .map(
          (module) => module.copyWith(
            sourceInspiration: sources,
            originalityNote:
                'Original module structure inspired by these jazz sources; all examples are product-authored.',
            isOriginalContent: true,
            conceptToMusicMaps: module.conceptToMusicMaps.isEmpty
                ? _conceptToMusicService.mapsForModule(module.id)
                : module.conceptToMusicMaps,
            exercises: module.exercises
                .map(
                  (exercise) => exercise.copyWith(
                    sourceInspiration: sources,
                    originalityNote:
                        'Original exercise content inspired by the listed sources; not copied from published books, solos, lead sheets, or etudes.',
                    isOriginalContent: true,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false),
    tunes: pillar.tunes
        .map(
          (tune) => tune.copyWith(
            sourceInspiration: sources,
            originalityNote:
                'Original tune-study framework inspired by the listed sources; it analyzes style, harmony, rhythm, and improvisation logic without reproducing copyrighted lead sheets or melodies.',
            isOriginalContent: true,
          ),
        )
        .toList(growable: false),
  );
}

const List<JazzPillarTrack> _pillars = [
  JazzPillarTrack(
    id: JazzPillarId.saxophoneFoundation,
    title: 'Saxophone Foundation',
    shortLabel: 'Sound',
    summary:
        'بناء الصوت، النفس، التقنية، articulation، والسيطرة على الريجسترات كأساس مهني قبل اللغة والارتجال.',
    whyItMatters:
        'من غير sound concept قوي وسيطرة تقنية وتنفس واضح، كل نظرية أو لغة جاز ستخرج ضعيفة وغير مقنعة.',
    objectives: [
      'تثبيت النفس والـ voicing ومركز النغمة',
      'بناء تقنية scales, arpeggios, intervals, palm keys, low register',
      'تطوير articulation جازية واعية',
      'التخطيط للتنفس ودعم الجملة',
    ],
    modules: [
      JazzLessonModule(
        id: 'foundation-tone-logic',
        title: 'Tone Production & Sound Colors',
        summary:
            'من long tones إلى overtones إلى vibrato وsubtone والزخارف التعبيرية مثل falls وscoops وdoits.',
        keyTakeaways: [
          'النغمة تبدأ من الهواء والـ voicing قبل الأصابع',
          'الـ long tone أداة استماع وتحكم، ليس مجرد warm-up',
          'ألوان التعبير مثل subtone, growl, falls, scoops, doits تأتي بعد ثبات المركز الصوتي',
        ],
        exercises: [
          JazzExercise(
            id: 'foundation-tone-longtones',
            title: 'Long Tones with Dynamic Arcs',
            category: ExerciseCategory.technique,
            goal: 'تثبيت مركز النغمة مع التحكم في dynamics من pp إلى ff.',
            minutes: 12,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 52, maxBpm: 72),
            targetConcepts: [
              'long tones',
              'dynamic control',
              'tone center',
              'air support',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Tone Core',
                description: 'ثبات اللون الصوتي من بداية النغمة إلى نهايتها.',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.intonation,
                label: 'Pitch Stability',
                description:
                    'عدم هبوط أو ارتفاع النغمة أثناء crescendo وdecrescendo.',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع لون النغمة',
                description:
                    'استمع لنغمة مرجعية ثابتة وركز على ثبات اللون أثناء الصعود من pp إلى ff والعودة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم arc الديناميكي',
                description:
                    'اعرف أن الهدف ليس رفع الصوت فقط، بل الحفاظ على نفس مركز النغمة مع تغير intensity.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ اللون قبل العزف',
                description:
                    'غنّ النغمة مع تخيل القوس الديناميكي نفسه قبل لمس الساكسفون.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف long tone arc',
                description:
                    'اعزف 8 عدات: ابدأ pp، صِل إلى ff في المنتصف، ثم عُد إلى pp مع release نظيف.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'لوّن نهاية phrase',
                description:
                    'استخدم نفس القوس الديناميكي في نهاية phrase قصيرة على note واحدة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل take ديناميكية',
                description:
                    'سجّل 3 محاولات وقارن أي واحدة حافظت على اللون والـ pitch أفضل.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'راجع المركز الصوتي',
                description: 'هل تغير اللون أو سقط الـ pitch عند pp أو عند ff؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.intonation,
              FeedbackDimension.articulation,
            ],
          ),
          JazzExercise(
            id: 'foundation-overtone-bridge',
            title: 'Overtone Ladder and Voicing',
            category: ExerciseCategory.technique,
            goal: 'ربط low register بالـ overtone control وتحسين voicing.',
            minutes: 12,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 48, maxBpm: 66),
            targetConcepts: [
              'overtone exercises',
              'voicing',
              'low register control',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Voicing Match',
                description:
                    'قدرتك على إخراج overtone نظيفة من fingered fundamental واحد.',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Partial Accuracy',
                description: 'الوصول للـ partial المطلوب بدون كسر أو forcing.',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع partials',
                description:
                    'استمع للفارق بين fundamental والـ overtone الأعلى قبل المحاولة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم voicing',
                description:
                    'الفرق يأتي من shape داخلي للهواء واللسان، لا من ضغط زائد على الريشة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ الـ partial',
                description:
                    'غنّ النغمة الأعلى التي تريد إنتاجها قبل عزفها من نفس fingering.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف ladder',
                description:
                    'ابدأ بـ low Bb أو B ثم اصعد إلى overtone أعلى بشكل تدريجي.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل مقارنة',
                description:
                    'سجّل fundamental ثم overtone وقارن الاستقرار والزمن للوصول.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم نظافة الانتقال',
                description:
                    'هل خرجت overtone مباشرة أم مع crack أو pitch bend غير مضبوط؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'أعد على tempo أبطأ',
                description:
                    'إن كانت overtone غير مستقرة، قلل السرعة وارجع إلى partial أقل.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.intonation,
            ],
          ),
          JazzExercise(
            id: 'foundation-ballad-colors',
            title: 'Ballad Colors: Vibrato, Subtone, Growl, Falls & Scoops',
            category: ExerciseCategory.technique,
            goal:
                'تطوير ألوان تعبيرية مضبوطة: vibrato control, subtone, controlled growl, falls, scoops, doits.',
            minutes: 14,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
            ],
            concertKey: 'Eb',
            writtenKeyForBbSax: 'F',
            writtenKeyForEbSax: 'C',
            tempoRange: TempoRange(minBpm: 54, maxBpm: 84),
            targetConcepts: [
              'vibrato control',
              'subtone for ballads',
              'controlled growl',
              'falls',
              'scoops',
              'doits',
            ],
            backingTrack: BackingTrack(
              id: 'foundation-ballad-pad',
              title: 'Ballad Pad in Concert Eb',
              tempo: 60,
              timeSignature: '4/4',
              formDescription: 'Open ballad vamp',
              styleLabel: 'Ballad',
              keyCenter: 'Eb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Color Control',
                description:
                    'هل تغير اللون التعبيري تحت السيطرة أم أصبح rough بلا قصد؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Ornament Shape',
                description: 'هل الـ scoop أو fall له بداية ونهاية واضحتان؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع ballad color',
                description:
                    'استمع لنهاية phrase ballad فيها subtone خفيف وvibrato متدرج ثم fall قصير.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم وظيفة اللون',
                description:
                    'هذه الزخارف ليست مؤثرات عشوائية؛ كل واحدة تخدم نهاية phrase أو accent عاطفي.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ شكل الزخرفة',
                description:
                    'قلّد بصوتك الـ scoop ثم الـ fall لتسمع shape الحركة قبل عزفها.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'طبّق color set',
                description:
                    'اعزف phrase قصيرة 4 مرات: مرة vibrato فقط، مرة subtone، مرة scoop/fall، مرة growl مضبوط.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'لوّن نهاية الجملة',
                description:
                    'ارتجل جملة ballad قصيرة واستخدم لونًا تعبيريًا واحدًا فقط بوضوح.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل مقارنة الألوان',
                description: 'قارن أي take كانت أكثر musical وأقل مبالغة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم التحكم',
                description: 'هل بقي مركز النغمة واضحًا رغم إضافة الـ color؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'كرّر بلون أقل',
                description:
                    'إذا كان اللون مبالغًا فيه، ارجع لمستوى subtler ثم ابنِ منه.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'foundation-technique-logic',
        title: 'Technique Map',
        summary:
            'Scales, arpeggios, intervals, finger speed, alternate fingerings, palm keys, low register، ثم altissimo لاحقًا.',
        keyTakeaways: [
          'التقنية ليست سرعة فقط؛ بل clarity + timing + efficient motion',
          'الـ palm keys والـ low register يحتاجان نفس قدر الوعي الذي تعطيه للـ middle register',
        ],
        exercises: [
          JazzExercise(
            id: 'foundation-major-scale-grid',
            title: 'Major Scale Grid',
            category: ExerciseCategory.technique,
            goal: 'بناء major scales نظيفة عبر التيمبو والريجستر.',
            minutes: 12,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 60, maxBpm: 132),
            targetConcepts: [
              'major scales',
              'finger speed',
              'time accuracy',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Subdivision Consistency',
                description: 'ثبات الثمنات عبر الصعود والهبوط.',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Clean Connection',
                description:
                    'هل الانتقال بين الأصابع نظيف أم فيه clicks غير مرغوبة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع pulse ثابت',
                description:
                    'استمع للصعود والهبوط في scale على pulse واضح قبل العزف.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم grid',
                description:
                    'اعرف أين يقع الجذر، 3rd، 5th، و7th داخل السلم قبل السرعة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ درجات السلم',
                description: 'غنّ 1-2-3-4-5-6-7-1 قبل عزفه.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف scale grid',
                description:
                    'اعزف major scale في ثمنات ثم ثلاثيات ثم patterns 1-2-3-5.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل أسرع tempo نظيف',
                description:
                    'احتفظ بأعلى tempo بقي فيه sound والـ pulse واضحين.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الوضوح',
                description: 'هل تأخرت أصابعك أم سبق لسانك؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'أعد من tempo أقل',
                description:
                    'إن فقدت clarity، انزل 8 BPM وأعد بنفس الـ subdivision.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.articulation,
              FeedbackDimension.intonation,
            ],
          ),
          JazzExercise(
            id: 'foundation-arpeggio-register-control',
            title: 'Arpeggios, Intervals, Palm Keys & Low Register',
            category: ExerciseCategory.technique,
            goal:
                'ربط arpeggios وintervals بالسيطرة على palm keys والـ low register مع alternate fingerings عند الحاجة.',
            minutes: 14,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 56, maxBpm: 120),
            targetConcepts: [
              'arpeggios',
              'intervals',
              'palm keys',
              'low register control',
              'alternate fingerings',
              'altissimo later',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Register Match',
                description:
                    'هل بقي اللون متماسكًا بين low register وpalm keys؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Leap Accuracy',
                description:
                    'هل القفزات intervallic وصلت مباشرة أم احتاجت adjustment؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع القفزات',
                description:
                    'استمع لفرق اللون بين low note وpalm key note داخل arpeggio واحد.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم fingering choice',
                description:
                    'بعض alternate fingerings تخدم intonation أو speed، لا تستخدمها عشوائيًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف arpeggio intervals',
                description:
                    'اعزف triad و7th arpeggios مع قفزات 3rd و4th و5th وoctave.',
                minutes: 6,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل register pass',
                description:
                    'سجّل سلسلة تصعد إلى palm keys ثم تعود إلى low register.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الانتقال',
                description:
                    'هل هناك squeeze في palm keys أو air drop في low register؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'ثبّت قبل altissimo',
                description:
                    'لا تنتقل إلى altissimo قبل ثبات هذه المنطقة بوضوح.',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.intonation,
              FeedbackDimension.articulation,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'foundation-articulation-logic',
        title: 'Articulation Language',
        summary:
            'Tongue placement, legato, staccato, jazz articulation, ghosted notes, accents، والزخارف المرتبطة بالبداية والنهاية.',
        keyTakeaways: [
          'مكان اللسان يغيّر attack أكثر من القوة',
          'الجاز articulation ليست staccato أو legato فقط، بل shape كاملة للجملة',
        ],
        exercises: [
          JazzExercise(
            id: 'foundation-attack-map',
            title: 'Tongue Placement, Legato & Staccato Map',
            category: ExerciseCategory.technique,
            goal:
                'بناء control في attack بين legato وstaccato على نفس المادة النغمية.',
            minutes: 10,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 62, maxBpm: 112),
            targetConcepts: [
              'tongue placement',
              'legato',
              'staccato',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Attack Consistency',
                description: 'هل بداية كل نغمة واضحة بدون slap أو puff؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الفرق',
                description:
                    'استمع لنفس pattern مرة legato ومرة staccato مع نفس pulse.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم موضع اللسان',
                description:
                    'الهجوم يأتي من tip placement خفيف، لا من ضغط مبالغ فيه.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف pattern مزدوج',
                description:
                    'اعزف 4 نغمات legato ثم 4 staccato بنفس tempo والنبرة.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل attack check',
                description:
                    'راجع هل اختلف الـ tone عندما تغيّرت articulation.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم النظافة',
                description:
                    'هل كل attack واضح ومتزن أم هناك نغمات متأخرة أو قاسية؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'خفف السرعة',
                description:
                    'إن اختلطت articulations، انزل tempo وابق على نفس الـ pattern.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.articulation,
              FeedbackDimension.timeFeel,
            ],
          ),
          JazzExercise(
            id: 'foundation-jazz-articulation-cell',
            title: 'Jazz Articulation, Ghost Notes, Accents, Falls & Scoops',
            category: ExerciseCategory.rhythm,
            goal:
                'تحويل phrase بسيطة إلى جملة جازية عبر accents وghosts وshape النهايات.',
            minutes: 12,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 88, maxBpm: 148),
            targetConcepts: [
              'jazz articulation',
              'ghosted notes',
              'accents',
              'falls',
              'scoops',
              'doits',
            ],
            backingTrack: BackingTrack(
              id: 'foundation-medium-swing-bb',
              title: 'Medium Swing in Concert Bb',
              tempo: 120,
              timeSignature: '4/4',
              formDescription: '8-bar swing vamp',
              styleLabel: 'Medium Swing',
              keyCenter: 'Bb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: 'Swing Placement',
                description:
                    'هل الـ ghosts والـ accents يخدمان placement بدل تشويشه؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Phrase Shape',
                description: 'هل النهاية فيها fall/scoop/doit موسيقي أم مفتعل؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع articulation cell',
                description:
                    'استمع لphrase قصيرة ولاحظ أين accent وأين ghosted note.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم shape الجملة',
                description:
                    'المهم ليس كل note وحدها، بل كيف توجّه accents الأذن داخل الجملة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ accents',
                description:
                    'صفّق pulse وغنّ نفس الجملة مع accent واضح وghost ناعم.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف cell',
                description:
                    'اعزف الجملة كما هي، ثم غيّر النهاية بـ fall أو scoop أو doit.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل بجملة واحدة',
                description:
                    'خذ نفس الـ articulation shape وطبّقه على motif جديدة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل phrase swing',
                description:
                    'سجّل 2 chorus قصيرين وقارن أيهما swing أكثر دون over-articulation.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم placement',
                description:
                    'هل accent على المكان الصحيح أم جاءت الجملة stiff؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.swingPlacement,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'foundation-breathing-logic',
        title: 'Breathing & Phrase Support',
        summary:
            'Phrase length, breath marks, support, air speed, breath planning.',
        keyTakeaways: [
          'التنفس لا يُدار عند نهاية النفس فقط، بل قبل الجملة',
          'air speed والـ support يحددان ثبات tone والphrase length',
        ],
        exercises: [
          JazzExercise(
            id: 'foundation-breath-mapping',
            title: 'Phrase Length & Breath Planning',
            category: ExerciseCategory.technique,
            goal:
                'تخطيط النفس داخل جملة واضحة مع breath marks وair speed ثابتة.',
            minutes: 11,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 56, maxBpm: 92),
            targetConcepts: [
              'phrase length',
              'breath marks',
              'support',
              'air speed',
              'breath planning',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Air Support',
                description: 'هل بقي الصوت مدعومًا حتى آخر الجملة؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Phrase Completion',
                description:
                    'هل انتهت الجملة موسيقيًا أم انهارت بسبب نفَس متأخر؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع طول الجملة',
                description:
                    'استمع إلى جملة 8 عدات وحدد أين يوجد breath mark الطبيعي.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'خطط النفس',
                description:
                    'حدد أماكن التنفس قبل العزف ولا تتركها للحظة التعب.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ مع النفس',
                description: 'غنّ الجملة وخذ النفس في المكان المخطط نفسه.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف phrase كاملة',
                description:
                    'اعزف الجملة مرتين: مرة بنفس مخطط، ومرة بنفس أبطأ مع air speed أوضح.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل نهاية الجملة',
                description: 'هل آخر note بقيت مدعومة أم ضعفت لأن النفس انتهى؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الـ support',
                description:
                    'راجع إن كان breath mark في مكان موسيقي أم قاطع للفكرة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'أعد بخطة أوضح',
                description:
                    'إذا انكسرت الجملة، قصّرها أولاً ثم زد طولها تدريجيًا.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.jazzTheoryCore,
    title: 'Jazz Theory Core',
    shortLabel: 'Theory',
    summary:
        'فهم harmony, guide tones, chord construction, chord-scale color، من خلال السمع والتطبيق داخل الجملة لا الحفظ المجرد.',
    whyItMatters:
        'النظرية هنا ليست معلومات حفظ، بل خريطة سمعية وعملية تقود القرار أثناء العزف والارتجال.',
    objectives: [
      'سماع الـ intervals والـ chord qualities قبل تسميتها',
      'بناء chords من triads إلى tensions مع وعي بوظيفة كل degree',
      'تعلم chord-scale relationships بترتيب: chord sound → guide tones → chord tones → passing tones → scale color',
    ],
    modules: [
      JazzLessonModule(
        id: 'theory-interval-hearing',
        title: 'Intervals through Sound and Phrase',
        summary:
            'الـ interval تُدرَّس كصوت وحركة وجملة: اسمعها، غنِّها، اعزفها من جذور مختلفة، ثم ضعها داخل phrase.',
        keyTakeaways: [
          'الـ interval ليست اسمًا على الورق بل مسافة سمعية لها طابع واضح',
          'قبل بناء chord أو line قوية، يجب أن تسمع اتجاه المسافة داخليًا',
        ],
        exercises: [
          JazzExercise(
            id: 'theory-interval-call-shape',
            title: 'Hear, Sing, Play, Phrase Intervals',
            category: ExerciseCategory.theory,
            goal:
                'تمييز interval سمعيًا، غناؤها، عزفها من جذور مختلفة، ثم استخدامها داخل phrase قصيرة.',
            minutes: 14,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 56, maxBpm: 104),
            targetConcepts: [
              'intervals',
              'ear training',
              'phrase application',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Interval Accuracy',
                description:
                    'هل تسمع وتغني وتعزف نفس المسافة بدقة من أكثر من starting note؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Phrase Use',
                description:
                    'هل استخدمت الـ interval كفكرة موسيقية أم كقفزة عشوائية فقط؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع المسافة',
                description:
                    'استمع إلى 3rd, 4th, 5th, و6th كألوان مختلفة، وحدد هل الحركة ضيقة أم مفتوحة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم وظيفة الـ interval',
                description:
                    'اعرف كيف تغيّر 3rd صغيرة/كبيرة معنى الجملة، وكيف تصنع 4th و5th إحساسًا مختلفًا في الخط.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّها من جذور مختلفة',
                description:
                    'غنّ نفس الـ interval من 4 starting notes مختلفة قبل عزفها.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف الـ interval map',
                description:
                    'اعزف المسافة نفسها صعودًا وهبوطًا من أكثر من root، ثم انقلها إلى 3 مفاتيح أخرى.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ضعها داخل phrase',
                description:
                    'ابنِ phrase من 4 إلى 6 نغمات يكون فيها الـ interval هي الفكرة الأساسية.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل phrase intervallic',
                description:
                    'سجّل take قصيرة وتأكد أن السامع يستطيع سماع القفزة كفكرة متكررة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم السمع والتطبيق',
                description:
                    'هل بقيت المسافة نفسها صحيحة بعد تغيير الجذر والسياق؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
              FeedbackDimension.intonation,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'theory-chord-construction',
        title: 'Chord Construction from Triads to Tensions',
        summary:
            'من major/minor/diminished/augmented triads إلى 7ths و9ths و11ths و13ths والتوترات المعدّلة، من خلال السمع والبناء العملي.',
        keyTakeaways: [
          'الـ chord تُسمع كجودة صوتية قبل أن تُكتب كرمز',
          'امتداد 9 أو #11 أو b13 لا قيمة له إذا لم تُسمع علاقته بالـ guide tones والجذر',
        ],
        exercises: [
          JazzExercise(
            id: 'theory-triad-seventh-builder',
            title: 'Triads, 7ths and Tension Families',
            category: ExerciseCategory.theory,
            goal:
                'تعلم بناء وسماع major/minor/diminished/augmented triads ثم maj7, m7, dominant 7, m7b5, dim7, 9, 11, 13, b9, #9, #11, b13.',
            minutes: 16,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 52, maxBpm: 96),
            targetConcepts: [
              'major triad',
              'minor triad',
              'diminished triad',
              'augmented triad',
              'maj7',
              'm7',
              'dominant 7',
              'm7b5',
              'dim7',
              '9',
              '11',
              '13',
              'b9',
              '#9',
              '#11',
              'b13',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Chord Tone Accuracy',
                description:
                    'هل تبني chord tones وextensions الصحيحة من دون الخلط بين qualities؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Quality Hearing',
                description:
                    'هل تسمع الفرق بين maj7 وdominant 7 وm7b5 وdim7 كألوان مستقلة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع جودة الـ chord',
                description:
                    'استمع للفرق بين major, minor, diminished, augmented، ثم استمع لاختلاف maj7, m7, dominant 7, m7b5, dim7.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'ابنِ الـ chord',
                description:
                    'كوّن كل chord degree-by-degree: 1-3-5 ثم أضف 7th ثم tensions المناسبة أو المعدّلة.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ البناء الداخلي',
                description:
                    'غنّ 1-3-5-7 ثم tension المستهدفة حتى تسمع وظيفة كل degree داخل الصوت العام.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف stack to line',
                description:
                    'اعزف chord tones كـ arpeggio ثم حوّلها إلى line قصيرة من 5 أو 6 نغمات.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'لوّن chord واحدة',
                description:
                    'على vamp ثابتة، استخدم maj7 أو dominant 7 أو m7b5 مع tension واحدة واضحة في كل مرة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل quality check',
                description:
                    'سجّل 3 takes، كل واحدة تبرز جودة chord مختلفة بوضوح.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الجودة',
                description:
                    'هل سُمعت quality والـ tension المقصودة بوضوح أم بدا الخط scale-like فقط؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
              FeedbackDimension.intonation,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'theory-chord-scale-relationships',
        title:
            'Chord Sound → Guide Tones → Chord Tones → Passing Tones → Scale Color',
        summary:
            'تعليم chord-scale relationships بترتيب سمعي وتطبيقي صحيح، لا على شكل “هذه scale فوق هذا chord” فقط.',
        keyTakeaways: [
          'قبل أي scale color، يجب أن تسمع 3rd و7th وresolution بوضوح',
          'في dominant harmony خصوصًا، tensions مثل b9 و#9 وb13 تُدرَّس كصوت وحلّ وليس كحفظ أسماء فقط',
        ],
        exercises: [
          JazzExercise(
            id: 'theory-guide-tone-to-color',
            title: 'Guide Tones before Scale Color',
            category: ExerciseCategory.theory,
            goal:
                'تعلم Maj7 → Ionian/Lydian, m7 → Dorian, dominant 7 → Mixolydian من خلال sound-first logic.',
            minutes: 15,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 60, maxBpm: 118),
            targetConcepts: [
              'Maj7 → Ionian / Lydian',
              'm7 → Dorian',
              'dominant 7 → Mixolydian',
              'guide tones',
              'chord tones',
              'passing tones',
              'scale color',
            ],
            backingTrack: BackingTrack(
              id: 'theory-major-minor-dominant-vamp',
              title: 'Maj7 / m7 / dominant 7 vamp',
              tempo: 84,
              timeSignature: '4/4',
              formDescription: 'Three-chord vamp cycling through qualities',
              styleLabel: 'Medium Swing',
              keyCenter: 'C',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Guide-Tone Priority',
                description:
                    'هل تبدأ line من sound of the chord أم تقفز مباشرة إلى scale notes بلا anchor؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Color Timing',
                description:
                    'هل أضفت passing tones وscale color بعد تثبيت chord sound، أم اختلطت الأولويات؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع جودة كل chord',
                description:
                    'استمع إلى Maj7 ثم m7 ثم dominant 7 وحدد الفرق قبل ذكر أي scale name.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'ابدأ بالـ guide tones',
                description:
                    'حدّد 3rd و7th أولًا، ثم chord tones، ثم passing tones، ثم Ionian/Lydian أو Dorian أو Mixolydian color.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ 3rd و7th',
                description:
                    'غنّ guide tones ثم أضف 9 أو #11 أو 13 كـ color بعد تثبيت السمع الأساسي.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف من الداخل للخارج',
                description:
                    'اعزف guide tones فقط، ثم chord tones، ثم passing tones، ثم أضف scale color في آخر pass.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل بمستويات',
                description:
                    'خذ chorus واحدة guide tones فقط، والثانية chord tones، والثالثة color notes محسوبة.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم المنطق',
                description:
                    'هل line لا تزال توضّح الـ chord sound بدون backing track حتى بعد إضافة color؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'ارجع خطوة للداخل',
                description:
                    'إن اختلطت الألوان، ارجع إلى guide tones ثم ابنِ منها من جديد.',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
          JazzExercise(
            id: 'theory-dominant-altered-resolution',
            title: 'Dominant Color and Resolution Logic',
            category: ExerciseCategory.theory,
            goal:
                'تعلم dominant 7 → Altered / Lydian Dominant / Half-Whole diminished، وm7b5 → Locrian / Locrian natural 2، وdim7 → Diminished scale من خلال resolution logic.',
            minutes: 16,
            difficulty: DifficultyLevel.advanced,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 56, maxBpm: 126),
            targetConcepts: [
              'dominant 7 → Altered',
              'dominant 7 → Lydian Dominant',
              'dominant 7 → Half-Whole diminished',
              'm7b5 → Locrian / Locrian natural 2',
              'dim7 → Diminished scale',
              '3rd',
              '7th',
              'b9',
              '#9',
              'b13',
              'resolution',
            ],
            backingTrack: BackingTrack(
              id: 'theory-dominant-resolution-vamp',
              title: 'Dominant Resolution Vamp',
              tempo: 96,
              timeSignature: '4/4',
              formDescription: 'Resolving dominant vamp into tonic minor/major',
              styleLabel: 'Medium-Up Swing',
              keyCenter: 'F',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Resolution Clarity',
                description:
                    'هل سُمعت 3rd و7th والتوترات مثل b9/#9/b13 وهي تتحلل إلى tonic بوضوح؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Color Function',
                description:
                    'هل استُخدمت altered colors كحلّ functional أم كخارجية بلا اتجاه؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع التوتر والحل',
                description:
                    'استمع إلى dominant line فيها 3rd, 7th, b9, #9, b13 ثم resolution واضح إلى tonic.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'رتّب الأولويات',
                description:
                    'لا تبدأ بالـ altered scale كاملة. ابدأ بـ 3rd و7th، ثم اسمع b9/#9/b13، ثم resolution، وبعدها scale color.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ التوترات قبل الحل',
                description:
                    'غنّ 3rd و7th ثم b9 أو #9 أو b13، ثم غنّ كيف تتحلل كل واحدة إلى tonic note.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف color ladder',
                description:
                    'اعزف line من guide tones ثم أضف altered color واحدة في كل مرة قبل حلها.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل dominant logic',
                description:
                    'على vamp، اعمل 4 takes: Mixolydian، ثم Lydian Dominant، ثم Altered، ثم Half-Whole diminished، مع resolution دائمًا.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل color resolution',
                description:
                    'سجّل أي take وأغلق عينيك: هل تسمع tension and release بوضوح؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الوظيفة',
                description:
                    'هل بقي الـ line functional أم تحولت إلى scale run بلا direction؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.swingRhythmEngine,
    title: 'Swing & Rhythm Engine',
    shortLabel: 'Time',
    summary:
        'الـ quarter-note pulse، metronome on 2 and 4، off-beat placement، triplet subdivision، swing eighths، anticipation، syncopation، وtime placement عبر الأساليب والسرعات المختلفة.',
    whyItMatters:
        'العازف قد يعرف النغمات الصحيحة لكنه يخسر الجاز كله إذا ضاع الـ time feel؛ والسوينغ ليس ratio ثابتة بل إحساس يتغير مع التيمبو والحقبة والـ rhythm section.',
    objectives: [
      'تثبيت quarter note pulse حتى من دون عزف نغمات كثيرة',
      'تعلم metronome on 2 and 4 كمرجع داخلي لا كسند خارجي فقط',
      'فهم swing feel حسب التيمبو: أوسع في البطيء، أوضح في المتوسط، وأقرب للاستقامة في السريع',
      'ضبط anticipation, syncopation, behind the beat, on top of the beat, laid-back phrasing',
    ],
    modules: [
      JazzLessonModule(
        id: 'swing-pulse-and-metronome',
        title: 'Quarter Note Pulse & Metronome on 2 and 4',
        summary:
            'بناء pulse داخلي حقيقي قبل أي تعقيد rhythmic، مع metronome على 2 و4 كمرآة لإحساس السوينغ.',
        keyTakeaways: [
          'الـ quarter note هي العمود الفقري للسوينغ، لا الثمنات فقط',
          'الـ metronome على 2 و4 يختبر إحساسك الداخلي ولا يقوده بالنيابة عنك',
        ],
        exercises: [
          JazzExercise(
            id: 'swing-pulse-ladder',
            title: 'Quarter Pulse Ladder',
            category: ExerciseCategory.rhythm,
            goal:
                'تثبيت quarter note pulse، ثم نقلها إلى clap back ثم note واحدة ثم scale ثم improvisation rhythm.',
            minutes: 14,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 50, maxBpm: 96),
            targetConcepts: [
              'quarter note pulse',
              'metronome on 2 and 4',
              'consistency of pulse',
            ],
            rhythmTrainerModes: [
              RhythmTrainerMode.clapBack,
              RhythmTrainerMode.playBackOneNote,
              RhythmTrainerMode.playRhythmUsingScale,
              RhythmTrainerMode.improviseTwoBarsSameRhythm,
            ],
            feelNotes: [
              'في التيمبو البطيء يجب أن يبقى الـ pulse عميقًا وثابتًا دون rush بين النبضات.',
              'ضع المترونوم على 2 و4 واستمع هل أنت تتنفس معه أم تلاحقه.',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Pulse Consistency',
                description:
                    'هل بقيت الأرباع ثابتة عندما انتقلت من clap إلى sax؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: '2 & 4 Lock',
                description:
                    'هل شعرت أن الـ click هو 2 و4 حقًا أم ما زلت تتعامل معه كـ 1 و3؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع quarter pulse',
                description:
                    'استمع للـ ride feel ولاحظ كيف تحمل الـ quarter note الزمن حتى عندما لا تُسمع كل subdivisions.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم 2 و4',
                description:
                    'ضع المترونوم على 2 و4 واعرف أن المطلوب ليس مطابقة click فقط بل بناء beat 1 و3 داخليًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ pulse مع العد',
                description:
                    'غنّ count داخليًا مع التشديد السمعي على 2 و4 قبل التصفيق أو العزف.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'نفّذ Rhythm Trainer',
                description:
                    'Mode 1 clap back، Mode 2 note واحدة، Mode 3 scale، Mode 4 improvise 2 bars بنفس rhythm.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل pulse check',
                description:
                    'راجع هل هجومك مبكر أم متأخر وهل بقيت الـ note durations متساوية.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الثبات',
                description:
                    'هل حافظت على نفس pulse عبر كل modes أم تغيّرت بمجرد إضافة نغمات؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.swingPlacement,
              FeedbackDimension.articulation,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'swing-subdivision-and-feel',
        title: 'Subdivision, Swing Eighths and Tempo-Dependent Feel',
        summary:
            'السوينغ ليست triplet ratio ثابتة؛ في البطيء تكون أوسع، وفي المتوسط أوضح، وفي السريع أقرب للثمنات المستقيمة.',
        keyTakeaways: [
          'السوينغ تتغير حسب tempo, style, era, player, phrase, rhythm section feel',
          'التعامل مع swing eighths كرقم جامد يقتل الإحساس بدلاً من تدريبه',
        ],
        exercises: [
          JazzExercise(
            id: 'swing-ratio-by-tempo',
            title: 'Swing Feel across Slow, Medium and Fast Tempos',
            category: ExerciseCategory.rhythm,
            goal:
                'تمييز كيف تتغير swing eighths بين slow, medium, fast بدون حبسها في ratio واحد.',
            minutes: 16,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 58, maxBpm: 220),
            targetConcepts: [
              'triplet subdivision',
              'swing eighths',
              'tempo-dependent swing feel',
              'off-beat eighth notes',
            ],
            rhythmTrainerModes: [
              RhythmTrainerMode.clapBack,
              RhythmTrainerMode.playBackOneNote,
              RhythmTrainerMode.improviseTwoBarsSameRhythm,
            ],
            feelNotes: [
              'Slow tempos: wider swing feel, more buoyant triplet pull.',
              'Medium tempos: clear swing subdivision without exaggeration.',
              'Fast tempos: straighter eighth-note flow with lighter separation.',
            ],
            backingTrack: BackingTrack(
              id: 'swing-tempo-ladder',
              title: 'Tempo Ladder Swing Loop',
              tempo: 120,
              timeSignature: '4/4',
              formDescription:
                  'Loop switches between slow, medium, and fast swing',
              styleLabel: 'Swing Tempo Ladder',
              keyCenter: 'Bb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: 'Swing Ratio Choice',
                description:
                    'هل تغيّر إحساس الثمنات مع التيمبو بشكل musical أم ظل ثابتًا بشكل مصطنع؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Off-Beat Placement',
                description:
                    'هل الأوف-بيت تقع في المكان الصحيح أم أصبحت rushed أو dragged؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع اختلاف السوينغ',
                description:
                    'استمع إلى نفس الخلية في slow ثم medium ثم fast ولاحظ كيف تضيق/تتسع المسافة بين الثمنات.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم متغيرات feel',
                description:
                    'السوينغ تتغير حسب tempo والـ rhythm section؛ لا تحفظها كنسبة واحدة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ subdivision',
                description:
                    'غنّ نفس rhythm في 3 tempi مختلفة مع تعديل واضح في الإحساس.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف one-note swing ladder',
                description:
                    'اعزف نفس rhythm على note واحدة في slow, medium, fast مع تعديل الـ feel لا مجرد السرعة.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل نفس rhythm',
                description:
                    'خذ نفس rhythm في كل tempo وبدّل فقط النغمات أو direction.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الإحساس',
                description:
                    'هل أصبحت fast phrases straight enough without losing swing؟ وهل ظل slow feel واسعًا من دون ثقل؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.swingPlacement,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'swing-anticipation-and-syncopation',
        title: 'Anticipation, Syncopation and Placement',
        summary:
            'تدريب anticipation وsyncopation وplacement: behind the beat, on top of the beat, laid-back phrasing.',
        keyTakeaways: [
          'الـ anticipation يجب أن تشد الخط للأمام من غير أن تكسره',
          'behind the beat وon top of the beat كلاهما صالحان موسيقيًا إذا كان الـ pulse الداخلي ثابتًا',
        ],
        exercises: [
          JazzExercise(
            id: 'swing-placement-modes',
            title:
                'Placement Modes: Anticipation, Syncopation, Behind/Top/Laid-Back',
            category: ExerciseCategory.rhythm,
            goal:
                'تعلم تحريك phrase داخل beat مع الحفاظ على pulse والـ articulation والـ duration.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 72, maxBpm: 168),
            targetConcepts: [
              'anticipation',
              'syncopation',
              'behind the beat',
              'on top of the beat',
              'laid-back phrasing',
            ],
            rhythmTrainerModes: [
              RhythmTrainerMode.clapBack,
              RhythmTrainerMode.playBackOneNote,
              RhythmTrainerMode.playRhythmUsingScale,
              RhythmTrainerMode.improviseTwoBarsSameRhythm,
            ],
            feelNotes: [
              'On top of the beat is energetic, not rushed.',
              'Behind the beat is relaxed, not late and collapsing.',
              'Laid-back phrasing still sits on a strong inner quarter-note pulse.',
            ],
            backingTrack: BackingTrack(
              id: 'swing-placement-vamp',
              title: 'Placement Training Vamp',
              tempo: 132,
              timeSignature: '4/4',
              formDescription:
                  '8-bar swing vamp for anticipation and syncopation',
              styleLabel: 'Medium-Up Swing',
              keyCenter: 'F',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Early/Late Attack Control',
                description:
                    'هل تعرف متى دخلت مبكرًا أو متأخرًا وهل كان ذلك intentional أم لا؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: 'Placement Character',
                description:
                    'هل phrase on top / behind / laid-back تحمل شخصية واضحة من دون فقدان pulse؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Duration and Attack Shape',
                description:
                    'هل بقيت durations والـ accents والـ releases دقيقة مع تغير placement؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع placement shifts',
                description:
                    'استمع لنفس الخلية مرة anticipated، مرة syncopated، مرة laid-back، ومرة on top.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'سمِّ الإحساس',
                description:
                    'حدد هل الهجوم مبكر intentional، أم خلف الـ beat، أم فقط متأخر وغير متحكم فيه.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ نفس rhythm بمواضع مختلفة',
                description:
                    'غنّ rhythm مرة strict، ثم anticipated، ثم laid-back مع نفس الـ pulse الداخلي.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'نفّذ Rhythm Trainer الكامل',
                description:
                    'Mode 1 clap back، Mode 2 one note، Mode 3 scale، Mode 4 improvise 2 bars بنفس rhythm.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل placement comparison',
                description:
                    'سجّل 4 takes: straight placement, anticipated, behind, laid-back.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'حلّل الهجمات والزمن',
                description:
                    'راجع early attacks, late attacks, offbeat placement, note duration, swing ratio, consistency of pulse, articulation accuracy.',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.swingPlacement,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.bluesCurriculum,
    title: 'Blues Curriculum',
    shortLabel: 'Blues',
    summary:
        'البلوز pillar مركزية تبني form, language, call-and-response, guide tones, repetition, motivic development, space, phrase endings, وصوت الساكسفون الغنائي.',
    whyItMatters:
        'البلوز ليست side lesson؛ هي قلب اللغة الجازية، ومنها يتعلم العازف form, groove, voice-leading, motivic logic, and vocal phrasing.',
    objectives: [
      'فهم Basic 12-Bar Blues ثم Jazz Blues ثم Bebop Blues ثم Minor Blues',
      'تطوير language تشمل: minor pentatonic, major pentatonic, blues scale, mixolydian, bebop dominant, guide tones',
      'بناء call and response, repetition, motivic development, space, phrase endings, vocal saxophone phrasing',
      'استخدام backing tracks وoriginal blues etudes للتطبيق، لا حفظ licks معزولة فقط',
    ],
    modules: [
      JazzLessonModule(
        id: 'blues-level-1-basic',
        title: 'Level 1: Basic 12-Bar Blues',
        summary:
            'I7 | I7 | I7 | I7 · IV7 | IV7 | I7 | I7 · V7 | IV7 | I7 | V7. تأسيس form واضحة، call-response، واللغة الأولية.',
        keyTakeaways: [
          'الجملة البلوزية القوية تبدأ من form واضحة قبل كثرة النغمات',
          'minor pentatonic وmajor pentatonic وblues scale أدوات، لكن العبارة أهم من السلم نفسه',
        ],
        exercises: [
          JazzExercise(
            id: 'blues-basic-call-response',
            title: 'Basic Blues Call, Response and Space',
            category: ExerciseCategory.improvisation,
            goal:
                'تعلم form الـ 12-bar الأساسية، ثم استخدام call and response, repetition, space, phrase endings، وصوت ساكسفون غنائي داخل البلوز البسيط.',
            minutes: 16,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 72, maxBpm: 136),
            targetConcepts: [
              'basic 12-bar blues',
              'minor pentatonic',
              'major pentatonic',
              'blues scale',
              'call and response',
              'repetition',
              'space',
              'phrase endings',
              'vocal saxophone phrasing',
            ],
            backingTrack: BackingTrack(
              id: 'blues-basic-f',
              title: 'Basic 12-Bar Blues in Concert F',
              tempo: 98,
              timeSignature: '4/4',
              formDescription: 'Basic blues form in 12 bars',
              styleLabel: 'Medium Shuffle',
              keyCenter: 'F',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Call and Response Shape',
                description:
                    'هل phrase الثانية تجيب فعلاً على الأولى أم أنك تعزف أفكارًا غير مترابطة؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Space and Endings',
                description:
                    'هل تترك فراغًا كافيًا وهل نهايات الجمل تبدو غنائية وواضحة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع form والسؤال/الجواب',
                description:
                    'استمع إلى 12-bar blues بسيطة وحدد أين تنتهي الجملة الأولى وأين تبدأ الإجابة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم 12-bar map',
                description:
                    'سمِّ I7 وIV7 وV7 داخل 12-bar form قبل محاولة أي improvisation.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ الجملة البلوزية',
                description:
                    'غنّ call بسيطة من barين ثم غنّ response مختلفة بنفس الروح.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف motif قصيرة',
                description:
                    'استخدم minor pentatonic أو blues scale لبناء call، ثم رد عليها باستخدام space وphrase ending واضحة.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل chorus واحدة',
                description:
                    'التزم motif واحدة وطورها بالتكرار وتغيير النهاية بدل التنقل العشوائي.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل chorus basic blues',
                description:
                    'سجّل chorus واحدة وتأكد أن form والجملتان واضحتان حتى من دون accompaniment كامل.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الوضوح والغناء',
                description:
                    'هل يمكن ترديد الجملة بعد سماعها مرة واحدة، وهل بقي فيها فراغ وتنفس طبيعي؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.timeFeel,
              FeedbackDimension.phraseShape,
              FeedbackDimension.formAwareness,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'blues-level-2-jazz',
        title: 'Level 2: Jazz Blues',
        summary:
            'I7 | IV7 | I7 | I7 · IV7 | #IVdim | I7 | VI7 · IIm7 | V7 | I7 VI7 | IIm7 V7. تطوير form البلوز إلى لغة جازية أوضح.',
        keyTakeaways: [
          'في Jazz Blues تبدأ الحركة الهارمونية نفسها في تعليم phrase direction',
          'guide tones وmixolydian color أهم من الجري فوق scale كاملة بلا اتجاه',
        ],
        exercises: [
          JazzExercise(
            id: 'blues-jazz-guide-tone-map',
            title: 'Jazz Blues Guide Tones and Turnaround Shape',
            category: ExerciseCategory.improvisation,
            goal:
                'سماع Jazz Blues form، استخدام guide tones وmixolydian color، والتعامل مع #IVdim وVI7 وIIm7-V7 كاتجاهات داخل الخط.',
            minutes: 17,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 88, maxBpm: 152),
            targetConcepts: [
              'jazz blues',
              'guide tones',
              'mixolydian',
              '#IVdim',
              'VI7',
              'ii-V',
              'call and response',
              'motivic development',
            ],
            backingTrack: BackingTrack(
              id: 'blues-jazz-bb',
              title: 'Jazz Blues in Concert Bb',
              tempo: 118,
              timeSignature: '4/4',
              formDescription: 'Jazz blues with #IVdim, VI7 and ii-V movement',
              styleLabel: 'Medium Swing',
              keyCenter: 'Bb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Guide-Tone Motion',
                description:
                    'هل تغيّرت الجملة مع التغييرات الهارمونية أم بقيت pentatonic فوق كل شيء؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Turnaround Awareness',
                description:
                    'هل يبان دخول VI7 وii-V وbar 11-12 في phrase endings؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الحركة',
                description:
                    'استمع إلى انتقال I7 → IV7 → #IVdim → VI7 → ii-V وحدد أين يشتد التوتر وأين يهدأ.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'ارسم guide tones',
                description:
                    'حدد 3rd و7th للـ dominant chords ثم راقب كيف تقودك إلى VI7 ثم ii-V.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ line داخل form',
                description:
                    'غنّ line صغيرة تعبر bars 5-8 ثم bars 9-12 مع إحساس direction واضح.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف form map',
                description:
                    'اعزف chorus فيها أولًا guide tones، ثم chord tones، ثم mixolydian color على الدومينانت.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'طوّر motif عبر form',
                description:
                    'خذ phrase قصيرة وطورها عند #IVdim ثم عند turnaround بدل اختراع فكرة جديدة كل barين.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم direction',
                description: 'هل تشعر فعلًا بأن harmonic motion أثّر في line؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'blues-level-3-bebop',
        title: 'Level 3: Bebop Blues',
        summary:
            'تعلم ii-V insertions, diminished passing chords, tritone substitutions, turnarounds, وbebop dominant language داخل form البلوز.',
        keyTakeaways: [
          'Bebop blues لا تعني كثرة النغمات فقط، بل clarity في harmonic pull',
          'ii-Vs والدومينانت language يجب أن تُسمع كاتجاه وحلّ لا كpatterns محفوظة فقط',
        ],
        exercises: [
          JazzExercise(
            id: 'blues-bebop-dominant-language',
            title: 'Bebop Blues Insertions and Dominant Language',
            category: ExerciseCategory.improvisation,
            goal:
                'استخدام ii-V insertions, diminished passing chords, tritone substitutions, turnarounds, وbebop dominant language داخل blues form أصلية.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 112, maxBpm: 208),
            targetConcepts: [
              'bebop blues',
              'ii-V insertions',
              'diminished passing chords',
              'tritone substitutions',
              'turnarounds',
              'bebop dominant',
              'motivic development',
            ],
            backingTrack: BackingTrack(
              id: 'blues-bebop-f',
              title: 'Bebop Blues in Concert F',
              tempo: 156,
              timeSignature: '4/4',
              formDescription:
                  'Bebop blues with ii-V insertions and turnaround variants',
              styleLabel: 'Up Swing',
              keyCenter: 'F',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Bebop Flow',
                description:
                    'هل الخط يوضح ii-V والـ turnaround والdominant motion أم يبدو كسلسلة patterns منفصلة؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Dominant Language Control',
                description:
                    'هل targets على الـ dominant واضحة قبل إضافة bebop passing notes؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع bebop pull',
                description:
                    'استمع إلى line تستخدم ii-V insertions وdominant motion من غير أن تفقد form البلوز.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم insertion logic',
                description:
                    'حدد أين يدخل ii-V، وأين يوجد diminished passing chord أو tritone substitution، ولماذا يخدم الحركة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ guide tones ثم bebop note',
                description:
                    'غنّ skeleton line أولًا، ثم أضف passing note واحدة أو enclosure حتى لا تضيع الوظيفة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف original etude',
                description:
                    'اعزف etude أصلية قصيرة على form الـ bebop blues، مع تركيز على dominant resolution وturnarounds.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل chorus واحدة',
                description:
                    'استخدم bebop dominant language، لكن احتفظ بفكرة motif واضحة بدل الجري المستمر.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل bebop chorus',
                description:
                    'سجّل chorus واحدة وقارن هل بقيت واضحة form-wise أم اختفت داخل كثافة النغمات.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الوضوح داخل السرعة',
                description:
                    'هل تسمع form, ii-Vs, turnaround, and phrase endings رغم السرعة؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
              FeedbackDimension.earResponse,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'blues-level-4-minor',
        title: 'Level 4: Minor Blues',
        summary:
            'Im7 | IVm7 | Im7 | Im7 · IVm7 | IVm7 | Im7 | Im7 · bVI7 | V7alt | Im7 | V7. بناء لغة minor blues أصلية وغنائية.',
        keyTakeaways: [
          'Minor blues تحتاج dark center واضح مع حلّ قوي في bVI7 وV7alt',
          'vocal sax phrasing والspace مهمان جدًا كي لا تتحول minor blues إلى scale exercise فقط',
        ],
        exercises: [
          JazzExercise(
            id: 'blues-minor-vocal-etude',
            title: 'Minor Blues Vocal Etude',
            category: ExerciseCategory.improvisation,
            goal:
                'بناء لغة minor blues باستخدام minor pentatonic, blues scale, mixolydian على V7, guide tones, phrase endings، وصوت ساكسفون غنائي.',
            minutes: 17,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C minor',
            writtenKeyForBbSax: 'D minor',
            writtenKeyForEbSax: 'A minor',
            tempoRange: TempoRange(minBpm: 68, maxBpm: 144),
            targetConcepts: [
              'minor blues',
              'minor pentatonic',
              'blues scale',
              'mixolydian on V7',
              'guide tones',
              'space',
              'phrase endings',
              'vocal saxophone phrasing',
            ],
            backingTrack: BackingTrack(
              id: 'blues-minor-c',
              title: 'Minor Blues in Concert C minor',
              tempo: 92,
              timeSignature: '4/4',
              formDescription: 'Minor blues with bVI7 and V7alt cadence',
              styleLabel: 'Minor Swing',
              keyCenter: 'C minor',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Vocal Phrase Shape',
                description:
                    'هل line تبدو مغناة وقابلة للترديد أم مجرد scale motion في minor mode؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Cadence Control',
                description:
                    'هل أوضحت bVI7 وV7alt ثم resolution إلى Im7 بشكل مسموع؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع dark center',
                description:
                    'استمع إلى minor blues ولاحظ كيف يختلف مركز الصوت والإحساس عن major/jazz blues.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم cadence',
                description:
                    'حدد دور bVI7 ثم V7 أو V7alt وكيف يعود الخط إلى Im7.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ phrase endings',
                description:
                    'غنّ نهايتين مختلفتين على bars 9-12: واحدة حزينة بسيطة، وأخرى أجرأ مع tension على V7.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف original minor etude',
                description:
                    'اعزف etude أصلية على minor blues تدمج guide tones مع minor pentatonic وblues color.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل بجمل غنائية',
                description:
                    'ارتجل chorus واحدة مع تركيز على space، phrase endings، وvocal saxophone phrasing.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل minor chorus',
                description:
                    'سجّل chorus واحدة واسأل: هل تبدو الجمل غنائية أم محشوة؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الإحساس',
                description:
                    'هل أوضحت form والcadence والهوية الـ minor من غير فقدان blues feel؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
              FeedbackDimension.earResponse,
            ],
          ),
        ],
      ),
    ],
    tunes: [
      TuneStudy(
        id: 'blues-etude-basic-01',
        title: 'Original Basic Blues Etude No. 1',
        focus: '12-bar form + call-response + space',
        whyItMatters:
            'يوفر نقطة دخول أصلية للـ basic blues من غير نسخ solos منشورة.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.beginner,
        skillAreas: [
          SkillArea.blues,
          SkillArea.improvisation,
          SkillArea.rhythm
        ],
        formDescription: 'Basic 12-bar blues study anchor.',
        keyCenters: ['F7', 'Bb7', 'C7'],
        cadences: ['V7 → IV7 → I7'],
        commonProgressions: [
          'I7 | I7 | I7 | I7',
          'IV7 | IV7 | I7 | I7',
          'V7 | IV7 | I7 | V7'
        ],
        guideToneMap: ['Track 3rds and b7ths through I7, IV7 and V7'],
        chordTonePractice: ['Play shells before adding blues scale color'],
        rhythmOnlyImprovisation: ['Improvise one chorus with one note only'],
        motifDevelopmentPrompts: ['Repeat one 2-beat phrase in three places'],
      ),
      TuneStudy(
        id: 'blues-etude-jazz-01',
        title: 'Original Jazz Blues Etude No. 1',
        focus: '#IVdim + VI7 + ii-V movement',
        whyItMatters:
            'يساعد على سماع الحركة الهارمونية داخل Jazz Blues من غير الاكتفاء بالpentatonic.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [
          SkillArea.blues,
          SkillArea.theory,
          SkillArea.improvisation
        ],
        formDescription: 'Jazz blues study anchor with functional movement.',
        keyCenters: ['Bb7', 'Eb7', 'G7', 'Cm7 F7'],
        cadences: ['ii-V → I7 return', '#IVdim passing motion'],
        commonProgressions: [
          'IV7 | #IVdim | I7 | VI7',
          'IIm7 | V7 | I7 VI7 | IIm7 V7'
        ],
        guideToneMap: ['Land 3rds cleanly across VI7 and ii-V movement'],
        chordTonePractice: [
          'Alternate chorus: guide tones only, then arpeggio shells'
        ],
        rhythmOnlyImprovisation: [
          'Keep one motif while bars 5-10 get denser harmonically'
        ],
        motifDevelopmentPrompts: [
          'Reharmonize one blues motif through VI7 and ii-V'
        ],
      ),
      TuneStudy(
        id: 'blues-etude-bebop-01',
        title: 'Original Bebop Blues Etude No. 1',
        focus: 'ii-V insertions + turnarounds + bebop dominant language',
        whyItMatters:
            'يربط الـ bebop motion بالـ blues form بشكل أصلي وغير منسوخ.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.advanced,
        skillAreas: [
          SkillArea.blues,
          SkillArea.improvisation,
          SkillArea.saxLanguage
        ],
        formDescription: 'Bebop blues anchor with denser cadence cells.',
        keyCenters: ['F7', 'Bb7', 'Gm7 C7', 'Am7 D7'],
        cadences: [
          'ii-V insertions',
          'turnaround pressure into the next chorus'
        ],
        commonProgressions: [
          'I7 | IV7 | I7 | VI7',
          'ii-V cells entering bars 9-12'
        ],
        guideToneMap: [
          'Outline every inserted dominant with 3rds and 7ths first'
        ],
        chordTonePractice: [
          'Add approach notes only after cadence targets are audible'
        ],
        rhythmOnlyImprovisation: [
          'Compress rhythms to keep the form intelligible at faster tempos'
        ],
        motifDevelopmentPrompts: [
          'Shrink one motif so it survives denser harmony'
        ],
      ),
      TuneStudy(
        id: 'blues-etude-minor-01',
        title: 'Original Minor Blues Etude No. 1',
        focus: 'minor cadence + vocal phrasing + phrase endings',
        whyItMatters:
            'يحول minor blues من تمرين scales إلى قصة phrasing واضحة.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [SkillArea.blues, SkillArea.tone, SkillArea.improvisation],
        formDescription: 'Minor blues study anchor with vocal phrase shaping.',
        keyCenters: ['C minor', 'F minor', 'Ab7 / G7alt'],
        cadences: ['bVI7 → V7alt → Im7'],
        commonProgressions: [
          'Im7 | IVm7 | Im7 | Im7',
          'bVI7 | V7alt | Im7 | V7'
        ],
        guideToneMap: [
          'Use b3 and b7 as the core sound before adding altered V color'
        ],
        chordTonePractice: [
          'Sustain shell notes across bars 9-12 before ornamenting'
        ],
        rhythmOnlyImprovisation: [
          'Leave more space in the first 8 bars and answer later'
        ],
        motifDevelopmentPrompts: [
          'Use one lament-like motif and vary only the ending'
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.improvisationSystem,
    title: 'Improvisation System',
    shortLabel: 'Improv',
    summary:
        'منطق الارتجال من sound-first: chord sound → chord tones → guide tones → rhythm → approach notes → phrase → keys → progression.',
    whyItMatters:
        'الارتجال ليس اختيار scale والجري بها، بل سماع chord sound ثم بناء جملة تتنفس وتتحرك وتتحلل بوضوح.',
    objectives: [
      'تعلم chord tone soloing من الجذر حتى approach notes',
      'سماع guide tone resolution داخل ii-V-I قبل قراءتها',
      'بناء bebop language أصلية: enclosures, chromatic approaches, delayed resolution, anticipation, turnarounds',
      'توصيل الخطوط بين chords بمنطق linear harmony أصيل',
    ],
    modules: [
      JazzLessonModule(
        id: 'improv-chord-tone-soloing',
        title: 'Chord Tone Soloing',
        summary:
            'ابدأ بصوت الـ chord نفسها: roots, 3rds, 7ths, ثم 3rds-to-7ths, full arpeggios, ثم approach notes.',
        keyTakeaways: [
          'إذا لم تسمع الـ chord sound فلن تنقذك أي scale',
          'كل إضافة جديدة تأتي بعد تثبيت الطبقة السابقة: root ثم 3rd/7th ثم arpeggio ثم approach notes',
        ],
        exercises: [
          JazzExercise(
            id: 'improv-chord-tone-layers',
            title: 'Chord Tone Layers in Progression',
            category: ExerciseCategory.improvisation,
            goal:
                'تعلم الارتجال تدريجيًا: root only → 3rds only → 7ths only → connect 3rds to 7ths → full arpeggios → approach notes.',
            minutes: 16,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 58, maxBpm: 120),
            targetConcepts: [
              'chord sound',
              'roots',
              '3rds',
              '7ths',
              'full arpeggios',
              'approach notes',
            ],
            backingTrack: BackingTrack(
              id: 'improv-chord-tone-vamp',
              title: 'ii-V-I Chord Tone Vamp',
              tempo: 84,
              timeSignature: '4/4',
              formDescription: 'Slow ii-V-I vamp for layered soloing',
              styleLabel: 'Medium Swing',
              keyCenter: 'C',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Chord Tone Priority',
                description:
                    'هل تبني line من داخل الـ chord فعلًا أم تخرج إلى notes عامة بسرعة؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Layer Discipline',
                description:
                    'هل التزمت بالطبقة المطلوبة في كل pass قبل إضافة طبقة جديدة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع صوت الـ chord',
                description:
                    'استمع إلى Dm7 أو G7 أو Cmaj7 كجودة مستقلة قبل التفكير في أي scale.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'رتّب الطبقات',
                description:
                    'ابدأ root only، ثم 3rds only، ثم 7ths only، ثم 3rds-to-7ths، ثم arpeggio، ثم approach note.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ 1-3-5-7',
                description:
                    'غنّ root ثم 3rd ثم 5th ثم 7th لكل chord قبل العزف.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف الطبقات',
                description:
                    'نفّذ 6 passes: roots only، 3rds only، 7ths only، connect 3rds to 7ths، full arpeggios، ثم approach notes.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ابنِ phrase من طبقة واحدة',
                description:
                    'خذ barين فقط واصنع phrase من الطبقة الحالية دون القفز إلى كل شيء مرة واحدة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل layering take',
                description:
                    'سجّل passين مختلفين وقارن هل line الثانية أوضحت harmony أكثر من الأولى.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم المنطق',
                description:
                    'هل وضحت الجملة chord progression حتى مع قلة النغمات؟',
                minutes: 1,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'improv-guide-tone-lines',
        title: 'Guide Tone Lines',
        summary:
            'تعليم voice leading الحقيقي عبر ii-V-I، بحيث يسمع العازف resolution قبل أن يقرأها.',
        keyTakeaways: [
          'الـ guide tone line هي أقصر طريق لسماع harmony من الداخل',
          'F → F → E و C → B → B يجب أن تُسمع كحلّ قبل أن تُحفظ كأحرف',
        ],
        exercises: [
          JazzExercise(
            id: 'improv-guide-tone-resolution',
            title: 'ii-V-I Guide Tone Resolution',
            category: ExerciseCategory.improvisation,
            goal:
                'سماع وعزف 3rd و7th ثم خلق rhythm باستخدامهما ثم إضافة 9th وpassing tones ثم phrase من barين ثم نقلها إلى 12 مفتاحًا ثم progression حقيقية.',
            minutes: 17,
            difficulty: DifficultyLevel.earlyIntermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 52, maxBpm: 126),
            targetConcepts: [
              'guide tone lines',
              'ii-V-I',
              '3rd and 7th',
              'resolution',
              'passing tones',
              '12 keys',
            ],
            backingTrack: BackingTrack(
              id: 'improv-guide-tone-iivi',
              title: 'ii-V-I Resolution Loop',
              tempo: 76,
              timeSignature: '4/4',
              formDescription: 'Looped ii-V-I with space for repeated keys',
              styleLabel: 'Medium Swing',
              keyCenter: 'C',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Resolution Hearing',
                description:
                    'هل تسمع أين تذهب F → F → E و C → B → B أم أنك تقرأها فقط؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Phrase from Skeleton',
                description:
                    'هل بقيت الجملة مبنية على skeleton line بعد إضافة 9th وpassing tones؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع F→F→E و C→B→B',
                description:
                    'استمع إلى line بسيطة على Dm7 → G7 → Cmaj7 وركز في الإحساس بالحل.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد 3rd و7th',
                description:
                    'سمِّ 3rd و7th لكل chord، ثم تتبع كيف تنتقل بأقل حركة ممكنة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ skeleton line',
                description:
                    'غنّ F → F → E ثم C → B → B قبل عزفها، ثم غنِّها بإيقاعات مختلفة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزفها بإيقاعات متعددة',
                description:
                    'اعزف 3rd و7th فقط، ثم أضف 9th، ثم passing tone، ثم ابنِ phrase من barين.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'انقلها عبر المفاتيح',
                description:
                    'خذ phrase barين نفسها عبر 12 keys ثم استخدمها داخل progression حقيقية.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم السمع',
                description:
                    'هل resolution ما زالت واضحة بعد نقل الفكرة إلى مفاتيح أخرى؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'improv-bebop-language',
        title: 'Bebop Language',
        summary:
            'تعليم enclosures, chromatic approaches, bebop scales, delayed resolution, anticipation, turnarounds, وii-V-I vocabulary كمنطق لغوي أصلي.',
        keyTakeaways: [
          'الـ enclosure وسيلة للوصول إلى target note، وليست decorative trick فقط',
          'bebop scale لا تُعزف كجري متواصل بل تخدم target والresolution',
        ],
        exercises: [
          JazzExercise(
            id: 'improv-bebop-resolution-lab',
            title: 'Enclosures, Chromatic Approaches and Delayed Resolution',
            category: ExerciseCategory.improvisation,
            goal:
                'تعلم target-note improvisation عبر enclosures, chromatic approaches, bebop scales, delayed resolution, anticipation, turnarounds, وii-V-I vocabulary أصلية.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 76, maxBpm: 176),
            targetConcepts: [
              'enclosures',
              'chromatic approaches',
              'bebop scales',
              'delayed resolution',
              'anticipation',
              'turnarounds',
              'ii-V-I vocabulary',
            ],
            backingTrack: BackingTrack(
              id: 'improv-bebop-turnaround',
              title: 'Bebop ii-V-I / Turnaround Loop',
              tempo: 132,
              timeSignature: '4/4',
              formDescription: 'Looped ii-V-I and turnaround cells',
              styleLabel: 'Up Swing',
              keyCenter: 'Bb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Target Logic',
                description:
                    'هل الـ chromatic notes تخدم target note واضحة أم تبدو random outside notes؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Delayed Resolution Control',
                description: 'هل تعرف متى تؤخر الحل ومتى تغلق الجملة بوضوح؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع target first',
                description:
                    'استمع لخط bebop بسيط ولاحظ أن الهدف واضح حتى مع وجود chromatic motion.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد target notes',
                description:
                    'اختر target note لكل chord ثم صمّم enclosure أو chromatic approach نحوها.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ الوصول',
                description: 'غنّ الهدف ثم غنّ الطريق إليه، وليس العكس.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف 4 language cells',
                description:
                    'اعزف enclosure، ثم chromatic approach، ثم bebop scale fragment، ثم delayed resolution على turnaround.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ابنِ ii-V-I chorus',
                description:
                    'ارتجل chorus قصيرة تستعمل 2 أو 3 cells فقط بدل الإفراط في vocabulary.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل bebop cells',
                description:
                    'سجّل take واسأل: هل ما زال target note واضحًا من أول مرة؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم التحكم',
                description:
                    'هل الجمل تسير نحو resolution أم تتحول إلى run مستمرة بلا معنى؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.phraseShape,
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'improv-linear-lab',
        title: 'Linear Improvisation Lab',
        summary:
            'مختبر خطوط متصلة inspired by Bert Ligon-style linear harmony: connecting chords, outlines, target notes, resolution، عبر ii-V-I والblues والrhythm changes.',
        keyTakeaways: [
          'الخط الجيد يربط chord بالتي بعدها، لا يعيد التشغيل من الصفر كل bar',
          'الـ target note والـ resolution هما ما يجعل الخط linear لا scale-based فقط',
        ],
        exercises: [
          JazzExercise(
            id: 'improv-linear-harmony-lab',
            title: 'Connecting Chords and Target Notes',
            category: ExerciseCategory.improvisation,
            goal:
                'تعلم connecting chords, outlines, target notes, resolution، وبناء lines أصلية عبر ii-V-I, blues, and rhythm changes.',
            minutes: 19,
            difficulty: DifficultyLevel.advanced,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C',
            writtenKeyForBbSax: 'D',
            writtenKeyForEbSax: 'A',
            tempoRange: TempoRange(minBpm: 72, maxBpm: 196),
            targetConcepts: [
              'connecting chords',
              'outlines',
              'target notes',
              'resolution',
              'lines through ii-V-I',
              'lines through blues',
              'lines through rhythm changes',
            ],
            backingTrack: BackingTrack(
              id: 'improv-linear-lab-progressions',
              title: 'ii-V-I / Blues / Rhythm Changes Lab',
              tempo: 124,
              timeSignature: '4/4',
              formDescription:
                  'Progression lab cycling through ii-V-I, blues and rhythm changes cells',
              styleLabel: 'Swing Lab',
              keyCenter: 'C',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Line Continuity',
                description:
                    'هل الخط يعبر harmony باستمرار أم يبدو مقطعًا chord-by-chord؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Target Resolution',
                description:
                    'هل تهبط line على target notes واضحة عند التحول بين chords؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الخط كجملة واحدة',
                description:
                    'استمع لline تعبر أكثر من chord من غير توقف، ولاحظ أين تُحس بالحل.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'ارسم outlines',
                description:
                    'حدد outline لكل chord ثم صمّم target note للانتقال إلى التالية.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ المسار الكامل',
                description:
                    'غنّ line من barين أو 4 bars كاملة قبل العزف حتى تسمع continuity داخليًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف line building',
                description:
                    'اعزف line على ii-V-I، ثم line على blues، ثم line على rhythm changes cell بنفس منطق target-resolve.',
                minutes: 6,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ابنِ line أصلية',
                description:
                    'ارتجل line جديدة من 4 bars تربط كل chord بالأخرى من غير التوقف على boundaries.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل linear pass',
                description: 'استمع هل يبدو الخط continuous أم segmented؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الاتصال',
                description:
                    'هل هناك target and resolution في كل pivot point، أم مجرد movement أفقي بلا وجهة؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.repertoireTuneStudy,
    title: 'Repertoire / Tune Study System',
    shortLabel: 'Tunes',
    summary:
        'Tune Study Framework تدرّس form, harmony, guide tones, motif logic, rhythm, والارتجال من خلال style studies أصلية بدل نسخ lead sheets محمية.',
    whyItMatters:
        'الجاز لا يُفهم من التمارين وحدها؛ اللاعب يحتاج أن يسمع form، يعرف cadences، ويربط improvisation ببنية tune حقيقية من غير انتهاك حقوق النشر.',
    objectives: [
      'تحليل form type وkey centers وcadences قبل الارتجال',
      'سماع guide tones وchord-tone targets داخل progression حقيقية',
      'التدرّب على rhythm-only improvisation وmotif development داخل form',
      'استخدام style studies أصلية بدل نسخ melodies أو lead sheets محمية',
    ],
    modules: [
      JazzLessonModule(
        id: 'repertoire-framework',
        title: 'Tune Study Framework',
        summary:
            'ابدأ من form والحركة الهارمونية والguide tones، لا من حفظ melody فقط. كل tune study تتحرك عبر Listen → Understand → Sing → Play → Improvise → Record → Evaluate.',
        keyTakeaways: [
          'الشكل AABA أو blues أو modal vamp يحدد كيف تتنفس الجمل قبل اختيار أي notes',
          'Chord sound ثم guide tones ثم chord tones ثم rhythm ثم motif development هو الترتيب الصحيح داخل tune study',
          'نحن ندرّس style studies أصلية وآمنة قانونيًا، لا نسخًا من lead sheets منشورة',
        ],
        exercises: [
          JazzExercise(
            id: 'repertoire-form-hearing-map',
            title: 'Form Hearing, Guide Tones and Motif Map',
            category: ExerciseCategory.repertoire,
            goal:
                'تعلم أن تسمع form sections وcadences ثم تبني guide-tone map وmotif بسيطة قبل أي solo طويل.',
            minutes: 15,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F',
            writtenKeyForBbSax: 'G',
            writtenKeyForEbSax: 'D',
            tempoRange: TempoRange(minBpm: 76, maxBpm: 132),
            targetConcepts: [
              'form hearing',
              'cadence recognition',
              'guide tones',
              'motif economy',
              'rhythm-only improvisation',
            ],
            backingTrack: BackingTrack(
              id: 'repertoire-framework-medium-blues',
              title: 'Medium Swing Blues Framework in Concert F',
              tempo: 112,
              timeSignature: '4/4',
              formDescription: '12-bar blues form loop',
              styleLabel: 'Medium Swing',
              keyCenter: 'F',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Guide Tone Accuracy',
                description:
                    'هل تعرف أين تهبط الجملة عند تغيّر الـ cadence أم ما زلت تعزف بشكل أفقي فقط؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Form-Aware Rhythm',
                description:
                    'هل rhythm تتنفس مع boundaries الخاصة بالform أم تبقى uniform طوال الوقت؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع form أولًا',
                description:
                    'استمع لكورَس كامل وعدّ sections والcadences من غير عزف. ركز أين يبدأ IV وأين يعود I وأين turnaround.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'ارسم map بسيطة',
                description:
                    'اكتب key centers والcadences و3 guide-tone landing notes فقط عبر form قبل إضافة أي language.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ guide tones',
                description:
                    'غنّ landing notes في أماكنها مع العدّ الداخلي حتى تسمع structure قبل الأصابع.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف map مختصرة',
                description:
                    'اعزف guide-tone line ثم chord-tone shell line من غير fills كثيرة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل rhythm فقط',
                description:
                    'ارتجل بك note واحدة أو نغمتين لكن غيّر rhythm وشكل motif مع الحفاظ على form.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل chorus قصيرة',
                description:
                    'سجّل chorus واحدة واسأل هل المستمع يقدر يشعر بالform حتى من غير كثرة notes؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الوضوح',
                description:
                    'هل resolution والcadence boundaries واضحة أم تختفي داخل continuous eighth notes؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.timeFeel,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'repertoire-beginner-style-studies',
        title: 'Beginner Style Studies',
        summary:
            'دراسات blues وmodal vamp أصلية لتثبيت form, call-response, motif economy, والpulse قبل التوسع الهارموني.',
        keyTakeaways: [
          'ابدأ بالform والspace قبل complexity',
          'البلوز البسيط والmodal vamp يدرسان phrasing أكثر من كثرة النغمات',
        ],
        exercises: [
          JazzExercise(
            id: 'repertoire-beginner-blues-and-vamps',
            title: 'Blues & Vamp Study Builder',
            category: ExerciseCategory.repertoire,
            goal:
                'تطبيق call and response وphrase endings وmotif repetition داخل blues بسيطة وmodal vamps أصلية.',
            minutes: 16,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb',
            writtenKeyForBbSax: 'C',
            writtenKeyForEbSax: 'G',
            tempoRange: TempoRange(minBpm: 68, maxBpm: 120),
            targetConcepts: [
              'basic 12-bar blues',
              'minor pentatonic vamp',
              'modal dorian study',
              'call and response',
              'space',
            ],
            backingTrack: BackingTrack(
              id: 'repertoire-beginner-vamp-lab',
              title: 'Slow Blues & Dorian Vamp Lab',
              tempo: 88,
              timeSignature: '4/4',
              formDescription: 'Alternating blues chorus and 8-bar modal vamp',
              styleLabel: 'Beginner Study',
              keyCenter: 'Bb / D minor',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Motif Economy',
                description:
                    'هل تطور فكرة قصيرة بوضوح أم تغيّر material كل بار بلا رابط؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: 'Pulse and Space',
                description:
                    'هل تترك مساحات وتتنفس الجملة مع pulse أم تمتلئ كل النبضات بلا سبب؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع phrase lengths',
                description:
                    'استمع كيف phrase قصيرة يمكن أن تجيب phrase أخرى داخل blues أو vamp.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد سؤالًا وجوابًا',
                description:
                    'اختر motif من beat واحد أو beatين وحدد كيف ستجيبها مع نفس rhythm أو variation بسيطة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ call-response',
                description:
                    'غنّ سؤالًا ثم جوابًا قبل العزف حتى يصبح phrasing سمعيًا لا ميكانيكيًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف chorus بسيطة',
                description:
                    'اعزف blues chorus قصيرة ثم modal vamp chorus مع أقل material ممكنة.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'بدّل rhythm لا الـ notes',
                description:
                    'في chorus التالية، حافظ على نفس note set تقريبًا لكن غيّر rhythm وشكل النهاية.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل motif take',
                description:
                    'سجّل دقيقة واحدة واسأل هل المستمع يقدر يتذكر فكرتك الرئيسية؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'راجع الاقتصاد',
                description:
                    'هل هناك هوية واضحة أم phrases منفصلة من غير motif أو space؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.timeFeel,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'repertoire-intermediate-style-studies',
        title: 'Intermediate Harmonic Movement Studies',
        summary:
            'دراسات أصلية مستوحاة من minor movement, turnaround studies, وjazz blues حتى يتعلم اللاعب الحركة الهارمونية من غير نسخ melodies.',
        keyTakeaways: [
          'الحركة الهارمونية أهم من حفظ melody منسوخة',
          'guide tones والcadences هي الهيكل الذي يحمل vocabulary',
        ],
        exercises: [
          JazzExercise(
            id: 'repertoire-intermediate-cadence-lines',
            title: 'Cadence Lines through Minor and Turnaround Forms',
            category: ExerciseCategory.repertoire,
            goal:
                'تثبيت ii-V movement وturnaround logic وjazz blues cadence hearing داخل style studies أصلية.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb / G minor',
            writtenKeyForBbSax: 'C / A minor',
            writtenKeyForEbSax: 'G / E minor',
            tempoRange: TempoRange(minBpm: 88, maxBpm: 156),
            targetConcepts: [
              'minor harmonic movement',
              'turnaround study',
              'jazz blues in Bb',
              'guide tones',
              'cadence hearing',
            ],
            backingTrack: BackingTrack(
              id: 'repertoire-intermediate-progressions',
              title: 'Minor Movement and Turnaround Study',
              tempo: 124,
              timeSignature: '4/4',
              formDescription:
                  '16-bar minor progression and 32-bar turnaround study',
              styleLabel: 'Intermediate Swing / Latin-to-Swing',
              keyCenter: 'Bb / G minor',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Cadence Targeting',
                description:
                    'هل تهبط بوضوح على 3rds و7ths عند تغيرات ii-V وturnarounds؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Progression Logic',
                description:
                    'هل الجمل تشرح progression أم تتحول إلى scale fragments معزولة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع cadences',
                description:
                    'استمع لمواضع ii-V وminor cadences وturnaround returns قبل العزف.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حلل key centers',
                description:
                    'قسّم الدراسة إلى key centers صغيرة وحدد أين يحدث tension وأين resolution.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ guide-tone line',
                description:
                    'غنّ 3rd/7th line عبر progression ثم أضف 9th واحدة في أماكن مختارة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف cadence skeleton',
                description:
                    'اعزف skeleton line ثم chord-tone expansion بسيط فوق نفس form.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل chorus مقيد',
                description:
                    'ارتجل chorus لا تستخدم فيها إلا guide tones + approach notes + rhythm variation.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل harmonic pass',
                description:
                    'سجّل take واسأل هل يمكن سماع progression حتى بدون backing track عالية؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم السمع الهارموني',
                description: 'هل resolution واضحة أم تضيع عند التغيرات الأسرع؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'repertoire-advanced-style-studies',
        title: 'Advanced Harmonic Rhythm & Cycle Studies',
        summary:
            'Rhythm changes, fast ii-V-I, fast harmonic rhythm, وcycle studies أصلية للاعب الذي يريد أن يسمع changes بسرعة من غير تقليد solos محفوظة.',
        keyTakeaways: [
          'السرعة تكشف إذا كنت تسمع changes فعلًا أم تحفظ shapes فقط',
          'في الدراسات السريعة، guide-tone hearing والmotif compression أهم من كثرة information',
        ],
        exercises: [
          JazzExercise(
            id: 'repertoire-advanced-fast-form-navigation',
            title: 'Fast Form Navigation and Cycle Studies',
            category: ExerciseCategory.repertoire,
            goal:
                'التحكم في rhythm changes, fast ii-V-I, fast harmonic rhythm, وcycle studies بمنطق سمعي وجملي أصلي.',
            minutes: 20,
            difficulty: DifficultyLevel.advanced,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb / B / Eb',
            writtenKeyForBbSax: 'C / C# / F',
            writtenKeyForEbSax: 'G / G# / C',
            tempoRange: TempoRange(minBpm: 144, maxBpm: 280),
            targetConcepts: [
              'rhythm changes',
              'fast bebop ii-V-I',
              'fast harmonic rhythm',
              'cycle studies',
              'motif compression',
            ],
            backingTrack: BackingTrack(
              id: 'repertoire-advanced-cycles',
              title: 'Advanced Changes Lab',
              tempo: 208,
              timeSignature: '4/4',
              formDescription:
                  'Rhythm changes bridge, fast ii-V-I cells, and cycle studies',
              styleLabel: 'Fast Bebop',
              keyCenter: 'Bb / B / Eb',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Fast Target Control',
                description:
                    'هل تصل إلى target notes بوضوح رغم سرعة التغيّر الهارموني؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Line Compression',
                description:
                    'هل الفكرة ما زالت مفهومة ومتماسكة أم تتحول إلى running بلا syntax؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع bridge والcycles',
                description:
                    'استمع للharmonic rhythm وحدد أين compress phrase وأين تترك landing واضحة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'قسّم التغيّر السريع',
                description:
                    'اقسم progression إلى cells صغيرة: bridge cell، ii-V-I cell، cycle cell.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ targets فقط',
                description:
                    'غنّ 3rds و7ths وtop note of each cell قبل full line construction.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف compressed lines',
                description:
                    'ابنِ lines قصيرة جدًا وواضحة بدل محاولة ملء كل beat بكثافة غير مسموعة.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل chorus سريعة',
                description:
                    'ارتجل chorus على fast changes مع motif صغيرة قابلة للتدوير بين cells.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل one-chorus test',
                description:
                    'سجّل chorus واحدة وراجع هل الخطوط ما زالت توصل form والresolution بوضوح.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم السيطرة',
                description:
                    'هل تسمع changes فعلًا أم تعتمد على finger memory فقط؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.earResponse,
              FeedbackDimension.timeFeel,
            ],
          ),
        ],
      ),
    ],
    tunes: [
      TuneStudy(
        id: 'tune-study-medium-swing-blues-f',
        title: 'Medium Swing Blues in F',
        focus: '12-bar blues form + call and response + phrase endings',
        whyItMatters:
            'أفضل نقطة دخول لفهم form والpulse والاقتصاد اللحني من غير الاعتماد على مادة محفوظة جاهزة.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.beginner,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.blues,
          SkillArea.rhythm,
          SkillArea.improvisation,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-medium-swing-blues-f-track',
          title: 'Medium Swing Blues in Concert F',
          tempo: 116,
          timeSignature: '4/4',
          formDescription: '12-bar blues',
          styleLabel: 'Medium Swing',
          keyCenter: 'F',
        ),
        formDescription:
            '12-bar blues with strong I7, IV7 and turnaround identity.',
        keyCenters: ['F7', 'Bb7', 'C7'],
        cadences: ['IV7 → I7 return', 'V7 → IV7 → I7 turnaround'],
        commonProgressions: [
          'F7 | F7 | F7 | F7',
          'Bb7 | Bb7 | F7 | F7',
          'C7 | Bb7 | F7 | C7'
        ],
        guideToneMap: [
          'A → Ab → A across I7-IV7-I7',
          'Eb anchors the dominant color on F7',
          'E on C7 resolves back toward F7 language'
        ],
        chordTonePractice: [
          'Play 1-3-5-b7 on each dominant shell',
          'Alternate chorus: 3rds only, then 7ths only',
          'Add 9th only after guide tones are stable'
        ],
        rhythmOnlyImprovisation: [
          'Clap one chorus using only two rhythmic cells',
          'Play one note for a full chorus and shape only rhythm and articulation'
        ],
        motifDevelopmentPrompts: [
          'Repeat a 2-beat motif for bars 1-4',
          'Answer your own phrase in bars 5-6',
          'Use a shorter ending motif in bars 9-12'
        ],
        listeningGoals: [
          'Hear where the IV chord changes the emotional color',
          'Feel the turnaround before you play it'
        ],
        improvisationGoals: [
          'Build one chorus from a single motif family',
          'Land clearly on bar 9 without filling every beat'
        ],
        suggestedListening: [
          'Count Basie small-group medium blues feel',
          'Cannonball-style blues phrasing with short vocal cells'
        ],
      ),
      TuneStudy(
        id: 'tune-study-slow-blues-bb',
        title: 'Slow Blues in Bb',
        focus: 'slow phrasing + subtone space + breath-shaped blues language',
        whyItMatters:
            'السرعات البطيئة تفضح ضعف time feel وتدرب اللاعب على space والصوت والتعبير.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.beginner,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.blues,
          SkillArea.tone,
          SkillArea.swing,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-slow-blues-bb-track',
          title: 'Slow Blues in Concert Bb',
          tempo: 68,
          timeSignature: '12/8',
          formDescription: '12-bar slow blues',
          styleLabel: 'Slow Blues',
          keyCenter: 'Bb',
        ),
        formDescription:
            '12-bar slow blues with room for subtone, vibrato and long phrase endings.',
        keyCenters: ['Bb7', 'Eb7', 'F7alt'],
        cadences: ['IV7 → I7 release', 'bVI color into V7alt setup'],
        commonProgressions: [
          'Bb7 | Eb7 | Bb7 | Bb7',
          'Eb7 | Eb7 | Bb7 | Bb7',
          'Gb7 color | F7alt | Bb7 | F7'
        ],
        guideToneMap: [
          'D and Ab define Bb7 color',
          'G and Db anchor Eb7',
          'A and Eb intensify F7alt before resolving'
        ],
        chordTonePractice: [
          'Sustain 3rds through the first 8 bars',
          'Practice 3rd-to-b7 resolutions across bars 9-12',
          'Add blues inflection only after landing notes are secure'
        ],
        rhythmOnlyImprovisation: [
          'Play one chorus using half-note and quarter-note placements only',
          'Delay your answer phrase behind the beat in bars 7-8'
        ],
        motifDevelopmentPrompts: [
          'Stretch one motif over two bars',
          'End each phrase with a different duration, not a different note set'
        ],
        listeningGoals: [
          'Hear how long notes still swing',
          'Notice breath placement and phrase endings'
        ],
        improvisationGoals: [
          'Create tension with duration, not density',
          'Use subtone or softer attacks without losing time'
        ],
        suggestedListening: [
          'Ben Webster-style slow blues breath and subtone',
          'Ballad-era tenor blues phrasing with space'
        ],
      ),
      TuneStudy(
        id: 'tune-study-minor-pentatonic-vamp',
        title: 'Minor Pentatonic Vamp',
        focus: 'one-chord vamp + rhythm development + pentatonic color control',
        whyItMatters:
            'يعلم اللاعب كيف يبني معنى من limited material بدل القفز مبكرًا إلى كثرة النغمات.',
        formType: TuneFormType.modalVamp,
        difficulty: DifficultyLevel.beginner,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.blues,
          SkillArea.improvisation,
          SkillArea.rhythm,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-minor-pentatonic-vamp-track',
          title: 'Minor Pentatonic Vamp in D minor',
          tempo: 96,
          timeSignature: '4/4',
          formDescription: '8-bar repeated vamp',
          styleLabel: 'Groove Vamp',
          keyCenter: 'D minor',
        ),
        formDescription:
            'Static minor vamp centered on one tonal area for rhythm and motif work.',
        keyCenters: ['D minor'],
        cadences: [
          'No functional cadence; release comes from phrase shape and register'
        ],
        commonProgressions: ['Dm7 | Dm7 | Dm7 | Dm7'],
        guideToneMap: [
          'F and C define the chord shell',
          'A adds open color without changing the static harmony'
        ],
        chordTonePractice: [
          'Alternate between D-F-A-C and pure pentatonic fragments',
          'Target the 3rd on strong beats to avoid aimless running'
        ],
        rhythmOnlyImprovisation: [
          'Improvise for 8 bars using one pitch only',
          'Keep the same notes and change only attack placement'
        ],
        motifDevelopmentPrompts: [
          'Repeat one 3-note cell in three registers',
          'Displace your motif by an eighth-note on the next pass'
        ],
        listeningGoals: [
          'Hear how groove creates tension without chord changes',
          'Notice how phrase length replaces harmonic motion'
        ],
        improvisationGoals: [
          'Develop one cell instead of adding more notes',
          'Use rests as part of the vamp language'
        ],
        suggestedListening: [
          'Groove-based modal vamp phrasing from soul-jazz tradition',
          'Simple funk-jazz horn vamps with strong repetition'
        ],
      ),
      TuneStudy(
        id: 'tune-study-simple-modal-dorian',
        title: 'Simple Modal Dorian Study',
        focus: 'dorian color + long-line phrasing + dynamic shape',
        whyItMatters:
            'الدراسة المودالية تعلّم السمع الأفقي واللون والphrase architecture بعيدًا عن القفز بين تغيّرات كثيرة.',
        formType: TuneFormType.modalVamp,
        difficulty: DifficultyLevel.beginner,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.theory,
          SkillArea.improvisation,
          SkillArea.earTraining,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-simple-modal-dorian-track',
          title: 'Simple Dorian Study in C minor',
          tempo: 104,
          timeSignature: '4/4',
          formDescription: '16-bar modal vamp',
          styleLabel: 'Modal Swing',
          keyCenter: 'C Dorian',
        ),
        formDescription:
            'Modal vamp with one minor color and room for long phrase development.',
        keyCenters: ['C Dorian'],
        cadences: [
          'Color shifts come from phrase direction, not functional harmony'
        ],
        commonProgressions: ['Cm7 | Cm7 | Dm7/C pedal | Cm7'],
        guideToneMap: [
          'Eb and Bb anchor the minor shell',
          'D natural is the color note that separates Dorian from Aeolian'
        ],
        chordTonePractice: [
          'Practice 1-b3-5-b7 before adding the natural 6',
          'Sustain the natural 6 against the shell to hear color'
        ],
        rhythmOnlyImprovisation: [
          'Build two choruses with one rhythm cell and different note choices',
          'Place the same motif on beat 1, then on the offbeat'
        ],
        motifDevelopmentPrompts: [
          'Develop a phrase by changing only its ending',
          'Move one motif from low register to mid register over 8 bars'
        ],
        listeningGoals: [
          'Hear the difference between minor quality and Dorian color',
          'Listen for long phrase arcs rather than bar-by-bar licks'
        ],
        improvisationGoals: [
          'Use the natural 6 as a color, not a default passing tone',
          'Shape intensity by rhythm and dynamics'
        ],
        suggestedListening: [
          'Modal quartet phrasing with sustained minor color',
          'Post-bop Dorian playing that uses long arcs instead of scale runs'
        ],
      ),
      TuneStudy(
        id: 'tune-study-autumn-style-movement',
        title: 'Autumn Leaves-style Harmonic Movement',
        focus:
            'minor-major ii-V motion + phrase direction + guide-tone hearing',
        whyItMatters:
            'ينقل اللاعب من static material إلى movement through key centers من غير الاعتماد على melody محفوظة.',
        formType: TuneFormType.abac,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.theory,
          SkillArea.improvisation,
          SkillArea.earTraining,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-autumn-style-track',
          title: 'Minor-to-Major Harmonic Motion Study',
          tempo: 132,
          timeSignature: '4/4',
          formDescription: '32-bar ABAC-style progression',
          styleLabel: 'Medium Swing',
          keyCenter: 'G minor to Bb major',
        ),
        formDescription:
            'A minor-to-major study built around descending fifth motion and clear ii-V-I arrivals.',
        keyCenters: ['G minor', 'Bb major', 'C minor'],
        cadences: ['ii-V-i in minor', 'ii-V-I into relative major'],
        commonProgressions: [
          'Am7b5 D7 | Gm7',
          'Cm7 F7 | Bbmaj7',
          'Am7b5 D7 | Gm7'
        ],
        guideToneMap: [
          'F → F# → G outlines the minor cadence',
          'Eb → D carries the release into Bb major',
          'A on D7 resolves to Bb or G by context'
        ],
        chordTonePractice: [
          'Play 3rds and 7ths only for one full form',
          'Add 9ths only on the second pass',
          'Outline chord tones before any scale color'
        ],
        rhythmOnlyImprovisation: [
          'Use one two-beat rhythm through all key centers',
          'Move the same rhythm cell through both minor and major cadences'
        ],
        motifDevelopmentPrompts: [
          'Take one motif from the minor cadence and answer it in the major cadence',
          'Shorten your motif in the C section to reflect the tighter motion'
        ],
        listeningGoals: [
          'Hear the emotional shift from minor area to relative major',
          'Recognize descending-fifths gravity by ear'
        ],
        improvisationGoals: [
          'Land clearly on 3rds during each cadence',
          'Let motif contour reflect harmonic direction'
        ],
        suggestedListening: [
          'Minor-to-major standard movement in mid-tempo swing',
          'Players who emphasize guide-tone resolutions through descending fifths'
        ],
      ),
      TuneStudy(
        id: 'tune-study-blue-bossa-style-minor',
        title: 'Blue Bossa-style Minor Progression',
        focus: 'minor vamp into cadence + Latin-to-swing transition logic',
        whyItMatters:
            'تعلم هذه الدراسة كيف يتغير feel مع ثبات بعض material الهارمونية، وهي خطوة مهمة بين modal thinking وfunctional cadence.',
        formType: TuneFormType.abac,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.rhythm,
          SkillArea.improvisation,
          SkillArea.theory,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-bossa-style-track',
          title: 'Minor Progression Study with Latin Pulse',
          tempo: 126,
          timeSignature: '4/4',
          formDescription: '16-bar minor progression with cadence release',
          styleLabel: 'Latin-to-Swing Study',
          keyCenter: 'C minor',
        ),
        formDescription:
            'Minor progression that alternates static color with functional arrival points.',
        keyCenters: ['C minor', 'Db major color', 'D half-diminished to G7'],
        cadences: [
          'ii-V-i in minor',
          'temporary color shift to nearby major area'
        ],
        commonProgressions: [
          'Cm7 | Cm7 | Fm7 | Fm7',
          'Dm7b5 G7alt | Cm7',
          'Dbmaj7 | Dm7b5 G7'
        ],
        guideToneMap: [
          'Eb and Bb hold the minor shell',
          'F and C support Fm7 color',
          'F → B → C hears the ii-V-i release'
        ],
        chordTonePractice: [
          'Alternate minor pentatonic with full chord-tone shells',
          'Practice only guide tones across Dm7b5 → G7alt → Cm7'
        ],
        rhythmOnlyImprovisation: [
          'Keep a Latin-style phrase cell and move it to the cadence bars',
          'Answer a straight phrase with a more swung one in the release section'
        ],
        motifDevelopmentPrompts: [
          'Start with one minor motif and change only the ending over the cadence',
          'Move the motif up a third for the color-shift section'
        ],
        listeningGoals: [
          'Hear the contrast between static minor bars and functional cadence bars',
          'Notice how rhythm feel can shift while form stays intact'
        ],
        improvisationGoals: [
          'Make the cadence sound inevitable',
          'Use repetition before introducing chromatic color'
        ],
        suggestedListening: [
          'Latin minor jazz forms with clear cadence release',
          'Players who move from vamp logic into swing cadences smoothly'
        ],
      ),
      TuneStudy(
        id: 'tune-study-satin-style-turnaround',
        title: 'Satin Doll-style Turnaround Study',
        focus: 'turnaround hearing + dominant motion + elegant phrase endings',
        whyItMatters:
            'يعلم اللاعب كيف يتعامل مع turnarounds والdominant motion بجمل مهذبة ومنظمة بدل الجري المستمر.',
        formType: TuneFormType.aaba,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.swing,
          SkillArea.theory,
          SkillArea.improvisation,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-turnaround-track',
          title: 'Turnaround Elegance Study',
          tempo: 142,
          timeSignature: '4/4',
          formDescription: '32-bar AABA turnaround study',
          styleLabel: 'Elegant Swing',
          keyCenter: 'C major',
        ),
        formDescription:
            'Turnaround-based AABA study with polished dominant motion and phrase release.',
        keyCenters: ['C major', 'A7 color', 'D7 → G7 dominant chain'],
        cadences: [
          'I → VI7 → II7 → V7',
          'secondary dominant arrivals inside A sections'
        ],
        commonProgressions: ['Cmaj7 A7 | Dm7 G7', 'E7 | A7 | D7 | G7'],
        guideToneMap: [
          'E → C# → F → B tracks the turnaround shell',
          'B on G7 resolves elegantly back into C material'
        ],
        chordTonePractice: [
          'Play only 3rds through the turnaround chain',
          'Then connect 3rds to 7ths without roots'
        ],
        rhythmOnlyImprovisation: [
          'Improvise one A section with mostly quarter-note language',
          'Use shorter anticipations only at the end of the turnaround'
        ],
        motifDevelopmentPrompts: [
          'End each A section with a cleaner and shorter motif',
          'Keep one motif identity while the harmony cycles underneath'
        ],
        listeningGoals: [
          'Hear the pull of secondary dominants as forward motion',
          'Notice phrase elegance and release instead of density'
        ],
        improvisationGoals: [
          'Make turnarounds singable',
          'Use articulation to make the chain feel lighter'
        ],
        suggestedListening: [
          'Classic swing-era turnaround phrasing with elegant attacks',
          'Players who let secondary dominants flow instead of overfilling them'
        ],
      ),
      TuneStudy(
        id: 'tune-study-jazz-blues-bb',
        title: 'Jazz Blues in Bb',
        focus: '#IVdim + VI7 + ii-V movement inside a jazz blues form',
        whyItMatters:
            'الجاز بلوز هي الجسر بين blues language والfunctional harmony، وهي صيغة مركزية لأي لاعب جاز.',
        formType: TuneFormType.twelveBarBlues,
        difficulty: DifficultyLevel.intermediate,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.blues,
          SkillArea.theory,
          SkillArea.improvisation,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-jazz-blues-bb-track',
          title: 'Jazz Blues in Concert Bb',
          tempo: 152,
          timeSignature: '4/4',
          formDescription: '12-bar jazz blues',
          styleLabel: 'Jazz Blues',
          keyCenter: 'Bb',
        ),
        formDescription:
            'Jazz blues with movement through IV7, #IVdim, VI7 and ii-V cadences.',
        keyCenters: ['Bb7', 'Eb7', 'E diminished color', 'G7', 'Cm7 F7'],
        cadences: [
          'IV7 → #IVdim → I7 setup',
          'ii-V return to I7',
          'VI7 pushes into ii-V'
        ],
        commonProgressions: [
          'Bb7 | Eb7 | Bb7 | Bb7',
          'Eb7 | Edim7 | Bb7 G7',
          'Cm7 F7 | Bb7 G7 | Cm7 F7'
        ],
        guideToneMap: [
          'D and Ab anchor Bb7',
          'G and Db define Eb7',
          'B and F on G7 pull strongly into Cm7'
        ],
        chordTonePractice: [
          'Outline Bb7 shell before adding blues notes',
          'Practice guide tones only through bars 5-10',
          'Add bebop dominant color only after bar-9 clarity is solid'
        ],
        rhythmOnlyImprovisation: [
          'Keep the same rhythm while the harmony gets denser in bars 5-10',
          'Answer bar 9 with a shorter bar-10 response'
        ],
        motifDevelopmentPrompts: [
          'Start with a blues motif and reharmonize it through VI7 and ii-V',
          'Condense the motif in the turnaround bars'
        ],
        listeningGoals: [
          'Hear where jazz blues departs from basic blues',
          'Notice when harmony demands more precise landing notes'
        ],
        improvisationGoals: [
          'Blend blues language with chord awareness',
          'Make bars 9-12 sound directional, not generic'
        ],
        suggestedListening: [
          'Jazz blues forms that mix blues vocabulary with ii-V clarity',
          'Players who keep the blues feeling while outlining functional movement'
        ],
      ),
      TuneStudy(
        id: 'tune-study-rhythm-changes-bb',
        title: 'Rhythm Changes in Bb',
        focus: 'AABA form + I-VI-II-V cycles + bridge navigation',
        whyItMatters:
            'Rhythm changes مدرسة كاملة في form awareness والphrase compression والتنقل السريع بين changes.',
        formType: TuneFormType.rhythmChanges,
        difficulty: DifficultyLevel.advanced,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.theory,
          SkillArea.improvisation,
          SkillArea.swing,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-rhythm-changes-track',
          title: 'Rhythm Changes in Concert Bb',
          tempo: 208,
          timeSignature: '4/4',
          formDescription: '32-bar AABA rhythm changes',
          styleLabel: 'Up Swing',
          keyCenter: 'Bb',
        ),
        formDescription:
            'AABA cycle study with turnaround A sections and dominant bridge motion.',
        keyCenters: [
          'Bb major',
          'D7 / G7 / C7 dominant cycle',
          'Bridge dominant key centers'
        ],
        cadences: [
          'I → VI7 → II7 → V7',
          'bridge dominant cycles resolving back to Bb'
        ],
        commonProgressions: ['Bbmaj7 G7 | Cm7 F7', 'D7 | G7 | C7 | F7'],
        guideToneMap: [
          'D → B → Eb → A outlines the A section turnaround',
          'F# → B → E → A hears the bridge dominant chain'
        ],
        chordTonePractice: [
          'Play 3rds only through one chorus',
          'Practice shell lines through the bridge at half-tempo first',
          'Add bebop approach notes only after the shell is clear'
        ],
        rhythmOnlyImprovisation: [
          'Improvise one chorus with one-bar rhythmic motifs only',
          'Use the same rhythmic sentence through all four bridge dominants'
        ],
        motifDevelopmentPrompts: [
          'State one motif in A1, answer it in A2, compress it in the bridge',
          'Return to a cleaner version in the last A'
        ],
        listeningGoals: [
          'Hear the bridge as a separate energy shape',
          'Feel the return to the last A before it arrives'
        ],
        improvisationGoals: [
          'Outline the bridge without panic',
          'Keep motifs intelligible at fast tempos'
        ],
        suggestedListening: [
          'Fast AABA swing forms with strong bridge identity',
          'Players who make rhythm changes sound singable instead of crowded'
        ],
      ),
      TuneStudy(
        id: 'tune-study-fast-bebop-iivi',
        title: 'Fast Bebop ii-V-I Study',
        focus:
            'compact cadence language + anticipation + delayed resolution at fast tempo',
        whyItMatters:
            'هذه الدراسة تجعل اللاعب يسمع ii-V-I بسرعة من خلال targets لا من خلال run محفوظة فقط.',
        formType: TuneFormType.throughComposedCycle,
        difficulty: DifficultyLevel.advanced,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.improvisation,
          SkillArea.theory,
          SkillArea.saxLanguage,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-fast-bebop-iivi-track',
          title: 'Fast Bebop ii-V-I Loop',
          tempo: 236,
          timeSignature: '4/4',
          formDescription: 'Continuous ii-V-I cadence cycle',
          styleLabel: 'Fast Bebop',
          keyCenter: 'Cycling keys',
        ),
        formDescription:
            'A through-composed cadence study built from fast ii-V-I cells and clear arrivals.',
        keyCenters: ['C major', 'Bb major', 'Eb major', 'A major'],
        cadences: ['ii-V-I repeated through multiple keys'],
        commonProgressions: [
          'Dm7 G7 | Cmaj7',
          'Cm7 F7 | Bbmaj7',
          'Fm7 Bb7 | Ebmaj7'
        ],
        guideToneMap: [
          'F → F → E for Dm7 → G7 → Cmaj7',
          'Eb → D → D for Cm7 → F7 → Bbmaj7'
        ],
        chordTonePractice: [
          'Play guide-tone lines through all keys first',
          'Add arpeggio shells before bebop color tones',
          'Introduce b9/#9 only where resolution is audible'
        ],
        rhythmOnlyImprovisation: [
          'Use one two-beat bebop rhythm cell in every key',
          'Anticipate the I chord in only one cadence per chorus'
        ],
        motifDevelopmentPrompts: [
          'Move one cadence motif through 4 keys',
          'Delay one resolution, then resolve cleanly in the next key'
        ],
        listeningGoals: [
          'Hear the 3rd and 7th motion before chromatic detail',
          'Notice how resolution creates meaning at high speed'
        ],
        improvisationGoals: [
          'Keep targets audible at full tempo',
          'Avoid treating every cadence like the same mechanical pattern'
        ],
        suggestedListening: [
          'Fast bebop cadence playing centered on targets and delayed release',
          'Players who make rapid ii-V-I motion still feel vocal'
        ],
      ),
      TuneStudy(
        id: 'tune-study-cherokee-style-fast-rhythm',
        title: 'Cherokee-style Fast Harmonic Rhythm Study',
        focus: 'fast-moving key centers + phrase compression + breath planning',
        whyItMatters:
            'السرعة والهارموني السريع هنا يدربان اللاعب على hearing in sections بدل التعلق بنغمة واحدة أو shape واحدة.',
        formType: TuneFormType.aaba,
        difficulty: DifficultyLevel.advanced,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.improvisation,
          SkillArea.rhythm,
          SkillArea.earTraining,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-fast-harmonic-rhythm-track',
          title: 'Fast Harmonic Rhythm Style Study',
          tempo: 264,
          timeSignature: '4/4',
          formDescription: 'AABA-style fast harmonic rhythm study',
          styleLabel: 'Very Fast Swing',
          keyCenter: 'Multiple fast key areas',
        ),
        formDescription:
            'AABA fast-harmony study with rapid modulation pressure and short phrase windows.',
        keyCenters: ['Bb major', 'G major', 'E major', 'C major pockets'],
        cadences: ['short ii-V arrivals', 'fast sectional tonicizations'],
        commonProgressions: [
          'ii-V-I cells moving every 1-2 bars',
          'bridge built from rapid key shifts'
        ],
        guideToneMap: [
          'Choose one guide-tone target per two bars',
          'Compress landing notes rather than spelling every chord'
        ],
        chordTonePractice: [
          'Practice roots-to-3rds only first',
          'Then guide tones only across the bridge',
          'Add one enclosure per section, not per bar'
        ],
        rhythmOnlyImprovisation: [
          'Play sparse quarter-note and offbeat phrases to keep form clear',
          'Answer every dense bar with a simpler bar'
        ],
        motifDevelopmentPrompts: [
          'Shrink one motif so it can survive faster harmonic motion',
          'Use a short pickup to announce each new key area'
        ],
        listeningGoals: [
          'Hear harmonic rhythm as waves, not isolated chords',
          'Notice where phrases must become shorter to stay logical'
        ],
        improvisationGoals: [
          'Survive tempo by clarity, not density',
          'Make sectional key changes audible'
        ],
        suggestedListening: [
          'Very fast swing repertoire where players compress lines intelligently',
          'Up-tempo solos that keep phrase syntax intact under pressure'
        ],
      ),
      TuneStudy(
        id: 'tune-study-giant-steps-style-cycle',
        title: 'Giant Steps-style Cycle Study',
        focus:
            'symmetrical key cycles + target-note hearing + rapid resolution logic',
        whyItMatters:
            'هذه الدراسة تبني سمعًا حقيقيًا للcycle movement بدل الحفظ الأعمى لأشكال جاهزة.',
        formType: TuneFormType.throughComposedCycle,
        difficulty: DifficultyLevel.advanced,
        skillAreas: [
          SkillArea.repertoire,
          SkillArea.theory,
          SkillArea.improvisation,
          SkillArea.earTraining,
        ],
        backingTrack: BackingTrack(
          id: 'tune-study-cycle-study-track',
          title: 'Symmetrical Cycle Study',
          tempo: 228,
          timeSignature: '4/4',
          formDescription: 'Cycle study moving through distant key centers',
          styleLabel: 'Cycle Study',
          keyCenter: 'B / G / Eb cycle',
        ),
        formDescription:
            'Through-composed cycle study built around fast movement through distant tonic centers.',
        keyCenters: ['B major', 'G major', 'Eb major'],
        cadences: [
          'rapid tonic arrival in major thirds',
          'ii-V entries into distant tonic centers'
        ],
        commonProgressions: [
          'Bmaj7 D7 | Gmaj7 Bb7 | Ebmaj7 F#7',
          'ii-V inserts leading into the next tonic center'
        ],
        guideToneMap: [
          'D# → C# → B across the B center',
          'B → A → G across the G center',
          'G → F → Eb across the Eb center'
        ],
        chordTonePractice: [
          'Play only 3rds through the cycle first',
          'Then play 3rd-to-7th shells through each arrival',
          'Add one approach note only after the cycle is singable'
        ],
        rhythmOnlyImprovisation: [
          'Keep one rhythmic cell while the key centers leap by major third',
          'Use silence after each tonic arrival to hear the next cycle point'
        ],
        motifDevelopmentPrompts: [
          'Transpose one motif through all three tonic centers',
          'Change only the pickup note while the cycle repeats'
        ],
        listeningGoals: [
          'Hear distant tonic centers as destinations, not math problems',
          'Notice which targets make the cycle feel inevitable'
        ],
        improvisationGoals: [
          'Outline each tonic center with minimal notes',
          'Keep resolutions clean even when the cycle feels fast'
        ],
        suggestedListening: [
          'Cycle-based modern jazz studies focused on target hearing',
          'Players who simplify symmetrical movement into vocal phrase shapes'
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.saxophoneJazzLanguage,
    title: 'Saxophone-Specific Jazz Language',
    shortLabel: 'Language',
    summary:
        'لغة ساكسفون جازية حقيقية: swing articulation, bebop touch, blues ornaments, ballad colors, funk attacks, ومنطق transposition العملي عبر الآلة.',
    whyItMatters:
        'الساكسفون ليس generic theory machine. نفس الجملة تتغير بالهواء واللسان والزخرفة والريجستر، ولازم اللاعب يفكر كذلك أيضًا في transposition دائمًا داخل chart والتمرين والbacking track.',
    objectives: [
      'تعلم swing articulation وdoo-dat feel والghosted upbeats بشكل سمعي وعملي',
      'بناء bebop touch خفيف وواضح في legato eighths وchromatic approaches',
      'تطوير blues language صوتية: falls, scoops, bends, growl, call-response, expressive timing',
      'التحكم في ballad colors مثل subtone, vibrato, breath pacing, dynamic shape',
      'بناء funk attack واضح مع short notes وsixteenth-note control وrepeated riffs',
      'فهم transposition logic للـ Concert / Bb / Eb عبر المحتوى كله',
    ],
    modules: [
      JazzLessonModule(
        id: 'language-swing-articulation',
        title: 'Swing Articulation Engine',
        summary:
            'doo-dat feel, ghosted upbeats, connected eighth notes, accents، وشكل نهاية الجملة في swing phrasing.',
        keyTakeaways: [
          'السوينغ لا يأتي من النغمات فقط بل من كيفية نطقها وتوصيلها',
          'ghosted upbeats والphrase ending shape هما ما يجعلان الجملة تتكلم لا أن تُقرأ',
        ],
        exercises: [
          JazzExercise(
            id: 'language-swing-doo-dat',
            title: 'Doo-Dat, Ghosted Upbeats and Phrase Endings',
            category: ExerciseCategory.improvisation,
            goal:
                'تثبيت swing articulation عبر doo-dat feel, connected eighth notes, ghosted upbeats, accents, وشكل نهاية الجملة.',
            minutes: 16,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F blues',
            writtenKeyForBbSax: 'G blues',
            writtenKeyForEbSax: 'D blues',
            tempoRange: TempoRange(minBpm: 84, maxBpm: 156),
            targetConcepts: [
              'doo-dat feel',
              'ghosted upbeats',
              'accents',
              'connected eighth notes',
              'phrase ending shape',
            ],
            backingTrack: BackingTrack(
              id: 'language-swing-articulation-track',
              title: 'Medium Swing Articulation Lab',
              tempo: 124,
              timeSignature: '4/4',
              formDescription: 'Medium swing loop',
              styleLabel: 'Medium Swing',
              keyCenter: 'F blues',
              concertKey: 'F blues',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.swingFeel,
                label: 'Upbeat Lift',
                description:
                    'هل الـ upbeats ghosted ومرفوعة بإحساس أم مسطحة ومتماثلة مع downbeats؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Phrase Shape',
                description:
                    'هل تنتهي الجملة بشكل طبيعي ومقنع أم تنقطع بلا release واضح؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع النطق',
                description:
                    'استمع لنفس line مرة بنطق مستقيم ومرة بـ doo-dat feel ولاحظ الفرق فورًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد أين تُخفى الـ upbeat',
                description:
                    'افهم أن الـ ghosted upbeat أخف من الـ downbeat، وأن نهاية phrase تحتاج release مقصودًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ doo-dat',
                description:
                    'غنّ line قصيرة باستخدام syllables قبل عزفها حتى تسمع articulation داخليًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف articulation cells',
                description:
                    'اعزف 3 خلايا قصيرة مع connected eighths وghosted upbeats وaccent في قمة الجملة.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل بنغمتين فقط',
                description:
                    'ارتجل باستخدام نغمتين أو ثلاث، لكن غيّر articulation وشكل endings بدل زيادة notes.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل phrase endings',
                description:
                    'سجّل 4 endings مختلفة واسأل أيها يبدو أكثر natural swing.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم النطق',
                description:
                    'هل تبدو الجملة مقولة على الساكسفون أم مجرد notes متساوية؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.swingPlacement,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'library-swing-articulation-map',
            title: 'Swing Articulation Reference',
            categoryLabel: 'Articulation Map',
            summary:
                'Reference for doo-dat feel, connected eighths, ghosted upbeats, accents, and phrase ending shapes.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'The Jazz Language — Dan Haerle',
            ],
            tags: ['swing', 'articulation', 'ghosted upbeat'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'language-bebop-articulation',
        title: 'Bebop Touch and Chromatic Clarity',
        summary:
            'lighter tongue, legato eighths, accents on phrase peaks، وclean chromatic approaches داخل لغة bebop أصلية.',
        keyTakeaways: [
          'bebop tongue أخف من النطق القاسي في كل note',
          'الـ chromatic approach لازم تبقى نظيفة وتخدم target note لا أن تُغرقها',
        ],
        exercises: [
          JazzExercise(
            id: 'language-bebop-touch',
            title: 'Legato Eighths and Clean Chromatic Approaches',
            category: ExerciseCategory.improvisation,
            goal:
                'تعلم tongue أخف، legato eighths، accent على phrase peaks، وclean chromatic approaches في سياق bebop.',
            minutes: 17,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb major',
            writtenKeyForBbSax: 'C major',
            writtenKeyForEbSax: 'G major',
            tempoRange: TempoRange(minBpm: 96, maxBpm: 196),
            targetConcepts: [
              'lighter tongue',
              'legato eighths',
              'phrase-peak accents',
              'clean chromatic approaches',
            ],
            backingTrack: BackingTrack(
              id: 'language-bebop-touch-track',
              title: 'Bebop Cadence Lab',
              tempo: 152,
              timeSignature: '4/4',
              formDescription: 'ii-V-I cadence loop',
              styleLabel: 'Bebop Swing',
              keyCenter: 'Bb major',
              concertKey: 'Bb major',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Legato Integrity',
                description:
                    'هل الثمنيات متصلة وخفيفة أم مفصولة زيادة عن اللزوم؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Chromatic Targeting',
                description:
                    'هل الـ chromatic approaches تصل إلى target note بوضوح ونظافة؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الخط الخفيف',
                description:
                    'استمع لline bebop بنطق خفيف ولاحظ أين accent تقع عند phrase peak لا على كل note.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد target والpeak',
                description:
                    'اعرف أين تقع target note، وأين تحتاج accent خفيفة، وأين يجب أن تبقى line legato.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ chromatic approach',
                description:
                    'غنّ الطريق إلى target note من غير آلة حتى تسمع resolution بوضوح.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف bebop cells',
                description:
                    'اعزف 4 cells قصيرة فيها approach notes لكن مع tongue خفيفة وline legato.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل ii-V-I صغيرة',
                description:
                    'ارتجل 2-bar phrases فقط، مع accent على phrase peak واحدة في كل جملة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل chromatic pass',
                description:
                    'سجّل take واسأل هل الـ chromatic notes واضحة ونظيفة أم blur؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الخفة',
                description:
                    'هل الجملة ما زالت swing وlegato أم أصبحت too tongued أو heavy؟',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.articulation,
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'language-blues-saxophone',
        title: 'Blues Saxophone Language',
        summary:
            'falls, scoops, bends, growl, vocal phrasing, call and response, وexpressive timing داخل blues sax tradition أصلية.',
        keyTakeaways: [
          'الـ blues phrase تُقال وتُغنّى قبل أن تُعزف',
          'الزخرفة تخدم التعبير والتوقيت، لا تُضاف بشكل آلي على كل نهاية',
        ],
        exercises: [
          JazzExercise(
            id: 'language-blues-ornaments',
            title: 'Falls, Scoops, Bends, Growl and Vocal Timing',
            category: ExerciseCategory.improvisation,
            goal:
                'تطوير falls وscoops وbends وgrowl وcall-response وexpressive timing داخل blues language أصلية.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C blues',
            writtenKeyForBbSax: 'D blues',
            writtenKeyForEbSax: 'A blues',
            tempoRange: TempoRange(minBpm: 70, maxBpm: 132),
            targetConcepts: [
              'falls',
              'scoops',
              'bends',
              'growl',
              'vocal phrasing',
              'call and response',
              'expressive timing',
            ],
            backingTrack: BackingTrack(
              id: 'language-blues-vocal-track',
              title: 'Blues Vocal Phrasing Lab',
              tempo: 92,
              timeSignature: '4/4',
              formDescription: '12-bar blues loop',
              styleLabel: 'Slow-Medium Blues',
              keyCenter: 'C blues',
              concertKey: 'C blues',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Ornament Shape',
                description:
                    'هل الـ fall أو scoop أو bend له curve واضح ومتحكم فيه؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Vocal Phrasing',
                description:
                    'هل call-response والtiming يحملان شخصية غنائية أم يبدوان ميكانيكيين؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الزخرفة كصوت',
                description:
                    'استمع لفروق fall وscoop وbend، ولاحظ كيف التوقيت التعبيري يغير المعنى.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'اختر مكان الزخرفة',
                description:
                    'اعرف أن كل زخرفة لها مكان: بداية phrase، قمة phrase، أو نهاية phrase.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ النداء والجواب',
                description:
                    'غنّ سؤالًا قصيرًا ثم جوابًا مع bend أو scoop قبل العزف.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف 4 blues cells',
                description:
                    'اعزف falls وscoops وgrowl على خلايا قصيرة مع timing مرن لكن pulse ثابت.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل call-response',
                description:
                    'ارتجل كورس قصيرة مبنية على call-response لا على كثافة notes.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل blues take',
                description:
                    'سجّل chorus واسأل هل phrase تبدو مغناة ومقولة أم مجرد scale.',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الشخصية',
                description:
                    'هل الزخارف under control وهل التوقيت expressive من غير فقدان pulse؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.bluesLanguage,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'library-concert-c-blues-transposition',
            title: 'Concert C Blues Transposition',
            categoryLabel: 'Transposition Quick View',
            summary:
                'Concert C blues becomes D blues for Bb tenor/soprano and A blues for Eb alto/baritone.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'The Jazz Language — Dan Haerle',
            ],
            concertKey: 'C blues',
            writtenKeyForBbSax: 'D blues',
            writtenKeyForEbSax: 'A blues',
            tags: ['transposition', 'concert pitch', 'blues'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'language-ballad-colors',
        title: 'Ballad Saxophone Colors',
        summary:
            'subtone, vibrato, breath pacing, phrase shape, وdynamic control داخل ballad language أصلية.',
        keyTakeaways: [
          'ballad control يعتمد على الهواء والوقت بقدر اعتماده على pitch',
          'subtone وvibrato يجب أن يكونا intentional لا default effect',
        ],
        exercises: [
          JazzExercise(
            id: 'language-ballad-subtone-vibrato',
            title: 'Subtone, Vibrato and Breath-Paced Ballad Phrasing',
            category: ExerciseCategory.improvisation,
            goal:
                'بناء subtone, vibrato, breath pacing, phrase shape, وdynamic control داخل ballad phrasing على الساكسفون.',
            minutes: 16,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
            ],
            concertKey: 'Eb major',
            writtenKeyForBbSax: 'F major',
            writtenKeyForEbSax: 'C major',
            tempoRange: TempoRange(minBpm: 48, maxBpm: 84),
            targetConcepts: [
              'subtone',
              'vibrato',
              'breath pacing',
              'phrase shape',
              'dynamic control',
            ],
            backingTrack: BackingTrack(
              id: 'language-ballad-pad-track',
              title: 'Ballad Color Pad',
              tempo: 60,
              timeSignature: '4/4',
              formDescription: 'Open ballad pad',
              styleLabel: 'Ballad',
              keyCenter: 'Eb major',
              concertKey: 'Eb major',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.tone,
                label: 'Ballad Color',
                description:
                    'هل subtone وvibrato تحت السيطرة ويحافظان على core tone؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Breath Shape',
                description:
                    'هل الجملة تتنفس طبيعيًا وتكبر ثم تهدأ بشكل مقصود؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع النفس الطويل',
                description:
                    'استمع لphrase ballad ولاحظ كيف يُبنى القوس الديناميكي وكيف يدخل subtone أو vibrato.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'اختر color moments',
                description:
                    'حدد أين تحتاج subtone وأين تحتاج tone core وأين يبدأ vibrato ومتى يتوقف.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ الجملة بنَفَس',
                description:
                    'غنّ الجملة كاملة مع تخيل النفس والdynamic curve قبل عزفها.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف ballad cells',
                description:
                    'اعزف خلايا قصيرة مع subtone controlled وvibrato في نهايات مختارة فقط.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ابنِ line هادئة',
                description:
                    'ارتجل 4 bars فقط لكن أعطِ كل phrase بداية وقمة ونهاية.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل ballad take',
                description:
                    'سجّل هل النفس واللون واضحان أم أن effect تطغى على الجملة؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم السيطرة',
                description:
                    'هل dynamic shape والهواء والvibrato يخدمون الجملة أم يشتتونها؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.phraseShape,
              FeedbackDimension.intonation,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'language-funk-attacks',
        title: 'Funk Saxophone Attacks',
        summary:
            'short notes, sixteenth-note control, strong articulation, repeated riffs, وsyncopation داخل funk sax vocabulary أصلية.',
        keyTakeaways: [
          'في funk، وضوح attack وطول النغمة مهمان بقدر اختيار النغمات',
          'repeated riffs تحتاج consistency وsyncopation لا كثرة vocabulary',
        ],
        exercises: [
          JazzExercise(
            id: 'language-funk-riff-control',
            title: 'Short Notes, Sixteenths and Syncopated Riffs',
            category: ExerciseCategory.rhythm,
            goal:
                'تطوير short notes وsixteenth-note control وstrong articulation وrepeated riffs وsyncopation على الساكسفون.',
            minutes: 17,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'E minor',
            writtenKeyForBbSax: 'F# minor',
            writtenKeyForEbSax: 'C# minor',
            tempoRange: TempoRange(minBpm: 88, maxBpm: 116),
            targetConcepts: [
              'short notes',
              'sixteenth-note control',
              'strong articulation',
              'repeated riffs',
              'syncopation',
            ],
            backingTrack: BackingTrack(
              id: 'language-funk-riff-track',
              title: 'Funk Riff Pocket Lab',
              tempo: 100,
              timeSignature: '4/4',
              formDescription: '8-bar vamp loop',
              styleLabel: 'Funk',
              keyCenter: 'E minor',
              concertKey: 'E minor',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Sixteenth Precision',
                description: 'هل الsixteenth notes ثابتة ونظيفة أم تتسع وتضيق؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Riff Attack',
                description:
                    'هل الriffs القصيرة لها attack قوي ومتسق وطول note مضبوط؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع الجيب',
                description:
                    'استمع إلى riff قصيرة وركز في طول النغمة لا في pitch فقط.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد note lengths',
                description:
                    'افهم أين تنتهي short note وأين تبدأ syncopation الحقيقية داخل البار.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ الriff',
                description:
                    'غنّ الriff بإيقاعها الدقيق قبل العزف حتى يتثبت pocket داخليًا.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف repeated riffs',
                description:
                    'اعزف 3 riffs قصيرة متكررة مع ضبط sixteenth notes وطول كل note.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ارتجل pocket variation',
                description:
                    'ارتجل عبر variations صغيرة على riff واحدة بدل تغيير material بالكامل.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل groove take',
                description:
                    'سجّل هل pocket ثابتة وهل attack متسقة عبر repetitions؟',
                minutes: 1,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الtightness',
                description:
                    'هل الـ syncopation واضحة ومشدودة أم متأخرة/مبكرة بشكل يضعف الجيب؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.articulation,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'language-transposition-system',
        title: 'Saxophone Transposition System',
        summary:
            'منطق Concert pitch مقابل Bb tenor/soprano وEb alto/baritone، مع تطبيقه على blues, lessons, backing tracks, وlibrary references.',
        keyTakeaways: [
          'الـ concert key هي الحقيقة الهارمونية، والـ written key هي ما يقرأه عازف الساكسفون',
          'Concert C blues تصبح D blues للـ Bb horns وA blues للـ Eb horns',
        ],
        exercises: [
          JazzExercise(
            id: 'language-transposition-practice',
            title: 'Concert-to-Bb/Eb Key Translation',
            category: ExerciseCategory.theory,
            goal:
                'ترجمة key center بسرعة بين concert pitch وBb/Eb saxophones أثناء التمرين والقراءة والـ backing tracks.',
            minutes: 12,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C blues',
            writtenKeyForBbSax: 'D blues',
            writtenKeyForEbSax: 'A blues',
            tempoRange: TempoRange(minBpm: 60, maxBpm: 100),
            targetConcepts: [
              'concert pitch',
              'Bb transposition',
              'Eb transposition',
              'key translation',
            ],
            backingTrack: BackingTrack(
              id: 'language-transposition-reference-track',
              title: 'Concert C Blues Reference',
              tempo: 92,
              timeSignature: '4/4',
              formDescription: '12-bar blues reference loop',
              styleLabel: 'Reference',
              keyCenter: 'C blues',
              concertKey: 'C blues',
              writtenKeyForBbSax: 'D blues',
              writtenKeyForEbSax: 'A blues',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Key Translation Accuracy',
                description:
                    'هل تترجم الـ concert key إلى key مكتوبة صحيحة للآلة التي تعزفها؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'اسمع key center',
                description:
                    'استمع إلى backing track ثم سمِّ الـ concert key أولًا قبل تحويلها إلى written key.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد نوع الساكسفون',
                description:
                    'اعرف هل أنت على Bb horn أم Eb horn، ثم حدد what you read مقابل what the band hears.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ root concert ثم written',
                description:
                    'غنّ الـ root كـ concert ثم سمِّ root المكتوبة للـ tenor أو alto.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف blues scale بالتحويل الصحيح',
                description:
                    'اعزف نفس الـ backing مرة كأنك tenor ومرة كأنك alto لتثبت التحويل عمليًا.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'راجع السرعة',
                description:
                    'هل أصبحت الترجمة بين concert/Bb/Eb تلقائية أم ما زالت تحتاج توقفًا طويلًا؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'library-transposition-cheat-sheet',
            title: 'Concert / Bb / Eb Cheat Sheet',
            categoryLabel: 'Reference',
            summary:
                'Quick transposition view for common jazz keys and examples used across lessons and backing tracks.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'The Jazz Theory Book — Mark Levine',
            ],
            concertKey: 'Concert C blues',
            writtenKeyForBbSax: 'D blues',
            writtenKeyForEbSax: 'A blues',
            tags: ['concert pitch', 'Bb', 'Eb', 'tenor', 'alto'],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.listeningTranscription,
    title: 'Listening & Transcription System',
    shortLabel: 'Listening',
    summary:
        'منهج transcription بشري authored: phrase قصيرة، استماع متكرر، غناء، عزف ببطء، تحليل هارموني/إيقاعي/نطقي، نقل لمفتاح جديد، ثم استخدام الفكرة في improvisation.',
    whyItMatters:
        'اللغة الأصلية في الجاز تنتقل بالاستماع قبل أي كتاب. التطبيق هنا لا يولّد AI licks كبديل للمناهج، بل يبني curriculum بشرية ويستخدم AI فقط في feedback عند التسجيل والمراجعة.',
    objectives: [
      'اختيار 1–2 bars فقط بدل مطاردة solo كامل من البداية',
      'تثبيت workflow: Listen → Sing → Play → Identify → Analyze → Move Key → Improvise',
      'تحويل كل phrase مسموعة إلى مادة قابلة للنقل والتطوير على الساكسفون',
      'الحفاظ على النموذج الصحيح: human-authored curriculum + AI-assisted feedback + licensed audio if available + original studies',
    ],
    modules: [
      JazzLessonModule(
        id: 'listening-phrase-capture',
        title: 'Phrase Capture: 1–2 Bar Copying',
        summary:
            'ابدأ دائمًا بـ 1–2 bars فقط: اسمع phrase قصيرة، كررها، غنّها، ثم اعزفها ببطء قبل أي تحليل نظري.',
        keyTakeaways: [
          'Bar واحدة دقيقة أفضل من chorus كامل غير ثابت',
          'الـ singing قبل العزف تمنعك من التحول إلى finger-guessing',
          'المقصد هو السمع والذاكرة والحركة على الآلة، لا جمع licks عشوائية',
        ],
        exercises: [
          JazzExercise(
            id: 'listening-one-bar-phrase-capture',
            title: 'One-Bar Swing Phrase Capture',
            category: ExerciseCategory.transcription,
            goal:
                'نسخ phrase قصيرة جدًا من 1–2 bars عبر السمع، ثم غنائها وعزفها ببطء بدقة rhythm وarticulation.',
            minutes: 15,
            difficulty: DifficultyLevel.beginner,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'F blues',
            writtenKeyForBbSax: 'G blues',
            writtenKeyForEbSax: 'D blues',
            tempoRange: TempoRange(minBpm: 72, maxBpm: 124),
            targetConcepts: [
              '1-bar transcription',
              'repeat listening',
              'sing before play',
              'slow playback on saxophone',
            ],
            backingTrack: BackingTrack(
              id: 'listening-phrase-capture-track',
              title: 'Medium Swing Phrase Capture',
              tempo: 108,
              timeSignature: '4/4',
              formDescription: 'Phrase loop over medium swing blues',
              styleLabel: 'Swing Study',
              keyCenter: 'F blues',
              concertKey: 'F blues',
            ),
            transcriptionTask: TranscriptionTask(
              id: 'transcription-task-phrase-capture-01',
              title: 'Capture a 1-Bar Phrase',
              focus:
                  'listen repeatedly, sing the exact contour, then play slowly',
              minutes: 8,
              audioReference:
                  'Use a short licensed example if available, otherwise use the app’s original phrase loop.',
              instructions: [
                'Choose one short phrase, ideally 1 bar and never more than 2 bars.',
                'Listen to it several times before touching the saxophone.',
                'Sing the phrase exactly with its rhythm and articulation.',
                'Play it back slowly on one note first, then with the real notes.',
                'Check whether the contour and timing match the source.',
              ],
              expectedOutcome:
                  'The player can sing and play the phrase slowly with the same rhythmic shape and attack pattern.',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Phrase Timing Match',
                description:
                    'هل توقيت phrase المنسوخة قريب من المرجع، خصوصًا placement ونهايات الجملة؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.articulation,
                label: 'Attack Match',
                description:
                    'هل attack والghosting والربط في الجملة يشبه المرجع السمعي؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'استمع عدة مرات',
                description:
                    'استمع لنفس phrase خمس مرات متتالية على الأقل قبل أي محاولة عزف.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ phrase',
                description:
                    'غنّ phrase كاملة بنفس rhythm وarticulation قدر الإمكان.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزفها ببطء',
                description:
                    'اعزف phrase ببطء، أولًا على note واحدة ثم بالنغمات الحقيقية.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل replay',
                description:
                    'سجّل أول إعادة عزف لك لتقارن contour والtiming مع المرجع.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم التطابق',
                description:
                    'قارن: هل البداية، الـ upbeat، وشكل النهاية قريبون من المرجع؟',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'أعد phrase واحدة فقط',
                description:
                    'إن لم تتثبت phrase، لا تنتقل إلى material جديدة. أعد نفس الـ 1-bar حتى تصبح مريحة.',
                minutes: 2,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.timeFeel,
              FeedbackDimension.articulation,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'library-transcription-philosophy',
            title: 'Transcription Philosophy',
            categoryLabel: 'Method',
            summary:
                'Preferred model: human-authored curriculum + AI-assisted feedback + licensed audio examples if available + original etudes and studies.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'The Jazz Language — Dan Haerle',
            ],
            tags: ['transcription', 'human-authored', 'ai-assisted feedback'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'listening-analysis-lab',
        title: 'Phrase Analysis Lab',
        summary:
            'بعد التقاط phrase، نحللها: chord tones, approach notes, rhythm, articulation, phrase shape، بدل أن نظل نعيدها بلا فهم.',
        keyTakeaways: [
          'التحليل يأتي بعد السمع والغناء والعزف، لا قبله',
          'المطلوب معرفة لماذا phrase نجحت: target notes؟ approach notes؟ timing؟ shape؟',
        ],
        exercises: [
          JazzExercise(
            id: 'listening-analysis-lab',
            title: 'Analyze Chord Tones, Approaches and Phrase Shape',
            category: ExerciseCategory.transcription,
            goal:
                'تحليل phrase قصيرة بعد نسخها: note content, intervals, chord tones, approach notes, rhythm, articulation, phrase shape.',
            minutes: 17,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'Bb major',
            writtenKeyForBbSax: 'C major',
            writtenKeyForEbSax: 'G major',
            tempoRange: TempoRange(minBpm: 84, maxBpm: 152),
            targetConcepts: [
              'identify notes or intervals',
              'chord tones',
              'approach notes',
              'rhythm',
              'articulation',
              'phrase shape',
            ],
            backingTrack: BackingTrack(
              id: 'listening-analysis-track',
              title: 'ii-V-I Phrase Analysis Loop',
              tempo: 124,
              timeSignature: '4/4',
              formDescription: '2-bar ii-V-I loop',
              styleLabel: 'Swing Analysis',
              keyCenter: 'Bb major',
              concertKey: 'Bb major',
            ),
            transcriptionTask: TranscriptionTask(
              id: 'transcription-task-analysis-01',
              title: 'Analyze a 2-Bar ii-V-I Phrase',
              focus:
                  'notes, intervals, chord tones, approach notes, rhythm, articulation, phrase shape',
              minutes: 9,
              audioReference:
                  'Prefer a short licensed ii-V-I example if available; otherwise use the original app-authored phrase study.',
              instructions: [
                'Write or name the notes after you can sing and play the phrase.',
                'Mark which notes are chord tones and which are approach notes.',
                'Describe the rhythm in words or counts before writing notation.',
                'Notice how articulation changes the phrase shape.',
                'State where the phrase peaks and where it resolves.',
              ],
              expectedOutcome:
                  'The player can explain what makes the phrase work, not only imitate it.',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.chordToneTargeting,
                label: 'Harmonic Understanding',
                description:
                    'هل تستطيع تحديد chord tones وapproach notes بوضوح داخل phrase؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.phraseShape,
                label: 'Phrase Logic',
                description:
                    'هل تفهم أين تبلغ الجملة ذروتها وكيف تحلّ في النهاية؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'استمع للوظيفة',
                description:
                    'اسمع phrase وركّز أين tension وأين resolution عبر الـ ii-V-I.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدّد note roles',
                description:
                    'سمِّ أي note chord tone وأي note approach وأي interval هو المفتاح السمعي.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّ targets',
                description:
                    'غنّ فقط target notes والـ resolution points ثم غنّ phrase كاملة من جديد.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف phrase مع الوعي',
                description:
                    'أعد عزف phrase، لكن الآن وأنت تعرف role كل note فيها.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'ابنِ variation واحدة',
                description:
                    'غيّر rhythm أو ending فقط مع الحفاظ على نفس harmonic logic.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الفهم',
                description:
                    'هل لو غيّرت المفتاح أو progression cell ستبقى logic نفسها مفهومة لك؟',
                minutes: 4,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'listening-key-transfer-and-improv',
        title: 'Key Transfer and Improvisation Transfer',
        summary:
            'الخطوة الحاسمة: انقل الفكرة إلى مفتاح جديد، ثم استخدمها داخل improvisation بدل أن تبقى phrase محفوظة فقط.',
        keyTakeaways: [
          'إذا لم تُنقل phrase إلى مفتاح جديد، فهي ما زالت تقليدًا لا vocabulary',
          'الهدف النهائي من transcription هو improvisation idea transfer',
        ],
        exercises: [
          JazzExercise(
            id: 'listening-transfer-to-keys',
            title: 'Move the Phrase and Use It in Improvisation',
            category: ExerciseCategory.transcription,
            goal:
                'نقل phrase إلى مفتاح جديد ثم استخدامها كفكرة داخل improvisation قصيرة مع الحفاظ على logic وليس النسخ الحرفي فقط.',
            minutes: 18,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            concertKey: 'C major',
            writtenKeyForBbSax: 'D major',
            writtenKeyForEbSax: 'A major',
            tempoRange: TempoRange(minBpm: 76, maxBpm: 168),
            targetConcepts: [
              'move phrase to new key',
              'idea transfer',
              'improvisation application',
              'human-authored curriculum with ai-assisted feedback',
            ],
            backingTrack: BackingTrack(
              id: 'listening-key-transfer-track',
              title: 'Phrase Transfer Progression Lab',
              tempo: 132,
              timeSignature: '4/4',
              formDescription:
                  'Looped cadence and blues cells for idea transfer',
              styleLabel: 'Transfer Lab',
              keyCenter: 'C major / A minor',
              concertKey: 'C major',
            ),
            transcriptionTask: TranscriptionTask(
              id: 'transcription-task-transfer-01',
              title: 'Move, Adapt, Improvise',
              focus:
                  'transpose the phrase, adapt it, then use it in real improvisation',
              minutes: 10,
              audioReference:
                  'Work from the original or licensed short phrase you already captured and analyzed.',
              instructions: [
                'Move the phrase to at least one new key, slowly and accurately.',
                'Keep the rhythmic identity even when the notes change key.',
                'Use the phrase idea inside a new 2-bar or 4-bar improvisation task.',
                'Do not paste the phrase unchanged every time; adapt the ending or the target note.',
                'Record the transfer and compare whether the new version still sounds musical.',
              ],
              expectedOutcome:
                  'The phrase becomes flexible vocabulary that can be moved and developed in improvisation.',
            ),
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Key Transfer Accuracy',
                description:
                    'هل انتقلت الفكرة للمفتاح الجديد من غير تشويه contour أو targets الأساسية؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Vocabulary Transfer',
                description:
                    'هل استخدمت الفكرة كفكرة ارتجالية فعلًا أم كررت phrase حرفيًا من غير تطوير؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.listen,
                title: 'استعد الفكرة الأصلية',
                description:
                    'اسمع phrase الأصلية مرة أخيرة حتى تتأكد أن السمع ما زال يقود النقل.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد ما الذي سينتقل',
                description:
                    'اعرف هل ما ستنقله هو contour أم target notes أم rhythm cell أم articulation shape.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.sing,
                title: 'غنّها في مفتاح جديد',
                description:
                    'غنّ phrase في المفتاح الجديد قبل العزف للتأكد أن النقل سمعي لا finger-pattern فقط.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'اعزف النقل ببطء',
                description:
                    'اعزف phrase في المفتاح الجديد ببطء ثم ارفع السرعة تدريجيًا.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'استخدمها في chorus صغيرة',
                description:
                    'استعمل الفكرة داخل 2–4 bars of improvisation مع ending مختلفة أو rhythm variation.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل transfer take',
                description:
                    'سجّل النسخة المنقولة ثم النسخة المرتجلة لتقارن المرونة والسلاسة.',
                minutes: 2,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'قيّم الاندماج',
                description:
                    'هل أصبحت الفكرة vocabulary مرنة أم ما زالت quote ثابتة لا تتحرك؟',
                minutes: 3,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.earResponse,
              FeedbackDimension.phraseShape,
              FeedbackDimension.formAwareness,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.practiceEngine,
    title: 'Practice Engine',
    shortLabel: 'Engine',
    summary:
        'قلب المنتج: adaptive daily planning, spaced repetition, complexity ladders, micro-goals، وربط آخر أداء بقرار تمرين اليوم.',
    whyItMatters:
        'التحسن لا يأتي من كثرة الوقت فقط، بل من جودة هيكل التدريب. المحرك الجيد يعرف متى يكرر، متى يبطئ، متى يبسط، ومتى يزيد التعقيد.',
    objectives: [
      'توليد خطة يومية من level, sax type, goal, available time, weak areas, recent performance, current course, upcoming lessons',
      'تطبيق spaced repetition rules واضحة بدل التخمين',
      'خفض أو رفع التعقيد حسب النجاح أو التعثر المتكرر',
      'تحويل كل session إلى قرار تدريبي لليوم التالي',
    ],
    modules: [
      JazzLessonModule(
        id: 'practice-engine-daily-builder',
        title: 'Adaptive Daily Plan Builder',
        summary:
            'بناء خطة يومية بحسب المستوى، الآلة، الهدف، الوقت، الضعف، الأداء الحديث، الكورس الحالي، والدروس القادمة.',
        keyTakeaways: [
          'الخطة اليومية ليست template ثابتة؛ هي قرار مبني على مدخلات واضحة',
          'الوقت القصير لا يعني إلغاء العناصر الأساسية، بل ضغطها بذكاء',
        ],
        exercises: [
          JazzExercise(
            id: 'practice-engine-plan-mapping',
            title: 'Map a 30-Minute Session by Goal and Weakness',
            category: ExerciseCategory.reflection,
            goal:
                'بناء session عملية بناءً على level, sax, goal, time, weak areas, recent performance, current course, and upcoming lessons.',
            minutes: 14,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            targetConcepts: [
              'adaptive planning',
              'goal-based session design',
              'time budgeting',
              'weak-area prioritization',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Plan Logic',
                description:
                    'هل ترتيب blocks يخدم الهدف والضعف، أم مجرد قائمة عشوائية من موضوعات؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'حدد المدخلات',
                description:
                    'اكتب level والآلة والهدف والوقت والweak areas وآخر attempt قبل بناء الخطة.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.play,
                title: 'قسّم الوقت',
                description:
                    'وزّع 30 دقيقة على tone, articulation, rhythm, concept work, record/evaluate بحسب priority الحالية.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.improvise,
                title: 'اختر block نهائية',
                description:
                    'اختر blocks تجعل الهدف النهائي doable اليوم، لا idealistic فقط.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'راجع هل الخطة قابلة للتنفيذ',
                description:
                    'هل الخطة مناسبة للوقت فعلاً، وهل فيها block تسجيل/feedback تقود إلى قرار الغد؟',
                minutes: 4,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'practice-engine-example-30min',
            title: '30-Minute Practice Example',
            categoryLabel: 'Planning Template',
            summary:
                'Example: 5 min tone, 5 min articulation, 5 min rhythm on one note, 5 min blues scale in 3 keys, 5 min guide tones over blues, 5 min record improvisation + feedback.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
            ],
            tags: ['30-minute plan', 'daily routine', 'adaptive planning'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'practice-engine-spaced-repetition',
        title: 'Spaced Repetition and Recovery Rules',
        summary:
            'قواعد صريحة: متى نكرر نفس التمرين، متى نبطئ tempo، متى نوجه articulation، ومتى نفتح variation أصعب.',
        keyTakeaways: [
          'القرار التالي يجب أن يخرج من النتيجة السابقة',
          'التكرار الذكي لا يعني إعادة كل شيء؛ يعني إعادة الشيء الصحيح بالشكل الصحيح',
        ],
        exercises: [
          JazzExercise(
            id: 'practice-engine-spaced-rules',
            title: 'Apply Recovery and Progress Rules',
            category: ExerciseCategory.reflection,
            goal:
                'تطبيق قواعد عملية: pitch<80 repeat tomorrow، rhythm<70 reduce 15 BPM، articulation weak → articulation variation، mastery x3 → harder variation.',
            minutes: 12,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            targetConcepts: [
              'spaced repetition',
              'tempo reduction',
              'articulation variation',
              'unlock harder variation',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Tempo Decision',
                description:
                    'هل قرار tempo مبني على rhythm accuracy فعلًا أم على مزاج اليوم؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'اقرأ rule-set',
                description:
                    'طبّق rule مناسبة لكل حالة بدل تعميم نفس العلاج على كل ضعف.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'اربط rule بالأداء',
                description:
                    'اسأل: ماذا تقول الأرقام؟ هل المشكلة pitch أم rhythm أم articulation أم complexity overload؟',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'اختر قرار الغد',
                description:
                    'حدد هل غدًا سيُعاد نفس التمرين، أم tempo أبطأ، أم phrase أصغر، أم variation أصعب.',
                minutes: 5,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.intonation,
              FeedbackDimension.articulation,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'practice-engine-spaced-rules-sheet',
            title: 'Spaced Repetition Rules Sheet',
            categoryLabel: 'Rules',
            summary:
                'Pitch <80%: repeat tomorrow. Rhythm <70%: reduce tempo by 15 BPM. Weak articulation: articulation variation. Mastered 3 times: unlock harder variation. Repeated failure: reduce complexity. Consistent success: increase complexity.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'Patterns for Jazz — Jerry Coker, Jimmy Casale, Gary Campbell, Jerry Greene',
            ],
            tags: ['spaced repetition', 'tempo', 'complexity'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'practice-engine-complexity-ladder',
        title: 'Complexity Ladder',
        summary:
            'لو فشل المستخدم نخفض complexity، ولو نجح نرفعها: slower/faster tempo, fewer/more notes, one-note version, more keys, longer form, backing track, improvisation task.',
        keyTakeaways: [
          'المشكلة أحيانًا ليست في الجهد، بل في أن المستوى الحالي أعلى من readiness',
          'زيادة التعقيد يجب أن تأتي تدريجيًا وبأسباب واضحة',
        ],
        exercises: [
          JazzExercise(
            id: 'practice-engine-complexity-ladder',
            title: 'Scale Complexity Down or Up',
            category: ExerciseCategory.reflection,
            goal:
                'تعلم متى تقلل complexity إلى slower tempo / fewer notes / one-note rhythm / smaller phrase / easier key، ومتى تزيدها إلى faster tempo / more keys / longer form / backing track / improvisation.',
            minutes: 13,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            targetConcepts: [
              'reduce complexity',
              'increase complexity',
              'one-note version',
              'smaller phrase',
              'more keys',
              'longer form',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Complexity Fit',
                description:
                    'هل مستوى المهمة مناسب للحالة الحالية، أم أنها أسهل/أصعب من اللازم؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.understand,
                title: 'افهم ladder',
                description:
                    'رتب versions من one-note rhythm إلى full improvisation مع backing track.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'شخّص موضعك الحالي',
                description:
                    'حدد هل التعثر سببه tempo أم كثرة notes أم كثرة keys أم طول form.',
                minutes: 4,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'اختر النسخة المناسبة',
                description:
                    'خفف أو زِد التعقيد خطوة واحدة فقط، ثم اختبر النتيجة بدلاً من القفز الكبير.',
                minutes: 6,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.timeFeel,
              FeedbackDimension.phraseShape,
            ],
          ),
        ],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.aiAudioFeedback,
    title: 'AI / Audio Feedback Logic',
    shortLabel: 'Feedback',
    summary:
        'طبقة feedback موسيقية تترجم التسجيل إلى مشاكل قابلة للإصلاح في pitch, rhythm, tone, articulation, وimprovisation logic بدل الاكتفاء برقم واحد.',
    whyItMatters:
        'اللاعب يحتاج أن يعرف ماذا يصلح أولًا، وكيف يصلحه موسيقيًا. “71%” لا تكفي. المطلوب تفسير موسيقي + fix عملي + next exercise واضحة.',
    objectives: [
      'فصل feedback إلى pitch / rhythm / tone / articulation / improvisation',
      'كتابة feedback موسيقية قابلة للتنفيذ، لا score فقط',
      'دعم طبقة heuristic حالية يمكن لاحقًا توصيلها بمحرك تحليل صوت حقيقي',
      'ربط كل issue بـ recommended fix وnext exercise id',
    ],
    modules: [
      JazzLessonModule(
        id: 'feedback-musical-diagnostics',
        title: 'Musical Diagnostics',
        summary:
            'تشخيص واضح لمشكلات pitch, rhythm, tone, articulation، مع تفسير موسيقي لاختلال الجملة وسبب ضعفها.',
        keyTakeaways: [
          'المشكلة ليست رقمًا فقط؛ هي موقع الخطأ داخل السمع والtime والattack والshape',
          'Feedback الجيدة تحدد أول أولوية لا كل الأخطاء دفعة واحدة',
        ],
        exercises: [
          JazzExercise(
            id: 'feedback-diagnostic-pass',
            title: 'Diagnostic Pass: Pitch, Rhythm, Tone and Articulation',
            category: ExerciseCategory.recording,
            goal:
                'قراءة نتيجة التسجيل عبر categories واضحة: wrong notes, intonation, unstable long tones, early/late attacks, note duration, offbeat placement, tone stability, articulation issues.',
            minutes: 14,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            targetConcepts: [
              'pitch diagnostics',
              'rhythm diagnostics',
              'tone diagnostics',
              'articulation diagnostics',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.pitch,
                label: 'Problem Identification',
                description:
                    'هل تعرف هل المشكلة wrong note أم intonation أم instability؟',
              ),
              EvaluationCriterion(
                category: FeedbackCategory.rhythm,
                label: 'Timing Diagnosis',
                description:
                    'هل تفرّق بين early/late attack وبين note duration أو offbeat placement؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل take قصيرة',
                description:
                    'سجّل phrase أو chorus قصيرة حتى يصبح diagnosis محددًا وواضحًا.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'صنّف الخطأ',
                description:
                    'حدّد هل الخلل Pitch أم Rhythm أم Tone أم Articulation، ثم اختر أول أولوية فقط.',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'طبّق fix واحدة',
                description:
                    'لا تصلح كل شيء دفعة واحدة. اختر fix عملية واحدة ثم أعد take جديدة فورًا.',
                minutes: 6,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.toneCenter,
              FeedbackDimension.timeFeel,
              FeedbackDimension.articulation,
              FeedbackDimension.earResponse,
            ],
          ),
        ],
        libraryItems: [
          LibraryItem(
            id: 'feedback-model-reference',
            title: 'Feedback Model Reference',
            categoryLabel: 'Model',
            summary:
                'Each feedback item carries: score, category, issue, musical explanation, recommended fix, and next exercise id.',
            sourceInspiration: [
              'Jamey Aebersold Jazz Handbook',
              'The Jazz Theory Book — Mark Levine',
            ],
            tags: ['feedback model', 'musical diagnostics'],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'feedback-improv-coaching',
        title: 'Improvisation Coaching',
        summary:
            'feedback خاصة بالارتجال: chord tone targeting, phrase length, use of space, repetition, motivic development, rhythmic variety, resolution quality.',
        keyTakeaways: [
          'الارتجال لا يُقيَّم فقط من عدد النغمات الصحيحة',
          'الجملة قد تكون صحيحة نغميًا لكنها ضعيفة في الـ space أو الـ resolution أو الـ motif logic',
        ],
        exercises: [
          JazzExercise(
            id: 'feedback-improv-review',
            title: 'Improvisation Review Loop',
            category: ExerciseCategory.recording,
            goal:
                'تحويل improvisation feedback إلى توصية ملموسة: phrase أقصر، space أوضح، target notes أقوى، أو rhythmic variety أفضل.',
            minutes: 13,
            difficulty: DifficultyLevel.intermediate,
            suggestedSaxTypes: [
              SaxType.altoEb,
              SaxType.tenorBb,
              SaxType.sopranoBb,
              SaxType.baritoneEb,
            ],
            targetConcepts: [
              'chord tone targeting',
              'phrase length',
              'use of space',
              'repetition',
              'motivic development',
              'rhythmic variety',
              'resolution quality',
            ],
            evaluationCriteria: [
              EvaluationCriterion(
                category: FeedbackCategory.improvisationLogic,
                label: 'Musical Decision Quality',
                description:
                    'هل الfeedback تترجم إلى قرار عزف واضح في المحاولة التالية؟',
              ),
            ],
            steps: [
              JazzPracticeStep(
                stage: LearningLoopStage.record,
                title: 'سجّل chorus قصيرة',
                description:
                    'سجّل improvisation قصيرة حتى يكون analysis على phrase structure لا على stamina فقط.',
                minutes: 3,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.evaluate,
                title: 'اسأل سؤالًا واحدًا',
                description:
                    'هل المشكلة الأساسية target notes، أم كثرة notes، أم غياب motif أو space؟',
                minutes: 5,
              ),
              JazzPracticeStep(
                stage: LearningLoopStage.repeat,
                title: 'أعد chorus مع constraint',
                description:
                    'أعد المحاولة مع constraint واضح: fewer notes أو one motif أو cleaner resolution.',
                minutes: 5,
              ),
            ],
            feedbackDimensions: [
              FeedbackDimension.formAwareness,
              FeedbackDimension.phraseShape,
              FeedbackDimension.bluesLanguage,
            ],
          ),
        ],
      ),
      JazzLessonModule(
        id: 'feedback-service-architecture',
        title: 'Heuristic Now, Real Analysis Later',
        summary:
            'المشروع حاليًا يستخدم feedback logic heuristics فوق التسجيل والتقييم المتاحين، لكن الواجهات نظيفة لتوصيل pitch/rhythm/tone analyzers حقيقية لاحقًا.',
        keyTakeaways: [
          'الـ curriculum بشرية authored، والـ AI هنا أداة تحليل ومساعدة لا مولّد licks عشوائي',
          'licensed audio examples يمكن ربطها لاحقًا، وكذلك waveform/pitch/rhythm analyzers حقيقية',
        ],
        exercises: [],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.libraryReference,
    title: 'Library / Reference System',
    shortLabel: 'Library',
    summary:
        'مكتبة مرجعية للأصابع، الإيقاع، guide tones، blues cells، والتونات الأساسية.',
    whyItMatters:
        'المتعلم يحتاج مرجعاً سريعاً يعود له أثناء التدريب وليس فقط داخل الدروس.',
    objectives: [
      'تنظيم المعرفة المرجعية',
      'الوصول السريع للمعلومة أثناء التمرين',
      'تحويل المرجع إلى tool يومية',
    ],
    modules: [
      JazzLessonModule(
        id: 'reference-fingering',
        title: 'Fingering & Staff Reference',
        summary: 'مرجع فوري للأصابع والمدرج والنغمات الأساسية.',
        keyTakeaways: [
          'المرجع يجب أن يكون سريعاً وواضحاً',
          'الوضوح البصري يختصر وقتًا في التدريب',
        ],
        exercises: [],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.progressTracking,
    title: 'Progress Tracking',
    shortLabel: 'Progress',
    summary:
        'تتبع الأيام، المحاولات، blocks المنجزة، وتحوّل المهارات عبر الوقت.',
    whyItMatters: 'الإحساس بالتقدم الحقيقي يثبت العادة ويكشف مناطق الضعف.',
    objectives: [
      'ربط كل جلسة بهدف',
      'قياس الاستمرارية',
      'رؤية التحسن note-by-note وليس يومًا بيوم فقط',
    ],
    modules: [
      JazzLessonModule(
        id: 'progress-review',
        title: 'Weekly Review Logic',
        summary: 'مراجعة ما تم تعلمه وما يحتاج تكرارًا.',
        keyTakeaways: [
          'التقدم ليس خطيًا',
          'المراجعة المنتظمة تمنع التشتت',
        ],
        exercises: [],
      ),
    ],
  ),
  JazzPillarTrack(
    id: JazzPillarId.dailyPracticeGenerator,
    title: 'Daily Practice Generator',
    shortLabel: 'Generator',
    summary:
        'خطة يومية ديناميكية تجمع listening, singing, playing, improvising, recording, evaluation.',
    whyItMatters:
        'اللاعب يحتاج خطة تنفيذية واضحة كل يوم، لا مجرد قائمة موضوعات عامة.',
    objectives: [
      'تخصيص جلسة اليوم',
      'الحفاظ على فلسفة التعلم الكاملة',
      'الربط بين التقدم والقرار التالي',
    ],
    modules: [
      JazzLessonModule(
        id: 'daily-plan-logic',
        title: 'Daily Loop Builder',
        summary: 'بناء جلسة متوازنة من آخر بيانات التدريب.',
        keyTakeaways: [
          'الاختيار اليومي يجب أن يكون له سبب',
          'كل block تخدم block أخرى بعدها',
        ],
        exercises: [],
      ),
    ],
  ),
];
