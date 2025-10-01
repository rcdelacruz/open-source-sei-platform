"""Developers endpoints."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from datetime import datetime
import uuid

from database import get_db

router = APIRouter()


class DeveloperBase(BaseModel):
    """Base developer schema."""
    team_id: str | None = None
    email: str
    name: str | None = None
    github_username: str | None = None
    gitlab_username: str | None = None
    jira_username: str | None = None


class DeveloperCreate(DeveloperBase):
    """Developer creation schema."""
    pass


class DeveloperResponse(DeveloperBase):
    """Developer response schema."""
    id: str
    is_active: bool
    joined_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


@router.get("/", response_model=List[DeveloperResponse])
async def list_developers(
    team_id: str | None = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """List all developers."""
    # TODO: Implement actual database query
    return []


@router.post("/", response_model=DeveloperResponse)
async def create_developer(
    developer: DeveloperCreate,
    db: Session = Depends(get_db)
):
    """Create a new developer."""
    # TODO: Implement actual database insert
    return DeveloperResponse(
        id=str(uuid.uuid4()),
        **developer.dict(),
        is_active=True,
        joined_at=datetime.utcnow(),
        created_at=datetime.utcnow()
    )