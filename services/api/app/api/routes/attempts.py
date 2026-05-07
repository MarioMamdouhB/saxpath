from fastapi import APIRouter

from app.schemas.attempt import AttemptCreateRequest, AttemptEvaluationResponse
from app.services.evaluation import submit_mock_attempt

router = APIRouter(prefix="/attempts", tags=["attempts"])


@router.post("", response_model=AttemptEvaluationResponse)
def create_attempt(payload: AttemptCreateRequest) -> AttemptEvaluationResponse:
    return submit_mock_attempt(payload)
