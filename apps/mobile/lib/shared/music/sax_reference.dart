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

/// A comprehensive lookup for saxophone fingerings and staff positions.
/// Coordinates with [SaxFingeringCard] and [NoteStaffCard].
final Map<String, SaxReferenceNote> _referenceLibrary = {
  // --- Low Register ---
  'Bb3': const SaxReferenceNote(
    token: 'Bb',
    staffStepFromBottom: -3,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'lowBb', 'lowB', 'lowC', 'lowC#'},
    summary: 'أقل نغمة في الساكسفون. تحتاج استرخاء تاماً في الفك وتدفق هواء كثيف.',
  ),
  'B3': const SaxReferenceNote(
    token: 'B',
    staffStepFromBottom: -3,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'lowB', 'lowC', 'lowC#'},
    summary: 'نغمة سي المنخفضة. تأكد من إغلاق مفتاح B المنخفض في الجرس.',
  ),
  'C4': const SaxReferenceNote(
    token: 'C',
    staffStepFromBottom: -2,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'lowC'},
    summary: 'دو المنخفضة. نغمة أساسية قوية. استخدم خنصر اليد اليمنى.',
  ),
  'C#4': const SaxReferenceNote(
    token: 'C#',
    staffStepFromBottom: -2,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'lowC#'},
    summary: 'دو دييز المنخفضة. جميع الأصابع الستة مغلقة مع مفتاح C# للخنصر الأيسر.',
  ),
  'D4': const SaxReferenceNote(
    token: 'D',
    staffStepFromBottom: -1,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6'},
    summary: 'ري المنخفضة. 6 أصابع أساسية. أساس جيد لبناء الصوت.',
  ),
  'Eb4': const SaxReferenceNote(
    token: 'Eb',
    staffStepFromBottom: -1,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'lowEb'},
    summary: 'مي بيمول المنخفضة. استخدم المفتاح العلوي في خنصر اليد اليمنى.',
  ),
  'E4': const SaxReferenceNote(
    token: 'E',
    staffStepFromBottom: 0,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4', 'p5'},
    summary: 'نغمة مي. 5 أصابع. تقع على أول سطر في المدرج الموسيقي.',
  ),
  'F4': const SaxReferenceNote(
    token: 'F',
    staffStepFromBottom: 1,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p4'},
    summary: 'نغمة فا. 4 أصابع (3 يسار + سبابة يمين).',
  ),
  'F#4': const SaxReferenceNote(
    token: 'F#',
    staffStepFromBottom: 1,
    pressedKeyIds: {'p1', 'p2', 'p3', 'p5'},
    summary: 'فا دييز. استخدم الوسطى اليمنى بدلاً من السبابة.',
  ),
  'G4': const SaxReferenceNote(
    token: 'G',
    staffStepFromBottom: 2,
    pressedKeyIds: {'p1', 'p2', 'p3'},
    summary: 'نغمة صول. 3 أصابع يد يسرى. نغمة التوازن المثالية للمبتدئين.',
  ),
  'Ab4': const SaxReferenceNote(
    token: 'Ab',
    staffStepFromBottom: 3,
    pressedKeyIds: {'p1', 'p2', 'p3', 'leftPinkyAb'},
    summary: 'لا بيمول. صول + مفتاح الخنصر الأيسر العلوي.',
  ),
  'A4': const SaxReferenceNote(
    token: 'A',
    staffStepFromBottom: 3,
    pressedKeyIds: {'p1', 'p2'},
    summary: 'نغمة لا. إصبعان فقط. حافظ على استقرار وضعية اليد.',
  ),
  'Bb4': const SaxReferenceNote(
    token: 'Bb',
    staffStepFromBottom: 4,
    pressedKeyIds: {'p1', 'sideBb'},
    summary: 'سي بيمول الوسطى. استخدم السبابة اليسرى مع المفتاح الجانبي السفلي لليمنى.',
  ),
  'B4': const SaxReferenceNote(
    token: 'B',
    staffStepFromBottom: 4,
    pressedKeyIds: {'p1'},
    summary: 'نغمة سي. إصبع واحد فقط. ركز على جودة الصوت.',
  ),
  'C5': const SaxReferenceNote(
    token: 'C',
    staffStepFromBottom: 5,
    pressedKeyIds: {'p2'},
    summary: 'دو الوسطى. الإصبع الأوسط لليد اليسرى فقط.',
  ),
  'C#5': const SaxReferenceNote(
    token: 'C#',
    staffStepFromBottom: 5,
    pressedKeyIds: {},
    summary: 'دو دييز الوسطى. "نغمة مفتوحة" - جميع المفاتيح مفتوحة.',
  ),

  // --- Middle/Upper Register (Octave Key) ---
  'D5': const SaxReferenceNote(
    token: 'D',
    staffStepFromBottom: 6,
    pressedKeyIds: {'octave', 'p1', 'p2', 'p3', 'p4', 'p5', 'p6'},
    summary: 'ري العالية. نفس فينجرينج ري المنخفضة ولكن مع إضافة مفتاح الأوكتاف.',
  ),
  'E5': const SaxReferenceNote(
    token: 'E',
    staffStepFromBottom: 7,
    pressedKeyIds: {'octave', 'p1', 'p2', 'p3', 'p4', 'p5'},
    summary: 'مي العالية مع مفتاح الأوكتاف.',
  ),
  'F5': const SaxReferenceNote(
    token: 'F',
    staffStepFromBottom: 8,
    pressedKeyIds: {'octave', 'p1', 'p2', 'p3', 'p4'},
    summary: 'فا العالية مع مفتاح الأوكتاف.',
  ),
  'G5': const SaxReferenceNote(
    token: 'G',
    staffStepFromBottom: 9,
    pressedKeyIds: {'octave', 'p1', 'p2', 'p3'},
    summary: 'صول العالية. استخدم مفتاح الأوكتاف بالإبهام الأيسر.',
  ),
  'A5': const SaxReferenceNote(
    token: 'A',
    staffStepFromBottom: 10,
    pressedKeyIds: {'octave', 'p1', 'p2'},
    summary: 'لا العالية.',
  ),
  'B5': const SaxReferenceNote(
    token: 'B',
    staffStepFromBottom: 11,
    pressedKeyIds: {'octave', 'p1'},
    summary: 'سي العالية.',
  ),
  'C6': const SaxReferenceNote(
    token: 'C',
    staffStepFromBottom: 12,
    pressedKeyIds: {'octave', 'p2'},
    summary: 'دو الحادة العليا.',
  ),

  // --- Palm Keys (High Notes) ---
  'D6': const SaxReferenceNote(
    token: 'D',
    staffStepFromBottom: 13,
    pressedKeyIds: {'octave', 'palmD'},
    summary: 'ري الحادة جداً. استخدم مفتاح النخلة الأول باليد اليسرى.',
  ),
  'Eb6': const SaxReferenceNote(
    token: 'Eb',
    staffStepFromBottom: 13,
    pressedKeyIds: {'octave', 'palmD', 'palmEb'},
    summary: 'مي بيمول الحادة. مفتاحا النخلة الأول والثاني.',
  ),
  'E6': const SaxReferenceNote(
    token: 'E', staffStepFromBottom: 14,
    pressedKeyIds: {'octave', 'palmD', 'palmEb', 'palmE'},
    summary: 'مي العليا. أضف مفتاح النخلة الثالث باليد اليمنى.',
  ),
  'F6': const SaxReferenceNote(
    token: 'F', staffStepFromBottom: 15,
    pressedKeyIds: {'octave', 'palmD', 'palmEb', 'palmE', 'palmF'},
    summary: 'فا العليا. أضف مفتاح النخلة العلوي لليسرى.',
  ),
};

SaxReferenceNote lookupSaxReference(String token) {
  // Normalize token (e.g. 'g4' -> 'G4', 'eb' -> 'Eb4')
  String key = token.toUpperCase();
  if (!RegExp(r'\d$').hasMatch(key)) {
    // Add default octave if missing
    if (RegExp(r'[D-G]').hasMatch(key[0])) {
      key += '4';
    } else if (RegExp(r'[A-C]').hasMatch(key[0])) {
      key += '4';
    }
  }
  
  // Handle some common aliases
  if (key == 'EB4') key = 'Eb4';
  if (key == 'BB3') key = 'Bb3';
  if (key == 'F#4') key = 'F#4';

  return _referenceLibrary[key] ?? _referenceLibrary['G4']!;
}

List<String> getAllReferenceTokens() => _referenceLibrary.keys.toList();
