from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from app.schemas.attempt import AttemptAnalysis
from app.services.audio_analysis import AudioAnalysisInputError, analyze_upload

router = APIRouter(prefix="/audio-analysis", tags=["audio-analysis"])


@router.post("/pitch", response_model=AttemptAnalysis)
async def analyze_pitch_upload(
    file: UploadFile = File(...),
    expected_note: str = Form("G"),
) -> AttemptAnalysis:
    try:
        return await analyze_upload(
            file=file,
            kind="pitch",
            expected_note=expected_note,
        )
    except AudioAnalysisInputError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/rhythm", response_model=AttemptAnalysis)
async def analyze_rhythm_upload(
    file: UploadFile = File(...),
    bpm: int = Form(60),
    rhythm_target: str = Form("quarter_note"),
) -> AttemptAnalysis:
    try:
        return await analyze_upload(
            file=file,
            kind="rhythm",
            bpm=bpm,
            rhythm_target=rhythm_target,
        )
    except AudioAnalysisInputError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
