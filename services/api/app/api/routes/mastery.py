from fastapi import APIRouter

from app.schemas.mastery import SkillMasteryResponse
from app.services.mastery import get_skill_mastery

router = APIRouter(prefix="/mastery", tags=["mastery"])


@router.get("", response_model=SkillMasteryResponse)
def read_skill_mastery() -> SkillMasteryResponse:
    return get_skill_mastery()
