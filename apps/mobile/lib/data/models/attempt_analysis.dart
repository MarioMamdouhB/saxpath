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

class EventMatch {
  const EventMatch({
    required this.expectedNote,
    required this.detectedNote,
    required this.expectedSeconds,
    required this.timingErrorMs,
    required this.pitchOk,
    this.observedSeconds,
  });

  factory EventMatch.fromJson(Map<String, dynamic> json) {
    return EventMatch(
      expectedNote: json['expected_note'] as String? ?? '-',
      detectedNote: json['detected_note'] as String? ?? '-',
      expectedSeconds: (json['expected_seconds'] as num?)?.toDouble() ?? 0,
      observedSeconds: (json['observed_seconds'] as num?)?.toDouble(),
      timingErrorMs: (json['timing_error_ms'] as num?)?.toDouble() ?? 0,
      pitchOk: json['pitch_ok'] as bool? ?? false,
    );
  }

  final String expectedNote;
  final String detectedNote;
  final double expectedSeconds;
  final double? observedSeconds;
  final double timingErrorMs;
  final bool pitchOk;
}

class AttemptAnalysis {
  const AttemptAnalysis({
    required this.pitchScore,
    required this.rhythmScore,
    required this.detectedNotes,
    required this.timingErrors,
    this.toneScore = 0,
    this.eventMatches = const <EventMatch>[],
    this.sustainStability = 0,
    required this.confidence,
    required this.source,
    this.analysisVersion = 'v1',
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
      toneScore: json['tone_score'] as int? ?? 0,
      eventMatches: (json['event_matches'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(EventMatch.fromJson)
          .toList(),
      sustainStability: (json['sustain_stability'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? 'unknown',
      analysisVersion: json['analysis_version'] as String? ?? 'v1',
    );
  }

  final int pitchScore;
  final int rhythmScore;
  final List<DetectedNote> detectedNotes;
  final List<TimingError> timingErrors;
  final int toneScore;
  final List<EventMatch> eventMatches;
  final double sustainStability;
  final double confidence;
  final String source;
  final String analysisVersion;
}
