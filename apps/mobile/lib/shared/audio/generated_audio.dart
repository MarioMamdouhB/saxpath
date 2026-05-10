import 'dart:math';
import 'dart:typed_data';

class AudioSegment {
  const AudioSegment.tone({
    required this.durationMs,
    required this.frequencyHz,
    this.volume = 0.35,
  }) : isRest = false;

  const AudioSegment.rest({
    required this.durationMs,
  })  : isRest = true,
        frequencyHz = 0,
        volume = 0;

  final bool isRest;
  final int durationMs;
  final double frequencyHz;
  final double volume;
}

enum PlaybackPattern {
  note,
  rhythm,
  phrase,
}

class GeneratedAudio {
  const GeneratedAudio({
    required this.bytes,
    required this.totalDurationMs,
  });

  final Uint8List bytes;
  final int totalDurationMs;
}

class GeneratedAudioFactory {
  static const _sampleRate = 44100;

  static GeneratedAudio build({
    required PlaybackPattern pattern,
    required String patternKey,
    required int durationSeconds,
    int? bpm,
    int countInBeats = 0,
  }) {
    final coreSegments = switch (pattern) {
      PlaybackPattern.note => _buildNoteSegments(patternKey, durationSeconds),
      PlaybackPattern.rhythm =>
        _buildRhythmSegments(patternKey, durationSeconds, bpm: bpm),
      PlaybackPattern.phrase =>
        _buildPhraseSegments(patternKey, durationSeconds, bpm: bpm),
    };
    final segments = [
      if (countInBeats > 0) ..._buildCountInSegments(
        countInBeats,
        bpm: bpm,
      ),
      ...coreSegments,
    ];

    return GeneratedAudio(
      bytes: _buildWaveBytes(segments),
      totalDurationMs:
          segments.fold(0, (sum, segment) => sum + segment.durationMs),
    );
  }

  static Uint8List buildMetronomeClick({required bool accented}) {
    return _buildWaveBytes(_metronomeClickBody(accented: accented));
  }

  static List<AudioSegment> _buildCountInSegments(
    int countInBeats, {
    int? bpm,
  }) {
    final beatMs = _beatMs(bpm);
    final segments = <AudioSegment>[];

    for (var beatIndex = 0; beatIndex < countInBeats; beatIndex++) {
      final clickBody = _metronomeClickBody(accented: beatIndex == 0);
      final clickDurationMs = clickBody.fold<int>(
        0,
        (sum, segment) => sum + segment.durationMs,
      );
      segments.addAll(clickBody);
      if (clickDurationMs < beatMs) {
        segments.add(AudioSegment.rest(durationMs: beatMs - clickDurationMs));
      }
    }

    return segments;
  }

  static List<AudioSegment> _metronomeClickBody({required bool accented}) {
    if (accented) {
      return const [
        AudioSegment.tone(
          durationMs: 22,
          frequencyHz: 1660,
          volume: 0.46,
        ),
        AudioSegment.tone(
          durationMs: 18,
          frequencyHz: 1240,
          volume: 0.34,
        ),
        AudioSegment.rest(durationMs: 12),
      ];
    }

    return const [
      AudioSegment.tone(
        durationMs: 18,
        frequencyHz: 1120,
        volume: 0.34,
      ),
      AudioSegment.tone(
        durationMs: 16,
        frequencyHz: 860,
        volume: 0.24,
      ),
      AudioSegment.rest(durationMs: 10),
    ];
  }

  static List<AudioSegment> _buildNoteSegments(
      String noteLabel, int durationSeconds) {
    final sequence = _extractExplicitPhraseNotes(noteLabel);
    if (sequence.length > 1) {
      final baseSegments = <AudioSegment>[
        for (final note in sequence) ...[
          AudioSegment.tone(
            durationMs: 560,
            frequencyHz: _noteFrequency(note),
            volume: 0.36,
          ),
          const AudioSegment.rest(durationMs: 180),
        ],
      ];
      final repeats = max(1, min(2, durationSeconds ~/ 4));
      return [for (var i = 0; i < repeats; i++) ...baseSegments];
    }

    final frequency = _noteFrequency(noteLabel);
    final repeatCount = max(1, min(4, durationSeconds ~/ 2));

    return [
      for (var i = 0; i < repeatCount; i++) ...[
        AudioSegment.tone(
            durationMs: 700, frequencyHz: frequency, volume: 0.38),
        const AudioSegment.rest(durationMs: 220),
      ],
    ];
  }

  static List<AudioSegment> _buildRhythmSegments(
      String rhythmKey, int durationSeconds,
      {int? bpm}) {
    final beatMs = _beatMs(bpm);
    final eighthMs = (beatMs / 2).round();
    final cycle = switch (rhythmKey) {
      'quarter_note' => [
          const AudioSegment.tone(
              durationMs: 150, frequencyHz: 920, volume: 0.45),
          AudioSegment.rest(durationMs: beatMs - 150),
        ],
      'half_note' => [
          const AudioSegment.tone(
              durationMs: 180, frequencyHz: 920, volume: 0.45),
          AudioSegment.rest(durationMs: (beatMs * 2) - 180),
        ],
      'quarter_rest' => [
          AudioSegment.rest(durationMs: beatMs),
          const AudioSegment.tone(
              durationMs: 150, frequencyHz: 760, volume: 0.32),
          AudioSegment.rest(durationMs: beatMs - 150),
        ],
      'eighth_notes' => [
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 980, volume: 0.45),
          AudioSegment.rest(durationMs: eighthMs - 90),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 760, volume: 0.35),
          AudioSegment.rest(durationMs: eighthMs - 90),
        ],
      'dotted_half_note' => [
          const AudioSegment.tone(
              durationMs: 190, frequencyHz: 880, volume: 0.45),
          AudioSegment.rest(durationMs: (beatMs * 3) - 190),
        ],
      'count_4_4' => [
          const AudioSegment.tone(
              durationMs: 100, frequencyHz: 1040, volume: 0.45),
          AudioSegment.rest(durationMs: beatMs - 100),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 820, volume: 0.34),
          AudioSegment.rest(durationMs: beatMs - 90),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 820, volume: 0.34),
          AudioSegment.rest(durationMs: beatMs - 90),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 820, volume: 0.34),
          AudioSegment.rest(durationMs: beatMs - 90),
        ],
      'weekly_review' => [
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 1040, volume: 0.45),
          AudioSegment.rest(durationMs: eighthMs - 90),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 880, volume: 0.38),
          AudioSegment.rest(durationMs: eighthMs - 90),
          const AudioSegment.tone(
              durationMs: 90, frequencyHz: 760, volume: 0.34),
          AudioSegment.rest(durationMs: beatMs - 90),
          const AudioSegment.tone(
              durationMs: 180, frequencyHz: 920, volume: 0.42),
          AudioSegment.rest(durationMs: beatMs - 180),
        ],
      _ => [
          const AudioSegment.tone(
              durationMs: 150, frequencyHz: 920, volume: 0.45),
          AudioSegment.rest(durationMs: beatMs - 150),
        ],
    };

    final cycles = max(1, min(4, durationSeconds ~/ 2));
    return [for (var i = 0; i < cycles; i++) ...cycle];
  }

  static List<AudioSegment> _buildPhraseSegments(
      String practiceTaskId, int durationSeconds,
      {int? bpm}) {
    final explicitNotes = _extractExplicitPhraseNotes(practiceTaskId);
    final phraseNotes = explicitNotes.isNotEmpty
        ? explicitNotes
        : switch (_extractDayNumber(practiceTaskId)) {
            1 => ['G', 'G', 'A', 'A'],
            2 => ['A', 'A', 'G', 'G'],
            3 => ['G', 'A', 'B', 'A'],
            4 => ['G', 'A', 'B', 'C'],
            5 => ['D', 'C', 'B', 'A'],
            6 => ['G', 'A', 'B', 'C', 'D'],
            7 => ['G', 'A', 'B', 'C', 'C', 'B', 'A', 'G'],
            _ => ['G', 'A', 'B', 'A'],
          };

    final baseSegments = <AudioSegment>[
      for (final note in phraseNotes) ...[
        AudioSegment.tone(
          durationMs: (_beatMs(bpm) * 0.72).round(),
          frequencyHz: _noteFrequency(note),
          volume: 0.36,
        ),
        AudioSegment.rest(durationMs: (_beatMs(bpm) * 0.28).round()),
      ],
    ];

    final repeats = max(1, min(3, durationSeconds ~/ 4));
    return [for (var i = 0; i < repeats; i++) ...baseSegments];
  }

  static Uint8List _buildWaveBytes(List<AudioSegment> segments) {
    final totalSamples = segments.fold<int>(
      0,
      (sum, segment) => sum + ((_sampleRate * segment.durationMs) ~/ 1000),
    );
    final dataLength = totalSamples * 2;
    final bytes = ByteData(44 + dataLength);

    _writeString(bytes, 0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    _writeString(bytes, 8, 'WAVE');
    _writeString(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, _sampleRate, Endian.little);
    bytes.setUint32(28, _sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    _writeString(bytes, 36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);

    var offset = 44;
    for (final segment in segments) {
      final sampleCount = (_sampleRate * segment.durationMs) ~/ 1000;

      for (var sampleIndex = 0; sampleIndex < sampleCount; sampleIndex++) {
        var sampleValue = 0.0;

        if (!segment.isRest) {
          final time = sampleIndex / _sampleRate;
          final envelope = _envelope(sampleIndex, sampleCount);
          sampleValue = sin(2 * pi * segment.frequencyHz * time) *
              segment.volume *
              envelope;
        }

        final pcm = (sampleValue * 32767).round().clamp(-32768, 32767);
        bytes.setInt16(offset, pcm, Endian.little);
        offset += 2;
      }
    }

    return bytes.buffer.asUint8List();
  }

  static double _envelope(int index, int sampleCount) {
    final fadeLength =
        max(1, min(sampleCount ~/ 10, (_sampleRate * 12) ~/ 1000));

    if (index < fadeLength) {
      return index / fadeLength;
    }

    if (index > sampleCount - fadeLength) {
      return (sampleCount - index) / fadeLength;
    }

    return 1.0;
  }

  static int _beatMs(int? bpm) {
    final safeBpm = (bpm ?? 60).clamp(40, 120);
    return (60000 / safeBpm).round();
  }

  static double _noteFrequency(String noteLabel) {
    final token = RegExp(r'[A-G](?:#|B)?')
            .firstMatch(noteLabel.toUpperCase())
            ?.group(0) ??
        'G';

    return switch (token) {
      'AB' => 415.30,
      'A' => 440.00,
      'A#' => 466.16,
      'B' => 493.88,
      'BB' => 466.16,
      'C' => 523.25,
      'C#' => 554.37,
      'DB' => 554.37,
      'D' => 587.33,
      'D#' => 622.25,
      'EB' => 622.25,
      'E' => 659.25,
      'F#' => 739.99,
      'F' => 698.46,
      'GB' => 739.99,
      _ => 392.00,
    };
  }

  static List<String> _extractExplicitPhraseNotes(String rawPattern) {
    final normalized = rawPattern.trim().toUpperCase();
    final sequencePattern =
        RegExp(r'^[A-G](?:#|B)?(?:[\s,/-]+[A-G](?:#|B)?)+$');
    if (!sequencePattern.hasMatch(normalized)) {
      return const <String>[];
    }

    return normalized
        .split(RegExp(r'[\s,/-]+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  static int _extractDayNumber(String id) {
    final match = RegExp(r'day_(\d+)').firstMatch(id);
    return match == null ? 1 : int.tryParse(match.group(1) ?? '1') ?? 1;
  }

  static void _writeString(ByteData bytes, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}
