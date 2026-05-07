from pydantic import BaseModel


class DailyTask(BaseModel):
    id: str
    type: str
    title: str
    duration_minutes: int
    status: str


class DailyPlanResponse(BaseModel):
    user_name: str
    day_number: int
    total_minutes: int
    progress_percent: int
    tasks: list[DailyTask]
