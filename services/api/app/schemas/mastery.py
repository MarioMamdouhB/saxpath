from pydantic import BaseModel, Field


class SkillMasteryEntry(BaseModel):
    skill: str
    score: int
    status: str
    focus_label: str
    last_updated_at: str | None = None
    trend_label: str = "waiting_for_signal"
    recommended_next_drill_ar: str = ""
    recent_deltas: list[int] = Field(default_factory=list)


class SkillMasteryResponse(BaseModel):
    weak_skill: str | None = None
    updated_at: str | None = None
    skills: list[SkillMasteryEntry] = Field(default_factory=list)
