import 'jazz_curriculum_models.dart';

class LessonFiveQuestions {
  const LessonFiveQuestions({
    required this.whatDoIHear,
    required this.whatDoIPlay,
    required this.whyDoesItWork,
    required this.whereInRealJazz,
    required this.howDoIUseItInMySolo,
  });

  final String whatDoIHear;
  final String whatDoIPlay;
  final String whyDoesItWork;
  final String whereInRealJazz;
  final String howDoIUseItInMySolo;

  bool get isComplete =>
      whatDoIHear.isNotEmpty &&
      whatDoIPlay.isNotEmpty &&
      whyDoesItWork.isNotEmpty &&
      whereInRealJazz.isNotEmpty &&
      howDoIUseItInMySolo.isNotEmpty;
}

class MvpCurriculumModule {
  const MvpCurriculumModule({
    required this.id,
    required this.order,
    required this.title,
    required this.summary,
  });

  final String id;
  final int order;
  final String title;
  final String summary;
}

class MvpCurriculumDay {
  const MvpCurriculumDay({
    required this.dayNumber,
    required this.weekNumber,
    required this.title,
    required this.focus,
    required this.moduleIds,
    required this.lesson,
    required this.fiveQuestions,
    required this.listeningAssignment,
    required this.improvisationAssignment,
    this.recordCheckpoint,
  });

  final int dayNumber;
  final int weekNumber;
  final String title;
  final String focus;
  final List<String> moduleIds;
  final Lesson lesson;
  final LessonFiveQuestions fiveQuestions;
  final String listeningAssignment;
  final String improvisationAssignment;
  final String? recordCheckpoint;

  bool get isComplete =>
      fiveQuestions.isComplete && lesson.supportsCoreEducationalFlow;
}

class MvpCurriculumWeek {
  const MvpCurriculumWeek({
    required this.weekNumber,
    required this.title,
    required this.summary,
    required this.days,
  });

  final int weekNumber;
  final String title;
  final String summary;
  final List<MvpCurriculumDay> days;
}

class MvpCurriculumProgram {
  const MvpCurriculumProgram({
    required this.id,
    required this.title,
    required this.summary,
    required this.modules,
    required this.weeks,
  });

  final String id;
  final String title;
  final String summary;
  final List<MvpCurriculumModule> modules;
  final List<MvpCurriculumWeek> weeks;

  int get totalDays =>
      weeks.fold<int>(0, (sum, week) => sum + week.days.length);

  MvpCurriculumDay? dayByNumber(int dayNumber) {
    for (final week in weeks) {
      for (final day in week.days) {
        if (day.dayNumber == dayNumber) {
          return day;
        }
      }
    }

    return null;
  }
}
