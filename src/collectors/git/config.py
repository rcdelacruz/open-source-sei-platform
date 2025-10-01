"""Configuration management for Git Collector Service."""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""

    # Application
    environment: str = "development"
    log_level: str = "INFO"
    debug: bool = True

    # GitHub API
    github_token: str = ""
    github_api_url: str = "https://api.github.com"

    # GitLab API
    gitlab_token: str = ""
    gitlab_api_url: str = "https://gitlab.com/api/v4"

    # Kafka
    kafka_brokers: str = "kafka:9092"
    kafka_topic_prefix: str = "sei_"

    # Redis
    redis_url: str = "redis://redis:6379"

    # Database
    postgres_url: str = "postgresql://sei_user:sei_password@postgresql:5432/sei_metadata"

    # Rate Limiting
    rate_limit_requests: int = 5000
    rate_limit_window: int = 3600

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()