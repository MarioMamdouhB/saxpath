import json
import logging
import time
import wave

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from starlette.requests import Request

from app.analysis import analyze_pitch_wav, analyze_rhythm_wav
from app.schemas import AudioAnalysisResponse

app = FastAPI(title="SaxPath Audio Engine", version="0.1.0")
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("saxpath.audio_engine")


@app.middleware("http")
async def log_requests(request: Request, call_next):
    started_at = time.perf_counter()
    response = await call_next(request)
    duration_ms = round((time.perf_counter() - started_at) * 1000, 2)
    logger.info(
        json.dumps(
            {
                "event": "http_request",
                "service": "saxpath-audio-engine",
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "duration_ms": duration_ms,
            },
            ensure_ascii=False,
        )
    )
    return response


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "saxpath-audio-engine"}


@app.post("/api/v1/audio-analysis/pitch", response_model=AudioAnalysisResponse)
async def analyze_pitch(
    file: UploadFile = File(...),
    expected_note: str = Form("G"),
) -> AudioAnalysisResponse:
    wav_bytes = await file.read()
    try:
        return analyze_pitch_wav(wav_bytes, expected_note=expected_note)
    except (ValueError, wave.Error, EOFError) as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@app.post("/api/v1/audio-analysis/rhythm", response_model=AudioAnalysisResponse)
async def analyze_rhythm(
    file: UploadFile = File(...),
    bpm: int = Form(60),
    rhythm_target: str = Form("quarter_note"),
) -> AudioAnalysisResponse:
    wav_bytes = await file.read()
    try:
        return analyze_rhythm_wav(
            wav_bytes,
            bpm=bpm,
            rhythm_target=rhythm_target,
        )
    except (ValueError, wave.Error, EOFError) as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
