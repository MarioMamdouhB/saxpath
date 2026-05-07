from pydantic import BaseModel


class LessonResponse(BaseModel):
    id: str
    type: str
    title: str
    note: str | None = None
    arabic_name: str | None = None
    rhythm: str | None = None
    description_ar: str
    duration_minutes: int
