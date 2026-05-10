import 'package:flutter/material.dart';

import 'package:saxpath_mobile/data/models/attempt_history_entry.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/shared/widgets/recorded_audio_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class AttemptDetailsScreen extends StatelessWidget {
  const AttemptDetailsScreen({
    super.key,
    required this.entry,
  });

  final AttemptHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final recording = MockRecording(
      audioUrl: entry.audioUrl,
      durationSeconds: entry.durationSeconds,
      label: entry.audioUrl.split(RegExp(r'[\\/]')).last,
      isRealRecording: !entry.audioUrl.startsWith('mock://'),
      recordingId: entry.recordingId,
      playbackUrl: entry.audioUrl,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المحاولة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: 'اليوم ${entry.dayNumber}',
            subtitle:
                'محاولة محفوظة بتاريخ ${_buildDateLabel(entry.createdAt)}',
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Pitch',
                    value: '${entry.pitchAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Rhythm',
                    value: '${entry.rhythmAccuracy}%',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Completion',
                    value: '${entry.completion}%',
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
                Text('المعرف: ${entry.attemptId}'),
                const SizedBox(height: 6),
                Text('التمرين: ${entry.exerciseId}'),
                const SizedBox(height: 6),
                Text('المدة: ${entry.durationSeconds} ثانية'),
                const SizedBox(height: 6),
                Text('المسار: ${entry.audioUrl}'),
                const SizedBox(height: 6),
                Text('حالة التسجيل: ${_recordingStatusLabel(recording)}'),
                if (entry.recordingId != null) ...[
                  const SizedBox(height: 6),
                  Text('معرّف التسجيل: ${entry.recordingId}'),
                ],
                if (entry.retryReason != null) ...[
                  const SizedBox(height: 6),
                  Text('سبب إعادة المحاولة: ${entry.retryReason}'),
                ],
                if (entry.analysis != null) ...[
                  const SizedBox(height: 6),
                  Text('مصدر التحليل: ${entry.analysis!.source}'),
                  const SizedBox(height: 6),
                  Text(
                    'ثقة التحليل: ${(entry.analysis!.confidence * 100).round()}%',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Text(entry.feedbackAr),
          ),
          const SizedBox(height: 16),
          SaxCard(
            child: Text(entry.nextRecommendation),
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
