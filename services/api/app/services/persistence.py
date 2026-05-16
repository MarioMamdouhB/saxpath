import json
import re
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from threading import Lock
from typing import Any
from uuid import uuid4

from app.core.config import get_settings
from app.schemas.attempt import (
    AttemptCreateRequest,
    AttemptEvaluationResponse,
    AttemptHistoryEntry,
    TeacherReview,
)
from app.schemas.analytics import (
    AnalyticsEventCreateRequest,
    AnalyticsEventResponse,
)
from app.schemas.progress import LearnerProgressResponse
from app.schemas.recording import RecordingResponse

try:
    import psycopg
    from psycopg.rows import dict_row
except ImportError:  # pragma: no cover - only relevant outside installed envs.
    psycopg = None
    dict_row = None

_DAY_PATTERN = re.compile(r"day_(\d+)")
_STORE_LOCK = Lock()
_SCHEMA_LOCK = Lock()
_SCHEMA_READY = False


def get_store_path() -> Path:
    return Path(__file__).resolve().parents[2] / "data" / "demo_store.json"


def record_attempt(
    payload: AttemptCreateRequest,
    evaluation: AttemptEvaluationResponse,
) -> AttemptHistoryEntry:
    if _use_postgres():
        return _record_attempt_postgres(payload, evaluation)
    return _record_attempt_file(payload, evaluation)


def list_attempt_history(limit: int = 20) -> list[AttemptHistoryEntry]:
    if _use_postgres():
        return _list_attempt_history_postgres(limit)

    with _STORE_LOCK:
        state = _read_state()

    return [
        AttemptHistoryEntry(**entry)
        for entry in state["attempts"][: max(1, limit)]
    ]


def get_attempt_detail(attempt_id: str) -> AttemptHistoryEntry | None:
    if _use_postgres():
        return _get_attempt_detail_postgres(attempt_id)

    with _STORE_LOCK:
        state = _read_state()

    attempts = state["attempts"]
    if not isinstance(attempts, list):
        return None

    for entry in attempts:
        if isinstance(entry, dict) and entry.get("attempt_id") == attempt_id:
            return AttemptHistoryEntry(**entry)
    return None


def update_teacher_review(
    attempt_id: str,
    teacher_review: TeacherReview,
) -> AttemptHistoryEntry | None:
    if _use_postgres():
        return _update_teacher_review_postgres(attempt_id, teacher_review)

    with _STORE_LOCK:
        state = _read_state()
        attempts = state["attempts"]
        if not isinstance(attempts, list):
            return None

        for index, entry in enumerate(attempts):
            if not isinstance(entry, dict) or entry.get("attempt_id") != attempt_id:
                continue

            updated_entry = dict(entry)
            updated_entry["teacher_review"] = teacher_review.model_dump()
            attempts[index] = updated_entry
            _write_state(state)
            return AttemptHistoryEntry(**updated_entry)

    return None


def record_recording(recording: RecordingResponse) -> RecordingResponse:
    if _use_postgres():
        return _record_recording_postgres(recording)

    with _STORE_LOCK:
        state = _read_state()
        recordings = state["recordings"]
        if isinstance(recordings, dict):
            recordings[recording.recording_id] = recording.model_dump()
        _write_state(state)

    return recording


def get_recording(recording_id: str) -> RecordingResponse | None:
    if _use_postgres():
        return _get_recording_postgres(recording_id)

    with _STORE_LOCK:
        state = _read_state()

    recordings = state["recordings"]
    recording = recordings.get(recording_id) if isinstance(recordings, dict) else None
    if not isinstance(recording, dict):
        return None

    return RecordingResponse(**recording)


def get_learner_progress(total_days: int = 30) -> LearnerProgressResponse:
    if _use_postgres():
        return _get_learner_progress_postgres(total_days)

    with _STORE_LOCK:
        state = _read_state()

    completed_days = _normalize_completed_days(
        state["completed_days"],
        total_days=total_days,
    )
    completion_log = _normalize_completion_log(
        state.get("completion_log"),
        total_days=total_days,
    )

    return _build_progress_response(
        completed_days,
        total_days=total_days,
        completion_log=completion_log,
    )


def load_skill_mastery_state() -> dict[str, object]:
    if _use_postgres():
        return _load_skill_mastery_state_postgres()

    with _STORE_LOCK:
        state = _read_state()

    return _normalize_skill_mastery_state(state.get("skill_mastery"))


def save_skill_mastery_state(skill_mastery: dict[str, object]) -> None:
    normalized = _normalize_skill_mastery_state(skill_mastery)
    if _use_postgres():
        _save_skill_mastery_state_postgres(normalized)
        return

    with _STORE_LOCK:
        state = _read_state()
        state["skill_mastery"] = normalized
        _write_state(state)


def complete_day(day_number: int, total_days: int = 30) -> LearnerProgressResponse:
    if _use_postgres():
        return _complete_day_postgres(day_number, total_days)

    with _STORE_LOCK:
        state = _read_state()
        completed_days = set(
            _normalize_completed_days(state["completed_days"], total_days=total_days)
        )
        completion_log = _normalize_completion_log(
            state.get("completion_log"),
            total_days=total_days,
        )
        if 1 <= day_number <= total_days:
            completed_days.add(day_number)
            completion_log[day_number] = _now_iso()
        state["completed_days"] = sorted(completed_days)
        state["completion_log"] = {
            str(day): timestamp for day, timestamp in completion_log.items()
        }
        _write_state(state)

    return get_learner_progress(total_days=total_days)


def reset_progress(total_days: int = 30) -> LearnerProgressResponse:
    if _use_postgres():
        return _reset_progress_postgres(total_days)

    with _STORE_LOCK:
        state = _read_state()
        state["completed_days"] = []
        state["completion_log"] = {}
        _write_state(state)

    return get_learner_progress(total_days=total_days)


def record_analytics_event(
    payload: AnalyticsEventCreateRequest,
) -> AnalyticsEventResponse:
    if _use_postgres():
        return _record_analytics_event_postgres(payload)

    event = _build_analytics_event(payload)

    with _STORE_LOCK:
        state = _read_state()
        events = state["analytics_events"]
        if isinstance(events, list):
            events.insert(0, event.model_dump())
        _write_state(state)

    return event


def list_analytics_events(limit: int = 20) -> list[AnalyticsEventResponse]:
    if _use_postgres():
        return _list_analytics_events_postgres(limit)

    with _STORE_LOCK:
        state = _read_state()

    return [
        AnalyticsEventResponse(**entry)
        for entry in state["analytics_events"][: max(1, limit)]
    ]


def _record_attempt_file(
    payload: AttemptCreateRequest,
    evaluation: AttemptEvaluationResponse,
) -> AttemptHistoryEntry:
    entry = _build_attempt_history_entry(payload, evaluation)

    with _STORE_LOCK:
        state = _read_state()
        attempts = state["attempts"]
        if isinstance(attempts, list):
            attempts.insert(0, entry.model_dump())
        _write_state(state)

    return entry


def _record_attempt_postgres(
    payload: AttemptCreateRequest,
    evaluation: AttemptEvaluationResponse,
) -> AttemptHistoryEntry:
    entry = _build_attempt_history_entry(payload, evaluation)
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id
    analysis_payload = (
        entry.analysis.model_dump() if entry.analysis is not None else None
    )

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            INSERT INTO attempts (
                id, learner_id, exercise_id, day_number, duration_seconds,
                audio_url, recording_id, pitch_accuracy, rhythm_accuracy,
                completion, feedback_ar, next_recommendation, retry_reason,
                analysis, mastery_delta, recommended_retry_block,
                teacher_review,
                confidence_label, created_at
            )
            VALUES (
                %(id)s, %(learner_id)s, %(exercise_id)s, %(day_number)s,
                %(duration_seconds)s, %(audio_url)s, %(recording_id)s,
                %(pitch_accuracy)s, %(rhythm_accuracy)s, %(completion)s,
                %(feedback_ar)s, %(next_recommendation)s, %(retry_reason)s,
                %(analysis)s::jsonb, %(mastery_delta)s::jsonb,
                %(recommended_retry_block)s, %(teacher_review)s::jsonb,
                %(confidence_label)s,
                %(created_at)s
            )
            ON CONFLICT (id) DO UPDATE SET
                completion = EXCLUDED.completion,
                analysis = EXCLUDED.analysis,
                mastery_delta = EXCLUDED.mastery_delta,
                recommended_retry_block = EXCLUDED.recommended_retry_block,
                teacher_review = EXCLUDED.teacher_review,
                confidence_label = EXCLUDED.confidence_label
            """,
            {
                "id": entry.attempt_id,
                "learner_id": learner_id,
                "exercise_id": entry.exercise_id,
                "day_number": entry.day_number,
                "duration_seconds": entry.duration_seconds,
                "audio_url": entry.audio_url,
                "recording_id": entry.recording_id,
                "pitch_accuracy": entry.pitch_accuracy,
                "rhythm_accuracy": entry.rhythm_accuracy,
                "completion": entry.completion,
                "feedback_ar": entry.feedback_ar,
                "next_recommendation": entry.next_recommendation,
                "retry_reason": entry.retry_reason,
                "analysis": json.dumps(analysis_payload, ensure_ascii=False),
                "mastery_delta": json.dumps(
                    [delta.model_dump() for delta in entry.mastery_delta],
                    ensure_ascii=False,
                ),
                "recommended_retry_block": entry.recommended_retry_block,
                "teacher_review": json.dumps(
                    entry.teacher_review.model_dump()
                    if entry.teacher_review is not None
                    else {},
                    ensure_ascii=False,
                ),
                "confidence_label": entry.confidence_label,
                "created_at": entry.created_at,
            },
        )

    return entry


def _list_attempt_history_postgres(limit: int) -> list[AttemptHistoryEntry]:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        rows = connection.execute(
            """
            SELECT
                id AS attempt_id,
                exercise_id,
                day_number,
                duration_seconds,
                audio_url,
                recording_id,
                pitch_accuracy,
                rhythm_accuracy,
                completion,
                feedback_ar,
                next_recommendation,
                retry_reason,
                analysis,
                mastery_delta,
                recommended_retry_block,
                teacher_review,
                confidence_label,
                created_at
            FROM attempts
            WHERE learner_id = %s
            ORDER BY created_at DESC
            LIMIT %s
            """,
            (learner_id, max(1, limit)),
        ).fetchall()

    return [_attempt_from_row(row) for row in rows]


def _get_attempt_detail_postgres(attempt_id: str) -> AttemptHistoryEntry | None:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        row = connection.execute(
            """
            SELECT
                id AS attempt_id,
                exercise_id,
                day_number,
                duration_seconds,
                audio_url,
                recording_id,
                pitch_accuracy,
                rhythm_accuracy,
                completion,
                feedback_ar,
                next_recommendation,
                retry_reason,
                analysis,
                mastery_delta,
                recommended_retry_block,
                teacher_review,
                confidence_label,
                created_at
            FROM attempts
            WHERE learner_id = %s AND id = %s
            """,
            (learner_id, attempt_id),
        ).fetchone()

    if row is None:
        return None

    return _attempt_from_row(row)


def _update_teacher_review_postgres(
    attempt_id: str,
    teacher_review: TeacherReview,
) -> AttemptHistoryEntry | None:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        row = connection.execute(
            """
            UPDATE attempts
            SET teacher_review = %s::jsonb
            WHERE learner_id = %s AND id = %s
            RETURNING
                id AS attempt_id,
                exercise_id,
                day_number,
                duration_seconds,
                audio_url,
                recording_id,
                pitch_accuracy,
                rhythm_accuracy,
                completion,
                feedback_ar,
                next_recommendation,
                retry_reason,
                analysis,
                mastery_delta,
                recommended_retry_block,
                teacher_review,
                confidence_label,
                created_at
            """,
            (
                json.dumps(teacher_review.model_dump(), ensure_ascii=False),
                learner_id,
                attempt_id,
            ),
        ).fetchone()

    if row is None:
        return None

    return _attempt_from_row(row)


def _record_recording_postgres(recording: RecordingResponse) -> RecordingResponse:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            INSERT INTO recordings (
                id, learner_id, filename, duration_seconds, storage_path,
                playback_url, content_type, created_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
                storage_path = EXCLUDED.storage_path,
                playback_url = EXCLUDED.playback_url
            """,
            (
                recording.recording_id,
                learner_id,
                recording.filename,
                recording.duration_seconds,
                recording.storage_path,
                recording.playback_url,
                recording.content_type,
                recording.created_at,
            ),
        )

    return recording


def _get_recording_postgres(recording_id: str) -> RecordingResponse | None:
    _ensure_postgres_schema()

    with _connect(row_factory=dict_row) as connection:
        row = connection.execute(
            """
            SELECT
                id AS recording_id,
                filename,
                duration_seconds,
                storage_path,
                playback_url,
                content_type,
                created_at
            FROM recordings
            WHERE id = %s
            """,
            (recording_id,),
        ).fetchone()

    if row is None:
        return None

    return RecordingResponse(
        recording_id=row["recording_id"],
        filename=row["filename"],
        duration_seconds=row["duration_seconds"],
        storage_path=row["storage_path"],
        playback_url=row["playback_url"],
        content_type=row["content_type"],
        created_at=_serialize_datetime(row["created_at"]),
    )


def _get_learner_progress_postgres(total_days: int) -> LearnerProgressResponse:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        _ensure_learner(connection, learner_id)
        row = connection.execute(
            "SELECT completed_days, completion_log FROM progress WHERE learner_id = %s",
            (learner_id,),
        ).fetchone()

    completed_days = _normalize_completed_days(
        row["completed_days"] if row else [],
        total_days=total_days,
    )
    completion_log = _normalize_completion_log(
        row["completion_log"] if row else {},
        total_days=total_days,
    )
    return _build_progress_response(
        completed_days,
        total_days=total_days,
        completion_log=completion_log,
    )


def _complete_day_postgres(
    day_number: int,
    total_days: int,
) -> LearnerProgressResponse:
    learner_id = get_settings().demo_learner_id
    progress = _get_learner_progress_postgres(total_days)
    completed_days = set(progress.completed_days)
    completion_log = _normalize_completion_log(
        _get_completion_log_postgres(learner_id),
        total_days=total_days,
    )
    if 1 <= day_number <= total_days:
        completed_days.add(day_number)
        completion_log[day_number] = _now_iso()

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            UPDATE progress
            SET completed_days = %s, completion_log = %s::jsonb, updated_at = NOW()
            WHERE learner_id = %s
            """,
            (
                sorted(completed_days),
                json.dumps(
                    {str(day): timestamp for day, timestamp in completion_log.items()},
                    ensure_ascii=False,
                ),
                learner_id,
            ),
        )

    return _get_learner_progress_postgres(total_days)


def _reset_progress_postgres(total_days: int) -> LearnerProgressResponse:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            UPDATE progress
            SET completed_days = '{}', completion_log = '{}'::jsonb, updated_at = NOW()
            WHERE learner_id = %s
            """,
            (learner_id,),
        )

    return _get_learner_progress_postgres(total_days)


def _record_analytics_event_postgres(
    payload: AnalyticsEventCreateRequest,
) -> AnalyticsEventResponse:
    event = _build_analytics_event(payload)
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            INSERT INTO analytics_events (
                id, learner_id, event_name, day_number, task_id,
                attempt_id, metadata, created_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb, %s)
            """,
            (
                event.event_id,
                learner_id,
                event.event_name,
                event.day_number,
                event.task_id,
                event.attempt_id,
                json.dumps(event.metadata, ensure_ascii=False),
                event.created_at,
            ),
        )

    return event


def _list_analytics_events_postgres(limit: int) -> list[AnalyticsEventResponse]:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        rows = connection.execute(
            """
            SELECT
                id AS event_id,
                event_name,
                day_number,
                task_id,
                attempt_id,
                metadata,
                created_at
            FROM analytics_events
            WHERE learner_id = %s
            ORDER BY created_at DESC
            LIMIT %s
            """,
            (learner_id, max(1, limit)),
        ).fetchall()

    return [
        AnalyticsEventResponse(
            event_id=row["event_id"],
            event_name=row["event_name"],
            day_number=row["day_number"],
            task_id=row["task_id"],
            attempt_id=row["attempt_id"],
            metadata=row["metadata"] or {},
            created_at=_serialize_datetime(row["created_at"]),
        )
        for row in rows
    ]


def _build_attempt_history_entry(
    payload: AttemptCreateRequest,
    evaluation: AttemptEvaluationResponse,
) -> AttemptHistoryEntry:
    day_number = _extract_day_number(payload.exercise_id)
    duration_seconds = payload.duration_seconds or 0
    audio_url = payload.audio_url or ""

    return AttemptHistoryEntry(
        attempt_id=evaluation.attempt_id,
        exercise_id=payload.exercise_id,
        day_number=day_number,
        duration_seconds=duration_seconds,
        audio_url=audio_url,
        recording_id=evaluation.recording_id or payload.recording_id,
        pitch_accuracy=evaluation.pitch_accuracy,
        rhythm_accuracy=evaluation.rhythm_accuracy,
        completion=evaluation.completion,
        feedback_ar=evaluation.feedback_ar,
        next_recommendation=evaluation.next_recommendation,
        retry_reason=evaluation.retry_reason,
        analysis=evaluation.analysis,
        mastery_delta=evaluation.mastery_delta,
        recommended_retry_block=evaluation.recommended_retry_block,
        confidence_label=evaluation.confidence_label,
        teacher_review=evaluation.teacher_review,
        created_at=datetime.now(timezone.utc).isoformat(),
    )


def _build_analytics_event(
    payload: AnalyticsEventCreateRequest,
) -> AnalyticsEventResponse:
    return AnalyticsEventResponse(
        event_id=f"event_{uuid4().hex[:12]}",
        event_name=payload.event_name,
        day_number=payload.day_number,
        task_id=payload.task_id,
        attempt_id=payload.attempt_id,
        metadata=payload.metadata,
        created_at=datetime.now(timezone.utc).isoformat(),
    )


def _default_state() -> dict[str, object]:
    return {
        "completed_days": [],
        "attempts": [],
        "analytics_events": [],
        "recordings": {},
        "completion_log": {},
        "skill_mastery": {},
    }


def _read_state() -> dict[str, object]:
    path = get_store_path()
    if not path.exists():
        return _default_state()

    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return _default_state()

    if not isinstance(payload, dict):
        return _default_state()

    return {
        "completed_days": payload.get("completed_days", []),
        "attempts": payload.get("attempts", []),
        "analytics_events": payload.get("analytics_events", []),
        "recordings": payload.get("recordings", {}),
        "completion_log": payload.get("completion_log", {}),
        "skill_mastery": payload.get("skill_mastery", {}),
    }


def _write_state(state: dict[str, object]) -> None:
    path = get_store_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = path.with_suffix(f"{path.suffix}.tmp")
    payload = json.dumps(state, ensure_ascii=False, indent=2)
    temp_path.write_text(
        payload,
        encoding="utf-8",
    )
    try:
        temp_path.replace(path)
    except PermissionError:
        path.write_text(payload, encoding="utf-8")
        temp_path.unlink(missing_ok=True)


def _ensure_postgres_schema() -> None:
    global _SCHEMA_READY

    if _SCHEMA_READY:
        return

    with _SCHEMA_LOCK:
        if _SCHEMA_READY:
            return

        with _connect() as connection:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS learners (
                    id TEXT PRIMARY KEY,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS recordings (
                    id TEXT PRIMARY KEY,
                    learner_id TEXT NOT NULL REFERENCES learners(id),
                    filename TEXT NOT NULL,
                    duration_seconds INTEGER NOT NULL,
                    storage_path TEXT NOT NULL,
                    playback_url TEXT NOT NULL,
                    content_type TEXT NOT NULL,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )
            connection.execute(
                """
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
                    mastery_delta JSONB NOT NULL DEFAULT '[]',
                    recommended_retry_block TEXT,
                    teacher_review JSONB NOT NULL DEFAULT '{}',
                    confidence_label TEXT NOT NULL DEFAULT 'medium',
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS progress (
                    learner_id TEXT PRIMARY KEY REFERENCES learners(id),
                    completed_days INTEGER[] NOT NULL DEFAULT '{}',
                    completion_log JSONB NOT NULL DEFAULT '{}',
                    mastery JSONB NOT NULL DEFAULT '{}',
                    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )
            connection.execute(
                """
                ALTER TABLE progress
                ADD COLUMN IF NOT EXISTS completion_log JSONB NOT NULL DEFAULT '{}'
                """
            )
            connection.execute(
                """
                ALTER TABLE progress
                ADD COLUMN IF NOT EXISTS mastery JSONB NOT NULL DEFAULT '{}'
                """
            )
            connection.execute(
                """
                ALTER TABLE attempts
                ADD COLUMN IF NOT EXISTS mastery_delta JSONB NOT NULL DEFAULT '[]'
                """
            )
            connection.execute(
                """
                ALTER TABLE attempts
                ADD COLUMN IF NOT EXISTS recommended_retry_block TEXT
                """
            )
            connection.execute(
                """
                ALTER TABLE attempts
                ADD COLUMN IF NOT EXISTS confidence_label TEXT NOT NULL DEFAULT 'medium'
                """
            )
            connection.execute(
                """
                ALTER TABLE attempts
                ADD COLUMN IF NOT EXISTS teacher_review JSONB NOT NULL DEFAULT '{}'
                """
            )
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS analytics_events (
                    id TEXT PRIMARY KEY,
                    learner_id TEXT NOT NULL REFERENCES learners(id),
                    event_name TEXT NOT NULL,
                    day_number INTEGER,
                    task_id TEXT,
                    attempt_id TEXT,
                    metadata JSONB NOT NULL DEFAULT '{}',
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS idx_attempts_learner_created ON attempts (learner_id, created_at DESC)"
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS idx_events_learner_created ON analytics_events (learner_id, created_at DESC)"
            )

        _SCHEMA_READY = True


def _ensure_learner(connection: Any, learner_id: str) -> None:
    connection.execute(
        "INSERT INTO learners (id) VALUES (%s) ON CONFLICT (id) DO NOTHING",
        (learner_id,),
    )
    connection.execute(
        """
        INSERT INTO progress (learner_id, completed_days)
        VALUES (%s, '{}')
        ON CONFLICT (learner_id) DO NOTHING
        """,
        (learner_id,),
    )


def _connect(*, row_factory: Any | None = None) -> Any:
    if psycopg is None:
        raise RuntimeError("psycopg is required when PERSISTENCE_BACKEND=postgres.")

    settings = get_settings()
    kwargs: dict[str, object] = {
        "host": settings.postgres_host,
        "port": settings.postgres_port,
        "dbname": settings.postgres_db,
        "user": settings.postgres_user,
        "password": settings.postgres_password,
    }
    if row_factory is not None:
        kwargs["row_factory"] = row_factory
    return psycopg.connect(**kwargs)


def _use_postgres() -> bool:
    return get_settings().persistence_backend.lower() == "postgres"


def _normalize_completed_days(
    completed_days: object,
    *,
    total_days: int,
) -> list[int]:
    if not isinstance(completed_days, list):
        return []

    normalized = {
        day
        for day in completed_days
        if isinstance(day, int) and 1 <= day <= total_days
    }
    return sorted(normalized)


def _normalize_completion_log(
    completion_log: object,
    *,
    total_days: int,
) -> dict[int, str]:
    if not isinstance(completion_log, dict):
        return {}

    normalized: dict[int, str] = {}
    for raw_day, raw_timestamp in completion_log.items():
        try:
            day = int(raw_day)
        except (TypeError, ValueError):
            continue
        if not isinstance(raw_timestamp, str) or not (1 <= day <= total_days):
            continue
        try:
            datetime.fromisoformat(raw_timestamp.replace("Z", "+00:00"))
        except ValueError:
            continue
        normalized[day] = raw_timestamp
    return normalized


def _build_progress_response(
    completed_days: list[int],
    *,
    total_days: int,
    completion_log: dict[int, str] | None = None,
) -> LearnerProgressResponse:
    normalized_log = completion_log or {}
    return LearnerProgressResponse(
        completed_days=completed_days,
        completed_days_count=len(completed_days),
        current_day_number=_current_day_number(
            completed_days=completed_days,
            total_days=total_days,
        ),
        total_days=total_days,
        current_streak_days=_current_streak_days(normalized_log),
        last_completed_at=_latest_completion_timestamp(normalized_log),
    )


def _current_day_number(*, completed_days: list[int], total_days: int) -> int:
    for day_number in range(1, total_days + 1):
        if day_number not in completed_days:
            return day_number

    return total_days


def _current_streak_days(completion_log: dict[int, str]) -> int:
    completion_dates = sorted(
        {_completion_date(timestamp) for timestamp in completion_log.values()},
        reverse=True,
    )
    if not completion_dates:
        return 0

    today = datetime.now(timezone.utc).date()
    if completion_dates[0] not in {today, today - timedelta(days=1)}:
        return 0

    streak = 1
    for index in range(1, len(completion_dates)):
        expected = completion_dates[index - 1] - timedelta(days=1)
        if completion_dates[index] != expected:
            break
        streak += 1
    return streak


def _latest_completion_timestamp(completion_log: dict[int, str]) -> str | None:
    if not completion_log:
        return None
    return max(completion_log.values(), key=_completion_datetime)


def _completion_datetime(timestamp: str) -> datetime:
    return datetime.fromisoformat(timestamp.replace("Z", "+00:00"))


def _completion_date(timestamp: str) -> date:
    return _completion_datetime(timestamp).date()


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _get_completion_log_postgres(learner_id: str) -> object:
    _ensure_postgres_schema()
    with _connect(row_factory=dict_row) as connection:
        row = connection.execute(
            "SELECT completion_log FROM progress WHERE learner_id = %s",
            (learner_id,),
        ).fetchone()
    if row is None:
        return {}
    return row["completion_log"]


def _extract_day_number(exercise_id: str) -> int:
    match = _DAY_PATTERN.search(exercise_id)
    if not match:
        return 1
    return max(1, int(match.group(1)))


def _attempt_from_row(row: dict[str, Any]) -> AttemptHistoryEntry:
    return AttemptHistoryEntry(
        attempt_id=row["attempt_id"],
        exercise_id=row["exercise_id"],
        day_number=row["day_number"],
        duration_seconds=row["duration_seconds"],
        audio_url=row["audio_url"],
        recording_id=row["recording_id"],
        pitch_accuracy=row["pitch_accuracy"],
        rhythm_accuracy=row["rhythm_accuracy"],
        completion=row["completion"],
        feedback_ar=row["feedback_ar"],
        next_recommendation=row["next_recommendation"],
        retry_reason=row["retry_reason"],
        analysis=row["analysis"],
        mastery_delta=row.get("mastery_delta") or [],
        recommended_retry_block=row.get("recommended_retry_block"),
        confidence_label=row.get("confidence_label") or "medium",
        teacher_review=row.get("teacher_review") or None,
        created_at=_serialize_datetime(row["created_at"]),
    )


def _serialize_datetime(value: object) -> str:
    if isinstance(value, datetime):
        return value.isoformat()
    return str(value)


def _load_skill_mastery_state_postgres() -> dict[str, object]:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect(row_factory=dict_row) as connection:
        _ensure_learner(connection, learner_id)
        row = connection.execute(
            "SELECT mastery FROM progress WHERE learner_id = %s",
            (learner_id,),
        ).fetchone()

    return _normalize_skill_mastery_state(row["mastery"] if row else {})


def _save_skill_mastery_state_postgres(skill_mastery: dict[str, object]) -> None:
    _ensure_postgres_schema()
    learner_id = get_settings().demo_learner_id

    with _connect() as connection:
        _ensure_learner(connection, learner_id)
        connection.execute(
            """
            UPDATE progress
            SET mastery = %s::jsonb, updated_at = NOW()
            WHERE learner_id = %s
            """,
            (
                json.dumps(skill_mastery, ensure_ascii=False),
                learner_id,
            ),
        )


def _normalize_skill_mastery_state(skill_mastery: object) -> dict[str, object]:
    if not isinstance(skill_mastery, dict):
        return {}

    normalized: dict[str, object] = {}
    for key, value in skill_mastery.items():
        if not isinstance(key, str) or not isinstance(value, dict):
            continue
        normalized[key] = {
            "score": value.get("score", 0),
            "last_updated_at": value.get("last_updated_at"),
            "focus_label": value.get("focus_label"),
            "status": value.get("status"),
        }
    return normalized
