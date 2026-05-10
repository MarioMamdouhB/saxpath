import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../practice/practice_screen.dart';

class RhythmLessonScreen extends StatefulWidget {
  const RhythmLessonScreen({
    super.key,
    required this.lessonsFuture,
    required this.apiClient,
    required this.dayPlan,
  });

  final Future<List<Lesson>> lessonsFuture;
  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;

  @override
  State<RhythmLessonScreen> createState() => _RhythmLessonScreenState();
}

class _RhythmLessonScreenState extends State<RhythmLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  late int _lessonBpm;

  @override
  void initState() {
    super.initState();
    _lessonBpm = _initialRhythmBpm(widget.dayPlan.dayNumber);
    _scheduleScrollReset();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('درس الإيقاع - اليوم ${widget.dayPlan.dayNumber}')),
      body: FutureBuilder<List<Lesson>>(
        future: widget.lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _LessonErrorState();
          }

          final rhythmLessons = snapshot.requireData
              .where((lesson) => lesson.type == 'rhythm_lesson')
              .toList();

          if (rhythmLessons.isEmpty) {
            return const _LessonErrorState();
          }

          final rhythmLesson = rhythmLessons.first;

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              SectionTitle(
                title: _rhythmLessonTitle(rhythmLesson),
                subtitle: rhythmLesson.descriptionAr,
              ),
              const SizedBox(height: 16),
              const SaxCard(
                child: SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      '♩',
                      style:
                          TextStyle(fontSize: 72, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SaxCard(
                child: Center(
                  child: Text(
                    _rhythmCount(rhythmLesson.rhythm),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MockPlaybackCard(
                title: 'عدّ الإيقاع',
                caption:
                    'استمع إلى العدّ الفعلي ثم كرره بصوت عالٍ أو بالتصفيق على أكثر من سرعة.',
                accentLabel: _rhythmCount(rhythmLesson.rhythm),
                pattern: PlaybackPattern.rhythm,
                patternKey: rhythmLesson.rhythm ?? 'quarter_note',
                durationSeconds: 8,
                bpm: _lessonBpm,
                presets: _buildPlaybackPresets(rhythmLesson),
              ),
              const SizedBox(height: 16),
              _RhythmTrainingLoopCard(
                rhythmLabel: _rhythmCount(rhythmLesson.rhythm),
                bpm: _lessonBpm,
              ),
              const SizedBox(height: 16),
              MetronomeCard(
                initialBpm: _lessonBpm,
                onBpmChanged: (nextBpm) {
                  setState(() {
                    _lessonBpm = nextBpm;
                  });
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'التالي',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PracticeScreen(
                        apiClient: widget.apiClient,
                        dayPlan: widget.dayPlan,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<PlaybackPreset> _buildPlaybackPresets(Lesson rhythmLesson) {
    final slowerBpm = (_lessonBpm - 10).clamp(48, 110);
    final fasterBpm = (_lessonBpm + 10).clamp(48, 110);
    final rhythmLabel = _rhythmCount(rhythmLesson.rhythm);

    return [
      PlaybackPreset(
        id: 'slow',
        label: 'بطيء',
        caption: 'مناسب لبداية العد بصوت واضح قبل التصفيق أو العزف.',
        accentLabel: '$rhythmLabel | $slowerBpm نبضة/د',
        patternKey: rhythmLesson.rhythm ?? 'quarter_note',
        durationSeconds: 10,
        bpm: slowerBpm,
      ),
      PlaybackPreset(
        id: 'lesson',
        label: 'الدرس',
        caption: 'هذه هي السرعة التعليمية الحالية لدرس اليوم.',
        accentLabel: '$rhythmLabel | $_lessonBpm نبضة/د',
        patternKey: rhythmLesson.rhythm ?? 'quarter_note',
        durationSeconds: 8,
        bpm: _lessonBpm,
      ),
      PlaybackPreset(
        id: 'faster',
        label: 'أسرع',
        caption: 'اختبر ثبات العد بعد ما تتقن النسخة المرجعية.',
        accentLabel: '$rhythmLabel | $fasterBpm نبضة/د',
        patternKey: rhythmLesson.rhythm ?? 'quarter_note',
        durationSeconds: 8,
        bpm: fasterBpm,
      ),
    ];
  }

  int _initialRhythmBpm(int dayNumber) {
    return switch (dayNumber) {
      1 => 56,
      2 => 58,
      3 => 60,
      4 => 64,
      5 => 66,
      6 => 68,
      _ => 72,
    };
  }

  static String _rhythmCount(String? rhythm) {
    switch (rhythm) {
      case 'quarter_note':
        return '1';
      case 'half_note':
        return '1 2';
      case 'quarter_rest':
        return 'صمت';
      case 'eighth_notes':
        return '1 &';
      case 'dotted_half_note':
        return '1 2 3';
      case 'count_4_4':
        return '1 2 3 4';
      case 'weekly_review':
        return '1 & 2 3';
      default:
        return '-';
    }
  }

  String _rhythmLessonTitle(Lesson lesson) {
    return switch (lesson.rhythm) {
      'quarter_note' => 'النوار',
      'half_note' => 'البلانش',
      'quarter_rest' => 'سكتة نوار',
      'eighth_notes' => 'الثمنان',
      'dotted_half_note' => 'بلانش منقوط',
      'count_4_4' => 'العد 4 على 4',
      'weekly_review' => 'مراجعة إيقاعية',
      _ => lesson.title,
    };
  }

  void _scheduleScrollReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }
}

class _LessonErrorState extends StatelessWidget {
  const _LessonErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'تعذر تحميل درس الإيقاع من الخادم حالياً.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RhythmTrainingLoopCard extends StatelessWidget {
  const _RhythmTrainingLoopCard({
    required this.rhythmLabel,
    required this.bpm,
  });

  final String rhythmLabel;
  final int bpm;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حلقة التدريب العملية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('1. صفّق النمط "$rhythmLabel" على $bpm نبضة/د من غير عزف.'),
          const SizedBox(height: 6),
          const Text(
            '2. قل العد بصوت واضح مع نفس النبض حتى لا يسبق اللسان اليد أو العكس.',
          ),
          const SizedBox(height: 6),
          const Text(
            '3. اعزف النمط على نغمة واحدة فقط. لو اهتز الوقت، ارجع أبطأ 8 BPM وكرر.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RhythmPill(label: 'أبطأ', bpm: (bpm - 8).clamp(48, 120)),
              _RhythmPill(label: 'الدرس', bpm: bpm),
              _RhythmPill(label: 'أسرع', bpm: (bpm + 8).clamp(48, 120)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RhythmPill extends StatelessWidget {
  const _RhythmPill({
    required this.label,
    required this.bpm,
  });

  final String label;
  final int bpm;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$label $bpm نبضة/د',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.deepTeal,
          ),
        ),
      ),
    );
  }
}
