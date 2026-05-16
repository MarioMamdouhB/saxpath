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


def test_mastery_endpoint_returns_default_skill_graph() -> None:
    response = client.get("/api/v1/mastery")

    assert response.status_code == 200
    payload = response.json()

    assert payload["weak_skill"] is not None
    assert len(payload["skills"]) == 6
    assert payload["skills"][0]["focus_label"]
    assert payload["skills"][0]["trend_label"]
    assert "recommended_next_drill_ar" in payload["skills"][0]
    assert isinstance(payload["skills"][0]["recent_deltas"], list)


def test_mastery_endpoint_includes_recent_trend_and_drill_after_attempt() -> None:
    create_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 8,
            "audio_url": "mock://recordings/day_02_short.wav",
        },
    )

    assert create_response.status_code == 200

    response = client.get("/api/v1/mastery")
    assert response.status_code == 200
    payload = response.json()

    rhythm_entry = next(entry for entry in payload["skills"] if entry["skill"] == "rhythm")
    assert rhythm_entry["trend_label"] in {
        "waiting_for_signal",
        "rising",
        "stable",
        "slipping",
    }
    assert rhythm_entry["recommended_next_drill_ar"]
    assert isinstance(rhythm_entry["recent_deltas"], list)


def test_practice_session_endpoint_returns_four_guided_blocks() -> None:
    response = client.get("/api/v1/practice-sessions/today?track=beginner")

    assert response.status_code == 200
    payload = response.json()

    assert payload["track"] == "beginner"
    assert 10 <= payload["total_minutes"] <= 12
    assert payload["stage_title"]
    assert payload["guided_path_label"]
    assert payload["recommended_next_drill_ar"]
    assert [block["id"] for block in payload["blocks"]] == [
        "warm_up",
        "note_fingering",
        "rhythm_call_response",
        "record_check",
    ]
    assert any(block["supports_wait_mode"] for block in payload["blocks"])
    assert payload["blocks"][1]["loop_target"] >= 2
    assert payload["blocks"][0]["recommended_next_drill_ar"]


def test_practice_session_adapts_after_weak_rhythm_attempt() -> None:
    create_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 8,
            "audio_url": "mock://recordings/day_02_short.wav",
        },
    )

    assert create_response.status_code == 200

    response = client.get("/api/v1/practice-sessions/day/3?track=beginner")

    assert response.status_code == 200
    payload = response.json()
    rhythm_block = next(
        block for block in payload["blocks"] if block["id"] == "rhythm_call_response"
    )

    assert payload["source"] == "adaptive_rule_engine_v1"
    assert payload["adaptation_reason_ar"]
    assert rhythm_block["recommended_bpm"] <= 60
    assert rhythm_block["loop_target"] >= 3


def test_attempt_detail_returns_mastery_delta_and_confidence_label() -> None:
    create_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 10,
            "audio_url": "mock://recordings/day_02.wav",
        },
    )

    assert create_response.status_code == 200
    created = create_response.json()

    detail_response = client.get(f"/api/v1/attempts/{created['attempt_id']}")

    assert detail_response.status_code == 200
    payload = detail_response.json()

    assert payload["attempt_id"] == created["attempt_id"]
    assert payload["confidence_label"] in {"low", "medium", "high"}
    assert isinstance(payload["mastery_delta"], list)
    assert payload["teacher_review"]["status"] == "available"
