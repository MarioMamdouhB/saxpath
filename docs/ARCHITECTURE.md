# Architecture

## Monorepo Structure

- `apps/mobile`: learner-facing Flutter app
- `services/api`: FastAPI backend
- `services/audio-engine`: FastAPI audio analysis service boundary
- `docs`: product and technical documentation

## Mobile App

The mobile app is an Arabic RTL Flutter client built around the daily learner journey: `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Progress`.

It also exposes supporting surfaces for deeper learning and review such as the learn hub, library, practice room, record-feedback shortcut, and device-local settings.

`shared_preferences` is used for local profile/setup values and for caching unlocked progress on the device, while backend progress remains the preferred source of truth whenever the API is reachable.

## Backend API

The backend is a FastAPI service that exposes versioned endpoints for health, daily plan, lessons, recordings, attempts, analytics, and learner progress.

The API supports both `demo_file` persistence for lightweight local runs and PostgreSQL-backed persistence for Docker and beta-style runs.

When a real learner recording is available, the API uploads it, bridges to the audio-engine for pitch and rhythm analysis, and falls back to deterministic analysis when the engine is unavailable.

## Audio Engine

The audio engine is a separate FastAPI boundary for WAV-based pitch and rhythm experiments.

It currently provides lightweight heuristic analysis that is good enough for local verification and product wiring, but it is not yet production-grade audio evaluation.

## Local Runtime

`docker compose` runs `postgres`, `audio-engine`, and `api` together.

The mobile app points to `http://127.0.0.1:8000` on desktop, `http://10.0.2.2:8000` on Android emulators, and a browser-origin-aware host on web, with `API_BASE_URL` available as an override.
