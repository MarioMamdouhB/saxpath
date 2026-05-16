from pydantic import BaseModel, Field

class StageSummary(BaseModel):
    id: str
    title: str
    description: str
    is_unlocked: bool = True
    is_completed: bool = False
    day_count: int

class TrackResponse(BaseModel):
    id: str
    title: str
    description: str
    stages: list[StageSummary]
