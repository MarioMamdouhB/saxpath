# Manual Testing

## Latest Verification Snapshot

Date: 2026-05-09

Validated:
- `docker compose up --build -d` starts `postgres`, `audio-engine`, and `api` healthy
- `GET /health` succeeds on both `api` and `audio-engine`
- `GET /api/v1/progress`, `GET /api/v1/daily-plan/today`, and `GET /api/v1/lessons?day_number=1` succeed against the Docker stack
- `POST /api/v1/analytics/events` persists an event in Postgres
- `POST /api/v1/progress/day/1/complete` persists learner progress in Postgres
- `POST /api/v1/recordings` stores a WAV upload and returns a playback URL
- `POST /api/v1/attempts` with a saved `recording_id` reaches `audio-engine` and persists attempt history
- Restarting the API container preserves progress, analytics, and attempt history
- Low-octave pitch analysis such as `196 Hz` now maps correctly to `G`
- The mobile progress screen now shows sync state and supports manual refresh from the backend
- Curriculum-backed tasks now expose `expected_notes` and `rhythm_target` metadata consistently
- Rhythm analysis now honors target-aware grids such as `eighth_notes`
- Flutter Web can load against the Docker API from localhost dev ports after the expanded default CORS list
- Windows desktop release build reaches the `Home` screen without an immediate crash in smoke testing

## Recommended Order Now

### 1. Environment smoke

```bash
docker compose up --build
```

If you plan to test Flutter Web from `3000`, `3001`, or `4130`, keep `CORS_ALLOW_ORIGINS` aligned before starting the API container.

### 2. Automated checks

```bash
cd apps/mobile
flutter pub get
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

### 3. Backend API smoke

```bash
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/daily-plan/today
curl http://localhost:8000/api/v1/lessons
curl http://localhost:8000/api/v1/attempts/history
curl http://localhost:8000/api/v1/progress
curl http://localhost:8000/api/v1/analytics/events
```

For a quick attempt smoke check:

```bash
curl -X POST http://localhost:8000/api/v1/attempts ^
  -H "Content-Type: application/json" ^
  -d "{\"exercise_id\":\"practice_day_01_001\",\"duration_seconds\":120,\"audio_url\":\"mock://local-recording.wav\"}"
```

### 4. Main learner UX path

- Open `Home`
- Start the current unlocked day
- Complete `Note Lesson -> Rhythm Lesson -> Practice -> Results`
- Confirm `Progress` reflects the latest attempt and current unlocked day

What to verify in that path:
- Home shows the current day, progress summary, and clear access to the main session
- Locked days stay blocked and redirect the learner toward the current unlocked day
- Note lesson plays generated note audio and review-note sequences correctly
- Rhythm lesson provides audible presets plus a working metronome
- Practice shows slow, lesson, and challenge phrase playback presets
- Fallback recording can be submitted for review only, while a real microphone recording is required to unlock the next day
- Results show evaluation, audio feedback, retry messaging, and completion gating clearly
- Progress shows backend sync state, recent attempts, and reset behavior

### 5. Supporting flows when touched

- `التعلّم`: foundation, jazz academy, and 30-day curriculum surfaces open correctly
- `المكتبة`: track cards and reference sections open and read clearly
- `غرفة التدريب`: metronome, key changes, and tempo ladder stay coherent
- `الإعدادات والملف`: saved values reload correctly on the same device

## Defer For Now

These are useful, but they are not the highest-value checks for the current local iteration:

- Real Android microphone permissions and device-specific recording UX
- Playback and recording behavior on Windows desktop runtime hardware
- Full web-surface QA if Flutter Web is not part of the immediate release target
- Large benchmark runs on real learner recordings before the current heuristic tuning changes again

## Audio Benchmark

When real learner recordings become available and the current heuristics are stable enough to compare, run:

```bash
python tools/audio_benchmark.py --manifest docs/audio_benchmark_manifest.example.json
```
