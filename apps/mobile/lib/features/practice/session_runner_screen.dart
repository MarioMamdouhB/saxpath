import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

import '../results/results_screen.dart';
import 'models/mock_recording.dart';
import 'widgets/mock_recording_card.dart';

class SessionRunnerScreen extends StatefulWidget {
  const SessionRunnerScreen({
    super.key,
    required this.apiClient,
    required this.dayPlan,
  });

  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;

  @override
  State<SessionRunnerScreen> createState() => _SessionRunnerScreenState();
}

class _SessionRunnerScreenState extends State<SessionRunnerScreen> {
  late final PageController _pageController;
  late final Future<List<Lesson>> _lessonsFuture;
  int _currentStep = 0;
  bool _isSubmitting = false;
  MockRecording? _recording;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _lessonsFuture = widget.apiClient.getLessons(dayNumber: widget.dayPlan.dayNumber);

    widget.apiClient.trackEvent(
      eventName: 'session_start',
      dayNumber: widget.dayPlan.dayNumber,
    ).catchError((_) {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  int get _totalSteps => widget.dayPlan.tasks.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text('تمرين اليوم ${widget.dayPlan.dayNumber}'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                backgroundColor: AppColors.paleMint,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = snapshot.data ?? [];

          return PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            itemCount: _totalSteps,
            itemBuilder: (context, index) {
              final task = widget.dayPlan.tasks[index];
              return _TaskStepView(
                task: task,
                lessons: lessons,
                onNext: _nextStep,
                onRecordingChanged: (rec) => setState(() => _recording = rec),
                onSubmit: () => _submitAttempt(task.id),
                isSubmitting: _isSubmitting,
                canSubmit: _recording != null,
                dayNumber: widget.dayPlan.dayNumber,
                apiClient: widget.apiClient,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submitAttempt(String exerciseId) async {
    final recording = _recording;
    if (recording == null) return;

    setState(() => _isSubmitting = true);

    try {
      var recordingForResult = recording;
      if (recording.isRealRecording && recording.recordingId == null) {
        final upload = await widget.apiClient.uploadRecording(filePath: recording.audioUrl);
        recordingForResult = recording.copyWith(
          durationSeconds: upload.durationSeconds,
          label: upload.filename,
          recordingId: upload.recordingId,
          playbackUrl: upload.playbackUrl,
        );
      }

      final evaluation = await widget.apiClient.submitPracticeAttempt(
        exerciseId: exerciseId,
        durationSeconds: recordingForResult.durationSeconds,
        audioUrl: recordingForResult.playbackUrl ?? recordingForResult.audioUrl,
        recordingId: recordingForResult.recordingId,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            evaluation: evaluation,
            apiClient: widget.apiClient,
            dayNumber: widget.dayPlan.dayNumber,
            exerciseId: exerciseId,
            recording: recordingForResult,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عذراً، حدث خطأ أثناء إرسال المحاولة.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _TaskStepView extends StatelessWidget {
  const _TaskStepView({
    required this.task,
    required this.lessons,
    required this.onNext,
    required this.onRecordingChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.canSubmit,
    required this.dayNumber,
    required this.apiClient,
  });

  final DailyTask task;
  final List<Lesson> lessons;
  final VoidCallback onNext;
  final ValueChanged<MockRecording?> onRecordingChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool canSubmit;
  final int dayNumber;
  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    if (task.type == 'note_lesson') return _NoteLessonView(task: task, lessons: lessons, onNext: onNext);
    if (task.type == 'rhythm_lesson') return _RhythmLessonView(task: task, lessons: lessons, onNext: onNext);
    if (task.type == 'practice' || task.type == 'recording_attempt') {
      return _PracticeStepView(
        task: task,
        onRecordingChanged: onRecordingChanged,
        onSubmit: onSubmit,
        isSubmitting: isSubmitting,
        canSubmit: canSubmit,
        dayNumber: dayNumber,
        apiClient: apiClient,
      );
    }

    return Center(child: Text('نوع غير مدعوم: ${task.type}'));
  }
}

class _NoteLessonView extends StatelessWidget {
  const _NoteLessonView({required this.task, required this.lessons, required this.onNext});
  final DailyTask task;
  final List<Lesson> lessons;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final lesson = lessons.firstWhere((l) => l.type == 'note_lesson', orElse: () => lessons.first);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionTitle(title: lesson.title, subtitle: 'افهم النغمة ومكانها على الآلة'),
        const SizedBox(height: 20),
        NoteStaffCard(noteLabel: lesson.note ?? 'G'),
        const SizedBox(height: 16),
        SaxCard(child: Text(lesson.descriptionAr, style: const TextStyle(fontSize: 16, height: 1.5))),
        const SizedBox(height: 16),
        SaxFingeringCard(noteLabel: lesson.note ?? 'G'),
        const SizedBox(height: 32),
        PrimaryButton(label: 'فهمت، التالي', onPressed: onNext),
      ],
    );
  }
}

class _RhythmLessonView extends StatelessWidget {
  const _RhythmLessonView({required this.task, required this.lessons, required this.onNext});
  final DailyTask task;
  final List<Lesson> lessons;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final lesson = lessons.firstWhere((l) => l.type == 'rhythm_lesson', orElse: () => lessons.first);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionTitle(title: lesson.title, subtitle: 'ثبّت زمن النغمات مع الميترونوم'),
        const SizedBox(height: 20),
        const SaxCard(child: Center(child: Text('♩', style: TextStyle(fontSize: 80)))),
        const SizedBox(height: 16),
        MockPlaybackCard(
          title: 'اسمع الإيقاع',
          caption: 'استمع للنمط الإيقاعي وكرره مع الميترونوم.',
          accentLabel: lesson.title,
          pattern: PlaybackPattern.rhythm,
          patternKey: lesson.rhythm ?? 'quarter_note',
          durationSeconds: 8,
          bpm: 60,
        ),
        const SizedBox(height: 32),
        PrimaryButton(label: 'جاهز للتمرين', onPressed: onNext),
      ],
    );
  }
}

class _PracticeStepView extends StatelessWidget {
  const _PracticeStepView({
    required this.task,
    required this.onRecordingChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.canSubmit,
    required this.dayNumber,
    required this.apiClient,
  });

  final DailyTask task;
  final ValueChanged<MockRecording?> onRecordingChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool canSubmit;
  final int dayNumber;
  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionTitle(title: task.title, subtitle: 'الآن وقت العزف والتسجيل'),
        const SizedBox(height: 20),
        MetronomeCard(initialBpm: task.targetBpm ?? 60),
        const SizedBox(height: 16),
        MockPlaybackCard(
          title: 'اسمع الجملة كاملة',
          caption: 'استمع للجملة الموسيقية كاملة قبل بدء التسجيل.',
          accentLabel: task.title,
          pattern: PlaybackPattern.phrase,
          patternKey: task.expectedNotes.join(' '),
          durationSeconds: 12,
          bpm: task.targetBpm ?? 60,
        ),
        const SizedBox(height: 24),
        MockRecordingCard(
          exerciseId: task.id,
          dayNumber: dayNumber,
          onChanged: onRecordingChanged,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: isSubmitting ? 'جارٍ التحليل...' : 'إرسال المحاولة النهائية',
          onPressed: isSubmitting || !canSubmit ? null : onSubmit,
        ),
      ],
    );
  }
}
