import io
import math
import struct
import wave

from app.schemas import AudioAnalysisResponse, DetectedNote, EventMatch, TimingError

_NOTE_NAMES = (
    "C",
    "C#",
    "D",
    "Ed",
    "Eb",
    "E",
    "F",
    "F#",
    "G",
    "Ab",
    "A",
    "Bd",
    "Bb",
    "B",
)
_CHROMATIC_NOTE_NAMES = (
    "C",
    "C#",
    "D",
    "Eb",
    "E",
    "F",
    "F#",
    "G",
    "Ab",
    "A",
    "Bb",
    "B",
)
_OCTAVE_SIZE = 12
_NOTE_INDEX = {
    "C": 0,
    "Db": 1,
    "C#": 1,
    "D": 2,
    "Ed": 2.5,
    "Eb": 3,
    "D#": 3,
    "E": 4,
    "F": 5,
    "Gb": 6,
    "F#": 6,
    "G": 7,
    "Ab": 8,
    "G#": 8,
    "A": 9,
    "Bd": 9.5,
    "Bb": 10,
    "A#": 10,
    "B": 11,
}


def analyze_pitch_wav(
    wav_bytes: bytes,
    *,
    expected_note: str = "G",
) -> AudioAnalysisResponse:
    samples, sample_rate = _read_mono_pcm16(wav_bytes)
    frequency = _estimate_frequency(samples, sample_rate)
    note = _closest_note(frequency)
    target = _target_frequency(expected_note, frequency)
    pitch_score = _score_pitch(frequency, target)
    confidence = _confidence(samples, frequency)

    return AudioAnalysisResponse(
        pitch_score=pitch_score,
        rhythm_score=0,
        detected_notes=[
            DetectedNote(
                note=note,
                frequency_hz=round(frequency, 2),
                confidence=round(confidence, 2),
            )
        ],
        timing_errors=[],
        confidence=round(confidence, 2),
    )


def analyze_rhythm_wav(
    wav_bytes: bytes,
    *,
    bpm: int = 60,
    rhythm_target: str = "quarter_note",
) -> AudioAnalysisResponse:
    samples, sample_rate = _read_mono_pcm16(wav_bytes)
    onsets = _detect_onsets(samples, sample_rate)
    beat_seconds = 60 / max(30, min(240, bpm))
    grid_seconds = _grid_seconds_for_rhythm_target(
        beat_seconds=beat_seconds,
        rhythm_target=rhythm_target,
    )
    timing_errors = []

    for onset in onsets[:12]:
        expected = round(onset / grid_seconds) * grid_seconds
        error_ms = (onset - expected) * 1000
        timing_errors.append(
            TimingError(
                onset_seconds=round(onset, 3),
                expected_seconds=round(expected, 3),
                error_ms=round(error_ms, 1),
            )
        )

    rhythm_score = _score_rhythm(timing_errors, grid_seconds=grid_seconds)
    confidence = min(1.0, len(timing_errors) / 4) if timing_errors else 0.0

    return AudioAnalysisResponse(
        pitch_score=0,
        rhythm_score=rhythm_score,
        detected_notes=[],
        timing_errors=timing_errors,
        confidence=round(confidence, 2),
    )


def analyze_phrase_wav(
    wav_bytes: bytes,
    *,
    expected_note: str = "G",
    bpm: int = 60,
    rhythm_target: str = "quarter_note",
    expected_event_timeline: list[dict[str, object]] | None = None,
) -> AudioAnalysisResponse:
    samples, sample_rate = _read_mono_pcm16(wav_bytes)
    pitch_response = analyze_pitch_wav(wav_bytes, expected_note=expected_note)
    rhythm_response = analyze_rhythm_wav(
        wav_bytes,
        bpm=bpm,
        rhythm_target=rhythm_target,
    )
    onsets = _detect_onsets(samples, sample_rate)
    expected_events = _normalize_expected_events(expected_event_timeline)
    if not expected_events:
        expected_events = [
            {
                "note": expected_note,
                "onset_seconds": 0.0,
                "duration_seconds": max(0.5, 60 / max(40, bpm)),
            }
        ]

    detected_notes: list[DetectedNote] = []
    event_matches: list[EventMatch] = []
    pitch_scores: list[int] = []

    for index, event in enumerate(expected_events):
        observed_seconds = onsets[index] if index < len(onsets) else None
        duration_seconds = float(event["duration_seconds"])
        expected_seconds = float(event["onset_seconds"])
        expected_event_note = str(event["note"])
        timing_error_ms = (
            (observed_seconds - expected_seconds) * 1000
            if observed_seconds is not None
            else beat_gap_ms(rhythm_target, bpm)
        )

        if observed_seconds is None:
            event_matches.append(
                EventMatch(
                    expected_note=expected_event_note,
                    detected_note="-",
                    expected_seconds=round(expected_seconds, 3),
                    observed_seconds=None,
                    timing_error_ms=round(timing_error_ms, 1),
                    pitch_ok=False,
                )
            )
            continue

        window_samples = _slice_samples(
            samples,
            sample_rate=sample_rate,
            onset_seconds=observed_seconds,
            duration_seconds=duration_seconds,
        )
        frequency = _estimate_frequency(window_samples, sample_rate)
        detected_note = _closest_note(frequency)
        note_confidence = _confidence(window_samples, frequency)
        pitch_score = _score_pitch(
            frequency,
            _target_frequency(expected_event_note, frequency),
        )
        pitch_scores.append(pitch_score)
        detected_notes.append(
            DetectedNote(
                note=detected_note,
                frequency_hz=round(frequency, 2),
                confidence=round(note_confidence, 2),
            )
        )
        event_matches.append(
            EventMatch(
                expected_note=expected_event_note,
                detected_note=detected_note,
                expected_seconds=round(expected_seconds, 3),
                observed_seconds=round(observed_seconds, 3),
                timing_error_ms=round(timing_error_ms, 1),
                pitch_ok=pitch_score >= 75,
            )
        )

    sustain_stability = _sustain_stability(samples)
    tone_score = max(
        0,
        min(
            100,
            round(
                ((sum(pitch_scores) / len(pitch_scores)) if pitch_scores else pitch_response.pitch_score)
                * 0.55
                + sustain_stability * 100 * 0.45
            ),
        ),
    )
    mean_pitch_score = (
        round(sum(pitch_scores) / len(pitch_scores))
        if pitch_scores
        else pitch_response.pitch_score
    )
    confidence = min(
        1.0,
        (
            pitch_response.confidence * 0.35
            + rhythm_response.confidence * 0.25
            + sustain_stability * 0.2
            + min(1.0, len(event_matches) / max(1, len(expected_events))) * 0.2
        ),
    )

    return AudioAnalysisResponse(
        pitch_score=mean_pitch_score,
        rhythm_score=rhythm_response.rhythm_score,
        detected_notes=detected_notes or pitch_response.detected_notes,
        timing_errors=rhythm_response.timing_errors,
        tone_score=tone_score,
        event_matches=event_matches,
        sustain_stability=round(sustain_stability, 2),
        confidence=round(confidence, 2),
        analysis_version="phrase_v2",
    )


def _normalize_expected_events(
    expected_event_timeline: list[dict[str, object]] | None,
) -> list[dict[str, float | str]]:
    if not expected_event_timeline:
        return []

    normalized: list[dict[str, float | str]] = []
    for item in expected_event_timeline:
        note = item.get("note")
        onset_seconds = item.get("onset_seconds")
        duration_seconds = item.get("duration_seconds", 0.75)
        if not isinstance(note, str):
            continue
        try:
            onset_value = float(onset_seconds)
            duration_value = max(0.2, float(duration_seconds))
        except (TypeError, ValueError):
            continue
        normalized.append(
            {
                "note": note,
                "onset_seconds": onset_value,
                "duration_seconds": duration_value,
            }
        )
    return normalized


def _slice_samples(
    samples: list[float],
    *,
    sample_rate: int,
    onset_seconds: float,
    duration_seconds: float,
) -> list[float]:
    start_index = max(0, int(onset_seconds * sample_rate))
    end_index = min(len(samples), start_index + int(duration_seconds * sample_rate))
    if end_index <= start_index:
        return samples
    return samples[start_index:end_index]


def _sustain_stability(samples: list[float]) -> float:
    if not samples:
        return 0.0

    bucket_size = max(256, len(samples) // 24)
    envelope = [
        sum(abs(sample) for sample in samples[index : index + bucket_size]) / bucket_size
        for index in range(0, len(samples), bucket_size)
        if samples[index : index + bucket_size]
    ]
    if not envelope:
        return 0.0

    mean_level = sum(envelope) / len(envelope)
    if mean_level <= 1e-6:
        return 0.0

    normalized_variation = (
        sum(abs(level - mean_level) for level in envelope) / len(envelope)
    ) / mean_level
    return max(0.0, min(1.0, 1.0 - normalized_variation * 1.6))


def beat_gap_ms(rhythm_target: str, bpm: int) -> float:
    beat_seconds = 60 / max(40, bpm)
    grid_seconds = _grid_seconds_for_rhythm_target(
        beat_seconds=beat_seconds,
        rhythm_target=rhythm_target,
    )
    return grid_seconds * 1000


def _read_mono_pcm16(wav_bytes: bytes) -> tuple[list[float], int]:
    with wave.open(io.BytesIO(wav_bytes), "rb") as wav_file:
        channels = wav_file.getnchannels()
        sample_width = wav_file.getsampwidth()
        sample_rate = wav_file.getframerate()
        frame_count = wav_file.getnframes()
        raw = wav_file.readframes(frame_count)

    if sample_width != 2:
        raise ValueError("Only 16-bit PCM WAV input is supported.")

    values = struct.unpack(f"<{len(raw) // 2}h", raw)
    samples = []
    for index in range(0, len(values), channels):
        samples.append(values[index] / 32768.0)

    if not samples:
        raise ValueError("WAV file does not contain audio samples.")

    return samples, sample_rate


def _estimate_frequency(samples: list[float], sample_rate: int) -> float:
    window = samples[: min(len(samples), sample_rate * 2)]
    rms = math.sqrt(sum(sample * sample for sample in window) / len(window))
    if rms < 0.005:
        return 0.0

    crossings = []
    for index in range(1, len(window)):
        previous = window[index - 1]
        current = window[index]
        if previous <= 0 < current:
            crossings.append(index)

    if len(crossings) >= 3:
        periods = [
            crossings[index] - crossings[index - 1]
            for index in range(1, len(crossings))
        ]
        average_period = sum(periods) / len(periods)
        if average_period > 0:
            return sample_rate / average_period

    min_lag = max(1, sample_rate // 900)
    max_lag = max(min_lag + 1, sample_rate // 80)
    best_lag = min_lag
    best_score = float("-inf")

    for lag in range(min_lag, min(max_lag, len(window) // 2)):
        score = 0.0
        for index in range(0, len(window) - lag, 8):
            score += window[index] * window[index + lag]
        if score > best_score:
            best_score = score
            best_lag = lag

    return sample_rate / best_lag if best_lag else 0.0


def _closest_note(frequency: float) -> str:
    if frequency <= 0:
        return "unknown"

    return _CHROMATIC_NOTE_NAMES[_frequency_to_midi(frequency) % _OCTAVE_SIZE]


def _target_frequency(expected_note: str, observed_frequency: float) -> float:
    note_index = _NOTE_INDEX.get(expected_note, _NOTE_INDEX["G"])
    if observed_frequency <= 0:
        return _midi_to_frequency(60 + note_index)

    observed_midi = _frequency_to_midi(observed_frequency)
    octave_start = observed_midi - (observed_midi % _OCTAVE_SIZE)
    candidates = [
        octave_start + note_index,
        octave_start + note_index - _OCTAVE_SIZE,
        octave_start + note_index + _OCTAVE_SIZE,
    ]
    target_midi = min(candidates, key=lambda candidate: abs(candidate - observed_midi))
    return _midi_to_frequency(target_midi)


def _score_pitch(frequency: float, target: float) -> int:
    if frequency <= 0:
        return 0

    cents = abs(1200 * math.log2(frequency / target))
    return max(0, min(100, round(100 - cents / 2)))


def _confidence(samples: list[float], frequency: float) -> float:
    rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
    if frequency <= 0:
        return 0.0
    return max(0.0, min(1.0, rms * 4))


def _frequency_to_midi(frequency: float) -> int:
    return round(69 + 12 * math.log2(frequency / 440.0))


def _midi_to_frequency(midi_note: int) -> float:
    return 440.0 * (2 ** ((midi_note - 69) / 12))


def _detect_onsets(samples: list[float], sample_rate: int) -> list[float]:
    frame_size = max(1, sample_rate // 50)
    energies = []
    for start in range(0, len(samples), frame_size):
        frame = samples[start : start + frame_size]
        if not frame:
            continue
        energies.append(sum(abs(sample) for sample in frame) / len(frame))

    if not energies:
        return []

    threshold = max(0.05, sum(energies) / len(energies) * 2.4)
    onsets = []
    was_active = False
    cooldown_frames = 0

    for index, energy in enumerate(energies):
        if cooldown_frames > 0:
            cooldown_frames -= 1
            continue

        active = energy >= threshold
        if active and not was_active:
            onsets.append(index * frame_size / sample_rate)
            cooldown_frames = 4
        was_active = active

    return onsets


def _grid_seconds_for_rhythm_target(*, beat_seconds: float, rhythm_target: str) -> float:
    multiplier = {
        "long_tone": 1.0,
        "quarter_note": 1.0,
        "quarter_rest": 1.0,
        "half_note": 2.0,
        "dotted_half_note": 3.0,
        "eighth_notes": 0.5,
        "count_4_4": 1.0,
        "weekly_review": 0.5,
        "syncopation_intro": 0.5,
    }.get(rhythm_target, 1.0)
    return beat_seconds * multiplier


def _score_rhythm(
    timing_errors: list[TimingError],
    *,
    grid_seconds: float,
) -> int:
    if not timing_errors:
        return 0

    average_error_ms = sum(abs(error.error_ms) for error in timing_errors) / len(
        timing_errors
    )
    if grid_seconds <= 0:
        return 0

    average_error_ratio = average_error_ms / (grid_seconds * 1000)
    return max(0, min(100, round(100 - average_error_ratio * 160)))
