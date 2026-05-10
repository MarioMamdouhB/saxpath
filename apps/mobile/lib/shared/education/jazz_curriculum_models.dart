enum JazzPillarId {
  saxophoneFoundation,
  jazzTheoryCore,
  swingRhythmEngine,
  bluesCurriculum,
  improvisationSystem,
  repertoireTuneStudy,
  saxophoneJazzLanguage,
  listeningTranscription,
  practiceEngine,
  aiAudioFeedback,
  libraryReference,
  progressTracking,
  dailyPracticeGenerator,
}

enum ContentType {
  lesson,
  exercise,
  backingTrack,
  practicePlan,
  practiceSession,
  tuneStudy,
  transcriptionTask,
  etude,
  rhythmPattern,
  scaleStudy,
  chordStudy,
  improvisationPrompt,
  feedbackResult,
  libraryItem,
}

enum ConceptMusicContextType {
  blues,
  iiVI,
  jazzStandardProgression,
  bebopLine,
  saxEtude,
  earTraining,
  backingTrack,
  rhythmExercise,
  improvisationPrompt,
}

enum SkillArea {
  tone,
  technique,
  articulation,
  rhythm,
  swing,
  blues,
  theory,
  earTraining,
  improvisation,
  transcription,
  repertoire,
  saxLanguage,
  feedback,
}

enum DifficultyLevel {
  beginner,
  earlyIntermediate,
  intermediate,
  advanced,
}

enum TuneFormType {
  aaba,
  abac,
  twelveBarBlues,
  rhythmChanges,
  modalVamp,
  throughComposedCycle,
}

enum SaxType {
  altoEb,
  tenorBb,
  sopranoBb,
  baritoneEb,
}

enum LessonStepType {
  listen,
  understand,
  sing,
  play,
  analyze,
  improvise,
  record,
  evaluate,
  repeat,
}

enum ExerciseType {
  longTone,
  overtone,
  scale,
  arpeggio,
  articulation,
  rhythmPlayback,
  swingSubdivision,
  bluesPhrase,
  guideTone,
  chordToneSoloing,
  iiVI,
  transcription,
  callAndResponse,
  etude,
  backingTrackImprovisation,
}

enum FeedbackCategory {
  pitch,
  intonation,
  rhythm,
  swingFeel,
  articulation,
  tone,
  phraseShape,
  improvisationLogic,
  chordToneTargeting,
}

enum RhythmTrainerMode {
  clapBack,
  playBackOneNote,
  playRhythmUsingScale,
  improviseTwoBarsSameRhythm,
}

enum RepeatRecommendationType {
  retrySameTempo,
  slowerTempo,
  easierVariation,
  harderVariation,
  nextLesson,
}

enum PracticeGoal {
  betterSwing,
  betterBluesImprovisation,
  strongerTone,
  cleanerArticulation,
  transcriptionGrowth,
  repertoireFluency,
  balancedDevelopment,
}

enum PracticeAdaptationType {
  repeatTomorrow,
  reduceTempo,
  articulationVariation,
  unlockHarderVariation,
  reduceComplexity,
  increaseComplexity,
}

enum SkillTreeNodeStatus {
  locked,
  available,
  inProgress,
  mastered,
}

enum AudioFeedbackIssue {
  wrongNote,
  intonationSharp,
  intonationFlat,
  unstableLongTones,
  earlyAttack,
  lateAttack,
  noteDuration,
  swingRatio,
  offbeatPlacement,
  pulseConsistency,
  toneConsistency,
  breathNoise,
  dynamicControl,
  toneStability,
  registerQuality,
  articulationTooHeavy,
  articulationTooLegato,
  missingAccents,
  unclearGhostNotes,
  poorPhraseEndings,
  chordToneTargeting,
  phraseLength,
  useOfSpace,
  repetition,
  motivicDevelopment,
  rhythmicVariety,
  resolutionQuality,
}

enum LearningLoopStage {
  listen,
  understand,
  sing,
  play,
  improvise,
  record,
  evaluate,
  repeat,
}

enum ExerciseCategory {
  listening,
  earTraining,
  theory,
  rhythm,
  technique,
  improvisation,
  repertoire,
  transcription,
  recording,
  reflection,
}

enum FeedbackDimension {
  toneCenter,
  timeFeel,
  swingPlacement,
  articulation,
  intonation,
  phraseShape,
  bluesLanguage,
  formAwareness,
  earResponse,
}

class LessonStep {
  const LessonStep({
    required this.type,
    required this.title,
    required this.description,
    this.minutes = 0,
    this.listenPrompt,
    this.singPrompt,
    this.playPrompt,
    this.evaluatePrompt,
  });

  final LessonStepType type;
  final String title;
  final String description;
  final int minutes;
  final String? listenPrompt;
  final String? singPrompt;
  final String? playPrompt;
  final String? evaluatePrompt;

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      type: lessonStepTypeFromName(json['type'] as String? ?? 'play'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
      listenPrompt: json['listen_prompt'] as String?,
      singPrompt: json['sing_prompt'] as String?,
      playPrompt: json['play_prompt'] as String?,
      evaluatePrompt: json['evaluate_prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'minutes': minutes,
      'listen_prompt': listenPrompt,
      'sing_prompt': singPrompt,
      'play_prompt': playPrompt,
      'evaluate_prompt': evaluatePrompt,
    };
  }
}

class BackingTrack {
  const BackingTrack({
    required this.id,
    required this.title,
    required this.tempo,
    required this.timeSignature,
    required this.formDescription,
    required this.styleLabel,
    this.form,
    this.keyCenter,
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.audioUrl,
    this.choruses,
    this.hasCountIn = false,
    this.loopEnabled = true,
  });

  final String id;
  final String title;
  final int tempo;
  final String timeSignature;
  final String formDescription;
  final String styleLabel;
  final String? form;
  final String? keyCenter;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final String? audioUrl;
  final int? choruses;
  final bool hasCountIn;
  final bool loopEnabled;

  factory BackingTrack.fromJson(Map<String, dynamic> json) {
    return BackingTrack(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ??
          '${json['style'] ?? json['style_label'] ?? 'Backing Track'}',
      tempo: json['tempo'] as int? ?? 0,
      timeSignature:
          (json['time_signature'] ?? json['meter']) as String? ?? '4/4',
      formDescription:
          (json['form_description'] ?? json['form']) as String? ?? '',
      styleLabel: (json['style_label'] ?? json['style']) as String? ?? '',
      form: json['form'] as String?,
      keyCenter: json['key_center'] as String?,
      concertKey: json['concert_key'] as String?,
      writtenKeyForBbSax: (json['written_key_for_bb_sax'] ??
          json['written_key_for_tenor']) as String?,
      writtenKeyForEbSax: (json['written_key_for_eb_sax'] ??
          json['written_key_for_alto']) as String?,
      audioUrl: json['audio_url'] as String?,
      choruses: json['choruses'] as int?,
      hasCountIn:
          (json['has_count_in'] ?? json['hasCountIn']) as bool? ?? false,
      loopEnabled: json['loop_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tempo': tempo,
      'time_signature': timeSignature,
      'meter': timeSignature,
      'form': form ?? formDescription,
      'form_description': formDescription,
      'style': styleLabel,
      'style_label': styleLabel,
      'key_center': keyCenter,
      'concert_key': concertKey,
      'written_key_for_bb_sax': writtenKeyForBbSax,
      'written_key_for_eb_sax': writtenKeyForEbSax,
      'written_key_for_tenor': writtenKeyForBbSax,
      'written_key_for_alto': writtenKeyForEbSax,
      'audio_url': audioUrl,
      'choruses': choruses,
      'has_count_in': hasCountIn,
      'hasCountIn': hasCountIn,
      'loop_enabled': loopEnabled,
    };
  }

  ContentType get contentType => ContentType.backingTrack;

  String? keyForSax(SaxType saxType) => resolveKeyForSax(
        saxType,
        concertKey: concertKey ?? keyCenter,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );

  Map<String, String> get transpositionSummary => buildTranspositionSummary(
        concertKey: concertKey ?? keyCenter,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );
}

class TempoRange {
  const TempoRange({
    required this.minBpm,
    required this.maxBpm,
  });

  final int minBpm;
  final int maxBpm;

  factory TempoRange.fromJson(dynamic json) {
    if (json is List && json.length >= 2) {
      return TempoRange(
        minBpm: (json[0] as num?)?.toInt() ?? 0,
        maxBpm: (json[1] as num?)?.toInt() ?? 0,
      );
    }

    if (json is Map<String, dynamic>) {
      return TempoRange(
        minBpm: (json['min_bpm'] as num?)?.toInt() ?? 0,
        maxBpm: (json['max_bpm'] as num?)?.toInt() ?? 0,
      );
    }

    return const TempoRange(minBpm: 0, maxBpm: 0);
  }

  List<int> toJson() => [minBpm, maxBpm];

  bool get isSingleTempo => minBpm > 0 && minBpm == maxBpm;
}

class EvaluationCriterion {
  const EvaluationCriterion({
    required this.category,
    required this.label,
    required this.description,
  });

  final FeedbackCategory category;
  final String label;
  final String description;

  factory EvaluationCriterion.fromJson(Map<String, dynamic> json) {
    return EvaluationCriterion(
      category: feedbackCategoryFromName(
        json['category'] as String? ?? 'tone',
      ),
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'label': label,
      'description': description,
    };
  }
}

class FlowRecommendation {
  const FlowRecommendation({
    required this.type,
    required this.label,
    required this.description,
    this.targetLessonId,
  });

  final RepeatRecommendationType type;
  final String label;
  final String description;
  final String? targetLessonId;

  factory FlowRecommendation.fromJson(Map<String, dynamic> json) {
    return FlowRecommendation(
      type: repeatRecommendationTypeFromName(
        json['type'] as String? ?? 'retrySameTempo',
      ),
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetLessonId: json['target_lesson_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'label': label,
      'description': description,
      'target_lesson_id': targetLessonId,
    };
  }
}

class EducationalFlowStage {
  const EducationalFlowStage({
    required this.type,
    required this.title,
    required this.description,
    this.minutes = 0,
    this.isGenerated = false,
    this.evaluationCategories = const [],
    this.recommendations = const [],
  });

  final LessonStepType type;
  final String title;
  final String description;
  final int minutes;
  final bool isGenerated;
  final List<FeedbackCategory> evaluationCategories;
  final List<FlowRecommendation> recommendations;

  factory EducationalFlowStage.fromJson(Map<String, dynamic> json) {
    return EducationalFlowStage(
      type: lessonStepTypeFromName(json['type'] as String? ?? 'play'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
      isGenerated: json['is_generated'] as bool? ?? false,
      evaluationCategories:
          ((json['evaluation_categories'] as List?) ?? const [])
              .map((item) => feedbackCategoryFromName(item.toString()))
              .toList(growable: false),
      recommendations: ((json['recommendations'] as List?) ?? const [])
          .map(
            (item) => FlowRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'minutes': minutes,
      'is_generated': isGenerated,
      'evaluation_categories':
          evaluationCategories.map((item) => item.name).toList(),
      'recommendations': recommendations.map((item) => item.toJson()).toList(),
    };
  }
}

class EducationalFlow {
  const EducationalFlow({
    required this.stages,
  });

  final List<EducationalFlowStage> stages;

  factory EducationalFlow.fromJson(Map<String, dynamic> json) {
    return EducationalFlow(
      stages: ((json['stages'] as List?) ?? const [])
          .map(
            (item) =>
                EducationalFlowStage.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stages': stages.map((item) => item.toJson()).toList(),
    };
  }
}

class TranscriptionTask {
  const TranscriptionTask({
    required this.id,
    required this.title,
    required this.focus,
    required this.minutes,
    required this.instructions,
    this.audioReference,
    this.expectedOutcome,
  });

  final String id;
  final String title;
  final String focus;
  final int minutes;
  final List<String> instructions;
  final String? audioReference;
  final String? expectedOutcome;

  factory TranscriptionTask.fromJson(Map<String, dynamic> json) {
    return TranscriptionTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
      instructions: ((json['instructions'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      audioReference: json['audio_reference'] as String?,
      expectedOutcome: json['expected_outcome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'focus': focus,
      'minutes': minutes,
      'instructions': instructions,
      'audio_reference': audioReference,
      'expected_outcome': expectedOutcome,
    };
  }

  ContentType get contentType => ContentType.transcriptionTask;
}

class TuneStudy {
  const TuneStudy({
    required this.id,
    required this.title,
    required this.focus,
    required this.whyItMatters,
    required this.formType,
    required this.difficulty,
    required this.skillAreas,
    this.backingTrack,
    this.formDescription,
    this.keyCenters = const [],
    this.cadences = const [],
    this.commonProgressions = const [],
    this.guideToneMap = const [],
    this.chordTonePractice = const [],
    this.rhythmOnlyImprovisation = const [],
    this.motifDevelopmentPrompts = const [],
    this.listeningGoals = const [],
    this.improvisationGoals = const [],
    this.suggestedListening = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original tune study framework inspired by jazz repertoire traditions without reproducing copyrighted melodies or charts.',
    this.isOriginalContent = true,
  });

  final String id;
  final String title;
  final String focus;
  final String whyItMatters;
  final TuneFormType formType;
  final DifficultyLevel difficulty;
  final List<SkillArea> skillAreas;
  final BackingTrack? backingTrack;
  final String? formDescription;
  final List<String> keyCenters;
  final List<String> cadences;
  final List<String> commonProgressions;
  final List<String> guideToneMap;
  final List<String> chordTonePractice;
  final List<String> rhythmOnlyImprovisation;
  final List<String> motifDevelopmentPrompts;
  final List<String> listeningGoals;
  final List<String> improvisationGoals;
  final List<String> suggestedListening;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  factory TuneStudy.fromJson(Map<String, dynamic> json) {
    return TuneStudy(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      whyItMatters: json['why_it_matters'] as String? ?? '',
      formType: tuneFormTypeFromName(json['form_type'] as String? ?? 'aaba'),
      difficulty: difficultyLevelFromName(
        json['difficulty'] as String? ?? 'beginner',
      ),
      skillAreas: ((json['skill_areas'] as List?) ?? const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(
              json['backing_track'] as Map<String, dynamic>,
            )
          : null,
      formDescription: json['form_description'] as String?,
      keyCenters: ((json['key_centers'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      cadences: ((json['cadences'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      commonProgressions: ((json['common_progressions'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      guideToneMap: ((json['guide_tone_map'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      chordTonePractice: ((json['chord_tone_practice'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      rhythmOnlyImprovisation:
          ((json['rhythm_only_improvisation'] as List?) ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      motifDevelopmentPrompts:
          ((json['motif_development_prompts'] as List?) ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      listeningGoals: ((json['listening_goals'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      improvisationGoals: ((json['improvisation_goals'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      suggestedListening: ((json['suggested_listening'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original tune study framework inspired by jazz repertoire traditions without reproducing copyrighted melodies or charts.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'focus': focus,
      'why_it_matters': whyItMatters,
      'form_type': formType.name,
      'difficulty': difficulty.name,
      'skill_areas': skillAreas.map((item) => item.name).toList(),
      'backing_track': backingTrack?.toJson(),
      'form_description': formDescription,
      'key_centers': keyCenters,
      'cadences': cadences,
      'common_progressions': commonProgressions,
      'guide_tone_map': guideToneMap,
      'chord_tone_practice': chordTonePractice,
      'rhythm_only_improvisation': rhythmOnlyImprovisation,
      'motif_development_prompts': motifDevelopmentPrompts,
      'listening_goals': listeningGoals,
      'improvisation_goals': improvisationGoals,
      'suggested_listening': suggestedListening,
      'source_inspiration': sourceInspiration,
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
    };
  }

  ContentType get contentType => ContentType.tuneStudy;

  TuneStudy copyWith({
    BackingTrack? backingTrack,
    List<String>? sourceInspiration,
    String? originalityNote,
    bool? isOriginalContent,
  }) {
    return TuneStudy(
      id: id,
      title: title,
      focus: focus,
      whyItMatters: whyItMatters,
      formType: formType,
      difficulty: difficulty,
      skillAreas: skillAreas,
      backingTrack: backingTrack ?? this.backingTrack,
      formDescription: formDescription,
      keyCenters: keyCenters,
      cadences: cadences,
      commonProgressions: commonProgressions,
      guideToneMap: guideToneMap,
      chordTonePractice: chordTonePractice,
      rhythmOnlyImprovisation: rhythmOnlyImprovisation,
      motifDevelopmentPrompts: motifDevelopmentPrompts,
      listeningGoals: listeningGoals,
      improvisationGoals: improvisationGoals,
      suggestedListening: suggestedListening,
      sourceInspiration: sourceInspiration ?? this.sourceInspiration,
      originalityNote: originalityNote ?? this.originalityNote,
      isOriginalContent: isOriginalContent ?? this.isOriginalContent,
    );
  }
}

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.categoryLabel,
    required this.summary,
    required this.sourceInspiration,
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.authorOrTradition,
    this.copyrightNote,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String categoryLabel;
  final String summary;
  final List<String> sourceInspiration;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final String? authorOrTradition;
  final String? copyrightNote;
  final List<String> tags;

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      concertKey: json['concert_key'] as String?,
      writtenKeyForBbSax: (json['written_key_for_bb_sax'] ??
          json['written_key_for_tenor']) as String?,
      writtenKeyForEbSax: (json['written_key_for_eb_sax'] ??
          json['written_key_for_alto']) as String?,
      authorOrTradition: json['author_or_tradition'] as String?,
      copyrightNote: json['copyright_note'] as String?,
      tags: ((json['tags'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category_label': categoryLabel,
      'summary': summary,
      'source_inspiration': sourceInspiration,
      'concert_key': concertKey,
      'written_key_for_bb_sax': writtenKeyForBbSax,
      'written_key_for_eb_sax': writtenKeyForEbSax,
      'written_key_for_tenor': writtenKeyForBbSax,
      'written_key_for_alto': writtenKeyForEbSax,
      'author_or_tradition': authorOrTradition,
      'copyright_note': copyrightNote,
      'tags': tags,
    };
  }

  ContentType get contentType => ContentType.libraryItem;

  String? keyForSax(SaxType saxType) => resolveKeyForSax(
        saxType,
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );

  Map<String, String> get transpositionSummary => buildTranspositionSummary(
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );
}

class ProgressMetric {
  const ProgressMetric({
    required this.id,
    required this.label,
    required this.skillArea,
    required this.currentValue,
    required this.targetValue,
    this.unit = '%',
    this.lastUpdatedAt,
  });

  final String id;
  final String label;
  final SkillArea skillArea;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime? lastUpdatedAt;

  factory ProgressMetric.fromJson(Map<String, dynamic> json) {
    return ProgressMetric(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      skillArea: skillAreaFromName(json['skill_area'] as String? ?? 'feedback'),
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0,
      targetValue: (json['target_value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '%',
      lastUpdatedAt:
          DateTime.tryParse(json['last_updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'skill_area': skillArea.name,
      'current_value': currentValue,
      'target_value': targetValue,
      'unit': unit,
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
    };
  }
}

class AudioFeedbackResult {
  const AudioFeedbackResult({
    required this.id,
    required this.exerciseId,
    required this.overallScore,
    required this.categories,
    required this.summary,
    required this.nextStep,
    this.insights = const [],
    this.recordingUrl,
  });

  final String id;
  final String exerciseId;
  final double overallScore;
  final List<FeedbackCategoryScore> categories;
  final String summary;
  final String nextStep;
  final List<AudioFeedbackInsight> insights;
  final String? recordingUrl;

  ContentType get contentType => ContentType.feedbackResult;
}

class FeedbackCategoryScore {
  const FeedbackCategoryScore({
    required this.category,
    required this.score,
    required this.note,
  });

  final FeedbackCategory category;
  final double score;
  final String note;

  factory FeedbackCategoryScore.fromJson(Map<String, dynamic> json) {
    return FeedbackCategoryScore(
      category: feedbackCategoryFromName(json['category'] as String? ?? 'tone'),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'score': score,
      'note': note,
    };
  }
}

class AudioFeedbackInsight {
  const AudioFeedbackInsight({
    required this.score,
    required this.category,
    required this.issue,
    required this.musicalExplanation,
    required this.recommendedFix,
    this.nextExerciseId,
  });

  final int score;
  final FeedbackCategory category;
  final AudioFeedbackIssue issue;
  final String musicalExplanation;
  final String recommendedFix;
  final String? nextExerciseId;

  factory AudioFeedbackInsight.fromJson(Map<String, dynamic> json) {
    return AudioFeedbackInsight(
      score: json['score'] as int? ?? 0,
      category: feedbackCategoryFromName(json['category'] as String? ?? 'tone'),
      issue:
          audioFeedbackIssueFromName(json['issue'] as String? ?? 'wrongNote'),
      musicalExplanation: json['musical_explanation'] as String? ?? '',
      recommendedFix: json['recommended_fix'] as String? ?? '',
      nextExerciseId: json['next_exercise_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'category': category.name,
      'issue': issue.name,
      'musical_explanation': musicalExplanation,
      'recommended_fix': recommendedFix,
      'next_exercise_id': nextExerciseId,
    };
  }
}

class SaxTransposition {
  const SaxTransposition({
    required this.saxType,
    required this.writtenToConcertSemitoneOffset,
    required this.displayLabel,
  });

  final SaxType saxType;
  final int writtenToConcertSemitoneOffset;
  final String displayLabel;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    required this.type,
    required this.skillAreas,
    required this.difficulty,
    required this.goal,
    required this.minutes,
    required this.steps,
    this.bars,
    this.meter = '4/4',
    this.swing = false,
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.targetConcepts = const [],
    this.feedbackCategories = const [],
    this.evaluationCriteria = const [],
    this.rhythmTrainerModes = const [],
    this.feelNotes = const [],
    this.suggestedSaxTypes = const [],
    this.backingTrack,
    this.transcriptionTask,
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original exercise content inspired by serious jazz pedagogy.',
    this.isOriginalContent = true,
    this.flow,
  });

  final String id;
  final String title;
  final ExerciseType type;
  final List<SkillArea> skillAreas;
  final DifficultyLevel difficulty;
  final String goal;
  final int minutes;
  final List<LessonStep> steps;
  final int? bars;
  final String meter;
  final bool swing;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final TempoRange tempoRange;
  final List<String> targetConcepts;
  final List<FeedbackCategory> feedbackCategories;
  final List<EvaluationCriterion> evaluationCriteria;
  final List<RhythmTrainerMode> rhythmTrainerModes;
  final List<String> feelNotes;
  final List<SaxType> suggestedSaxTypes;
  final BackingTrack? backingTrack;
  final TranscriptionTask? transcriptionTask;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;
  final EducationalFlow? flow;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: exerciseTypeFromName(json['type'] as String? ?? 'etude'),
      skillAreas: (((json['skill_areas'] ??
                  json['target_skills'] ??
                  json['targetSkills']) as List?) ??
              const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      difficulty: difficultyLevelFromValue(json['difficulty']),
      goal: json['goal'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
      steps: ((json['steps'] as List?) ?? const [])
          .map((item) => LessonStep.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      bars: json['bars'] as int?,
      meter: (json['meter'] ?? json['time_signature']) as String? ?? '4/4',
      swing: json['swing'] as bool? ?? false,
      concertKey: json['concert_key'] as String?,
      writtenKeyForBbSax: (json['written_key_for_bb_sax'] ??
          json['written_key_for_tenor']) as String?,
      writtenKeyForEbSax: (json['written_key_for_eb_sax'] ??
          json['written_key_for_alto']) as String?,
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      targetConcepts: ((json['target_concepts'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      feedbackCategories:
          (((json['feedback_categories'] ?? json['evaluation']) as List?) ??
                  const [])
              .map((item) => feedbackCategoryFromName(item.toString()))
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      rhythmTrainerModes: ((json['rhythm_trainer_modes'] as List?) ?? const [])
          .map((item) => rhythmTrainerModeFromName(item.toString()))
          .toList(growable: false),
      feelNotes: ((json['feel_notes'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(
              json['backing_track'] as Map<String, dynamic>,
            )
          : null,
      transcriptionTask: json['transcription_task'] is Map<String, dynamic>
          ? TranscriptionTask.fromJson(
              json['transcription_task'] as Map<String, dynamic>,
            )
          : null,
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original exercise content inspired by serious jazz pedagogy.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
      flow: json['flow'] is Map<String, dynamic>
          ? EducationalFlow.fromJson(json['flow'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'skill_areas': skillAreas.map((item) => item.name).toList(),
      'difficulty': difficulty.name,
      'difficulty_rank': difficulty.numericLevel,
      'goal': goal,
      'minutes': minutes,
      'steps': steps.map((item) => item.toJson()).toList(),
      'bars': bars,
      'meter': meter,
      'time_signature': meter,
      'swing': swing,
      'concert_key': concertKey,
      'written_key_for_bb_sax': writtenKeyForBbSax,
      'written_key_for_eb_sax': writtenKeyForEbSax,
      'written_key_for_tenor': writtenKeyForBbSax,
      'written_key_for_alto': writtenKeyForEbSax,
      'tempo_range': tempoRange.toJson(),
      'tempo': tempo,
      'target_concepts': targetConcepts,
      'target_skills': skillAreas.map((item) => item.name).toList(),
      'feedback_categories':
          feedbackCategories.map((item) => item.name).toList(),
      'evaluation': feedbackCategories.map((item) => item.name).toList(),
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'rhythm_trainer_modes':
          rhythmTrainerModes.map((item) => item.name).toList(),
      'feel_notes': feelNotes,
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'backing_track': backingTrack?.toJson(),
      'transcription_task': transcriptionTask?.toJson(),
      'source_inspiration': sourceInspiration,
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
      'flow': resolvedFlow.toJson(),
    };
  }

  ContentType get contentType => ContentType.exercise;

  int? get tempo => tempoRange.isSingleTempo ? tempoRange.minBpm : null;

  EducationalFlow get resolvedFlow {
    if (flow != null) {
      return flow!;
    }

    return EducationalFlow(
      stages: buildEducationalFlowStages(
        steps: steps,
        title: title,
        concepts: const [],
        evaluationCategories: feedbackCategories,
      ),
    );
  }

  String? keyForSax(SaxType saxType) => resolveKeyForSax(
        saxType,
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );

  Map<String, String> get transpositionSummary => buildTranspositionSummary(
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.skillAreas,
    required this.concepts,
    required this.sourceInspiration,
    required this.saxTypes,
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    required this.steps,
    required this.exercises,
    this.backingTrackReferences = const [],
    this.evaluationCriteria = const [],
    this.nextRecommendedLessons = const [],
    this.tuneStudies = const [],
    this.conceptToMusicMaps = const [],
    this.libraryItems = const [],
    this.originalityNote =
        'Original lesson flow inspired by serious jazz and saxophone pedagogy.',
    this.isOriginalContent = true,
    this.flow,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: difficultyLevelFromName(json['level'] as String? ?? 'beginner'),
      skillAreas: ((json['skill_areas'] as List?) ?? const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      concepts: ((json['concepts'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      saxTypes: ((json['sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      concertKey: json['concert_key'] as String?,
      writtenKeyForBbSax: (json['written_key_for_bb_sax'] ??
          json['written_key_for_tenor']) as String?,
      writtenKeyForEbSax: (json['written_key_for_eb_sax'] ??
          json['written_key_for_alto']) as String?,
      tempoRange: TempoRange.fromJson(json['tempo_range']),
      steps: ((json['steps'] as List?) ?? const []).map((item) {
        if (item is String) {
          return LessonStep(
            type: lessonStepTypeFromName(item),
            title: item,
            description: item,
          );
        }
        return LessonStep.fromJson(item as Map<String, dynamic>);
      }).toList(growable: false),
      exercises: ((json['exercises'] as List?) ?? const [])
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      backingTrackReferences:
          ((json['backing_track_references'] as List?) ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      nextRecommendedLessons:
          ((json['next_recommended_lessons'] as List?) ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      tuneStudies: ((json['tune_studies'] as List?) ?? const [])
          .map((item) => TuneStudy.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      conceptToMusicMaps: ((json['concept_to_music_maps'] as List?) ?? const [])
          .map(
            (item) => ConceptToMusicMap.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      libraryItems: ((json['library_items'] as List?) ?? const [])
          .map((item) => LibraryItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original lesson flow inspired by serious jazz and saxophone pedagogy.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
      flow: json['flow'] is Map<String, dynamic>
          ? EducationalFlow.fromJson(json['flow'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String title;
  final String description;
  final DifficultyLevel level;
  final List<SkillArea> skillAreas;
  final List<String> concepts;
  final List<String> sourceInspiration;
  final List<SaxType> saxTypes;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final TempoRange tempoRange;
  final List<LessonStep> steps;
  final List<Exercise> exercises;
  final List<String> backingTrackReferences;
  final List<EvaluationCriterion> evaluationCriteria;
  final List<String> nextRecommendedLessons;
  final List<TuneStudy> tuneStudies;
  final List<ConceptToMusicMap> conceptToMusicMaps;
  final List<LibraryItem> libraryItems;
  final String originalityNote;
  final bool isOriginalContent;
  final EducationalFlow? flow;

  String get summary => description;
  DifficultyLevel get difficulty => level;
  String? get writtenKeyForTenor => writtenKeyForBbSax;
  String? get writtenKeyForAlto => writtenKeyForEbSax;
  bool get supportsCoreEducationalFlow =>
      resolvedFlow.stages.length == coreEducationalFlowOrder.length;

  EducationalFlow get resolvedFlow {
    if (flow != null) {
      return flow!;
    }

    final evaluationCategories = evaluationCriteria
        .map((criterion) => criterion.category)
        .toSet()
        .toList(growable: false);

    return EducationalFlow(
      stages: buildEducationalFlowStages(
        steps: steps,
        title: title,
        concepts: concepts,
        evaluationCategories: evaluationCategories,
        nextRecommendedLessons: nextRecommendedLessons,
      ),
    );
  }

  String? keyForSax(SaxType saxType) => resolveKeyForSax(
        saxType,
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );

  Map<String, String> get transpositionSummary => buildTranspositionSummary(
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level.name,
      'skill_areas': skillAreas.map((item) => item.name).toList(),
      'concepts': concepts,
      'source_inspiration': sourceInspiration,
      'sax_types': saxTypes.map((item) => item.name).toList(),
      'concert_key': concertKey,
      'written_key_for_bb_sax': writtenKeyForBbSax,
      'written_key_for_eb_sax': writtenKeyForEbSax,
      'written_key_for_tenor': writtenKeyForBbSax,
      'written_key_for_alto': writtenKeyForEbSax,
      'tempo_range': tempoRange.toJson(),
      'steps': steps.map((item) => item.toJson()).toList(),
      'exercises': exercises.map((item) => item.toJson()).toList(),
      'backing_track_references': backingTrackReferences,
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'next_recommended_lessons': nextRecommendedLessons,
      'tune_studies': tuneStudies.map((item) => item.toJson()).toList(),
      'concept_to_music_maps':
          conceptToMusicMaps.map((item) => item.toJson()).toList(),
      'library_items': libraryItems.map((item) => item.toJson()).toList(),
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
      'flow': resolvedFlow.toJson(),
    };
  }

  ContentType get contentType => ContentType.lesson;
}

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.skillAreas,
    required this.exercises,
    this.endedAt,
    this.reflection,
    this.feedbackResult,
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<SkillArea> skillAreas;
  final List<Exercise> exercises;
  final String? reflection;
  final AudioFeedbackResult? feedbackResult;

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: DateTime.tryParse(json['ended_at'] as String? ?? ''),
      skillAreas: ((json['skill_areas'] as List?) ?? const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      exercises: ((json['exercises'] as List?) ?? const [])
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      reflection: json['reflection'] as String?,
      feedbackResult: json['feedback_result'] is Map<String, dynamic>
          ? FeedbackResult.fromJson(
              json['feedback_result'] as Map<String, dynamic>,
            ).toAudioFeedbackResult()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'skill_areas': skillAreas.map((item) => item.name).toList(),
      'exercises': exercises.map((item) => item.toJson()).toList(),
      'reflection': reflection,
      'feedback_result': feedbackResult == null
          ? null
          : FeedbackResult.fromAudioFeedbackResult(
              id: '${id}_feedback',
              title: '$title Feedback',
              feedback: feedbackResult!,
            ).toJson(),
    };
  }

  ContentType get contentType => ContentType.practiceSession;
}

class PracticePlan {
  const PracticePlan({
    required this.id,
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.totalMinutes,
    required this.focusAreas,
    required this.lessons,
    required this.exercises,
    this.transcriptionTasks = const [],
    this.tuneStudies = const [],
    this.etudes = const [],
    this.rhythmPatterns = const [],
    this.scaleStudies = const [],
    this.chordStudies = const [],
    this.improvisationPrompts = const [],
    this.backingTracks = const [],
    this.progressMetrics = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original practice plan inspired by serious jazz practice methodology.',
    this.isOriginalContent = true,
  });

  final String id;
  final String title;
  final String summary;
  final DifficultyLevel difficulty;
  final int totalMinutes;
  final List<SkillArea> focusAreas;
  final List<Lesson> lessons;
  final List<Exercise> exercises;
  final List<TranscriptionTask> transcriptionTasks;
  final List<TuneStudy> tuneStudies;
  final List<Etude> etudes;
  final List<RhythmPattern> rhythmPatterns;
  final List<ScaleStudy> scaleStudies;
  final List<ChordStudy> chordStudies;
  final List<ImprovisationPrompt> improvisationPrompts;
  final List<BackingTrack> backingTracks;
  final List<ProgressMetric> progressMetrics;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  factory PracticePlan.fromJson(Map<String, dynamic> json) {
    return PracticePlan(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      difficulty: difficultyLevelFromValue(json['difficulty']),
      totalMinutes: json['total_minutes'] as int? ?? 0,
      focusAreas: ((json['focus_areas'] as List?) ?? const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      lessons: ((json['lessons'] as List?) ?? const [])
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      exercises: ((json['exercises'] as List?) ?? const [])
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      transcriptionTasks: ((json['transcription_tasks'] as List?) ?? const [])
          .map(
            (item) => TranscriptionTask.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      tuneStudies: ((json['tune_studies'] as List?) ?? const [])
          .map((item) => TuneStudy.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      etudes: ((json['etudes'] as List?) ?? const [])
          .map((item) => Etude.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      rhythmPatterns: ((json['rhythm_patterns'] as List?) ?? const [])
          .map((item) => RhythmPattern.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      scaleStudies: ((json['scale_studies'] as List?) ?? const [])
          .map((item) => ScaleStudy.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      chordStudies: ((json['chord_studies'] as List?) ?? const [])
          .map((item) => ChordStudy.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      improvisationPrompts:
          ((json['improvisation_prompts'] as List?) ?? const [])
              .map(
                (item) =>
                    ImprovisationPrompt.fromJson(item as Map<String, dynamic>),
              )
              .toList(growable: false),
      backingTracks: ((json['backing_tracks'] as List?) ?? const [])
          .map((item) => BackingTrack.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      progressMetrics: ((json['progress_metrics'] as List?) ?? const [])
          .map((item) => ProgressMetric.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original practice plan inspired by serious jazz practice methodology.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'difficulty': difficulty.name,
      'difficulty_rank': difficulty.numericLevel,
      'total_minutes': totalMinutes,
      'focus_areas': focusAreas.map((item) => item.name).toList(),
      'lessons': lessons.map((item) => item.toJson()).toList(),
      'exercises': exercises.map((item) => item.toJson()).toList(),
      'transcription_tasks':
          transcriptionTasks.map((item) => item.toJson()).toList(),
      'tune_studies': tuneStudies.map((item) => item.toJson()).toList(),
      'etudes': etudes.map((item) => item.toJson()).toList(),
      'rhythm_patterns': rhythmPatterns.map((item) => item.toJson()).toList(),
      'scale_studies': scaleStudies.map((item) => item.toJson()).toList(),
      'chord_studies': chordStudies.map((item) => item.toJson()).toList(),
      'improvisation_prompts':
          improvisationPrompts.map((item) => item.toJson()).toList(),
      'backing_tracks': backingTracks.map((item) => item.toJson()).toList(),
      'progress_metrics': progressMetrics.map((item) => item.toJson()).toList(),
      'source_inspiration': sourceInspiration,
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
    };
  }

  ContentType get contentType => ContentType.practicePlan;
}

class Etude {
  const Etude({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.skillAreas,
    required this.targetConcepts,
    required this.evaluationCriteria,
    this.bars,
    this.meter = '4/4',
    this.swing = false,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.suggestedSaxTypes = const [],
    this.backingTrack,
    this.sourceInspiration = const [],
    this.originalityNote = 'Original etude content for jazz saxophone study.',
    this.isOriginalContent = true,
  });

  final String id;
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final List<SkillArea> skillAreas;
  final List<String> targetConcepts;
  final List<EvaluationCriterion> evaluationCriteria;
  final int? bars;
  final String meter;
  final bool swing;
  final TempoRange tempoRange;
  final List<SaxType> suggestedSaxTypes;
  final BackingTrack? backingTrack;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  factory Etude.fromJson(Map<String, dynamic> json) {
    return Etude(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      difficulty: difficultyLevelFromValue(json['difficulty']),
      skillAreas: (((json['skill_areas'] ?? json['target_skills']) as List?) ??
              const [])
          .map((item) => skillAreaFromName(item.toString()))
          .toList(growable: false),
      targetConcepts: ((json['target_concepts'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      bars: json['bars'] as int?,
      meter: (json['meter'] ?? json['time_signature']) as String? ?? '4/4',
      swing: json['swing'] as bool? ?? false,
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(json['backing_track'] as Map<String, dynamic>)
          : null,
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original etude content for jazz saxophone study.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty.name,
      'difficulty_rank': difficulty.numericLevel,
      'skill_areas': skillAreas.map((item) => item.name).toList(),
      'target_concepts': targetConcepts,
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'bars': bars,
      'meter': meter,
      'time_signature': meter,
      'swing': swing,
      'tempo_range': tempoRange.toJson(),
      'tempo': tempoRange.isSingleTempo ? tempoRange.minBpm : null,
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'backing_track': backingTrack?.toJson(),
      'source_inspiration': sourceInspiration,
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
    };
  }

  ContentType get contentType => ContentType.etude;
}

class RhythmPattern {
  const RhythmPattern({
    required this.id,
    required this.title,
    required this.description,
    required this.bars,
    required this.meter,
    required this.targetSkills,
    required this.evaluationCriteria,
    this.swing = false,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.subdivisionDescription,
    this.countPattern = const [],
    this.suggestedSaxTypes = const [],
    this.sourceInspiration = const [],
  });

  final String id;
  final String title;
  final String description;
  final int bars;
  final String meter;
  final bool swing;
  final TempoRange tempoRange;
  final List<SkillArea> targetSkills;
  final List<EvaluationCriterion> evaluationCriteria;
  final String? subdivisionDescription;
  final List<String> countPattern;
  final List<SaxType> suggestedSaxTypes;
  final List<String> sourceInspiration;

  factory RhythmPattern.fromJson(Map<String, dynamic> json) {
    return RhythmPattern(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bars: json['bars'] as int? ?? 0,
      meter: (json['meter'] ?? json['time_signature']) as String? ?? '4/4',
      swing: json['swing'] as bool? ?? false,
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      targetSkills:
          (((json['target_skills'] ?? json['skill_areas']) as List?) ??
                  const [])
              .map((item) => skillAreaFromName(item.toString()))
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      subdivisionDescription: json['subdivision_description'] as String?,
      countPattern: ((json['count_pattern'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bars': bars,
      'meter': meter,
      'time_signature': meter,
      'swing': swing,
      'tempo_range': tempoRange.toJson(),
      'tempo': tempoRange.isSingleTempo ? tempoRange.minBpm : null,
      'target_skills': targetSkills.map((item) => item.name).toList(),
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'subdivision_description': subdivisionDescription,
      'count_pattern': countPattern,
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'source_inspiration': sourceInspiration,
    };
  }

  ContentType get contentType => ContentType.rhythmPattern;
}

class ScaleStudy {
  const ScaleStudy({
    required this.id,
    required this.title,
    required this.scaleName,
    required this.description,
    required this.keys,
    required this.targetSkills,
    required this.evaluationCriteria,
    this.patternDescription,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.swing = false,
    this.suggestedSaxTypes = const [],
    this.backingTrack,
    this.sourceInspiration = const [],
  });

  final String id;
  final String title;
  final String scaleName;
  final String description;
  final List<String> keys;
  final List<SkillArea> targetSkills;
  final List<EvaluationCriterion> evaluationCriteria;
  final String? patternDescription;
  final TempoRange tempoRange;
  final bool swing;
  final List<SaxType> suggestedSaxTypes;
  final BackingTrack? backingTrack;
  final List<String> sourceInspiration;

  factory ScaleStudy.fromJson(Map<String, dynamic> json) {
    return ScaleStudy(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      scaleName: json['scale_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      keys: ((json['keys'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      targetSkills:
          (((json['target_skills'] ?? json['skill_areas']) as List?) ??
                  const [])
              .map((item) => skillAreaFromName(item.toString()))
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      patternDescription: json['pattern_description'] as String?,
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      swing: json['swing'] as bool? ?? false,
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(json['backing_track'] as Map<String, dynamic>)
          : null,
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scale_name': scaleName,
      'description': description,
      'keys': keys,
      'target_skills': targetSkills.map((item) => item.name).toList(),
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'pattern_description': patternDescription,
      'tempo_range': tempoRange.toJson(),
      'tempo': tempoRange.isSingleTempo ? tempoRange.minBpm : null,
      'swing': swing,
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'backing_track': backingTrack?.toJson(),
      'source_inspiration': sourceInspiration,
    };
  }

  ContentType get contentType => ContentType.scaleStudy;
}

class ChordStudy {
  const ChordStudy({
    required this.id,
    required this.title,
    required this.description,
    required this.chordSymbols,
    required this.targetConcepts,
    required this.targetSkills,
    required this.evaluationCriteria,
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.suggestedSaxTypes = const [],
    this.backingTrack,
    this.sourceInspiration = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<String> chordSymbols;
  final List<String> targetConcepts;
  final List<SkillArea> targetSkills;
  final List<EvaluationCriterion> evaluationCriteria;
  final TempoRange tempoRange;
  final List<SaxType> suggestedSaxTypes;
  final BackingTrack? backingTrack;
  final List<String> sourceInspiration;

  factory ChordStudy.fromJson(Map<String, dynamic> json) {
    return ChordStudy(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      chordSymbols: ((json['chord_symbols'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      targetConcepts: ((json['target_concepts'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      targetSkills:
          (((json['target_skills'] ?? json['skill_areas']) as List?) ??
                  const [])
              .map((item) => skillAreaFromName(item.toString()))
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(json['backing_track'] as Map<String, dynamic>)
          : null,
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'chord_symbols': chordSymbols,
      'target_concepts': targetConcepts,
      'target_skills': targetSkills.map((item) => item.name).toList(),
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'tempo_range': tempoRange.toJson(),
      'tempo': tempoRange.isSingleTempo ? tempoRange.minBpm : null,
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'backing_track': backingTrack?.toJson(),
      'source_inspiration': sourceInspiration,
    };
  }

  ContentType get contentType => ContentType.chordStudy;
}

class ImprovisationPrompt {
  const ImprovisationPrompt({
    required this.id,
    required this.title,
    required this.prompt,
    required this.targetSkills,
    required this.evaluationCriteria,
    this.formDescription,
    this.requirements = const [],
    this.tempoRange = const TempoRange(minBpm: 0, maxBpm: 0),
    this.backingTrack,
    this.suggestedSaxTypes = const [],
    this.sourceInspiration = const [],
  });

  final String id;
  final String title;
  final String prompt;
  final List<SkillArea> targetSkills;
  final List<EvaluationCriterion> evaluationCriteria;
  final String? formDescription;
  final List<String> requirements;
  final TempoRange tempoRange;
  final BackingTrack? backingTrack;
  final List<SaxType> suggestedSaxTypes;
  final List<String> sourceInspiration;

  factory ImprovisationPrompt.fromJson(Map<String, dynamic> json) {
    return ImprovisationPrompt(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      targetSkills:
          (((json['target_skills'] ?? json['skill_areas']) as List?) ??
                  const [])
              .map((item) => skillAreaFromName(item.toString()))
              .toList(growable: false),
      evaluationCriteria: ((json['evaluation_criteria'] as List?) ?? const [])
          .map(
            (item) => EvaluationCriterion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      formDescription: json['form_description'] as String?,
      requirements: ((json['requirements'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      tempoRange: json['tempo_range'] is Map<String, dynamic>
          ? TempoRange.fromJson(json['tempo_range'] as Map<String, dynamic>)
          : json['tempo'] is int
              ? TempoRange(
                  minBpm: json['tempo'] as int,
                  maxBpm: json['tempo'] as int,
                )
              : const TempoRange(minBpm: 0, maxBpm: 0),
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(json['backing_track'] as Map<String, dynamic>)
          : null,
      suggestedSaxTypes: ((json['suggested_sax_types'] as List?) ?? const [])
          .map((item) => saxTypeFromName(item.toString()))
          .toList(growable: false),
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'target_skills': targetSkills.map((item) => item.name).toList(),
      'evaluation_criteria':
          evaluationCriteria.map((item) => item.toJson()).toList(),
      'form_description': formDescription,
      'requirements': requirements,
      'tempo_range': tempoRange.toJson(),
      'tempo': tempoRange.isSingleTempo ? tempoRange.minBpm : null,
      'backing_track': backingTrack?.toJson(),
      'suggested_sax_types':
          suggestedSaxTypes.map((item) => item.name).toList(),
      'source_inspiration': sourceInspiration,
    };
  }

  ContentType get contentType => ContentType.improvisationPrompt;
}

class ConceptToMusicContext {
  const ConceptToMusicContext({
    required this.type,
    required this.title,
    required this.description,
    this.progression,
    this.noteFocus,
    this.exerciseInstruction,
    this.backingTrack,
    this.rhythmPattern,
    this.etude,
    this.improvisationPrompt,
    this.transcriptionTask,
  });

  final ConceptMusicContextType type;
  final String title;
  final String description;
  final String? progression;
  final String? noteFocus;
  final String? exerciseInstruction;
  final BackingTrack? backingTrack;
  final RhythmPattern? rhythmPattern;
  final Etude? etude;
  final ImprovisationPrompt? improvisationPrompt;
  final TranscriptionTask? transcriptionTask;

  factory ConceptToMusicContext.fromJson(Map<String, dynamic> json) {
    return ConceptToMusicContext(
      type: conceptMusicContextTypeFromName(
        json['type'] as String? ?? 'blues',
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      progression: json['progression'] as String?,
      noteFocus: json['note_focus'] as String?,
      exerciseInstruction: json['exercise_instruction'] as String?,
      backingTrack: json['backing_track'] is Map<String, dynamic>
          ? BackingTrack.fromJson(json['backing_track'] as Map<String, dynamic>)
          : null,
      rhythmPattern: json['rhythm_pattern'] is Map<String, dynamic>
          ? RhythmPattern.fromJson(
              json['rhythm_pattern'] as Map<String, dynamic>,
            )
          : null,
      etude: json['etude'] is Map<String, dynamic>
          ? Etude.fromJson(json['etude'] as Map<String, dynamic>)
          : null,
      improvisationPrompt: json['improvisation_prompt'] is Map<String, dynamic>
          ? ImprovisationPrompt.fromJson(
              json['improvisation_prompt'] as Map<String, dynamic>,
            )
          : null,
      transcriptionTask: json['transcription_task'] is Map<String, dynamic>
          ? TranscriptionTask.fromJson(
              json['transcription_task'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'progression': progression,
      'note_focus': noteFocus,
      'exercise_instruction': exerciseInstruction,
      'backing_track': backingTrack?.toJson(),
      'rhythm_pattern': rhythmPattern?.toJson(),
      'etude': etude?.toJson(),
      'improvisation_prompt': improvisationPrompt?.toJson(),
      'transcription_task': transcriptionTask?.toJson(),
    };
  }
}

class ConceptToMusicMap {
  const ConceptToMusicMap({
    required this.id,
    required this.conceptTitle,
    required this.theory,
    required this.soundTarget,
    required this.coreContext,
    required this.contexts,
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original concept-to-music framework inspired by serious jazz pedagogy.',
    this.isOriginalContent = true,
  });

  final String id;
  final String conceptTitle;
  final String theory;
  final String soundTarget;
  final String coreContext;
  final List<ConceptToMusicContext> contexts;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  factory ConceptToMusicMap.fromJson(Map<String, dynamic> json) {
    return ConceptToMusicMap(
      id: json['id'] as String? ?? '',
      conceptTitle: json['concept_title'] as String? ?? '',
      theory: json['theory'] as String? ?? '',
      soundTarget: json['sound_target'] as String? ?? '',
      coreContext: json['core_context'] as String? ?? '',
      contexts: ((json['contexts'] as List?) ?? const [])
          .map(
            (item) => ConceptToMusicContext.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      concertKey: json['concert_key'] as String?,
      writtenKeyForBbSax: (json['written_key_for_bb_sax'] ??
          json['written_key_for_tenor']) as String?,
      writtenKeyForEbSax: (json['written_key_for_eb_sax'] ??
          json['written_key_for_alto']) as String?,
      sourceInspiration: ((json['source_inspiration'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      originalityNote: json['originality_note'] as String? ??
          'Original concept-to-music framework inspired by serious jazz pedagogy.',
      isOriginalContent: json['is_original_content'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concept_title': conceptTitle,
      'theory': theory,
      'sound_target': soundTarget,
      'core_context': coreContext,
      'contexts': contexts.map((item) => item.toJson()).toList(),
      'concert_key': concertKey,
      'written_key_for_bb_sax': writtenKeyForBbSax,
      'written_key_for_eb_sax': writtenKeyForEbSax,
      'written_key_for_tenor': writtenKeyForBbSax,
      'written_key_for_alto': writtenKeyForEbSax,
      'source_inspiration': sourceInspiration,
      'originality_note': originalityNote,
      'is_original_content': isOriginalContent,
    };
  }

  Map<String, String> get transpositionSummary => buildTranspositionSummary(
        concertKey: concertKey,
        writtenKeyForBbSax: writtenKeyForBbSax,
        writtenKeyForEbSax: writtenKeyForEbSax,
      );
}

class FeedbackResult {
  const FeedbackResult({
    required this.id,
    required this.title,
    required this.summary,
    required this.nextStep,
    this.overallScore,
    this.categoryScores = const [],
    this.insights = const [],
    this.sourceExerciseId,
    this.nextExerciseId,
    this.generatedAt,
  });

  final String id;
  final String title;
  final String summary;
  final String nextStep;
  final double? overallScore;
  final List<FeedbackCategoryScore> categoryScores;
  final List<AudioFeedbackInsight> insights;
  final String? sourceExerciseId;
  final String? nextExerciseId;
  final DateTime? generatedAt;

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    return FeedbackResult(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      nextStep: json['next_step'] as String? ?? '',
      overallScore: (json['overall_score'] as num?)?.toDouble(),
      categoryScores: ((json['category_scores'] as List?) ?? const [])
          .map(
            (item) => FeedbackCategoryScore.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      insights: ((json['insights'] as List?) ?? const [])
          .map(
            (item) =>
                AudioFeedbackInsight.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      sourceExerciseId: json['source_exercise_id'] as String?,
      nextExerciseId: json['next_exercise_id'] as String?,
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? ''),
    );
  }

  factory FeedbackResult.fromAudioFeedbackResult({
    required String id,
    required String title,
    required AudioFeedbackResult feedback,
    String? sourceExerciseId,
  }) {
    return FeedbackResult(
      id: id,
      title: title,
      summary: feedback.summary,
      nextStep: feedback.nextStep,
      overallScore: feedback.overallScore,
      categoryScores: feedback.categories,
      insights: feedback.insights,
      sourceExerciseId: sourceExerciseId,
      nextExerciseId:
          feedback.insights.map((item) => item.nextExerciseId).firstWhere(
                (item) => item != null && item.isNotEmpty,
                orElse: () => null,
              ),
      generatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'next_step': nextStep,
      'overall_score': overallScore,
      'category_scores': categoryScores.map((item) => item.toJson()).toList(),
      'insights': insights.map((item) => item.toJson()).toList(),
      'source_exercise_id': sourceExerciseId,
      'next_exercise_id': nextExerciseId,
      'generated_at': generatedAt?.toIso8601String(),
    };
  }

  AudioFeedbackResult toAudioFeedbackResult() {
    return AudioFeedbackResult(
      id: id,
      exerciseId: sourceExerciseId ?? '',
      overallScore: overallScore ?? 0,
      categories: categoryScores,
      summary: summary,
      nextStep: nextStep,
      insights: insights,
    );
  }

  ContentType get contentType => ContentType.feedbackResult;
}

class JazzPracticeStep {
  const JazzPracticeStep({
    required this.stage,
    required this.title,
    required this.description,
    this.minutes = 0,
  });

  final LearningLoopStage stage;
  final String title;
  final String description;
  final int minutes;

  LessonStep toLessonStep() {
    return LessonStep(
      type: lessonStepTypeFromLearningLoopStage(stage),
      title: title,
      description: description,
      minutes: minutes,
    );
  }
}

class JazzExercise {
  const JazzExercise({
    required this.id,
    required this.title,
    required this.category,
    required this.goal,
    required this.minutes,
    required this.steps,
    required this.feedbackDimensions,
    this.difficulty = DifficultyLevel.beginner,
    this.suggestedSaxTypes = const [
      SaxType.altoEb,
      SaxType.tenorBb,
      SaxType.sopranoBb,
      SaxType.baritoneEb,
    ],
    this.concertKey,
    this.writtenKeyForBbSax,
    this.writtenKeyForEbSax,
    this.tempoRange = const TempoRange(minBpm: 60, maxBpm: 120),
    this.targetConcepts = const [],
    this.backingTrack,
    this.transcriptionTask,
    this.evaluationCriteria = const [],
    this.rhythmTrainerModes = const [],
    this.feelNotes = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original exercise inspired by established jazz education practice.',
    this.isOriginalContent = true,
  });

  final String id;
  final String title;
  final ExerciseCategory category;
  final String goal;
  final int minutes;
  final List<JazzPracticeStep> steps;
  final List<FeedbackDimension> feedbackDimensions;
  final DifficultyLevel difficulty;
  final List<SaxType> suggestedSaxTypes;
  final String? concertKey;
  final String? writtenKeyForBbSax;
  final String? writtenKeyForEbSax;
  final TempoRange tempoRange;
  final List<String> targetConcepts;
  final BackingTrack? backingTrack;
  final TranscriptionTask? transcriptionTask;
  final List<EvaluationCriterion> evaluationCriteria;
  final List<RhythmTrainerMode> rhythmTrainerModes;
  final List<String> feelNotes;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  EducationalFlow get resolvedFlow {
    return EducationalFlow(
      stages: buildEducationalFlowStages(
        steps: steps.map((step) => step.toLessonStep()).toList(growable: false),
        title: title,
        concepts: const [],
        evaluationCategories: feedbackDimensions
            .map(feedbackCategoryFromDimension)
            .toList(growable: false),
      ),
    );
  }

  Exercise toExercise({
    DifficultyLevel? difficultyOverride,
    List<SkillArea> skillAreas = const [SkillArea.improvisation],
    ExerciseType type = ExerciseType.etude,
  }) {
    return Exercise(
      id: id,
      title: title,
      type: type,
      skillAreas: skillAreas,
      difficulty: difficultyOverride ?? difficulty,
      goal: goal,
      minutes: minutes,
      steps: steps.map((step) => step.toLessonStep()).toList(growable: false),
      concertKey: concertKey,
      writtenKeyForBbSax: writtenKeyForBbSax,
      writtenKeyForEbSax: writtenKeyForEbSax,
      tempoRange: tempoRange,
      targetConcepts: targetConcepts,
      feedbackCategories: feedbackDimensions
          .map(feedbackCategoryFromDimension)
          .toList(growable: false),
      evaluationCriteria: evaluationCriteria,
      rhythmTrainerModes: rhythmTrainerModes,
      feelNotes: feelNotes,
      suggestedSaxTypes: suggestedSaxTypes,
      backingTrack: backingTrack,
      transcriptionTask: transcriptionTask,
      sourceInspiration: sourceInspiration,
      originalityNote: originalityNote,
      isOriginalContent: isOriginalContent,
    );
  }

  JazzExercise copyWith({
    DifficultyLevel? difficulty,
    List<SaxType>? suggestedSaxTypes,
    String? concertKey,
    String? writtenKeyForBbSax,
    String? writtenKeyForEbSax,
    TempoRange? tempoRange,
    List<String>? targetConcepts,
    BackingTrack? backingTrack,
    TranscriptionTask? transcriptionTask,
    List<EvaluationCriterion>? evaluationCriteria,
    List<RhythmTrainerMode>? rhythmTrainerModes,
    List<String>? feelNotes,
    List<String>? sourceInspiration,
    String? originalityNote,
    bool? isOriginalContent,
  }) {
    return JazzExercise(
      id: id,
      title: title,
      category: category,
      goal: goal,
      minutes: minutes,
      steps: steps,
      feedbackDimensions: feedbackDimensions,
      difficulty: difficulty ?? this.difficulty,
      suggestedSaxTypes: suggestedSaxTypes ?? this.suggestedSaxTypes,
      concertKey: concertKey ?? this.concertKey,
      writtenKeyForBbSax: writtenKeyForBbSax ?? this.writtenKeyForBbSax,
      writtenKeyForEbSax: writtenKeyForEbSax ?? this.writtenKeyForEbSax,
      tempoRange: tempoRange ?? this.tempoRange,
      targetConcepts: targetConcepts ?? this.targetConcepts,
      backingTrack: backingTrack ?? this.backingTrack,
      transcriptionTask: transcriptionTask ?? this.transcriptionTask,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      rhythmTrainerModes: rhythmTrainerModes ?? this.rhythmTrainerModes,
      feelNotes: feelNotes ?? this.feelNotes,
      sourceInspiration: sourceInspiration ?? this.sourceInspiration,
      originalityNote: originalityNote ?? this.originalityNote,
      isOriginalContent: isOriginalContent ?? this.isOriginalContent,
    );
  }
}

class JazzLessonModule {
  const JazzLessonModule({
    required this.id,
    required this.title,
    required this.summary,
    required this.keyTakeaways,
    required this.exercises,
    this.conceptToMusicMaps = const [],
    this.libraryItems = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original module structure inspired by serious jazz pedagogy.',
    this.isOriginalContent = true,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> keyTakeaways;
  final List<JazzExercise> exercises;
  final List<ConceptToMusicMap> conceptToMusicMaps;
  final List<LibraryItem> libraryItems;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  Lesson toLesson({
    DifficultyLevel difficulty = DifficultyLevel.beginner,
    List<SkillArea> skillAreas = const [SkillArea.improvisation],
    List<SaxType> saxTypes = const [
      SaxType.altoEb,
      SaxType.tenorBb,
      SaxType.sopranoBb,
      SaxType.baritoneEb,
    ],
  }) {
    final lessonExercises = exercises
        .map(
          (exercise) => exercise.toExercise(
            difficultyOverride: difficulty,
            skillAreas: skillAreas,
          ),
        )
        .toList(growable: false);

    return Lesson(
      id: id,
      title: title,
      description: summary,
      level: difficulty,
      skillAreas: skillAreas,
      concepts: keyTakeaways,
      sourceInspiration: sourceInspiration,
      saxTypes: saxTypes,
      concertKey: null,
      writtenKeyForBbSax: null,
      writtenKeyForEbSax: null,
      tempoRange: const TempoRange(minBpm: 60, maxBpm: 120),
      steps: lessonExercises.expand((exercise) => exercise.steps).toList(
            growable: false,
          ),
      exercises: lessonExercises,
      backingTrackReferences: const [],
      evaluationCriteria: const [],
      nextRecommendedLessons: const [],
      libraryItems: libraryItems,
      conceptToMusicMaps: conceptToMusicMaps,
      originalityNote: originalityNote,
      isOriginalContent: isOriginalContent,
    );
  }

  JazzLessonModule copyWith({
    List<JazzExercise>? exercises,
    List<ConceptToMusicMap>? conceptToMusicMaps,
    List<LibraryItem>? libraryItems,
    List<String>? sourceInspiration,
    String? originalityNote,
    bool? isOriginalContent,
  }) {
    return JazzLessonModule(
      id: id,
      title: title,
      summary: summary,
      keyTakeaways: keyTakeaways,
      exercises: exercises ?? this.exercises,
      conceptToMusicMaps: conceptToMusicMaps ?? this.conceptToMusicMaps,
      libraryItems: libraryItems ?? this.libraryItems,
      sourceInspiration: sourceInspiration ?? this.sourceInspiration,
      originalityNote: originalityNote ?? this.originalityNote,
      isOriginalContent: isOriginalContent ?? this.isOriginalContent,
    );
  }
}

class TuneStudyItem {
  const TuneStudyItem({
    required this.title,
    required this.focus,
    required this.whyItMatters,
  });

  final String title;
  final String focus;
  final String whyItMatters;
}

class JazzPillarTrack {
  const JazzPillarTrack({
    required this.id,
    required this.title,
    required this.shortLabel,
    required this.summary,
    required this.whyItMatters,
    required this.objectives,
    required this.modules,
    this.tunes = const [],
    this.conceptToMusicMaps = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original pillar content inspired by professional jazz education sources.',
    this.isOriginalContent = true,
  });

  final JazzPillarId id;
  final String title;
  final String shortLabel;
  final String summary;
  final String whyItMatters;
  final List<String> objectives;
  final List<JazzLessonModule> modules;
  final List<TuneStudy> tunes;
  final List<ConceptToMusicMap> conceptToMusicMaps;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;

  JazzPillarTrack copyWith({
    List<JazzLessonModule>? modules,
    List<TuneStudy>? tunes,
    List<ConceptToMusicMap>? conceptToMusicMaps,
    List<String>? sourceInspiration,
    String? originalityNote,
    bool? isOriginalContent,
  }) {
    return JazzPillarTrack(
      id: id,
      title: title,
      shortLabel: shortLabel,
      summary: summary,
      whyItMatters: whyItMatters,
      objectives: objectives,
      modules: modules ?? this.modules,
      tunes: tunes ?? this.tunes,
      conceptToMusicMaps: conceptToMusicMaps ?? this.conceptToMusicMaps,
      sourceInspiration: sourceInspiration ?? this.sourceInspiration,
      originalityNote: originalityNote ?? this.originalityNote,
      isOriginalContent: isOriginalContent ?? this.isOriginalContent,
    );
  }
}

class SkillTreeNode {
  const SkillTreeNode({
    required this.id,
    required this.title,
    required this.level,
    required this.skillAreas,
    required this.status,
    this.progressPercent = 0,
    this.summary,
  });

  final String id;
  final String title;
  final DifficultyLevel level;
  final List<SkillArea> skillAreas;
  final SkillTreeNodeStatus status;
  final int progressPercent;
  final String? summary;
}

class SkillTreeLevel {
  const SkillTreeLevel({
    required this.level,
    required this.title,
    required this.summary,
    required this.nodes,
    required this.unlocked,
    required this.masteredCount,
    required this.progressPercent,
  });

  final DifficultyLevel level;
  final String title;
  final String summary;
  final List<SkillTreeNode> nodes;
  final bool unlocked;
  final int masteredCount;
  final int progressPercent;
}

class SkillTreeSnapshot {
  const SkillTreeSnapshot({
    required this.levels,
    required this.currentLevel,
    required this.totalNodes,
    required this.masteredNodes,
    required this.overallProgressPercent,
  });

  final List<SkillTreeLevel> levels;
  final DifficultyLevel currentLevel;
  final int totalNodes;
  final int masteredNodes;
  final int overallProgressPercent;
}

class DailyPracticeBlock {
  const DailyPracticeBlock({
    required this.title,
    required this.minutes,
    required this.pillarId,
    required this.stage,
    required this.instructions,
    this.skillAreas = const [],
    this.targetTempoBpm,
    this.targetExerciseId,
    this.adaptationNote,
    this.recommendedSaxType,
  });

  final String title;
  final int minutes;
  final JazzPillarId pillarId;
  final LearningLoopStage stage;
  final String instructions;
  final List<SkillArea> skillAreas;
  final int? targetTempoBpm;
  final String? targetExerciseId;
  final String? adaptationNote;
  final SaxType? recommendedSaxType;
}

class PracticeEngineInput {
  const PracticeEngineInput({
    required this.level,
    required this.saxType,
    required this.goal,
    required this.availableMinutes,
    this.weakAreas = const [],
    this.currentCourse,
    this.upcomingLessons = const [],
    this.conceptMasteryCount = const {},
    this.repeatedFailureCount = const {},
  });

  final DifficultyLevel level;
  final SaxType saxType;
  final PracticeGoal goal;
  final int availableMinutes;
  final List<SkillArea> weakAreas;
  final String? currentCourse;
  final List<String> upcomingLessons;
  final Map<String, int> conceptMasteryCount;
  final Map<String, int> repeatedFailureCount;
}

class PracticeAdaptationDecision {
  const PracticeAdaptationDecision({
    required this.type,
    required this.title,
    required this.description,
    this.relatedSkillArea,
    this.relatedExerciseId,
    this.tempoAdjustmentBpm,
  });

  final PracticeAdaptationType type;
  final String title;
  final String description;
  final SkillArea? relatedSkillArea;
  final String? relatedExerciseId;
  final int? tempoAdjustmentBpm;
}

class DailyPracticeProgram {
  const DailyPracticeProgram({
    required this.title,
    required this.summary,
    required this.totalMinutes,
    required this.blocks,
    required this.nextRecommendation,
    required this.inputProfile,
    this.adaptationDecisions = const [],
    this.sourceInspiration = const [],
    this.originalityNote =
        'Original daily practice plan inspired by established jazz practice methods.',
    this.isOriginalContent = true,
  });

  final String title;
  final String summary;
  final int totalMinutes;
  final List<DailyPracticeBlock> blocks;
  final String nextRecommendation;
  final PracticeEngineInput inputProfile;
  final List<PracticeAdaptationDecision> adaptationDecisions;
  final List<String> sourceInspiration;
  final String originalityNote;
  final bool isOriginalContent;
}

const List<LessonStepType> coreEducationalFlowOrder = [
  LessonStepType.listen,
  LessonStepType.understand,
  LessonStepType.sing,
  LessonStepType.play,
  LessonStepType.improvise,
  LessonStepType.record,
  LessonStepType.evaluate,
  LessonStepType.repeat,
];

List<EducationalFlowStage> buildEducationalFlowStages({
  required List<LessonStep> steps,
  required String title,
  required List<String> concepts,
  required List<FeedbackCategory> evaluationCategories,
  List<String> nextRecommendedLessons = const [],
}) {
  final byType = <LessonStepType, LessonStep>{};
  for (final step in steps) {
    byType.putIfAbsent(step.type, () => step);
  }

  return coreEducationalFlowOrder.map((type) {
    final existing = byType[type];
    if (existing != null) {
      return EducationalFlowStage(
        type: type,
        title: existing.title,
        description: existing.description,
        minutes: existing.minutes,
        evaluationCategories:
            type == LessonStepType.evaluate ? evaluationCategories : const [],
        recommendations: type == LessonStepType.repeat
            ? buildRepeatRecommendations(nextRecommendedLessons)
            : const [],
      );
    }

    return EducationalFlowStage(
      type: type,
      title: lessonStepTypeLabel(type),
      description: generatedFlowDescription(
        type: type,
        title: title,
        concepts: concepts,
      ),
      isGenerated: true,
      evaluationCategories:
          type == LessonStepType.evaluate ? evaluationCategories : const [],
      recommendations: type == LessonStepType.repeat
          ? buildRepeatRecommendations(nextRecommendedLessons)
          : const [],
    );
  }).toList(growable: false);
}

List<FlowRecommendation> buildRepeatRecommendations(
  List<String> nextRecommendedLessons,
) {
  return [
    const FlowRecommendation(
      type: RepeatRecommendationType.retrySameTempo,
      label: 'Retry',
      description: 'أعد المحاولة بنفس التيمبو لتثبيت الفكرة قبل التصعيد.',
    ),
    const FlowRecommendation(
      type: RepeatRecommendationType.slowerTempo,
      label: 'Slower Tempo',
      description: 'انزل بالتيمبو وراجع placement والوضوح قبل السرعة.',
    ),
    const FlowRecommendation(
      type: RepeatRecommendationType.easierVariation,
      label: 'Easier Variation',
      description: 'خفف التعقيد إلى phrase أقصر أو rhythm أبسط.',
    ),
    const FlowRecommendation(
      type: RepeatRecommendationType.harderVariation,
      label: 'Harder Variation',
      description: 'لو اتقنت الأساس، وسّع المدى أو غيّر articulation.',
    ),
    if (nextRecommendedLessons.isNotEmpty)
      FlowRecommendation(
        type: RepeatRecommendationType.nextLesson,
        label: 'Next Lesson',
        description: 'انتقل إلى الدرس التالي بعد تثبيت النتيجة الحالية.',
        targetLessonId: nextRecommendedLessons.first,
      ),
  ];
}

String generatedFlowDescription({
  required LessonStepType type,
  required String title,
  required List<String> concepts,
}) {
  final conceptText = concepts.isEmpty ? 'الفكرة الحالية' : concepts.join(', ');
  switch (type) {
    case LessonStepType.listen:
      return 'استمع إلى مثال مرجعي يوضّح $conceptText داخل $title.';
    case LessonStepType.understand:
      return 'افهم ما يحدث موسيقيًا: placement, harmony, articulation, وسبب عمل الفكرة.';
    case LessonStepType.sing:
      return 'غنّ أو اسمع داخليًا الفكرة قبل لمس الساكسفون.';
    case LessonStepType.play:
      return 'اعزف الفكرة بوضوح على الساكسفون مع تحكم في التيمبو والـ tone.';
    case LessonStepType.analyze:
      return 'حلّل ما عزفته، لكن هذه المرحلة ليست ضمن الحلقة الأساسية الحالية.';
    case LessonStepType.improvise:
      return 'استخدم الفكرة في improvisation مقيّد بدل عزفها كتمرين ثابت فقط.';
    case LessonStepType.record:
      return 'سجّل take قصيرة حتى تستطيع المقارنة والتقييم بموضوعية.';
    case LessonStepType.evaluate:
      return 'قيّم pitch, rhythm, swing feel, articulation, tone, وimprovisation logic.';
    case LessonStepType.repeat:
      return 'أعد المحاولة أو غيّر الصعوبة/التيمبو أو انتقل لما بعده حسب النتيجة.';
  }
}

String lessonStepTypeLabel(LessonStepType type) {
  switch (type) {
    case LessonStepType.listen:
      return 'Listen';
    case LessonStepType.understand:
      return 'Understand';
    case LessonStepType.sing:
      return 'Sing';
    case LessonStepType.play:
      return 'Play';
    case LessonStepType.analyze:
      return 'Analyze';
    case LessonStepType.improvise:
      return 'Improvise';
    case LessonStepType.record:
      return 'Record';
    case LessonStepType.evaluate:
      return 'Evaluate';
    case LessonStepType.repeat:
      return 'Repeat';
  }
}

LessonStepType lessonStepTypeFromLearningLoopStage(LearningLoopStage stage) {
  switch (stage) {
    case LearningLoopStage.listen:
      return LessonStepType.listen;
    case LearningLoopStage.understand:
      return LessonStepType.understand;
    case LearningLoopStage.sing:
      return LessonStepType.sing;
    case LearningLoopStage.play:
      return LessonStepType.play;
    case LearningLoopStage.improvise:
      return LessonStepType.improvise;
    case LearningLoopStage.record:
      return LessonStepType.record;
    case LearningLoopStage.evaluate:
      return LessonStepType.evaluate;
    case LearningLoopStage.repeat:
      return LessonStepType.repeat;
  }
}

FeedbackCategory feedbackCategoryFromDimension(FeedbackDimension dimension) {
  switch (dimension) {
    case FeedbackDimension.toneCenter:
      return FeedbackCategory.tone;
    case FeedbackDimension.timeFeel:
      return FeedbackCategory.rhythm;
    case FeedbackDimension.swingPlacement:
      return FeedbackCategory.swingFeel;
    case FeedbackDimension.articulation:
      return FeedbackCategory.articulation;
    case FeedbackDimension.intonation:
      return FeedbackCategory.intonation;
    case FeedbackDimension.phraseShape:
      return FeedbackCategory.phraseShape;
    case FeedbackDimension.bluesLanguage:
      return FeedbackCategory.improvisationLogic;
    case FeedbackDimension.formAwareness:
      return FeedbackCategory.chordToneTargeting;
    case FeedbackDimension.earResponse:
      return FeedbackCategory.pitch;
  }
}

SkillArea skillAreaFromName(String name) {
  return SkillArea.values.firstWhere(
    (value) => value.name == name,
    orElse: () => SkillArea.feedback,
  );
}

ContentType contentTypeFromName(String name) {
  return ContentType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => ContentType.lesson,
  );
}

DifficultyLevel difficultyLevelFromName(String name) {
  return DifficultyLevel.values.firstWhere(
    (value) => value.name == name,
    orElse: () => DifficultyLevel.beginner,
  );
}

DifficultyLevel difficultyLevelFromValue(dynamic value) {
  if (value is num) {
    switch (value.toInt()) {
      case 2:
        return DifficultyLevel.earlyIntermediate;
      case 3:
        return DifficultyLevel.intermediate;
      case 4:
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }

  return difficultyLevelFromName(value?.toString() ?? 'beginner');
}

SaxType saxTypeFromName(String name) {
  return SaxType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => SaxType.altoEb,
  );
}

LessonStepType lessonStepTypeFromName(String name) {
  return LessonStepType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => LessonStepType.play,
  );
}

ExerciseType exerciseTypeFromName(String name) {
  return ExerciseType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => ExerciseType.etude,
  );
}

FeedbackCategory feedbackCategoryFromName(String name) {
  switch (name) {
    case 'timing':
      return FeedbackCategory.rhythm;
    case 'swing':
    case 'swingFeel':
      return FeedbackCategory.swingFeel;
    case 'phrasing':
      return FeedbackCategory.phraseShape;
  }

  return FeedbackCategory.values.firstWhere(
    (value) => value.name == name,
    orElse: () => FeedbackCategory.tone,
  );
}

AudioFeedbackIssue audioFeedbackIssueFromName(String name) {
  return AudioFeedbackIssue.values.firstWhere(
    (value) => value.name == name,
    orElse: () => AudioFeedbackIssue.wrongNote,
  );
}

RhythmTrainerMode rhythmTrainerModeFromName(String name) {
  return RhythmTrainerMode.values.firstWhere(
    (value) => value.name == name,
    orElse: () => RhythmTrainerMode.playBackOneNote,
  );
}

ConceptMusicContextType conceptMusicContextTypeFromName(String name) {
  return ConceptMusicContextType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => ConceptMusicContextType.blues,
  );
}

RepeatRecommendationType repeatRecommendationTypeFromName(String name) {
  return RepeatRecommendationType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => RepeatRecommendationType.retrySameTempo,
  );
}

String conceptMusicContextTypeLabel(ConceptMusicContextType type) {
  switch (type) {
    case ConceptMusicContextType.blues:
      return 'Blues';
    case ConceptMusicContextType.iiVI:
      return 'ii-V-I';
    case ConceptMusicContextType.jazzStandardProgression:
      return 'Standard-style Progression';
    case ConceptMusicContextType.bebopLine:
      return 'Bebop Line';
    case ConceptMusicContextType.saxEtude:
      return 'Sax Etude';
    case ConceptMusicContextType.earTraining:
      return 'Ear Training';
    case ConceptMusicContextType.backingTrack:
      return 'Backing Track';
    case ConceptMusicContextType.rhythmExercise:
      return 'Rhythm Exercise';
    case ConceptMusicContextType.improvisationPrompt:
      return 'Improvisation Prompt';
  }
}

String rhythmTrainerModeLabel(RhythmTrainerMode mode) {
  switch (mode) {
    case RhythmTrainerMode.clapBack:
      return 'Clap Back';
    case RhythmTrainerMode.playBackOneNote:
      return 'Play Back One Note';
    case RhythmTrainerMode.playRhythmUsingScale:
      return 'Play with Scale';
    case RhythmTrainerMode.improviseTwoBarsSameRhythm:
      return 'Improvise 2 Bars';
  }
}

TuneFormType tuneFormTypeFromName(String name) {
  return TuneFormType.values.firstWhere(
    (value) => value.name == name,
    orElse: () => TuneFormType.aaba,
  );
}

String tuneFormTypeLabel(TuneFormType formType) {
  switch (formType) {
    case TuneFormType.aaba:
      return 'AABA';
    case TuneFormType.abac:
      return 'ABAC';
    case TuneFormType.twelveBarBlues:
      return '12-Bar Blues';
    case TuneFormType.rhythmChanges:
      return 'Rhythm Changes';
    case TuneFormType.modalVamp:
      return 'Modal Vamp';
    case TuneFormType.throughComposedCycle:
      return 'Cycle Study';
  }
}

const List<SaxTransposition> supportedSaxTranspositions = [
  SaxTransposition(
    saxType: SaxType.altoEb,
    writtenToConcertSemitoneOffset: -9,
    displayLabel: 'Alto in Eb',
  ),
  SaxTransposition(
    saxType: SaxType.tenorBb,
    writtenToConcertSemitoneOffset: -14,
    displayLabel: 'Tenor in Bb',
  ),
  SaxTransposition(
    saxType: SaxType.sopranoBb,
    writtenToConcertSemitoneOffset: -2,
    displayLabel: 'Soprano in Bb',
  ),
  SaxTransposition(
    saxType: SaxType.baritoneEb,
    writtenToConcertSemitoneOffset: -21,
    displayLabel: 'Baritone in Eb',
  ),
];

String saxTypeDisplayLabel(SaxType saxType) {
  switch (saxType) {
    case SaxType.altoEb:
      return 'Eb Alto';
    case SaxType.tenorBb:
      return 'Bb Tenor';
    case SaxType.sopranoBb:
      return 'Bb Soprano';
    case SaxType.baritoneEb:
      return 'Eb Bari';
  }
}

String practiceGoalLabel(PracticeGoal goal) {
  switch (goal) {
    case PracticeGoal.betterSwing:
      return 'Better Swing';
    case PracticeGoal.betterBluesImprovisation:
      return 'Blues Improvisation';
    case PracticeGoal.strongerTone:
      return 'Stronger Tone';
    case PracticeGoal.cleanerArticulation:
      return 'Cleaner Articulation';
    case PracticeGoal.transcriptionGrowth:
      return 'Transcription Growth';
    case PracticeGoal.repertoireFluency:
      return 'Repertoire Fluency';
    case PracticeGoal.balancedDevelopment:
      return 'Balanced Development';
  }
}

String practiceAdaptationTypeLabel(PracticeAdaptationType type) {
  switch (type) {
    case PracticeAdaptationType.repeatTomorrow:
      return 'Repeat Tomorrow';
    case PracticeAdaptationType.reduceTempo:
      return 'Reduce Tempo';
    case PracticeAdaptationType.articulationVariation:
      return 'Articulation Focus';
    case PracticeAdaptationType.unlockHarderVariation:
      return 'Unlock Harder Variation';
    case PracticeAdaptationType.reduceComplexity:
      return 'Reduce Complexity';
    case PracticeAdaptationType.increaseComplexity:
      return 'Increase Complexity';
  }
}

String skillTreeNodeStatusLabel(SkillTreeNodeStatus status) {
  switch (status) {
    case SkillTreeNodeStatus.locked:
      return 'Locked';
    case SkillTreeNodeStatus.available:
      return 'Available';
    case SkillTreeNodeStatus.inProgress:
      return 'In Progress';
    case SkillTreeNodeStatus.mastered:
      return 'Mastered';
  }
}

String audioFeedbackIssueLabel(AudioFeedbackIssue issue) {
  switch (issue) {
    case AudioFeedbackIssue.wrongNote:
      return 'Wrong Note';
    case AudioFeedbackIssue.intonationSharp:
      return 'Sharp Intonation';
    case AudioFeedbackIssue.intonationFlat:
      return 'Flat Intonation';
    case AudioFeedbackIssue.unstableLongTones:
      return 'Unstable Long Tones';
    case AudioFeedbackIssue.earlyAttack:
      return 'Early Attack';
    case AudioFeedbackIssue.lateAttack:
      return 'Late Attack';
    case AudioFeedbackIssue.noteDuration:
      return 'Note Duration';
    case AudioFeedbackIssue.swingRatio:
      return 'Swing Ratio';
    case AudioFeedbackIssue.offbeatPlacement:
      return 'Offbeat Placement';
    case AudioFeedbackIssue.pulseConsistency:
      return 'Pulse Consistency';
    case AudioFeedbackIssue.toneConsistency:
      return 'Tone Consistency';
    case AudioFeedbackIssue.breathNoise:
      return 'Breath Noise';
    case AudioFeedbackIssue.dynamicControl:
      return 'Dynamic Control';
    case AudioFeedbackIssue.toneStability:
      return 'Tone Stability';
    case AudioFeedbackIssue.registerQuality:
      return 'Register Quality';
    case AudioFeedbackIssue.articulationTooHeavy:
      return 'Too Heavy';
    case AudioFeedbackIssue.articulationTooLegato:
      return 'Too Legato';
    case AudioFeedbackIssue.missingAccents:
      return 'Missing Accents';
    case AudioFeedbackIssue.unclearGhostNotes:
      return 'Unclear Ghost Notes';
    case AudioFeedbackIssue.poorPhraseEndings:
      return 'Poor Phrase Endings';
    case AudioFeedbackIssue.chordToneTargeting:
      return 'Chord Tone Targeting';
    case AudioFeedbackIssue.phraseLength:
      return 'Phrase Length';
    case AudioFeedbackIssue.useOfSpace:
      return 'Use of Space';
    case AudioFeedbackIssue.repetition:
      return 'Repetition';
    case AudioFeedbackIssue.motivicDevelopment:
      return 'Motivic Development';
    case AudioFeedbackIssue.rhythmicVariety:
      return 'Rhythmic Variety';
    case AudioFeedbackIssue.resolutionQuality:
      return 'Resolution Quality';
  }
}

String feedbackCategoryLabel(FeedbackCategory category) {
  switch (category) {
    case FeedbackCategory.pitch:
      return 'Pitch';
    case FeedbackCategory.intonation:
      return 'Intonation';
    case FeedbackCategory.rhythm:
      return 'Rhythm';
    case FeedbackCategory.swingFeel:
      return 'Swing Feel';
    case FeedbackCategory.articulation:
      return 'Articulation';
    case FeedbackCategory.tone:
      return 'Tone';
    case FeedbackCategory.phraseShape:
      return 'Phrase Shape';
    case FeedbackCategory.improvisationLogic:
      return 'Improvisation';
    case FeedbackCategory.chordToneTargeting:
      return 'Chord Targeting';
  }
}

String difficultyLevelLabel(DifficultyLevel level) {
  switch (level) {
    case DifficultyLevel.beginner:
      return 'Beginner';
    case DifficultyLevel.earlyIntermediate:
      return 'Early Intermediate';
    case DifficultyLevel.intermediate:
      return 'Intermediate';
    case DifficultyLevel.advanced:
      return 'Advanced';
  }
}

extension DifficultyLevelPresentation on DifficultyLevel {
  int get numericLevel {
    switch (this) {
      case DifficultyLevel.beginner:
        return 1;
      case DifficultyLevel.earlyIntermediate:
        return 2;
      case DifficultyLevel.intermediate:
        return 3;
      case DifficultyLevel.advanced:
        return 4;
    }
  }
}

String? resolveKeyForSax(
  SaxType saxType, {
  String? concertKey,
  String? writtenKeyForBbSax,
  String? writtenKeyForEbSax,
}) {
  switch (saxType) {
    case SaxType.tenorBb:
    case SaxType.sopranoBb:
      return writtenKeyForBbSax ?? transposedKeyLabel(concertKey, saxType);
    case SaxType.altoEb:
    case SaxType.baritoneEb:
      return writtenKeyForEbSax ?? transposedKeyLabel(concertKey, saxType);
  }
}

Map<String, String> buildTranspositionSummary({
  String? concertKey,
  String? writtenKeyForBbSax,
  String? writtenKeyForEbSax,
}) {
  final summary = <String, String>{};
  if (concertKey != null && concertKey.isNotEmpty) {
    summary['Concert'] = concertKey;
  }
  final bbKey =
      writtenKeyForBbSax ?? transposedKeyLabel(concertKey, SaxType.tenorBb);
  if (bbKey != null && bbKey.isNotEmpty) {
    summary['Bb'] = bbKey;
  }
  final ebKey =
      writtenKeyForEbSax ?? transposedKeyLabel(concertKey, SaxType.altoEb);
  if (ebKey != null && ebKey.isNotEmpty) {
    summary['Eb'] = ebKey;
  }
  return summary;
}

String? transposedKeyLabel(String? source, SaxType saxType) {
  if (source == null || source.isEmpty) {
    return null;
  }

  final semitoneShift = -supportedSaxTranspositions
      .firstWhere((item) => item.saxType == saxType)
      .writtenToConcertSemitoneOffset;

  return source.replaceAllMapped(_notePattern, (match) {
    final note = match.group(0);
    if (note == null) {
      return '';
    }

    final transposed = _transposeNoteToken(note, semitoneShift);
    return transposed ?? note;
  });
}

final RegExp _notePattern = RegExp(
  r'(?<![A-Za-z])(C#|Db|D#|Eb|F#|Gb|G#|Ab|A#|Bb|C|D|E|F|G|A|B)(?![A-Za-z])',
);

const List<String> _sharpPitchNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

const Map<String, int> _pitchNameToIndex = {
  'C': 0,
  'B#': 0,
  'C#': 1,
  'Db': 1,
  'D': 2,
  'D#': 3,
  'Eb': 3,
  'E': 4,
  'Fb': 4,
  'F': 5,
  'E#': 5,
  'F#': 6,
  'Gb': 6,
  'G': 7,
  'G#': 8,
  'Ab': 8,
  'A': 9,
  'A#': 10,
  'Bb': 10,
  'B': 11,
  'Cb': 11,
};

String? _transposeNoteToken(String token, int semitoneShift) {
  final index = _pitchNameToIndex[token];
  if (index == null) {
    return null;
  }

  final newIndex = (index + semitoneShift) % 12;
  final normalizedIndex = newIndex < 0 ? newIndex + 12 : newIndex;
  return _preferredSpellingForIndex(normalizedIndex,
      preferFlat: token.contains('b'));
}

String _preferredSpellingForIndex(int index, {required bool preferFlat}) {
  const flatNames = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  if (preferFlat) {
    return flatNames[index];
  }

  return _sharpPitchNames[index];
}
