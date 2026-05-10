import 'package:flutter_test/flutter_test.dart';
import 'package:saxpath_mobile/shared/audio/generated_audio.dart';

void main() {
  test('phrase playback becomes shorter at faster BPM values', () {
    final slow = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.phrase,
      patternKey: 'G A B C',
      durationSeconds: 16,
      bpm: 48,
    );
    final fast = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.phrase,
      patternKey: 'G A B C',
      durationSeconds: 16,
      bpm: 84,
    );

    expect(slow.totalDurationMs, greaterThan(fast.totalDurationMs));
    expect(slow.bytes.length, greaterThan(44));
    expect(fast.bytes.length, greaterThan(44));
  });

  test('note playback supports explicit multi-note review sequences', () {
    final review = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.note,
      patternKey: 'G-A-B-C-D',
      durationSeconds: 8,
    );
    final single = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.note,
      patternKey: 'G',
      durationSeconds: 8,
    );

    expect(review.totalDurationMs, greaterThan(single.totalDurationMs));
    expect(review.bytes.length, greaterThan(single.bytes.length));
  });

  test('Gb playback matches F# playback for generated tones', () {
    final sharp = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.note,
      patternKey: 'F#',
      durationSeconds: 4,
    );
    final flat = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.note,
      patternKey: 'Gb',
      durationSeconds: 4,
    );

    expect(flat.totalDurationMs, sharp.totalDurationMs);
    expect(flat.bytes, orderedEquals(sharp.bytes));
  });

  test('count-in adds extra duration before generated playback', () {
    final withoutCountIn = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.phrase,
      patternKey: 'G A B C',
      durationSeconds: 8,
      bpm: 60,
    );
    final withCountIn = GeneratedAudioFactory.build(
      pattern: PlaybackPattern.phrase,
      patternKey: 'G A B C',
      durationSeconds: 8,
      bpm: 60,
      countInBeats: 4,
    );

    expect(withCountIn.totalDurationMs, greaterThan(withoutCountIn.totalDurationMs));
    expect(withCountIn.bytes.length, greaterThan(withoutCountIn.bytes.length));
  });
}
