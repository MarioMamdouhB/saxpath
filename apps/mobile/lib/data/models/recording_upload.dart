class RecordingUpload {
  const RecordingUpload({
    required this.recordingId,
    required this.filename,
    required this.durationSeconds,
    required this.storagePath,
    required this.playbackUrl,
    required this.contentType,
    required this.createdAt,
  });

  factory RecordingUpload.fromJson(Map<String, dynamic> json) {
    return RecordingUpload(
      recordingId: json['recording_id'] as String,
      filename: json['filename'] as String,
      durationSeconds: json['duration_seconds'] as int,
      storagePath: json['storage_path'] as String,
      playbackUrl: json['playback_url'] as String,
      contentType: json['content_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String recordingId;
  final String filename;
  final int durationSeconds;
  final String storagePath;
  final String playbackUrl;
  final String contentType;
  final DateTime createdAt;
}
