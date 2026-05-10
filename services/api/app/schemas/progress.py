from pydantic import BaseModel


class LearnerProgressResponse(BaseModel):
    completed_days: list[int]
    completed_days_count: int
    current_day_number: int
    total_days: int
    current_streak_days: int = 0
    last_completed_at: str | None = None
