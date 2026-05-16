from fastapi import APIRouter, HTTPException

from app.schemas.lesson import LessonResponse
from app.services.mock_content import get_lessons

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.get("", response_model=list[LessonResponse])
def list_lessons(day_number: int | None = None, track: str = "beginner") -> list[LessonResponse]:
    try:
        return get_lessons(day_number=day_number, track=track)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
