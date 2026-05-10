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


def test_progress_defaults_to_day_one() -> None:
    response = client.get("/api/v1/progress")

    assert response.status_code == 200
    payload = response.json()

    assert payload["completed_days"] == []
    assert payload["completed_days_count"] == 0
    assert payload["current_day_number"] == 1
    assert payload["total_days"] == 30
    assert payload["current_streak_days"] == 0
    assert payload["last_completed_at"] is None


def test_progress_can_complete_and_reset_days() -> None:
    complete_response = client.post("/api/v1/progress/day/3/complete")

    assert complete_response.status_code == 200
    complete_payload = complete_response.json()

    assert complete_payload["completed_days"] == [3]
    assert complete_payload["completed_days_count"] == 1
    assert complete_payload["current_day_number"] == 1
    assert complete_payload["current_streak_days"] == 1
    assert complete_payload["last_completed_at"] is not None

    reset_response = client.post("/api/v1/progress/reset")

    assert reset_response.status_code == 200
    reset_payload = reset_response.json()

    assert reset_payload["completed_days"] == []
    assert reset_payload["completed_days_count"] == 0
    assert reset_payload["current_day_number"] == 1
    assert reset_payload["current_streak_days"] == 0
    assert reset_payload["last_completed_at"] is None
