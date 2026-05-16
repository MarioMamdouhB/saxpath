# Next Product Execution Order

Date: 2026-05-11

This file defines the next major product steps for `SaxPath` after the current V2 guided-flow, wait-mode, interactive practice tools, stage curriculum, and AI/teacher-review groundwork.

We will execute these steps in order.

## Current Baseline

Already implemented:

- guided entry flow
- `Beginner Course` / `Experienced Path` shell
- daily guided session blocks
- phrase-level audio evaluation
- wait-mode oriented practice UI
- interactive practice tools inside the practice screen
- skill mastery snapshot
- AI + teacher review surface
- persisted attempts, recordings, and mastery

This means the next work should focus on making the product loop smarter, more adaptive, and more retention-oriented.

## Priority Order

### 1. Adaptive Practice Engine

Goal:
- make every learner attempt change the next session in a visible and useful way

Why first:
- this is the core intelligence layer
- it turns the app from a guided flow into a responsive coach
- it gives meaning to `mastery`, `retry block`, `confidence`, and `teacher review`

Scope:
- choose one weakest skill after each attempt
- adjust next-day `focus`, `target_bpm`, `loop_target`, and `wait_mode`
- route learners into the right retry block:
  - `warm_up`
  - `note_fingering`
  - `rhythm_call_response`
  - `record_check`
- support rule-based difficulty upgrades when mastery is stable
- support rule-based slowdowns when rhythm or pitch drops

Done when:
- the next session is materially different after weak vs strong attempts
- the user can understand why the session changed
- backend and mobile are aligned on the same adaptation rules

Primary files to touch:
- `services/api/app/services/practice_sessions.py`
- `services/api/app/services/mastery.py`
- `services/api/app/services/evaluation.py`
- `services/api/app/services/mock_content.py`
- `apps/mobile/lib/features/home/home_screen.dart`
- `apps/mobile/lib/features/practice/practice_screen.dart`

### 2. Real Session Runner

Goal:
- replace the feeling of “many connected screens” with one coherent guided practice runner

Why second:
- the current product flow works, but still feels screen-based
- this step upgrades the user experience from app navigation to a true lesson loop

Scope:
- build a single session runner for:
  - `warm_up`
  - `note_fingering`
  - `rhythm_call_response`
  - `record_check`
- preserve:
  - metronome
  - playback presets
  - wait mode
  - loop counting
  - visual phrase flow
  - result handoff
- reduce unnecessary route hopping between lesson screens
- make the user always know:
  - where they are
  - what is next
  - what counts as completion

Done when:
- a beginner can finish the full daily session from one continuous runner
- every block has a clear state:
  - ready
  - active
  - retry
  - done
- session completion logic is explicit and stable

Primary files to touch:
- `apps/mobile/lib/features/practice/`
- `apps/mobile/lib/features/lessons/`
- `apps/mobile/lib/features/results/results_screen.dart`
- `apps/mobile/lib/data/models/practice_session.dart`

### 3. Mastery Timeline

Goal:
- make progress visible across days instead of showing only snapshots

Why third:
- visible growth is one of the strongest retention drivers
- the app already computes useful signals, but the learner still cannot see the trend clearly

Scope:
- show history for core skills:
  - `tone`
  - `breath`
  - `fingering`
  - `note_accuracy`
  - `rhythm`
  - `response_imitation`
- surface:
  - strongest improving skill
  - weakest flat skill
  - current plateau
  - recommended next drill
- add time-based progression views inside `Progress`
- make attempt history explain mastery movement, not just scores

Done when:
- the learner can see what is improving and what is stuck
- the progress screen can answer:
  - what improved this week?
  - what is still unstable?
  - what should I train next?

Primary files to touch:
- `services/api/app/services/persistence.py`
- `services/api/app/services/mastery.py`
- `services/api/app/schemas/mastery.py`
- `apps/mobile/lib/features/progress/progress_screen.dart`
- `apps/mobile/lib/features/progress/attempt_details_screen.dart`

### 4. Teacher Review Workflow

Goal:
- turn the current teacher-review surface into a usable feedback workflow

Why fourth:
- the current layer is a strong start, but it is still a product stub
- this step makes `ArtistWorks`-style feedback more real and monetizable

Scope:
- track review state more explicitly:
  - available
  - requested
  - in_review
  - responded
- store teacher note payloads
- show teacher response history beside AI summary
- keep AI summary as the fast layer and teacher review as the deep layer

Done when:
- a learner can request review and later see a returned coaching note
- the UI makes clear what came from AI and what came from teacher review

Primary files to touch:
- `services/api/app/services/teacher_review.py`
- `services/api/app/services/persistence.py`
- `services/api/app/api/routes/attempts.py`
- `apps/mobile/lib/features/results/results_screen.dart`
- `apps/mobile/lib/features/progress/attempt_details_screen.dart`

### 5. Content Scaling System

Goal:
- make it practical to grow from the current early-course material into a larger curriculum

Why fifth:
- once adaptation and runner quality are strong, content quantity becomes the next multiplier

Scope:
- normalize reusable drill definitions
- author more stages and beginner session packs
- separate product logic from raw content data more cleanly
- make exercise metadata rich enough for:
  - adaptation
  - scoring
  - playback
  - retry logic

Done when:
- new days and drills can be added without touching core logic every time
- stage progression remains consistent as content grows

Primary files to touch:
- `services/api/app/services/mock_content.py`
- `services/api/app/services/curriculum_sources.py`
- `apps/mobile/lib/shared/education/`

### 6. Retention Analytics + Beta Readiness

Goal:
- measure where learners drop, stall, or succeed before wider release

Why sixth:
- this step matters most after the core product loop is stable

Scope:
- detect likely drop-off points
- log adaptation outcomes
- compare completion before and after runner/adaptation changes
- prepare a manual QA checklist for the new loop
- run real-device validation for recording, persistence, and progression

Done when:
- we can answer where learners fail to continue
- we can prioritize fixes based on real behavior, not guesswork

Primary files to touch:
- `services/api/app/api/routes/analytics.py`
- `services/api/app/services/persistence.py`
- `apps/mobile/lib/features/progress/progress_screen.dart`
- `docs/MANUAL_TESTING.md`
- `docs/BETA_RELEASE_CHECKLIST.md`

## Working Rule

We should not split effort equally across all six steps.

Execution order should be:

1. `Adaptive Practice Engine`
2. `Real Session Runner`
3. `Mastery Timeline`
4. `Teacher Review Workflow`
5. `Content Scaling System`
6. `Retention Analytics + Beta Readiness`

## Immediate Next Build

If work starts now, begin with:

`Adaptive Practice Engine`

That is the highest-leverage next move because it makes the existing V2 foundation behave like a real coach instead of a guided but mostly static curriculum.
