# Roadmap

This roadmap reflects the current state of the project after the foundation, week-one curriculum, playback/metronome mocks, recording mocks, smarter mock evaluation, and local progress persistence work.

## Phase 1: Foundation

Status: completed

Tasks:
- Set up the monorepo structure for `apps/mobile`, `services/api`, `services/audio-engine`, and `docs`
- Add the FastAPI mock backend and Docker Compose local environment
- Add the Flutter mobile skeleton with Arabic RTL support
- Document architecture, API shape, and manual testing flow

## Phase 2: Core Learning Flow

Status: completed

Tasks:
- Connect the Flutter app to the backend instead of relying on hardcoded local content
- Add loading and error states for the main learner flow
- Complete the end-to-end journey from home to results
- Add local progress unlocking between days

## Phase 3: First 7 Days Curriculum

Status: completed

Tasks:
- Expand the mocked content from day 1 to a full first-week curriculum
- Add `GET /api/v1/daily-plan/week`
- Add `GET /api/v1/daily-plan/day/{day_number}`
- Add day-scoped lessons and week overview cards in the app

## Phase 4: Audio Playback + Metronome

Status: completed

Tasks:
- Add mock playback cards for notes, rhythm counting, and practice phrases
- Add a mock metronome with BPM control and beat indicators
- Replace visual placeholders with interactive playback/metronome widgets
- Add real generated note, rhythm, and phrase playback inside the app
- Add audible metronome clicks alongside beat indicators
- Add per-lesson playback tempo variations in rhythm lessons
- Add phrase playback presets for slow, lesson, and challenge practice
- Support generated note-review sequences such as `G-A-B-C-D`
- Next: replace generated tones with richer lesson audio assets and phrase references

## Phase 5: Recording

Status: in progress

Tasks:
- Add a mock recording card with start, stop, reset, timer, and waveform-style feedback
- Require a recording before final attempt submission
- Show recording metadata in the results screen
- Add real microphone capture using a cross-platform recorder plugin
- Save a real WAV file path for the submitted attempt
- Add playback for the captured learner recording in practice/results
- Next: keep a history of learner recordings per attempt

## Phase 6: Smarter Evaluation

Status: completed as deterministic mock, pending for signal analysis

Tasks:
- Make attempt evaluation vary by day and recording duration
- Return different feedback and next recommendations across exercises
- Keep evaluation deterministic for repeatable demo/testing behavior
- Next: base evaluation on captured audio features instead of request metadata only

## Phase 7: Pitch Detection POC

Status: in progress as lightweight POC

Tasks:
- Define the first note-detection experiment boundary in `services/audio-engine`
- Choose a library or approach for mono pitch estimation
- Accept a short audio clip and produce note-confidence output
- Compare detected pitch against the expected note target for the exercise
- Current state: heuristic mono WAV analysis is wired through `services/audio-engine` and covered by tests, but it is still a lightweight prototype rather than production-grade detection

## Phase 8: Rhythm Detection POC

Status: in progress as lightweight POC

Tasks:
- Detect onset timing from the recorded audio
- Compare detected timing against the expected beat grid
- Produce a simple rhythm score and timing notes
- Feed the rhythm analysis into the attempt evaluation output
- Current state: onset-based rhythm scoring is already exposed through the audio engine, and the API now resolves `expected_note` and rhythm tempo targets from curriculum task metadata instead of relying on task-id heuristics alone
- Current state: early week tasks now expose `expected_notes` and `rhythm_target` metadata consistently, which keeps playback, API evaluation, and future analysis upgrades aligned to the same lesson intent
- Current state: the audio engine now evaluates rhythm against target-aware grids such as `eighth_notes` instead of assuming quarter-note spacing only, and slight late attacks are scored with a more usable timing-tolerance curve
- Next: improve onset accuracy on real sax phrases and repeated-note articulations before beta reliance

## Phase 9: Persistence + Learner State

Status: in progress

Tasks:
- Keep local progress persistent between app launches using `shared_preferences`
- Add a reset-progress action for testing and demos
- Add backend demo persistence for completed days and attempt history
- Show recent attempt history and backend progress summary in the mobile app
- Current state: Docker + Postgres runtime verification now confirms persisted progress, analytics, recordings, and attempt history survive API restarts
- Current state: the mobile app now refreshes learner progress from the backend on startup and app resume, and the progress screen exposes the current sync state with a manual refresh action
- Next: make backend persistence the primary source of truth instead of local-first sync
- Next: expose simple analytics views for lesson start, practice finish, and day completion

## Phase 10: Private Beta

Status: in progress

Tasks:
- Add a seeded demo learner profile and polished onboarding
- Improve visual consistency and in-app guidance for first-time users
- Validate the first-week experience with real Arabic-speaking beginners
- Use beta feedback to prioritize real audio, retention, and usability work
- Current state: the main learner flow, progress syncing, fallback-vs-real recording gating, and results decision UX are now implemented and covered by local tests
- Remaining gate: complete one real-device or real-runtime manual smoke run with true recording plus Docker/Postgres persistence before calling V1 closed

## Next Major Execution Order

Status: defined

Reference:
- `docs/NEXT_PRODUCT_EXECUTION_ORDER.md`

Ordered next product steps:
- `Adaptive Practice Engine`
- `Real Session Runner`
- `Mastery Timeline`
- `Teacher Review Workflow`
- `Content Scaling System`
- `Retention Analytics + Beta Readiness`
