import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  final _recorder = AudioRecorder();
  final _pitchDetector = PitchDetector();
  StreamSubscription<Uint8List>? _audioSubscription;

  double _frequency = 0;
  String _note = '-';
  double _status = 0; // -1 (flat) to 1 (sharp)
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // V3.1 Fix: Do not start tuning automatically to avoid audio device conflicts
  }

  @override
  void dispose() {
    _stopTuning();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startTuning() async {
    try {
      if (await _recorder.hasPermission()) {
        const config = RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        );

        final stream = await _recorder.startStream(config);

        _audioSubscription = stream.listen((data) async {
          final result = await _pitchDetector.getPitchFromIntBuffer(data);
          if (result.pitched) {
            _processPitch(result.pitch);
          }
        });

        setState(() {
          _isListening = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting tuner: $e');
    }
  }

  Future<void> _stopTuning() async {
    await _audioSubscription?.cancel();
    await _recorder.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _frequency = 0;
        _note = '-';
        _status = 0;
      });
    }
  }

  void _processPitch(double pitch) {
    final noteInfo = _getNoteInfo(pitch);

    if (mounted) {
      setState(() {
        _frequency = pitch;
        _note = noteInfo.name;
        _status = noteInfo.offset;
      });
    }
  }

  _NoteInfo _getNoteInfo(double frequency) {
    if (frequency <= 0) return _NoteInfo('-', 0);

    // MIDI number calculation (69 is A4)
    final midi = 12 * (math.log(frequency / 440) / math.log(2)) + 69;
    final roundedMidi = midi.round();
    final offset = midi - roundedMidi; // range -0.5 to 0.5 semitones

    // Standard semitone names
    final semitones = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'];

    String name = semitones[roundedMidi % 12];
    double finalOffset = offset * 2; // scale to -1 to 1 for the needle

    // Logic for Quarter Tones (Ed and Bd)
    if (offset.abs() > 0.22 && offset.abs() < 0.28) {
       if (name == 'D' && offset > 0) return _NoteInfo('Ed (سيكا)', (offset - 0.25) * 8);
       if (name == 'Eb' && offset < 0) return _NoteInfo('Ed (سيكا)', (offset + 0.25) * 8);
       if (name == 'A' && offset > 0) return _NoteInfo('Bd (أوج)', (offset - 0.25) * 8);
       if (name == 'Bb' && offset < 0) return _NoteInfo('Bd (أوج)', (offset + 0.25) * 8);
    }

    return _NoteInfo(name, finalOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دوزان الساكسفون (Tuner)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'اعزف نغمة الآن',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _TunerDial(status: _status, note: _note),
            const SizedBox(height: 40),
            SaxCard(
              child: Column(
                children: [
                  Text(
                    'التردد: ${_frequency.toStringAsFixed(1)} Hz',
                    style: const TextStyle(fontSize: 16, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'تأكد من اختيار نوع الساكسفون الخاص بك من الإعدادات للحصول على أدق النتائج.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_isListening)
              PrimaryButton(label: 'ابدأ الاستماع', onPressed: _startTuning)
            else
              OutlinedButton(onPressed: _stopTuning, child: const Text('إيقاف')),
          ],
        ),
      ),
    );
  }
}

class _NoteInfo {
  final String name;
  final double offset;
  _NoteInfo(this.name, this.offset);
}

class _TunerDial extends StatelessWidget {
  final double status;
  final String note;

  const _TunerDial({required this.status, required this.note});

  @override
  Widget build(BuildContext context) {
    final color = status.abs() < 0.15
        ? Colors.green
        : (status.abs() < 0.4 ? Colors.amber : Colors.red);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: _DialPainter(status: status, color: color),
          ),
        ),
        Column(
          children: [
            Text(
              note,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              status > 0.05 ? 'Sharp' : (status < -0.05 ? 'Flat' : 'Perfect'),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double status;
  final Color color;

  _DialPainter({required this.status, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Draw needle/indicator
    final angle = (math.pi * 1.5) + (status * math.pi * 0.6);
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + (radius - 20) * math.cos(angle - math.pi / 2),
      center.dy + (radius - 20) * math.sin(angle - math.pi / 2),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 8, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
