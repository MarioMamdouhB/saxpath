from fastapi import APIRouter

from app.schemas.analytics import AnalyticsEventCreateRequest, AnalyticsEventResponse
from app.services.persistence import list_analytics_events, record_analytics_event

router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.post("/events", response_model=AnalyticsEventResponse)
def create_analytics_event(
    payload: AnalyticsEventCreateRequest,
) -> AnalyticsEventResponse:
    return record_analytics_event(payload)


@router.get("/events", response_model=list[AnalyticsEventResponse])
def get_analytics_events(limit: int = 20) -> list[AnalyticsEventResponse]:
    return list_analytics_events(limit=limit)
