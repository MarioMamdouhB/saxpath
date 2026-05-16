import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_audio_capture/audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class AudioAnalysisResult {
  final String note;
  final double frequency;
  final double cents;
  final bool isCorrect;
  final double centOffset;

  AudioAnalysisResult({
    required this.note,
    required this.frequency,
    required this.cents,
    required this.isCorrect,
    this.centOffset = 0.0,
  });
}

class AudioAnalysisService {
  final AudioCapture _audioCapture = AudioCapture();
  final PitchDetector _pitchDetector = PitchDetector(44100, 2048);

  bool _isRecording = false;
  final _controller = StreamController<AudioAnalysisResult>.broadcast();
  Stream<AudioAnalysisResult> get analysisStream => _controller.stream;
  Timer? _mockTimer;

  Future<bool> requestPermissions() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS) return true;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startAnalysis({required String targetNote}) async {
    if (_isRecording) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint("Microphone permission denied");
      return;
    }

    _isRecording = true;

    // Windows/Desktop Fallback
    if (Platform.isWindows || Platform.isMacOS) {
      _startMockAnalysis(targetNote);
      return;
    }

    try {
      await _audioCapture.start(
        (dynamic buffer) {
          if (!_isRecording) return;
          
          final List<double> audioData = (buffer as List<dynamic>).cast<double>();
          final result = _pitchDetector.getPitch(audioData);

          if (result.pitch > 0) {
            // Note detection logic
            final double freq = result.pitch;
            final detectedNote = _frequencyToNote(freq);
            
            // Calculate Cent Offset
            final double targetFreq = _noteToFrequency(targetNote);
            final double offset = 1200 * (log(freq / targetFreq) / log(2));

            // Logic: Correct if note matches OR if it's a Sikah (approx -50 cents)
            final bool matchesNote = detectedNote.toUpperCase().contains(targetNote.toUpperCase());
            final bool isSikah = matchesNote && (offset + 50).abs() < 15;
            final bool isStrictMatch = matchesNote && offset.abs() < 40;

            _controller.add(AudioAnalysisResult(
              note: detectedNote,
              frequency: freq,
              cents: 0.0,
              isCorrect: isStrictMatch || isSikah,
              centOffset: offset,
            ));
          }
        },
        (dynamic error) => debugPrint("Audio Capture Error: $error"),
        sampleRate: 44100,
        bufferSize: 2048,
      );
    } catch (e) {
      _isRecording = false;
      debugPrint("Audio Engine Start Error: $e");
    }
  }

  void _startMockAnalysis(String targetNote) {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      final random = Random();
      final isFinalTarget = random.nextDouble() > 0.8;
      
      final result = AudioAnalysisResult(
        note: isFinalTarget ? targetNote : "C4",
        frequency: 440.0,
        cents: 0.0,
        isCorrect: isFinalTarget,
        centOffset: isFinalTarget ? (random.nextDouble() * 10 - 5) : 100.0,
      );

      _controller.add(result);
    });
  }

  Future<void> stopAnalysis() async {
    if (!_isRecording) return;
    _isRecording = false;
    _mockTimer?.cancel();
    if (!Platform.isWindows && !Platform.isMacOS) {
      await _audioCapture.stop();
    }
  }

  String _frequencyToNote(double freq) {
    final List<String> notes = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"];
    final double semi = 12 * (log(freq / 440.0) / log(2));
    final int noteIndex = (semi.round() + 69) % 12;
    final int octave = ((semi.round() + 69) / 12).floor();
    return "${notes[noteIndex]}$octave";
  }

  double _noteToFrequency(String note) {
    final Map<String, double> base = {
      "C": 261.63, "C#": 277.18, "D": 293.66, "Eb": 311.13, "E": 329.63,
      "F": 349.23, "F#": 369.99, "G": 392.00, "Ab": 415.30, "A": 440.00, "Bb": 466.16, "B": 493.88
    };
    final String name = note.replaceAll(RegExp(r'\d'), '');
    return base[name] ?? 440.0;
  }

  void dispose() {
    _mockTimer?.cancel();
    _controller.close();
  }
}
