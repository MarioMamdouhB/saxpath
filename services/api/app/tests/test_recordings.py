import io
import math
import struct
import wave
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services import audio_analysis, persistence, recordings

client = TestClient(app)


@pytest.fixture(autouse=True)
def isolated_demo_store(
    isolated_service_dir: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        persistence,
        "get_store_path",
        lambda: isolated_service_dir / "demo_store.json",
    )
    monkeypatch.setattr(
        recordings,
        "get_recording_storage_dir",
        lambda: isolated_service_dir / "recordings",
    )


def test_upload_recording_returns_playback_reference() -> None:
    response = client.post(
        "/api/v1/recordings",
        files={"file": ("take.wav", _wav_bytes(), "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()

    assert payload["recording_id"].startswith("rec_")
    assert payload["duration_seconds"] == 1
    assert payload["playback_url"].endswith("/file")

    playback_response = client.get(payload["playback_url"])
    assert playback_response.status_code == 200


def test_attempt_with_recording_uses_audio_analysis(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fake_post_file(*, endpoint: str, path: Path, data: dict[str, str]):
        if endpoint.endswith("/pitch"):
            return {
                "pitch_score": 92,
                "rhythm_score": 0,
                "detected_notes": [
                    {"note": "G", "frequency_hz": 196.0, "confidence": 0.94}
                ],
                "timing_errors": [],
                "confidence": 0.94,
            }

        return {
            "pitch_score": 0,
            "rhythm_score": 88,
            "detected_notes": [],
            "timing_errors": [],
            "confidence": 0.9,
        }

    monkeypatch.setattr(audio_analysis, "_post_file", fake_post_file)

    recording_response = client.post(
        "/api/v1/recordings",
        files={"file": ("take.wav", _wav_bytes(seconds=8), "audio/wav")},
    )
    recording_id = recording_response.json()["recording_id"]

    attempt_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_01_practice_ggaa",
            "recording_id": recording_id,
        },
    )

    assert attempt_response.status_code == 200
    payload = attempt_response.json()

    assert payload["recording_id"] == recording_id
    assert payload["pitch_accuracy"] == 92
    assert payload["rhythm_accuracy"] == 88
    assert payload["analysis"]["source"] == "audio_engine"
    assert payload["retry_reason"] is None


def test_attempt_with_missing_recording_returns_not_found() -> None:
    response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_01_practice_ggaa",
            "recording_id": "rec_missing",
        },
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Recording not found."


def test_attempt_with_audio_analysis_failure_falls_back_to_deterministic_mock(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fail_post_file(*, endpoint: str, path: Path, data: dict[str, str]):
        raise audio_analysis.AudioAnalysisError("audio engine unavailable")

    monkeypatch.setattr(audio_analysis, "_post_file", fail_post_file)

    recording_response = client.post(
        "/api/v1/recordings",
        files={"file": ("take.wav", _wav_bytes(seconds=8), "audio/wav")},
    )
    recording_id = recording_response.json()["recording_id"]

    attempt_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_01_practice_ggaa",
            "recording_id": recording_id,
        },
    )

    assert attempt_response.status_code == 200
    payload = attempt_response.json()

    assert payload["recording_id"] == recording_id
    assert payload["analysis"]["source"] == "deterministic_mock_fallback"
    assert payload["pitch_accuracy"] == 70
    assert payload["rhythm_accuracy"] == 65
    assert payload["completion"] == 73
    assert payload["retry_reason"] == "rhythm_needs_work"


def test_attempt_uses_curriculum_targets_for_generated_days(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    captured_calls: list[tuple[str, dict[str, str]]] = []

    def fake_post_file(*, endpoint: str, path: Path, data: dict[str, str]):
        captured_calls.append((endpoint, data))
        if endpoint.endswith("/pitch"):
            return {
                "pitch_score": 90,
                "rhythm_score": 0,
                "detected_notes": [
                    {"note": "C", "frequency_hz": 261.63, "confidence": 0.9}
                ],
                "timing_errors": [],
                "confidence": 0.9,
            }

        return {
            "pitch_score": 0,
            "rhythm_score": 84,
            "detected_notes": [],
            "timing_errors": [],
            "confidence": 0.85,
        }

    monkeypatch.setattr(audio_analysis, "_post_file", fake_post_file)

    recording_response = client.post(
        "/api/v1/recordings",
        files={"file": ("take.wav", _wav_bytes(seconds=8), "audio/wav")},
    )
    recording_id = recording_response.json()["recording_id"]

    attempt_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_12_practice_c",
            "recording_id": recording_id,
        },
    )

    assert attempt_response.status_code == 200
    assert captured_calls == [
        ("/api/v1/audio-analysis/pitch", {"expected_note": "C"}),
        (
            "/api/v1/audio-analysis/rhythm",
            {"bpm": "76", "rhythm_target": "syncopation_intro"},
        ),
    ]


def _wav_bytes(*, seconds: int = 1, frequency: float = 196.0) -> bytes:
    sample_rate = 8000
    frame_count = sample_rate * seconds
    buffer = io.BytesIO()

    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for index in range(frame_count):
            value = int(16000 * math.sin(2 * math.pi * frequency * index / sample_rate))
            wav_file.writeframes(struct.pack("<h", value))

    buffer.seek(0)
    return buffer.read()
