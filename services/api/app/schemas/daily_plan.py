from pydantic import BaseModel, Field


class DailyTask(BaseModel):
    id: str
    type: str
    title: str
    duration_minutes: int
    status: str
    level: str | None = None
    expected_notes: list[str] = Field(default_factory=list)
    rhythm_target: str | None = None
    locked_reason: str | None = None
    retry_reason: str | None = None


class DailyPlanResponse(BaseModel):
    user_name: str
    day_number: int
    total_minutes: int
    progress_percent: int
    tasks: list[DailyTask]


class WeekDaySummary(BaseModel):
    day_number: int
    focus_title: str
    total_minutes: int
    status: str
    progress_percent: int


class WeekOverviewResponse(BaseModel):
    current_day_number: int
    total_days: int
    completed_days: int
    days: list[WeekDaySummary]
