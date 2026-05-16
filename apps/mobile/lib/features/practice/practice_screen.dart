import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
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
  bool _isLoadingAdaptiveSession = true;
  bool _waitModeEnabled = true;
  MockRecording? _recording;
  PracticeSession? _adaptiveSession;
  int _practiceBpm = 60;
  int _completedLoops = 0;
  int _targetLoops = 2;

  @override
  void initState() {
    super.initState();
    final practiceTask = widget.dayPlan.tasks.firstWhere(
      (task) => task.type == 'practice',
      orElse: () => widget.dayPlan.tasks.first,
    );
    _practiceBpm = practiceTask.targetBpm ?? _practiceBpm;
    _targetLoops = _suggestLoopTarget(practiceTask);
    _waitModeEnabled =
        practiceTask.expectedEventTimeline.isNotEmpty ||
        practiceTask.blockType == 'rhythm_call_response';
    _loadAdaptiveSession();
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
          if (_adaptiveSession != null) ...[
            _AdaptiveSessionCard(
              session: _adaptiveSession!,
              focusBlock: _focusPracticeBlock(_adaptiveSession!),
              isLoading: _isLoadingAdaptiveSession,
            ),
            const SizedBox(height: 16),
          ] else if (_isLoadingAdaptiveSession) ...[
            const SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جارٍ تجهيز الجلسة المتكيفة...',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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
            countInBeats: _waitModeEnabled ? 4 : 0,
            countInLabel: _waitModeEnabled
                ? 'في وضع Wait Mode: اسمع العد أولاً، ثم دع المرجع يمر مرة واحدة، وبعدها رد على الساكس قبل أن تكرّر loop جديدة.'
                : null,
          ),
          const SizedBox(height: 16),
          _InteractivePracticeToolsCard(
            practiceTask: practiceTask,
            bpm: _practiceBpm,
            waitModeEnabled: _waitModeEnabled,
            completedLoops: _completedLoops,
            targetLoops: _targetLoops,
            adaptationReasonAr:
                _adaptiveSession == null
                    ? null
                    : _focusPracticeBlock(_adaptiveSession!)?.adaptationReasonAr,
          ),
          const SizedBox(height: 16),
          _WaitModeCoachCard(
            enabled: _waitModeEnabled,
            completedLoops: _completedLoops,
            targetLoops: _targetLoops,
            onToggleEnabled: () {
              setState(() {
                _waitModeEnabled = !_waitModeEnabled;
              });
            },
            onMarkLoopDone: () {
              setState(() {
                _completedLoops = (_completedLoops + 1).clamp(0, _targetLoops);
              });
            },
            onResetLoops: () {
              setState(() {
                _completedLoops = 0;
              });
            },
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

  int _suggestLoopTarget(DailyTask task) {
    if (task.expectedEventTimeline.length >= 4) {
      return 3;
    }
    if (task.expectedNotes.length >= 3) {
      return 3;
    }
    return 2;
  }

  Future<void> _loadAdaptiveSession() async {
    try {
      final session = await widget.apiClient.getPracticeSessionForDay(
        widget.dayPlan.dayNumber,
      );
      final focusBlock = _focusPracticeBlock(session);
      if (!mounted) {
        return;
      }

      setState(() {
        _adaptiveSession = session;
        if (focusBlock?.recommendedBpm != null) {
          _practiceBpm = focusBlock!.recommendedBpm!;
        }
        if (focusBlock != null) {
          _targetLoops = focusBlock.loopTarget;
          _waitModeEnabled = focusBlock.supportsWaitMode;
        }
      });
    } catch (_) {
      // Keep heuristic defaults when adaptive session data is unavailable.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAdaptiveSession = false;
        });
      }
    }
  }

  PracticeBlock? _focusPracticeBlock(PracticeSession? session) {
    if (session == null) {
      return null;
    }
    for (final block in session.blocks) {
      if (block.status == 'focus') {
        return block;
      }
    }
    for (final block in session.blocks) {
      if (block.blockType == 'rhythm_call_response') {
        return block;
      }
    }
    return session.blocks.isEmpty ? null : session.blocks.first;
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

class _AdaptiveSessionCard extends StatelessWidget {
  const _AdaptiveSessionCard({
    required this.session,
    required this.focusBlock,
    required this.isLoading,
  });

  final PracticeSession session;
  final PracticeBlock? focusBlock;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adaptive Practice Engine',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(session.recommendedFocusAr),
          if (session.adaptationReasonAr != null) ...[
            const SizedBox(height: 8),
            Text(session.adaptationReasonAr!),
          ],
          if (focusBlock != null) ...[
            const SizedBox(height: 10),
            Text(
              'Focus block: ${focusBlock!.title} • ${focusBlock!.recommendedBpm ?? '-'} BPM • ${focusBlock!.loopTarget} loops',
            ),
          ],
          if (isLoading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _InteractivePracticeToolsCard extends StatelessWidget {
  const _InteractivePracticeToolsCard({
    required this.practiceTask,
    required this.bpm,
    required this.waitModeEnabled,
    required this.completedLoops,
    required this.targetLoops,
    this.adaptationReasonAr,
  });

  final DailyTask practiceTask;
  final int bpm;
  final bool waitModeEnabled;
  final int completedLoops;
  final int targetLoops;
  final String? adaptationReasonAr;

  @override
  Widget build(BuildContext context) {
    final timeline = practiceTask.expectedEventTimeline;
    final notes = practiceTask.expectedNotes.isEmpty
        ? timeline.map((event) => event.note).toSet().toList()
        : practiceTask.expectedNotes;

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive Practice Tools',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'هنا نحول التمرين من سماع عابر إلى loop واضحة: reference, response, ثم تكرار محسوب.',
          ),
          if (adaptationReasonAr != null && adaptationReasonAr!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              adaptationReasonAr!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'BPM $bpm'),
              _InfoChip(label: 'Loop $completedLoops/$targetLoops'),
              _InfoChip(label: waitModeEnabled ? 'Wait Mode On' : 'Free Flow'),
              if (practiceTask.fingeringHintId != null)
                _InfoChip(label: 'Fingering ${practiceTask.fingeringHintId!.toUpperCase()}'),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Focus Notes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notes
                  .map(
                    (note) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (timeline.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Visual Phrase Flow',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < timeline.length; index++) ...[
              _TimelineRow(
                stepNumber: index + 1,
                note: timeline[index].note,
                onsetSeconds: timeline[index].onsetSeconds,
                durationSeconds: timeline[index].durationSeconds,
              ),
              if (index < timeline.length - 1) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _WaitModeCoachCard extends StatelessWidget {
  const _WaitModeCoachCard({
    required this.enabled,
    required this.completedLoops,
    required this.targetLoops,
    required this.onToggleEnabled,
    required this.onMarkLoopDone,
    required this.onResetLoops,
  });

  final bool enabled;
  final int completedLoops;
  final int targetLoops;
  final VoidCallback onToggleEnabled;
  final VoidCallback onMarkLoopDone;
  final VoidCallback onResetLoops;

  @override
  Widget build(BuildContext context) {
    final finishedAllLoops = completedLoops >= targetLoops;

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Wait Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (_) => onToggleEnabled(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            enabled
                ? 'اسمع المرجع مرة، رد على الآلة، ثم علّم loop كمكتملة. بهذه الطريقة نحاكي call-and-response بدل التشغيل المستمر فقط.'
                : 'الوضع الحر مناسب عندما تريد تكرار الجملة بسرعة من غير توقف بين كل استجابة.',
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: targetLoops == 0 ? 0 : completedLoops / targetLoops,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            finishedAllLoops
                ? 'اكتملت loops المطلوبة. الآن سجّل محاولة نظيفة.'
                : 'الهدف الحالي: $completedLoops من $targetLoops loops نظيفة قبل التسجيل.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onMarkLoopDone,
                icon: const Icon(Icons.check_rounded),
                label: const Text('تمت الاستجابة'),
              ),
              OutlinedButton(
                onPressed: onResetLoops,
                child: const Text('إعادة الـ loop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stepNumber,
    required this.note,
    required this.onsetSeconds,
    required this.durationSeconds,
  });

  final int stepNumber;
  final String note;
  final double onsetSeconds;
  final double durationSeconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${onsetSeconds.toStringAsFixed(1)}s -> ${durationSeconds.toStringAsFixed(1)}s',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
