# SaxPath Audio Engine

FastAPI service for SaxPath pitch and rhythm analysis experiments.

## Local

```bash
python -m pip install -r requirements.txt
uvicorn app.main:app --reload --port 8010
```

## Run Tests

```bash
pytest
```

## Endpoints

- `GET /health`
- `POST /api/v1/audio-analysis/pitch`
- `POST /api/v1/audio-analysis/rhythm`
