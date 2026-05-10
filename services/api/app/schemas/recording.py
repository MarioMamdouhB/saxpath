from pydantic import BaseModel


class RecordingResponse(BaseModel):
    recording_id: str
    filename: str
    duration_seconds: int
    storage_path: str
    playback_url: str
    content_type: str
    created_at: str
