# V1 Release Readiness

Date: 2026-05-10

This document is the final closeout view for V1 / private beta.

## What Is Already Done

- Main learner flow is implemented: `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Progress`
- Locked-day routing and current unlocked-day focus are now clearer on `Home`
- Results now surface the decision state early: continue, retry, or review-only
- Generated playback, metronome guidance, and fallback recording behavior are wired in the app
- Real recording upload, attempt submission, analytics events, progress sync, and attempt history are exposed through the backend
- Audio-engine pitch and rhythm analysis are available as lightweight POCs
- Branding metadata is no longer left at default Flutter template values for web and Windows

## Automated Status

Latest locally verified checks:

- `apps/mobile`: `flutter analyze`
- `apps/mobile`: `flutter test`
- `services/api`: `pytest`
- `services/audio-engine`: `pytest`

Automated status is green as of the latest local verification pass on 2026-05-10.

## Remaining V1 Gate

V1 should be considered closed only after this one manual gate is complete:

1. Start the official stack with `docker compose up --build`
2. Verify `PERSISTENCE_BACKEND=postgres`, `DEMO_MODE=false`, and the intended `CORS_ALLOW_ORIGINS`
3. Run one real learner flow with a true microphone recording:
   `Home -> Note Lesson -> Rhythm Lesson -> Practice -> Results -> Progress`
4. Confirm:
   - the attempt reaches the backend
   - the recording playback URL works
   - the result screen shows the correct completion decision
   - progress survives an API restart

## Sign-Off Rule

Treat V1 as closed when both conditions are true:

- automated checks are green
- the manual gate above is completed successfully on the intended beta runtime

## After V1

The next work should focus on:

- backend-first progress as the primary source of truth
- richer lesson/reference audio assets
- better analytics/debug visibility
- stronger real-audio validation before wider rollout
