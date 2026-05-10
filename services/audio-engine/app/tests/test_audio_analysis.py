import io
import math
import struct
import wave

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_returns_ok() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "saxpath-audio-engine"}


def test_pitch_analysis_detects_expected_note() -> None:
    wav_bytes = _sine_wav(frequency=392.0, duration_seconds=1.0)

    response = client.post(
        "/api/v1/audio-analysis/pitch",
        data={"expected_note": "G"},
        files={"file": ("g.wav", wav_bytes, "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["pitch_score"] >= 90
    assert payload["detected_notes"][0]["note"] == "G"
    assert payload["confidence"] > 0


def test_pitch_analysis_matches_expected_note_across_octaves() -> None:
    wav_bytes = _sine_wav(frequency=196.0, duration_seconds=1.0)

    response = client.post(
        "/api/v1/audio-analysis/pitch",
        data={"expected_note": "G"},
        files={"file": ("g_low.wav", wav_bytes, "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["pitch_score"] >= 90
    assert payload["detected_notes"][0]["note"] == "G"


def test_rhythm_analysis_scores_on_grid_pulses() -> None:
    wav_bytes = _pulse_wav(duration_seconds=2.2, pulse_seconds=[0.0, 1.0, 2.0])

    response = client.post(
        "/api/v1/audio-analysis/rhythm",
        data={"bpm": "60"},
        files={"file": ("pulse.wav", wav_bytes, "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["rhythm_score"] >= 85
    assert len(payload["timing_errors"]) >= 2


def test_rhythm_analysis_supports_eighth_note_grid_for_articulated_notes() -> None:
    wav_bytes = _sax_like_note_wav(
        duration_seconds=1.8,
        onset_seconds=[0.0, 0.5, 1.0, 1.5],
        note_duration_seconds=0.16,
    )

    response = client.post(
        "/api/v1/audio-analysis/rhythm",
        data={"bpm": "60", "rhythm_target": "eighth_notes"},
        files={"file": ("articulated.wav", wav_bytes, "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["rhythm_score"] >= 85
    assert len(payload["timing_errors"]) == 4


def test_rhythm_analysis_tolerates_small_late_attacks() -> None:
    wav_bytes = _sax_like_note_wav(
        duration_seconds=2.4,
        onset_seconds=[0.08, 1.08, 2.08],
    )

    response = client.post(
        "/api/v1/audio-analysis/rhythm",
        data={"bpm": "60", "rhythm_target": "quarter_note"},
        files={"file": ("late.wav", wav_bytes, "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["rhythm_score"] >= 80
    assert len(payload["timing_errors"]) == 3


def test_pitch_analysis_rejects_invalid_wav() -> None:
    response = client.post(
        "/api/v1/audio-analysis/pitch",
        data={"expected_note": "G"},
        files={"file": ("broken.wav", b"not-a-valid-wav", "audio/wav")},
    )

    assert response.status_code == 400
    assert response.json()["detail"]


def _sine_wav(*, frequency: float, duration_seconds: float) -> bytes:
    sample_rate = 8000
    total_samples = int(sample_rate * duration_seconds)
    samples = [
        int(12000 * math.sin(2 * math.pi * frequency * index / sample_rate))
        for index in range(total_samples)
    ]
    return _wav_from_samples(samples, sample_rate=sample_rate)


def _pulse_wav(*, duration_seconds: float, pulse_seconds: list[float]) -> bytes:
    sample_rate = 8000
    total_samples = int(sample_rate * duration_seconds)
    samples = [0] * total_samples
    pulse_width = int(sample_rate * 0.06)

    for pulse_second in pulse_seconds:
        start = int(pulse_second * sample_rate)
        for offset in range(pulse_width):
            index = start + offset
            if index < len(samples):
                samples[index] = 18000

    return _wav_from_samples(samples, sample_rate=sample_rate)


def _sax_like_note_wav(
    *,
    duration_seconds: float,
    onset_seconds: list[float],
    frequency: float = 196.0,
    note_duration_seconds: float = 0.22,
) -> bytes:
    sample_rate = 8000
    total_samples = int(sample_rate * duration_seconds)
    samples = [0] * total_samples
    attack_samples = max(1, int(sample_rate * 0.02))
    note_samples = max(1, int(sample_rate * note_duration_seconds))

    for onset_second in onset_seconds:
        start = int(onset_second * sample_rate)
        for offset in range(note_samples):
            index = start + offset
            if index >= len(samples):
                break
            attack = min(1.0, offset / attack_samples)
            decay = math.exp(-4 * offset / note_samples)
            amplitude = 14000 * attack * decay
            samples[index] += int(
                amplitude
                * math.sin(2 * math.pi * frequency * offset / sample_rate)
            )

    return _wav_from_samples(samples, sample_rate=sample_rate)


def _wav_from_samples(samples: list[int], *, sample_rate: int) -> bytes:
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(struct.pack(f"<{len(samples)}h", *samples))
    return buffer.getvalue()
