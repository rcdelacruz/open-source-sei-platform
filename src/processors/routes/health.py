"""Health check endpoints."""
from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()


class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    service: str
    version: str
    timestamp: datetime


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint.

    Returns service health status.
    """
    return HealthResponse(
        status="healthy",
        service="data-processor",
        version="0.1.0",
        timestamp=datetime.utcnow()
    )


@router.get("/ready")
async def readiness_check():
    """
    Readiness check endpoint.

    Checks if service is ready to accept requests.
    """
    # TODO: Add checks for Kafka, TimescaleDB, PostgreSQL
    return {"ready": True, "checks": {}}