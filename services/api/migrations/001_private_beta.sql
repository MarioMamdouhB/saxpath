CREATE TABLE IF NOT EXISTS learners (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS recordings (
    id TEXT PRIMARY KEY,
    learner_id TEXT NOT NULL REFERENCES learners(id),
    filename TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL,
    storage_path TEXT NOT NULL,
    playback_url TEXT NOT NULL,
    content_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS attempts (
    id TEXT PRIMARY KEY,
    learner_id TEXT NOT NULL REFERENCES learners(id),
    exercise_id TEXT NOT NULL,
    day_number INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    audio_url TEXT NOT NULL,
    recording_id TEXT REFERENCES recordings(id),
    pitch_accuracy INTEGER NOT NULL,
    rhythm_accuracy INTEGER NOT NULL,
    completion INTEGER NOT NULL,
    feedback_ar TEXT NOT NULL,
    next_recommendation TEXT NOT NULL,
    retry_reason TEXT,
    analysis JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS progress (
    learner_id TEXT PRIMARY KEY REFERENCES learners(id),
    completed_days INTEGER[] NOT NULL DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS analytics_events (
    id TEXT PRIMARY KEY,
    learner_id TEXT NOT NULL REFERENCES learners(id),
    event_name TEXT NOT NULL,
    day_number INTEGER,
    task_id TEXT,
    attempt_id TEXT,
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_attempts_learner_created
    ON attempts (learner_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_events_learner_created
    ON analytics_events (learner_id, created_at DESC);
