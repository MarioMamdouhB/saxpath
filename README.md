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

## One-Click Windows Dev

If you want a faster local loop than Docker while editing code:

- Double-click `start_dev_android.bat`
  - Starts `audio-engine` on `8010`
  - Starts `api` on `8000`
  - Opens Android Studio
  - Launches the `Pixel_7` emulator when available
  - Runs Flutter against `http://10.0.2.2:8000`

- Double-click `start_dev_web.bat`
  - Starts `audio-engine` on `8010`
  - Starts `api` on `8000`
  - Runs Flutter Web on `http://127.0.0.1:4131/index.html`

- Double-click `stop_dev_stack.bat`
  - Stops the local dev stack processes started for SaxPath

These local scripts use `uvicorn --reload`, so Python changes refresh automatically, while Flutter keeps `hot reload` for UI edits.

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
- [docs/V3_USER_JOURNEY_PLAN.md](docs/V3_USER_JOURNEY_PLAN.md): proposed V3 learner journey, information architecture, and rollout plan
- [docs/V3_1_MASTER_EXECUTION_PLAN.md](docs/V3_1_MASTER_EXECUTION_PLAN.md): unified V3.1 execution plan covering scope, phases, workstreams, and release gates
- [docs/V3_1_CONTENT_DATA_ROADMAP.md](docs/V3_1_CONTENT_DATA_ROADMAP.md): V3.1 roadmap for content sourcing, rights-safe media strategy, and in-app content system implementation
- [docs/V3_1_NOTATION_CURRICULUM_ROADMAP.md](docs/V3_1_NOTATION_CURRICULUM_ROADMAP.md): V3.1 roadmap for a full notation path with beginner/intermediate/professional levels, tap/clap/count training, and practical in-app drills
- [docs/TASKS.md](docs/TASKS.md): near-term work
- [docs/CURRICULUM_SOURCES.md](docs/CURRICULUM_SOURCES.md): verified source links behind the curriculum
- [docs/V1_RELEASE_READINESS.md](docs/V1_RELEASE_READINESS.md): final V1 closeout checklist and sign-off gate
