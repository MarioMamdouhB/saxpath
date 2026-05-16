from enum import Enum
from pydantic import BaseModel, Field

class LicenseStatus(str, Enum):
    ORIGINAL = "original"
    CC0 = "cc0"
    CC_BY = "cc_by"
    CC_BY_SA = "cc_by_sa"
    PERMISSION_GRANTED = "permission_granted"
    REFERENCE_ONLY = "reference_only"
    UNKNOWN_BLOCKED = "unknown_blocked"

class ReviewState(str, Enum):
    DRAFT = "draft"
    REVIEW_NEEDED = "review_needed"
    APPROVED_REFERENCE = "approved_reference"
    APPROVED_PUBLISHABLE = "approved_publishable"
    BLOCKED = "blocked"

class SourceRecord(BaseModel):
    id: str
    title: str
    institution: str | None = None
    source_type: str # e.g. "university_curriculum", "method_book", "original"
    url: str | None = None
    license_type: str | None = None
    commercial_use_allowed: bool = False
    attribution_required: bool = True
    verification_status: str = "pending"

class ContentAsset(BaseModel):
    id: str
    asset_type: str # e.g. "lesson_text", "audio_demo", "video_clip", "drill_prompt"
    license_status: LicenseStatus
    source_record_ids: list[str] = Field(default_factory=list)
    attribution_text: str | None = None
    publish_status: ReviewState = ReviewState.DRAFT
