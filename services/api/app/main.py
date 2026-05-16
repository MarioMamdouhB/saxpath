import json
import logging
import time

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.requests import Request

from app.api.routes.analytics import router as analytics_router
from app.api.routes.audio_analysis import router as audio_analysis_router
from app.api.routes.attempts import router as attempts_router
from app.api.routes.daily_plan import router as daily_plan_router
from app.api.routes.health import router as health_router
from app.api.routes.lessons import router as lessons_router
from app.api.routes.mastery import router as mastery_router
from app.api.routes.practice_sessions import router as practice_sessions_router
from app.api.routes.progress import router as progress_router
from app.api.routes.recordings import router as recordings_router
from app.api.routes.tracks import router as tracks_router
from app.core.config import get_settings

settings = get_settings()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("saxpath.api")

app = FastAPI(title="SaxPath API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    started_at = time.perf_counter()
    response = await call_next(request)
    duration_ms = round((time.perf_counter() - started_at) * 1000, 2)
    logger.info(
        json.dumps(
            {
                "event": "http_request",
                "service": "saxpath-api",
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "duration_ms": duration_ms,
            },
            ensure_ascii=False,
        )
    )
    return response


app.include_router(health_router)
app.include_router(daily_plan_router, prefix=settings.api_v1_prefix)
app.include_router(lessons_router, prefix=settings.api_v1_prefix)
app.include_router(attempts_router, prefix=settings.api_v1_prefix)
app.include_router(recordings_router, prefix=settings.api_v1_prefix)
app.include_router(audio_analysis_router, prefix=settings.api_v1_prefix)
app.include_router(analytics_router, prefix=settings.api_v1_prefix)
app.include_router(progress_router, prefix=settings.api_v1_prefix)
app.include_router(mastery_router, prefix=settings.api_v1_prefix)
app.include_router(practice_sessions_router, prefix=settings.api_v1_prefix)
app.include_router(tracks_router, prefix=settings.api_v1_prefix)
