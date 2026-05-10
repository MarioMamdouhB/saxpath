import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/recorded_audio_card.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class MockRecordingCard extends StatefulWidget {
  const MockRecordingCard({
    super.key,
    required this.exerciseId,
    required this.dayNumber,
    required this.onChanged,
  });

  final String exerciseId;
  final int dayNumber;
  final ValueChanged<MockRecording?> onChanged;

  @override
  State<MockRecordingCard> createState() => _MockRecordingCardState();
}

class _MockRecordingCardState extends State<MockRecordingCard> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRecording = false;
  bool _isPreparing = false;
  bool _isFallbackAvailable = false;
  String? _statusMessage;
  MockRecording? _recording;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(12, (index) {
      final active =
          _isRecording ? index <= (_elapsedSeconds % 12) : _recording != null;
      final height = 12.0 + ((index % 4) * 8);

      return Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: active ? height + 6 : height,
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      );
    });

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التسجيل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(_statusMessage ?? _statusLabel()),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isPreparing
                    ? null
                    : (_isRecording ? _stopRecording : _startRecording),
                icon: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                ),
                label: Text(
                  _isPreparing
                      ? 'جارٍ التحضير...'
                      : _isRecording
                          ? 'إيقاف التسجيل'
                          : 'ابدأ التسجيل',
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: (_isRecording || _recording != null)
                    ? _resetRecording
                    : null,
                child: const Text('مسح'),
              ),
            ],
          ),
          if (_showFallbackAction) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'استخدم تسجيلًا تجريبيًا للمراجعة',
              onPressed: _createFallbackRecording,
            ),
            const SizedBox(height: 8),
            const Text(
              'لو التسجيل الحقيقي متعذر على هذا الجهاز أو على الويب، سيُنشأ تسجيل تجريبي للمراجعة فقط ولن يفتح اليوم التالي.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'المدة: ${_formatDuration(_elapsedSeconds)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (_recording != null) ...[
            const SizedBox(height: 8),
            Text('الملف: ${_recording!.label}'),
            const SizedBox(height: 16),
            RecordedAudioCard(
              recording: _recording!,
              title: 'مراجعة التسجيل',
              caption:
                  'استمع إلى التسجيل الذي التقطه الميكروفون قبل إرسال المحاولة للتحليل.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    setState(() {
      _isPreparing = true;
      _statusMessage = null;
    });

    if (kIsWeb) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparing = false;
        _isFallbackAvailable = true;
        _statusMessage =
            'التسجيل الحقيقي على الويب غير مستقر حالياً في هذا النموذج. استخدم التسجيل التجريبي للمتابعة أو جرّب من التطبيق المكتبي.';
      });
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparing = false;
        _isFallbackAvailable = true;
        _statusMessage =
            'لم يتم منح إذن الميكروفون بعد. يمكنك السماح به أو استخدام تسجيل تجريبي للمراجعة الآن.';
      });
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final fileName =
          'day_${widget.dayNumber.toString().padLeft(2, '0')}_${widget.exerciseId}.wav';
      final path = '${directory.path}${Platform.pathSeparator}$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparing = false;
        _isFallbackAvailable = true;
        _statusMessage =
            'تعذر بدء التسجيل الحقيقي على هذا الجهاز حالياً. استخدم التسجيل التجريبي للمراجعة فقط.';
      });
      return;
    }

    _timer?.cancel();
    setState(() {
      _isPreparing = false;
      _isRecording = true;
      _isFallbackAvailable = false;
      _elapsedSeconds = 0;
      _recording = null;
      _statusMessage = 'جارٍ تسجيل محاولة حقيقية من الميكروفون.';
    });
    widget.onChanged(null);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  Future<void> _stopRecording() async {
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isFallbackAvailable = true;
        _statusMessage =
            'تعذر إنهاء التسجيل وحفظ الملف. يمكنك المحاولة مجددًا أو استخدام تسجيل تجريبي للمراجعة.';
      });
      return;
    }

    _timer?.cancel();
    final safeDuration = _elapsedSeconds == 0 ? 1 : _elapsedSeconds;

    if (!mounted) {
      return;
    }

    if (path == null) {
      setState(() {
        _isRecording = false;
        _isFallbackAvailable = true;
        _statusMessage =
            'لم يتم حفظ التسجيل. جرّب مرة أخرى أو استخدم تسجيلًا تجريبيًا للمراجعة.';
      });
      return;
    }

    final label = path.split(Platform.pathSeparator).last;
    final recording = MockRecording(
      audioUrl: path,
      durationSeconds: safeDuration,
      label: label,
      isRealRecording: true,
    );

    setState(() {
      _isRecording = false;
      _isFallbackAvailable = false;
      _elapsedSeconds = safeDuration;
      _recording = recording;
      _statusMessage = 'تم حفظ تسجيل حقيقي ويمكنك الآن إرسال المحاولة للتحليل.';
    });

    widget.onChanged(recording);
  }

  Future<void> _resetRecording() async {
    _timer?.cancel();

    String? statusMessage;
    var canClearState = true;

    if (_isRecording) {
      try {
        await _recorder.cancel();
      } catch (_) {
        canClearState = false;
        statusMessage =
            'تعذر إلغاء التسجيل الحالي. أوقف التسجيل ثم حاول المسح مرة أخرى.';
      }
    }

    if (canClearState) {
      final existingPath = _recording?.audioUrl;
      if (existingPath != null &&
          !existingPath.startsWith('mock://') &&
          !existingPath.startsWith('/api/') &&
          !existingPath.startsWith('http://') &&
          !existingPath.startsWith('https://')) {
        try {
          final file = File(existingPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          statusMessage = 'تم مسح الحالة لكن تعذر حذف ملف التسجيل من الجهاز.';
        }
      }
    }

    if (!mounted) {
      return;
    }

    if (!canClearState) {
      setState(() {
        _statusMessage = statusMessage;
      });
      return;
    }

    setState(() {
      _isPreparing = false;
      _isRecording = false;
      _isFallbackAvailable = false;
      _elapsedSeconds = 0;
      _recording = null;
      _statusMessage = statusMessage;
    });
    widget.onChanged(null);
  }

  bool get _showFallbackAction =>
      !_isRecording &&
      !_isPreparing &&
      _recording == null &&
      (_isFallbackAvailable || kIsWeb);

  void _createFallbackRecording() {
    final safeDuration = _elapsedSeconds >= 8 ? _elapsedSeconds : 8;
    final recording = MockRecording(
      audioUrl:
          'mock://day_${widget.dayNumber.toString().padLeft(2, '0')}/${widget.exerciseId}.wav',
      durationSeconds: safeDuration,
      label: 'fallback_day_${widget.dayNumber}.wav',
      isRealRecording: false,
    );

    setState(() {
      _isPreparing = false;
      _isRecording = false;
      _isFallbackAvailable = true;
      _elapsedSeconds = safeDuration;
      _recording = recording;
      _statusMessage =
          'تم تجهيز تسجيل تجريبي للمراجعة فقط. أرسل المحاولة لو أردت رؤية feedback، لكن فتح اليوم التالي يحتاج تسجيلًا حقيقيًا.';
    });

    widget.onChanged(recording);
  }

  String _statusLabel() {
    if (_isRecording) {
      return 'جارٍ التقاط محاولة حقيقية. اعزف الجملة كاملة ثم أوقف التسجيل.';
    }

    if (_recording != null) {
      return _recording!.isRealRecording
          ? 'تم حفظ تسجيل حقيقي ويمكنك الآن إرسال المحاولة للتحليل.'
          : 'تم إنشاء تسجيل تجريبي للمراجعة فقط لأن التسجيل الحقيقي غير متاح حالياً.';
    }

    if (kIsWeb) {
      return 'التسجيل الحقيقي على الويب غير مستقر حالياً في هذا النموذج. يمكنك استخدام التسجيل التجريبي مباشرة للمراجعة أو تجربة التطبيق المكتبي.';
    }

    return 'ابدأ تسجيلاً حقيقياً قبل إرسال المحاولة النهائية، أو استخدم المسار التجريبي إذا كان التسجيل متعذرًا.';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
