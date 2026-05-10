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

## GET /api/v1/daily-plan/week

Returns a 7-day overview for the first curriculum week, including the current day and each day's focus.

The current week is product-authored but source-informed: it is synthesized from official public curriculum pages and handbooks from institutions such as Berklee, Boston Conservatory at Berklee, Eastman, Indiana University Jacobs School of Music, and UNT. See [CURRICULUM_SOURCES.md](./CURRICULUM_SOURCES.md).

## GET /api/v1/daily-plan/day/{day_number}

Returns the mocked plan for a specific day from 1 to 7.

## GET /api/v1/lessons

Returns source-informed beginner note and rhythm lessons for the first week.

Optional query:

`?day_number=3` to return lessons for a specific day.

## POST /api/v1/attempts

Request:

```json
{
  "exercise_id": "practice_day_01_001",
  "recording_id": "rec_abc123"
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
  "next_recommendation": "أعد التمرين على سرعة أبطأ BPM 50.",
  "recording_id": "rec_abc123",
  "retry_reason": null,
  "analysis": {
    "pitch_score": 78,
    "rhythm_score": 64,
    "detected_notes": [],
    "timing_errors": [],
    "confidence": 0.82,
    "source": "audio_engine"
  }
}
```

`POST /api/v1/attempts` now prefers a real `recording_id` returned from upload. The deterministic mock path still works for demo/fallback, but it is no longer the primary learner path.

Each submitted attempt is persisted in the configured backend. Local dev can use `demo_file`; beta uses Postgres.

## POST /api/v1/recordings

Accepts a short mono WAV upload as multipart form data under `file`.

Response:

```json
{
  "recording_id": "rec_abc123",
  "filename": "day_01_take.wav",
  "duration_seconds": 8,
  "storage_path": "/app/data/recordings/rec_abc123_day_01_take.wav",
  "playback_url": "/api/v1/recordings/rec_abc123/file",
  "content_type": "audio/wav",
  "created_at": "2026-05-08T10:00:00Z"
}
```

## POST /api/v1/audio-analysis/pitch

Accepts multipart WAV upload and returns the shared analysis schema.

Returns `400` when the uploaded WAV is invalid. If the audio engine is temporarily unavailable, the API falls back to deterministic mock analysis so the learner flow can continue.

## POST /api/v1/audio-analysis/rhythm

Accepts multipart WAV upload and returns rhythm/onset timing details.

## GET /api/v1/attempts/history

Returns the most recent saved attempts first.

Optional query:

`?limit=5` to return only the latest five attempts.

## GET /api/v1/progress

Returns the backend-saved learner progress snapshot:

```json
{
  "completed_days": [1, 2],
  "completed_days_count": 2,
  "current_day_number": 3,
  "total_days": 7
}
```

## POST /api/v1/progress/day/{day_number}/complete

Marks a day as completed in backend storage and returns the updated progress snapshot.

## POST /api/v1/progress/reset

Clears backend-saved completed days and returns the reset progress snapshot.

## POST /api/v1/analytics/events

Stores a lightweight product event for demo analytics.

Example request:

```json
{
  "event_name": "practice_finish",
  "day_number": 4,
  "task_id": "task_day_04_practice_gabc",
  "attempt_id": "attempt_day_04_010",
  "metadata": {
    "duration_seconds": 10,
    "completion": 74
  }
}
```

## GET /api/v1/analytics/events

Returns recent analytics events, newest first.
