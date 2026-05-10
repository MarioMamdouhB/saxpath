import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import 'rhythm_lesson_screen.dart';

class NoteLessonScreen extends StatefulWidget {
  const NoteLessonScreen({
    super.key,
    required this.lessonsFuture,
    required this.apiClient,
    required this.dayPlan,
  });

  final Future<List<Lesson>> lessonsFuture;
  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;

  @override
  State<NoteLessonScreen> createState() => _NoteLessonScreenState();
}

class _NoteLessonScreenState extends State<NoteLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _didTrackStart = false;

  @override
  void initState() {
    super.initState();
    _scheduleScrollReset();
    if (!_didTrackStart) {
      _didTrackStart = true;
      widget.apiClient.trackEvent(
        eventName: 'lesson_start',
        dayNumber: widget.dayPlan.dayNumber,
        taskId: widget.dayPlan.tasks.first.id,
        metadata: {
          'screen': 'note_lesson',
        },
      ).catchError((_) {});
    }
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
          AppBar(title: Text('درس النغمة - اليوم ${widget.dayPlan.dayNumber}')),
      body: FutureBuilder<List<Lesson>>(
        future: widget.lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _LessonErrorState();
          }

          final noteLessons = snapshot.requireData
              .where((lesson) => lesson.type == 'note_lesson')
              .toList();

          if (noteLessons.isEmpty) {
            return const _LessonErrorState();
          }

          final noteLesson = noteLessons.first;

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              SectionTitle(
                title: noteLesson.title,
                subtitle:
                    'الجزء الأول من خطة اليوم ${widget.dayPlan.dayNumber}',
              ),
              const SizedBox(height: 16),
              SaxCard(
                child: SizedBox(
                  height: 210,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.deepTeal,
                          AppColors.navyLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'نغمة اليوم',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          noteLesson.note ?? '-',
                          style: const TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'استمع للنغمة، شاهد موضعها على المدرج، ثم طابق الفينجرينج على الرسم التفاعلي.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NoteStaffCard(noteLabel: noteLesson.note ?? '-'),
              const SizedBox(height: 16),
              Text(noteLesson.descriptionAr),
              const SizedBox(height: 16),
              MockPlaybackCard(
                title: 'تشغيل النغمة',
                caption:
                    'تشغيل صوتي فعلي يساعدك تثبّت النغمة في أذنك قبل العزف.',
                accentLabel: noteLesson.note ?? '-',
                pattern: PlaybackPattern.note,
                patternKey: noteLesson.note ?? 'G',
                durationSeconds: 10,
              ),
              const SizedBox(height: 16),
              _PracticalNoteDrillCard(
                noteLabel: noteLesson.note ?? '-',
                dayNumber: widget.dayPlan.dayNumber,
              ),
              const SizedBox(height: 16),
              SaxFingeringCard(
                noteLabel: noteLesson.note ?? 'G',
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'التالي',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RhythmLessonScreen(
                        lessonsFuture: widget.lessonsFuture,
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
          'تعذر تحميل الدرس من الخادم حالياً.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PracticalNoteDrillCard extends StatelessWidget {
  const _PracticalNoteDrillCard({
    required this.noteLabel,
    required this.dayNumber,
  });

  final String noteLabel;
  final int dayNumber;

  @override
  Widget build(BuildContext context) {
    final settleBpm = 52 + (dayNumber * 2);
    final controlBpm = settleBpm + 8;
    final challengeBpm = controlBpm + 8;

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نفّذ الآن',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'لا تحفظ المعلومة فقط. حوّلها فورًا إلى sound ثابت يمكن تكراره.',
          ),
          const SizedBox(height: 12),
          const Text('1. استمع للنغمة مرتين وغنّها قبل لمس الساكس.'),
          const SizedBox(height: 6),
          Text('2. اعزف $noteLabel أربع مرات long tone مع نفس البداية والنهاية.'),
          const SizedBox(height: 6),
          const Text(
            '3. أعد المحاولة مرة أهدأ، ومرة أقوى، من غير أن ينهار الصوت أو يعلو الضغط.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TempoPill(label: 'تثبيت', bpm: settleBpm),
              _TempoPill(label: 'تحكم', bpm: controlBpm),
              _TempoPill(label: 'تحدي', bpm: challengeBpm),
            ],
          ),
        ],
      ),
    );
  }
}

class _TempoPill extends StatelessWidget {
  const _TempoPill({
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
