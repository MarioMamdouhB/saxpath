import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/features/shell/main_app_shell.dart';
import 'package:saxpath_mobile/shared/education/jazz_curriculum_models.dart';
import 'package:saxpath_mobile/shared/education/services/feedback_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/recorded_audio_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import '../progress/progress_screen.dart';
import 'results_completion.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.evaluation,
    required this.apiClient,
    required this.dayNumber,
    required this.exerciseId,
    required this.recording,
    FeedbackService? feedbackService,
  }) : feedbackService = feedbackService ?? const FeedbackService();

  final AttemptEvaluation evaluation;
  final SaxPathApiClient apiClient;
  final int dayNumber;
  final String exerciseId;
  final MockRecording recording;
  final FeedbackService feedbackService;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  late AttemptEvaluation _evaluation;
  bool _isRequestingTeacherReview = false;
  bool _showStageCelebration = false;

  @override
  void initState() {
    super.initState();
    _evaluation = widget.evaluation;
    _scheduleScrollReset();
    _checkStageCompletion();
  }

  void _checkStageCompletion() {
    // Stage completion logic based on the day number
    final stageDays = {
      10: 'الأساسيات الأولى',
      14: 'الأوكتاف الثاني والسلم الكامل',
    };

    if (stageDays.containsKey(widget.dayNumber) && widget.evaluation.completion >= 70) {
      setState(() {
        _showStageCelebration = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressController = AppProgressScope.of(context);
    final audioFeedback = widget.feedbackService.generateSync(
      exerciseId: widget.exerciseId,
      dayNumber: widget.dayNumber,
      recording: widget.recording,
      evaluation: _evaluation,
    );
    final coachingPoints = _buildCoachingPoints(
      evaluation: _evaluation,
      recording: widget.recording,
      dayNumber: widget.dayNumber,
    );
    final completionState = buildResultsCompletionState(
      evaluation: _evaluation,
      recording: widget.recording,
      dayNumber: widget.dayNumber,
      totalDays: progressController.totalDays,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          if (_showStageCelebration) ...[
            _StageCelebrationCard(
              stageName: widget.dayNumber == 10
                ? 'الأساسيات الأولى'
                : 'الأوكتاف الثاني والسلم الكامل',
            ),
            const SizedBox(height: 16),
          ],
          const SectionTitle(
            title: 'نتيجة اليوم',
            subtitle: 'خذ القرار أولاً، ثم راجع التفاصيل التي تساعدك على الخطوة التالية.',
          ),
          const SizedBox(height: 16),
          _DecisionBannerCard(
            evaluation: _evaluation,
            recording: widget.recording,
            completionState: completionState,
            dayNumber: widget.dayNumber,
          ),
          const SizedBox(height: 16),
          _LabeledMessageCard(
            title: 'ما نجح',
            body: _whatWorkedMessage(_evaluation),
          ),
          const SizedBox(height: 16),
          _LabeledMessageCard(
            title: 'ما يحتاج إعادة',
            body: _whatNeedsRetryMessage(_evaluation),
          ),
          const SizedBox(height: 16),
          _LabeledMessageCard(
            title: 'الخطوة التالية الآن',
            body: _evaluation.nextRecommendation,
          ),
          if (_evaluation.confidenceLabel == 'low') ...[
            const SizedBox(height: 16),
            const _LabeledMessageCard(
              title: 'ملاحظة مهمة',
              body:
                  'التحليل الصوتي الحالي منخفض الثقة، لذلك اعتبر الملاحظات إرشادية ولا تمنعك من إكمال اليوم.',
            ),
          ],
          const SizedBox(height: 16),
          SaxCard(
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'النغمة',
                    value: '${_evaluation.pitchAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'الإيقاع',
                    value: '${_evaluation.rhythmAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'الإكمال',
                    value: '${_evaluation.completion}%',
                  ),
                ),
              ],
            ),
          ),
          if (_evaluation.analysis != null) ...[
            const SizedBox(height: 16),
            SaxCard(
              child: _AnalysisSummary(evaluation: _evaluation),
            ),
          ],
          if (_evaluation.retryReason != null) ...[
            const SizedBox(height: 16),
            SaxCard(
              child: Text(retryReasonMessage(_evaluation.retryReason)),
            ),
          ],
          if (_evaluation.teacherReview != null) ...[
            const SizedBox(height: 16),
            _TeacherReviewCard(
              review: _evaluation.teacherReview!,
              isRequesting: _isRequestingTeacherReview,
              onRequestReview: _requestTeacherReview,
            ),
          ],
          const SizedBox(height: 16),
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ملاحظات الصوت والتحليل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  audioFeedback.summary,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                for (var index = 0;
                    index < audioFeedback.insights.length;
                    index++) ...[
                  _AudioFeedbackInsightCard(
                      insight: audioFeedback.insights[index]),
                  if (index < audioFeedback.insights.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
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
                  'خطواتك التالية',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < coachingPoints.length; index++) ...[
                  _CoachingPoint(
                    title: coachingPoints[index].title,
                    body: coachingPoints[index].body,
                  ),
                  if (index < coachingPoints.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
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
                  'ملخص التسجيل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('الملف: ${widget.recording.label}'),
                const SizedBox(height: 6),
                Text('المدة: ${widget.recording.durationSeconds} ثانية'),
                const SizedBox(height: 6),
                Text('المسار: ${widget.recording.audioUrl}'),
                const SizedBox(height: 6),
                Text(
                  widget.recording.isRealRecording
                      ? 'نوع التسجيل: حقيقي من الميكروفون'
                      : 'نوع التسجيل: تجريبي',
                ),
                const SizedBox(height: 6),
                Text('حالة الحفظ: ${_recordingStorageLabel(widget.recording)}'),
                if (widget.recording.recordingId != null) ...[
                  const SizedBox(height: 6),
                  Text('معرّف التسجيل: ${widget.recording.recordingId}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          RecordedAudioCard(
            recording: widget.recording,
            title: 'الاستماع إلى تسجيلك',
            caption:
                'يمكنك مراجعة نفس التسجيل من الجهاز أو من الخادم قبل فتح اليوم التالي.',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: completionState.primaryActionLabel,
            onPressed: () async {
              if (!completionState.canCompleteDay) {
                Navigator.of(context).pop();
                return;
              }

              try {
                final serverProgress =
                    await widget.apiClient.completeDay(widget.dayNumber);
                await progressController.syncFromSnapshot(
                  serverProgress.completedDays,
                  currentStreakDays: serverProgress.currentStreakDays,
                  lastCompletedAt: serverProgress.lastCompletedAt,
                  replace: true,
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تعذر حفظ التقدم على الخادم حالياً. لن يتم فتح اليوم التالي قبل نجاح الحفظ.',
                      ),
                    ),
                  );
                }
                return;
              }

              try {
                await widget.apiClient.trackEvent(
                  eventName: 'day_complete',
                  dayNumber: widget.dayNumber,
                  attemptId: _evaluation.attemptId,
                  metadata: {
                    'next_day_number': completionState.nextDayNumber,
                    'completion': _evaluation.completion,
                    'analysis_source': _evaluation.analysis?.source,
                  },
                );
              } catch (_) {
                // Do not block unlocked progress when analytics is down.
              }

              if (!context.mounted) {
                return;
              }

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => MainAppShell(
                    apiClient: widget.apiClient,
                  ),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('أعد التمرين الآن'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProgressScreen(apiClient: widget.apiClient),
                      ),
                    );
                  },
                  child: const Text('كل النتائج'),
                ),
              ),
            ],
          ),
        ],
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

  Future<void> _requestTeacherReview() async {
    if (_isRequestingTeacherReview) {
      return;
    }

    setState(() {
      _isRequestingTeacherReview = true;
    });

    try {
      final updated =
          await widget.apiClient.requestTeacherReview(_evaluation.attemptId);
      if (!mounted) {
        return;
      }

      setState(() {
        _evaluation = _evaluation.copyWith(
          teacherReview: updated.teacherReview,
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر طلب مراجعة المدرس حالياً. حاول مرة أخرى.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingTeacherReview = false;
        });
      }
    }
  }

  String _whatWorkedMessage(AttemptEvaluation evaluation) {
    if (evaluation.analysis != null && evaluation.analysis!.toneScore >= 75) {
      return 'الصوت الأساسي ثابت، ومعه أساس جيد لبناء الجملة التالية.';
    }
    if (evaluation.pitchAccuracy >= 75 && evaluation.rhythmAccuracy >= 75) {
      return 'الدقة العامة متماسكة، وده معناه إن حلقة التدريب بدأت تثبت.';
    }
    return evaluation.feedbackAr;
  }

  String _whatNeedsRetryMessage(AttemptEvaluation evaluation) {
    if (evaluation.retryReason == null &&
        evaluation.recommendedRetryBlock == null) {
      return 'لا توجد نقطة إعادة حرجة الآن. يمكنك تثبيت نفس الجودة ثم المتابعة.';
    }

    return switch (evaluation.recommendedRetryBlock) {
      'warm_up' => 'ارجع إلى warm-up وثبّت النفس والصوت قبل إعادة الجملة.',
      'note_fingering' =>
        'ركز على note/fingering: النغمة أو انتقالات الأصابع ما زالت تحتاج إعادة هادئة.',
      'rhythm_call_response' =>
        'أعد جزء rhythm/call-and-response بسرعة أبطأ قبل التسجيل التالي.',
      'record_check' =>
        'كرر التسجيل مرة أوضح وأطول قليلاً حتى يظهر الأداء الحقيقي بشكل أدق.',
      _ => retryReasonMessage(evaluation.retryReason),
    };
  }
}

class _TeacherReviewCard extends StatelessWidget {
  const _TeacherReviewCard({
    required this.review,
    required this.isRequesting,
    required this.onRequestReview,
  });

  final TeacherReview review;
  final bool isRequesting;
  final Future<void> Function() onRequestReview;

  @override
  Widget build(BuildContext context) {
    final isRequested = review.status == 'requested';

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI + Teacher Review',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(review.aiSummaryAr),
          const SizedBox(height: 10),
          for (var index = 0; index < review.focusPointsAr.length; index++) ...[
            Text('${index + 1}. ${review.focusPointsAr[index]}'),
            if (index < review.focusPointsAr.length - 1)
              const SizedBox(height: 6),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(review.teacherPromptAr),
          ),
          const SizedBox(height: 10),
          Text(review.queueEtaAr),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isRequested || isRequesting ? null : onRequestReview,
            child: Text(
              isRequested
                  ? 'تم طلب مراجعة المدرس'
                  : isRequesting
                      ? 'جارٍ إرسال الطلب...'
                      : 'اطلب مراجعة مدرس',
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionBannerCard extends StatelessWidget {
  const _DecisionBannerCard({
    required this.evaluation,
    required this.recording,
    required this.completionState,
    required this.dayNumber,
  });

  final AttemptEvaluation evaluation;
  final MockRecording recording;
  final ResultsCompletionState completionState;
  final int dayNumber;

  @override
  Widget build(BuildContext context) {
    final accentColor = _decisionAccentColor(
      evaluation: evaluation,
      recording: recording,
      completionState: completionState,
    );

    return SaxCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              accentColor,
              AppColors.deepTeal,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _decisionEyebrow(
                  evaluation: evaluation,
                  recording: recording,
                  completionState: completionState,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _decisionTitle(
                evaluation: evaluation,
                recording: recording,
                completionState: completionState,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              completionState.message,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DecisionPill(
                  label: 'نوع التسجيل',
                  value: recording.isRealRecording ? 'حقيقي' : 'تجريبي',
                ),
                _DecisionPill(
                  label: 'الإكمال',
                  value: '${evaluation.completion}%',
                ),
                _DecisionPill(
                  label: 'اليوم',
                  value: '$dayNumber',
                ),
                _DecisionPill(
                  label: completionState.canCompleteDay
                      ? 'الخطوة التالية'
                      : 'الهدف التالي',
                  value: completionState.canCompleteDay
                      ? '${completionState.nextDayNumber}'
                      : '70%+',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionPill extends StatelessWidget {
  const _DecisionPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledMessageCard extends StatelessWidget {
  const _LabeledMessageCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(height: 1.45),
          ),
        ],
      ),
    );
  }
}

List<_CoachingAdvice> _buildCoachingPoints({
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required int dayNumber,
}) {
  final points = <_CoachingAdvice>[];

  if (recording.durationSeconds < 6) {
    points.add(
      const _CoachingAdvice(
        title: 'طوّل التسجيل قليلاً',
        body:
            'ابدأ بعدّ داخلي واضح ثم اترك لنفسك وقتاً كافياً لإكمال الجملة كاملة قبل الإيقاف.',
      ),
    );
  }

  if (evaluation.rhythmAccuracy < 70) {
    points.add(
      const _CoachingAdvice(
        title: 'ثبّت التوقيت أولاً',
        body:
            'ارجع إلى الميترونوم، وصفّق أو عدّ الجملة مرة بدون عزف، ثم أعد التسجيل على سرعة أبطأ.',
      ),
    );
  }

  if (evaluation.pitchAccuracy < 75) {
    points.add(
      const _CoachingAdvice(
        title: 'ركّز على ثبات النغمة',
        body:
            'أعد تشغيل النموذج الصوتي، ثم جرّب نغمة طويلة قبل الجملة حتى يثبت الهواء وشكل الفم.',
      ),
    );
  }

  if (points.isEmpty) {
    points.add(
      _CoachingAdvice(
        title: 'جاهز للخطوة التالية',
        body: dayNumber >= 6
            ? 'أداؤك متماسك. كرر الجملة مرتين بنفس الجودة قبل الانتقال حتى تثبت الثقة.'
            : 'أداؤك متماسك. ارفع التحدي تدريجياً مع الحفاظ على نفس الثبات في النغمة والتوقيت.',
      ),
    );
  }

  points.add(
    _CoachingAdvice(
      title: 'هدف المحاولة القادمة',
      body: evaluation.nextRecommendation,
    ),
  );

  return points.take(3).toList();
}

class _AnalysisSummary extends StatelessWidget {
  const _AnalysisSummary({
    required this.evaluation,
  });

  final AttemptEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final analysis = evaluation.analysis!;
    final notes = analysis.detectedNotes
        .take(4)
        .map(
            (note) => '${note.note} (${note.frequencyHz.toStringAsFixed(1)}Hz)')
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل التحليل الصوتي',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('المصدر: ${_analysisSourceLabel(analysis.source)}'),
        const SizedBox(height: 6),
        Text('الثقة: ${(analysis.confidence * 100).round()}%'),
        const SizedBox(height: 6),
        Text(
          notes.isEmpty
              ? 'النغمات المكتشفة: غير كافية'
              : 'النغمات المكتشفة: $notes',
        ),
        const SizedBox(height: 6),
        Text('أخطاء التوقيت المكتشفة: ${analysis.timingErrors.length}'),
      ],
    );
  }
}

String _analysisSourceLabel(String source) {
  return switch (source) {
    'audio_engine' => 'Audio Engine فعلي',
    'demo_mode' => 'وضع العرض',
    'deterministic_mock_fallback' => 'تحليل احتياطي تجريبي',
    'deterministic_mock' => 'تحليل تجريبي ثابت',
    _ => source,
  };
}

Color _decisionAccentColor({
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required ResultsCompletionState completionState,
}) {
  if (completionState.canCompleteDay) {
    return AppColors.navyLight;
  }

  if (!recording.isRealRecording) {
    return AppColors.muted;
  }

  if (evaluation.retryReason != null || evaluation.completion < 70) {
    return AppColors.navyLight;
  }

  return AppColors.deepTeal;
}

String _decisionEyebrow({
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required ResultsCompletionState completionState,
}) {
  if (completionState.canCompleteDay) {
    return 'جاهز للمتابعة';
  }

  if (!recording.isRealRecording) {
    return 'مراجعة فقط';
  }

  if (evaluation.retryReason != null) {
    return 'إعادة مطلوبة';
  }

  if (evaluation.completion < 70) {
    return 'أقل من الحد المطلوب';
  }

  return 'يحتاج محاولة أخرى';
}

String _decisionTitle({
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required ResultsCompletionState completionState,
}) {
  if (completionState.canCompleteDay) {
    return 'أنت جاهز لفتح اليوم ${completionState.nextDayNumber}';
  }

  if (!recording.isRealRecording) {
    return 'شاهد النتيجة ثم أعد التسجيل الحقيقي';
  }

  if (evaluation.retryReason == 'rhythm_needs_work') {
    return 'ثبّت التوقيت قبل فتح اليوم التالي';
  }

  if (evaluation.retryReason == 'pitch_needs_work') {
    return 'ثبّت النغمة قبل فتح اليوم التالي';
  }

  if (evaluation.completion < 70) {
    return 'الإكمال الحالي لا يكفي للفتح بعد';
  }

  return 'أعد المحاولة مرة أخرى';
}

String _recordingStorageLabel(MockRecording recording) {
  if (recording.isFallbackRecording) {
    return 'تجريبي للمراجعة فقط';
  }

  if (recording.hasLocalFileReference && recording.isUploadedToServer) {
    return 'محفوظ على الجهاز وعلى الخادم';
  }

  if (recording.isUploadedToServer) {
    return 'محفوظ على الخادم';
  }

  return 'محفوظ على الجهاز فقط';
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

class _CoachingPoint extends StatelessWidget {
  const _CoachingPoint({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(body),
      ],
    );
  }
}

class _AudioFeedbackInsightCard extends StatelessWidget {
  const _AudioFeedbackInsightCard({
    required this.insight,
  });

  final AudioFeedbackInsight insight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${audioFeedbackIssueLabel(insight.issue)} · ${insight.score}%',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'الفئة: ${feedbackCategoryLabel(insight.category)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(insight.musicalExplanation),
        const SizedBox(height: 8),
        Text(
          insight.recommendedFix,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (insight.nextExerciseId != null) ...[
          const SizedBox(height: 6),
          Text(
            'التمرين التالي: ${insight.nextExerciseId}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoachingAdvice {
  const _CoachingAdvice({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _StageCelebrationCard extends StatelessWidget {
  final String stageName;

  const _StageCelebrationCard({required this.stageName});

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber[300]!, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '🎉 إنجاز عظيم!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Text(
              'لقد أكملت بنجاح مرحلة:',
              style: TextStyle(fontSize: 16, color: Colors.brown[700]),
            ),
            const SizedBox(height: 4),
            Text(
              stageName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepTeal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'أنت الآن جاهز للانتقال إلى تحديات أكثر إثارة في المرحلة القادمة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
