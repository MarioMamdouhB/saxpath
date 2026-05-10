import io
import math
import struct
import wave

from app.schemas import AudioAnalysisResponse, DetectedNote, TimingError

_NOTE_NAMES = (
    "C",
    "Db",
    "D",
    "Eb",
    "E",
    "F",
    "Gb",
    "G",
    "Ab",
    "A",
    "Bb",
    "B",
)
_NOTE_INDEX = {
    "C": 0,
    "Db": 1,
    "C#": 1,
    "D": 2,
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

    return _NOTE_NAMES[_frequency_to_midi(frequency) % len(_NOTE_NAMES)]


def _target_frequency(expected_note: str, observed_frequency: float) -> float:
    note_index = _NOTE_INDEX.get(expected_note, _NOTE_INDEX["G"])
    if observed_frequency <= 0:
        return _midi_to_frequency(60 + note_index)

    observed_midi = _frequency_to_midi(observed_frequency)
    octave_start = observed_midi - (observed_midi % len(_NOTE_NAMES))
    candidates = [
        octave_start + note_index,
        octave_start + note_index - len(_NOTE_NAMES),
        octave_start + note_index + len(_NOTE_NAMES),
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
