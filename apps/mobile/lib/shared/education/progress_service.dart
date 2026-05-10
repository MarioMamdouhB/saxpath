import '../../data/models/attempt_history_entry.dart';
import '../../data/models/learner_progress.dart';

class ProgressDashboardSnapshot {
  const ProgressDashboardSnapshot({
    required this.toneScore,
    required this.timingScore,
    required this.theoryScore,
    required this.earScore,
    required this.improvisationScore,
    required this.repertoireLearned,
    required this.practiceDays,
  });

  final String toneScore;
  final String timingScore;
  final String theoryScore;
  final String earScore;
  final String improvisationScore;
  final String repertoireLearned;
  final String practiceDays;
}

class ProgressService {
  const ProgressService();

  ProgressDashboardSnapshot buildDashboard({
    required LearnerProgress progress,
    required List<AttemptHistoryEntry> attempts,
  }) {
    if (attempts.isEmpty) {
      return ProgressDashboardSnapshot(
        toneScore: '${(progress.completedDaysCount * 10).clamp(10, 100)}%',
        timingScore: '${(progress.completedDaysCount * 9).clamp(10, 100)}%',
        theoryScore:
            '${((progress.completedDaysCount / progress.totalDays) * 100).round()}%',
        earScore: '${(progress.completedDaysCount * 8).clamp(10, 100)}%',
        improvisationScore:
            '${(progress.completedDaysCount * 8).clamp(10, 100)}%',
        repertoireLearned: '${progress.completedDaysCount} يوم',
        practiceDays: '${progress.completedDaysCount} يوم',
      );
    }

    final pitchAverage =
        (attempts.fold<int>(0, (sum, item) => sum + item.pitchAccuracy) /
                attempts.length)
            .round();
    final rhythmAverage =
        (attempts.fold<int>(0, (sum, item) => sum + item.rhythmAccuracy) /
                attempts.length)
            .round();
    final completionAverage =
        (attempts.fold<int>(0, (sum, item) => sum + item.completion) /
                attempts.length)
            .round();
    final theoryScore =
        (((progress.completedDaysCount / progress.totalDays) * 100) * 0.65 +
                completionAverage * 0.35)
            .round();
    final earScore = ((pitchAverage * 0.7) + (completionAverage * 0.3)).round();
    final improvisationScore =
        ((completionAverage * 0.6) + (rhythmAverage * 0.4)).round();

    return ProgressDashboardSnapshot(
      toneScore: '$pitchAverage%',
      timingScore: '$rhythmAverage%',
      theoryScore: '${theoryScore.clamp(0, 100)}%',
      earScore: '${earScore.clamp(0, 100)}%',
      improvisationScore: '${improvisationScore.clamp(0, 100)}%',
      repertoireLearned: '${progress.completedDaysCount} يوم',
      practiceDays: '${progress.completedDaysCount} يوم',
    );
  }
}
