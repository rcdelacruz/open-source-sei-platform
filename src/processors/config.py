"""Configuration management for Data Processor Service."""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""

    # Application
    environment: str = "development"
    log_level: str = "INFO"
    debug: bool = True

    # Kafka
    kafka_brokers: str = "kafka:9092"
    kafka_topic_prefix: str = "sei_"
    kafka_consumer_group: str = "data-processor-group"

    # Redis
    redis_url: str = "redis://redis:6379"

    # TimescaleDB
    timescale_url: str = "postgresql://sei_user:sei_password@timescaledb:5432/sei_platform"

    # PostgreSQL
    postgres_url: str = "postgresql://sei_user:sei_password@postgresql:5432/sei_metadata"

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()