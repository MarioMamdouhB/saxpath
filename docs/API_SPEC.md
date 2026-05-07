# API Specification

## GET /health

Response:

```json
{
  "status": "ok",
  "service": "saxpath-api"
}
```

## GET /api/v1/daily-plan/today

Response:

```json
{
  "user_name": "أحمد",
  "day_number": 1,
  "total_minutes": 25,
  "progress_percent": 0,
  "tasks": [
    {
      "id": "task_day_01_note_g",
      "type": "note_lesson",
      "title": "نغمة G / صول",
      "duration_minutes": 5,
      "status": "next"
    }
  ]
}
```

## GET /api/v1/lessons

Returns mocked note and rhythm lessons for the first day.

## POST /api/v1/attempts

Request:

```json
{
  "exercise_id": "practice_day_01_001",
  "duration_seconds": 120,
  "audio_url": "mock://local-recording.wav"
}
```

Response:

```json
{
  "attempt_id": "attempt_mock_001",
  "pitch_accuracy": 78,
  "rhythm_accuracy": 64,
  "completion": 100,
  "feedback_ar": "أداء جيد. النغمات قريبة، لكن حاول تثبيت التوقيت مع الميترونوم.",
  "next_recommendation": "أعد التمرين على سرعة أبطأ BPM 50."
}
```
