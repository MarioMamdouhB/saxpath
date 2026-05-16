import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_fft/flutter_fft.dart';
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
  final FlutterFft _flutterFft = FlutterFft();

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

    // Windows/Desktop Fallback: Simulate audio detection for testing
    if (Platform.isWindows || Platform.isMacOS) {
      _startMockAnalysis(targetNote);
      return;
    }

    try {
      await _flutterFft.startRecorder();
      _flutterFft.onRecorderStateChanged.listen((data) {
        if (data == null || !_isRecording) return;

        final currentNote = data[2] as String;
        final currentFreq = data[1] as double;
        final currentOctave = data[5] as int;
        final double centOffset = data[3] as double;

        final detectedFullNote = "$currentNote$currentOctave";

        // Looser matching for beginner, strict for Pro
        final isCorrect = detectedFullNote.toUpperCase().contains(targetNote.toUpperCase()) && centOffset.abs() < 50;

        _controller.add(AudioAnalysisResult(
          note: detectedFullNote,
          frequency: currentFreq,
          cents: 0.0,
          isCorrect: isCorrect,
          centOffset: centOffset,
        ));
      });
    } catch (e) {
      _isRecording = false;
      debugPrint("FFT Start Error: $e");
    }
  }

  void _startMockAnalysis(String targetNote) {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      // Simulate getting closer to the target note over 3 seconds
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
      await _flutterFft.stopRecorder();
    }
  }

  void dispose() {
    _mockTimer?.cancel();
    _controller.close();
  }
}
