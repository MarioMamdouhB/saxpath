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
