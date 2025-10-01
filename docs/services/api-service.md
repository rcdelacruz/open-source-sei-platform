# API Service

The API Service is the main REST API layer of the SEI platform. It provides endpoints for accessing all platform data, metrics, and analytics. The service acts as the primary interface for frontend applications and external integrations.

## Overview

The service is built using FastAPI and provides a comprehensive REST API for the SEI platform. It connects to both TimescaleDB for time-series data and PostgreSQL for metadata storage.

### Key Responsibilities

- Serve REST API endpoints for all resources
- Query and aggregate metrics data
- Manage organizations, teams, and users
- Provide authentication and authorization
- Handle data validation and transformation
- Serve real-time updates via WebSockets

## Architecture

### Service Components

**Main Application** (`main.py`)

- FastAPI application with CORS middleware
- Structured logging using structlog
- Database connection management
- Route registration and lifecycle management

**Routes**

- `/health` - Service health check
- `/api/v1/organizations` - Organization management
- `/api/v1/teams` - Team management
- `/api/v1/repositories` - Repository information
- `/api/v1/developers` - Developer metrics
- `/api/v1/analytics` - Analytics and metrics

**Database** (`database.py`)

- SQLAlchemy ORM configuration
- Database connection pooling
- Session management
- Model base classes

**Configuration** (`config.py`)

- Environment-based configuration
- Database connection settings
- CORS configuration
- Security settings

### Data Flow

```
Frontend/Clients → API Service → TimescaleDB (metrics)
                                → PostgreSQL (metadata)
                                → Redis (cache)
```

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `TIMESCALE_URL` | TimescaleDB connection URL | Yes | - |
| `POSTGRES_URL` | PostgreSQL connection URL | Yes | - |
| `REDIS_URL` | Redis connection URL | Yes | `redis://redis:6379` |
| `LOG_LEVEL` | Logging level | No | `INFO` |
| `CORS_ORIGINS` | Allowed CORS origins | No | `*` |
| `DEBUG` | Enable debug mode | No | `false` |
| `SECRET_KEY` | JWT secret key | Yes | - |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiration | No | `30` |

### Docker Configuration

The service is configured in `docker-compose.yml`:

```yaml
api-service:
  build:
    context: ./src/apis
    dockerfile: Dockerfile
  container_name: sei-api-service
  depends_on:
    - timescaledb
    - postgresql
    - redis
  environment:
    TIMESCALE_URL: postgresql://sei_user:sei_password@timescaledb:5432/sei_platform
    POSTGRES_URL: postgresql://sei_user:sei_password@postgresql:5432/sei_metadata
    REDIS_URL: redis://redis:6379
    LOG_LEVEL: INFO
  ports:
    - "8080:8080"
```

## Development

### Local Setup

1. Navigate to the service directory:

    ```bash
    cd src/apis
    ```

2. Install dependencies:

    ```bash
    pip install -r requirements.txt
    ```

3. Run the service:

    ```bash
    python main.py
    ```

The service will start on `http://localhost:8080`.

### Running with Docker

```bash
docker-compose up api-service
```

### Running Tests

```bash
pytest tests/apis/
```

### API Documentation

Once running, visit:

- Swagger UI: `http://localhost:8080/docs`
- ReDoc: `http://localhost:8080/redoc`
- OpenAPI JSON: `http://localhost:8080/openapi.json`

## API Endpoints

### Root Endpoint

**GET /**

Returns API information and available endpoints.

**Response**

```json
{
  "service": "SEI Platform API",
  "version": "0.1.0",
  "status": "operational",
  "docs": "/docs",
  "health": "/health"
}
```

### Health Check

**GET /health**

Returns service health status and dependency connectivity.

**Response**

```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2025-10-01T12:00:00Z",
  "dependencies": {
    "timescaledb": "connected",
    "postgresql": "connected",
    "redis": "connected"
  }
}
```

### Organizations API

**GET /api/v1/organizations**

List all organizations with pagination.

**Query Parameters**

- `skip` (integer, optional): Number of records to skip. Default: `0`
- `limit` (integer, optional): Maximum records to return. Default: `100`

**Response**

```json
{
  "total": 50,
  "items": [
    {
      "id": "org-123",
      "name": "Acme Corporation",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-10-01T12:00:00Z"
    }
  ]
}
```

**POST /api/v1/organizations**

Create a new organization.

**Request Body**

```json
{
  "name": "New Organization",
  "description": "Organization description",
  "settings": {
    "timezone": "UTC",
    "default_language": "en"
  }
}
```

**GET /api/v1/organizations/{organization_id}**

Get organization details by ID.

**PUT /api/v1/organizations/{organization_id}**

Update an organization.

**DELETE /api/v1/organizations/{organization_id}**

Delete an organization.

### Teams API

**GET /api/v1/teams**

List all teams with filtering and pagination.

**Query Parameters**

- `organization_id` (string, optional): Filter by organization
- `skip` (integer, optional): Number of records to skip. Default: `0`
- `limit` (integer, optional): Maximum records to return. Default: `100`

**Response**

```json
{
  "total": 25,
  "items": [
    {
      "id": "team-456",
      "name": "Platform Team",
      "organization_id": "org-123",
      "members_count": 8,
      "created_at": "2025-01-15T00:00:00Z"
    }
  ]
}
```

**POST /api/v1/teams**

Create a new team.

**GET /api/v1/teams/{team_id}**

Get team details including members and metrics.

**PUT /api/v1/teams/{team_id}**

Update team information.

**DELETE /api/v1/teams/{team_id}**

Delete a team.

### Repositories API

**GET /api/v1/repositories**

List repositories with filtering.

**Query Parameters**

- `team_id` (string, optional): Filter by team
- `organization_id` (string, optional): Filter by organization
- `skip` (integer, optional): Number of records to skip. Default: `0`
- `limit` (integer, optional): Maximum records to return. Default: `100`

**Response**

```json
{
  "total": 150,
  "items": [
    {
      "id": "repo-789",
      "name": "backend-api",
      "url": "https://github.com/org/backend-api",
      "language": "Python",
      "team_id": "team-456",
      "last_commit": "2025-10-01T10:30:00Z",
      "commit_count": 1250
    }
  ]
}
```

**POST /api/v1/repositories**

Register a new repository.

**GET /api/v1/repositories/{repository_id}**

Get repository details and statistics.

**GET /api/v1/repositories/{repository_id}/commits**

Get commit history for a repository.

**GET /api/v1/repositories/{repository_id}/pull-requests**

Get pull requests for a repository.

### Developers API

**GET /api/v1/developers**

List developers with metrics.

**Query Parameters**

- `team_id` (string, optional): Filter by team
- `skip` (integer, optional): Number of records to skip. Default: `0`
- `limit` (integer, optional): Maximum records to return. Default: `100`

**Response**

```json
{
  "total": 75,
  "items": [
    {
      "id": "dev-101",
      "name": "John Doe",
      "email": "john@example.com",
      "team_id": "team-456",
      "metrics": {
        "commits_last_30d": 45,
        "prs_opened": 12,
        "prs_reviewed": 25,
        "lines_added": 2500,
        "lines_deleted": 800
      }
    }
  ]
}
```

**GET /api/v1/developers/{developer_id}**

Get developer details and comprehensive metrics.

**GET /api/v1/developers/{developer_id}/activity**

Get developer activity timeline.

### Analytics API

**GET /api/v1/analytics/dora-metrics**

Get DORA metrics for specified time range.

**Query Parameters**

- `team_id` (string, optional): Filter by team
- `repository_id` (string, optional): Filter by repository
- `start_date` (string, required): Start date (ISO 8601)
- `end_date` (string, required): End date (ISO 8601)
- `granularity` (string, optional): `daily`, `weekly`, `monthly`. Default: `daily`

**Response**

```json
{
  "deployment_frequency": {
    "value": 15.2,
    "unit": "per_week",
    "trend": "increasing"
  },
  "lead_time_for_changes": {
    "median_hours": 4.5,
    "p90_hours": 12.0,
    "trend": "decreasing"
  },
  "change_failure_rate": {
    "percentage": 5.2,
    "trend": "stable"
  },
  "time_to_restore": {
    "median_hours": 2.0,
    "p90_hours": 6.5,
    "trend": "decreasing"
  }
}
```

**GET /api/v1/analytics/velocity**

Get team velocity metrics.

**Query Parameters**

- `team_id` (string, required): Team identifier
- `sprint_count` (integer, optional): Number of sprints. Default: `6`

**Response**

```json
{
  "sprints": [
    {
      "sprint_id": "sprint-10",
      "name": "Sprint 10",
      "start_date": "2025-09-15",
      "end_date": "2025-09-29",
      "planned_points": 50,
      "completed_points": 48,
      "velocity": 48,
      "completion_rate": 0.96
    }
  ],
  "average_velocity": 46.5,
  "trend": "stable"
}
```

**GET /api/v1/analytics/code-quality**

Get code quality metrics.

**Query Parameters**

- `repository_id` (string, optional): Filter by repository
- `team_id` (string, optional): Filter by team
- `start_date` (string, required): Start date
- `end_date` (string, required): End date

**Response**

```json
{
  "test_coverage": 85.5,
  "code_smells": 23,
  "technical_debt_hours": 45.5,
  "security_issues": 2,
  "bugs": 8,
  "vulnerabilities": 1
}
```

**GET /api/v1/analytics/cycle-time**

Get cycle time breakdown.

**Query Parameters**

- `team_id` (string, optional): Filter by team
- `start_date` (string, required): Start date
- `end_date` (string, required): End date

**Response**

```json
{
  "total_cycle_time_hours": 72.5,
  "breakdown": {
    "coding_hours": 24.0,
    "review_hours": 18.5,
    "testing_hours": 16.0,
    "deployment_hours": 14.0
  },
  "percentiles": {
    "p50": 65.0,
    "p75": 85.0,
    "p90": 120.0
  }
}
```

## Database Models

### SQLAlchemy Models

**Organization**

```python
class Organization(Base):
    __tablename__ = "organizations"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    settings = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
```

**Team**

```python
class Team(Base):
    __tablename__ = "teams"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    organization_id = Column(String, ForeignKey("organizations.id"))
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
```

**Repository**

```python
class Repository(Base):
    __tablename__ = "repositories"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    url = Column(String, unique=True)
    team_id = Column(String, ForeignKey("teams.id"))
    language = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
```

## Authentication

### JWT Authentication

The API uses JWT tokens for authentication.

**POST /api/v1/auth/login**

Login and receive JWT token.

**Request Body**

```json
{
  "username": "user@example.com",
  "password": "secure_password"
}
```

**Response**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 1800
}
```

**Using the Token**

Include the token in the Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Caching Strategy

### Redis Caching

The API uses Redis for caching frequently accessed data:

- Organization and team information
- Repository metadata
- User profiles
- Recent metrics queries

### Cache Keys

- `api:org:{organization_id}` - Organization cache
- `api:team:{team_id}` - Team cache
- `api:repo:{repository_id}` - Repository cache
- `api:metrics:{query_hash}` - Metrics query cache

### Cache TTL

- Organizations: 1 hour
- Teams: 30 minutes
- Repositories: 15 minutes
- Metrics: 5 minutes

## Monitoring

### Health Checks

The service provides comprehensive health checks:

- Database connectivity
- Redis connectivity
- API responsiveness
- Dependency status

### Metrics

Prometheus metrics are exposed at `/metrics`:

- `api_requests_total` - Total API requests
- `api_requests_duration_seconds` - Request duration
- `api_requests_failed_total` - Failed requests
- `api_active_connections` - Active connections
- `api_database_queries_total` - Database queries

### Logging

Structured JSON logging includes:

- Request/response logging
- Database query logging
- Error tracking
- Performance metrics
- Security events

## Error Handling

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

### Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## Security

### CORS Configuration

CORS is configured to allow specific origins:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Rate Limiting

Rate limiting is implemented per API key:

- 1000 requests per hour for authenticated users
- 100 requests per hour for unauthenticated users

### SQL Injection Prevention

- SQLAlchemy ORM with parameterized queries
- Input validation using Pydantic models
- Query sanitization

### Data Privacy

- Sensitive data filtering
- PII handling compliance
- Audit logging
- Data encryption at rest

## Performance

### Query Optimization

- Database connection pooling
- Query result caching
- Lazy loading of relationships
- Pagination for large datasets

### Resource Requirements

**Development**

- CPU: 1 core
- Memory: 1 GB
- Storage: Minimal

**Production**

- CPU: 4-8 cores
- Memory: 4-8 GB
- Storage: 10 GB

## Troubleshooting

### Common Issues

**Database Connection Errors**

- Verify database URLs in environment variables
- Check database service status
- Review connection pool settings
- Monitor active connections

**Slow API Responses**

- Enable query logging
- Check database indexes
- Review cache hit rates
- Monitor resource usage

**Authentication Failures**

- Verify JWT secret key
- Check token expiration
- Review CORS settings
- Validate credentials

### Debug Mode

Enable debug logging:

```bash
DEBUG=true LOG_LEVEL=DEBUG docker-compose up api-service
```

### Query Profiling

Enable SQL query logging:

```bash
SQLALCHEMY_ECHO=true python main.py
```

## API Versioning

The API uses URL-based versioning:

- Current version: `/api/v1/*`
- Future versions: `/api/v2/*`

Deprecated endpoints will be maintained for 6 months with deprecation warnings.

## Future Enhancements

- GraphQL API support
- WebSocket subscriptions for real-time updates
- Advanced filtering and search capabilities
- Bulk operation endpoints
- Data export functionality
- Custom report generation
- API analytics dashboard
- Enhanced caching strategies
