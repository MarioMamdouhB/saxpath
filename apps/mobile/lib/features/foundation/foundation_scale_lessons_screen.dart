import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/foundation/foundation_exercise_player_screen.dart';
import 'package:saxpath_mobile/features/foundation/widgets/foundation_exercise_card.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/education/scale_service.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_repository.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class FoundationScaleLessonsScreen extends StatefulWidget {
  const FoundationScaleLessonsScreen({
    super.key,
    required this.repository,
    this.scaleService = const ScaleService(),
  });

  final SaxFoundationRepository repository;
  final ScaleService scaleService;

  @override
  State<FoundationScaleLessonsScreen> createState() =>
      _FoundationScaleLessonsScreenState();
}

class _FoundationScaleLessonsScreenState
    extends State<FoundationScaleLessonsScreen> {
  late List<FoundationScaleLesson> _scales;
  late FoundationScaleLesson _selectedScale;

  @override
  void initState() {
    super.initState();
    _scales = widget.repository.getScales();
    _selectedScale = _scales.first;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.scaleService.getScaleExercises(_selectedScale.id);
    final sequence = _selectedScale.noteSequence.join(' ');
    final scaleNotes = widget.scaleService.getScaleNotes(_selectedScale.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Scale Lessons')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'Scale Lessons',
            subtitle:
                'ابدأ بسلالم قصيرة مبنية من نغماتك التأسيسية، ثم حوّلها إلى جمل وتمارين قابلة للتكرار.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scale in _scales)
                ChoiceChip(
                  label: Text(scale.title),
                  selected: _selectedScale.id == scale.id,
                  onSelected: (_) {
                    setState(() {
                      _selectedScale = scale;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedScale.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedScale.subtitle,
                  style: const TextStyle(
                    color: AppColors.deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_selectedScale.purpose),
                const SizedBox(height: 8),
                Text(
                  _selectedScale.transferGoal,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Formula: ${_selectedScale.formula}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final note in _selectedScale.noteSequence)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softMint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          note,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepTeal,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'Scale Preview',
            caption:
                'استمع إلى تسلسل السلم أولاً قبل أن تعزفه. الفكرة هنا أن تربط الأذن بالحركة منذ البداية.',
            accentLabel: _selectedScale.tonalCenter,
            pattern: PlaybackPattern.phrase,
            patternKey: sequence,
            durationSeconds: 14,
            bpm: 68,
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fingering for each note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                for (final noteRef in scaleNotes) ...[
                  Text(
                    noteRef.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (noteRef.note != null)
                    SaxFingeringCard(
                      noteLabel: noteRef.note!.label,
                      title: 'Fingering',
                      fingering: noteRef.note!.fingering,
                    )
                  else
                    Text(
                      noteRef.referenceHint!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Practice blocks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Slow practice: ${_selectedScale.slowPractice}'),
                const SizedBox(height: 8),
                Text('Metronome practice: ${_selectedScale.metronomePractice}'),
                const SizedBox(height: 8),
                Text('Ascending practice: ${_selectedScale.ascendingPractice}'),
                const SizedBox(height: 8),
                Text(
                    'Descending practice: ${_selectedScale.descendingPractice}'),
                const SizedBox(height: 8),
                Text('Rhythm variation: ${_selectedScale.rhythmVariation}'),
                const SizedBox(height: 8),
                Text(
                  'Simple phrase application: ${_selectedScale.simplePhraseApplication}',
                ),
                const SizedBox(height: 8),
                Text(_selectedScale.backingTrackPlaceholder),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply this scale to music',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (final prompt in _selectedScale.phrasePrompts) ...[
                  Text(
                    '${prompt.title}: ${prompt.prompt}',
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Scale Exercises',
            subtitle:
                'كل سلم هنا مرتبط بتمارين مباشرة: صعود وهبوط، نقاط توقف، جملة قصيرة، ثم تسجيل ذاتي.',
          ),
          const SizedBox(height: 12),
          for (final exercise in exercises) ...[
            FoundationExerciseCard(
              exercise: exercise,
              onStart: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoundationExercisePlayerScreen(
                      exercise: exercise,
                      scale: _selectedScale,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
