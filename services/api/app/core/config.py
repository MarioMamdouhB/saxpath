from functools import lru_cache

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    environment: str = "development"
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    api_v1_prefix: str = "/api/v1"
    cors_allow_origins: list[str] = ["*"]
    postgres_host: str = "postgres"
    postgres_port: int = 5432
    postgres_db: str = "saxpath"
    postgres_user: str = "saxpath"
    postgres_password: str = "saxpath"
    persistence_backend: str = "demo_file"
    demo_learner_id: str = "demo"
    recording_storage_dir: str = "data/recordings"
    audio_engine_base_url: str = "http://127.0.0.1:8010"
    demo_mode: bool = False

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    @model_validator(mode="after")
    def validate_production_cors(self) -> "Settings":
        if self.environment.lower() == "production" and "*" in self.cors_allow_origins:
            raise ValueError("Production CORS must list explicit origins.")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
