import 'package:flutter_test/flutter_test.dart';

import 'package:saxpath_mobile/features/practice/models/mock_recording.dart';

void main() {
  test('classifies local-only recordings correctly', () {
    const recording = MockRecording(
      audioUrl: 'C:/temp/day_01_take.wav',
      durationSeconds: 8,
      label: 'day_01_take.wav',
      isRealRecording: true,
    );

    expect(recording.isFallbackRecording, isFalse);
    expect(recording.hasLocalFileReference, isTrue);
    expect(recording.hasRemotePlaybackReference, isFalse);
    expect(recording.isUploadedToServer, isFalse);
  });

  test('classifies uploaded recordings with local and remote playback', () {
    const recording = MockRecording(
      audioUrl: 'C:/temp/day_01_take.wav',
      durationSeconds: 8,
      label: 'day_01_take.wav',
      isRealRecording: true,
      recordingId: 'rec_123',
      playbackUrl: '/api/v1/recordings/rec_123/file',
    );

    expect(recording.hasLocalFileReference, isTrue);
    expect(recording.hasRemotePlaybackReference, isTrue);
    expect(recording.isUploadedToServer, isTrue);
  });

  test('classifies fallback recordings correctly', () {
    const recording = MockRecording(
      audioUrl: 'mock://day_01/task_day_01_practice_ggaa.wav',
      durationSeconds: 8,
      label: 'fallback_day_1.wav',
      isRealRecording: false,
    );

    expect(recording.isFallbackRecording, isTrue);
    expect(recording.hasLocalFileReference, isFalse);
    expect(recording.hasRemotePlaybackReference, isFalse);
    expect(recording.isUploadedToServer, isFalse);
  });
}
