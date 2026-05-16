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


class AudioAnalysisResponse(BaseModel):
    pitch_score: int = Field(ge=0, le=100)
    rhythm_score: int = Field(ge=0, le=100)
    detected_notes: list[DetectedNote]
    timing_errors: list[TimingError]
    tone_score: int = Field(default=0, ge=0, le=100)
    event_matches: list[EventMatch] = Field(default_factory=list)
    sustain_stability: float = Field(default=0, ge=0, le=1)
    confidence: float = Field(ge=0, le=1)
    analysis_version: str = "v1"
