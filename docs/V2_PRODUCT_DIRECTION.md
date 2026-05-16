# V2 Product Direction

Date: 2026-05-10

## Current Verification Snapshot

The codebase is currently stable at the automated-check level:

- `services/api`: `23` tests passed
- `services/audio-engine`: `7` tests passed
- `apps/mobile`: `flutter analyze` passed with no issues
- `apps/mobile`: `flutter test` passed with `24` tests

This means the biggest blockers for the next iteration are product shape and learning design, not a broken technical base.

## Main V2 Problems To Solve

### 1. Entry experience is still unclear

The current app already has several useful surfaces, but the learner still has to understand too much too early:

- daily flow
- foundation
- jazz academy
- 30-day curriculum
- practice room
- settings

V2 should make the first choice explicit:

- `Beginner Course`
- `Experienced Path`
- `Theory Intro`
- `Settings`

The user should understand in a few seconds where to start and why.

### 2. Jazz content is too text-heavy

The current jazz area has structure, concepts, pillars, and educational language, but it still feels more like reading than training.

V2 should shift the jazz experience to:

- shorter explanations
- more playable drills
- more repetition-based exercise chains
- clearer listening tasks
- record-and-respond loops
- stronger progression from one exercise to the next

### 3. Jazz should become the product base

If the target direction is closer to a `tonestro`-style learning product, then the jazz path cannot remain a side area.

V2 should treat jazz as a primary system with:

- a guided core path
- progressive unlocking
- daily playable tasks
- clear levels
- measurable repetition
- audio feedback checkpoints

## Recommended V2 Structure

### Track 1: Beginner Course

Goal: get a new player producing stable sound and surviving the first practice loop.

Should include:

- setup and posture
- breath and tone center
- first notes
- fingering confidence
- slow rhythm basics
- short call-and-response drills

### Track 2: Experienced Path

Goal: let returning or stronger players skip the earliest setup material.

Should include:

- warm-up routing
- daily practice generator
- jazz skill tree
- direct access to focused work such as time, articulation, blues, and ii-V-I

### Track 3: Theory Intro

Goal: explain the music idea quickly, then send the learner into an actual drill.

Should include:

- very short concept cards
- one listening example
- one sing-it task
- one play-it task
- one improvise-it task

## Jazz Content Rules For V2

Every jazz lesson should answer the product question:

`What do I do with the horn right now?`

That means each lesson should contain:

- one clear exercise goal
- one exact note or rhythm target
- one backing or pulse context
- one recording checkpoint
- one retry instruction

Avoid long theory blocks unless they immediately unlock a playable task.

## Suggested Implementation Order

1. Simplify the home entry so course selection is obvious.
2. Rebuild the jazz start path into exercise-first lessons.
3. Convert reading-heavy jazz screens into drill sequences.
4. Add stronger progress states for each track.
5. Tie audio feedback to course progression instead of only isolated practice results.
