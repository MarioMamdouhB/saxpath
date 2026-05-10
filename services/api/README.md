# SaxPath API

FastAPI backend for SaxPath daily plans, lessons, learner progress, attempt history, analytics events, recording uploads, and audio-analysis handoff.

## Run Locally

```bash
python -m pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Run Tests

```bash
pytest
```

The test suite isolates demo-file storage per run so API tests do not share learner progress, recordings, or analytics state.

## Runtime Notes

- `PERSISTENCE_BACKEND=demo_file` is fine for lightweight local runs
- `PERSISTENCE_BACKEND=postgres` is the intended Docker and beta-style mode
- `AUDIO_ENGINE_BASE_URL` should point at the audio-engine service when you want real pitch/rhythm experiments instead of fallback-only behavior
