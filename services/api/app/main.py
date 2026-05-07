from fastapi import FastAPI

from app.api.routes.attempts import router as attempts_router
from app.api.routes.daily_plan import router as daily_plan_router
from app.api.routes.health import router as health_router
from app.api.routes.lessons import router as lessons_router
from app.core.config import get_settings

settings = get_settings()

app = FastAPI(title="SaxPath API", version="0.1.0")

app.include_router(health_router)
app.include_router(daily_plan_router, prefix=settings.api_v1_prefix)
app.include_router(lessons_router, prefix=settings.api_v1_prefix)
app.include_router(attempts_router, prefix=settings.api_v1_prefix)
