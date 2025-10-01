# Jira Collector Service

The Jira Collector Service is responsible for collecting data from Jira and other project management platforms. It retrieves issue data, sprint information, workflow states, and team metrics.

## Overview

The service is built using FastAPI and runs as a microservice in the SEI platform architecture. It collects data from Jira projects and publishes it to Apache Kafka for downstream processing.

### Key Responsibilities

- Collect issue and ticket data
- Retrieve sprint and board information
- Track workflow states and transitions
- Gather team and project metrics
- Monitor project health and velocity
- Extract custom field data

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
- `/api/v1/collect/status/{project_key}` - Get collection status

**Configuration** (`config.py`)

- Environment-based configuration
- Kafka broker settings
- Redis connection settings
- Jira API credentials management

### Data Flow

```
Jira APIs → Jira Collector → Kafka Topics → Data Processor → TimescaleDB
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
| `JIRA_URL` | Jira instance URL | Yes | - |
| `JIRA_USERNAME` | Jira username or email | Yes | - |
| `JIRA_API_TOKEN` | Jira API token | Yes | - |
| `JIRA_PROJECT_KEYS` | Comma-separated project keys | Yes | - |

### Docker Configuration

The service is configured in `docker-compose.yml`:

```yaml
jira-collector:
  build:
    context: ./src/collectors/jira
    dockerfile: Dockerfile
  container_name: sei-jira-collector
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

Manually trigger data collection for a Jira project.

**Request Body**

```json
{
  "project_key": "PROJ",
  "full_sync": false
}
```

**Response**

```json
{
  "status": "queued",
  "message": "Collection job has been queued for processing",
  "project_key": "PROJ"
}
```

**Parameters**

- `project_key` (string, required): Jira project key
- `full_sync` (boolean, optional): Whether to perform full sync or incremental. Default: `false`

### GET /api/v1/collect/status/{project_key}

Get the current collection status for a Jira project.

**Path Parameters**

- `project_key` (string, required): Jira project key

**Response**

```json
{
  "project_key": "PROJ",
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
    cd src/collectors/jira
    ```

2. Install dependencies:

    ```bash
    pip install -r requirements.txt
    ```

3. Run the service:

    ```bash
    python main.py
    ```

The service will start on `http://localhost:8001`.

### Running with Docker

```bash
docker-compose up jira-collector
```

### Running Tests

```bash
pytest tests/collectors/jira/
```

## Data Collection

### Collected Data Types

**Issues and Tickets**

- Issue metadata (key, summary, description)
- Status and workflow information
- Priority and severity
- Assignee and reporter
- Created and updated timestamps
- Resolution and close dates
- Labels and components

**Sprints and Boards**

- Sprint metadata and goals
- Sprint start and end dates
- Sprint velocity and capacity
- Board configuration
- Swimlanes and columns

**Workflows**

- Workflow states and transitions
- State duration metrics
- Transition history
- Custom workflow rules

**Custom Fields**

- Story points
- Epic links
- Custom date fields
- Custom text and number fields

**Comments and History**

- Issue comments
- Change history
- Attachment metadata
- Work logs

### Collection Strategies

**Full Sync**

- Collects all historical data from the project
- Used for initial setup or data refresh
- Includes all issues, sprints, and workflows
- Resource intensive, scheduled during off-peak hours

**Incremental Sync**

- Collects only updated issues since last sync
- Default collection mode
- Uses JQL queries with updated date filters
- Efficient and quick

**Webhook-Triggered**

- Real-time updates from Jira webhooks
- Triggered by issue events
- Low latency, immediate processing
- Requires webhook configuration in Jira

## Kafka Integration

### Published Topics

**`jira.issues`**

- Issue creation, updates, and deletions
- Status transitions
- Assignment changes

**`jira.sprints`**

- Sprint creation and updates
- Sprint start and completion
- Velocity metrics

**`jira.workflows`**

- Workflow state changes
- Transition events
- Cycle time data

**`jira.comments`**

- Comment creation and updates
- Collaboration metrics
- Communication patterns

### Message Format

All messages published to Kafka follow this structure:

```json
{
  "event_type": "issue_updated",
  "timestamp": "2025-10-01T12:00:00Z",
  "source": "jira",
  "project_key": "PROJ",
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
- **Field Mapping**: Cache custom field configurations

### Cache Keys

- `jira:ratelimit:{project_key}` - Rate limiting counters
- `jira:status:{project_key}` - Collection status
- `jira:last_sync:{project_key}` - Last sync timestamp
- `jira:fields:{project_key}` - Custom field mappings

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

- `jira_collector_requests_total` - Total API requests made
- `jira_collector_requests_failed` - Failed API requests
- `jira_collector_collections_total` - Total collection jobs
- `jira_collector_issues_collected` - Issues collected per job
- `jira_collector_processing_duration_seconds` - Processing time

### Logging

Structured JSON logging is configured for:

- Collection job lifecycle
- API request/response
- Error conditions
- Rate limiting events
- Data transformation operations

## Error Handling

### API Errors

- **Rate Limiting**: Automatic backoff and retry with exponential delay
- **Authentication**: Token validation and error reporting
- **Network Errors**: Retry with exponential backoff
- **Validation Errors**: Detailed error logging

### Recovery Mechanisms

- Automatic retry for transient failures
- Dead letter queue for permanent failures
- Checkpoint mechanism for partial collection
- Graceful degradation on API limitations

## Security

### Authentication

- API tokens stored in environment variables
- Secrets managed via Docker secrets or Kubernetes secrets
- Support for OAuth 2.0 authentication
- Token rotation capabilities

### Authorization

- Project-level access control
- Service account with minimal permissions
- Audit logging for all operations
- Encrypted communication with Jira

### Data Privacy

- Sensitive data filtering
- PII handling compliance
- Configurable field exclusions
- Data retention policies

## Performance

### Optimization Strategies

- Parallel collection for multiple projects
- Batch API requests using bulk endpoints
- Connection pooling for HTTP clients
- Efficient JQL query construction
- Field filtering to reduce payload size

### Resource Requirements

**Development**

- CPU: 0.5 cores
- Memory: 512 MB
- Storage: Minimal (logs only)

**Production**

- CPU: 2-4 cores
- Memory: 2-4 GB
- Storage: 10 GB (logs and cache)

## JQL Query Examples

### Incremental Sync

```sql
updated >= -1h ORDER BY updated ASC
```

### Full Sync

```sql
project = PROJ ORDER BY created ASC
```

### Sprint Issues

```sql
sprint = 123 AND project = PROJ
```

### Recently Closed Issues

```sql
status = Done AND resolved >= -7d
```

## Troubleshooting

### Common Issues

**Collection Not Starting**

- Check Kafka connectivity
- Verify Redis connection
- Validate Jira credentials
- Review service logs
- Confirm project key exists

**Rate Limit Exceeded**

- Increase rate limit thresholds in Jira
- Reduce collection frequency
- Implement request throttling
- Use multiple service accounts

**Missing Issues**

- Verify project permissions
- Check JQL query syntax
- Review field mappings
- Validate custom fields configuration

**Authentication Failures**

- Verify API token validity
- Check username/email format
- Confirm Jira instance URL
- Review security settings in Jira

### Debug Mode

Enable debug logging:

```bash
LOG_LEVEL=DEBUG docker-compose up jira-collector
```

### Verify Jira Connection

Test Jira API connectivity:

```bash
curl -u username:token https://your-domain.atlassian.net/rest/api/3/myself
```

## Jira API Versions

The service supports multiple Jira API versions:

- Jira Cloud REST API v3
- Jira Server/Data Center REST API v2
- Agile REST API (for sprints and boards)

## Custom Field Mapping

Custom fields are mapped using field IDs:

```json
{
  "customfield_10016": "story_points",
  "customfield_10018": "epic_link",
  "customfield_10019": "sprint"
}
```

Field mappings are cached in Redis and refreshed periodically.

## Future Enhancements

- Support for Jira Service Desk data
- Advanced analytics on issue patterns
- Predictive issue resolution time
- Integration with Confluence
- Support for Azure DevOps Boards
- Real-time webhook processing
- Enhanced custom field handling
- Multi-project bulk operations
