"""Health check endpoints."""
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import text

from database import get_db, get_timescale_db

router = APIRouter()


class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    service: str
    version: str
    timestamp: datetime


class ReadinessResponse(BaseModel):
    """Readiness check response model."""
    ready: bool
    checks: dict


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint.

    Returns service health status.
    """
    return HealthResponse(
        status="healthy",
        service="api-service",
        version="0.1.0",
        timestamp=datetime.utcnow()
    )


@router.get("/ready", response_model=ReadinessResponse)
async def readiness_check(
    db: Session = Depends(get_db),
    timescale_db: Session = Depends(get_timescale_db)
):
    """
    Readiness check endpoint.

    Checks if service is ready to accept requests by verifying:
    - PostgreSQL connection
    - TimescaleDB connection
    """
    checks = {}

    # Check PostgreSQL
    try:
        db.execute(text("SELECT 1"))
        checks["postgres"] = "healthy"
    except Exception as e:
        checks["postgres"] = f"unhealthy: {str(e)}"

    # Check TimescaleDB
    try:
        timescale_db.execute(text("SELECT 1"))
        checks["timescaledb"] = "healthy"
    except Exception as e:
        checks["timescaledb"] = f"unhealthy: {str(e)}"

    # Service is ready if all checks pass
    ready = all(status == "healthy" for status in checks.values())

    return ReadinessResponse(ready=ready, checks=checks)