from pathlib import Path

import httpx
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services import audio_analysis

client = TestClient(app)


def test_pitch_upload_rejects_invalid_wav() -> None:
    response = client.post(
        "/api/v1/audio-analysis/pitch",
        data={"expected_note": "G"},
        files={"file": ("broken.wav", b"not-a-valid-wav", "audio/wav")},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid WAV recording."


def test_pitch_upload_falls_back_when_audio_engine_is_unavailable(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fail_post_file(*, endpoint: str, path: Path, data: dict[str, str]):
        request = httpx.Request("POST", f"http://offline.local{endpoint}")
        raise httpx.ConnectError("engine unavailable", request=request)

    monkeypatch.setattr(audio_analysis, "_post_file", fail_post_file)

    response = client.post(
        "/api/v1/audio-analysis/pitch",
        data={"expected_note": "G"},
        files={"file": ("take.wav", _wav_bytes(), "audio/wav")},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["source"] == "deterministic_mock_fallback"
    assert payload["pitch_score"] > 0


def _wav_bytes() -> bytes:
    return (
        b"RIFF$\x00\x00\x00WAVEfmt "
        b"\x10\x00\x00\x00\x01\x00\x01\x00@\x1f\x00\x00\x80>\x00\x00"
        b"\x02\x00\x10\x00data\x00\x00\x00\x00"
    )
