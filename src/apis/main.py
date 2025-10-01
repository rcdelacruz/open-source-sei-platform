"""SEI Platform API Service - Main Application."""
import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from config import settings
from database import engine, Base
from routes import health, organizations, teams, repositories, developers, analytics


# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifespan."""
    # Startup
    logger.info("api_service_starting", environment=settings.environment)

    # Create database tables (for development)
    # In production, use Alembic migrations
    if settings.environment == "development":
        Base.metadata.create_all(bind=engine)
        logger.info("database_tables_created")

    yield

    # Shutdown
    logger.info("api_service_shutting_down")


# Create FastAPI application
app = FastAPI(
    title="SEI Platform API",
    description="Software Engineering Intelligence Platform - Main API Service",
    version="0.1.0",
    lifespan=lifespan,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["health"])
app.include_router(
    organizations.router,
    prefix="/api/v1/organizations",
    tags=["organizations"]
)
app.include_router(
    teams.router,
    prefix="/api/v1/teams",
    tags=["teams"]
)
app.include_router(
    repositories.router,
    prefix="/api/v1/repositories",
    tags=["repositories"]
)
app.include_router(
    developers.router,
    prefix="/api/v1/developers",
    tags=["developers"]
)
app.include_router(
    analytics.router,
    prefix="/api/v1/analytics",
    tags=["analytics"]
)


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "service": "SEI Platform API",
        "version": "0.1.0",
        "status": "operational",
        "docs": "/docs",
        "health": "/health"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8080,
        reload=settings.debug,
        log_level=settings.log_level.lower()
    )