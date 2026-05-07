from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_daily_plan_returns_day_one() -> None:
    response = client.get("/api/v1/daily-plan/today")

    assert response.status_code == 200
    payload = response.json()

    assert payload["day_number"] == 1
    assert len(payload["tasks"]) == 4
    assert payload["tasks"][0]["type"] == "note_lesson"
    assert payload["tasks"][0]["status"] == "next"
