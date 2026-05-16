import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/audio_playback_coordinator.dart';
import '../audio/generated_audio.dart';
import 'sax_card.dart';

class MetronomeCard extends StatefulWidget {
  const MetronomeCard({
    super.key,
    this.initialBpm = 60,
    this.beatsPerBar = 4,
    this.onBpmChanged,
    this.linkedPlaybackTitle,
    this.linkedPlaybackHint,
  });

  final int initialBpm;
  final int beatsPerBar;
  final ValueChanged<int>? onBpmChanged;
  final String? linkedPlaybackTitle;
  final String? linkedPlaybackHint;

  @override
  State<MetronomeCard> createState() => _MetronomeCardState();
}

class _MetronomeCardState extends State<MetronomeCard> {
  final AudioPlayer _accentPlayer = AudioPlayer();
  final AudioPlayer _regularPlayer = AudioPlayer();
  final Object _playbackOwner = Object();
  Timer? _timer;
  late int _bpm;
  late int _currentBeat;
  late String _accentPath;
  late String _regularPath;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
    _currentBeat = 1;
    _prepareFiles();
  }

  Future<void> _prepareFiles() async {
    _accentPath = await GeneratedAudioFactory.saveToFile(
      GeneratedAudioFactory.buildMetronomeClick(accented: true),
      'met_accent.wav'
    );
    _regularPath = await GeneratedAudioFactory.saveToFile(
      GeneratedAudioFactory.buildMetronomeClick(accented: false),
      'met_regular.wav'
    );

    // Pre-set sources for faster response
    await _accentPlayer.setSource(UrlSource(Uri.file(_accentPath).toString()));
    await _regularPlayer.setSource(UrlSource(Uri.file(_regularPath).toString()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioPlaybackCoordinator.instance.release(_playbackOwner);
    unawaited(_accentPlayer.dispose());
    unawaited(_regularPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _changeBpm(5);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _changeBpm(-5);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: SaxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الميترونوم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 8),
          const Text('استخدمه كدليل إيقاعي فعلي أثناء التمرين.'),
          if (widget.linkedPlaybackTitle != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.linkedPlaybackHint ??
                          'سرعة هذا الميترونوم مربوطة مباشرة مع ${widget.linkedPlaybackTitle}. اضبط النبض هنا ثم شغّل النموذج أسفلها بنفس التوقيت.',
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text('النبض'),
                    const SizedBox(height: 6),
                    Text(
                      '$_bpm',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text('النبضة الحالية'),
                    const SizedBox(height: 6),
                    Text(
                      '$_currentBeat / ${widget.beatsPerBar}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _bpm > 40 ? () => _changeBpm(-5) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _bpm.toDouble(),
                  min: 40,
                  max: 120,
                  divisions: 16,
                  label: '$_bpm نبضة/د',
                  onChanged: (value) {
                    _setBpm(value.round());
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: _bpm < 120 ? () => _changeBpm(5) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(widget.beatsPerBar, (index) {
              final beatNumber = index + 1;
              final isActive = beatNumber == _currentBeat;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.only(start: index == 0 ? 0 : 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 18,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (beatNumber == 1
                              ? Colors.amber.shade600
                              : Theme.of(context).colorScheme.primary)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _toggleRunning,
            icon: Icon(
              _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(_isRunning ? 'إيقاف الميترونوم' : 'تشغيل الميترونوم'),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _toggleRunning() async {
    if (_isRunning) {
      await _stopRunning(releaseOwnership: true);
      return;
    }

    await AudioPlaybackCoordinator.instance.activate(
      owner: _playbackOwner,
      onInterrupt: _handleExternalInterruption,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = true;
      _currentBeat = 1;
    });
    await _playBeatSound(1);
    _startTimer();
  }

  void _changeBpm(int delta) {
    _setBpm((_bpm + delta).clamp(40, 120));
  }

  void _setBpm(int nextBpm) {
    setState(() {
      _bpm = nextBpm;
    });
    widget.onBpmChanged?.call(nextBpm);

    if (_isRunning) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / _bpm).round());
    _timer = Timer.periodic(interval, (_) {
      setState(() {
        _currentBeat =
            _currentBeat == widget.beatsPerBar ? 1 : _currentBeat + 1;
      });
      unawaited(_playBeatSound(_currentBeat));
    });
  }

  Future<void> _playBeatSound(int beatNumber) async {
    final player = beatNumber == 1 ? _accentPlayer : _regularPlayer;
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('Metronome audio error: $e');
    }
  }

  Future<void> _stopRunning({required bool releaseOwnership}) async {
    _timer?.cancel();
    await _accentPlayer.stop();
    await _regularPlayer.stop();
    if (releaseOwnership) {
      AudioPlaybackCoordinator.instance.release(_playbackOwner);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
      _currentBeat = 1;
    });
  }

  Future<void> _handleExternalInterruption() {
    return _stopRunning(releaseOwnership: false);
  }
}
