from fastapi import APIRouter

from app.schemas.progress import LearnerProgressResponse
from app.services.persistence import (
    complete_day,
    get_learner_progress,
    reset_progress,
)

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("", response_model=LearnerProgressResponse)
def read_progress() -> LearnerProgressResponse:
    return get_learner_progress()


@router.post("/day/{day_number}/complete", response_model=LearnerProgressResponse)
def complete_progress_day(day_number: int) -> LearnerProgressResponse:
    return complete_day(day_number)


@router.post("/reset", response_model=LearnerProgressResponse)
def reset_progress_state() -> LearnerProgressResponse:
    return reset_progress()
