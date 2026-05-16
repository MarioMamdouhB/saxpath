from fastapi import APIRouter, HTTPException

from app.schemas.attempt import (
    AttemptCreateRequest,
    AttemptEvaluationResponse,
    AttemptHistoryEntry,
)
from app.services.mastery import apply_attempt_mastery
from app.services.evaluation import submit_attempt
from app.services.persistence import (
    get_attempt_detail,
    list_attempt_history,
    record_attempt,
    update_teacher_review,
)
from app.services.recordings import get_recording
from app.services.teacher_review import request_teacher_review

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
    mastery_delta = apply_attempt_mastery(
        exercise_id=payload.exercise_id,
        evaluation=evaluation,
    )
    evaluation = evaluation.model_copy(update={"mastery_delta": mastery_delta})
    record_attempt(payload, evaluation)
    return evaluation


@router.get("/history", response_model=list[AttemptHistoryEntry])
def get_attempt_history(limit: int = 20) -> list[AttemptHistoryEntry]:
    return list_attempt_history(limit=limit)


@router.get("/{attempt_id}", response_model=AttemptHistoryEntry)
def read_attempt_detail(attempt_id: str) -> AttemptHistoryEntry:
    attempt = get_attempt_detail(attempt_id)
    if attempt is None:
        raise HTTPException(status_code=404, detail="Attempt not found.")
    return attempt


@router.post("/{attempt_id}/teacher-review", response_model=AttemptHistoryEntry)
def create_teacher_review_request(attempt_id: str) -> AttemptHistoryEntry:
    attempt = get_attempt_detail(attempt_id)
    if attempt is None:
        raise HTTPException(status_code=404, detail="Attempt not found.")

    updated = update_teacher_review(
        attempt_id,
        request_teacher_review(attempt),
    )
    if updated is None:
        raise HTTPException(
            status_code=500,
            detail="Unable to update teacher review state.",
        )
    return updated
