import 'package:flutter/material.dart';

import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class JazzPillarDetailScreen extends StatelessWidget {
  const JazzPillarDetailScreen({
    super.key,
    required this.pillar,
  });

  final JazzPillarTrack pillar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pillar.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: pillar.title,
            subtitle: pillar.whyItMatters,
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Source Inspiration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _SourceWrap(sources: pillar.sourceInspiration),
                const SizedBox(height: 12),
                Text(
                  pillar.originalityNote,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Objectives',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final objective in pillar.objectives) ...[
                  Text('• $objective'),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          if (pillar.conceptToMusicMaps.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SaxCard(
              child: Text(
                'Concept to Music يحوّل الفكرة من معلومة نظرية إلى sound وسياقات متعددة: blues, ii-V-I, line, etude, ear training, rhythm, backing track, وimprovisation prompt.',
              ),
            ),
            const SizedBox(height: 12),
            for (final conceptMap in pillar.conceptToMusicMaps) ...[
              _ConceptToMusicCard(conceptMap: conceptMap),
              const SizedBox(height: 12),
            ],
          ],
          const SizedBox(height: 16),
          for (final module in pillar.modules) ...[
            _ModuleCard(module: module),
            const SizedBox(height: 12),
          ],
          if (pillar.tunes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SaxCard(
              child: Text(
                'The studies below are original, copyright-safe tune frameworks built to teach form, harmony, rhythm, guide tones, motif development, and improvisation logic.',
              ),
            ),
            const SizedBox(height: 12),
            for (final tune in pillar.tunes) ...[
              _TuneStudyCard(tune: tune),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
  });

  final JazzLessonModule module;

  @override
  Widget build(BuildContext context) {
    final lesson = module.toLesson();

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(module.summary),
          const SizedBox(height: 10),
          _SourceWrap(sources: module.sourceInspiration),
          const SizedBox(height: 8),
          Text(
            module.originalityNote,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _FlowCard(
            title: 'Educational Flow',
            stages: lesson.resolvedFlow.stages,
          ),
          const SizedBox(height: 10),
          for (final takeaway in module.keyTakeaways) ...[
            Text('• $takeaway'),
            const SizedBox(height: 6),
          ],
          if (module.conceptToMusicMaps.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Concept to Music',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final conceptMap in module.conceptToMusicMaps) ...[
              _ConceptToMusicCard(conceptMap: conceptMap),
              const SizedBox(height: 10),
            ],
          ],
          if (module.exercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final exercise in module.exercises) ...[
              _ExerciseCard(exercise: exercise),
              const SizedBox(height: 10),
            ],
          ],
          if (lesson.libraryItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Reference Library',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final item in lesson.libraryItems) ...[
              _LibraryItemCard(item: item),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _ConceptToMusicCard extends StatelessWidget {
  const _ConceptToMusicCard({
    required this.conceptMap,
  });

  final ConceptToMusicMap conceptMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conceptMap.conceptTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text('Theory: ${conceptMap.theory}'),
          const SizedBox(height: 6),
          Text('Sound: ${conceptMap.soundTarget}'),
          const SizedBox(height: 6),
          Text('Context: ${conceptMap.coreContext}'),
          if (conceptMap.transpositionSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in conceptMap.transpositionSummary.entries)
                  _FlowChip(label: '${entry.key} ${entry.value}'),
              ],
            ),
          ],
          const SizedBox(height: 10),
          for (final item in conceptMap.contexts) ...[
            Text(
              conceptMusicContextTypeLabel(item.type),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(item.title),
            const SizedBox(height: 4),
            Text(item.description),
            if (item.progression != null) ...[
              const SizedBox(height: 4),
              Text(
                'Progression: ${item.progression}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            if (item.noteFocus != null) ...[
              const SizedBox(height: 4),
              Text(
                'Focus: ${item.noteFocus}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            if (item.exerciseInstruction != null) ...[
              const SizedBox(height: 4),
              Text('Task: ${item.exerciseInstruction}'),
            ],
            if (item.backingTrack != null) ...[
              const SizedBox(height: 4),
              Text(
                'Backing Track: ${item.backingTrack!.title} · ${item.backingTrack!.tempo} BPM',
              ),
            ],
            if (item.rhythmPattern != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rhythm: ${item.rhythmPattern!.title} · ${item.rhythmPattern!.meter}',
              ),
            ],
            if (item.etude != null) ...[
              const SizedBox(height: 4),
              Text(
                'Etude: ${item.etude!.title} · ${difficultyLevelLabel(item.etude!.difficulty)}',
              ),
            ],
            if (item.improvisationPrompt != null) ...[
              const SizedBox(height: 4),
              Text('Prompt: ${item.improvisationPrompt!.prompt}'),
            ],
            if (item.transcriptionTask != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ear Task: ${item.transcriptionTask!.title} · ${item.transcriptionTask!.minutes} min',
              ),
            ],
            const SizedBox(height: 10),
          ],
          _SourceWrap(sources: conceptMap.sourceInspiration),
          const SizedBox(height: 8),
          Text(
            conceptMap.originalityNote,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
  });

  final JazzExercise exercise;

  @override
  Widget build(BuildContext context) {
    final richExercise = exercise.toExercise();
    final transpositions = richExercise.transpositionSummary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('${exercise.minutes} min · ${exercise.goal}'),
          const SizedBox(height: 10),
          _SourceWrap(sources: exercise.sourceInspiration),
          const SizedBox(height: 8),
          Text(
            exercise.originalityNote,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FlowChip(label: richExercise.difficulty.name),
              _FlowChip(
                label:
                    '${richExercise.tempoRange.minBpm}-${richExercise.tempoRange.maxBpm} BPM',
              ),
              for (final entry in transpositions.entries)
                _FlowChip(label: '${entry.key} ${entry.value}'),
            ],
          ),
          if (richExercise.suggestedSaxTypes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Sax Types: ${richExercise.suggestedSaxTypes.map((type) => type.name).join(', ')}',
            ),
          ],
          if (richExercise.targetConcepts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Target Concepts: ${richExercise.targetConcepts.join(' | ')}',
            ),
          ],
          if (richExercise.rhythmTrainerModes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Rhythm Trainer Modes: ${richExercise.rhythmTrainerModes.map(rhythmTrainerModeLabel).join(' | ')}',
            ),
          ],
          if (richExercise.feelNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final note in richExercise.feelNotes) ...[
              Text(
                'Feel Note: $note',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
            ],
          ],
          if (richExercise.backingTrack != null) ...[
            const SizedBox(height: 10),
            Text(
              'Backing Track: ${richExercise.backingTrack!.title} · ${richExercise.backingTrack!.tempo} BPM',
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry
                    in richExercise.backingTrack!.transpositionSummary.entries)
                  _FlowChip(label: '${entry.key} ${entry.value}'),
              ],
            ),
          ],
          if (richExercise.transcriptionTask != null) ...[
            const SizedBox(height: 10),
            const Text(
              'Transcription Workflow',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '${richExercise.transcriptionTask!.title} · ${richExercise.transcriptionTask!.minutes} min',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Focus: ${richExercise.transcriptionTask!.focus}'),
            if (richExercise.transcriptionTask!.audioReference != null) ...[
              const SizedBox(height: 6),
              Text(
                'Audio Reference: ${richExercise.transcriptionTask!.audioReference}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            for (final instruction
                in richExercise.transcriptionTask!.instructions) ...[
              Text('• $instruction'),
              const SizedBox(height: 4),
            ],
            if (richExercise.transcriptionTask!.expectedOutcome != null) ...[
              const SizedBox(height: 6),
              Text(
                'Expected Outcome: ${richExercise.transcriptionTask!.expectedOutcome}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
          if (richExercise.evaluationCriteria.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final criterion in richExercise.evaluationCriteria) ...[
              Text(
                'Evaluate: ${criterion.label} - ${criterion.description}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
            ],
          ],
          const SizedBox(height: 10),
          _FlowStrip(stages: exercise.resolvedFlow.stages),
          const SizedBox(height: 10),
          for (final step in exercise.steps) ...[
            Text(
              '${step.stage.name.toUpperCase()} · ${step.title}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(step.description),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.title,
    required this.stages,
  });

  final String title;
  final List<EducationalFlowStage> stages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _FlowStrip(stages: stages),
          const SizedBox(height: 12),
          for (final stage in stages) ...[
            Text(
              '${lessonStepTypeLabel(stage.type)} · ${stage.title}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(stage.description),
            if (stage.recommendations.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final recommendation in stage.recommendations)
                    _FlowChip(label: recommendation.label),
                ],
              ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TuneStudyCard extends StatelessWidget {
  const _TuneStudyCard({
    required this.tune,
  });

  final TuneStudy tune;

  @override
  Widget build(BuildContext context) {
    final transpositions = tune.backingTrack?.transpositionSummary ??
        buildTranspositionSummary(
          concertKey: tune.keyCenters.isNotEmpty ? tune.keyCenters.first : null,
        );

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tune.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(tune.focus),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FlowChip(label: tune.difficulty.name),
              _FlowChip(label: tuneFormTypeLabel(tune.formType)),
              for (final keyCenter in tune.keyCenters.take(3))
                _FlowChip(label: keyCenter),
              for (final entry in transpositions.entries)
                _FlowChip(label: '${entry.key} ${entry.value}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(tune.whyItMatters),
          if (tune.formDescription != null) ...[
            const SizedBox(height: 10),
            Text(
              'Form: ${tune.formDescription}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (tune.cadences.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Cadences',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final cadence in tune.cadences) ...[
              Text('• $cadence'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.commonProgressions.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Common Progressions',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final progression in tune.commonProgressions) ...[
              Text('• $progression'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.guideToneMap.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Guide Tone Map',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.guideToneMap) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.chordTonePractice.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Chord Tone Practice',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.chordTonePractice) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.rhythmOnlyImprovisation.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Rhythm-Only Improvisation',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.rhythmOnlyImprovisation) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.motifDevelopmentPrompts.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Motif Development',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.motifDevelopmentPrompts) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.backingTrack != null) ...[
            const SizedBox(height: 10),
            Text(
              'Backing Track: ${tune.backingTrack!.title} · ${tune.backingTrack!.tempo} BPM · ${tune.backingTrack!.styleLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (tune.listeningGoals.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Listening Goals',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.listeningGoals) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.improvisationGoals.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Improvisation Goals',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.improvisationGoals) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          if (tune.suggestedListening.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Suggested Listening',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final item in tune.suggestedListening) ...[
              Text('• $item'),
              const SizedBox(height: 4),
            ],
          ],
          const SizedBox(height: 10),
          _SourceWrap(sources: tune.sourceInspiration),
          const SizedBox(height: 8),
          Text(
            tune.originalityNote,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryItemCard extends StatelessWidget {
  const _LibraryItemCard({
    required this.item,
  });

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(item.categoryLabel),
          const SizedBox(height: 8),
          Text(item.summary),
          if (item.transpositionSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in item.transpositionSummary.entries)
                  _FlowChip(label: '${entry.key} ${entry.value}'),
              ],
            ),
          ],
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in item.tags) _FlowChip(label: tag),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FlowStrip extends StatelessWidget {
  const _FlowStrip({
    required this.stages,
  });

  final List<EducationalFlowStage> stages;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final stage in stages)
          _FlowChip(
            label: lessonStepTypeLabel(stage.type),
            generated: stage.isGenerated,
          ),
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({
    required this.label,
    this.generated = false,
  });

  final String label;
  final bool generated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: generated
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SourceWrap extends StatelessWidget {
  const _SourceWrap({
    required this.sources,
  });

  final List<String> sources;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final source in sources)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              source,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
