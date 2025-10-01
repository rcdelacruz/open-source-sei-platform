"""Configuration management for Jira Collector Service."""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""

    # Application
    environment: str = "development"
    log_level: str = "INFO"
    debug: bool = True

    # Jira API
    jira_api_token: str = ""
    jira_base_url: str = "https://your-domain.atlassian.net"
    jira_username: str = ""

    # Kafka
    kafka_brokers: str = "kafka:9092"
    kafka_topic_prefix: str = "sei_"

    # Redis
    redis_url: str = "redis://redis:6379"

    # Database
    postgres_url: str = "postgresql://sei_user:sei_password@postgresql:5432/sei_metadata"

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()