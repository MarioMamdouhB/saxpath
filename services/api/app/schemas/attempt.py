from typing import Any

from pydantic import BaseModel, Field


class DetectedNote(BaseModel):
    note: str
    frequency_hz: float
    confidence: float


class TimingError(BaseModel):
    onset_seconds: float
    expected_seconds: float
    error_ms: float


class EventMatch(BaseModel):
    expected_note: str
    detected_note: str
    expected_seconds: float
    observed_seconds: float | None = None
    timing_error_ms: float = 0
    pitch_ok: bool = False


class MasteryDelta(BaseModel):
    skill: str
    previous_score: int
    new_score: int
    delta: int


class TeacherReview(BaseModel):
    status: str = "available"
    ai_summary_ar: str
    teacher_prompt_ar: str
    queue_eta_ar: str
    focus_points_ar: list[str] = Field(default_factory=list)
    source: str = "ai_teacher_bridge_v1"


class AttemptAnalysis(BaseModel):
    pitch_score: int
    rhythm_score: int
    detected_notes: list[DetectedNote] = Field(default_factory=list)
    timing_errors: list[TimingError] = Field(default_factory=list)
    tone_score: int = 0
    event_matches: list[EventMatch] = Field(default_factory=list)
    sustain_stability: float = 0
    confidence: float = 0
    source: str = "deterministic_mock"
    analysis_version: str = "v1"


class AttemptCreateRequest(BaseModel):
    exercise_id: str
    duration_seconds: int | None = None
    audio_url: str | None = None
    recording_id: str | None = None


class AttemptEvaluationResponse(BaseModel):
    attempt_id: str
    pitch_accuracy: int
    rhythm_accuracy: int
    completion: int
    feedback_ar: str
    next_recommendation: str
    recording_id: str | None = None
    retry_reason: str | None = None
    analysis: AttemptAnalysis | None = None
    mastery_delta: list[MasteryDelta] = Field(default_factory=list)
    recommended_retry_block: str | None = None
    confidence_label: str = "medium"
    teacher_review: TeacherReview | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class AttemptHistoryEntry(BaseModel):
    attempt_id: str
    exercise_id: str
    day_number: int
    duration_seconds: int
    audio_url: str
    recording_id: str | None = None
    pitch_accuracy: int
    rhythm_accuracy: int
    completion: int
    feedback_ar: str
    next_recommendation: str
    retry_reason: str | None = None
    analysis: AttemptAnalysis | None = None
    mastery_delta: list[MasteryDelta] = Field(default_factory=list)
    recommended_retry_block: str | None = None
    confidence_label: str = "medium"
    teacher_review: TeacherReview | None = None
    created_at: str
