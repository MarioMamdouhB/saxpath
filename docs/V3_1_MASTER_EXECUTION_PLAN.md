# V3.1 Master Execution Plan

Date: 2026-05-12

This document is the unified execution plan for `SaxPath V3.1`.

It combines the direction from:

- `docs/V3_USER_JOURNEY_PLAN.md`
- `docs/V3_1_CONTENT_DATA_ROADMAP.md`
- `docs/V3_1_NOTATION_CURRICULUM_ROADMAP.md`

into one practical build order.

## Executive Decision

The best direction for `V3.1` is not to make the app bigger.

The best direction is to make it:

- clearer
- deeper
- safer legally
- more practical musically
- centered on one real beginner journey

So `V3.1` should focus on this product promise:

`An Arabic-first guided beginner saxophone course with a complete note-reading and rhythm foundation, practical drills inside the app, and a single coherent session loop.`

## What V3.1 Is

`V3.1` is the version where SaxPath stops feeling like:

- several useful screens
- mixed curriculum surfaces
- partial beginner flow
- scattered notation/rhythm drills

and starts feeling like:

- one structured beginner course
- one strong notation path
- one content system
- one clear learner loop

## What V3.1 Is Not

`V3.1` should not try to fully complete every track in the product.

It should not be:

- full jazz academy completion
- full oriental curriculum completion
- a giant content library
- a teacher marketplace
- a broad premium media platform

Those are later layers.

## Core Product Thesis

The beginner must be able to open the app and understand:

1. what today’s task is
2. what note or rhythm they are training
3. how to tap it
4. how to play it
5. how to record it
6. what to do next

If `V3.1` achieves this reliably, the product becomes much stronger.

## Recommended V3.1 Scope

### Must Ship In V3.1

- one stable shell: `Today / Learn / Practice / Progress`
- one strong `Beginner Core` path
- one full `Notation Beginner` path
- required `Tap / Clap / Count` blocks inside notation and rhythm work
- original or safely licensed core learner assets
- backend-aware content registry and publish safety rules
- one session runner that can carry the learner through practical blocks
- practical recording checkpoints and retry loops

### Should Start In V3.1 But Does Not Need Full Completion

- `Notation Intermediate` early modules
- `Jazz Foundations` restructuring into drill-first form
- adaptive retry logic for weak rhythm or note reading
- stronger progress explanations for notation and beginner skill growth

### Explicitly Deferred

- full `Notation Professional` completion
- full `Jazz Foundations` catalog completion
- full `Oriental Maqam` track
- teacher review workflow as a major product layer
- deep external content partnership workflows

## The Five V3.1 Pillars

### Pillar 1: Core Learner Loop

The learner path should become:

`Today -> Session Runner -> Results -> Progress -> Today`

This is the operational core of V3.1.

### Pillar 2: Beginner Core Curriculum

This is the most important content investment.

It should become the deepest and clearest path in the app.

### Pillar 3: Notation + Rhythm System

Notation should become a real training path, not a small lab.

It should include:

- note reading
- value reading
- rest reading
- counting
- tapping
- clapping
- one-note rhythm performance
- reading on the horn

### Pillar 4: Content + Rights System

All learner-facing content must become:

- source-aware
- rights-aware
- publish-safe
- placed in the curriculum intentionally

### Pillar 5: Practical Feedback + Retry

The learner should always know:

- what was weak
- what to repeat
- what changed next

## Product Architecture Decision

`V3.1` should organize learning as:

1. `Track`
2. `Stage`
3. `Session Pack`
4. `Drill`
5. `Record Check`
6. `Unlock Rule`

This structure should be shared by:

- `Beginner Core`
- `Notation Path`
- later `Jazz Foundations`

## V3.1 Tracks

### Track 1: Beginner Core

This is the main ship-ready track for V3.1.

It should include:

- setup and posture
- breath and tone center
- first notes
- fingering confidence
- one-note rhythm
- first reading cells
- short playable phrases
- review and record checkpoints

### Track 2: Notation Path

This should live under `Learn`, but also feed the daily loop.

For V3.1:

- `Beginner` notation should be complete
- `Intermediate` notation should begin
- `Professional` notation should be planned, not required for ship

### Track 3: Jazz Foundations

This should be reduced in scope for V3.1 and rebuilt in a more playable way.

The focus in V3.1 is not catalog size.

The focus is:

- drill-first structure
- less text
- stronger record-and-retry loops

## Notation Scope Decision

The full three-level notation vision remains valid.

But the most realistic and strongest shipping decision is:

### V3.1 Ship Target

- `Notation Beginner`: complete
- `Notation Intermediate`: first modules shipped
- `Notation Professional`: roadmap only

This is the best scope because it creates a complete learner win without overextending the team.

## Workstreams

V3.1 should run through five coordinated workstreams.

### Workstream A: Product Structure

Owns:

- shell cleanup
- navigation
- learner loop
- screen ownership

### Workstream B: Curriculum Authoring

Owns:

- beginner session packs
- notation lessons
- rhythm drills
- retry logic wording

### Workstream C: Content Data + Rights

Owns:

- source records
- content assets
- publish gating
- attribution logic
- blocked asset rules

### Workstream D: Media Production

Owns:

- original audio demos
- original micro-videos
- notation visual snippets
- rhythm clap/count demos

### Workstream E: Feedback + Progress

Owns:

- retry instructions
- mastery signals
- notation progress states
- next recommended drill logic

## Phase Plan

### Phase 0: V3.1 Contract

Goal:

- lock the scope before building more surfaces

Build:

- confirm V3.1 as `Beginner-first`
- confirm notation beginner completion as a shipping requirement
- confirm content rights rules as mandatory
- confirm deferred items

Done when:

- the team can say in one sentence what V3.1 ships

### Phase 1: Content System Foundation

Goal:

- create one clean foundation for publishable curriculum

Build:

- content source registry
- content asset model
- curriculum node model
- review state model
- publish gating rules

Done when:

- every learner-facing core asset can be classified and tracked

### Phase 2: Beginner Core Spine

Goal:

- turn the beginner experience into a real course

Build:

- beginner stages
- 14 to 30 connected session packs
- practical drill chains
- record checkpoints
- review days

Done when:

- the main path feels like a course, not a short demo flow

### Phase 3: Notation Beginner System

Goal:

- make notation foundational and practical

Build:

- staff basics
- first notes on staff
- pulse and counting
- note values
- rests
- first reading cells
- tap/clap/count drill blocks
- notation-linked horn drills

Done when:

- a beginner can go from first symbol to short playable reading phrases inside the app

### Phase 4: Session Runner Integration

Goal:

- stop route-hopping and unify practice flow

Build:

- session runner supports beginner and notation blocks
- count-in and rhythm support stay coherent
- playback, metronome, and record flow stay in one guided sequence

Done when:

- the learner can finish a session without feeling moved across unrelated pages

### Phase 5: Progress + Retry Layer

Goal:

- make the product teach through repetition, not just expose content

Build:

- notation progress states
- weakest-skill explanation
- retry block recommendation
- one next-step recommendation

Done when:

- the learner can clearly understand what to repeat next

### Phase 6: Intermediate Starter + Jazz Restructure

Goal:

- extend learning without losing clarity

Build:

- early intermediate notation modules
- jazz modules rewritten into drill-first structure
- better rhythm-driven and phrase-driven practical tasks

Done when:

- the app expands without returning to text-heavy sprawl

### Phase 7: Beta Hardening

Goal:

- make V3.1 safe for real learner testing

Build:

- blocked-asset checks
- QA pass on session packs
- learner-flow smoke tests
- rights audit for all shipped assets

Done when:

- the shipped path is coherent, playable, and legally cleaner

## Recommended Build Order

The best execution order is:

1. `Content System Foundation`
2. `Beginner Core Spine`
3. `Notation Beginner System`
4. `Session Runner Integration`
5. `Progress + Retry Layer`
6. `Intermediate Starter + Jazz Restructure`
7. `Beta Hardening`

This order is better than starting with broad content expansion because it prevents more scattered surfaces from being added on top of a weak structure.

## Primary Deliverables

### Deliverable A

`V3.1` shell with:

- `Today`
- `Learn`
- `Practice`
- `Progress`

### Deliverable B

`Beginner Core` course with:

- stage map
- session packs
- practical drills
- recording checkpoints

### Deliverable C

`Notation Beginner` path with:

- lesson ladder
- tap/clap/count trainer
- note-reading drills
- rhythm-reading drills

### Deliverable D

Content safety system with:

- source metadata
- license states
- publish gating
- blocked asset handling

### Deliverable E

Retry and progress layer with:

- one weak-skill recommendation
- one retry drill
- one next-step recommendation

## Suggested File Targets

Most likely implementation zones:

- `apps/mobile/lib/features/home/`
- `apps/mobile/lib/features/session/`
- `apps/mobile/lib/features/practice/`
- `apps/mobile/lib/features/progress/`
- `apps/mobile/lib/features/academy/`
- `apps/mobile/lib/features/lessons/`
- `apps/mobile/lib/shared/education/`
- `apps/mobile/lib/data/models/`
- `services/api/app/services/mock_content.py`
- `services/api/app/services/curriculum_sources.py`
- `services/api/app/services/`
- `services/api/app/schemas/`

## Release Gates

V3.1 should not be considered ready unless all of these are true:

- the beginner path is clearly stronger than the current short daily flow
- notation training is practical, not mostly descriptive
- tap/clap/count exists as a real system, not just a sentence in lessons
- every learner-facing core asset has a known rights state
- no blocked media can appear in the main loop
- the learner can move through a full daily session in one coherent path

## Now / Next / Later

### Now

- finalize V3.1 as `Beginner-first`
- build the content data foundation
- author the `Beginner Core` spine
- ship `Notation Beginner`
- enforce original-or-safe core media policy
- connect everything into one session loop

### Next

- add `Notation Intermediate` early modules
- improve progress and retry intelligence
- restructure `Jazz Foundations` into playable drill chains
- strengthen adaptive session behavior

### Later

- `Notation Professional`
- full `Jazz Foundations` expansion
- `Oriental Maqam`
- teacher review workflow
- deeper external partnerships and licensed media programs

## Final Recommendation

If the team wants the strongest V3.1, the answer is:

Do not spread effort evenly.

Put most of the effort into:

1. `Beginner Core`
2. `Notation Beginner`
3. `Session Runner`
4. `Content safety system`

That combination gives SaxPath the best chance to feel like a real learning product instead of a promising but scattered prototype.
