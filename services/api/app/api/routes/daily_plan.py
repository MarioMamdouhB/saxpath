from fastapi import APIRouter, HTTPException

from app.schemas.daily_plan import DailyPlanResponse, WeekOverviewResponse
from app.services.mock_content import get_daily_plan, get_today_daily_plan, get_week_overview

router = APIRouter(prefix="/daily-plan", tags=["daily-plan"])


@router.get("/today", response_model=DailyPlanResponse)
def get_today_plan() -> DailyPlanResponse:
    return get_today_daily_plan()


@router.get("/week", response_model=WeekOverviewResponse)
def get_week_plan() -> WeekOverviewResponse:
    return get_week_overview()


@router.get("/day/{day_number}", response_model=DailyPlanResponse)
def get_plan_for_day(day_number: int) -> DailyPlanResponse:
    try:
        return get_daily_plan(day_number)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
