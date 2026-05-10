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


def test_analytics_events_are_recorded_and_listed() -> None:
    create_response = client.post(
        "/api/v1/analytics/events",
        json={
            "event_name": "practice_finish",
            "day_number": 4,
            "task_id": "task_day_04_practice_gabc",
            "attempt_id": "attempt_day_04_010",
            "metadata": {
                "duration_seconds": 10,
                "completion": 74,
            },
        },
    )

    assert create_response.status_code == 200
    created = create_response.json()
    assert created["event_name"] == "practice_finish"
    assert created["day_number"] == 4
    assert created["task_id"] == "task_day_04_practice_gabc"

    list_response = client.get("/api/v1/analytics/events")

    assert list_response.status_code == 200
    payload = list_response.json()
    assert len(payload) == 1
    assert payload[0]["event_name"] == "practice_finish"
    assert payload[0]["metadata"]["duration_seconds"] == 10


def test_analytics_event_ids_are_unique() -> None:
    first_response = client.post(
        "/api/v1/analytics/events",
        json={"event_name": "lesson_start"},
    )
    second_response = client.post(
        "/api/v1/analytics/events",
        json={"event_name": "lesson_start"},
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    assert first_response.json()["event_id"] != second_response.json()["event_id"]
