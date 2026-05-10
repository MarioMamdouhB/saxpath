from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_lessons_returns_expected_mock_content() -> None:
    response = client.get("/api/v1/lessons")

    assert response.status_code == 200
    payload = response.json()

    assert len(payload) == 60
    assert payload[0]["id"] == "lesson_day_01_note_g"
    assert payload[0]["day_number"] == 1
    assert payload[0]["note"] == "G"
    assert payload[1]["id"] == "lesson_day_01_rhythm_quarter"
    assert payload[1]["rhythm"] == "quarter_note"
    assert payload[-1]["day_number"] == 30


def test_lessons_can_be_filtered_by_day() -> None:
    response = client.get("/api/v1/lessons?day_number=5")

    assert response.status_code == 200
    payload = response.json()

    assert len(payload) == 2
    assert payload[0]["day_number"] == 5
    assert payload[0]["title"] == "نغمة D / ري"
    assert payload[1]["rhythm"] == "dotted_half_note"
