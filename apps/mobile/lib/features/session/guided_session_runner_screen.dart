import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/daily_plan.dart';
import 'package:saxpath_mobile/data/models/lesson.dart';
import 'package:saxpath_mobile/data/models/practice_session.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/practice/widgets/mock_recording_card.dart';
import 'package:saxpath_mobile/features/practice/widgets/rhythm_drill_card.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';
import 'package:saxpath_mobile/shared/widgets/metronome_card.dart';
import 'package:saxpath_mobile/shared/widgets/mock_playback_card.dart';
import 'package:saxpath_mobile/shared/widgets/note_staff_card.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_fingering_card.dart';
import 'package:saxpath_mobile/shared/widgets/video_masterclass_card.dart';
import 'package:saxpath_mobile/shared/audio/audio_analysis_service.dart';
import 'package:saxpath_mobile/shared/services/settings_scope.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart' show SaxType;

import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';

class GuidedSessionRunnerScreen extends StatefulWidget {
  const GuidedSessionRunnerScreen({
    super.key,
    required this.apiClient,
    required this.dayPlan,
  });

  final SaxPathApiClient apiClient;
  final DailyPlan dayPlan;

  @override
  State<GuidedSessionRunnerScreen> createState() =>
      _GuidedSessionRunnerScreenState();
}

class _GuidedSessionRunnerScreenState extends State<GuidedSessionRunnerScreen> {
  bool _isLoading = true;
  String? _loadingError;
  List<Lesson> _lessons = const [];
  List<PracticeBlock> _orderedBlocks = const [];
  Map<String, bool> _blockCompletion = {};
  int _currentBlockIndex = 0;
  int _practiceBpm = 60;

  final AudioAnalysisService _audioAnalysis = AudioAnalysisService();
  bool _isListening = false;
  AudioAnalysisResult? _latestAnalysis;

  @override
  void initState() {
    super.initState();
    _loadRunnerData();
  }

  @override
  void dispose() {
    _audioAnalysis.stopAnalysis();
    _audioAnalysis.dispose();
    super.dispose();
  }

  Future<void> _loadRunnerData() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        widget.apiClient.getPracticeSessionForDay(widget.dayPlan.dayNumber),
        widget.apiClient.getLessons(dayNumber: widget.dayPlan.dayNumber),
      ]);
      final session = results[0] as PracticeSession;
      final lessons = results[1] as List<Lesson>;
      final orderedBlocks = _orderedSessionBlocks(session.blocks);

      if (!mounted) return;

      setState(() {
        _orderedBlocks = orderedBlocks;
        _lessons = lessons;
        _blockCompletion = {
          for (final block in orderedBlocks) block.id: false,
        };
        _currentBlockIndex = 0;
      });

      await _resumeStateIfAvailable();
      _applyBlockDefaults(_orderedBlocks[_currentBlockIndex]);
    } catch (_) {
      if (mounted) setState(() => _loadingError = 'failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resumeStateIfAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'session_resume_${widget.dayPlan.dayNumber}';
    final savedIndex = prefs.getInt('${dayKey}_index');

    if (savedIndex != null && savedIndex < _orderedBlocks.length) {
      setState(() => _currentBlockIndex = savedIndex);
      for (var block in _orderedBlocks) {
        if (prefs.getBool('${dayKey}_block_${block.id}') ?? false) {
          _blockCompletion[block.id] = true;
        }
      }
    }
  }

  Future<void> _persistCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'session_resume_${widget.dayPlan.dayNumber}';
    await prefs.setInt('${dayKey}_index', _currentBlockIndex);
    for (var entry in _blockCompletion.entries) {
      await prefs.setBool('${dayKey}_block_${entry.key}', entry.value);
    }
  }

  void _applyBlockDefaults(PracticeBlock block) {
    final task = _practiceTaskForBlock(block);
    _practiceBpm = block.recommendedBpm ?? task.targetBpm ?? 60;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_loadingError != null) return const Scaffold(body: Center(child: Text('خطأ في التحميل')));

    final currentBlock = _orderedBlocks[_currentBlockIndex];
    final settings = SettingsScope.of(context);
    final selectedSaxType = settings.saxType;

    return Scaffold(
      appBar: AppBar(title: Text('جلسة اليوم - ${widget.dayPlan.dayNumber}')),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withValues(alpha: 0.05),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text('الخطوة ${_currentBlockIndex + 1} من ${_orderedBlocks.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentBlockIndex + 1) / _orderedBlocks.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Focused Active Block
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: KeyedSubtree(
                  key: ValueKey(currentBlock.id),
                  child: Column(
                    children: [
                      Text(
                        currentBlock.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepTeal),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildBlockContent(currentBlock, selectedSaxType),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Controller
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_currentBlockIndex > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: _goBack,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: _currentBlockIndex == _orderedBlocks.length - 1 ? 'إكمال وإنهاء' : 'فهمت، التالي',
                    onPressed: _goNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockContent(PracticeBlock block, SaxType selectedSaxType) {
    return switch (block.blockType) {
      'warm_up' => _buildWarmUpBlock(block),
      'note_fingering' => _buildNoteBlock(block, selectedSaxType),
      'rhythm_call_response' => _buildRhythmBlock(block),
      'record_check' => _buildRecordBlock(block, selectedSaxType),
      'rhythm_tap' => _buildRhythmDrillBlock(block, RhythmDrillType.tap),
      'rhythm_clap' => _buildRhythmDrillBlock(block, RhythmDrillType.clap),
      'rhythm_count' => _buildRhythmDrillBlock(block, RhythmDrillType.count),
      _ => _buildGenericBlock(block),
    };
  }

  Widget _buildRhythmDrillBlock(PracticeBlock block, RhythmDrillType type) {
    return RhythmDrillCard(
      type: type,
      title: block.title,
      targetCount: 8,
      onCompleted: () => setState(() => _blockCompletion[block.id] = true),
    );
  }

  Widget _buildWarmUpBlock(PracticeBlock block) {
    return SaxCard(child: Text(block.focusHintAr));
  }

  Widget _buildNoteBlock(PracticeBlock block, SaxType selectedSaxType) {
    final task = _practiceTaskForBlock(block);
    final note = task.expectedNotes.firstOrNull ?? 'G4';

    // Find the associated lesson video if any
    final lesson = _lessons.cast<Lesson?>().firstWhere((l) => l?.id.replaceAll('lesson_', 'task_') == block.id, orElse: () => null);
    final videoUrl = lesson?.videoUrl;

    return Column(
      children: [
        NoteStaffCard(
          noteLabel: note,
          highlightedIndex: _latestAnalysis?.isCorrect == true ? 0 : null,
        ),
        const SizedBox(height: 16),
        if (videoUrl != null)
          VideoMasterclassCard(title: 'شرح فيديو للمهمة', videoUrl: videoUrl)
        else
          _VideoPlaceholderCard(title: 'كيفية عزف نغمة $note'),
        const SizedBox(height: 16),
        if (_isListening)
          _ListeningIndicator(result: _latestAnalysis)
        else
          PrimaryButton(
            label: 'ابدأ الاستماع (اعزف ليسمعك التطبيق)',
            onPressed: () => _toggleListening(note),
          ),
        const SizedBox(height: 16),
        MockPlaybackCard(
          title: 'اسمع وطابق النغمة',
          caption: 'استمع للتردد الصحيح وحاول تقليده بنفس جودة الصوت.',
          accentLabel: note,
          pattern: PlaybackPattern.note,
          patternKey: note,
          durationSeconds: 10,
          saxType: selectedSaxType,
        ),
        const SizedBox(height: 16),
        SaxFingeringCard(noteLabel: note),
      ],
    );
  }

  Widget _buildRhythmBlock(PracticeBlock block) {
    return Column(
      children: [
        MetronomeCard(
          initialBpm: _practiceBpm,
          onBpmChanged: (val) => setState(() => _practiceBpm = val),
        ),
        const SizedBox(height: 16),
        const SaxCard(child: Text('تمرين إيقاعي: اتبع نبض الميترونوم وصفق مع العد.')),
      ],
    );
  }

  Widget _buildRecordBlock(PracticeBlock block, SaxType selectedSaxType) {
    final task = _practiceTaskForBlock(block);
    return Column(
      children: [
        MockPlaybackCard(
          title: 'Reference Phrase (With Band)',
          caption: 'اسمع المرجع مع الإيقاع، ثم كرر محاولتك.',
          accentLabel: task.title,
          pattern: PlaybackPattern.phrase,
          patternKey: task.id,
          durationSeconds: 14,
          includeBacking: true,
          saxType: selectedSaxType,
        ),
        const SizedBox(height: 16),
        MockRecordingCard(
          exerciseId: block.id,
          dayNumber: widget.dayPlan.dayNumber,
          onChanged: (r) {}, // Local state removed for cleanup
        ),
      ],
    );
  }

  Widget _buildGenericBlock(PracticeBlock block) {
    return SaxCard(child: Text(block.title));
  }

  void _toggleListening(String targetNote) async {
    if (_isListening) {
      await _audioAnalysis.stopAnalysis();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _latestAnalysis = null;
      });
      _audioAnalysis.startAnalysis(targetNote: targetNote);
      _audioAnalysis.analysisStream.listen((result) {
        if (!mounted) return;
        setState(() => _latestAnalysis = result);
        if (result.isCorrect) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted && _isListening) _goNext();
          });
        }
      });
    }
  }

  void _goBack() {
    _audioAnalysis.stopAnalysis();
    setState(() => _isListening = false);
    if (_currentBlockIndex > 0) {
      setState(() => _currentBlockIndex--);
      _applyBlockDefaults(_orderedBlocks[_currentBlockIndex]);
      _persistCurrentState();
    }
  }

  void _goNext() {
    _audioAnalysis.stopAnalysis();
    setState(() => _isListening = false);
    setState(() => _blockCompletion[_orderedBlocks[_currentBlockIndex].id] = true);

    if (_currentBlockIndex < _orderedBlocks.length - 1) {
      setState(() => _currentBlockIndex++);
      _applyBlockDefaults(_orderedBlocks[_currentBlockIndex]);
      _persistCurrentState();
    } else {
      // AUTOMATION: Auto-complete day and return with success
      _finishSession();
    }
  }

  void _finishSession() {
    final progress = AppProgressScope.of(context);
    progress.completeDay(widget.dayPlan.dayNumber);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 مبروك يا بطل!', textAlign: TextAlign.center),
        content: const Text('لقد أتممت جلسة اليوم بنجاح وفتحت مرحلة جديدة في الخريطة.', textAlign: TextAlign.center),
        actions: [
          PrimaryButton(
            label: 'العودة للخريطة',
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home/map
            },
          ),
        ],
      ),
    );
  }

  DailyTask _practiceTaskForBlock(PracticeBlock block) {
    return widget.dayPlan.tasks.firstWhere((t) => t.blockType == block.blockType, orElse: () => widget.dayPlan.tasks.first);
  }

  List<PracticeBlock> _orderedSessionBlocks(List<PracticeBlock> blocks) => blocks;
}

class _ListeningIndicator extends StatelessWidget {
  final AudioAnalysisResult? result;
  const _ListeningIndicator({this.result});

  @override
  Widget build(BuildContext context) {
    final isCorrect = result?.isCorrect ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withValues(alpha: 0.1) : AppColors.deepTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCorrect ? Colors.green : AppColors.deepTeal),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.graphic_eq_rounded,
            color: isCorrect ? Colors.green : AppColors.deepTeal,
          ),
          const SizedBox(width: 12),
          Text(
            isCorrect ? 'نغمة صحيحة! جاري الانتقال...' : (result == null ? 'أنا أسمعك الآن... اعزف!' : 'عزفت نغمة: ${result!.note}'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : AppColors.deepTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlaceholderCard extends StatelessWidget {
  final String title;
  const _VideoPlaceholderCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_filled_rounded, size: 48, color: AppColors.deepTeal),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('فيديو توضيحي (قريباً في V4)', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
