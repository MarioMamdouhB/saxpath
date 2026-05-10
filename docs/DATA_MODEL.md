# Data Model

## User

Represents the learner profile.

In the private beta backend this is stored as `learners`. Auth is not implemented yet, so local/beta runs use `DEMO_LEARNER_ID`.

## Lesson

Represents a note or rhythm lesson shown to the learner.

## DailyPlan

Represents the learner's plan for a single day.

## DailyTask

Represents a single item inside the daily plan, such as a note lesson or practice step.

## Attempt

Represents one submitted practice attempt.

Attempts reference an uploaded recording, analysis scores, retry reason, and the recommendation shown to the learner.

## Recording

Represents a WAV file uploaded to the backend filesystem in v1. It stores duration, local storage path, and a playback URL for attempt history.

## Progress

Represents backend-owned completed days. Flutter `shared_preferences` should be treated as cache only.

## AnalyticsEvent

Represents lightweight product events such as practice finished and day completed.

## FeedbackResult

Represents the mocked evaluation returned after an attempt.

This remains available only as deterministic demo/fallback behavior. The primary beta path uses audio-engine analysis.
