from fastapi import APIRouter

from app.schemas.practice_session import PracticeSessionResponse
from app.services.practice_sessions import (
    get_practice_session_for_day,
    get_today_practice_session,
)

router = APIRouter(prefix="/practice-sessions", tags=["practice-sessions"])


@router.get("/today", response_model=PracticeSessionResponse)
def read_today_practice_session(track: str = "beginner") -> PracticeSessionResponse:
    return get_today_practice_session(track=track)


@router.get("/day/{day_number}", response_model=PracticeSessionResponse)
def read_practice_session_for_day(
    day_number: int,
    track: str = "beginner",
) -> PracticeSessionResponse:
    return get_practice_session_for_day(day_number, track=track)
