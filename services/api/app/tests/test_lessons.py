from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_lessons_returns_expected_mock_content() -> None:
    response = client.get("/api/v1/lessons")

    assert response.status_code == 200
    payload = response.json()

    assert len(payload) == 3
    assert payload[0]["id"] == "lesson_note_g"
    assert payload[0]["note"] == "G"
    assert payload[2]["id"] == "lesson_rhythm_quarter"
    assert payload[2]["rhythm"] == "quarter_note"
