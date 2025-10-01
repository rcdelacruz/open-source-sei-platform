# Git Collector Service

The Git Collector Service is responsible for collecting data from Git-based version control systems including GitHub, GitLab, and Bitbucket. It retrieves repository metadata, commit history, pull requests, code reviews, and contributor information.

## Overview

The service is built using FastAPI and runs as a microservice in the SEI platform architecture. It collects data from Git repositories and publishes it to Apache Kafka for downstream processing.

### Key Responsibilities

- Collect repository metadata and configuration
- Retrieve commit history and statistics
- Fetch pull request and merge request data
- Gather code review information
- Track contributor activity and metrics
- Monitor repository health and activity

## Architecture

### Service Components

**Main Application** (`main.py`)

- FastAPI application with CORS middleware
- Structured logging using structlog
- Health check endpoints
- Collection trigger endpoints

**Routes**

- `/health` - Service health check
- `/api/v1/collect/trigger` - Trigger manual collection
- `/api/v1/collect/status/{repository_id}` - Get collection status

**Configuration** (`config.py`)

- Environment-based configuration
- Kafka broker settings
- Redis connection settings
- API credentials management

### Data Flow

```
Git APIs → Git Collector → Kafka Topics → Data Processor → TimescaleDB
                ↓
             Redis Cache
```

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `KAFKA_BROKERS` | Kafka broker endpoints | Yes | `kafka:9092` |
| `REDIS_URL` | Redis connection URL | Yes | `redis://redis:6379` |
| `LOG_LEVEL` | Logging level | No | `INFO` |
| `GITHUB_TOKEN` | GitHub API token | Conditional | - |
| `GITLAB_TOKEN` | GitLab API token | Conditional | - |
| `BITBUCKET_TOKEN` | Bitbucket API token | Conditional | - |

### Docker Configuration

The service is configured in `docker-compose.yml`:

```yaml
git-collector:
  build:
    context: ./src/collectors/git
    dockerfile: Dockerfile
  container_name: sei-git-collector
  depends_on:
    - kafka
    - redis
  environment:
    KAFKA_BROKERS: kafka:9092
    REDIS_URL: redis://redis:6379
    LOG_LEVEL: INFO
  env_file:
    - .env
```

## API Reference

### POST /api/v1/collect/trigger

Manually trigger data collection for a Git repository.

**Request Body**
```json
{
  "repository_url": "https://github.com/owner/repo",
  "full_sync": false
}
```

**Response**
```json
{
  "status": "queued",
  "message": "Collection job has been queued for processing",
  "repository_url": "https://github.com/owner/repo"
}
```

**Parameters**

- `repository_url` (string, required): Full URL of the Git repository
- `full_sync` (boolean, optional): Whether to perform full sync or incremental. Default: `false`

### GET /api/v1/collect/status/{repository_id}

Get the current collection status for a repository.

**Path Parameters**

- `repository_id` (string, required): Unique repository identifier

**Response**
```json
{
  "repository_id": "repo-123",
  "status": "idle",
  "last_sync": "2025-10-01T12:00:00Z",
  "next_sync": "2025-10-01T13:00:00Z"
}
```

**Status Values**

- `idle` - No collection in progress
- `queued` - Collection job queued
- `running` - Collection in progress
- `completed` - Collection completed successfully
- `failed` - Collection failed

## Development

### Local Setup

1. Navigate to the service directory:
```bash
cd src/collectors/git
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the service:
```bash
python main.py
```

The service will start on `http://localhost:8000`.

### Running with Docker

```bash
docker-compose up git-collector
```

### Running Tests

```bash
pytest tests/collectors/git/
```

## Data Collection

### Supported Platforms

**GitHub**

- Repository metadata
- Commit history
- Pull requests and reviews
- Issues and comments
- Contributors and teams
- Branch protection rules
- Workflow runs (GitHub Actions)

**GitLab**

- Project information
- Commit history
- Merge requests and approvals
- Issues and notes
- Members and groups
- Protected branches
- Pipeline runs

**Bitbucket**

- Repository details
- Commit history
- Pull requests and comments
- Issues and discussions
- Users and teams
- Branch restrictions
- Pipeline executions

### Collection Strategies

**Full Sync**

- Collects all historical data from the repository
- Used for initial setup or data refresh
- Resource intensive, runs during off-peak hours

**Incremental Sync**

- Collects only new data since last sync
- Default collection mode
- Efficient and quick
- Runs on a scheduled basis

**Webhook-Triggered**

- Real-time updates from Git platforms
- Triggered by repository events
- Low latency, immediate processing

## Kafka Integration

### Published Topics

**`git.commits`**

- Individual commit data
- Author information
- File changes and statistics

**`git.pull_requests`**

- Pull request metadata
- Review information
- Merge status and timelines

**`git.repositories`**

- Repository metadata
- Configuration updates
- Health metrics

### Message Format

All messages published to Kafka follow this structure:

```json
{
  "event_type": "commit_created",
  "timestamp": "2025-10-01T12:00:00Z",
  "source": "github",
  "repository_id": "repo-123",
  "data": {
    // Event-specific data
  }
}
```

## Redis Caching

The service uses Redis for:

- **Rate Limiting**: Track API call quotas
- **Deduplication**: Prevent duplicate data collection
- **Status Tracking**: Store collection job status
- **Token Management**: Cache API tokens

### Cache Keys

- `git:ratelimit:{platform}:{repository_id}` - Rate limiting counters
- `git:status:{repository_id}` - Collection status
- `git:last_sync:{repository_id}` - Last sync timestamp

## Monitoring

### Health Checks

The service exposes a `/health` endpoint that returns:

```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2025-10-01T12:00:00Z"
}
```

### Metrics

Metrics are exposed for Prometheus scraping at `/metrics` (when enabled):

- `git_collector_requests_total` - Total API requests made
- `git_collector_requests_failed` - Failed API requests
- `git_collector_collections_total` - Total collection jobs
- `git_collector_processing_duration_seconds` - Processing time

### Logging

Structured JSON logging is configured for:

- Collection job lifecycle
- API request/response
- Error conditions
- Rate limiting events

## Error Handling

### API Errors

- **Rate Limiting**: Automatic backoff and retry
- **Authentication**: Token refresh and rotation
- **Network Errors**: Exponential retry with jitter
- **Validation Errors**: Logged and reported

### Recovery Mechanisms

- Automatic retry for transient failures
- Dead letter queue for permanent failures
- Circuit breaker for failing endpoints
- Graceful degradation on partial failures

## Security

### Authentication

- API tokens stored in environment variables
- Secrets managed via Docker secrets or Kubernetes secrets
- Token rotation supported

### Authorization

- Service-to-service authentication
- Role-based access for manual triggers
- Audit logging for all operations

### Data Privacy

- Sensitive data filtered before storage
- PII handling compliance
- Configurable data retention policies

## Performance

### Optimization Strategies

- Parallel collection for multiple repositories
- Batch API requests where supported
- Connection pooling for HTTP clients
- Efficient pagination handling

### Resource Requirements

**Development**

- CPU: 0.5 cores
- Memory: 512 MB
- Storage: Minimal (logs only)

**Production**

- CPU: 2-4 cores
- Memory: 2-4 GB
- Storage: 10 GB (logs and cache)

## Troubleshooting

### Common Issues

**Collection Not Starting**

- Check Kafka connectivity
- Verify Redis connection
- Validate API tokens
- Review service logs

**Rate Limit Exceeded**

- Increase rate limit thresholds
- Reduce collection frequency
- Add additional API tokens
- Enable request throttling

**Missing Data**

- Verify repository permissions
- Check collection status
- Review Kafka messages
- Validate data filters

### Debug Mode

Enable debug logging:
```bash
LOG_LEVEL=DEBUG docker-compose up git-collector
```

## Future Enhancements

- Support for additional Git platforms (Gitea, Gerrit)
- Webhooks for real-time collection
- Advanced filtering and sampling
- Multi-region deployment support
- Enhanced caching strategies
- GraphQL API support
