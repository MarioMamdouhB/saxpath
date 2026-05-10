import 'package:saxpath_mobile/data/models/attempt_evaluation.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';

class ResultsCompletionState {
  const ResultsCompletionState({
    required this.canCompleteDay,
    required this.nextDayNumber,
    required this.primaryActionLabel,
    required this.message,
  });

  final bool canCompleteDay;
  final int nextDayNumber;
  final String primaryActionLabel;
  final String message;
}

ResultsCompletionState buildResultsCompletionState({
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required int dayNumber,
  required int totalDays,
}) {
  final nextDayNumber = dayNumber < totalDays ? dayNumber + 1 : dayNumber;
  final canCompleteDay = recording.isRealRecording &&
      recording.durationSeconds >= 6 &&
      evaluation.completion >= 70 &&
      evaluation.retryReason == null;

  return ResultsCompletionState(
    canCompleteDay: canCompleteDay,
    nextDayNumber: nextDayNumber,
    primaryActionLabel: canCompleteDay
        ? dayNumber < totalDays
            ? 'فتح اليوم $nextDayNumber'
            : 'العودة إلى الخطة'
        : 'أعد التسجيل',
    message: _completionGateMessage(
      canCompleteDay: canCompleteDay,
      recording: recording,
      evaluation: evaluation,
      dayNumber: dayNumber,
      totalDays: totalDays,
      nextDayNumber: nextDayNumber,
    ),
  );
}

String _completionGateMessage({
  required bool canCompleteDay,
  required AttemptEvaluation evaluation,
  required MockRecording recording,
  required int dayNumber,
  required int totalDays,
  required int nextDayNumber,
}) {
  if (!recording.isRealRecording) {
    return 'هذه محاولة تجريبية صالحة للمراجعة فقط. افتح التسجيل الحقيقي حتى يتم حفظ اليوم وفتح اليوم التالي.';
  }

  if (recording.durationSeconds < 6) {
    return 'التسجيل أقصر من المطلوب لإكمال اليوم. أعد المحاولة لمدة لا تقل عن 6 ثوان.';
  }

  if (evaluation.completion < 70) {
    return 'النتيجة الحالية تحتاج إعادة محاولة قبل فتح اليوم التالي. الهدف الأدنى للإكمال هو 70%.';
  }

  if (evaluation.retryReason != null) {
    return retryReasonMessage(evaluation.retryReason);
  }

  if (!canCompleteDay) {
    return 'أعد المحاولة مرة أخرى قبل حفظ اليوم.';
  }

  return dayNumber < totalDays
      ? 'المحاولة مؤهلة للإكمال. عند المتابعة سيتم فتح اليوم $nextDayNumber في التقدم المحفوظ.'
      : 'المحاولة مؤهلة للإكمال. هذا هو آخر يوم في الأسبوع الأول.';
}

String retryReasonMessage(String? retryReason) {
  return switch (retryReason) {
    'recording_too_short' =>
      'التسجيل قصير جدًا للتحليل بثقة. أعد التسجيل لمدة 6 ثوان على الأقل.',
    'low_confidence_analysis' =>
      'التحليل غير واثق من الملف. جرّب التسجيل في مكان أهدأ وبقرب مناسب من الميكروفون.',
    'pitch_needs_work' =>
      'سبب إعادة المحاولة: ثبات النغمة يحتاج تمرين Tone/Drone قبل فتح اليوم التالي.',
    'rhythm_needs_work' =>
      'سبب إعادة المحاولة: التوقيت يحتاج تمرين إيقاعي بسرعة أبطأ قبل فتح اليوم التالي.',
    'completion_below_threshold' =>
      'سبب إعادة المحاولة: نسبة الإكمال أقل من الحد المطلوب لفتح اليوم التالي.',
    _ => 'هذه المحاولة تحتاج إعادة تسجيل قبل فتح اليوم التالي.',
  };
}
