import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';

import 'jazz_curriculum_models.dart';

class AudioAnalysisRequest {
  const AudioAnalysisRequest({
    required this.exerciseId,
    required this.dayNumber,
    required this.recording,
    required this.evaluation,
    this.targetTempoBpm,
    this.targetConcepts = const [],
  });

  final String exerciseId;
  final int dayNumber;
  final MockRecording recording;
  final AttemptEvaluation evaluation;
  final int? targetTempoBpm;
  final List<String> targetConcepts;
}

abstract class AudioFeedbackAnalyzer {
  Future<AudioFeedbackResult> analyze(AudioAnalysisRequest request);
}

class HeuristicAudioFeedbackAnalyzer implements AudioFeedbackAnalyzer {
  const HeuristicAudioFeedbackAnalyzer();

  static const List<String> _foundationExerciseKeywords = [
    'task_day_',
    'practice_day_',
    'lesson_day_',
    'foundation',
    'note',
    'tone',
    'longtone',
    'long-tone',
    'drone',
    'breath',
    'metronome',
    'rhythm',
    'scale',
    'count',
  ];

  static const List<String> _jazzExerciseKeywords = [
    'swing',
    'blues',
    'bebop',
    'guide',
    'improv',
    'ii-v',
    'iiv',
    'vocabulary',
    'changes',
    'solo',
  ];

  @override
  Future<AudioFeedbackResult> analyze(AudioAnalysisRequest request) async {
    return analyzeSync(request);
  }

  AudioFeedbackResult analyzeSync(AudioAnalysisRequest request) {
    final insights = <AudioFeedbackInsight>[
      ..._pitchInsights(request),
      ..._rhythmInsights(request),
      ..._toneInsights(request),
      ..._articulationInsights(request),
      ..._musicalFlowInsights(request),
    ];

    final categoryScores = _summarizeCategories(insights, request);

    return AudioFeedbackResult(
      id: request.evaluation.attemptId,
      exerciseId: request.exerciseId,
      overallScore: ((request.evaluation.pitchAccuracy +
                  request.evaluation.rhythmAccuracy +
                  request.evaluation.completion) /
              3)
          .toDouble(),
      categories: categoryScores,
      summary: _buildSummary(request, insights),
      nextStep: _buildNextStep(request, insights),
      insights: insights,
      recordingUrl: request.recording.audioUrl,
    );
  }

  List<AudioFeedbackInsight> _pitchInsights(AudioAnalysisRequest request) {
    final pitch = request.evaluation.pitchAccuracy;
    final isFoundationFlow = _isFoundationFlow(request);
    if (pitch < 68) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: pitch,
            category: FeedbackCategory.pitch,
            issue: AudioFeedbackIssue.wrongNote,
            musicalExplanation:
                'النغمات المستهدفة في هذا اليوم لم تثبت بعد، لذلك التمرين يبدو كبحث عن النغمة أكثر من كونه جملة مستقرة.',
            recommendedFix:
                'شغّل النغمة المرجعية أو drone، ثم طابق أول نغمتين ببطء قبل إعادة التمرين كاملًا.',
            nextExerciseId: 'foundation-note-matching',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: pitch,
          category: FeedbackCategory.pitch,
          issue: AudioFeedbackIssue.wrongNote,
          musicalExplanation:
              'النغمات الأساسية ليست مستقرة بعد، والجملة تفقد هدفها لأن بعض الهبوطات تقع خارج target notes المتوقعة.',
          recommendedFix:
              'اعزف نفس phrase ببطء شديد، ثم ثبت 3rds أو guide tones فقط قبل إعادة الجملة كاملة.',
          nextExerciseId: 'improv-guide-tone-lines',
        ),
      ];
    }
    if (pitch < 80) {
      return [
        AudioFeedbackInsight(
          score: pitch,
          category: FeedbackCategory.intonation,
          issue: request.recording.durationSeconds < 6
              ? AudioFeedbackIssue.unstableLongTones
              : AudioFeedbackIssue.intonationFlat,
          musicalExplanation: request.recording.durationSeconds < 6
              ? 'بداية النغمة غير مستقرة، وده يبان خصوصًا في long-tone moments أو أول note في الجملة.'
              : 'النغمات قريبة من الصحة، لكن فيها هبوط طفيف يخلي resolution أقل وضوحًا من المطلوب.',
          recommendedFix:
              'جرّب long tone قصيرة قبل الجملة، ثم أعد نفس phrase بعد تثبيت الهواء وشكل الفم.',
          nextExerciseId: 'foundation-tone-longtones',
        ),
      ];
    }
    if (pitch < 88) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: pitch,
            category: FeedbackCategory.intonation,
            issue: AudioFeedbackIssue.intonationSharp,
            musicalExplanation:
                'النغمة قريبة من الهدف، لكن بعض القمم أعلى قليلًا من اللازم، وده يجعل التمرين متوترًا بدل أن يكون ثابتًا.',
            recommendedFix:
                'خفف دفع الهواء عند القمم، ثم أعد نفس التمرين مع بداية أهدأ ونهاية أكثر ثباتًا.',
            nextExerciseId: 'foundation-tone-air-support',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: pitch,
          category: FeedbackCategory.intonation,
          issue: AudioFeedbackIssue.intonationSharp,
          musicalExplanation:
              'النغمات في المجمل صحيحة، لكن بعض القمم تبدو أعلى قليلًا من اللازم، وده يجعل الجملة متوترة أكثر من المطلوب.',
          recommendedFix:
              'أعد الجملة مع هواء أهدأ قليلًا وركز على release طبيعي في النهايات بدل الدفع الزائد في القمم.',
          nextExerciseId: 'foundation-ballad-colors',
        ),
      ];
    }
    return const [];
  }

  List<AudioFeedbackInsight> _rhythmInsights(AudioAnalysisRequest request) {
    final rhythm = request.evaluation.rhythmAccuracy;
    final targetTempo = request.targetTempoBpm ?? 90;
    final isFoundationFlow = _isFoundationFlow(request);
    if (rhythm < 60) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.rhythm,
            issue: AudioFeedbackIssue.lateAttack,
            musicalExplanation:
                'النبض العام ظاهر، لكن دخول النغمات يتأخر عن العد المتوقع، لذلك التمرين يفقد ثباته من أول لحظة.',
            recommendedFix:
                'عد 1-2-3-4 بصوت مسموع، ثم اعزف نفس الإيقاع على نغمة واحدة فقط مع metronome عند ${targetTempo.clamp(50, 90)} BPM.',
            nextExerciseId: 'foundation-rhythm-counting',
          ),
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.rhythm,
            issue: AudioFeedbackIssue.pulseConsistency,
            musicalExplanation:
                'أطوال النغمات نفسها تتغير من محاولة لأخرى، وده يجعل العد الداخلي غير واضح حتى لو كانت النغمة صحيحة.',
            recommendedFix:
                'صفّق الإيقاع أولًا، ثم سجّل نسخة ثانية بنفس طول النغمات قبل العودة للعزف الكامل.',
            nextExerciseId: 'foundation-rhythm-note-lengths',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: rhythm,
          category: FeedbackCategory.rhythm,
          issue: AudioFeedbackIssue.lateAttack,
          musicalExplanation:
              'النبض العام موجود، لكن بداية النغمات تتأخر عن مكانها المتوقع، وده يضعف drive الجملة.',
          recommendedFix:
              'صفّق أو اعزف نفس الـ rhythm على note واحدة فقط، ثم استخدم metronome على 2 و4 عند ${targetTempo.clamp(60, 110)} BPM.',
          nextExerciseId: 'swing-pulse-and-metronome',
        ),
        AudioFeedbackInsight(
          score: rhythm,
          category: FeedbackCategory.swingFeel,
          issue: AudioFeedbackIssue.offbeatPlacement,
          musicalExplanation:
              'الـ offbeats لسه مستقيمة أكثر من اللازم، لذلك الجملة لا تحمل lift swing واضح حتى لو notes نفسها صحيحة.',
          recommendedFix:
              'أعد نفس phrase مع count داخلي واضح، ثم اترك للـ upbeat وزنًا أخف بدون أن تتحول إلى even eighths.',
          nextExerciseId: 'swing-subdivision-and-feel',
        ),
      ];
    }
    if (rhythm < 70) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.rhythm,
            issue: AudioFeedbackIssue.earlyAttack,
            musicalExplanation:
                'فيه استعجال بسيط قبل النبض في بعض المداخل، وده يخلّي التمرين يسبق العد بدل ما يستقر فوقه.',
            recommendedFix:
                'انزل سرعة 10 إلى 15 BPM، وعد أول نبضتين قبل العزف حتى يستقر الدخول في مكانه.',
            nextExerciseId: 'foundation-rhythm-counting',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: rhythm,
          category: FeedbackCategory.rhythm,
          issue: AudioFeedbackIssue.earlyAttack,
          musicalExplanation:
              'فيه استعجال بسيط في بعض الهجمات، خصوصًا عندما تدخل الجملة بقوة أو عند إعادة motif متكررة.',
          recommendedFix:
              'انزل 15 BPM وجرّب metronome على 2 و4 فقط. العبرة هنا placement لا السرعة.',
          nextExerciseId: 'swing-pulse-and-metronome',
        ),
      ];
    }
    if (rhythm < 82) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.rhythm,
            issue: AudioFeedbackIssue.noteDuration,
            musicalExplanation:
                'بداية النغمات أوضح الآن، لكن أطوالها ما زالت غير متساوية، وده يخلي الجملة تبدو متقطعة.',
            recommendedFix:
                'أعد التمرين مع تركيز على نهاية كل نغمة، ثم قارن النسخة الجديدة بالسابقة قبل رفع السرعة.',
            nextExerciseId: 'foundation-rhythm-note-lengths',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: rhythm,
          category: FeedbackCategory.rhythm,
          issue: AudioFeedbackIssue.noteDuration,
          musicalExplanation:
              'بدايات النغمات أفضل، لكن أطوالها ليست متساوية مع intent الجملة، وده يجعل phrase تبدو غير مستقرة.',
          recommendedFix:
              'أعد الجملة نفسها مع تركيز على ends of notes، لا على starts فقط، ثم قارن التسجيلين.',
          nextExerciseId: 'language-funk-riff-control',
        ),
      ];
    }
    if (rhythm < 90) {
      if (isFoundationFlow) {
        return [
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.rhythm,
            issue: AudioFeedbackIssue.pulseConsistency,
            musicalExplanation:
                'الإيقاع جيد في المجمل، لكن العد الداخلي يحتاج ثباتًا أكبر حتى يبقى التمرين مرتاحًا من البداية للنهاية.',
            recommendedFix:
                'أعد نفس الجملة مرة مع العد بصوت منخفض ومرة من غير عد، ثم احتفظ بالنسخة الأكثر استقرارًا.',
            nextExerciseId: 'foundation-rhythm-subdivision',
          ),
        ];
      }

      return [
        AudioFeedbackInsight(
          score: rhythm,
          category: FeedbackCategory.swingFeel,
          issue: AudioFeedbackIssue.swingRatio,
          musicalExplanation:
              'الوقت جيد عمومًا، لكن swing ratio ما زالت بحاجة لمرونة أكثر حتى لا تبدو الثمنيات مكتوبة بشكل جامد.',
          recommendedFix:
              'جرّب نفس الجملة مرة أوسع swing ومرة straighter قليلًا، ثم اختر النسخة التي تخدم الـ tempo الحالي أفضل.',
          nextExerciseId: 'swing-subdivision-and-feel',
        ),
      ];
    }
    return const [];
  }

  List<AudioFeedbackInsight> _toneInsights(AudioAnalysisRequest request) {
    final pitch = request.evaluation.pitchAccuracy;
    final completion = request.evaluation.completion;
    final isFoundationFlow = _isFoundationFlow(request);
    if (pitch < 75) {
      return [
        AudioFeedbackInsight(
          score: pitch,
          category: FeedbackCategory.tone,
          issue: AudioFeedbackIssue.toneStability,
          musicalExplanation:
              'مركز الصوت يتغير من note إلى أخرى، وده يجعل السامع يركز على الاستقرار أكثر من الفكرة الموسيقية نفسها.',
          recommendedFix:
              isFoundationFlow
                  ? 'ابدأ بـ long tone قصيرة مع نفس هادئ، ثم أعد الجملة مع نفس كمية الهواء في كل نغمة.'
                  : 'ابدأ بـ long tone قصيرة أو overtone بسيطة، ثم أعد الجملة مع نفس النفس ونفس color concept.',
          nextExerciseId: isFoundationFlow
              ? 'foundation-tone-air-support'
              : 'foundation-overtone-bridge',
        ),
      ];
    }
    if (request.recording.isRealRecording &&
        request.recording.durationSeconds >= 8) {
      if (completion < 78) {
        return [
          AudioFeedbackInsight(
            score: completion,
            category: FeedbackCategory.tone,
            issue: AudioFeedbackIssue.dynamicControl,
            musicalExplanation:
                'فيه تفاوت واضح في شدة الصوت عبر الجملة، وده يضعف shape الموسيقية بدل ما يخدمها.',
            recommendedFix:
                isFoundationFlow
                    ? 'أعد التمرين مع بداية أهدأ ونهاية أوضح، وحافظ على نفس شدة الصوت تقريبًا من أول الجملة لآخرها.'
                    : 'أعد الجملة مع dynamic arc أصغر وتحكم أوضح في البداية والنهاية، لا سيما في القمم.',
            nextExerciseId: isFoundationFlow
                ? 'foundation-tone-longtones'
                : 'foundation-tone-longtones',
          ),
        ];
      }
    }
    return const [];
  }

  List<AudioFeedbackInsight> _articulationInsights(
      AudioAnalysisRequest request) {
    final rhythm = request.evaluation.rhythmAccuracy;
    final exerciseId = request.exerciseId.toLowerCase();
    final isFoundationFlow = _isFoundationFlow(request);

    if (isFoundationFlow && request.evaluation.completion < 80) {
      return [
        AudioFeedbackInsight(
          score: request.evaluation.completion,
          category: FeedbackCategory.articulation,
          issue: AudioFeedbackIssue.poorPhraseEndings,
          musicalExplanation:
              'بداية التمرين مفهومة، لكن النهايات تسقط بسرعة أو تختفي قبل أن تقفل الجملة بشكل مريح.',
          recommendedFix:
              'درّب آخر beat وحده مرتين أو ثلاثًا، ثم أعد ربطه ببقية الجملة بدل إعادة التمرين كله من البداية.',
          nextExerciseId: 'foundation-breath-and-release',
        ),
      ];
    }

    if (exerciseId.contains('swing') || exerciseId.contains('blues')) {
      if (rhythm < 80) {
        return [
          AudioFeedbackInsight(
            score: rhythm,
            category: FeedbackCategory.articulation,
            issue: AudioFeedbackIssue.unclearGhostNotes,
            musicalExplanation:
                'الـ upbeats والـ ghost notes لا تظهر بوضوح كافٍ، لذلك الجملة تبدو مسطحة أكثر من اللازم.',
            recommendedFix:
                'غنّ phrase بسيلابلز doo-dat أولًا، ثم أعدها بعزف أخف على الـ upbeats وبـ accents أوضح في القمم.',
            nextExerciseId: 'language-swing-doo-dat',
          ),
        ];
      }
    }
    if (exerciseId.contains('bebop')) {
      return [
        AudioFeedbackInsight(
          score: request.evaluation.completion,
          category: FeedbackCategory.articulation,
          issue: AudioFeedbackIssue.articulationTooHeavy,
          musicalExplanation:
              'الجملة تحمل المعلومات الصحيحة تقريبًا، لكن اللسان أثقل من المطلوب على ثمنيات bebop المتصلة.',
          recommendedFix:
              'خفف attack على الـ eighth notes، واترك accent فقط عند phrase peaks أو target notes المهمة.',
          nextExerciseId: 'language-bebop-touch',
        ),
      ];
    }
    if (request.evaluation.completion < 80) {
      return [
        AudioFeedbackInsight(
          score: request.evaluation.completion,
          category: FeedbackCategory.articulation,
          issue: AudioFeedbackIssue.poorPhraseEndings,
          musicalExplanation:
              'نهايات الجمل تذوب أو تنقطع بسرعة، لذلك المستمع لا يشعر release مقنعًا في النهاية.',
          recommendedFix:
              'أعد آخر beat من phrase وحده أكثر من مرة، ثم ركّب النهاية على بقية الجملة بدل إعادة كل شيء من البداية.',
          nextExerciseId: 'language-swing-doo-dat',
        ),
      ];
    }
    return const [];
  }

  List<AudioFeedbackInsight> _musicalFlowInsights(
    AudioAnalysisRequest request,
  ) {
    if (_isFoundationFlow(request)) {
      return _foundationFlowInsights(request);
    }

    return _improvisationInsights(request);
  }

  List<AudioFeedbackInsight> _foundationFlowInsights(
    AudioAnalysisRequest request,
  ) {
    final completion = request.evaluation.completion;

    if (completion < 72) {
      return [
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.phraseShape,
          issue: AudioFeedbackIssue.phraseLength,
          musicalExplanation:
              'التمرين لم يكتمل بنفس الثبات من البداية للنهاية، لذلك الفكرة الأساسية لا تصل كاملة بعد.',
          recommendedFix:
              'قسّم الجملة إلى جزأين قصيرين، وثبّت كل جزء وحده ثم أعد وصل الجزأين في تسجيل جديد.',
          nextExerciseId: 'foundation-call-and-response-short',
        ),
      ];
    }

    if (completion < 85) {
      return [
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.phraseShape,
          issue: AudioFeedbackIssue.repetition,
          musicalExplanation:
              'التمرين يقترب من الاكتمال، لكنك تحتاج نسخة أكثر هدوءًا وثباتًا حتى تبدو الجملة مقصودة بالكامل.',
          recommendedFix:
              'أعد نفس التمرين مرة ثانية بسرعة أقل قليلًا، مع هدف واحد واضح: نفس ثابت ونهاية مقفولة.',
          nextExerciseId: 'foundation-repeat-with-count-in',
        ),
      ];
    }

    return const [];
  }

  List<AudioFeedbackInsight> _improvisationInsights(
    AudioAnalysisRequest request,
  ) {
    final completion = request.evaluation.completion;
    final exerciseId = request.exerciseId.toLowerCase();
    final insights = <AudioFeedbackInsight>[];

    if (exerciseId.contains('blues') || exerciseId.contains('guide')) {
      insights.add(
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.chordToneTargeting,
          issue: AudioFeedbackIssue.chordToneTargeting,
          musicalExplanation:
              'الفكرة العامة موجودة، لكن landing notes لا تشرح التغيّر الهارموني بما يكفي، خصوصًا عند نقاط الحل.',
          recommendedFix:
              'ارجع إلى 3rds و7ths فقط فوق نفس progression، ثم أضف note أو noteين color بعد ما يثبت الحل.',
          nextExerciseId: 'improv-guide-tone-lines',
        ),
      );
    }

    if (completion < 72) {
      insights.add(
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.improvisationLogic,
          issue: AudioFeedbackIssue.useOfSpace,
          musicalExplanation:
              'فيه محاولة جيدة لاستكمال الجملة، لكن المساحات قليلة، وده يجعل كل فكرة تبدو متصلة أكثر من اللازم.',
          recommendedFix:
              'سجّل take ثانية تستخدم فيها نفس number of ideas تقريبًا لكن مع rests أوضح بين الجمل.',
          nextExerciseId: 'blues-level-1-basic',
        ),
      );
    } else if (completion < 85) {
      insights.add(
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.improvisationLogic,
          issue: AudioFeedbackIssue.motivicDevelopment,
          musicalExplanation:
              'عندك material جيدة، لكن الجملة التالية لا تطور ما قبلها بما يكفي، فتفقد الـ thread الموسيقية بين الأفكار.',
          recommendedFix:
              'خذ motif واحدة فقط من هذه المحاولة وكررها بثلاث variations rhythmically قبل إضافة فكرة جديدة.',
          nextExerciseId: 'improv-linear-harmony-lab',
        ),
      );
    } else {
      insights.add(
        AudioFeedbackInsight(
          score: completion,
          category: FeedbackCategory.improvisationLogic,
          issue: AudioFeedbackIssue.resolutionQuality,
          musicalExplanation:
              'الفكرة الأساسية متماسكة، والحل في نهاية الجملة واضح، لكن يمكنك جعل resolution أجرأ أو أكثر غنائية.',
          recommendedFix:
              'أعد نفس الجملة مع نهاية أبسط قليلًا ومركز أوضح على note الحل الأساسية.',
          nextExerciseId: 'improv-bebop-resolution-lab',
        ),
      );
    }

    return insights;
  }

  List<FeedbackCategoryScore> _summarizeCategories(
    List<AudioFeedbackInsight> insights,
    AudioAnalysisRequest request,
  ) {
    if (insights.isEmpty) {
      return [
        FeedbackCategoryScore(
          category: _isFoundationFlow(request)
              ? FeedbackCategory.tone
              : FeedbackCategory.improvisationLogic,
          score: request.evaluation.completion.toDouble(),
          note: _isFoundationFlow(request)
              ? 'أساسيات اليوم مستقرة، والخطوة التالية هي إعادة نفس الفكرة بثقة أكبر أو على سرعة أعلى قليلًا.'
              : 'أداؤك متماسك، والخطوة التالية هي رفع التحدي تدريجيًا مع الحفاظ على نفس الثبات.',
        ),
      ];
    }

    final byCategory = <FeedbackCategory, List<AudioFeedbackInsight>>{};
    for (final insight in insights) {
      byCategory.putIfAbsent(insight.category, () => []).add(insight);
    }

    return byCategory.entries.map((entry) {
      final average =
          entry.value.fold<int>(0, (sum, item) => sum + item.score) /
              entry.value.length;
      return FeedbackCategoryScore(
        category: entry.key,
        score: average,
        note: entry.value.first.musicalExplanation,
      );
    }).toList(growable: false);
  }

  String _buildSummary(
    AudioAnalysisRequest request,
    List<AudioFeedbackInsight> insights,
  ) {
    if (insights.isEmpty) {
      if (_isFoundationFlow(request)) {
        return 'محاولتك الأساسية مستقرة عمومًا. النغمة والوقت وشكل الجملة في مكان جيد، والخطوة التالية هي تثبيت نفس الجودة في محاولة ثانية.';
      }

      return 'محاولتك مستقرة عمومًا. النغمات والوقت والبناء العام في مكان جيد، والخطوة التالية هي زيادة التحدي من غير التضحية بالوضوح.';
    }

    final first = insights.first;
    final second = insights.length > 1 ? insights[1] : null;
    final secondText = second == null
        ? ''
        : ' وبعدها راجع ${_summaryFocusLabel(second)} لأنّه ما زال يؤثر على ثبات المحاولة.';

    return '${first.musicalExplanation}$secondText';
  }

  String _buildNextStep(
    AudioAnalysisRequest request,
    List<AudioFeedbackInsight> insights,
  ) {
    if (insights.isEmpty) {
      if (_isFoundationFlow(request)) {
        return 'أعد نفس المحاولة مرة ثانية مع count-in واضح وثبات أكبر، ثم قرر بعدها هل أنت جاهز لسرعة أعلى أو لليوم التالي.';
      }

      return 'أعد نفس المحاولة مرة أخرى على challenge أعلى قليلًا، أو انقل نفس الفكرة إلى مفتاح جديد ثم سجّلها من جديد.';
    }

    return insights.first.recommendedFix;
  }

  bool _isFoundationFlow(AudioAnalysisRequest request) {
    final exerciseId = request.exerciseId.toLowerCase();
    if (_containsKeyword(exerciseId, _jazzExerciseKeywords)) {
      return false;
    }

    if (_containsKeyword(exerciseId, _foundationExerciseKeywords)) {
      return true;
    }

    return request.dayNumber <= 30;
  }

  bool _containsKeyword(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  String _summaryFocusLabel(AudioFeedbackInsight insight) {
    switch (insight.category) {
      case FeedbackCategory.pitch:
      case FeedbackCategory.intonation:
        return 'ثبات النغمة';
      case FeedbackCategory.rhythm:
      case FeedbackCategory.swingFeel:
        return 'ثبات التوقيت';
      case FeedbackCategory.articulation:
        return 'نهايات الجملة';
      case FeedbackCategory.tone:
        return 'مركز الصوت';
      case FeedbackCategory.phraseShape:
        return 'اكتمال الجملة';
      case FeedbackCategory.improvisationLogic:
        return 'تسلسل الفكرة';
      case FeedbackCategory.chordToneTargeting:
        return 'وضوح الهبوط على النغمات المهمة';
    }
  }
}
