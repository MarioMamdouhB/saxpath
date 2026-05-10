import '../audio/generated_audio.dart';
import 'sax_foundation_models.dart';

class SaxFoundationRepository {
  const SaxFoundationRepository();

  SaxFoundationTrack getTrack() {
    return const SaxFoundationTrack(
      handPositionGuides: _handPositionLessons,
      notes: _notes,
      scales: _scales,
      firstFivePath: _firstFivePath,
      beginnerFlow: _beginnerFlow,
      beginnerPathLessons: _beginnerPathLessons,
    );
  }

  List<HandPositionGuide> getHandPositionLessons() =>
      List.unmodifiable(_handPositionLessons);

  List<FoundationNoteModel> getNotes() => List.unmodifiable(_notes);

  List<FoundationNoteModel> getFirstNotes() => List.unmodifiable(_notes);

  List<FoundationScaleLesson> getScales() => List.unmodifiable(_scales);

  List<BeginnerPathLesson> getBeginnerPathLessons() =>
      List.unmodifiable(_beginnerPathLessons);

  List<FoundationPracticeExercise> getHandPositionExercises() {
    return _handPositionExerciseIds.map(exerciseById).toList(growable: false);
  }

  List<FoundationPracticeExercise> getExercisesForNote(String noteId) {
    final note = noteById(noteId);
    return note.exerciseIds.map(exerciseById).toList(growable: false);
  }

  List<FoundationPracticeExercise> getExercisesForScale(String scaleId) {
    final scale = scaleById(scaleId);
    return scale.exerciseIds.map(exerciseById).toList(growable: false);
  }

  List<FoundationPracticeExercise> getExercisesByIds(List<String> exerciseIds) {
    return exerciseIds.map(exerciseById).toList(growable: false);
  }

  FoundationNoteModel noteById(String noteId) {
    return _notes.firstWhere((note) => note.id == noteId);
  }

  FoundationNoteModel? findNoteByWrittenNote(String writtenNote) {
    for (final note in _notes) {
      if (note.label.toUpperCase() == writtenNote.toUpperCase()) {
        return note;
      }
    }
    return null;
  }

  FoundationScaleLesson scaleById(String scaleId) {
    return _scales.firstWhere((scale) => scale.id == scaleId);
  }

  BeginnerPathLesson beginnerPathLessonById(String lessonId) {
    return _beginnerPathLessons.firstWhere((lesson) => lesson.id == lessonId);
  }

  FoundationPracticeExercise exerciseById(String exerciseId) {
    final exercise = _exerciseIndex[exerciseId];
    assert(exercise != null, 'Unknown foundation exercise: $exerciseId');
    return exercise!;
  }

  List<FoundationPracticeExercise> getExercisesForFlowStep(
    BeginnerPracticeStep step,
  ) {
    return step.exerciseIds.map(exerciseById).toList(growable: false);
  }
}

const _handPositionLessons = [
  HandPositionGuide(
    id: 'hand_left',
    title: 'Left Hand',
    cue: 'Balanced left hand, fingers resting close',
    detail:
        'ابدأ بيد يسرى ثابتة ومرتاحة قبل أي نغمة. الهدف هو وضع الأصابع فوق أماكنها الطبيعية بدون شد.',
    checkpoints: [
      'Thumb on the thumb rest',
      'Index finger on B key',
      'Middle finger on A key',
      'Ring finger on G key',
      'Pinky relaxed near left pinky keys',
    ],
  ),
  HandPositionGuide(
    id: 'hand_right',
    title: 'Right Hand',
    cue: 'Right hand under the hook, never gripping',
    detail:
        'دع الإبهام الأيمن تحت الـ thumb hook فقط من غير عصر، وخلي الأصابع مستعدة للنزول على F وE وD بسهولة.',
    checkpoints: [
      'Thumb under the thumb hook',
      'Index finger on F key',
      'Middle finger on E key',
      'Ring finger on D key',
      'Pinky relaxed near right pinky keys',
    ],
  ),
  HandPositionGuide(
    id: 'hand_general',
    title: 'General',
    cue: 'Relaxed body, curved fingers, minimal lift',
    detail:
        'الجسم المرتاح جزء من التقنية نفسها. التوتر الزائد يفسد الوقت والنغمة والفينجرينج في نفس اللحظة.',
    checkpoints: [
      'Fingers curved',
      'Fingers close to the keys',
      'Relaxed wrist',
      'Relaxed shoulders',
      'No unnecessary tension',
      'Do not lift fingers too far away from keys',
    ],
  ),
];

const _notes = [
  FoundationNoteModel(
    id: 'note_b',
    label: 'B',
    arabicName: 'سي',
    noteName: NoteName.b,
    concertPitchForAlto: 'D',
    concertPitchForTenor: 'A',
    register: Register.middle,
    description:
        'أول نوتة في هذا المسار. تعلّمك كيف تثبت اليد اليسرى وتبدأ بصوت واضح ومستقر.',
    tonalGoal: 'Play a stable written B with a relaxed left hand.',
    anchorScaleIds: ['scale_c_major', 'scale_g_major'],
    commonMistakes: [
      'ضغط الإبهام للخلف بدل تركه يسند الآلة بهدوء.',
      'رفع الإصبع الأوسط والبنصر بعيدًا عن المفاتيح.',
      'هواء متقطع يجعل النغمة تهتز.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'B',
      pressedKeyIds: ['p1'],
      handPositionTip: 'ثبت السبابة اليسرى على B key وخلي باقي الأصابع قريبة.',
      embouchureTip: 'ابدأ بنفخ متصل من غير عضة على الريشة.',
      airflowTip: 'استمر في الهواء 4 عدات كاملة قبل التوقف.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: false,
      leftRing: false,
    ),
    exerciseIds: [
      'b_listen_hold',
      'b_long_tone',
      'b_metronome_hold',
    ],
  ),
  FoundationNoteModel(
    id: 'note_a',
    label: 'A',
    arabicName: 'لا',
    noteName: NoteName.a,
    concertPitchForAlto: 'C',
    concertPitchForTenor: 'G',
    register: Register.middle,
    description:
        'A هي أول انتقال طبيعي بعد B. تضيف إصبعًا واحدًا وتختبر هل يبقى الصوت متوازنًا.',
    tonalGoal: 'Move from B to A without changing embouchure shape.',
    anchorScaleIds: [
      'scale_c_major',
      'scale_g_major',
      'scale_a_minor_pentatonic'
    ],
    commonMistakes: [
      'سقوط الإصبع الأوسط بقوة بدل حركة خفيفة.',
      'تغيير شكل الفم عند الانتقال من B إلى A.',
      'نغمة أقصر من B بسبب التردد في الحركة.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'A',
      pressedKeyIds: ['p1', 'p2'],
      handPositionTip: 'دع الإصبع الأوسط يهبط بهدوء بدون شد في المعصم.',
      embouchureTip: 'الفم ثابت؛ فقط الأصابع هي التي تتغير.',
      airflowTip: 'حافظ على نفس كمية الهواء من B إلى A.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: true,
      leftRing: false,
    ),
    exerciseIds: [
      'a_listen_hold',
      'a_long_tone',
      'b_a_change',
    ],
  ),
  FoundationNoteModel(
    id: 'note_g',
    label: 'G',
    arabicName: 'صول',
    noteName: NoteName.g,
    concertPitchForAlto: 'Bb',
    concertPitchForTenor: 'F',
    register: Register.middle,
    description:
        'G تكمل أصابع اليد اليسرى الثلاثة وتبني أول شكل متكامل يشعر به المبتدئ تحت اليد.',
    tonalGoal: 'Keep three left-hand fingers down while the sound stays even.',
    anchorScaleIds: [
      'scale_c_major',
      'scale_g_major',
      'scale_f_major',
      'scale_a_minor_pentatonic',
      'scale_a_blues',
    ],
    commonMistakes: [
      'ضغط البنصر بقوة أكبر من اللازم.',
      'ابتعاد الخنصر الأيسر بعيدًا عن مفاتيحه الجانبية.',
      'تغير السرعة الهوائية عند إضافة الإصبع الثالث.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'G',
      pressedKeyIds: ['p1', 'p2', 'p3'],
      handPositionTip: 'كل أصابع اليد اليسرى مقوسة وقريبة من pearls.',
      embouchureTip: 'ابدأ G بنفس هدوء B وA، من غير ضغط إضافي.',
      airflowTip: 'نفَس دافئ ومتصل، خاصة في آخر النغمة.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: true,
      leftRing: true,
    ),
    exerciseIds: [
      'g_listen_hold',
      'g_long_tone',
      'b_a_g_pattern',
    ],
  ),
  FoundationNoteModel(
    id: 'note_f',
    label: 'F',
    arabicName: 'فا',
    noteName: NoteName.f,
    concertPitchForAlto: 'Ab',
    concertPitchForTenor: 'Eb',
    register: Register.middle,
    description:
        'F تدخل أول إصبع من اليد اليمنى، وهنا يبدأ التنسيق بين اليدين بشكل واضح.',
    tonalGoal: 'Add the right index gently while both hands stay relaxed.',
    anchorScaleIds: ['scale_c_major', 'scale_f_major', 'scale_a_blues'],
    commonMistakes: [
      'تحريك كامل اليد اليمنى بدل نزول السبابة فقط.',
      'شد الكتف الأيمن عند أول استخدام لليد اليمنى.',
      'تأخر الإيقاع بسبب التفكير في اليدين معًا.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'F',
      pressedKeyIds: ['p1', 'p2', 'p3', 'p4'],
      handPositionTip: 'ثبّت الإبهام الأيمن تحت hook وخلي السبابة تنزل وحدها.',
      embouchureTip: 'لا تغيّر الفم عندما تدخل اليد اليمنى.',
      airflowTip: 'استمر في الهواء نفسه كي لا تصبح F أضعف من G.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: true,
      leftRing: true,
      rightIndex: true,
    ),
    exerciseIds: [
      'f_listen_hold',
      'f_long_tone',
      'g_f_change',
    ],
  ),
  FoundationNoteModel(
    id: 'note_e',
    label: 'E',
    arabicName: 'مي',
    noteName: NoteName.e,
    concertPitchForAlto: 'G',
    concertPitchForTenor: 'D',
    register: Register.middle,
    description:
        'E تضيف الإصبع الأوسط الأيمن وتساعدك على تثبيت شكل اليد اليمنى الكامل تقريبًا.',
    tonalGoal:
        'Place right index and middle together without squeezing the hand.',
    anchorScaleIds: [
      'scale_c_major',
      'scale_a_minor_pentatonic',
      'scale_a_blues'
    ],
    commonMistakes: [
      'التفاف المعصم الأيمن للداخل.',
      'رفع الإصبع السبابة الأيمن بالخطأ عند إضافة الأوسط.',
      'فقدان التساوي بين F وE.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'E',
      pressedKeyIds: ['p1', 'p2', 'p3', 'p4', 'p5'],
      handPositionTip: 'الإصبعان الأيمنان الأول والثاني يتحركان من المفصل فقط.',
      embouchureTip: 'استمر بنفس وضع الفم من F إلى E.',
      airflowTip: 'فكر في خط هواء ثابت بدل محاولة دفع النغمة.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: true,
      leftRing: true,
      rightIndex: true,
      rightMiddle: true,
    ),
    exerciseIds: [
      'e_listen_hold',
      'e_long_tone',
      'f_e_change',
    ],
  ),
  FoundationNoteModel(
    id: 'note_d',
    label: 'D',
    arabicName: 'ري',
    noteName: NoteName.d,
    concertPitchForAlto: 'F',
    concertPitchForTenor: 'C',
    register: Register.middle,
    description:
        'D تكمل أصابع اليد اليمنى الرئيسية الثلاثة، وهي مفتاح مهم لبناء أول سلالم كاملة.',
    tonalGoal: 'Use both hands together with no extra lift or wrist tension.',
    anchorScaleIds: [
      'scale_c_major',
      'scale_g_major',
      'scale_f_major',
      'scale_a_minor_pentatonic',
      'scale_a_blues'
    ],
    commonMistakes: [
      'رفع الإصبعين الأول والثاني معًا عند إضافة البنصر.',
      'تشنج في الرسغ الأيمن.',
      'تسارع النغمة عند أول مرة تعزف فيها D.',
    ],
    fingering: NoteFingeringModel(
      noteLabel: 'D',
      pressedKeyIds: ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'],
      handPositionTip: 'كل أصابع اليد اليمنى الثلاثة تهبط برفق وعلى نفس القوس.',
      embouchureTip: 'ابقَ هادئًا؛ التغيير هنا في الأصابع فقط.',
      airflowTip: 'حافظ على نفس الدعم من E إلى D.',
      octaveKey: false,
      leftIndex: true,
      leftMiddle: true,
      leftRing: true,
      rightIndex: true,
      rightMiddle: true,
      rightRing: true,
    ),
    exerciseIds: [
      'd_listen_hold',
      'd_long_tone',
      'e_d_change',
    ],
  ),
  FoundationNoteModel(
    id: 'note_c',
    label: 'C',
    arabicName: 'دو',
    noteName: NoteName.c,
    concertPitchForAlto: 'Eb',
    concertPitchForTenor: 'Bb',
    register: Register.upper,
    description:
        'C هنا تُقدَّم كفنجرة مبتدئة بسيطة للنوتة المكتوبة الوسطى C حتى يستطيع المتعلم إكمال أول سلم C major.',
    tonalGoal: 'Add the octave key cleanly and keep the sound stable.',
    anchorScaleIds: ['scale_c_major', 'scale_f_major'],
    commonMistakes: [
      'نسيان octave key عند الانتقال من D إلى C.',
      'زيادة الضغط على الفم لتعويض التغيير.',
      'رفع اليدين بعيدًا عن أماكنهما في محاولة الوصول للنغمة.',
    ],
      fingering: NoteFingeringModel(
        noteLabel: 'C',
        pressedKeyIds: ['octave'],
        handPositionTip:
            'فعّل مفتاح الأوكتاف وحده، مع بقاء بقية الأصابع مرتاحة وقريبة من أماكنها.',
        embouchureTip: 'الفم ثابت، ولا تحتاج لعنف أو ضغط كي تخرج النغمة.',
        airflowTip: 'هواء مستمر وواضح مع بداية ناعمة.',
      octaveKey: true,
      leftIndex: false,
      leftMiddle: false,
      leftRing: false,
      rightIndex: false,
      rightMiddle: false,
      rightRing: false,
    ),
    exerciseIds: [
      'c_listen_hold',
      'c_long_tone',
      'd_c_change',
    ],
  ),
];

const _scales = [
  FoundationScaleLesson(
    id: 'scale_c_major',
    title: 'C Major Scale',
    subtitle: 'C D E F G A B',
    noteSequence: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
    tonalCenter: 'C',
    purpose:
        'يبني أول سلم كامل من نغمات البداية، ويجعلك تشعر كيف تتحول النغمات المفردة إلى خط موسيقي مستمر.',
    transferGoal:
        'بعده تستطيع تكوين phrases قصيرة بدل عزف نغمة واحدة في كل مرة.',
    relatedNoteIds: [
      'note_c',
      'note_d',
      'note_e',
      'note_f',
      'note_g',
      'note_a',
      'note_b'
    ],
    exerciseIds: [
      'scale_c_slow',
      'scale_c_descend',
      'scale_c_phrase',
    ],
    formula: '1 - 2 - 3 - 4 - 5 - 6 - 7',
    slowPractice: 'اعزف كل نغمة 2 عدات مع راحة قصيرة للتأكد من وضعية الأصابع.',
    metronomePractice:
        'ابدأ عند 60 BPM ثم ارفع إلى 72 BPM فقط بعد استقرار الوقت.',
    ascendingPractice: 'اصعد من C إلى B بنغمة متساوية الطول والهواء.',
    descendingPractice:
        'انزل من B إلى C بنفس هدوء الصعود من غير إسقاط الأصابع.',
    rhythmVariation: 'اعزف: تا تا | تا-تا-تا | تاا تا ضمن نفس السلم.',
    simplePhraseApplication: 'ابنِ جملة من نغمتين ثم ثلاث نغمات من نفس السلم.',
    backingTrackPlaceholder:
        'لا يوجد backing track ثابت لهذا السلم بعد، لذا استخدم المترونوم أو أعد تشغيل المعاينة قبل العزف.',
    phrasePrompts: [
      ScalePhrasePrompt(
        title: '2-note phrase',
        prompt: 'جرّب C-D ثم D-C على pulse ثابت.',
      ),
      ScalePhrasePrompt(
        title: '3-note phrase',
        prompt: 'جرّب C-D-E ثم E-D-C.',
      ),
      ScalePhrasePrompt(
        title: 'Play with rhythm',
        prompt: 'غيّر الإيقاع بين طويل-قصير-قصير داخل نفس الثلاث نغمات.',
      ),
      ScalePhrasePrompt(
        title: 'Call and response',
        prompt: 'اعزف C-D ثم جاوب بـ E-D.',
      ),
      ScalePhrasePrompt(
        title: 'Simple blues phrase',
        prompt: 'استخدم G-E-D كخاتمة بسيطة بنكهة مبكرة.',
      ),
    ],
  ),
  FoundationScaleLesson(
    id: 'scale_g_major',
    title: 'G Major Scale',
    subtitle: 'G A B C D E F#',
    noteSequence: ['G', 'A', 'B', 'C', 'D', 'E', 'F#'],
    tonalCenter: 'G',
    purpose:
        'يأخذك من أول ثلاث نغمات أساسية إلى حركة سلميّة أطول مع لون جديد في آخر النغمات.',
    transferGoal: 'يعلمك أن السلم ليس نظرية فقط، بل مسار جاهز لصنع جملة قصيرة.',
    relatedNoteIds: [
      'note_g',
      'note_a',
      'note_b',
      'note_c',
      'note_d',
      'note_e'
    ],
    exerciseIds: [
      'scale_g_slow',
      'scale_g_descend',
      'scale_g_phrase',
    ],
    formula: '1 - 2 - 3 - 4 - 5 - 6 - 7',
    slowPractice:
        'اثبت على G-A-B أولاً، ثم أكمل السلم حتى F# مع مراجعة النظافة الحركية.',
    metronomePractice: 'تمرن على 58 BPM ثم 68 BPM مع عد داخلي واضح.',
    ascendingPractice: 'اصعد G إلى F# بتركيز على تساوي كل نغمة.',
    descendingPractice: 'انزل F# إلى G بنغمة أخيرة مستقرة لا تهبط في الصوت.',
    rhythmVariation: 'نفذ السلم بإيقاع: طويل-قصير | قصير-قصير | طويل.',
    simplePhraseApplication: 'ابنِ phrase من G-A ثم G-B-A.',
    backingTrackPlaceholder:
        'لا يوجد backing track ثابت لهذا السلم بعد، لذا استخدم المترونوم أو أعد تشغيل المعاينة قبل العزف.',
    phrasePrompts: [
      ScalePhrasePrompt(
        title: '2-note phrase',
        prompt: 'G-A ثم A-G على pulse هادئ.',
      ),
      ScalePhrasePrompt(
        title: '3-note phrase',
        prompt: 'G-B-A ثم A-G.',
      ),
      ScalePhrasePrompt(
        title: 'Play with rhythm',
        prompt: 'أعد G-A-B بإيقاع قصير-قصير-طويل.',
      ),
      ScalePhrasePrompt(
        title: 'Call and response',
        prompt: 'السؤال: G-A-B. الجواب: B-A-G.',
      ),
      ScalePhrasePrompt(
        title: 'Simple blues phrase',
        prompt: 'استخدم D-B-G كخاتمة قصيرة أصلية.',
      ),
    ],
  ),
  FoundationScaleLesson(
    id: 'scale_f_major',
    title: 'F Major Scale',
    subtitle: 'F G A Bb C D E',
    noteSequence: ['F', 'G', 'A', 'Bb', 'C', 'D', 'E'],
    tonalCenter: 'F',
    purpose:
        'يقدم لون Bb داخل سياق موسيقي بسيط، حتى يرى المتعلم كيف يبدأ السلم في التوسع خارج أول سبع نغمات.',
    transferGoal: 'ينقلك من حفظ الفنجرة إلى سماع الشخصية المختلفة لكل سلم.',
    relatedNoteIds: [
      'note_f',
      'note_g',
      'note_a',
      'note_c',
      'note_d',
      'note_e'
    ],
    exerciseIds: [
      'scale_f_slow',
      'scale_f_descend',
      'scale_f_phrase',
    ],
    formula: '1 - 2 - 3 - 4 - 5 - 6 - 7',
    slowPractice:
        'تدرّب على F-G-A أولاً، ثم خذ Bb وحدها ببطء قبل أن تعود إلى السلم كاملًا إذا كانت جديدة عليك.',
    metronomePractice: 'ابدأ 56 BPM مع عد واضح في كل نغمة.',
    ascendingPractice: 'اصعد حتى E من غير توتر في دخول وخروج اليد اليمنى.',
    descendingPractice:
        'انزل ببطء وحافظ على تساوي الزمن خاصة في آخر أربع نغمات.',
    rhythmVariation: 'اعزف ثلاثيات بسيطة من نفس نغمات السلم.',
    simplePhraseApplication: 'كوّن جملة F-A-G أو A-G-F ثم بدّل الإيقاع.',
    backingTrackPlaceholder:
        'لا يوجد backing track ثابت لهذا السلم بعد، لذا استخدم المترونوم أو أعد تشغيل المعاينة قبل العزف.',
    phrasePrompts: [
      ScalePhrasePrompt(
        title: '2-note phrase',
        prompt: 'F-G ثم A-G.',
      ),
      ScalePhrasePrompt(
        title: '3-note phrase',
        prompt: 'F-A-G ثم G-F.',
      ),
      ScalePhrasePrompt(
        title: 'Play with rhythm',
        prompt: 'استخدم F-G-A بإيقاع سنكوب أصلي بسيط.',
      ),
      ScalePhrasePrompt(
        title: 'Call and response',
        prompt: 'السؤال: F-G-A. الجواب: C-A-F.',
      ),
      ScalePhrasePrompt(
        title: 'Simple blues phrase',
        prompt: 'جرّب A-G-F مع وقفة قصيرة ثم أعدها.',
      ),
    ],
  ),
  FoundationScaleLesson(
    id: 'scale_a_minor_pentatonic',
    title: 'A Minor Pentatonic',
    subtitle: 'A C D E G',
    noteSequence: ['A', 'C', 'D', 'E', 'G'],
    tonalCenter: 'A',
    purpose:
        'هذا أول سلم يفتح الباب للعبارات الموسيقية الحرة بشكل بسيط جدًا وواضح.',
    transferGoal:
        'ستستطيع من خلاله عمل phrases قصيرة تبدو موسيقية بسرعة حتى كمبتدئ.',
    relatedNoteIds: ['note_a', 'note_c', 'note_d', 'note_e', 'note_g'],
    exerciseIds: [
      'scale_a_pent_slow',
      'scale_a_pent_descend',
      'scale_a_pent_phrase',
    ],
    formula: '1 - b3 - 4 - 5 - b7',
    slowPractice:
        'اعزف كل نغمة ببطء وتأكد أن المسافات المختلفة تبدو واضحة للأذن.',
    metronomePractice:
        'استخدم 60 BPM واعزف نغمتين في كل نبضة بعد أن يثبت الشكل.',
    ascendingPractice: 'اصعد A-C-D-E-G بنغمة واضحة ومنفصلة.',
    descendingPractice: 'انزل G-E-D-C-A بهدوء ونفس الوقت.',
    rhythmVariation: 'اعزف A-C | D-E-G بإيقاعات مختلفة من نفس المواد.',
    simplePhraseApplication: 'ابدأ بجملة من A-C ثم طوّرها إلى A-C-D أو G-E-D.',
    backingTrackPlaceholder:
        'لا يوجد backing track ثابت لهذا السلم بعد، لذا استخدم المترونوم أو أعد تشغيل المعاينة قبل العزف.',
    phrasePrompts: [
      ScalePhrasePrompt(
        title: '2-note phrase',
        prompt: 'A-C ثم C-A.',
      ),
      ScalePhrasePrompt(
        title: '3-note phrase',
        prompt: 'A-C-D ثم D-C-A.',
      ),
      ScalePhrasePrompt(
        title: 'Play with rhythm',
        prompt: 'بدّل بين A-C-D بإيقاع straight ثم syncopated.',
      ),
      ScalePhrasePrompt(
        title: 'Call and response',
        prompt: 'السؤال: A-C-D. الجواب: G-E-D.',
      ),
      ScalePhrasePrompt(
        title: 'Simple blues phrase',
        prompt: 'A-C-D ثم E-D-C كفكرة بلوز أصلية قصيرة.',
      ),
    ],
  ),
  FoundationScaleLesson(
    id: 'scale_a_blues',
    title: 'A Blues Scale',
    subtitle: 'A C D Eb E G',
    noteSequence: ['A', 'C', 'D', 'Eb', 'E', 'G'],
    tonalCenter: 'A',
    purpose:
        'يعطيك لون blues مبكر بشكل مبسط، ويُظهر كيف يمكن لنفس النوتات أن تصبح عبارة ذات شخصية.',
    transferGoal:
        'بعده تبدأ في بناء response قصير بنكهة بلوز من غير الدخول في تعقيد نظري.',
    relatedNoteIds: ['note_a', 'note_c', 'note_d', 'note_e', 'note_g'],
    exerciseIds: [
      'scale_a_blues_slow',
      'scale_a_blues_descend',
      'scale_a_blues_phrase',
    ],
    formula: '1 - b3 - 4 - b5 - 5 - b7',
    slowPractice:
        'اعزف السلم ببطء، وإذا كانت Eb جديدة عليك فكرر حركة D-Eb-E وحدها قبل العودة إلى السلم كاملًا.',
    metronomePractice:
        'ابدأ عند 58 BPM مع نبضات واضحة ومسافات دقيقة بين النغمات.',
    ascendingPractice: 'اصعد من A إلى G بنغمة مستقرة وبدون استعجال.',
    descendingPractice: 'انزل مع تركيز خاص على D-Eb-E كحركة لونية.',
    rhythmVariation: 'جرّب تقسيم A-C-D | Eb-E-G بإيقاعات قصيرة وطويلة.',
    simplePhraseApplication: 'استخدم D-Eb-E ثم G-E-D لعمل phrase blues بسيط.',
    backingTrackPlaceholder:
        'لا يوجد backing track ثابت لهذا السلم بعد، لذا استخدم المترونوم أو أعد تشغيل المعاينة قبل العزف.',
    phrasePrompts: [
      ScalePhrasePrompt(
        title: '2-note phrase',
        prompt: 'A-C ثم E-D.',
      ),
      ScalePhrasePrompt(
        title: '3-note phrase',
        prompt: 'D-Eb-E ثم G-E-D.',
      ),
      ScalePhrasePrompt(
        title: 'Play with rhythm',
        prompt: 'كرر D-Eb-E بإيقاع قصير-قصير-طويل.',
      ),
      ScalePhrasePrompt(
        title: 'Call and response',
        prompt: 'السؤال: A-C-D. الجواب: G-E-D.',
      ),
      ScalePhrasePrompt(
        title: 'Simple blues phrase',
        prompt: 'استخدم A-C-D ثم D-Eb-E كجملة بلوز أصلية للمبتدئ.',
      ),
    ],
  ),
];

const _firstFivePath = [
  FirstFivePathStage(
    noteId: 'note_b',
    title: '1. B',
    focus: 'ثبّت اليد اليسرى وابدأ أول long tone واضح.',
    nextMove: 'أضف الإصبع الأوسط لليد اليسرى للوصول إلى A.',
  ),
  FirstFivePathStage(
    noteId: 'note_a',
    title: '2. A',
    focus: 'اربط B بـ A من غير تغيير في شكل الفم.',
    nextMove: 'أضف البنصر الأيسر لتشعر بشكل G الكامل.',
  ),
  FirstFivePathStage(
    noteId: 'note_g',
    title: '3. G',
    focus: 'أكمل مجموعة اليد اليسرى الثلاثية بثبات.',
    nextMove: 'استخدم B-A-G كأول pattern لحني بسيط.',
  ),
  FirstFivePathStage(
    noteId: 'note_f',
    title: '4. F',
    focus: 'أدخل اليد اليمنى لأول مرة بهدوء وثبات.',
    nextMove: 'أضف الإصبع الأوسط الأيمن لتصل إلى E.',
  ),
  FirstFivePathStage(
    noteId: 'note_e',
    title: '5. E',
    focus: 'ثبّت اليد اليمنى على مفتاحين متجاورين.',
    nextMove: 'استخدم B-A-G-F-E كأول five-note melody.',
  ),
];

const _beginnerFlow = [
  BeginnerPracticeStep(
    id: 'flow_setup',
    title: '1. Hand position check',
    subtitle: 'راجع وضع الإبهامين، تقوس الأصابع، واسترخاء الكتفين.',
    recommendedMinutes: 2,
    exerciseIds: ['silent_finger_placement', 'finger_tap_exercise'],
  ),
  BeginnerPracticeStep(
    id: 'flow_note_b',
    title: '2. Learn note B',
    subtitle: 'استمع إلى B ثم اثبتها كـ long tone واضح.',
    recommendedMinutes: 5,
    exerciseIds: ['b_listen_hold', 'b_long_tone'],
  ),
  BeginnerPracticeStep(
    id: 'flow_note_a',
    title: '3. Learn note A',
    subtitle: 'أضف الإصبع الأوسط وراقب هل يبقى الصوت ثابتًا.',
    recommendedMinutes: 5,
    exerciseIds: ['a_listen_hold', 'b_a_change'],
  ),
  BeginnerPracticeStep(
    id: 'flow_rhythm',
    title: '4. Play B-A rhythm',
    subtitle: 'حوّل أول نغمتين إلى pattern إيقاعي بسيط.',
    recommendedMinutes: 5,
    exerciseIds: ['b_a_change', 'slow_note_change_drill'],
  ),
];

const _beginnerPathLessons = [
  BeginnerPathLesson(
    id: 'day_1_b',
    title: 'Lesson: First Note B',
    subtitle: 'Day 1',
    recommendedMinutes: 8,
    exerciseIds: ['silent_finger_placement', 'b_listen_hold', 'b_long_tone'],
    dayNumber: 1,
    goal: 'Learn how to place the left hand and play a stable written B.',
    explanation:
        'اليوم الأول يركز على وضع اليد اليسرى وبدء أول نغمة واضحة بدون استعجال.',
    noteIds: ['note_b'],
    listenStep: 'استمع إلى B مرة أو مرتين قبل أن تعزفها.',
    playStep: 'اعزف B لمدة 4 beats وكرر ذلك 4 مرات.',
    practiceExerciseId: 'b_metronome_hold',
    rhythmVariation: 'جرّب B كأربع نبضات ثم نبضتين + نبضتين.',
    completionKey: 'beginner_path_day_1',
  ),
  BeginnerPathLesson(
    id: 'day_2_a',
    title: 'Lesson: Add A',
    subtitle: 'Day 2',
    recommendedMinutes: 8,
    exerciseIds: ['a_listen_hold', 'a_long_tone', 'b_a_change'],
    dayNumber: 2,
    goal: 'Add left middle finger and move from B to A smoothly.',
    explanation:
        'هنا تبدأ أول حركة انتقالية حقيقية: B إلى A من غير تغيير في شكل الفم أو توتر اليد.',
    noteIds: ['note_b', 'note_a'],
    listenStep: 'استمع إلى B-A ثم كررها بالترتيب نفسه.',
    playStep: 'اعزف B ثم A ببطء على 4 beats لكل نغمة.',
    practiceExerciseId: 'b_a_change',
    rhythmVariation: 'استخدم B-A | B-A بإيقاع قصير-قصير-طويل.',
    completionKey: 'beginner_path_day_2',
  ),
  BeginnerPathLesson(
    id: 'day_3_g',
    title: 'Lesson: Add G',
    subtitle: 'Day 3',
    recommendedMinutes: 8,
    exerciseIds: ['g_listen_hold', 'g_long_tone', 'b_a_g_pattern'],
    dayNumber: 3,
    goal: 'Complete the left-hand shape and stabilize written G.',
    explanation: 'G تعطيك أول شكل كامل لليد اليسرى، ومنها تبدأ الجمل الصغيرة.',
    noteIds: ['note_g', 'note_a', 'note_b'],
    listenStep: 'اسمع G ثم اسمع B-A-G كعبارة قصيرة.',
    playStep: 'اعزف G 4 beats ثم بدّل بينها وبين A وB ببطء.',
    practiceExerciseId: 'b_a_g_pattern',
    rhythmVariation: 'جرّب B-A-G بإيقاع متساوٍ ثم بإيقاع طويل-قصير-قصير.',
    completionKey: 'beginner_path_day_3',
  ),
  BeginnerPathLesson(
    id: 'day_4_bag',
    title: 'Lesson: B-A-G',
    subtitle: 'Day 4',
    recommendedMinutes: 9,
    exerciseIds: ['b_a_g_pattern', 'slow_note_change_drill'],
    dayNumber: 4,
    goal: 'Turn B-A-G into your first musical pattern.',
    explanation:
        'اليوم الرابع ينقل النغمات الثلاث من التثبيت الفردي إلى pattern لحني وإيقاعي.',
    noteIds: ['note_b', 'note_a', 'note_g'],
    listenStep: 'استمع لعبارة B-A-G ثم أعدها بنفس الوقت.',
    playStep: 'اعزف B-A-G صعودًا وهبوطًا على metronome بطيء.',
    practiceExerciseId: 'slow_note_change_drill',
    rhythmVariation: 'B-A-G | B---A-G كتقسيم أول بسيط.',
    completionKey: 'beginner_path_day_4',
  ),
  BeginnerPathLesson(
    id: 'day_5_f',
    title: 'Lesson: Add F',
    subtitle: 'Day 5',
    recommendedMinutes: 8,
    exerciseIds: ['f_listen_hold', 'f_long_tone', 'g_f_change'],
    dayNumber: 5,
    goal: 'Bring in the right hand with a clean written F.',
    explanation: 'التركيز هنا على دخول اليد اليمنى من غير توتر أو حركة كبيرة.',
    noteIds: ['note_f', 'note_g'],
    listenStep: 'استمع إلى F ثم لاحظ الفرق بينها وبين G.',
    playStep: 'اعزف F 4 beats وكرر 4 مرات ثم بدّل بينها وبين G.',
    practiceExerciseId: 'g_f_change',
    rhythmVariation: 'F-G | G-F بإيقاع نبضتين لكل نغمة.',
    completionKey: 'beginner_path_day_5',
  ),
  BeginnerPathLesson(
    id: 'day_6_e',
    title: 'Lesson: Add E',
    subtitle: 'Day 6',
    recommendedMinutes: 8,
    exerciseIds: ['e_listen_hold', 'e_long_tone', 'f_e_change'],
    dayNumber: 6,
    goal: 'Add right middle finger and connect F to E with control.',
    explanation:
        'اليوم السادس يثبّت شكل اليد اليمنى ويعطيك خطًا أوسع للجمل الأولى.',
    noteIds: ['note_e', 'note_f'],
    listenStep: 'استمع إلى F-E ثم كررها ببطء شديد.',
    playStep: 'اعزف E 4 beats ثم بدّل F-E على metronome.',
    practiceExerciseId: 'f_e_change',
    rhythmVariation: 'F-E-F-E كإيقاع نبضة واحدة لكل نغمة.',
    completionKey: 'beginner_path_day_6',
  ),
  BeginnerPathLesson(
    id: 'day_7_melody',
    title: 'Lesson: First 5-Note Melody',
    subtitle: 'Day 7',
    recommendedMinutes: 10,
    exerciseIds: ['first_five_melody', 'first_five_call_response'],
    dayNumber: 7,
    goal: 'Play your first simple five-note melody from the notes you know.',
    explanation:
        'هذا اليوم يربط B-A-G-F-E داخل لحن أصلي قصير وتمرين call and response بسيط.',
    noteIds: ['note_b', 'note_a', 'note_g', 'note_f', 'note_e'],
    listenStep: 'استمع إلى اللحن القصير كاملاً قبل محاولة تقليده.',
    playStep: 'اعزف اللحن ببطء ثم كرره مع metronome.',
    practiceExerciseId: 'first_five_melody',
    rhythmVariation: 'بدّل بين النسخة المتساوية والنسخة الطويلة-القصيرة.',
    completionKey: 'beginner_path_day_7',
  ),
];

const _handPositionExerciseIds = [
  'silent_finger_placement',
  'finger_tap_exercise',
  'left_hand_only_movement',
  'right_hand_only_movement',
  'slow_note_change_drill',
];

const _exerciseIndex = <String, FoundationPracticeExercise>{
  'silent_finger_placement': FoundationPracticeExercise(
    id: 'silent_finger_placement',
    title: 'Silent finger placement check',
    summary:
        'ضع الأصابع في أماكنها الصحيحة من غير عزف، فقط راقب الاسترخاء والقرب من المفاتيح.',
    instructions:
        'تحقق من thumb rest وthumb hook، ثم ضع كل إصبع في مكانه من غير ضغط زائد. كرر 3 مرات ببطء.',
    category: FoundationExerciseCategory.warmup,
    playbackPattern: PlaybackPattern.rhythm,
    playbackKey: 'count_4_4',
    recommendedBpm: 50,
    durationMinutes: 2,
    checkpoints: [
      'الأصابع مقوسة',
      'الأكتاف مرتاحة',
      'لا يوجد شد في الرسغ',
    ],
  ),
  'finger_tap_exercise': FoundationPracticeExercise(
    id: 'finger_tap_exercise',
    title: 'Finger tap exercise',
    summary: 'ارفع كل إصبع قليلًا ثم أعده فوق المفتاح نفسه بدون مبالغة.',
    instructions:
        'نفذ taps صامتة باليد اليسرى ثم اليمنى. الهدف قرب الإصبع من المفتاح، لا السرعة.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.rhythm,
    playbackKey: 'quarter_note',
    recommendedBpm: 60,
    durationMinutes: 3,
    checkpoints: [
      'لا ترفع الإصبع عاليًا',
      'كل tap يعود للمفتاح نفسه',
      'المعصم لا يتحرك مع كل إصبع',
    ],
  ),
  'left_hand_only_movement': FoundationPracticeExercise(
    id: 'left_hand_only_movement',
    title: 'Left hand only movement',
    summary: 'مرّن B ثم A ثم G بحركة اليد اليسرى فقط.',
    instructions:
        'بدّل بين B وA وG ببطء، وركز أن تبقى اليد اليمنى ساكنة بالكامل.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G A B',
    recommendedBpm: 62,
    durationMinutes: 4,
    relatedNoteIds: ['note_b', 'note_a', 'note_g'],
    checkpoints: [
      'اليد اليمنى لا تتحرك',
      'الأصابع اليسرى تبقى قريبة من المفاتيح',
    ],
  ),
  'right_hand_only_movement': FoundationPracticeExercise(
    id: 'right_hand_only_movement',
    title: 'Right hand only movement',
    summary: 'مرّن F ثم E ثم D مع ثبات اليد اليسرى.',
    instructions:
        'ابدأ من G shape ثابت، ثم أدخل اليد اليمنى تدريجيًا حتى D على pulse بطيء.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G F E D E F',
    recommendedBpm: 60,
    durationMinutes: 4,
    relatedNoteIds: ['note_g', 'note_f', 'note_e', 'note_d'],
    checkpoints: [
      'اليسرى ثابتة',
      'اليمنى تتحرك من المفاصل فقط',
    ],
  ),
  'slow_note_change_drill': FoundationPracticeExercise(
    id: 'slow_note_change_drill',
    title: 'Slow note-change drill',
    summary: 'بدّل بين النغمات المعروفة على tempo بطيء وثابت.',
    instructions:
        'اختر نغمتين أو ثلاثًا من B-A-G أو G-F-E واعزفها ببطء شديد مع metronome.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G F E',
    recommendedBpm: 58,
    durationMinutes: 5,
    checkpoints: [
      'كل انتقال في وقته',
      'لا يوجد رفع مفرط للأصابع',
      'الصوت يبقى متساويًا',
    ],
  ),
  'b_listen_hold': FoundationPracticeExercise(
    id: 'b_listen_hold',
    title: 'Listen to B',
    summary: 'اسمع B أولاً ثم طابقها.',
    instructions:
        'استمع إلى B، ثم خذ نفسًا هادئًا وكرر النغمة بنفس الطول تقريبًا.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'B',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_b'],
    checkpoints: [
      'النغمة تبدأ بوضوح',
      'الهواء لا ينقطع في المنتصف',
    ],
  ),
  'b_long_tone': FoundationPracticeExercise(
    id: 'b_long_tone',
    title: 'B Long Tone',
    summary: 'اعزف B لمدة 4 beats بثبات.',
    instructions: 'اعزف B أربع عدات، استرح قليلاً، وكرر ذلك أربع مرات.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'B',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_b'],
    checkpoints: [
      'ثبات اليد اليسرى',
      'عدم رفع باقي الأصابع بعيدًا',
    ],
  ),
  'b_metronome_hold': FoundationPracticeExercise(
    id: 'b_metronome_hold',
    title: 'B with metronome',
    summary: 'ثبّت B مع metronome هادئ.',
    instructions: 'نفذ B لمدة 4 beats على metronome، ثم beat واحد صمت، ثم أعد.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.rhythm,
    playbackKey: 'quarter_note',
    recommendedBpm: 52,
    durationMinutes: 3,
    relatedNoteIds: ['note_b'],
    checkpoints: [
      'الدخول مع أول beat',
      'الخروج مع نهاية العد الرابع',
    ],
  ),
  'a_listen_hold': FoundationPracticeExercise(
    id: 'a_listen_hold',
    title: 'Listen to A',
    summary: 'استمع إلى A ثم طابقها بهدوء.',
    instructions: 'اسمع A ثم عزفها مباشرة مع مراقبة وضع الإصبع الأوسط.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'A',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_a'],
    checkpoints: [
      'الإصبع الأوسط يهبط بهدوء',
      'الصوت لا يتغير عن B في الجودة',
    ],
  ),
  'a_long_tone': FoundationPracticeExercise(
    id: 'a_long_tone',
    title: 'A Long Tone',
    summary: 'ثبّت A لمدة 4 beats.',
    instructions: 'اعزف A أربع عدات وكرر أربع مرات مع نفس الدعم الهوائي.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'A',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_a'],
    checkpoints: [
      'الرسغ مرتاح',
      'النغمة لا تصبح حادة',
    ],
  ),
  'b_a_change': FoundationPracticeExercise(
    id: 'b_a_change',
    title: 'B-A Change Notes',
    summary: 'بدّل بين B وA على pulse ثابت.',
    instructions:
        'نفّذ B ثم A ثم B ثم A. الهدف أن يبقى الهواء مستمرًا والوقت ثابتًا.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A B A',
    recommendedBpm: 64,
    durationMinutes: 4,
    relatedNoteIds: ['note_b', 'note_a'],
    checkpoints: [
      'الانتقال نظيف',
      'لا يوجد تأخير عند نزول الإصبع الأوسط',
    ],
  ),
  'g_listen_hold': FoundationPracticeExercise(
    id: 'g_listen_hold',
    title: 'Listen to G',
    summary: 'اسمع G ثم طابقها مع وضع اليد اليسرى الكامل.',
    instructions:
        'استمع إلى G ثم عزفها مباشرة مع الحفاظ على قرب الأصابع الثلاثة من المفاتيح.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'G',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_g'],
    checkpoints: [
      'الأصابع الثلاثة في أماكنها',
      'الصوت متساوٍ من البداية للنهاية',
    ],
  ),
  'g_long_tone': FoundationPracticeExercise(
    id: 'g_long_tone',
    title: 'G Long Tone',
    summary: 'ثبّت G كأول شكل مكتمل لليد اليسرى.',
    instructions: 'اعزف G لمدة 4 beats وكررها مع نفس اللون الصوتي.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'G',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_g'],
    checkpoints: [
      'البنصر لا يضغط بقوة',
      'الخنصر الأيسر يبقى قريبًا',
    ],
  ),
  'b_a_g_pattern': FoundationPracticeExercise(
    id: 'b_a_g_pattern',
    title: 'B-A-G Pattern',
    summary: 'أول pattern لحني من ثلاث نغمات.',
    instructions: 'اعزف B-A-G ثم G-A-B. بعد ذلك جرّب نفس النغمات بإيقاع مختلف.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G A B',
    recommendedBpm: 68,
    durationMinutes: 4,
    relatedNoteIds: ['note_b', 'note_a', 'note_g'],
    checkpoints: [
      'كل نغمة تسمع بوضوح',
      'الإيقاع لا يتسارع',
    ],
  ),
  'f_listen_hold': FoundationPracticeExercise(
    id: 'f_listen_hold',
    title: 'Listen to F',
    summary: 'استمع إلى F ولاحظ دخول اليد اليمنى للمرة الأولى.',
    instructions:
        'اسمع F ثم عزفها، مع الانتباه أن اليد اليمنى تنضم بهدوء ومن غير شد.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'F',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_f'],
    checkpoints: [
      'اليد اليمنى ثابتة',
      'الكتف الأيمن مرتاح',
    ],
  ),
  'f_long_tone': FoundationPracticeExercise(
    id: 'f_long_tone',
    title: 'F Long Tone',
    summary: 'اعزف F بثبات 4 beats.',
    instructions:
        'ثبت F أربع عدات وكررها مع بقاء السبابة اليمنى خفيفة فوق المفتاح.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'F',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_f'],
    checkpoints: [
      'لا يتحرك المعصم',
      'الصوت لا يهبط في آخر النغمة',
    ],
  ),
  'g_f_change': FoundationPracticeExercise(
    id: 'g_f_change',
    title: 'G-F Change Notes',
    summary: 'بدّل بين G وF مع تنسيق اليدين.',
    instructions:
        'اعزف G ثم F ثم G ثم F على tempo هادئ. ركز على دخول السبابة اليمنى فقط.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G F G F',
    recommendedBpm: 64,
    durationMinutes: 4,
    relatedNoteIds: ['note_g', 'note_f'],
    checkpoints: [
      'الانتقال في الوقت',
      'اليد اليمنى لا تنقبض',
    ],
  ),
  'e_listen_hold': FoundationPracticeExercise(
    id: 'e_listen_hold',
    title: 'Listen to E',
    summary: 'استمع إلى E ثم طابقها مع إصبعين من اليد اليمنى.',
    instructions:
        'اسمع E ثم كررها مع ثبات اليد اليسرى والانتقال الهادئ في اليمنى.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'E',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_e'],
    checkpoints: [
      'السبابة والوسطى اليمنى تتحركان معًا بهدوء',
      'النغمة واضحة',
    ],
  ),
  'e_long_tone': FoundationPracticeExercise(
    id: 'e_long_tone',
    title: 'E Long Tone',
    summary: 'ثبت E لمدة 4 beats مع يدين مرتاحتين.',
    instructions: 'اعزف E أربع عدات، ثم كررها مع نفس الوقت والهواء.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'E',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_e'],
    checkpoints: [
      'المعصم لا يلتف',
      'الصوت متساوٍ',
    ],
  ),
  'f_e_change': FoundationPracticeExercise(
    id: 'f_e_change',
    title: 'F-E Change Notes',
    summary: 'بدّل بين F وE على pulse واضح.',
    instructions: 'اعزف F ثم E وكرر ذلك مع metronome بطيء. انتبه لليد اليمنى.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'F E F E',
    recommendedBpm: 64,
    durationMinutes: 4,
    relatedNoteIds: ['note_f', 'note_e'],
    checkpoints: [
      'الانتقال ليس متأخرًا',
      'السبابة لا ترتفع بالخطأ',
    ],
  ),
  'd_listen_hold': FoundationPracticeExercise(
    id: 'd_listen_hold',
    title: 'Listen to D',
    summary: 'استمع إلى D ثم كررها مع شكل اليد اليمنى الكامل.',
    instructions:
        'اسمع D ثم اعزفها مباشرة مع بقاء الأصابع الستة قريبة من مفاتيحها.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'D',
    recommendedBpm: 60,
    durationMinutes: 2,
    relatedNoteIds: ['note_d'],
    checkpoints: [
      'جميع أصابع اليد اليمنى الثلاثة ثابتة',
      'الصوت لا يتقطع',
    ],
  ),
  'd_long_tone': FoundationPracticeExercise(
    id: 'd_long_tone',
    title: 'D Long Tone',
    summary: 'ثبت D وراقب استقرار اليد اليمنى كاملة.',
    instructions: 'اعزف D لمدة 4 beats وكررها بتركيز على استرخاء الرسغ.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'D',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_d'],
    checkpoints: [
      'البنصر الأيمن يتحرك بخفة',
      'الوقت ثابت',
    ],
  ),
  'e_d_change': FoundationPracticeExercise(
    id: 'e_d_change',
    title: 'E-D Change Notes',
    summary: 'بدّل بين E وD بإحكام زمني وحركي.',
    instructions:
        'اعزف E ثم D، وكرر ذلك على metronome بطيء مع أقل رفع ممكن للأصابع.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'E D E D',
    recommendedBpm: 64,
    durationMinutes: 4,
    relatedNoteIds: ['note_e', 'note_d'],
    checkpoints: [
      'اليد اليمنى تبقى مستديرة',
      'الانتقال متساوٍ في كل مرة',
    ],
  ),
  'c_listen_hold': FoundationPracticeExercise(
    id: 'c_listen_hold',
    title: 'Listen to C',
    summary: 'استمع إلى written middle C ثم طابقها بهدوء.',
    instructions:
        'اسمع C ثم عزفها مباشرة، وراقب استخدام octave key فقط في هذه النسخة المبتدئة.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'C',
    recommendedBpm: 58,
    durationMinutes: 2,
    relatedNoteIds: ['note_c'],
    checkpoints: [
      'octave key يعمل بوضوح',
      'اليدان تبقيان قريبتين من الآلة',
    ],
  ),
  'c_long_tone': FoundationPracticeExercise(
    id: 'c_long_tone',
    title: 'C Long Tone',
    summary: 'ثبت written middle C بوضوح وهدوء.',
    instructions: 'اعزف C لمدة 4 beats وكررها مع بداية ناعمة ودعم هوائي ثابت.',
    category: FoundationExerciseCategory.noteFocus,
    playbackPattern: PlaybackPattern.note,
    playbackKey: 'C',
    recommendedBpm: 56,
    durationMinutes: 3,
    relatedNoteIds: ['note_c'],
    checkpoints: [
      'لا يوجد شد في الرقبة',
      'الصوت يبقى واضحًا حتى النهاية',
    ],
  ),
  'd_c_change': FoundationPracticeExercise(
    id: 'd_c_change',
    title: 'D-C Change Notes',
    summary: 'بدّل بين D وC مع إدخال octave key بهدوء.',
    instructions:
        'اعزف D ثم C وكرر ذلك ببطء، مع التركيز على حركة octave key النظيفة.',
    category: FoundationExerciseCategory.coordination,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'D C D C',
    recommendedBpm: 60,
    durationMinutes: 4,
    relatedNoteIds: ['note_d', 'note_c'],
    checkpoints: [
      'octave key لا يسبب توترًا',
      'الزمن ثابت',
    ],
  ),
  'first_five_melody': FoundationPracticeExercise(
    id: 'first_five_melody',
    title: 'First 5-note melody',
    summary: 'أول لحن بسيط من B-A-G-F-E.',
    instructions: 'اعزف B-A-G ثم F-E، ثم كرر اللحن كاملًا مع metronome بطيء.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G F E G A B',
    recommendedBpm: 66,
    durationMinutes: 5,
    relatedNoteIds: ['note_b', 'note_a', 'note_g', 'note_f', 'note_e'],
    checkpoints: [
      'اللحن متصل',
      'لا توجد قفزات في شدة الصوت',
    ],
  ),
  'first_five_call_response': FoundationPracticeExercise(
    id: 'first_five_call_response',
    title: 'First 5-note call and response',
    summary: 'اسمع جملة قصيرة ثم جاوبها بنفس المواد.',
    instructions:
        'دع التشغيل يقدّم الجملة ثم أعدها. بعد ذلك غيّر النهاية بنغمة أخرى من الخمس نغمات.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G E F G A',
    recommendedBpm: 68,
    durationMinutes: 5,
    relatedNoteIds: ['note_b', 'note_a', 'note_g', 'note_f', 'note_e'],
    checkpoints: [
      'الجواب في نفس الوقت',
      'النهاية الجديدة ما زالت واضحة موسيقيًا',
    ],
  ),
  'scale_c_slow': FoundationPracticeExercise(
    id: 'scale_c_slow',
    title: 'C Major slow practice',
    summary: 'صعود بطيء لسلم C major.',
    instructions:
        'اعزف C-D-E-F-G-A-B ببطء شديد. توقف لحظة قصيرة إذا احتجت مراجعة الأصابع.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'C D E F G A B',
    recommendedBpm: 60,
    durationMinutes: 5,
    relatedScaleIds: ['scale_c_major'],
    checkpoints: [
      'كل نغمة مسموعة',
      'الوقت متساوٍ',
    ],
  ),
  'scale_c_descend': FoundationPracticeExercise(
    id: 'scale_c_descend',
    title: 'C Major descending',
    summary: 'نزول من B إلى C بنفس الهدوء.',
    instructions: 'انزل B-A-G-F-E-D-C وراقب ألّا تتسرع في آخر ثلاث نغمات.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'B A G F E D C',
    recommendedBpm: 60,
    durationMinutes: 5,
    relatedScaleIds: ['scale_c_major'],
    checkpoints: [
      'النهاية ثابتة',
      'النغمة الأخيرة C واضحة',
    ],
  ),
  'scale_c_phrase': FoundationPracticeExercise(
    id: 'scale_c_phrase',
    title: 'C Major phrase application',
    summary: 'حوّل السلم إلى 2-note و3-note phrases بسيطة.',
    instructions: 'جرّب C-D ثم E-D-C ثم call and response قصير من نفس النغمات.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'C D E D C G E D',
    recommendedBpm: 72,
    durationMinutes: 5,
    relatedScaleIds: ['scale_c_major'],
    checkpoints: [
      'الجملة تبدو متصلة',
      'الإيقاع متحكم فيه',
    ],
  ),
  'scale_g_slow': FoundationPracticeExercise(
    id: 'scale_g_slow',
    title: 'G Major slow practice',
    summary: 'صعود بطيء لسلم G major.',
    instructions: 'اعزف G-A-B-C-D-E-F# ببطء وراجع كل انتقال.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G A B C D E F#',
    recommendedBpm: 58,
    durationMinutes: 5,
    relatedScaleIds: ['scale_g_major'],
    checkpoints: [
      'الصعود متساوٍ',
      'انتبه لوضوح F# مع حركة أصابع هادئة ومنظمة.',
    ],
  ),
  'scale_g_descend': FoundationPracticeExercise(
    id: 'scale_g_descend',
    title: 'G Major descending',
    summary: 'انزل من F# إلى G بثبات.',
    instructions: 'نفّذ F#-E-D-C-B-A-G مع pulse هادئ.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'F# E D C B A G',
    recommendedBpm: 58,
    durationMinutes: 5,
    relatedScaleIds: ['scale_g_major'],
    checkpoints: [
      'الوقت ثابت',
      'النغمة الأخيرة G مستقرة',
    ],
  ),
  'scale_g_phrase': FoundationPracticeExercise(
    id: 'scale_g_phrase',
    title: 'G Major phrase application',
    summary: 'حوّل G major إلى phrases صغيرة أصلية.',
    instructions: 'جرّب G-A ثم G-B-A ثم سؤال وجواب قصير من نفس النغمات.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G A B A G D B G',
    recommendedBpm: 72,
    durationMinutes: 5,
    relatedScaleIds: ['scale_g_major'],
    checkpoints: [
      'السؤال والجواب مختلفان قليلًا',
      'التمبو لا يتغير',
    ],
  ),
  'scale_f_slow': FoundationPracticeExercise(
    id: 'scale_f_slow',
    title: 'F Major slow practice',
    summary: 'سلم F major بطيء مع ملاحظة Bb.',
    instructions:
        'اعزف F-G-A-Bb-C-D-E ببطء. إذا كانت Bb جديدة عليك، خذها وحدها مرتين ثم عد إلى السلم كاملًا.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'F G A Bb C D E',
    recommendedBpm: 56,
    durationMinutes: 5,
    relatedScaleIds: ['scale_f_major'],
    checkpoints: [
      'F-G-A نظيفة',
      'Bb تدخل بوضوح ومن غير توتر في اليد.',
    ],
  ),
  'scale_f_descend': FoundationPracticeExercise(
    id: 'scale_f_descend',
    title: 'F Major descending',
    summary: 'نزول من E إلى F بنفس الهدوء.',
    instructions: 'انزل E-D-C-Bb-A-G-F ببطء وعلى نبض ثابت.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'E D C Bb A G F',
    recommendedBpm: 56,
    durationMinutes: 5,
    relatedScaleIds: ['scale_f_major'],
    checkpoints: [
      'لا تتسرع في النزول',
      'F الأخيرة مستقرة',
    ],
  ),
  'scale_f_phrase': FoundationPracticeExercise(
    id: 'scale_f_phrase',
    title: 'F Major phrase application',
    summary: 'حوّل F major إلى جمل بسيطة.',
    instructions: 'اعزف F-A-G ثم A-G-F، وبعدها جرّب call and response قصير.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'F A G A G F C A F',
    recommendedBpm: 70,
    durationMinutes: 5,
    relatedScaleIds: ['scale_f_major'],
    checkpoints: [
      'العبارة واضحة',
      'التغيير الإيقاعي مسموع',
    ],
  ),
  'scale_a_pent_slow': FoundationPracticeExercise(
    id: 'scale_a_pent_slow',
    title: 'A Minor Pentatonic slow practice',
    summary: 'مرور بطيء على A-C-D-E-G.',
    instructions: 'اعزف A-C-D-E-G ببطء ثم استمع لشخصية السلم.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'A C D E G',
    recommendedBpm: 60,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_minor_pentatonic'],
    checkpoints: [
      'كل نغمة واضحة',
      'المسافات مختلفة لكن مسموعة',
    ],
  ),
  'scale_a_pent_descend': FoundationPracticeExercise(
    id: 'scale_a_pent_descend',
    title: 'A Minor Pentatonic descending',
    summary: 'نزول من G إلى A بثبات.',
    instructions: 'انزل G-E-D-C-A مع نفس الهدوء والتركيز.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G E D C A',
    recommendedBpm: 60,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_minor_pentatonic'],
    checkpoints: [
      'النغمة النهائية A مستقرة',
      'الإيقاع ثابت',
    ],
  ),
  'scale_a_pent_phrase': FoundationPracticeExercise(
    id: 'scale_a_pent_phrase',
    title: 'A Minor Pentatonic phrase application',
    summary: 'ابنِ phrases قصيرة من pentatonic.',
    instructions:
        'جرّب A-C ثم A-C-D ثم جواب بسيط G-E-D. بدّل الإيقاع في كل مرة.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'A C D C A G E D',
    recommendedBpm: 74,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_minor_pentatonic'],
    checkpoints: [
      'الجمل قصيرة وواضحة',
      'فيها سؤال وجواب',
    ],
  ),
  'scale_a_blues_slow': FoundationPracticeExercise(
    id: 'scale_a_blues_slow',
    title: 'A Blues slow practice',
    summary: 'مرور بطيء على A blues scale.',
    instructions:
        'اعزف A-C-D-Eb-E-G ببطء شديد، وخذ حركة D-Eb-E وحدها إذا احتجت تثبيت اللون قبل إكمال السلم.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'A C D Eb E G',
    recommendedBpm: 58,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_blues'],
    checkpoints: [
      'حركة D-Eb-E مسموعة',
      'Eb واضحة وتنتقل بسلاسة إلى E.',
    ],
  ),
  'scale_a_blues_descend': FoundationPracticeExercise(
    id: 'scale_a_blues_descend',
    title: 'A Blues descending',
    summary: 'نزول من G إلى A مع التركيز على اللون.',
    instructions: 'انزل G-E-Eb-D-C-A بهدوء وبتساوٍ زمني.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'G E Eb D C A',
    recommendedBpm: 58,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_blues'],
    checkpoints: [
      'اللون blues واضح',
      'لا تتسرع في D-Eb-E',
    ],
  ),
  'scale_a_blues_phrase': FoundationPracticeExercise(
    id: 'scale_a_blues_phrase',
    title: 'A Blues phrase application',
    summary: 'حوّل السلم إلى blues phrase قصيرة أصلية.',
    instructions: 'استخدم D-Eb-E ثم G-E-D. بعد ذلك جرّب سؤالًا وجوابًا صغيرًا.',
    category: FoundationExerciseCategory.scaleFlow,
    playbackPattern: PlaybackPattern.phrase,
    playbackKey: 'D Eb E G E D A C A',
    recommendedBpm: 72,
    durationMinutes: 5,
    relatedScaleIds: ['scale_a_blues'],
    checkpoints: [
      'العبارة تبدو مقصودة',
      'الإيقاع متحكم فيه',
    ],
  ),
};
