import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/shared/widgets/recorded_audio_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class AttemptDetailsScreen extends StatefulWidget {
  const AttemptDetailsScreen({
    super.key,
    required this.entry,
    this.apiClient,
  });

  final AttemptHistoryEntry entry;
  final SaxPathApiClient? apiClient;

  @override
  State<AttemptDetailsScreen> createState() => _AttemptDetailsScreenState();
}

class _AttemptDetailsScreenState extends State<AttemptDetailsScreen> {
  late AttemptHistoryEntry _entry;
  bool _isRequestingTeacherReview = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final recording = MockRecording(
      audioUrl: _entry.audioUrl,
      durationSeconds: _entry.durationSeconds,
      label: _entry.audioUrl.split(RegExp(r'[\\/]')).last,
      isRealRecording: !_entry.audioUrl.startsWith('mock://'),
      recordingId: _entry.recordingId,
      playbackUrl: _entry.audioUrl,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المحاولة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: 'اليوم ${_entry.dayNumber}',
            subtitle:
                'محاولة محفوظة بتاريخ ${_buildDateLabel(_entry.createdAt)}',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Pitch',
                    value: '${_entry.pitchAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Rhythm',
                    value: '${_entry.rhythmAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Completion',
                    value: '${_entry.completion}%',
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
                  'ملخص المحاولة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('المعرف: ${_entry.attemptId}'),
                const SizedBox(height: 6),
                Text('التمرين: ${_entry.exerciseId}'),
                const SizedBox(height: 6),
                Text('المدة: ${_entry.durationSeconds} ثانية'),
                const SizedBox(height: 6),
                Text('المسار: ${_entry.audioUrl}'),
                const SizedBox(height: 6),
                Text('حالة التسجيل: ${_recordingStatusLabel(recording)}'),
                if (_entry.recordingId != null) ...[
                  const SizedBox(height: 6),
                  Text('معرّف التسجيل: ${_entry.recordingId}'),
                ],
                if (_entry.retryReason != null) ...[
                  const SizedBox(height: 6),
                  Text('سبب إعادة المحاولة: ${_entry.retryReason}'),
                ],
                const SizedBox(height: 6),
                Text('مستوى الثقة: ${_entry.confidenceLabel}'),
                if (_entry.recommendedRetryBlock != null) ...[
                  const SizedBox(height: 6),
                  Text('بلوك الإعادة المقترح: ${_entry.recommendedRetryBlock}'),
                ],
                if (_entry.analysis != null) ...[
                  const SizedBox(height: 6),
                  Text('مصدر التحليل: ${_entry.analysis!.source}'),
                  const SizedBox(height: 6),
                  Text(
                    'ثقة التحليل: ${(_entry.analysis!.confidence * 100).round()}%',
                  ),
                ],
              ],
            ),
          ),
          if (_entry.masteryDelta.isNotEmpty) ...[
            const SizedBox(height: 16),
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                  'Mastery Delta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                  for (final delta in _entry.masteryDelta) ...[
                    Text(
                      '${delta.skill}: ${delta.previousScore}% -> ${delta.newScore}% (${delta.delta >= 0 ? '+' : ''}${delta.delta})',
                    ),
                    if (delta != _entry.masteryDelta.last)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
          ],
          if (_entry.teacherReview != null) ...[
            const SizedBox(height: 16),
            SaxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI + Teacher Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(_entry.teacherReview!.aiSummaryAr),
                  const SizedBox(height: 10),
                  for (final point in _entry.teacherReview!.focusPointsAr) ...[
                    Text('• $point'),
                    if (point != _entry.teacherReview!.focusPointsAr.last)
                      const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 10),
                  Text(_entry.teacherReview!.teacherPromptAr),
                  const SizedBox(height: 10),
                  Text(_entry.teacherReview!.queueEtaAr),
                  if (widget.apiClient != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _entry.teacherReview!.status == 'requested' ||
                              _isRequestingTeacherReview
                          ? null
                          : _requestTeacherReview,
                      child: Text(
                        _entry.teacherReview!.status == 'requested'
                            ? 'تم طلب مراجعة المدرس'
                            : _isRequestingTeacherReview
                                ? 'جارٍ إرسال الطلب...'
                                : 'اطلب مراجعة مدرس',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SaxCard(
            child: Text(_entry.feedbackAr),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Text(_entry.nextRecommendation),
          ),
          const SizedBox(height: 16),
          RecordedAudioCard(
            recording: recording,
            title: 'تشغيل التسجيل المحفوظ',
            caption:
                'يمكنك مراجعة التسجيل المرتبط بهذه المحاولة من الجهاز أو من الخادم إذا كانت النسخة المتاحة صالحة للتشغيل.',
          ),
        ],
      ),
    );
  }

  Future<void> _requestTeacherReview() async {
    final apiClient = widget.apiClient;
    if (apiClient == null || _isRequestingTeacherReview) {
      return;
    }

    setState(() {
      _isRequestingTeacherReview = true;
    });

    try {
      final updated = await apiClient.requestTeacherReview(_entry.attemptId);
      if (!mounted) {
        return;
      }

      setState(() {
        _entry = updated;
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

  String _buildDateLabel(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year/$month/$day - $hour:$minute';
  }

  String _recordingStatusLabel(MockRecording recording) {
    if (recording.isFallbackRecording) {
      return 'تجريبي للمراجعة فقط';
    }

    if (recording.hasLocalFileReference && recording.isUploadedToServer) {
      return 'محفوظ على الجهاز وعلى الخادم';
    }

    if (recording.isUploadedToServer) {
      return 'محفوظ على الخادم';
    }

    return 'محفوظ على الجهاز';
  }
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
