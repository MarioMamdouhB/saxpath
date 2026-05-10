class Lesson {
  const Lesson({
    required this.id,
    required this.dayNumber,
    required this.type,
    required this.title,
    required this.descriptionAr,
    required this.durationMinutes,
    this.note,
    this.arabicName,
    this.rhythm,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      dayNumber: json['day_number'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      descriptionAr: json['description_ar'] as String,
      durationMinutes: json['duration_minutes'] as int,
      note: json['note'] as String?,
      arabicName: json['arabic_name'] as String?,
      rhythm: json['rhythm'] as String?,
    );
  }

  final String id;
  final int dayNumber;
  final String type;
  final String title;
  final String descriptionAr;
  final int durationMinutes;
  final String? note;
  final String? arabicName;
  final String? rhythm;
}
