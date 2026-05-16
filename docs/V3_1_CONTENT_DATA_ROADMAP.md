# V3.1 Content + Data Roadmap

Date: 2026-05-12

This document turns the content-sourcing, content-rights, and curriculum-scaling discussion into a concrete `V3.1` build plan for `SaxPath`.

The goal is not only to add more content.

The goal is to make content:

- legally safer
- structurally clearer
- easier to scale
- implemented inside the product workflow itself

## V3.1 Goal

`SaxPath V3.1` should treat content as a product system, not a loose collection of lessons, references, and media.

By the end of V3.1, the app should know:

1. where every learning asset came from
2. whether it is safe to publish
3. whether it is original, open-licensed, or permission-based
4. where the asset sits in the learner curriculum
5. whether the asset is a lesson, drill, reference, assessment, audio demo, or video

## Core Decision

Universities and institutions should be used as:

- curriculum references
- level-structure references
- skill-sequencing references
- source inspiration for pedagogy

They should not be used as a default source for:

- copied lesson text
- copied slides or PDFs
- copied exercises
- embedded lecture videos
- downloaded recordings
- copied etudes, lead sheets, or protected notation

## Practical Rights Rule

Use this rule everywhere in V3.1:

`Ideas and curriculum structures are reusable references. Expression and media assets require rights.`

That means:

- use the sequence
- do not copy the wording
- use the concept
- do not copy the PDF
- use the skill ladder
- do not reuse the video unless the license clearly allows it

## Source Categories

All sources should be classified into one of these categories:

### 1. Reference-Only Sources

Use for:

- university curriculum pages
- public degree bulletins
- skill lists
- level descriptions
- course outlines

Allowed:

- summarizing
- extracting learning objectives
- extracting progression logic
- building original SaxPath lessons from them

Not allowed by default:

- copying text verbatim into the app
- rehosting downloadable material
- embedding or mirroring videos without clear license

### 2. Open-Licensed Sources

Use for:

- OER material
- Creative Commons assets
- public-domain assets

Allowed only if:

- the exact asset license is known
- the license is compatible with intended product use
- attribution rules are stored and applied

### 3. Permission-Based Sources

Use for:

- strategically important videos
- custom masterclass material
- partner institution content
- teacher-created media not released under an open license

Allowed only if:

- SaxPath has written permission
- the scope of use is documented
- the asset record stores proof of permission

### 4. Original SaxPath Assets

Preferred default for V3.1:

- original lesson text
- original drills
- original diagrams
- original finger charts
- original audio demos
- original video clips

## Licensing Rules For V3.1

Every media or downloadable asset must carry one of these statuses:

- `original`
- `cc0`
- `cc_by`
- `cc_by_sa`
- `cc_by_nc`
- `cc_by_nc_sa`
- `permission_granted`
- `reference_only`
- `unknown_blocked`

### Safe Defaults

Treat these as safer defaults:

- `original`
- `cc0`
- `cc_by`
- `permission_granted`

### Use With Caution

These may be usable, but only with explicit product review:

- `cc_by_sa`

### Avoid For Commercial Product Surfaces

These should not be part of the default commercial product path unless legal/product review says otherwise:

- `cc_by_nc`
- `cc_by_nc_sa`

### Never Publish By Default

- `unknown_blocked`
- any university asset with no explicit open license
- standard YouTube videos

## Video Policy

V3.1 should assume:

- `YouTube Standard License` videos are not reusable inside the product
- `YouTube CC BY` videos may be reusable only if the exact video is clearly marked and attribution is stored
- university course videos are not safe by default unless the institution publishes them under a compatible open license
- even open videos should not become the foundation of the learner experience unless the product intentionally supports attribution and license constraints

## Content Strategy For SaxPath

### What We Should Take From Universities

- beginner progression order
- skill ladders
- level expectations
- stage objectives
- method-book awareness
- theory sequence
- ensemble and checkpoint logic

### What We Should Build Ourselves

- Arabic lesson text
- drill wording
- rhythm prompts
- call-and-response patterns
- beginner session packs
- jazz exercise chains
- audio demos
- performance checkpoints
- short teaching videos

### What We Should Request Permission For

- rare strategic partner content
- guest teacher videos
- branded collaboration content
- premium feedback media

## V3.1 Product Requirement

All of this should live inside the application system, not only in docs.

That means V3.1 needs:

1. content source records
2. asset rights metadata
3. publish gating
4. attribution support
5. curriculum placement metadata
6. internal review states

## Target Content Data Model

V3.1 should add or normalize the following product concepts.

### SourceRecord

Represents where a lesson idea or asset came from.

Suggested fields:

- `id`
- `title`
- `institution`
- `source_type`
- `url`
- `license_type`
- `commercial_use_allowed`
- `adaptation_allowed`
- `attribution_required`
- `notes`
- `verification_status`

### ContentAsset

Represents an actual product asset.

Suggested fields:

- `id`
- `asset_type`
- `title`
- `language`
- `owner_type`
- `license_status`
- `source_record_ids`
- `permission_document_ref`
- `attribution_text`
- `file_path_or_url`
- `publish_status`

### CurriculumNode

Represents where the content lives in the learner journey.

Suggested fields:

- `id`
- `track_id`
- `stage_id`
- `session_pack_id`
- `drill_type`
- `skill_areas`
- `difficulty`
- `expected_notes`
- `rhythm_target`
- `target_bpm`
- `retry_rule`
- `unlock_rule`

### ReviewState

Controls whether the asset is safe for learner-facing release.

Suggested values:

- `draft`
- `review_needed`
- `approved_reference`
- `approved_publishable`
- `blocked`

## App-Level Implementation

V3.1 should implement this inside the product in five layers.

### Layer 1: Backend Content Registry

Add a backend-owned registry for:

- source records
- asset metadata
- license status
- approval status

The backend must become the source of truth for whether an asset is publishable.

### Layer 2: Publish Gating

The product must refuse to ship or serve blocked assets.

Rules:

- no learner-facing asset should be shown if `license_status = unknown_blocked`
- no external video should render without a compatible license state
- no assessment pack should publish if its required core media is blocked

### Layer 3: Learner-Facing Attribution

V3.1 should support light but clear attribution when needed.

Examples:

- `Inspired by conservatory-style beginner sequencing`
- `Uses CC BY material with attribution`
- `Open educational reference`

Important:

- the learner UI should stay clean
- attribution should exist, but not turn the learning flow into a legal wall of text

### Layer 4: Internal Review Surfaces

Even if a full admin app is not built yet, the system should support:

- blocked asset detection
- rights status inspection
- source traceability
- publish status review

### Layer 5: Curriculum Placement

Every approved learner asset should be placed inside:

- `Track`
- `Stage`
- `Session Pack`
- `Drill`
- `Assessment`

This prevents “orphan content” from appearing as random screens.

## Required Product Rules

### Rule 1

No copied university lesson text in learner-facing surfaces.

### Rule 2

No embedded external video unless license compatibility is verified.

### Rule 3

No new content should enter the product without:

- source record
- asset record
- curriculum placement
- review status

### Rule 4

Every lesson must end in a playable action, not just explanation.

### Rule 5

The `Beginner Core` path gets first priority for original content production.

## V3.1 Content Build Order

### 1. Beginner Core

Build first:

- original beginner text
- original drill chains
- original audio cues
- original first-note videos or animations
- recording checkpoints

Target:

- 14 to 30 connected session packs

### 2. Jazz Foundations

Build second:

- convert text-heavy areas into drill-first sequences
- build short playable loops
- attach recording checkpoints and retry logic

### 3. Theory Into Practice

Build third:

- short concept cards
- listening tasks
- sing-it prompts
- play-it prompts
- improv micro-tasks

### 4. Oriental Maqam

Build later:

- original maqam explanations
- original phrase examples
- original intonation and quarter-tone drill packs

## Content Acquisition Workflow

V3.1 should use this workflow every time we add a new asset.

1. find source
2. classify source
3. verify license
4. create source record
5. decide: reference only, open use, permission required, or rebuild original
6. create original/adapted SaxPath asset if needed
7. assign curriculum placement
8. assign review state
9. publish only if approved

## What To Build Instead Of Reusing University Videos

For V3.1, build these internal media types:

- 15 to 45 second horn demos
- embouchure micro-clips
- finger placement loops
- note playback references
- rhythm clap/count demos
- call-and-response phrase demos
- retry examples

This is better than depending on third-party university videos because it gives:

- cleaner pedagogy
- simpler rights handling
- stronger Arabic-first localization
- more consistent UX

## Suggested Engineering Targets

Primary code areas likely to change:

- `services/api/app/services/mock_content.py`
- `services/api/app/services/curriculum_sources.py`
- `services/api/app/schemas/`
- `apps/mobile/lib/shared/education/`
- `apps/mobile/lib/data/models/`
- `apps/mobile/lib/features/home/`
- `apps/mobile/lib/features/session/`
- `apps/mobile/lib/features/progress/`

Suggested new backend concepts:

- `source_records`
- `content_assets`
- `asset_permissions`
- `curriculum_nodes`

Suggested new frontend concepts:

- source-safe content cards
- attribution bottom sheet
- blocked asset fallback state
- learner-safe reference links

## Now / Next / Later

### Now

- create the `source record` and `content asset` model definitions
- classify current curriculum sources into `reference_only`, `open_licensed`, `permission_granted`, or `blocked`
- mark all current university-derived references as `reference_only` unless proven otherwise
- prioritize original `Beginner Core` asset production
- keep university pages only as sequencing references
- block default reuse of external videos inside learner-facing surfaces

### Next

- add backend publish gating for rights status
- connect curriculum placement metadata to all learner-facing content
- build original short-form audio/video for the first learner stages
- convert `Jazz Foundations` to a drill-first structure
- add light attribution support in the app where required

### Later

- partner licenses with teachers or institutions
- controlled import of compatible OER assets
- advanced internal review tools
- branded collaboration modules
- broader expansion into `Oriental Maqam` and premium media libraries

## Release Standard For V3.1

V3.1 should be considered ready only if:

- the core learner path uses mostly original or clearly licensed assets
- every learner-facing media asset has a tracked rights state
- no blocked asset can appear in the main product loop
- `Beginner Core` is deeper and more connected than the current short daily authored flow
- the app can explain where content belongs in the curriculum

## External Policy References

These external references should guide implementation and review:

- U.S. Copyright Office: copyright protects original expression, not bare ideas, facts, or systems
  - https://www.copyright.gov/help/faq/faq-general.html
  - https://www.copyright.gov/circs/circ01.pdf
- Creative Commons licensing framework
  - https://creativecommons.org/cc-licenses/
  - https://creativecommons.org/choose/
- UNESCO definition of Open Educational Resources
  - https://www.unesco.org/en/open-educational-resources
- YouTube license types
  - https://support.google.com/youtube/answer/2797468?hl=en
- MIT OpenCourseWare terms and open-license examples
  - https://ocw.mit.edu/pages/privacy-and-terms-of-use/
  - https://ocw.mit.edu/pages/get-started/

## Final Direction

The V3.1 answer is not:

`take university content and put it in the app`

The V3.1 answer is:

`build a rights-aware, source-aware, curriculum-aware content system inside the app, then fill it mainly with original SaxPath learning assets inspired by strong academic references.`
