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
        1 => 'الأسبوع 1 · الصوت والوقت',
        2 => 'الأسبوع 2 · لغة البلوز',
        3 => 'الأسبوع 3 · نغمات الدومينانت والدليل',
        _ => 'الأسبوع 4 · الـ ii-V-I وأول عزف منفرد',
      };
      final summary = switch (weekNumber) {
        1 =>
          'أساسيات النغمة، نغمات طويلة، الخماسي الصغير، السوينغ كروش، والإيقاع على نغمة واحدة.',
        2 =>
          'بلوز الـ 12 مازورة، سلم البلوز، الاستجابة والنداء، شكل الجملة، المساحات، والتكرار.',
        3 =>
          'صوت الدومينانت السابع، الثالث والسابع، نغمات الدليل، جاز بلوز، والقيادة الصوتية البسيطة.',
        _ =>
          'الـ ii-V-I، مداخل بيبوب بسيطة، أول عزف منفرد كامل، التسجيل والتقييم، وجملة شخصية من مازورتين.',
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
      title: 'منهج الـ 30 يوماً لمبتدئي الساكسفون',
      summary:
          'مسار جاد للشهر الأول يربط بين الصوت، السوينغ، البلوز، تدريب الأذن، النظرية، الارتجال والتسجيل.',
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
    title: 'تجهيز الساكس + أساسيات النغمة',
    summary: 'الوضعية، التنفس، شكل الفم، النغمات الطويلة، ومركز النغمة.',
  ),
  MvpCurriculumModule(
    id: 'swing_rhythm_trainer',
    order: 2,
    title: 'مدرب إيقاع السوينغ',
    summary:
        'نبض الربع نوار، كروش السوينغ، الإيقاع على نغمة واحدة، والتموضع.',
  ),
  MvpCurriculumModule(
    id: 'blues_course',
    order: 3,
    title: 'دورة البلوز',
    summary:
        'قالب الـ 12 مازورة، سلم البلوز، منطق الجملة، المساحة، التكرار، والاستجابة.',
  ),
  MvpCurriculumModule(
    id: 'ii_v_i_course',
    order: 4,
    title: 'دورة الـ ii-V-I',
    summary:
        'نغمات الدليل، لون الدومينانت، القيادة الصوتية البسيطة، وأول الخطوط العزفية.',
  ),
  MvpCurriculumModule(
    id: 'backing_tracks',
    order: 5,
    title: 'المسارات المصاحبة',
    summary:
        'حلقات أصلية للبلوز، نبض السوينغ، جاز بلوز، ودراسة الـ ii-V-I.',
  ),
  MvpCurriculumModule(
    id: 'record_feedback',
    order: 6,
    title: 'التسجيل وملاحظات التوقيت',
    summary:
        'سجل، اسمع، قيم، أعد المحاولة ببطء، واحفظ التصحيحات الواضحة.',
  ),
  MvpCurriculumModule(
    id: 'twelve_key_trainer',
    order: 7,
    title: 'مدرب الأنماط في 12 مقام',
    summary: 'تحريك الخلايا البسيطة عبر المقامات دون فقدان النغمة أو الوقت.',
  ),
  MvpCurriculumModule(
    id: 'transposition_bb_eb',
    order: 8,
    title: 'النقل للساكسفون Bb/Eb',
    summary: 'عرض الكونسيرت، التينور، والألتو لنفس مادة الدرس.',
  ),
  MvpCurriculumModule(
    id: 'daily_practice_generator',
    order: 9,
    title: 'مولد التدريب اليومي',
    summary:
        'خطط صغيرة متكيفة مبنية من الضعف، السرعة، والدورة الحالية.',
  ),
  MvpCurriculumModule(
    id: 'progress_dashboard',
    order: 10,
    title: 'لوحة التقدم',
    summary:
        'النغمة، التوقيت، الأذن، النظرية، الارتجال، المقطوعات، والسلسلة.',
  ),
];

final List<_DaySeed> _week1Seeds = [
  const _DaySeed(
    dayNumber: 1,
    weekNumber: 1,
    title: 'تجهيز الساكس ومركز النغمة',
    focus: 'أساسيات النغمة وتجهيز الآلة',
    description:
        'ابنِ أول صوت بوضعية الجسم الصحيحة، الهواء، شكل الفم، ومركز نغمة مستقر.',
    skillAreas: [SkillArea.tone, SkillArea.technique],
    concepts: ['tone basics', 'air support', 'embouchure'],
    moduleIds: ['sax_setup_tone_basics', 'progress_dashboard'],
    exerciseType: ExerciseType.longTone,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 56, maxBpm: 66),
    whatDoIHear: 'نغمة واحدة مركزة بدون اهتزاز وبدون بداية مشدودة.',
    whatDoIPlay:
        'نغمات طويلة على نغمة واحدة مستقرة مع بدايات نظيفة وهواء مسترخٍ.',
    whyDoesItWork:
        'لأن النغمة تبدأ من توجيه الهواء وشكل الفم الداخلي قبل حركة الأصابع.',
    whereInRealJazz:
        'كل عازف ساكسفون جاز قوي يحمل هذا المركز حتى في الألحان الهادئة والسوينغ المتوسط.',
    howDoIUseItInMySolo:
        'أحافظ على نفس مركز النغمة عندما تصبح الجمل أعلى، أهدأ، أو أكثر إيقاعية.',
    listeningAssignment:
        'استمع لما إذا كانت النغمة تتفتح أو تنهار بعد البداية.',
    improvisationAssignment:
        'اعزف نغمة واحدة بثلاثة أشكال ديناميكية (قوة الصوت) واجعل كل منها موسيقياً.',
  ),
  const _DaySeed(
    dayNumber: 2,
    weekNumber: 1,
    title: 'نغمات طويلة مع قوس ديناميكي',
    focus: 'النغمات الطويلة والتحكم في قوة الصوت',
    description:
        'قم بتوسيع نغمة واحدة من الهدوء الشديد إلى القوة القصوى والعودة دون فقدان المركز.',
    skillAreas: [SkillArea.tone, SkillArea.feedback],
    concepts: ['long tones', 'dynamics', 'stability'],
    moduleIds: ['sax_setup_tone_basics', 'record_feedback'],
    exerciseType: ExerciseType.longTone,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 52, maxBpm: 62),
    whatDoIHear:
        'نغمة تبقى مضبوطة (in tune) بينما يصبح الهواء أوسع وأقوى.',
    whatDoIPlay: 'نغمات ممتدة مع زيادة ونقصان تدريجي في قوة الصوت.',
    whyDoesItWork:
        'التحكم الديناميكي يعلم دعم التنفس واستقرار حدة النغمة في نفس الوقت.',
    whereInRealJazz:
        'الألحان الهادئة، المقدمات، والنغمات الممتدة في نهايات الجمل تحتاج لهذا التحكم.',
    howDoIUseItInMySolo:
        'أقوم بتشكيل نهايات الجمل بديناميكيات محكومة بدلاً من مجرد إيقاف النغمة.',
    listeningAssignment:
        'لاحظ ما إذا كانت حدة النغمة ترتفع عند النقاط العالية أو تنخفض عند النقاط الهادئة.',
    improvisationAssignment:
        'أنهِ جملتين قصيرتين بنغمة ممتدة تقوى ثم تتلاشى.',
    recordCheckpoint:
        'سجل نغمة طويلة واحدة مع قوس ديناميكي وقارن بين البداية والمنتصف والنهاية.',
  ),
  const _DaySeed(
    dayNumber: 3,
    weekNumber: 1,
    title: 'بداية النطق الأساسي',
    focus: 'النطق الأساسي (Articulation)',
    description:
        'ابدأ النغمات بلمسة لسان خفيفة وهواء متصل، وليس بهجوم قاصٍ.',
    skillAreas: [SkillArea.articulation, SkillArea.tone],
    concepts: ['basic articulation', 'tongue placement', 'connected air'],
    moduleIds: ['sax_setup_tone_basics', 'record_feedback'],
    exerciseType: ExerciseType.articulation,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 64, maxBpm: 78),
    whatDoIHear: 'بداية واضحة بدون صوت "كليك" وبدون فجوة بعد اللسان.',
    whatDoIPlay:
        'نغمات منطوقة متكررة على درجة صوتية واحدة، "ليغاتو" أولاً ثم مفصولة بخفة.',
    whyDoesItWork:
        'اللسان يحرر الهواء؛ لا ينبغي أن يحل محل تيار الهواء.',
    whereInRealJazz: 'حتى مقطوعات السوينغ البسيطة تحتاج لوضوح بدون خشونة.',
    howDoIUseItInMySolo:
        'أختار بدايات أخف أو أقوى لتشكيل طابع الجملة.',
    listeningAssignment:
        'استمع لما إذا كانت النغمة تنطق فوراً بعد اللسان أو تبدو "مخنوقة".',
    improvisationAssignment:
        'اعزف نداء واستجابة صغيراً جداً باستخدام تباين النطق فقط.',
  ),
  const _DaySeed(
    dayNumber: 4,
    weekNumber: 1,
    title: 'شكل الخماسي الصغير 1',
    focus: 'تأسيس السلم الخماسي الصغير',
    description:
        'تعلم صوتاً خماسياً واحداً مضغوطاً واسمعه كمادة للجمل، وليس كمجرد صعود سلم.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation, SkillArea.theory],
    concepts: ['minor pentatonic', 'small cell', 'phrase shape'],
    moduleIds: ['blues_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.scale,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 68, maxBpm: 84),
    whatDoIHear:
        'صوت خماسي من خمس نغمات محكم مع جاذبية البلوز وبدون فوضى زائدة.',
    whatDoIPlay:
        'خلية خماسية صغيرة صعوداً وهبوطاً مع مساحة بين التكرارات.',
    whyDoesItWork:
        'مجموعة نغمات محدودة تساعد الإيقاع والصوت ليصبحا هما التركيز.',
    whereInRealJazz:
        'البلوز، الفانك، سياقات الـ minor vamp، ولغة الارتجال المبكرة.',
    howDoIUseItInMySolo:
        'آخذ فقط 3-4 نغمات من المجموعة وأصنع جملة بدلاً من عزف الخمس نغمات كلها.',
    listeningAssignment:
        'اسمع أي نغمة تبدو كأنها "البيت" (القرار) وأي واحدة تريد الدفع للأمام.',
    improvisationAssignment:
        'ارتجل مازورتين باستخدام ثلاث نغمات خماسية فقط.',
  ),
  const _DaySeed(
    dayNumber: 5,
    weekNumber: 1,
    title: 'إحساس السوينغ كروش',
    focus: 'كروش السوينغ (Swing Eighths)',
    description:
        'تعلم أن السوينغ هو تموضع وإحساس، وليس صيغة رياضية ثابتة للثلاثيات.',
    skillAreas: [SkillArea.swing, SkillArea.rhythm],
    concepts: ['swing eighths', 'offbeat placement', 'pulse'],
    moduleIds: ['swing_rhythm_trainer', 'backing_tracks'],
    exerciseType: ExerciseType.swingSubdivision,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear:
        'نغمات الـ offbeat التي تستقر داخل النبض بدلاً من أن تبدو جامدة أو مستقيمة.',
    whatDoIPlay:
        'إيقاعات سوينغ من مازورتين على نغمة واحدة، مصفقة أولاً، ثم معزوفة.',
    whyDoesItWork:
        'السوينغ الجيد يأتي من العلاقة بالنبض، وليس من حفظ النسبة.',
    whereInRealJazz: 'جمل السوينغ المتوسطة، المقطوعات، واللازمات البسيطة.',
    howDoIUseItInMySolo:
        'أحافظ على نفس الإيقاع وأغير الدرجات الصوتية فقط بمجرد أن يشعر التموضع بالصحة.',
    listeningAssignment:
        'قارن نغمات الـ offbeat الخاصة بك مع الميترونوم على 2 و 4.',
    improvisationAssignment:
        'اعزف خلية إيقاعية واحدة ثلاث مرات بنفس إحساس السوينغ.',
  ),
  const _DaySeed(
    dayNumber: 6,
    weekNumber: 1,
    title: 'الإيقاع على نغمة واحدة',
    focus: 'الإيقاع على نغمة واحدة',
    description:
        'أبعد الدرجة الصوتية عن المشكلة ودرب إحساس الوقت، النطق، وشكل الجملة.',
    skillAreas: [SkillArea.rhythm, SkillArea.articulation, SkillArea.swing],
    concepts: ['one-note rhythm', 'pulse consistency', 'phrase ending'],
    moduleIds: ['swing_rhythm_trainer', 'record_feedback'],
    exerciseType: ExerciseType.rhythmPlayback,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 96),
    whatDoIHear: 'الإيقاع كرسالة موسيقية حتى عندما لا تتغير الدرجة الصوتية أبداً.',
    whatDoIPlay:
        'جمل إيقاعية قصيرة على نغمة واحدة مع بدايات ونهايات واضحة.',
    whyDoesItWork:
        'إنه يعزل محرك الجاز الحقيقي: الوقت، الشكل، والنطق.',
    whereInRealJazz:
        'اللازمات (Riffs)، أشكال الـ shout، والموتيفات المتكررة.',
    howDoIUseItInMySolo:
        'يمكنني الاحتفاظ بفكرة إيقاعية واحدة ونقلها لاحقاً إلى نغمات جديدة.',
    listeningAssignment:
        'استمع لما إذا كانت كل الهجمات تقع في نفس "الجيب" (المكان الصحيح).',
    improvisationAssignment:
        'ارتجل 4 موازير على نغمة واحدة واجعلها تبدو مقصودة.',
  ),
  const _DaySeed(
    dayNumber: 7,
    weekNumber: 1,
    title: 'دمج الأسبوع الأول',
    focus: 'مراجعة النغمة + النطق + الإيقاع',
    description:
        'اجمع بين النغمة المستقرة، النطق الخفيف، إيقاع النغمة الواحدة، ولون الخماسي الصغير.',
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
        'جملة بسيطة لا تزال تبدو موسيقية لأن الصوت والوقت منظمان.',
    whatDoIPlay: 'إيقاع نغمة واحدة أولاً، ثم إجابة خماسية صغيرة.',
    whyDoesItWork:
        'الأسبوع الأول ينجح فقط إذا ظل الصوت والوقت متصلين من أول جملة.',
    whereInRealJazz:
        'المقدمات البسيطة، جلسات العزف للطلاب، وارتجال اللازمات المبكر.',
    howDoIUseItInMySolo:
        'أبني جملاً قصيرة من الإيقاع أولاً، ثم أضيف حركة كافية من الدرجات الصوتية.',
    listeningAssignment:
        'استمع مرة أخرى واسأل ما إذا كانت جملة الإجابة تتناقض حقاً مع النداء.',
    improvisationAssignment: 'أنشئ نداءً من مازورتين وإجابة من مازورتين.',
    recordCheckpoint: 'سجل مراجعة الأسبوع الأول واحفظها كمرجع أساسي لك.',
  ),
];

final List<_DaySeed> _week2Seeds = [
  const _DaySeed(
    dayNumber: 8,
    weekNumber: 2,
    title: 'خريطة بلوز الـ 12 مازورة',
    focus: 'قالب البلوز المكون من 12 مازورة',
    description: 'اسمع الهيكل قبل محاولة ملئه بالنغمات.',
    skillAreas: [SkillArea.blues, SkillArea.theory, SkillArea.repertoire],
    concepts: ['12-bar blues', 'form', 'I7 IV7 V7'],
    moduleIds: ['blues_course', 'backing_tracks', 'transposition_bb_eb'],
    exerciseType: ExerciseType.bluesPhrase,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 94),
    whatDoIHear:
        'صوت القرار (I)، الانتقال للرابع (IV)، وتحول الطاقة في الموازير 9-10.',
    whatDoIPlay: 'نغمات الأساس (Roots) ونقاط دليل بسيطة عبر القالب بالكامل.',
    whyDoesItWork: 'إذا لم يكن القالب واضحاً، تفقد كل جملة معناها.',
    whereInRealJazz: 'مقطوعات البلوز، جلسات الارتجال، اللازمات، وهياكل السولو.',
    howDoIUseItInMySolo:
        'أقوم بتحديد الموازير الرئيسية بالإيقاع والمساحة بدلاً من ملء كل مازورة.',
    listeningAssignment:
        'صفّق عند المازورة 1، المازورة 5، والمازورة 9 أثناء الاستماع للحلقة.',
    improvisationAssignment:
        'اعزف نغمة واحدة فقط، لكن أظهر القالب من خلال إيقاعك.',
  ),
  const _DaySeed(
    dayNumber: 9,
    weekNumber: 2,
    title: 'صوت سلم البلوز',
    focus: 'سلم البلوز',
    description:
        'استخدم سلم البلوز كصوت ولون، وليس كمجرد صعود ونزول مستمر.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation],
    concepts: ['blues scale', 'blue note', 'color tone'],
    moduleIds: ['blues_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.scale,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 96),
    whatDoIHear:
        'لون بلوز قوي مع "نغمة البلوز" (Blue Note) التي تعمل كتوتر، وليس كقاعدة أساسية.',
    whatDoIPlay:
        'خلايا قصيرة من سلم البلوز في مقام واحد، ثم في مقام قريب آخر.',
    whyDoesItWork:
        'نغمة البلوز تعبيرية بسبب مكان وكيفية وضعك لها.',
    whereInRealJazz: 'سولوهات البلوز، خطوط الفانك، وجمل الكروس أوفر البسيطة.',
    howDoIUseItInMySolo:
        'ألمس نغمة البلوز لفترة وجيزة، ثم أحلّها أو أكررها إيقاعياً.',
    listeningAssignment: 'اسمع ما إذا كانت نغمة البلوز تبدو موضوعة بعناية أم عشوائية.',
    improvisationAssignment:
        'اعزف فكرتين من مازورتين باستخدام نغمة البلوز مرة واحدة في كل فكرة.',
  ),
  const _DaySeed(
    dayNumber: 10,
    weekNumber: 2,
    title: 'النداء والاستجابة في البلوز',
    focus: 'النداء والاستجابة (Call and Response)',
    description:
        'اجعل الجمل القصيرة تتحدث مع بعضها البعض بدلاً من أن تبدو كجمل منفصلة.',
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
        'جملة أولى تسأل شيئاً وجملة ثانية تجيب بتغيير في الشكل أو الإيقاع.',
    whatDoIPlay: 'نداء من مازورتين، استجابة من مازورتين، ثم صمت.',
    whyDoesItWork:
        'المحادثة تخلق اتجاهاً أفضل من الأفكار المنفصلة.',
    whereInRealJazz:
        'كورس البلوز، فرق اللازمات، وجمل الساكس المتأثرة بالغناء.',
    howDoIUseItInMySolo:
        'أجيب على جملتي الخاصة بتباين في الإيقاع، المساحة، أو المنطقة الصوتية.',
    listeningAssignment: 'غنِّ الاستجابة قبل أن تعزفها.',
    improvisationAssignment:
        'أنشئ ثلاث استجابات مختلفة لنفس النداء.',
  ),
  const _DaySeed(
    dayNumber: 11,
    weekNumber: 2,
    title: 'جملة بلوز بسيطة 1',
    focus: 'جمل بلوز بسيطة',
    description:
        'ابنِ جملة واحدة محكمة بنهاية واضحة وكررها في الوقت الصحيح.',
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
        'جملة قصيرة بما يكفي لتذكرها ولكنها قوية بما يكفي لتكرارها.',
    whatDoIPlay:
        'جملة بلوز من مازورتين مع مسار واحد واضح ونهاية واحدة واضحة.',
    whyDoesItWork:
        'المادة البسيطة تصبح مقنعة عندما يكون الإيقاع والنهاية واضحين.',
    whereInRealJazz: 'مقطوعات البلوز، سولوهات المبتدئين، ولازمات الـ shout.',
    howDoIUseItInMySolo:
        'أكرر الجملة مع تغيير واحد صغير بدلاً من التخلي عنها.',
    listeningAssignment:
        'تأكد مما إذا كانت الجملة تتوقف بوضوح أم تتلاشى بضعف.',
    improvisationAssignment:
        'كرر جملتك ثلاث مرات مع تغيير بسيط جداً في كل مرة.',
  ),
  const _DaySeed(
    dayNumber: 12,
    weekNumber: 2,
    title: 'المساحة في ارتجال البلوز',
    focus: 'المساحة والوتيرة (Pacing)',
    description: 'اترك صمتاً عن قصد لكي تعني الجملة شيئاً ما.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation, SkillArea.rhythm],
    concepts: ['space', 'pacing', 'breath planning'],
    moduleIds: ['blues_course', 'record_feedback'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear: 'الصمت كجزء من الجملة، وليس كخطأ فارغ.',
    whatDoIPlay: 'جملة قصيرة واحدة، نفس واحد، ثم استراحة.',
    whyDoesItWork:
        'المساحة تسمح للمستمع بسماع الشكل، الوقت، والاستجابة في قسم الإيقاع.',
    whereInRealJazz:
        'سولوهات البلوز القوية، جمل الألحان الهادئة، والخطوط بأسلوب الغناء.',
    howDoIUseItInMySolo:
        'أتوقف قبل أن تنفد أفكاري لكي تبدأ الجملة التالية بشكل أقوى.',
    listeningAssignment:
        'اسمع ما إذا كانت الاستراحة تخلق توتراً أم تبدو مجرد صدفة.',
    improvisationAssignment: 'اعزف ثلاث جمل قصيرة فقط في كورس واحد كامل.',
  ),
  const _DaySeed(
    dayNumber: 13,
    weekNumber: 2,
    title: 'التكرار مع التنويع',
    focus: 'التكرار والتطوير',
    description:
        'كرر جملة لأنها تعني شيئاً، ثم قم بثنيها قليلاً.',
    skillAreas: [SkillArea.blues, SkillArea.improvisation],
    concepts: ['repetition', 'variation', 'motivic development'],
    moduleIds: ['blues_course', 'daily_practice_generator'],
    exerciseType: ExerciseType.bluesPhrase,
    level: DifficultyLevel.beginner,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 98),
    whatDoIHear:
        'فكرة يمكن التعرف عليها تعود مع تغيير واحد في الإيقاع، النهاية، أو المنطقة الصوتية.',
    whatDoIPlay: 'نفس فكرة البلوز ثلاث مرات مع تنويع محكوم.',
    whyDoesItWork: 'التكرار يخلق الهوية؛ التنويع يخلق الحركة.',
    whereInRealJazz:
        'سولوهات البلوز، اللازمات، وحتى جمل البيبوب بسرعات أبطأ.',
    howDoIUseItInMySolo:
        'أحافظ على الموتيف حياً عبر الموازير بدلاً من اختراع فكرة جديدة كل ثانية.',
    listeningAssignment:
        'انظر ما إذا كان المستمع لا يزال بإمكانه التعرف على الفكرة بعد تنويعك.',
    improvisationAssignment: 'خذ فكرة من مازورتين وعبّر عنها بثلاث طرق.',
  ),
  const _DaySeed(
    dayNumber: 14,
    weekNumber: 2,
    title: 'كورس بلوز الأسبوع 2',
    focus: 'دمج مهارات البلوز',
    description:
        'اعزف كورس بلوز قصيراً واحداً باستخدام القالب، المساحة، الاستجابة، وذاكرة الجملة.',
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
        'كورس كامل لا يزال يبدو منظماً لأن الموازير وأدوار الجمل واضحة.',
    whatDoIPlay: 'كورس كامل من 12 مازورة فوق مسار بلوز مصاحب.',
    whyDoesItWork:
        'الكورس الكامل يعلم الذاكرة، الوتيرة، والقالب في نفس الوقت.',
    whereInRealJazz:
        'جلسات البلوز الجماعية، مواقع السولو البسيطة، وأقسام التبادل في الفرقة.',
    howDoIUseItInMySolo:
        'أبني الكورس من أفكار ذات مازورتين بدلاً من سلاسل نغمات عشوائية.',
    listeningAssignment:
        'بعد التسجيل، حدد أين حدثت أقوى وأضعف موازيرك.',
    improvisationAssignment:
        'اعزف كورس واحد كامل وحافظ على فكرة متكررة واحدة حية لمدة 4 موازير على الأقل.',
    recordCheckpoint:
        'سجل أول كورس بلوز لك واحفظه للمقارنة في الأسبوع الرابع.',
  ),
];

final List<_DaySeed> _week3Seeds = [
  const _DaySeed(
    dayNumber: 15,
    weekNumber: 3,
    title: 'صوت كورد الدومينانت السابع',
    focus: 'كوردات الدومينانت السابع (Dominant 7th)',
    description:
        'اسمع الدومينانت كتوتر يريد التحرك، وليس مجرد تسمية سلم.',
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
        'كورد يريد الاستقرار بسبب سحب نغمتي الثالث والسابع فيه.',
    whatDoIPlay: 'نغمات الأساس، الثالث، الخامس، والسابع في أنماط إيقاعية بطيئة.',
    whyDoesItWork:
        'نغمات الكورد تحدد الهارموني قبل ظهور أي لون من السلم.',
    whereInRealJazz:
        'البلوز، ii-V-I، والتحولات في كل مكان.',
    howDoIUseItInMySolo:
        'أستهدف نغمة الثالث أو السابع أولاً قبل إضافة نغمات ملونة.',
    listeningAssignment:
        'غنِّ الثالث والسابع وحدهما واسمع السحب بدون نغمة الأساس.',
    improvisationAssignment:
        'ارتجل مازورتين باستخدام نغمات كورد الدومينانت فقط.',
  ),
  const _DaySeed(
    dayNumber: 16,
    weekNumber: 3,
    title: 'الثالث والسابع أولاً',
    focus: 'نغمات الثالث والسابع',
    description: 'اجعل الثالث والسابع خريطتك الأولى قبل أي نغمات إضافية.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['3rds', '7ths', 'target notes'],
    moduleIds: ['ii_v_i_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 76, maxBpm: 92),
    whatDoIHear:
        'فقط النغمات التي تخبرك بنوع الكورد (كبير، صغير، أو دومينانت) فوراً.',
    whatDoIPlay: 'أنماط تعتمد على الثالث فقط والسابع فقط عبر تتابعات قصيرة.',
    whyDoesItWork:
        'هذه النغمات تحدد الوظيفة والاستقرار بأقل قدر من المادة.',
    whereInRealJazz: 'منطق المصاحبة، السولوهات، والسماع الداخلي للهرموني.',
    howDoIUseItInMySolo: 'أبدأ من نقاط الدليل ثم أقوم بزخرفتها.',
    listeningAssignment:
        'استمع ما إذا كان نوع الكورد لا يزال واضحاً عند إزالة الأساس والخامس.',
    improvisationAssignment: 'اعزف خطاً من مازورتين باستخدام الثالث والسابع فقط.',
  ),
  const _DaySeed(
    dayNumber: 17,
    weekNumber: 3,
    title: 'نغمات الدليل عبر حركة البلوز',
    focus: 'نغمات الدليل (Guide Tones)',
    description:
        'تحرك بسلاسة من هدف نغمة دليل إلى التالي عبر هارموني البلوز.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation, SkillArea.blues],
    concepts: ['guide tones', 'voice leading', 'blues harmony'],
    moduleIds: ['ii_v_i_course', 'blues_course'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 94),
    whatDoIHear:
        'نغمات تستقر بالخطوة أو النغمة المشتركة بدلاً من القفز العشوائي.',
    whatDoIPlay: 'خطوط بسيطة من نغمات الدليل عبر الموازير الرئيسية للبلوز.',
    whyDoesItWork:
        'القيادة الصوتية تجعل الخط يبدو متصلاً بالهارموني.',
    whereInRealJazz:
        'الجاز بلوز، التتابعات القياسية، وداخل لغة البيبوب.',
    howDoIUseItInMySolo:
        'أترك الكورد التالي يسحب الخط بدلاً من إجبار الأنماط.',
    listeningAssignment:
        'اسمع ما إذا كانت كل نغمة تنتمي للكورد التالي، وليس الحالي فقط.',
    improvisationAssignment:
        'اربط أربع موازير باستخدام نغمات الدليل فقط بلس نغمة عبور واحدة.',
  ),
  const _DaySeed(
    dayNumber: 18,
    weekNumber: 3,
    title: 'تغييرات جاز بلوز',
    focus: 'الجاز بلوز',
    description:
        'قم بترقية قالب البلوز الأساسي بحركة، تحولات، وهارموني أقوى.',
    skillAreas: [SkillArea.blues, SkillArea.theory, SkillArea.repertoire],
    concepts: ['jazz blues', 'turnaround', 'dominant movement'],
    moduleIds: ['blues_course', 'backing_tracks', 'ii_v_i_course'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 86, maxBpm: 104),
    whatDoIHear:
        'حركة أكثر من البلوز الأساسي، خاصة في مناطق التحول (Turnaround).',
    whatDoIPlay: 'جمل قصيرة تحترم حركة الكوردات المضافة.',
    whyDoesItWork:
        'الجاز بلوز يضيف حركة للأمام، والتي تتطلب أهدافاً أوضح.',
    whereInRealJazz:
        'جلسات الارتجال، مقطوعات البلوز الكلاسيكية، وريبورتوار البيبوب المبكر.',
    howDoIUseItInMySolo:
        'أقوم بالتبسيط من خلال سماع الأهداف القوية بدلاً من مطاردة كل رمز كورد.',
    listeningAssignment:
        'استمع للمكان الذي يتسارع فيه الهارموني والمكان الذي يسترخي فيه.',
    improvisationAssignment:
        'اعزف كورس واحد وحدد الموازير 4، 8، و 11 بأهداف واضحة.',
  ),
  const _DaySeed(
    dayNumber: 19,
    weekNumber: 3,
    title: 'قيادة صوتية بسيطة',
    focus: 'القيادة الصوتية البسيطة (Voice Leading)',
    description: 'اربط النغمات القريبة بسلاسة عبر الكوردات المتغيرة.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['voice leading', 'nearest note', 'resolution'],
    moduleIds: ['ii_v_i_course', 'daily_practice_generator'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.earlyIntermediate,
    tempoRange: TempoRange(minBpm: 74, maxBpm: 90),
    whatDoIHear:
        'خطوط تتحرك بهدف لأن كل هدف يأتي من الهدف السابق بشكل طبيعي.',
    whatDoIPlay: 'حركة لأقرب نغمة عبر سلاسل كوردات قصيرة.',
    whyDoesItWork: 'الخطوط الجيدة تبدو حتمية عندما تكون الحركة اقتصادية.',
    whereInRealJazz:
        'خطوط نغمات الدليل، جمل البيبوب، وكتابة الساكس المنظمة.',
    howDoIUseItInMySolo:
        'أتحرك لأقرب نغمة مهمة بدلاً من إعادة البدء من الأساس (Root).',
    listeningAssignment:
        'اسأل ما إذا كان الخط لا يزال يغني إذا عزفته ببطء بدون قسم إيقاع.',
    improvisationAssignment:
        'ابنِ خطاً من 4 نغمات يستقر مرتين بدون قفزات.',
  ),
  const _DaySeed(
    dayNumber: 20,
    weekNumber: 3,
    title: 'نغمات الدليل في 3 مقامات',
    focus: 'نغمات الدليل في مقامات متعددة',
    description: 'حرك خلية نغمات دليل صغيرة عبر ثلاث مقامات عملية.',
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
    whatDoIHear: 'نفس الوظيفة الهارمونية تنجو في مركز مقامي جديد.',
    whatDoIPlay: 'خلية نغمات دليل من نغمتين في مقامات C، F، و Bb.',
    whyDoesItWork: 'الطلاقة الحقيقية تبدأ عندما تنجو الفكرة من النقل (Transposition).',
    whereInRealJazz:
        'المقطوعات بمقامات مختلفة، البروفات، وعمل الأنماط التعليمية.',
    howDoIUseItInMySolo:
        'أحمل المفهوم إلى مقام جديد بدلاً من البدء من الصفر.',
    listeningAssignment:
        'تأكد مما إذا كانت الوظيفة لا تزال تشعر بنفس الشيء بعد النقل.',
    improvisationAssignment:
        'اعزف نفس فكرة نغمات الدليل ذات المازورتين في ثلاث مقامات.',
  ),
  const _DaySeed(
    dayNumber: 21,
    weekNumber: 3,
    title: 'مراجعة الدومينانت الأسبوع 3',
    focus: 'مراجعة الدومينانت ونغمات الدليل',
    description:
        'اجمع بين صوت الدومينانت، الثالث/السابع، الوعي بالجاز بلوز، والقيادة الصوتية.',
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
        'خط يبدو متصلاً بالهارموني حتى عندما يكون الإيقاع بسيطاً.',
    whatDoIPlay: 'كورس قصير واحد باستخدام نغمات الدليل كنقاط مرساة.',
    whyDoesItWork: 'الهرموني يبدو واضحاً عندما تكون نغمات الهدف مدروسة.',
    whereInRealJazz: 'الارتجال المبكر "داخل" الكوردات في البلوز والمقطوعات.',
    howDoIUseItInMySolo:
        'يمكنني الآن التصويب نحو الأهداف وترك الإيقاع يشكل الباقي.',
    listeningAssignment:
        'استمع مرة أخرى وحدد الموازير التي كانت فيها الأهداف أكثر وضوحاً.',
    improvisationAssignment:
        'ابنِ كورس واحد مع فكرة نغمات دليل واحدة تعود مرتين.',
    recordCheckpoint: 'سجل كورس نغمات دليل فوق جاز بلوز واحفظه.',
  ),
];

final List<_DaySeed> _week4Seeds = [
  const _DaySeed(
    dayNumber: 22,
    weekNumber: 4,
    title: 'صوت كورد ii-V-I',
    focus: 'صوت تتابع ii-V-I',
    description:
        'اسمع ii-V-I كحركة كاملة، وليس كثلاث صناديق نظرية منفصلة.',
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
        'التمهيد، التوتر، والاستقرار كجملة موسيقية واحدة.',
    whatDoIPlay:
        'نغمات الأساس، ثم نغمات الدليل، ثم نغمات الكورد عبر التتابع.',
    whyDoesItWork: 'الوظيفة تفسر لماذا يريد الخط الموسيقي الذهاب لمكان ما.',
    whereInRealJazz:
        'المقطوعات القياسية، مقطوعات البيبوب، والتحولات.',
    howDoIUseItInMySolo:
        'أحدد الاستقرار أولاً، ثم أضيف نغمات الاقتراب لاحقاً.',
    listeningAssignment:
        'غنِّ نغمة الاستقرار قبل أن تعزف كورد الـ V.',
    improvisationAssignment: 'ارتجل 4 موازير حول تتابع ii-V-I واحد فقط.',
  ),
  const _DaySeed(
    dayNumber: 23,
    weekNumber: 4,
    title: 'درس نغمات الدليل في ii-V-I',
    focus: 'نغمات الدليل في ii-V-I',
    description:
        'اسمع واعزف نغمات الثالث والسابع وهي تستقر بوضوح عبر التتابع.',
    skillAreas: [SkillArea.theory, SkillArea.improvisation],
    concepts: ['guide tones', 'ii-V-I', '3rds and 7ths'],
    moduleIds: ['ii_v_i_course', 'transposition_bb_eb'],
    exerciseType: ExerciseType.guideTone,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 78, maxBpm: 94),
    whatDoIHear: 'F ← F ← E و C ← B ← Bb كاستقرار هيكلي.',
    whatDoIPlay: 'أزواج نغمات الدليل فوق Dm7–G7–Cmaj7 والنسخ المنقولة.',
    whyDoesItWork:
        'نغمات الدليل تحمل الوظيفة حتى قبل وصول نغمات الكورد الكاملة.',
    whereInRealJazz:
        'داخل لغة الجاز، منطق المصاحبة، والقيادة الصوتية المبكرة في البيبوب.',
    howDoIUseItInMySolo:
        'أبدأ من نغمات الدليل، ثم أضيف الإيقاع، نغمات العبور، والإحاطة (Enclosure) لاحقاً.',
    listeningAssignment: 'غنِّ خطي نغمات الدليل قبل لمس الآلة.',
    improvisationAssignment:
        'استخدم نغمات الدليل فقط بلس نغمة عبور واحدة في 4 موازير.',
  ),
  const _DaySeed(
    dayNumber: 24,
    weekNumber: 4,
    title: 'مداخل بيبوب بسيطة',
    focus: 'مداخل بيبوب بسيطة (Approaches)',
    description:
        'أضف اقتراباً كروماتيكياً واحداً لهدف قوي بدلاً من عزف سلم كامل.',
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
        'توتر يحل فوراً في هدف، وليس نغمات خارجية عشوائية.',
    whatDoIPlay: 'اقترابات كروماتيكية من نغمة واحدة إلى الثالث أو السابع.',
    whyDoesItWork:
        'الكروماتيكية تبدو منطقية عندما يكون الهدف واضحاً والتوقيت قوياً.',
    whereInRealJazz: 'خطوط البيبوب، التحولات، ومفردات ii-V-I المدمجة.',
    howDoIUseItInMySolo:
        'أقوم بزخرفة هدف واحد مهم بدلاً من ملء كل نبضة كروماتيكياً.',
    listeningAssignment:
        'اسمع ما إذا كانت نغمة الاقتراب تبدو مقصودة أم مجرد تأخير.',
    improvisationAssignment: 'استخدم نغمة اقتراب واحدة في كل جملة من مازورتين.',
  ),
  const _DaySeed(
    dayNumber: 25,
    weekNumber: 4,
    title: 'ii-V-I في 3 مقامات',
    focus: 'تحريك ii-V-I عبر المقامات',
    description:
        'انقل نفس منطق نغمات الدليل إلى ثلاث مقامات تدريب شائعة.',
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
    whatDoIHear: 'نفس وظيفة التتابع بغض النظر عن حدة النغمات.',
    whatDoIPlay: 'خلية ii-V-I صغيرة واحدة في C، F، و Bb.',
    whyDoesItWork:
        'نقل المقامات هو كيف يصبح المفهوم قابلاً للاستخدام خارج غرفة التدريب.',
    whereInRealJazz: 'المقطوعات الحقيقية، البروفات، والدراسة المنقولة.',
    howDoIUseItInMySolo:
        'يمكنني أخذ فكرة مفضلة ذات مازورتين إلى المقامات القريبة بسرعة.',
    listeningAssignment:
        'تأكد مما إذا كنت لا تزال تسمع الاستقرار عند تغيير المقام.',
    improvisationAssignment:
        'اعزف نفس فكرة التتابع في 3 مقامات بوقت ثابت.',
  ),
  const _DaySeed(
    dayNumber: 26,
    weekNumber: 4,
    title: 'أول كورس سولو كامل',
    focus: 'أول كورس سولو كامل',
    description:
        'اجمع بين النغمة، الوقت، القالب، نغمات الدليل، لون البلوز، ومداخل البيبوب الصغيرة في كورس واحد.',
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
        'كورس كامل بجمل تتعلق بالهارموني ولا تزال تتنفس.',
    whatDoIPlay: 'كورس واحد فوق جاز بلوز أو حلقة تعتمد على ii-V-I.',
    whyDoesItWork:
        'الكورس يصبح متماسكاً عندما تعرف كل جملة دورها.',
    whereInRealJazz:
        'أي سولو صغير حيث يجب أن يقول كورس واحد شيئاً كاملاً.',
    howDoIUseItInMySolo:
        'أبدأ التفكير في كتل جمل متصلة بدلاً من "ليكات" منفصلة.',
    listeningAssignment:
        'حدد أين ذروة جملتك وأين تركت مساحة مفيدة.',
    improvisationAssignment:
        'ابنِ كورس كامل باستخدام فكرة متكررة واحدة على الأقل.',
  ),
  const _DaySeed(
    dayNumber: 27,
    weekNumber: 4,
    title: 'سجل وقيم',
    focus: 'سجل وقيم أداءك',
    description:
        'استخدم التسجيل كمعلم للتوقيت، الصوت، نهايات الجمل، والقالب.',
    skillAreas: [SkillArea.feedback, SkillArea.rhythm, SkillArea.tone],
    concepts: ['self-evaluation', 'timing feedback', 'retry slower'],
    moduleIds: ['record_feedback', 'progress_dashboard'],
    exerciseType: ExerciseType.backingTrackImprovisation,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 80, maxBpm: 96),
    whatDoIHear:
        'ما إذا كان إحساسك الحقيقي بالوقت يطابق ما تخيلته أثناء العزف.',
    whatDoIPlay:
        'نفس الكورس مرتين: الأولى طبيعية، والثانية بعد تصحيح واحد واضح.',
    whyDoesItWork:
        'التسجيل يكشف حقيقة التوقيت، النغمة، والجمل بشكل أفضل من الذاكرة.',
    whereInRealJazz:
        'غرف التدريب، التحضير للدروس، والنمو الموجه ذاتياً.',
    howDoIUseItInMySolo:
        'أحول نقطة ضعف واحدة إلى أول تدريب في اليوم التالي بدلاً من التخمين.',
    listeningAssignment:
        'استمع مرة للتوقيت فقط ومرة لشكل الجملة فقط.',
    improvisationAssignment:
        'أعد نفس الكورس بـ 10-15 BPM أبطأ بعد تصحيح واحد.',
    recordCheckpoint:
        'احفظ المحاولة 1 والمحاولة 2 واكتب جملة تحسين ملموسة واحدة.',
  ),
  const _DaySeed(
    dayNumber: 28,
    weekNumber: 4,
    title: 'جملة شخصية من مازورتين',
    focus: 'إنشاء جملة شخصية من مازورتين',
    description: 'صمم جملة يمكنك تذكرها حقاً، تكرارها، وامتلاكها.',
    skillAreas: [SkillArea.improvisation, SkillArea.saxLanguage],
    concepts: ['personal phrase', 'identity', 'motivic cell'],
    moduleIds: ['ii_v_i_course', 'twelve_key_trainer'],
    exerciseType: ExerciseType.etude,
    level: DifficultyLevel.intermediate,
    tempoRange: TempoRange(minBpm: 84, maxBpm: 98),
    whatDoIHear:
        'جملة تبدو كفكرة كاملة واحدة بدلاً من شظايا مستعارة.',
    whatDoIPlay: 'فكرة من مازورتين مع بداية، ذروة، ونهاية واضحة.',
    whyDoesItWork:
        'المفردات الشخصية تنمو من جمل صغيرة تفهمها بعمق.',
    whereInRealJazz:
        'اللازمات المميزة، الموتيفات المتكررة، وبدايات الأسلوب الشخصي.',
    howDoIUseItInMySolo:
        'أعود لهذه الجملة وأعيد تشكيلها في أماكن مختلفة.',
    listeningAssignment:
        'غنِّ جملتك بعيداً عن الآلة؛ إذا لم تستطع، فهي ليست ملكك بعد.',
    improvisationAssignment:
        'اذكر جملتك ذات المازورتين، ثم أجب عليها بتنويع.',
  ),
  const _DaySeed(
    dayNumber: 29,
    weekNumber: 4,
    title: 'نقل الجملة عبر 12 مقام',
    focus: 'مدرب الأنماط في 12 مقام',
    description:
        'حرك خليتك الشخصية وخلية ii-V-I واحدة عبر المقامات العملية دون فقدان الإحساس.',
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
        'نفس الفكرة تحافظ على وظيفتها وشكلها أثناء تحرك المقام.',
    whatDoIPlay:
        'جملة شخصية من مازورتين وخلية نغمات دليل في عدة مقامات.',
    whyDoesItWork:
        'النقل يثبت ما إذا كانت الفكرة قد تعلمت أم حفظت فقط.',
    whereInRealJazz: 'الإحماء، التدريبات التقنية، والتحضير للمقطوعات الحقيقية.',
    howDoIUseItInMySolo:
        'يمكنني سحب نفس مفهوم الجملة إلى مقطوعات جديدة بشكل أسرع.',
    listeningAssignment:
        'استمع لما إذا كان إحساس السوينغ ينجو من تغيير المقام.',
    improvisationAssignment:
        'خذ جملتك إلى 4 مقامات بإيقاع متطابق.',
  ),
  const _DaySeed(
    dayNumber: 30,
    weekNumber: 4,
    title: 'مراجعة ختامية للمنهج',
    focus: 'دمج الـ 30 يوماً',
    description:
        'اختم الشهر الأول بدمج النغمة، السوينغ، البلوز، نغمات الدليل، ii-V-I، التسجيل، ومنطق الجملة الشخصية.',
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
        'عازف يفكر الآن في الصوت، النبض، الجملة، والاتجاه الهارموني معاً.',
    whatDoIPlay:
        'كورس واحد بلس إعادة للجملة الشخصية ومحاولة تصحيحية بطيئة واحدة.',
    whyDoesItWork:
        'الشهر يهم فقط إذا اتصلت الأجزاء في عزف حقيقي.',
    whereInRealJazz:
        'أي روتين تدريب جاد ينتقل نحو المقطوعات الحقيقية والسولوهات الحقيقية.',
    howDoIUseItInMySolo:
        'آخذ أقوى الأفكار من هذا الشهر وأستمر في تطويرها في مجمع الدورة القادم.',
    listeningAssignment:
        'قارن تسجيلات اليوم 7، اليوم 14، اليوم 21، واليوم 30.',
    improvisationAssignment:
        'اعزف كورس واحد يتضمن موتيراً متكرراً واحداً وهدف استقرار (Cadence) واضحاً.',
    recordCheckpoint:
        'احفظ محاولتك الختامية واكتب نقطتي الضعف التاليتين للعمل عليهما.',
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
      title: 'ماذا أسمع؟',
      description: seed.whatDoIHear,
      minutes: 4,
      listenPrompt: seed.listeningAssignment,
    ),
    LessonStep(
      type: LessonStepType.understand,
      title: 'لماذا ينجح هذا؟',
      description: seed.whyDoesItWork,
      minutes: 4,
    ),
    LessonStep(
      type: LessonStepType.sing,
      title: 'غنِّها أولاً',
      description: 'غنِّ الفكرة أو الـ pulse قبل العزف حتى ترتبط الأذن بالجسم.',
      minutes: 3,
      singPrompt: seed.whatDoIHear,
    ),
    LessonStep(
      type: LessonStepType.play,
      title: 'ماذا أعزف؟',
      description: seed.whatDoIPlay,
      minutes: 8,
      playPrompt: seed.whatDoIPlay,
    ),
    LessonStep(
      type: LessonStepType.analyze,
      title: 'أين تظهر في الجاز؟',
      description: seed.whereInRealJazz,
      minutes: 3,
    ),
    LessonStep(
      type: LessonStepType.improvise,
      title: 'كيف أستخدمها في عزفي؟',
      description: seed.howDoIUseItInMySolo,
      minutes: 6,
      playPrompt: seed.improvisationAssignment,
    ),
    LessonStep(
      type: LessonStepType.record,
      title: 'سجّل',
      description: seed.recordCheckpoint ??
          'سجّل take قصيرة لهذه الفكرة وراجعها مباشرة.',
      minutes: 4,
    ),
    const LessonStep(
      type: LessonStepType.evaluate,
      title: 'قيّم',
      description:
          'قيّم النغمة، التوقيت، النطق، ومنطق الجملة قبل إضافة نغمات جديدة.',
      minutes: 3,
      evaluatePrompt:
          'هل حققت الصوت، الوقت، والوضوح الهارموني أم ما زال أحدها أضعف؟',
    ),
    const LessonStep(
      type: LessonStepType.repeat,
      title: 'كرر',
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
