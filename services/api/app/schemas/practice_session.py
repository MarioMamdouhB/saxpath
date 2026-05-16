from pydantic import BaseModel, Field


class PracticeBlock(BaseModel):
    id: str
    title: str
    block_type: str
    duration_minutes: int
    status: str
    focus_hint_ar: str
    task_ids: list[str] = Field(default_factory=list)
    skill_tags: list[str] = Field(default_factory=list)
    loop_target: int = 2
    supports_wait_mode: bool = False
    visual_focus_notes: list[str] = Field(default_factory=list)
    recommended_bpm: int | None = None
    adaptation_reason_ar: str | None = None
    recommended_next_drill_ar: str | None = None


class PracticeSessionResponse(BaseModel):
    track: str
    day_number: int
    total_minutes: int
    stage_id: str
    stage_title: str
    stage_subtitle_ar: str
    stage_progress_percent: int
    guided_path_label: str
    weak_skill: str | None = None
    recommended_focus_ar: str
    recommended_next_drill_ar: str | None = None
    adaptation_reason_ar: str | None = None
    source: str = "adaptive_rule_engine_v1"
    blocks: list[PracticeBlock] = Field(default_factory=list)
