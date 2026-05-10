import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/practice/widgets/mock_recording_card.dart';
import 'package:saxpath_mobile/features/progress/progress_screen.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../results/results_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.apiClient,
    required this.dayPlan,
  });

  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  MockRecording? _recording;
  int _practiceBpm = 60;

  @override
  void initState() {
    super.initState();
    _scheduleScrollReset();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practiceTask = widget.dayPlan.tasks.firstWhere(
      (task) => task.type == 'practice',
      orElse: () => widget.dayPlan.tasks.first,
    );
    final phrasePatternKey = _phrasePatternKey(practiceTask);
    final slowerBpm = (_practiceBpm - 12).clamp(48, 108);
    final fasterBpm = (_practiceBpm + 12).clamp(48, 108);
    final playbackPresets = [
      PlaybackPreset(
        id: 'slow',
        label: 'بطيء',
        caption: 'ابدأ بنسخة أبطأ لتثبيت مخارج النغمات والعد.',
        accentLabel: 'تمهيد $slowerBpm نبضة/د',
        patternKey: phrasePatternKey,
        durationSeconds: 16,
        bpm: slowerBpm,
      ),
      PlaybackPreset(
        id: 'lesson',
        label: 'الدرس',
        caption: 'هذه هي السرعة المرجعية الحالية للتمرين.',
        accentLabel: 'السرعة المرجعية $_practiceBpm نبضة/د',
        patternKey: phrasePatternKey,
        durationSeconds: 14,
        bpm: _practiceBpm,
      ),
      PlaybackPreset(
        id: 'challenge',
        label: 'تحدي',
        caption: 'جرّب نفس الجملة على سرعة أعلى بعد ما يثبت الأداء.',
        accentLabel: 'تحدي $fasterBpm نبضة/د',
        patternKey: phrasePatternKey,
        durationSeconds: 12,
        bpm: fasterBpm,
      ),
    ];

    return Scaffold(
      appBar:
          AppBar(title: Text('التمرين - اليوم ${widget.dayPlan.dayNumber}')),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: practiceTask.title,
            subtitle: 'تمرين تطبيقي من خطة اليوم ${widget.dayPlan.dayNumber}',
          ),
          const SizedBox(height: 16),
          MetronomeCard(
            initialBpm: _practiceBpm,
            onBpmChanged: (nextBpm) {
              setState(() {
                _practiceBpm = nextBpm;
              });
            },
          ),
          const SizedBox(height: 16),
          MockPlaybackCard(
            title: 'استمع إلى الجملة',
            caption:
                'تشغيل صوتي فعلي لعبارة اليوم مع ثلاث مستويات: بطيء، مرجعي، وتحدي.',
            accentLabel: practiceTask.title,
            pattern: PlaybackPattern.phrase,
            patternKey: phrasePatternKey,
            durationSeconds: 14,
            bpm: _practiceBpm,
            presets: playbackPresets,
          ),
          const SizedBox(height: 16),
          _PracticeDrillCard(
            practiceTask: practiceTask,
            bpm: _practiceBpm,
            onOpenPreviousResults: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProgressScreen(apiClient: widget.apiClient),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          MockRecordingCard(
            exerciseId: practiceTask.id,
            dayNumber: widget.dayPlan.dayNumber,
            onChanged: (recording) {
              setState(() {
                _recording = recording;
              });
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _isSubmitting
                ? 'جارٍ تحليل المحاولة...'
                : _recording == null
                    ? 'سجّل المحاولة أولاً'
                    : 'أرسل المحاولة',
            onPressed: _isSubmitting || _recording == null
                ? null
                : () => _submitAttempt(practiceTask.id),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAttempt(String exerciseId) async {
    final recording = _recording;
    if (recording == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      var recordingForResult = recording;
      if (recording.isRealRecording &&
          recording.recordingId == null &&
          !recording.audioUrl.startsWith('mock://')) {
        final upload = await widget.apiClient.uploadRecording(
          filePath: recording.audioUrl,
        );
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
      try {
        await widget.apiClient.trackEvent(
          eventName: 'practice_finish',
          dayNumber: widget.dayPlan.dayNumber,
          taskId: exerciseId,
          attemptId: evaluation.attemptId,
          metadata: {
            'duration_seconds': recordingForResult.durationSeconds,
            'completion': evaluation.completion,
            'recording_id': recordingForResult.recordingId,
            'analysis_source': evaluation.analysis?.source,
            'retry_reason': evaluation.retryReason,
          },
        );
      } catch (_) {
        // Keep the learner moving even if analytics tracking is unavailable.
      }
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إرسال المحاولة حالياً. حاول مرة أخرى.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _phrasePatternKey(DailyTask task) {
    final tokens = RegExp(r'[A-G](?:#|b)?', caseSensitive: false)
        .allMatches(task.title)
        .map((match) => match.group(0)?.toUpperCase())
        .whereType<String>()
        .toList(growable: false);

    if (tokens.length >= 2) {
      return tokens.join(' ');
    }

    if (task.expectedNotes.length >= 2) {
      return task.expectedNotes.join(' ');
    }

    return task.id;
  }

  void _scheduleScrollReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }
}

class _PracticeDrillCard extends StatelessWidget {
  const _PracticeDrillCard({
    required this.practiceTask,
    required this.bpm,
    required this.onOpenPreviousResults,
  });

  final DailyTask practiceTask;
  final int bpm;
  final VoidCallback onOpenPreviousResults;

  @override
  Widget build(BuildContext context) {
    final noteTargets = practiceTask.expectedNotes.isEmpty
        ? 'نفس نغمات الجملة'
        : practiceTask.expectedNotes.join(' - ');

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خطة التنفيذ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('1. اسمع الجملة على $bpm نبضة/د ثم غنِّها أو صفّقها مرة.'),
          const SizedBox(height: 6),
          Text('2. اعزف النغمات المستهدفة: $noteTargets مع نفس النبض.'),
          const SizedBox(height: 6),
          const Text(
            '3. إذا انهار الوقت أو النغمة، ارجع إلى النسخة الأبطأ بدل إعادة الخطأ بنفس السرعة.',
          ),
          const SizedBox(height: 6),
          const Text(
            '4. سجّل محاولة واحدة نظيفة بدل عشر محاولات عشوائية.',
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onOpenPreviousResults,
            child: const Text('راجع النتائج السابقة قبل التسجيل'),
          ),
        ],
      ),
    );
  }
}
