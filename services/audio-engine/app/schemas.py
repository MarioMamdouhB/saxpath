from pydantic import BaseModel, Field


class DetectedNote(BaseModel):
    note: str
    frequency_hz: float
    confidence: float


class TimingError(BaseModel):
    onset_seconds: float
    expected_seconds: float
    error_ms: float


class AudioAnalysisResponse(BaseModel):
    pitch_score: int = Field(ge=0, le=100)
    rhythm_score: int = Field(ge=0, le=100)
    detected_notes: list[DetectedNote]
    timing_errors: list[TimingError]
    confidence: float = Field(ge=0, le=1)
