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


def test_daily_plan_returns_day_one() -> None:
    response = client.get("/api/v1/daily-plan/today")

    assert response.status_code == 200
    payload = response.json()

    assert payload["day_number"] == 1
    assert len(payload["tasks"]) == 4
    assert payload["tasks"][0]["type"] == "note_lesson"
    assert payload["tasks"][0]["status"] == "next"
    assert payload["tasks"][0]["expected_notes"] == ["G"]
    assert payload["tasks"][0]["rhythm_target"] == "long_tone"
    assert payload["tasks"][2]["expected_notes"] == ["G", "A"]
    assert payload["tasks"][2]["rhythm_target"] == "quarter_note"


def test_daily_plan_returns_requested_day() -> None:
    response = client.get("/api/v1/daily-plan/day/4")

    assert response.status_code == 200
    payload = response.json()

    assert payload["day_number"] == 4
    assert payload["tasks"][0]["title"] == "نغمة C / دو"
    assert payload["total_minutes"] == 27


def test_week_overview_returns_private_beta_month() -> None:
    response = client.get("/api/v1/daily-plan/week")

    assert response.status_code == 200
    payload = response.json()

    assert payload["current_day_number"] == 1
    assert payload["total_days"] == 30
    assert len(payload["days"]) == 30
    assert payload["days"][0]["status"] == "current"
    assert payload["days"][1]["status"] == "locked"


def test_daily_plan_returns_generated_day_with_targets() -> None:
    response = client.get("/api/v1/daily-plan/day/12")

    assert response.status_code == 200
    payload = response.json()

    assert payload["day_number"] == 12
    assert payload["tasks"][2]["type"] == "practice"
    assert payload["tasks"][2]["expected_notes"]
    assert payload["tasks"][2]["rhythm_target"]


def test_daily_plan_adapts_after_weak_attempt() -> None:
    create_response = client.post(
        "/api/v1/attempts",
        json={
            "exercise_id": "task_day_02_practice_aagg",
            "duration_seconds": 8,
            "audio_url": "mock://recordings/day_02_short.wav",
        },
    )

    assert create_response.status_code == 200

    response = client.get("/api/v1/daily-plan/day/3")

    assert response.status_code == 200
    payload = response.json()
    focus_tasks = [task for task in payload["tasks"] if task["is_focus_task"]]

    assert focus_tasks
    assert any(task["adaptation_reason_ar"] for task in payload["tasks"])
    assert any(task["recommended_loop_target"] for task in payload["tasks"])
