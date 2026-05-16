from pydantic import BaseModel, Field


class ExpectedEvent(BaseModel):
    note: str
    onset_seconds: float
    duration_seconds: float = 0.75


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
    skill_tags: list[str] = Field(default_factory=list)
    block_type: str | None = None
    target_bpm: int | None = None
    reference_audio_url: str | None = None
    fingering_hint_id: str | None = None
    expected_event_timeline: list[ExpectedEvent] = Field(default_factory=list)
    recommended_loop_target: int | None = None
    supports_wait_mode: bool = False
    adaptation_reason_ar: str | None = None
    is_focus_task: bool = False
    # V3.1 Content System Fields
    license_status: str = "original"
    source_id: str | None = None
    publish_status: str = "approved_publishable"


class DailyPlanResponse(BaseModel):
    user_name: str
    day_number: int
    total_minutes: int
    progress_percent: int
    tasks: list[DailyTask]
    stage_id: str | None = None


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
