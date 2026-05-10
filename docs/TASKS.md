# Tasks

This file tracks the most practical next tasks from the current codebase state.

## Now

- Run the final V1 manual smoke on the Docker stack with a real recording path
- Confirm beta environment values and origins before inviting external learners

## Next

- Store per-day completion state on the backend as the primary source of truth
- Add phrase reference recordings alongside the generated playback fallback
- Add detail view for a single historical attempt and its saved recording
- Add a small analytics/debug view for recent event activity
- Add lightweight backend-backed streak logic instead of completed-days count only

## Audio POCs

- Create the first `services/audio-engine` interface for pitch analysis input/output
- Add a pitch-detection experiment endpoint behind a feature flag
- Add a rhythm-detection experiment endpoint behind a feature flag
- Compare expected exercise targets against detected note/rhythm output

## UX + Product

- Add a small home-screen summary for current streak or completed days
- Add a visual marker for the currently unlocked day
- Add onboarding text for first-time learners

## Release Prep

- Add environment configuration for local, demo, and beta targets
- Add a release checklist for backend, app, and test validation
- Prepare a private beta feedback form and testing script
