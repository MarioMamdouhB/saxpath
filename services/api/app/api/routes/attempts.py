from fastapi import APIRouter, HTTPException

from app.schemas.attempt import (
    AttemptCreateRequest,
    AttemptEvaluationResponse,
    AttemptHistoryEntry,
)
from app.services.evaluation import submit_attempt
from app.services.persistence import list_attempt_history, record_attempt
from app.services.recordings import get_recording

router = APIRouter(prefix="/attempts", tags=["attempts"])


@router.post("", response_model=AttemptEvaluationResponse)
def create_attempt(payload: AttemptCreateRequest) -> AttemptEvaluationResponse:
    recording = None
    if payload.recording_id is not None:
        recording = get_recording(payload.recording_id)
        if recording is None:
            raise HTTPException(status_code=404, detail="Recording not found.")

        payload = payload.model_copy(
            update={
                "duration_seconds": recording.duration_seconds,
                "audio_url": recording.playback_url,
            }
        )

    evaluation = submit_attempt(payload, recording=recording)
    record_attempt(payload, evaluation)
    return evaluation


@router.get("/history", response_model=list[AttemptHistoryEntry])
def get_attempt_history(limit: int = 20) -> list[AttemptHistoryEntry]:
    return list_attempt_history(limit=limit)
