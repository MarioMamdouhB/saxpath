# Architecture

## Monorepo Structure

- `apps/mobile`: learner-facing Flutter app
- `services/api`: FastAPI backend
- `services/audio-engine`: future audio processing boundary
- `docs`: product and technical documentation

## Mobile App

The mobile app is a simple Flutter application using Material 3, Arabic RTL layout, and local mock data for the first learning flow.

## Backend API

The backend is a FastAPI service that exposes versioned mocked endpoints for health, daily plan, lessons, and attempts.

## PostgreSQL Foundation

PostgreSQL is included in Docker Compose for future persistence, but it is not used by the mocked API in this phase.

## Future Audio Engine

The audio engine remains a placeholder for later playback, recording, and pitch/rhythm analysis work.
