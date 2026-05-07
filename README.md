# SaxPath

SaxPath is an Arabic-first mobile learning app for beginner alto saxophone players. This repository contains a small Phase 1 foundation: a Flutter mobile skeleton, a FastAPI backend with mocked endpoints, PostgreSQL local setup through Docker Compose, and concise product and technical documentation.

## Repository Layout

- `apps/mobile`: Flutter mobile app skeleton with a simple learning flow.
- `services/api`: FastAPI mock backend.
- `services/audio-engine`: Placeholder for future audio processing work.
- `docs`: Product, architecture, API, data model, roadmap, and manual testing notes.

## Backend Run

```bash
cd services/api
python -m pip install -r requirements.txt
uvicorn app.main:app --reload
```

Install the backend dependencies before running `pytest`.

## Mobile Run

```bash
cd apps/mobile
flutter pub get
flutter run
```

`flutter` must be installed and available on your `PATH`.

## Docker Compose

```bash
docker compose up --build
```

Docker Compose now falls back to the same defaults shown in `.env.example`. Create a local `.env` only if you want to override them.

API will be available at `http://localhost:8000` and PostgreSQL at `localhost:5432`.

## Manual Sprint / Phase 1 Testing

1. Start the backend with Docker Compose or run it directly.
2. Verify `GET /health`.
3. Verify `GET /api/v1/daily-plan/today`.
4. Verify `GET /api/v1/lessons`.
5. Verify `POST /api/v1/attempts`.
6. Run `pytest` in `services/api`.
7. Run `flutter pub get`, `flutter analyze`, and `flutter run` in `apps/mobile`.
8. In the app, navigate `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Home`.
