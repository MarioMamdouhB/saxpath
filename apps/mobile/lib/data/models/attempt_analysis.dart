class DetectedNote {
  const DetectedNote({
    required this.note,
    required this.frequencyHz,
    required this.confidence,
  });

  factory DetectedNote.fromJson(Map<String, dynamic> json) {
    return DetectedNote(
      note: json['note'] as String? ?? '-',
      frequencyHz: (json['frequency_hz'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  final String note;
  final double frequencyHz;
  final double confidence;
}

class TimingError {
  const TimingError({
    required this.onsetSeconds,
    required this.expectedSeconds,
    required this.errorMs,
  });

  factory TimingError.fromJson(Map<String, dynamic> json) {
    return TimingError(
      onsetSeconds: (json['onset_seconds'] as num?)?.toDouble() ?? 0,
      expectedSeconds: (json['expected_seconds'] as num?)?.toDouble() ?? 0,
      errorMs: (json['error_ms'] as num?)?.toDouble() ?? 0,
    );
  }

  final double onsetSeconds;
  final double expectedSeconds;
  final double errorMs;
}

class AttemptAnalysis {
  const AttemptAnalysis({
    required this.pitchScore,
    required this.rhythmScore,
    required this.detectedNotes,
    required this.timingErrors,
    required this.confidence,
    required this.source,
  });

  factory AttemptAnalysis.fromJson(Map<String, dynamic> json) {
    return AttemptAnalysis(
      pitchScore: json['pitch_score'] as int? ?? 0,
      rhythmScore: json['rhythm_score'] as int? ?? 0,
      detectedNotes: (json['detected_notes'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DetectedNote.fromJson)
          .toList(),
      timingErrors: (json['timing_errors'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TimingError.fromJson)
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? 'unknown',
    );
  }

  final int pitchScore;
  final int rhythmScore;
  final List<DetectedNote> detectedNotes;
  final List<TimingError> timingErrors;
  final double confidence;
  final String source;
}
