"""Collector endpoints."""
from fastapi import APIRouter
from pydantic import BaseModel
import structlog

router = APIRouter()
logger = structlog.get_logger()


class CollectionRequest(BaseModel):
    """Request model for manual collection trigger."""
    project_key: str
    full_sync: bool = False


class CollectionResponse(BaseModel):
    """Response model for collection operation."""
    status: str
    message: str
    project_key: str


@router.post("/collect/trigger", response_model=CollectionResponse)
async def trigger_collection(request: CollectionRequest):
    """
    Manually trigger data collection for a Jira project.

    Args:
        request: Collection request with project key

    Returns:
        Collection status and message
    """
    logger.info(
        "collection_triggered",
        project_key=request.project_key,
        full_sync=request.full_sync
    )

    # TODO: Implement actual collection logic
    return CollectionResponse(
        status="queued",
        message="Collection job has been queued for processing",
        project_key=request.project_key
    )


@router.get("/collect/status/{project_key}")
async def get_collection_status(project_key: str):
    """
    Get collection status for a Jira project.

    Args:
        project_key: Jira project key

    Returns:
        Current collection status
    """
    # TODO: Implement status tracking
    return {
        "project_key": project_key,
        "status": "idle",
        "last_sync": None,
        "next_sync": None
    }