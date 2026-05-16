import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart' show SaxType;

import '../audio/audio_playback_coordinator.dart';
import '../audio/generated_audio.dart';
import 'sax_card.dart';

class PlaybackPreset {
  const PlaybackPreset({
    required this.id,
    required this.label,
    this.caption,
    this.accentLabel,
    this.patternKey,
    this.durationSeconds,
    this.bpm,
  });

  final String id;
  final String label;
  final String? caption;
  final String? accentLabel;
  final String? patternKey;
  final int? durationSeconds;
  final int? bpm;
}

class MockPlaybackCard extends StatefulWidget {
  const MockPlaybackCard({
    super.key,
    required this.title,
    required this.caption,
    required this.accentLabel,
    required this.pattern,
    required this.patternKey,
    this.durationSeconds = 12,
    this.bpm,
    this.presets = const <PlaybackPreset>[],
    this.countInBeats = 0,
    this.countInLabel,
    this.onPlayStateChanged,
    this.includeBacking = false,
    this.saxType = SaxType.altoEb,
  });

  final String title;
  final String caption;
  final String accentLabel;
  final PlaybackPattern pattern;
  final String patternKey;
  final int durationSeconds;
  final int? bpm;
  final List<PlaybackPreset> presets;
  final int countInBeats;
  final String? countInLabel;
  final ValueChanged<bool>? onPlayStateChanged;
  final bool includeBacking;
  final SaxType saxType;

  @override
  State<MockPlaybackCard> createState() => _MockPlaybackCardState();
}

class _MockPlaybackCardState extends State<MockPlaybackCard> {
  final AudioPlayer _player = AudioPlayer();
  final Object _playbackOwner = Object();
  Timer? _timer;
  late GeneratedAudio _generatedAudio;
  int _selectedPresetIndex = 0;
  int _elapsedMilliseconds = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _generatedAudio = _buildAudio();
    _player.onPlayerComplete.listen((_) {
      _timer?.cancel();
      if (!mounted) {
        return;
      }

      setState(() {
        _elapsedMilliseconds = _generatedAudio.totalDurationMs;
        _isPlaying = false;
      });
      AudioPlaybackCoordinator.instance.release(_playbackOwner);
    });
  }

  @override
  void didUpdateWidget(covariant MockPlaybackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSignature = _signatureFor(oldWidget, _selectedPresetIndex);
    _selectedPresetIndex = _normalizedPresetIndex(widget, _selectedPresetIndex);
    final newSignature = _signatureFor(widget, _selectedPresetIndex);

    if (oldSignature != newSignature) {
      unawaited(_stopPlayback(resetProgress: true));
      _generatedAudio = _buildAudio();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioPlaybackCoordinator.instance.release(_playbackOwner);
    unawaited(_player.stop());
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMilliseconds = _generatedAudio.totalDurationMs;
    final progress =
        totalMilliseconds == 0 ? 0.0 : _elapsedMilliseconds / totalMilliseconds;
    final selectedPreset = _selectedPreset;
    final presetCaption = selectedPreset?.caption;
    final effectiveCaption =
        presetCaption == null || presetCaption.isEmpty
            ? widget.caption
            : '${widget.caption} $presetCaption';

    return SaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(effectiveCaption),
          if (widget.countInBeats > 0) ...[
            const SizedBox(height: 8),
            Text(
              widget.countInLabel ??
                  'يبدأ التشغيل بعد ${widget.countInBeats} عدات ميترونوم على نفس الـ BPM الحالي.',
              style: const TextStyle(
                color: Color(0xFF62708A),
                height: 1.4,
              ),
            ),
          ],
          if (widget.presets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < widget.presets.length; index++)
                  ChoiceChip(
                    label: Text(widget.presets[index].label),
                    selected: index == _selectedPresetIndex,
                    onSelected: (selected) {
                      if (!selected) {
                        return;
                      }
                      unawaited(_selectPreset(index));
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _togglePlayback,
                icon: Icon(
                  _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(_isPlaying ? 'إيقاف' : 'تشغيل الصوت'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _resetPlayback,
                child: const Text('إعادة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatMilliseconds(_elapsedMilliseconds)} / ${_formatMilliseconds(totalMilliseconds)}',
                ),
              ),
              Text(_effectiveAccentLabel),
            ],
          ),
        ],
      ),
    );
  }

  GeneratedAudio _buildAudio() {
    return GeneratedAudioFactory.build(
      pattern: widget.pattern,
      patternKey: _effectivePatternKey,
      durationSeconds: _effectiveDurationSeconds,
      bpm: _effectiveBpm,
      countInBeats: widget.countInBeats,
      includeBacking: widget.includeBacking,
      saxType: widget.saxType,
    );
  }

  PlaybackPreset? get _selectedPreset =>
      widget.presets.isEmpty ? null : widget.presets[_selectedPresetIndex];

  String get _effectivePatternKey =>
      _selectedPreset?.patternKey ?? widget.patternKey;

  int get _effectiveDurationSeconds =>
      _selectedPreset?.durationSeconds ?? widget.durationSeconds;

  int? get _effectiveBpm => _selectedPreset?.bpm ?? widget.bpm;

  String get _effectiveAccentLabel =>
      _selectedPreset?.accentLabel ?? widget.accentLabel;

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _stopPlayback(resetProgress: true);
      return;
    }

    await AudioPlaybackCoordinator.instance.activate(
      owner: _playbackOwner,
      onInterrupt: _handleExternalInterruption,
    );
    if (!mounted) {
      return;
    }

    final filePath = await GeneratedAudioFactory.saveToFile(
      _generatedAudio.bytes,
      'playback_${_effectivePatternKey.hashCode}.wav'
    );
    final fileUri = Uri.file(filePath).toString();

    setState(() {
      _elapsedMilliseconds = 0;
      _isPlaying = true;
    });
    widget.onPlayStateChanged?.call(true);

    await _player.stop();
    try {
      await _player.play(UrlSource(fileUri));
      _startProgressTimer();
    } catch (e) {
      debugPrint('Playback error: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _stopPlayback({
    required bool resetProgress,
    bool releaseOwnership = true,
  }) async {
    _timer?.cancel();
    await _player.stop();
    if (releaseOwnership) {
      AudioPlaybackCoordinator.instance.release(_playbackOwner);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isPlaying = false;
      if (resetProgress) {
        _elapsedMilliseconds = 0;
      }
    });
    widget.onPlayStateChanged?.call(false);
  }

  Future<void> _handleExternalInterruption() {
    return _stopPlayback(
      resetProgress: true,
      releaseOwnership: false,
    );
  }

  Future<void> _resetPlayback() async {
    await _stopPlayback(resetProgress: true);
  }

  Future<void> _selectPreset(int index) async {
    if (index == _selectedPresetIndex) {
      return;
    }

    await _stopPlayback(resetProgress: true);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedPresetIndex = index;
      _generatedAudio = _buildAudio();
    });
  }

  void _startProgressTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final nextValue = _elapsedMilliseconds + 120;
      if (nextValue >= _generatedAudio.totalDurationMs) {
        timer.cancel();
        if (!mounted) {
          return;
        }

        setState(() {
          _elapsedMilliseconds = _generatedAudio.totalDurationMs;
        });
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _elapsedMilliseconds = nextValue;
      });
    });
  }

  String _formatMilliseconds(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int _normalizedPresetIndex(MockPlaybackCard widget, int index) {
    if (widget.presets.isEmpty) {
      return 0;
    }

    return index.clamp(0, widget.presets.length - 1);
  }

  String _signatureFor(MockPlaybackCard widget, int selectedPresetIndex) {
    final normalizedIndex = _normalizedPresetIndex(widget, selectedPresetIndex);
    final preset =
        widget.presets.isEmpty ? null : widget.presets[normalizedIndex];

    return [
      widget.pattern.name,
      preset?.patternKey ?? widget.patternKey,
      (preset?.durationSeconds ?? widget.durationSeconds).toString(),
      (preset?.bpm ?? widget.bpm)?.toString() ?? '-',
      preset?.accentLabel ?? widget.accentLabel,
      preset?.id ?? 'default',
      widget.countInBeats.toString(),
    ].join('|');
  }
}
