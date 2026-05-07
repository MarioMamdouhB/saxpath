from fastapi import APIRouter

from app.schemas.lesson import LessonResponse
from app.services.mock_content import get_lessons

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.get("", response_model=list[LessonResponse])
def list_lessons() -> list[LessonResponse]:
    return get_lessons()
