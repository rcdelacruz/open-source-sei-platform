# Data Processor Service

The Data Processor Service is responsible for consuming data from Kafka topics, transforming and enriching it, and storing it in TimescaleDB for analytics and reporting. It acts as the central data processing engine in the SEI platform.

## Overview

The service is built using FastAPI and runs as a microservice in the SEI platform architecture. It processes streaming data from collector services and prepares it for analysis.

### Key Responsibilities

- Consume messages from Kafka topics
- Transform and normalize data
- Enrich data with additional context
- Calculate derived metrics and aggregations
- Store processed data in TimescaleDB
- Maintain data quality and consistency

## Architecture

### Service Components

**Main Application** (`main.py`)

- FastAPI application with CORS middleware
- Structured logging using structlog
- Health check endpoints
- Kafka consumer initialization

**Routes**

- `/health` - Service health check

**Configuration** (`config.py`)

- Environment-based configuration
- Kafka consumer settings
- TimescaleDB connection settings
- Redis cache configuration

### Data Flow

```
Kafka Topics → Data Processor → TimescaleDB
                    ↓              ↓
                Redis Cache    PostgreSQL
```

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `KAFKA_BROKERS` | Kafka broker endpoints | Yes | `kafka:9092` |
| `TIMESCALE_URL` | TimescaleDB connection URL | Yes | - |
| `REDIS_URL` | Redis connection URL | Yes | `redis://redis:6379` |
| `LOG_LEVEL` | Logging level | No | `INFO` |
| `CONSUMER_GROUP_ID` | Kafka consumer group ID | No | `data-processor-group` |
| `BATCH_SIZE` | Processing batch size | No | `100` |
| `BATCH_TIMEOUT_MS` | Batch timeout in milliseconds | No | `5000` |

### Docker Configuration

The service is configured in `docker-compose.yml`:

```yaml
data-processor:
  build:
    context: ./src/processors
    dockerfile: Dockerfile
  container_name: sei-data-processor
  depends_on:
    - kafka
    - timescaledb
    - redis
  environment:
    KAFKA_BROKERS: kafka:9092
    TIMESCALE_URL: postgresql://sei_user:sei_password@timescaledb:5432/sei_platform
    REDIS_URL: redis://redis:6379
    LOG_LEVEL: INFO
```

## Development

### Local Setup

1. Navigate to the service directory:

    ```bash
    cd src/processors
    ```

2. Install dependencies:

    ```bash
    pip install -r requirements.txt
    ```

3. Run the service:

    ```bash
    python main.py
    ```

The service will start on `http://localhost:8002`.

### Running with Docker

```bash
docker-compose up data-processor
```

### Running Tests

```bash
pytest tests/processors/
```

## Data Processing

### Kafka Topics Consumed

**`git.commits`**

- Processes commit data from Git repositories
- Extracts author information and file changes
- Calculates code metrics (lines added/deleted)
- Links commits to pull requests

**`git.pull_requests`**

- Processes pull request data
- Calculates review time and cycle time
- Tracks approval workflows
- Identifies merge conflicts

**`git.repositories`**

- Updates repository metadata
- Tracks repository health metrics
- Monitors activity trends

**`jira.issues`**

- Processes issue data from Jira
- Calculates issue lifecycle metrics
- Tracks workflow transitions
- Links issues to commits

**`jira.sprints`**

- Processes sprint data
- Calculates sprint velocity
- Tracks completion rates
- Analyzes sprint patterns

### Processing Pipeline

1. **Message Consumption**

    - Read messages from Kafka topics
    - Deserialize JSON payloads
    - Validate message schemas

2. **Data Transformation**

    - Normalize data formats
    - Convert timestamps to UTC
    - Extract relevant fields
    - Handle missing values

3. **Data Enrichment**

    - Add contextual information
    - Link related entities
    - Calculate derived fields
    - Apply business rules

4. **Metric Calculation**

    - Compute DORA metrics
    - Calculate cycle times
    - Aggregate team metrics
    - Generate time-series data

5. **Data Storage**

    - Write to TimescaleDB hypertables
    - Update materialized views
    - Cache frequently accessed data
    - Maintain data consistency

## Data Transformation

### Git Commit Processing

Input from Kafka:

```json
{
  "event_type": "commit_created",
  "timestamp": "2025-10-01T12:00:00Z",
  "source": "github",
  "repository_id": "repo-123",
  "data": {
    "sha": "abc123",
    "author": "user@example.com",
    "message": "Fix bug in authentication",
    "files_changed": 3,
    "additions": 45,
    "deletions": 12
  }
}
```

Transformed and stored:

```sql
INSERT INTO commits (
  sha, repository_id, author_email, message,
  files_changed, additions, deletions, committed_at
) VALUES (
  'abc123', 'repo-123', 'user@example.com',
  'Fix bug in authentication', 3, 45, 12,
  '2025-10-01T12:00:00Z'
);
```

### Jira Issue Processing

Input from Kafka:

```json
{
  "event_type": "issue_updated",
  "timestamp": "2025-10-01T12:00:00Z",
  "source": "jira",
  "project_key": "PROJ",
  "data": {
    "key": "PROJ-123",
    "status": "Done",
    "assignee": "john@example.com",
    "story_points": 5,
    "created": "2025-09-25T10:00:00Z",
    "resolved": "2025-10-01T12:00:00Z"
  }
}
```

Transformed and stored with calculated metrics:

```sql
INSERT INTO issues (
  issue_key, project_key, status, assignee,
  story_points, created_at, resolved_at, cycle_time_days
) VALUES (
  'PROJ-123', 'PROJ', 'Done', 'john@example.com',
  5, '2025-09-25T10:00:00Z', '2025-10-01T12:00:00Z', 6.08
);
```

## Metric Calculations

### DORA Metrics

**Deployment Frequency**

- Count of deployments per time period
- Aggregated by repository and team
- Calculated daily, weekly, monthly

**Lead Time for Changes**

- Time from commit to production deployment
- Tracked per commit and aggregated
- Percentile calculations (p50, p90, p95)

**Change Failure Rate**

- Percentage of deployments causing failures
- Tracked per repository
- Rolling window calculations

**Time to Restore Service**

- Time from incident detection to resolution
- Linked to issue tracking systems
- Mean and median calculations

### Cycle Time Metrics

**Code Review Time**

- Time from PR creation to approval
- Excludes author time
- Tracked by team and repository

**Issue Cycle Time**

- Time from issue creation to resolution
- Broken down by workflow stages
- Analyzed by issue type

**Sprint Velocity**

- Story points completed per sprint
- Trend analysis over time
- Team capacity planning

## TimescaleDB Integration

### Hypertables

**`commits`**

- Partitioned by `committed_at`
- Retention: 2 years
- Compression after 90 days

**`pull_requests`**

- Partitioned by `created_at`
- Retention: 2 years
- Compression after 90 days

**`issues`**

- Partitioned by `created_at`
- Retention: 5 years
- Compression after 180 days

**`metrics_daily`**

- Partitioned by `metric_date`
- Pre-aggregated daily metrics
- Continuous aggregates

### Continuous Aggregates

**`commits_daily_stats`**

```sql
CREATE MATERIALIZED VIEW commits_daily_stats
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', committed_at) AS day,
  repository_id,
  COUNT(*) AS commit_count,
  SUM(additions) AS total_additions,
  SUM(deletions) AS total_deletions
FROM commits
GROUP BY day, repository_id;
```

**`pull_requests_weekly_metrics`**

```sql
CREATE MATERIALIZED VIEW pull_requests_weekly_metrics
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 week', created_at) AS week,
  repository_id,
  COUNT(*) AS pr_count,
  AVG(review_time_hours) AS avg_review_time,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY review_time_hours) AS median_review_time
FROM pull_requests
GROUP BY week, repository_id;
```

## Redis Caching

The service uses Redis for:

- **Deduplication**: Track processed message IDs
- **State Management**: Store processing checkpoints
- **Lookup Cache**: Cache frequently accessed reference data
- **Rate Limiting**: Control processing rates

### Cache Keys

- `processor:dedupe:{message_id}` - Deduplication tracking
- `processor:checkpoint:{topic}:{partition}` - Kafka offset checkpoints
- `processor:cache:repo:{repository_id}` - Repository metadata
- `processor:cache:user:{user_id}` - User information

## Monitoring

### Health Checks

The service exposes a `/health` endpoint that returns:

```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2025-10-01T12:00:00Z",
  "kafka_connected": true,
  "timescale_connected": true,
  "redis_connected": true
}
```

### Metrics

Metrics are exposed for Prometheus scraping at `/metrics` (when enabled):

- `processor_messages_consumed_total` - Total messages consumed
- `processor_messages_processed_total` - Successfully processed messages
- `processor_messages_failed_total` - Failed message processing
- `processor_processing_duration_seconds` - Message processing time
- `processor_batch_size` - Current batch size
- `processor_lag` - Consumer lag per topic

### Logging

Structured JSON logging is configured for:

- Message consumption events
- Processing pipeline stages
- Database operations
- Error conditions
- Performance metrics

## Error Handling

### Processing Errors

**Schema Validation Failures**

- Log validation errors
- Send to dead letter queue
- Alert on high failure rates

**Database Errors**

- Retry with exponential backoff
- Use transaction rollback
- Maintain data consistency

**Network Errors**

- Automatic reconnection
- Circuit breaker pattern
- Graceful degradation

### Recovery Mechanisms

- Kafka offset management for replay
- Dead letter queue for failed messages
- Checkpoint mechanism for state recovery
- Transaction-based processing

## Performance

### Optimization Strategies

- Batch processing for efficiency
- Connection pooling for databases
- Parallel processing of independent messages
- Async I/O for network operations
- Pre-compiled SQL statements
- Bulk insert operations

### Batch Processing

Messages are processed in batches for efficiency:

```python
batch = []
for message in consumer:
    batch.append(message)
    if len(batch) >= BATCH_SIZE or timeout_reached():
        process_batch(batch)
        batch = []
```

### Resource Requirements

**Development**

- CPU: 1 core
- Memory: 1 GB
- Storage: Minimal (logs only)

**Production**

- CPU: 4-8 cores
- Memory: 8-16 GB
- Storage: 20 GB (logs and local cache)

## Kafka Consumer Configuration

### Consumer Settings

```python
consumer_config = {
    'bootstrap.servers': 'kafka:9092',
    'group.id': 'data-processor-group',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,
    'max.poll.records': 100,
    'session.timeout.ms': 30000,
    'heartbeat.interval.ms': 10000
}
```

### Topic Subscription

```python
topics = [
    'git.commits',
    'git.pull_requests',
    'git.repositories',
    'jira.issues',
    'jira.sprints'
]
consumer.subscribe(topics)
```

## Data Quality

### Validation Rules

- Required fields presence check
- Data type validation
- Range and format validation
- Referential integrity checks
- Duplicate detection

### Data Cleansing

- Timestamp normalization
- Email address standardization
- Text encoding fixes
- Null value handling
- Outlier detection and handling

## Troubleshooting

### Common Issues

**High Consumer Lag**

- Increase batch size
- Add more processor instances
- Optimize database operations
- Review processing logic

**Database Connection Errors**

- Check TimescaleDB connectivity
- Verify connection pool settings
- Review database logs
- Monitor connection count

**Memory Issues**

- Reduce batch size
- Optimize data structures
- Enable compression
- Monitor memory usage

**Slow Processing**

- Profile processing pipeline
- Optimize SQL queries
- Review network latency
- Check resource constraints

### Debug Mode

Enable debug logging:

```bash
LOG_LEVEL=DEBUG docker-compose up data-processor
```

### Monitor Consumer Lag

Check Kafka consumer lag:

```bash
docker exec sei-kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group data-processor-group --describe
```

## Future Enhancements

- Real-time stream processing with Apache Flink
- Machine learning model integration
- Advanced data validation rules
- Multi-region data replication
- Enhanced error recovery mechanisms
- GraphQL subscriptions for real-time updates
- Time-series forecasting
- Anomaly detection algorithms
