# SaxPath

SaxPath is an Arabic-first mobile learning app for beginner alto saxophone players. The current repo includes the main learner journey from `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Progress`, supporting learning hubs and practice tools, backend progress and analytics flows, recording uploads, and a separate audio-analysis service for pitch and rhythm experiments.

## Repository Layout

- `apps/mobile`: Flutter client for the daily learner flow, practice tools, and progress review
- `services/api`: FastAPI backend for plans, lessons, recordings, attempts, analytics, and progress
- `services/audio-engine`: FastAPI audio-analysis service for pitch and rhythm experiments
- `docs`: product, architecture, API, roadmap, and manual testing notes

## Main Learner Journey

- Primary path: `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Progress`
- Supporting paths: `Learn Hub`, `Library`, `Practice Room`, `Record Feedback`, and device-local settings

## Local Run

```bash
docker compose up --build
```

This starts `postgres`, `audio-engine`, and `api`.

The mobile app defaults to `http://127.0.0.1:8000` on desktop, `http://10.0.2.2:8000` on Android emulators, and the current host on web. Override it when needed with `--dart-define=API_BASE_URL=http://YOUR_HOST:8000`.

If you want to run services separately:

```bash
cd services/api
python -m pip install -r requirements.txt
uvicorn app.main:app --reload
```

```bash
cd services/audio-engine
python -m pip install -r requirements.txt
uvicorn app.main:app --reload --port 8010
```

```bash
cd apps/mobile
flutter pub get
flutter run
```

## Quality Checks

```bash
cd apps/mobile
flutter analyze
flutter test
```

```bash
cd services/api
pytest
```

```bash
cd services/audio-engine
pytest
```

## Docs

- [docs/MANUAL_TESTING.md](docs/MANUAL_TESTING.md): current smoke path, regression order, and deferred checks
- [docs/API_SPEC.md](docs/API_SPEC.md): API contract
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): system overview
- [docs/ROADMAP.md](docs/ROADMAP.md): current delivery status
- [docs/TASKS.md](docs/TASKS.md): near-term work
- [docs/CURRICULUM_SOURCES.md](docs/CURRICULUM_SOURCES.md): verified source links behind the curriculum
- [docs/V1_RELEASE_READINESS.md](docs/V1_RELEASE_READINESS.md): final V1 closeout checklist and sign-off gate
