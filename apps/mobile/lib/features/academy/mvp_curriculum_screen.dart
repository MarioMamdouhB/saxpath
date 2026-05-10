import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/mvp_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/services/curriculum_service.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class MvpCurriculumScreen extends StatelessWidget {
  MvpCurriculumScreen({
    super.key,
    CurriculumService? curriculumService,
  })  : curriculumService = curriculumService ?? const CurriculumService(),
        program =
            (curriculumService ?? const CurriculumService()).loadMvpProgram();

  final CurriculumService curriculumService;
  final MvpCurriculumProgram program;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('30-Day MVP Curriculum')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: program.title,
            subtitle: '${program.summary} · ${program.totalDays} days',
          ),
          const SizedBox(height: 16),
          const SaxCard(
            child: Text(
              'كل درس هنا مكتمل فقط إذا أجاب بوضوح على: What do I hear? What do I play? Why does it work? Where does it appear in real jazz? How do I use it in my own solo?',
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MVP Modules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final module in program.modules)
                      _ModulePill(module: module),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final week in program.weeks) ...[
            _WeekCard(week: week, modules: program.modules),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ModulePill extends StatelessWidget {
  const _ModulePill({
    required this.module,
  });

  final MvpCurriculumModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${module.order}. ${module.title}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.week,
    required this.modules,
  });

  final MvpCurriculumWeek week;
  final List<MvpCurriculumModule> modules;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            week.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(week.summary),
          const SizedBox(height: 12),
          for (final day in week.days) ...[
            _DayExpansion(day: day, modules: modules),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DayExpansion extends StatelessWidget {
  const _DayExpansion({
    required this.day,
    required this.modules,
  });

  final MvpCurriculumDay day;
  final List<MvpCurriculumModule> modules;

  @override
  Widget build(BuildContext context) {
    final matchedModules = modules
        .where((module) => day.moduleIds.contains(module.id))
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(
          'Day ${day.dayNumber} · ${day.title}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(day.focus),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: difficultyLevelLabel(day.lesson.level)),
              _InfoChip(
                label:
                    '${day.lesson.tempoRange.minBpm}-${day.lesson.tempoRange.maxBpm} BPM',
              ),
              for (final module in matchedModules)
                _InfoChip(label: module.title),
              _InfoChip(
                  label: day.isComplete ? 'Complete Lesson' : 'Incomplete'),
            ],
          ),
          const SizedBox(height: 12),
          Text(day.lesson.description),
          const SizedBox(height: 12),
          const Text(
            'Five Lesson Questions',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          _QuestionLine(
            question: '1. What do I hear?',
            answer: day.fiveQuestions.whatDoIHear,
          ),
          _QuestionLine(
            question: '2. What do I play?',
            answer: day.fiveQuestions.whatDoIPlay,
          ),
          _QuestionLine(
            question: '3. Why does it work?',
            answer: day.fiveQuestions.whyDoesItWork,
          ),
          _QuestionLine(
            question: '4. Where does it appear in real jazz?',
            answer: day.fiveQuestions.whereInRealJazz,
          ),
          _QuestionLine(
            question: '5. How do I use it in my own solo?',
            answer: day.fiveQuestions.howDoIUseItInMySolo,
          ),
          const SizedBox(height: 12),
          const Text(
            'Listen → Understand → Sing → Play → Improvise → Record → Evaluate → Repeat',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final step in day.lesson.steps) ...[
            Text(
              '${lessonStepTypeLabel(step.type)} · ${step.title}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(step.description),
            const SizedBox(height: 8),
          ],
          if (day.lesson.exercises.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'Core Exercise',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(day.lesson.exercises.first.title),
            const SizedBox(height: 4),
            Text(day.lesson.exercises.first.goal),
          ],
          const SizedBox(height: 12),
          Text('Listening Assignment: ${day.listeningAssignment}'),
          const SizedBox(height: 6),
          Text('Improvisation Task: ${day.improvisationAssignment}'),
          if (day.recordCheckpoint != null) ...[
            const SizedBox(height: 6),
            Text('Record Checkpoint: ${day.recordCheckpoint}'),
          ],
        ],
      ),
    );
  }
}

class _QuestionLine extends StatelessWidget {
  const _QuestionLine({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(answer),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
