import '../../data/models/attempt_history_entry.dart';
import '../../data/models/learner_progress.dart';
import 'curriculum_service.dart';
import 'jazz_curriculum_models.dart';
import 'jazz_curriculum_repository.dart';

class PracticePlanService {
  const PracticePlanService({
    JazzCurriculumRepository? repository,
    CurriculumService? curriculumService,
  })  : repository = repository ?? const JazzCurriculumRepository(),
        curriculumService = curriculumService ?? const CurriculumService();

  final JazzCurriculumRepository repository;
  final CurriculumService curriculumService;

  DailyPracticeProgram buildAdaptiveProgram({
    required LearnerProgress progress,
    AttemptHistoryEntry? latestAttempt,
    required PracticeEngineInput input,
  }) {
    return repository.buildDailyProgram(
      progress: progress,
      latestAttempt: latestAttempt,
      input: input,
    );
  }

  PracticeEngineInput buildInputProfile({
    required LearnerProgress progress,
    AttemptHistoryEntry? latestAttempt,
    required SaxType saxType,
    required int availableMinutes,
    PracticeGoal? goal,
  }) {
    return repository.buildPracticeEngineInput(
      progress: progress,
      latestAttempt: latestAttempt,
      saxType: saxType,
      availableMinutes: availableMinutes,
      goal: goal,
    );
  }

  PracticePlan buildSeedPlan({
    required DifficultyLevel level,
    required SaxType saxType,
    required int availableMinutes,
    SkillArea? weakness,
  }) {
    return curriculumService.buildSamplePracticePlan(
      level: level,
      saxType: saxType,
      availableMinutes: availableMinutes,
      weakness: weakness,
    );
  }
}
