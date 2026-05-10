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


class AttemptAnalysis(BaseModel):
    pitch_score: int
    rhythm_score: int
    detected_notes: list[DetectedNote] = Field(default_factory=list)
    timing_errors: list[TimingError] = Field(default_factory=list)
    confidence: float = 0
    source: str = "deterministic_mock"


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
    created_at: str
