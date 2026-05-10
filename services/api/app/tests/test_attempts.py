from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services import persistence

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


def test_attempts_returns_mock_evaluation() -> None:
    response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "practice_day_01_001",
            "duration_seconds": 120,
            "audio_url": "mock://local-recording.wav",
        },
    )

    assert response.status_code == 200
    payload = response.json()

    assert payload["attempt_id"].startswith("attempt_day_01_120_")
    assert payload["pitch_accuracy"] == 78
    assert payload["rhythm_accuracy"] == 73
    assert payload["completion"] == 87
    assert "المحاولة مستقرة" in payload["feedback_ar"]
    assert "ارفع السرعة تدريجياً" in payload["next_recommendation"]


def test_attempts_returns_short_attempt_feedback() -> None:
    response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_04_practice_gabc",
            "duration_seconds": 4,
            "audio_url": "mock://recordings/day_04_short.wav",
        },
    )

    assert response.status_code == 200
    payload = response.json()

    assert payload["attempt_id"].startswith("attempt_day_04_004_")
    assert payload["pitch_accuracy"] == 64
    assert payload["rhythm_accuracy"] == 58
    assert payload["completion"] == 50
    assert "المحاولة كانت قصيرة" in payload["feedback_ar"]
    assert payload["next_recommendation"] == "أعد التسجيل لمدة أطول مع عدّ واضح قبل أول نغمة."


def test_attempts_returns_late_week_recommendation() -> None:
    response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_07_practice_phrase",
            "duration_seconds": 13,
            "audio_url": "mock://recordings/day_07_phrase.wav",
        },
    )

    assert response.status_code == 200
    payload = response.json()

    assert payload["attempt_id"].startswith("attempt_day_07_013_")
    assert payload["pitch_accuracy"] == 84
    assert payload["rhythm_accuracy"] == 79
    assert payload["completion"] == 93
    assert "لليوم 7" in payload["feedback_ar"]
    assert payload["next_recommendation"] == "أعد الجملة كاملة مرتين متتاليتين قبل الانتقال لليوم التالي."


def test_attempt_history_persists_latest_attempts() -> None:
    first_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 10,
            "audio_url": "mock://recordings/day_02.wav",
        },
    )
    second_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_05_practice_dcba",
            "duration_seconds": 14,
            "audio_url": "mock://recordings/day_05.wav",
        },
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 200

    history_response = client.get("/api/v1/attempts/history")

    assert history_response.status_code == 200
    payload = history_response.json()

    assert len(payload) == 2
    assert payload[0]["exercise_id"] == "task_day_05_practice_dcba"
    assert payload[0]["day_number"] == 5
    assert payload[1]["exercise_id"] == "task_day_02_practice_aagg"
    assert payload[1]["audio_url"] == "mock://recordings/day_02.wav"
    assert payload[0]["created_at"]


def test_attempt_ids_are_unique_for_same_day_and_duration() -> None:
    first_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 10,
            "audio_url": "mock://recordings/day_02_take_1.wav",
        },
    )
    second_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 10,
            "audio_url": "mock://recordings/day_02_take_2.wav",
        },
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    assert first_response.json()["attempt_id"] != second_response.json()["attempt_id"]
