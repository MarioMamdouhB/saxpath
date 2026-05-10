class SaxReferenceNote {
  const SaxReferenceNote({
    required this.token,
    required this.staffStepFromBottom,
    required this.pressedKeyIds,
    required this.summary,
  });

  final String token;
  final int staffStepFromBottom;
  final Set<String> pressedKeyIds;
  final String summary;
}

const Map<String, SaxReferenceNote> saxReferenceNotes = {
  'G': SaxReferenceNote(
    token: 'G',
    staffStepFromBottom: 2,
    pressedKeyIds: {'octave', 'p1', 'p2', 'p3'},
    summary:
        'G في المرجع الحالي يظهر كأوكتاف مع أول ثلاثة مفاتيح رئيسية لليد اليسرى، وهو الشكل القياسي لبداية هذا السجل.',
  ),
  'A': SaxReferenceNote(
    token: 'A',
    staffStepFromBottom: 3,
    pressedKeyIds: {'octave', 'p1', 'p2'},
    summary:
        'A هنا يرفع المفتاح الثالث من اليد اليسرى مع الإبقاء على الأوكتاف وأول مفتاحين رئيسيين.',
  ),
  'B': SaxReferenceNote(
    token: 'B',
    staffStepFromBottom: 4,
    pressedKeyIds: {'octave', 'p1'},
    summary:
        'B في هذا المرجع يبقي الأوكتاف مع أول مفتاح رئيسي فقط، وهو الانتقال الطبيعي بعد A في نفس المنطقة.',
  ),
  'C': SaxReferenceNote(
    token: 'C',
    staffStepFromBottom: 5,
    pressedKeyIds: {'octave'},
    summary:
        'C في الشارت المرجعي يظهر كمفتاح أوكتاف فقط من غير ضغط دوائر العمود الرئيسية.',
  ),
  'D': SaxReferenceNote(
    token: 'D',
    staffStepFromBottom: 6,
    pressedKeyIds: {'octave', 'palmD'},
    summary:
        'D يعتمد على الأوكتاف مع مفتاح Palm D العلوي، وليس على عمود الأصابع الرئيسي مثل G وA وB.',
  ),
  'E': SaxReferenceNote(
    token: 'E',
    staffStepFromBottom: 7,
    pressedKeyIds: {'octave', 'palmD', 'palmE'},
    summary:
        'E في هذا المرجع يبني على D بإضافة Palm E، لذلك يحتاج نفس الهواء الثابت مع لمسة palm إضافية.',
  ),
  'F': SaxReferenceNote(
    token: 'F',
    staffStepFromBottom: 8,
    pressedKeyIds: {'octave', 'palmD', 'palmE', 'palmF'},
    summary:
        'F هنا يكمل مجموعة palm keys العليا، وهو مفيد لربط التأسيس الأول بسلالم C وD minor البسيطة.',
  ),
};

SaxReferenceNote lookupSaxReference(String token) =>
    saxReferenceNotes[token] ?? saxReferenceNotes['G']!;
