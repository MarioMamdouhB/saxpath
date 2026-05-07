from fastapi import APIRouter

from app.schemas.daily_plan import DailyPlanResponse
from app.services.mock_content import get_today_daily_plan

router = APIRouter(prefix="/daily-plan", tags=["daily-plan"])


@router.get("/today", response_model=DailyPlanResponse)
def get_today_plan() -> DailyPlanResponse:
    return get_today_daily_plan()
