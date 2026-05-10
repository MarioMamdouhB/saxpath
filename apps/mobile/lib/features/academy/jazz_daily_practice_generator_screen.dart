import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/models/learner_progress.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_repository.dart';
import 'package:saxpath_mobile/shared/education/services/practice_plan_service.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class JazzDailyPracticeGeneratorScreen extends StatefulWidget {
  JazzDailyPracticeGeneratorScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.latestAttempt,
    PracticePlanService? practicePlanService,
  }) : practicePlanService =
            practicePlanService ?? PracticePlanService(repository: repository);

  final JazzCurriculumRepository repository;
  final LearnerProgress progress;
  final AttemptHistoryEntry? latestAttempt;
  final PracticePlanService practicePlanService;

  @override
  State<JazzDailyPracticeGeneratorScreen> createState() =>
      _JazzDailyPracticeGeneratorScreenState();
}

class _JazzDailyPracticeGeneratorScreenState
    extends State<JazzDailyPracticeGeneratorScreen> {
  SaxType? _selectedSaxType;
  int? _selectedAvailableMinutes;
  PracticeGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    final inputProfile =
        _selectedSaxType != null && _selectedAvailableMinutes != null
            ? widget.practicePlanService.buildInputProfile(
                progress: widget.progress,
                latestAttempt: widget.latestAttempt,
                saxType: _selectedSaxType!,
                availableMinutes: _selectedAvailableMinutes!,
                goal: _selectedGoal,
              )
            : null;
    final program = inputProfile == null
        ? null
        : widget.practicePlanService.buildAdaptiveProgram(
            progress: widget.progress,
            latestAttempt: widget.latestAttempt,
            input: inputProfile,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Practice Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: program?.title ?? 'Daily Practice Generator',
            subtitle: program?.summary ??
                'اختر نوع الساكسفون والوقت المتاح أولًا حتى تتولد لك خطة صحيحة لآلتك ووقتك.',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Practice Setup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text('نوع الساكسفون الذي ستتمرن عليه اليوم'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final saxType in SaxType.values)
                      ChoiceChip(
                        label: Text(saxTypeDisplayLabel(saxType)),
                        selected: _selectedSaxType == saxType,
                        onSelected: (_) {
                          setState(() {
                            _selectedSaxType = saxType;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('الوقت المتاح اليوم'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final minutes in _minuteOptions)
                      ChoiceChip(
                        label: Text('$minutes min'),
                        selected: _selectedAvailableMinutes == minutes,
                        onSelected: (_) {
                          setState(() {
                            _selectedAvailableMinutes = minutes;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('الهدف الرئيسي اليوم'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Auto'),
                      selected: _selectedGoal == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedGoal = null;
                        });
                      },
                    ),
                    for (final goal in PracticeGoal.values)
                      ChoiceChip(
                        label: Text(practiceGoalLabel(goal)),
                        selected: _selectedGoal == goal,
                        onSelected: (_) {
                          setState(() {
                            _selectedGoal = goal;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (program == null)
            const SaxCard(
              child: Text(
                'لن نستخدم افتراضات مخفية هنا. اختر نوع الساكسفون والوقت المتاح أولًا لعرض خطة دقيقة.',
              ),
            ),
          if (program != null) ...[
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(label: program.inputProfile.level.name),
                      _Chip(
                        label:
                            saxTypeDisplayLabel(program.inputProfile.saxType),
                      ),
                      _Chip(
                          label: practiceGoalLabel(program.inputProfile.goal)),
                      _Chip(
                        label: '${program.inputProfile.availableMinutes} min',
                      ),
                      if (program.inputProfile.currentCourse != null)
                        _Chip(label: program.inputProfile.currentCourse!),
                    ],
                  ),
                  if (program.inputProfile.weakAreas.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Weak Areas: ${program.inputProfile.weakAreas.map((item) => item.name).join(' | ')}',
                    ),
                  ],
                  if (program.inputProfile.upcomingLessons.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Upcoming Lessons: ${program.inputProfile.upcomingLessons.join(' | ')}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (program.adaptationDecisions.isNotEmpty) ...[
              SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adaptive Decisions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final decision in program.adaptationDecisions) ...[
                      Text(
                        practiceAdaptationTypeLabel(decision.type),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(decision.description),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Learning Flow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final stage in _programFlowStages(program))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            lessonStepTypeLabel(stage),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ${program.totalMinutes} min',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(program.nextRecommendation),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final source in program.sourceInspiration)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            source,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    program.originalityNote,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final block in program.blocks) ...[
              SaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${block.minutes} min · ${block.stage.name.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (block.skillAreas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final area in block.skillAreas)
                            _Chip(label: area.name),
                          if (block.targetTempoBpm != null)
                            _Chip(label: '${block.targetTempoBpm} BPM'),
                          if (block.recommendedSaxType != null)
                            _Chip(
                              label: saxTypeDisplayLabel(
                                block.recommendedSaxType!,
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(block.instructions),
                    if (block.adaptationNote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        block.adaptationNote!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  List<LessonStepType> _programFlowStages(DailyPracticeProgram program) {
    return {
      for (final block in program.blocks)
        lessonStepTypeFromLearningLoopStage(block.stage),
      LessonStepType.repeat,
    }.where(coreEducationalFlowOrder.contains).toList(growable: false);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

const List<int> _minuteOptions = [15, 30, 45, 60];
