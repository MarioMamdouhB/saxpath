from pydantic import BaseModel


class AttemptCreateRequest(BaseModel):
    exercise_id: str
    duration_seconds: int
    audio_url: str


class AttemptEvaluationResponse(BaseModel):
    attempt_id: str
    pitch_accuracy: int
    rhythm_accuracy: int
    completion: int
    feedback_ar: str
    next_recommendation: str
