import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:saxpath_mobile/core/config/api_config.dart';
import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class RecordedAudioCard extends StatefulWidget {
  const RecordedAudioCard({
    super.key,
    required this.recording,
    this.title = 'تشغيل التسجيل',
    this.caption =
        'استمع إلى التسجيل الذي تم حفظه للتأكد من أن المحاولة التقطت بشكل صحيح.',
  });

  final MockRecording recording;
  final String title;
  final String caption;

  @override
  State<RecordedAudioCard> createState() => _RecordedAudioCardState();
}

class _RecordedAudioCardState extends State<RecordedAudioCard> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  bool _fileExists = false;
  bool _isCheckingFile = true;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _actualDuration = Duration.zero;
  String? _statusMessage;

  Duration get _fallbackDuration =>
      Duration(seconds: widget.recording.durationSeconds);

  Duration get _effectiveDuration =>
      _actualDuration > Duration.zero ? _actualDuration : _fallbackDuration;

  bool get _isReplayableLocalFile => widget.recording.hasLocalFileReference;

  String? get _remotePlaybackUrl {
    final candidate = widget.recording.playbackUrl ??
        (_isRemoteUrl(widget.recording.audioUrl) ||
                widget.recording.audioUrl.startsWith('/api/')
            ? widget.recording.audioUrl
            : null);
    if (candidate == null || candidate.isEmpty) {
      return null;
    }

    if (_isRemoteUrl(candidate)) {
      return candidate;
    }

    if (candidate.startsWith('/')) {
      return '${ApiConfig.baseUrl}$candidate';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          _position = _effectiveDuration;
        }
      });
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (!mounted) {
        return;
      }

      setState(() {
        _position = position;
      });
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actualDuration = duration;
      });
    });

    _refreshFileState();
  }

  @override
  void didUpdateWidget(covariant RecordedAudioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recording.audioUrl != widget.recording.audioUrl ||
        oldWidget.recording.playbackUrl != widget.recording.playbackUrl ||
        oldWidget.recording.recordingId != widget.recording.recordingId) {
      _refreshFileState();
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _effectiveDuration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _effectiveDuration.inMilliseconds)
            .clamp(0.0, 1.0);

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(widget.caption),
          const SizedBox(height: 12),
          Text(
            _statusMessage ?? _defaultStatus(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_effectiveDuration)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isCheckingFile || !_fileExists
                    ? null
                    : (_isPlaying ? _stopPlayback : _playRecording),
                icon: Icon(
                  _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(
                  _isCheckingFile
                      ? 'جارٍ التحقق...'
                      : _isPlaying
                          ? 'إيقاف التشغيل'
                          : 'تشغيل التسجيل',
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed:
                    _isCheckingFile || !_fileExists ? null : _restartPlayback,
                child: const Text('إعادة من البداية'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshFileState() async {
    setState(() {
      _isCheckingFile = true;
      _statusMessage = null;
      _position = Duration.zero;
      _actualDuration = Duration.zero;
    });

    await _player.stop();

    if (!_isReplayableLocalFile && _remotePlaybackUrl == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fileExists = false;
        _isCheckingFile = false;
        _isPlaying = false;
        _statusMessage =
            'هذا تسجيل تجريبي للمتابعة فقط، لذلك لا يوجد ملف محلي لإعادة تشغيله.';
      });
      return;
    }

    final exists = _isReplayableLocalFile
        ? await File(widget.recording.audioUrl).exists()
        : true;
    if (!mounted) {
      return;
    }

    setState(() {
      _fileExists = exists;
      _isCheckingFile = false;
      _isPlaying = false;
      _statusMessage = exists ? null : 'ملف التسجيل غير موجود حالياً على الجهاز.';
    });
  }

  Future<void> _playRecording() async {
    try {
      final source = await _playbackSource();
      if (source == null) {
        throw StateError('No playable recording source.');
      }

      await _player.play(source);
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'يتم الآن تشغيل تسجيلك المحفوظ.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'تعذر تشغيل الملف الصوتي على هذا الجهاز حالياً.';
        _isPlaying = false;
      });
    }
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    if (!mounted) {
      return;
    }

    setState(() {
      _position = Duration.zero;
      _statusMessage = 'تم إيقاف تشغيل التسجيل.';
    });
  }

  Future<void> _restartPlayback() async {
    try {
      final source = await _playbackSource();
      if (source == null) {
        throw StateError('No playable recording source.');
      }

      await _player.stop();
      await _player.play(source);
      if (!mounted) {
        return;
      }

      setState(() {
        _position = Duration.zero;
        _statusMessage = 'أُعيد تشغيل التسجيل من البداية.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'تعذر إعادة تشغيل التسجيل من البداية.';
      });
    }
  }

  String _defaultStatus() {
    if (_isCheckingFile) {
      return 'جارٍ تجهيز ملف التسجيل للتشغيل.';
    }

    if (widget.recording.isFallbackRecording && _remotePlaybackUrl == null) {
      return 'هذا تسجيل تجريبي للمتابعة فقط، لذلك لا يوجد ملف محلي لإعادة تشغيله.';
    }

    if (_isPlaying) {
      return 'يتم الآن تشغيل تسجيلك المحفوظ.';
    }

    if (_fileExists) {
      if (_isReplayableLocalFile && _remotePlaybackUrl != null) {
        return 'التسجيل محفوظ على الجهاز وعلى الخادم. يمكنك مراجعته محلياً أو من سجل المحاولات.';
      }

      if (_remotePlaybackUrl != null) {
        return 'التسجيل محفوظ على الخادم وجاهز للتشغيل من سجل المحاولات.';
      }

      return 'التسجيل جاهز للاستماع قبل إرسال المحاولة أو بعد ظهور النتيجة.';
    }

    return 'ملف التسجيل غير موجود حالياً على الجهاز.';
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<Source?> _playbackSource() async {
    if (_isReplayableLocalFile &&
        await File(widget.recording.audioUrl).exists()) {
      return DeviceFileSource(widget.recording.audioUrl);
    }

    final remoteUrl = _remotePlaybackUrl;
    if (remoteUrl != null) {
      return UrlSource(remoteUrl);
    }

    return null;
  }

  bool _isRemoteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }
}
