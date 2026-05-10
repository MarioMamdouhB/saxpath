from pydantic import BaseModel


class AnalyticsEventCreateRequest(BaseModel):
    event_name: str
    day_number: int | None = None
    task_id: str | None = None
    attempt_id: str | None = None
    metadata: dict[str, str | int | float | bool] = {}


class AnalyticsEventResponse(BaseModel):
    event_id: str
    event_name: str
    day_number: int | None = None
    task_id: str | None = None
    attempt_id: str | None = None
    metadata: dict[str, str | int | float | bool] = {}
    created_at: str
