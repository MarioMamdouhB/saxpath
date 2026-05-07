from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


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
    assert response.json() == {
        "attempt_id": "attempt_mock_001",
        "pitch_accuracy": 78,
        "rhythm_accuracy": 64,
        "completion": 100,
        "feedback_ar": "أداء جيد. النغمات قريبة، لكن حاول تثبيت التوقيت مع الميترونوم.",
        "next_recommendation": "أعد التمرين على سرعة أبطأ BPM 50.",
    }
