"""Configuration management for API Service."""
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import List


class Settings(BaseSettings):
    """Application settings."""

    # Application
    environment: str = "development"
    log_level: str = "INFO"
    debug: bool = True
    api_title: str = "SEI Platform API"
    api_version: str = "0.1.0"

    # Security
    jwt_secret: str = "your_jwt_secret_here_change_in_production"
    jwt_algorithm: str = "HS256"
    jwt_expiration: int = 3600  # 1 hour
    encryption_key: str = "your_encryption_key_here"

    # CORS
    cors_origins: List[str] = ["*"]

    # Database
    timescale_url: str = "postgresql://sei_user:sei_password@timescaledb:5432/sei_platform"
    postgres_url: str = "postgresql://sei_user:sei_password@postgresql:5432/sei_metadata"

    # Redis
    redis_url: str = "redis://redis:6379"

    # API Rate Limiting
    rate_limit_requests: int = 1000
    rate_limit_window: int = 3600

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()