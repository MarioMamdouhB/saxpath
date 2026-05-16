# V3 User Journey Plan

Date: 2026-05-12

This document reorganizes the learner journey for `SaxPath V3` so the app feels guided, not scattered.

It is based on the current product shape in:

- `apps/mobile/lib/features/onboarding/`
- `apps/mobile/lib/features/auth/`
- `apps/mobile/lib/features/home/`
- `apps/mobile/lib/features/session/`
- `apps/mobile/lib/features/academy/`
- `apps/mobile/lib/features/foundation/`
- `apps/mobile/lib/features/progress/`
- `apps/mobile/lib/shared/education/`
- `services/api/app/services/mock_content.py`
- `docs/NEXT_PRODUCT_EXECUTION_ORDER.md`

## Problem We Need To Fix

Right now the app has good building blocks, but the learner can still feel lost because:

- there is more than one starting point
- the app mixes `main path`, `supporting paths`, `tools`, and `reference content` too early
- onboarding asks useful questions, but that context does not fully drive the next screen
- the learner still moves between many separate screens instead of feeling one continuous lesson loop
- `Home`, `Course Shell`, `Library`, `Practice Room`, `Jazz Academy`, `Foundation`, and `Progress` can all feel like competing doors
- the core daily API flow still behaves like a short authored sequence while other curriculum systems live elsewhere
- content exists in multiple parallel systems instead of one curriculum source of truth
- some jazz and theory areas still feel more readable than playable

This is now both a navigation problem and a content-architecture problem.

## V3 Product Principle

`One learner = one next step.`

At any moment, V3 should answer only these questions:

1. Where am I now?
2. What should I do next?
3. Why is this the next step?
4. What optional things can I explore later?

## Content Reality Check

The current repo does not have a pure "lack of content" problem.

It has a `content organization` problem:

- the API daily flow is still the most visible learner path, but it is effectively much smaller than the broader authored material
- the `foundation` repository already contains meaningful beginner drills, note work, and scale work
- the `curriculum_service` already contains a larger 30-day shaped program
- the `jazz` repository already contains a lot of authored material, but part of it still feels too explanatory and not drill-first
- these systems are not yet arranged into one progressive ladder that the learner can feel

So the V3 content mission is not only to add more material.

It is to:

1. unify content sources
2. make progression clearer
3. make lessons more playable
4. expand the core path only after the structure is stable

## V3 Content Principles

- content must feel like a curriculum, not a collection
- each track must have visible progression
- every lesson must end in a playable action
- reference content must support lessons, not compete with them
- theory must be compressed into action-oriented cards
- beginner content must be the strongest and deepest path in the current stage
- expansion should happen through reusable session packs, not one-off screens

## V3 Content Rules

Every core lesson should answer:

`What do I do with the horn right now?`

That means the lesson should contain:

- one clear exercise goal
- one exact note, rhythm, or phrase target
- one pulse or backing context
- one repetition instruction
- one recording checkpoint
- one retry instruction

Avoid:

- long explanation before action
- theory-only lessons
- duplicate drills spread across separate screens
- unlocked exploration before the core path is stable

## Target Content Architecture

V3 should treat content as one ladder:

1. `Track`
2. `Stage`
3. `Session Pack`
4. `Drill`
5. `Record Check`
6. `Unlock Rule`

This should replace the feeling of disconnected lesson islands.

### Track

Examples:

- `Beginner Core`
- `Jazz Foundations`
- `Theory Into Practice`
- `Oriental Maqam` later

### Stage

Examples:

- setup and posture
- tone center
- first five notes
- one-note rhythm
- phrase control
- call and response
- first blues language

### Session Pack

A small authored practice unit with:

- a main focus
- 3 to 5 drills
- one completion condition
- one retry path

### Drill

A single playable block such as:

- long tone
- fingering switch
- one-note rhythm loop
- short phrase echo
- guided improv cell

### Record Check

Every meaningful session pack should have a recording or performance checkpoint.

### Unlock Rule

Unlocking should be based on:

- completion
- repetition stability
- score threshold
- recovery after weakness

## Content Priorities For The Current Stage

V3 should prioritize content in this order:

1. `Beginner Core`
2. `Jazz Foundations`
3. `Theory Into Practice`
4. `Oriental Maqam`
5. deep reference/library expansion

### Beginner Core

Needs:

- the deepest authored path right now
- clear stage progression
- 14 to 30 connected session packs
- strong repetition and review logic
- simple but meaningful recording checkpoints

### Jazz Foundations

Needs:

- less reading
- more drill chains
- stronger listen -> play -> record loops
- cleaner progression between modules

### Theory Into Practice

Needs:

- very short concept cards
- one listening task
- one sing-it task
- one play-it task
- one improvise-it task

### Oriental Maqam

Should not be treated as an equal first-day entry yet.

It should arrive after the core V3 ladder is stable.

## V3 Experience Rules

- `Today` is the primary surface, not just one card among many.
- `Session Runner` is the real core product loop.
- `Learn` is for structured curriculum, not mixed with tools.
- `Practice Tools` is a utility area, not a second curriculum.
- `Progress` explains growth and recommends the next drill.
- `Library/Reference` must stay behind the main loop, not beside it.
- The first-time learner should never need to choose from many equal-looking paths.

## Target Information Architecture

V3 should use one stable shell with four top-level areas:

1. `Today`
2. `Learn`
3. `Practice`
4. `Progress`

Optional fifth area later:

5. `Profile`

### 1. Today

Purpose:
- resume the current guided session
- show current focus
- explain why this session was chosen

Contains:
- one main CTA: `Start Session` or `Continue Session`
- daily focus summary
- adaptation reason
- current streak / goal
- one small card for "after this session, do..."

Must not contain:
- large lists of alternative destinations
- full library access
- many equal-priority cards

### 2. Learn

Purpose:
- show the learner's structured path clearly

Contains:
- current track map
- unlocked stages
- completed stages
- optional branch cards only after the main path is clear
- a clear split between `core sessions` and `supporting references`

Subsections:
- `Beginner Path`
- `Jazz Path`
- `Theory Path`
- `Oriental Path` later, only if the learner opted into it

Important rule:
- tracks are curriculum containers, not app homepages

### 3. Practice

Purpose:
- give free tools without breaking the main learning path

Contains:
- tuner
- metronome
- recording lab
- note lab
- warm-up utilities

Important rule:
- this area supports the lesson loop, but does not replace it

### 4. Progress

Purpose:
- explain growth, weakness, and next action

Contains:
- mastery timeline
- attempt history
- current weak skill
- recommended retry drill
- streak and completion summaries
- later: AI review vs teacher review

Important rule:
- progress should answer "what do I train next?" not only "what happened before?"

## Canonical User Journeys

V3 should be built around four main user states.

### Journey A: First-Time Beginner

Flow:

1. `Welcome`
2. `Onboarding`
3. `Profile Confirmation`
4. `Assigned Track`
5. `Today`
6. `Session Runner`
7. `Results`
8. `Progress Snapshot`
9. `Return to Today`

Rules:

- onboarding should save actual learner choices
- the app should recommend one track, not present four equal decisions
- after onboarding, the learner lands in `Today`, not in a content marketplace

### Journey B: Returning Learner

Flow:

1. `Open App`
2. `Today`
3. `Continue Session`
4. `Results`
5. `Next Recommended Step`

Rules:

- no re-orientation cost
- show current block and percent complete immediately
- if the learner stopped mid-session, resume the exact block

### Journey C: Stuck Learner

Flow:

1. `Today`
2. learner sees "why this changed"
3. `Retry Session` opens at the weak block
4. learner gets one recommended drill
5. after completion, return to updated progress

Rules:

- weakness should trigger a focused recovery path
- no manual hunting across library, tools, and lessons

### Journey D: Explorer / Advanced Learner

Flow:

1. `Learn`
2. open a structured path or pillar
3. jump into a targeted session or drill
4. review progress impact

Rules:

- exploration is allowed, but should not distort the beginner default journey

## Navigation Model

V3 should distinguish between `primary navigation` and `contextual actions`.

### Primary Navigation

Only four stable items:

- `Today`
- `Learn`
- `Practice`
- `Progress`

### Contextual Actions

Shown inside screens, not in the main nav:

- `Change Track`
- `Open Tuner`
- `Retry Weak Skill`
- `View Full History`
- `Open Reference`

This keeps the shell stable while still allowing deep actions.

## Recommended V3 Screen Ownership

### Today owns

- session readiness
- current focus
- adaptation explanation
- resume / continue / finish session

### Session Runner owns

- all intra-session steps
- warm-up
- note/fingering
- rhythm call-response
- record check
- completion state

### Learn owns

- stage map
- track overview
- session pack progression
- optional curriculum browsing

### Practice owns

- standalone utilities
- drills outside the mandatory daily flow

### Progress owns

- timelines
- history
- weak-skill explanation
- recommendations

## Migration Map From Current Screens

Current screens should be consolidated like this:

| Current area | V3 destination | Action |
| --- | --- | --- |
| `OnboardingQuestionnaireScreen` | `Onboarding` | keep, but persist answers and connect them to track assignment |
| `LoginScreen` | `Auth` | keep minimal; do not make it a product decision point |
| `V2CourseShellScreen` | split between `Today`, `Learn`, and `Profile` | reduce it from a destination hub to a light routing layer |
| `HomeScreen` | `Today` | keep as the main dashboard, but remove equal-priority detours |
| `GuidedSessionRunnerScreen` | `Session Runner` | expand; this becomes the true center of the app |
| `PracticeRoomScreen` + tool-like practice surfaces | `Practice` | consolidate tools here |
| `LibraryScreen` | secondary content inside `Learn` | demote from primary surface |
| `JazzAcademyScreen`, `Foundation`, `MvpCurriculumScreen` | `Learn` | keep as track content, not separate app entrances |
| `ProgressScreen` | `Progress` | keep and deepen with timeline + next drill logic |
| `services/api/app/services/mock_content.py` | `Content engine` | expand from short daily authored flow into stage/session-pack aware content |
| `apps/mobile/lib/shared/education/curriculum_service.dart` | `Content engine` | reuse as a structured authored curriculum source instead of parallel isolated content |
| `apps/mobile/lib/shared/education/sax_foundation_repository.dart` | `Beginner Core` | convert into canonical beginner drills and session packs |
| `apps/mobile/lib/shared/education/jazz_curriculum_repository.dart` | `Jazz Foundations` | keep rich authored material, but refactor drill-first and stage-first |

## V3 Rollout Plan

This plan should align with the existing execution order, but give it a stronger UX and content frame.

### Phase 1: Content Architecture Pass

Goal:
- create one curriculum source of truth before adding more surface area or intelligence

Build:
- choose the canonical authored content ladder for V3
- map `mock_content`, `foundation`, `curriculum_service`, and `jazz` content into one structure
- define shared metadata for drills, retry rules, unlock rules, BPM, expected notes, and skill areas
- separate `core lesson`, `support drill`, `theory card`, `reference`, and `assessment`

Done when:
- new content can be added without creating a new screen system
- the team can explain exactly where a drill lives in the curriculum

### Phase 2: Beginner Core Expansion

Goal:
- strengthen the most important path before broadening the rest of the product

Build:
- expand the core beginner ladder into connected session packs
- turn existing foundation drills into progressive daily or stage-based loops
- make the visible main path feel deeper than the current short API flow
- keep recording checkpoints and review days inside the authored sequence

Done when:
- the beginner path feels like a real course, not a demo week plus side content
- the learner can move through a clear early progression without content gaps

### Phase 3: Navigation Cleanup

Goal:
- make the product feel understandable once the content spine is defined

Build:
- define the four top-level V3 sections
- simplify `V2CourseShellScreen` into a stable app shell
- move optional destinations out of the first screen
- persist onboarding choices and selected track properly

Done when:
- a new learner can explain the app in one sentence
- the first screen has one obvious next action

### Phase 4: Today Becomes The Command Center

Goal:
- turn `Home` into the single source of truth for what to do now

Build:
- one primary CTA
- current session status
- current focus and reason
- one small optional "after this" recommendation

Done when:
- returning users no longer need to choose among multiple equal cards

### Phase 5: Session Runner Becomes The Product

Goal:
- reduce route hopping and make learning feel continuous

Build:
- full block-based runner
- clear state per block: `ready`, `active`, `retry`, `done`
- session resume support
- explicit completion handoff to results

Done when:
- the learner can finish the daily loop without feeling moved between unrelated pages

### Phase 6: Adaptive Practice Engine

Goal:
- make the next session change meaningfully after each attempt

Build:
- choose one weakest skill after each attempt
- route the learner into the right retry block
- change focus, BPM, loop target, and wait mode visibly
- explain the reason for adaptation inside `Today` and `Progress`

Done when:
- users can feel why tomorrow's session changed
- weak and strong attempts produce meaningfully different session behavior

### Phase 7: Learn Gets Structured

Goal:
- keep discovery, but make it orderly after the core loop is stable

Build:
- track map
- stage progression
- unlocked vs locked content
- track switching from one controlled place

Done when:
- `Learn` feels like a curriculum map, not a content dump

### Phase 8: Practice + Progress Support Retention

Goal:
- support habit and recovery without adding confusion

Build:
- tool hub inside `Practice`
- mastery timeline inside `Progress`
- weak-skill retry CTA
- clearer history and recommendations

Done when:
- users know both how they are doing and what to do next

### Phase 9: Teacher Review + Analytics

Goal:
- deepen feedback and measure real behavior after the core V3 loop is stable

Build:
- teacher review states and response history
- analytics for start, drop-off, retry, and completion
- beta-readiness validation for the new loop

Done when:
- the team can see where users stall
- advanced feedback no longer feels like a disconnected stub

## What V3 Should Explicitly Avoid

- opening with multiple equal primary paths
- mixing curriculum, tools, and references on the same first screen
- sending the learner to many route hops for one session
- exposing advanced exploration before the core loop is understood
- creating a new top-level section for every feature
- expanding library breadth before the core ladder feels strong
- adding more authored content without shared metadata and placement in the ladder

## Product KPI Check

We should treat the redesign as successful if it improves:

- time to first session start
- session completion rate
- number of taps before first useful action
- day-2 return clarity
- percent of learners who use `Today` as their default entry
- number of complete session packs available in the canonical core path
- percentage of lessons that end in recording or measurable drill completion

## Now / Next / Later

### Now

- run a `content architecture pass` and decide the canonical V3 content source of truth
- expand `Beginner Core` into the strongest connected path in the product
- persist onboarding answers and selected track properly
- simplify the app shell into `Today / Learn / Practice / Progress`
- make `Today -> Session Runner -> Results -> Progress` the canonical loop

### Next

- complete the real session runner and reduce route hopping
- add the adaptive practice engine on top of the stabilized content ladder
- restructure `Learn` into stage maps and session packs
- make `Jazz Foundations` more drill-first and less text-heavy
- turn `Progress` into a real recommendation surface, not only a history view

### Later

- teacher review workflow
- retention analytics and beta-readiness instrumentation
- `Oriental Maqam` expansion
- deeper library/reference organization
- broader content scaling after the core authoring system is proven

## Immediate Build Recommendation

If we start now, the best V3 move is:

1. unify content architecture
2. strengthen `Beginner Core`
3. persist onboarding answers
4. simplify the app shell into `Today / Learn / Practice / Progress`
5. make `Today -> Session Runner -> Results -> Progress` the canonical loop

That sequence solves both the feeling of being lost and the feeling that the content spine is still too weak or too scattered.
