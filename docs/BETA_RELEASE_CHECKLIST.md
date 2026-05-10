# Private Beta Release Checklist

This checklist remains the final manual release gate.

For the current status snapshot and sign-off order, use [V1_RELEASE_READINESS.md](./V1_RELEASE_READINESS.md).

## Before Inviting Learners

- Confirm `docker compose up --build` starts Postgres, API, and audio-engine with healthy checks.
- Run CI locally or in GitHub: `flutter analyze`, `flutter test`, API `pytest`, and audio-engine `pytest`.
- Verify `PERSISTENCE_BACKEND=postgres`, `DEMO_MODE=false`, and explicit `CORS_ALLOW_ORIGINS` for the beta URL.
- Complete a manual learner flow: open current day, record a WAV attempt, upload, analyze, retry when weak, complete when valid.
- Check attempt history playback from `/api/v1/recordings/{recording_id}/file`.
- Review logs for structured `http_request` events from both API and audio-engine.
- Keep `demo_file` and deterministic mock available only for local fallback or demos.

## Known V1 Limits

- Audio analysis currently targets short mono WAV files.
- Recordings are stored on the backend filesystem volume before moving to object storage.
- User identity is still represented by `DEMO_LEARNER_ID` until auth is introduced.
