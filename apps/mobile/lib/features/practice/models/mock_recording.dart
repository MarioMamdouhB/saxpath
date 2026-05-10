class MockRecording {
  const MockRecording({
    required this.audioUrl,
    required this.durationSeconds,
    required this.label,
    required this.isRealRecording,
    this.recordingId,
    this.playbackUrl,
  });

  final String audioUrl;
  final int durationSeconds;
  final String label;
  final bool isRealRecording;
  final String? recordingId;
  final String? playbackUrl;

  bool get isFallbackRecording => !isRealRecording;

  bool get hasRemotePlaybackReference =>
      (playbackUrl != null && playbackUrl!.isNotEmpty) ||
      audioUrl.startsWith('/api/') ||
      audioUrl.startsWith('http://') ||
      audioUrl.startsWith('https://');

  bool get hasLocalFileReference =>
      isRealRecording &&
      !audioUrl.startsWith('mock://') &&
      !audioUrl.startsWith('/api/') &&
      !audioUrl.startsWith('http://') &&
      !audioUrl.startsWith('https://');

  bool get isUploadedToServer =>
      (recordingId != null && recordingId!.isNotEmpty) ||
      hasRemotePlaybackReference;

  MockRecording copyWith({
    String? audioUrl,
    int? durationSeconds,
    String? label,
    bool? isRealRecording,
    String? recordingId,
    String? playbackUrl,
  }) {
    return MockRecording(
      audioUrl: audioUrl ?? this.audioUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      label: label ?? this.label,
      isRealRecording: isRealRecording ?? this.isRealRecording,
      recordingId: recordingId ?? this.recordingId,
      playbackUrl: playbackUrl ?? this.playbackUrl,
    );
  }
}
