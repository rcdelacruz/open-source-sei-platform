# System Design

## Service Architecture

### API Service

**Technology**: FastAPI, Python 3.11+

**Responsibilities**:

- Expose REST API endpoints for all platform functionality
- Handle authentication and authorization
- Validate and sanitize user input
- Orchestrate data retrieval from databases
- Cache frequently accessed data in Redis
- Rate limiting and request throttling

**Port**: 8080

**Key Components**:

```
src/apis/
├── main.py              # FastAPI application entry point
├── config.py            # Configuration and settings
├── database.py          # Database connections
├── models/              # SQLAlchemy ORM models
├── routes/              # API route handlers
│   ├── organizations.py
│   ├── teams.py
│   ├── repositories.py
│   ├── developers.py
│   └── analytics.py
├── schemas/             # Pydantic request/response schemas
├── services/            # Business logic layer
└── utils/               # Helper functions
```

**API Endpoints**:

- `/health` - Health check endpoint
- `/api/v1/organizations` - Organization CRUD
- `/api/v1/teams` - Team management
- `/api/v1/repositories` - Repository management
- `/api/v1/developers` - Developer profiles
- `/api/v1/analytics` - DORA metrics and analytics

### Git Collector Service

**Technology**: FastAPI, Python 3.11+

**Responsibilities**:

- Poll GitHub, GitLab, Bitbucket APIs for repository data
- Collect commits, pull requests, branches, tags
- Track code review activity
- Calculate code churn metrics
- Publish events to Kafka for processing

**Port**: 8000

**Data Sources**:

- **GitHub**: REST API v3, GraphQL API v4
- **GitLab**: REST API v4
- **Bitbucket**: REST API v2

**Collection Schedule**:

- **Commits**: Every hour
- **Pull Requests**: Every 30 minutes
- **Branches/Tags**: Every 4 hours
- **Contributors**: Daily

**Event Topics**:

- `git.commits` - New commits
- `git.pull_requests` - PR events
- `git.code_reviews` - Code review activity

### Jira Collector Service

**Technology**: FastAPI, Python 3.11+

**Responsibilities**:

- Integrate with Jira, Linear, Asana APIs
- Collect issues, sprints, story points
- Track issue lifecycle and transitions
- Calculate cycle time and lead time
- Publish events to Kafka

**Port**: 8001

**Data Sources**:

- **Jira**: REST API v3
- **Linear**: GraphQL API
- **Asana**: REST API v1

**Collection Schedule**:

- **Issues**: Every 15 minutes
- **Sprints**: Hourly
- **Boards**: Every 4 hours

**Event Topics**:

- `jira.issues` - Issue events
- `jira.sprints` - Sprint data
- `jira.transitions` - Issue state changes

### Data Processor Service

**Technology**: FastAPI, Python 3.11+, Kafka Consumer

**Responsibilities**:

- Consume events from Kafka topics
- Transform raw data into normalized format
- Calculate DORA metrics
- Aggregate data for reporting
- Store processed data in databases

**Port**: 8002

**Processing Pipeline**:

1. **Event Consumption**: Read from Kafka topics
2. **Validation**: Validate event schema
3. **Transformation**: Normalize data structure
4. **Enrichment**: Add calculated fields
5. **Storage**: Write to TimescaleDB/PostgreSQL
6. **Caching**: Update Redis cache

**Metric Calculations**:

- **Deployment Frequency**: Count deployments per day/week
- **Lead Time for Changes**: Time from commit to production
- **Change Failure Rate**: Percentage of deployments causing failures
- **Time to Restore Service**: Mean time to recovery (MTTR)

## Data Storage Design

### TimescaleDB Schema

**Purpose**: Time-series data for metrics and events

**Hypertables**:

```sql
-- Commit events
CREATE TABLE commits (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL,
    commit_sha VARCHAR(40) NOT NULL,
    author_id UUID NOT NULL,
    lines_added INT,
    lines_deleted INT,
    files_changed INT,
    message TEXT
);

SELECT create_hypertable('commits', 'time');

-- Pull request events
CREATE TABLE pull_requests (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL,
    pr_number INT NOT NULL,
    author_id UUID NOT NULL,
    state VARCHAR(20),
    merged_at TIMESTAMPTZ,
    lines_added INT,
    lines_deleted INT,
    review_comments INT
);

SELECT create_hypertable('pull_requests', 'time');

-- Deployment events
CREATE TABLE deployments (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL,
    environment VARCHAR(50),
    status VARCHAR(20),
    duration_seconds INT,
    deployed_by UUID
);

SELECT create_hypertable('deployments', 'time');
```

**Continuous Aggregates**:

```sql
-- Daily commit stats
CREATE MATERIALIZED VIEW daily_commit_stats
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS day,
    repository_id,
    COUNT(*) as commit_count,
    SUM(lines_added) as total_lines_added,
    SUM(lines_deleted) as total_lines_deleted
FROM commits
GROUP BY day, repository_id;

-- Weekly DORA metrics
CREATE MATERIALIZED VIEW weekly_dora_metrics
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 week', time) AS week,
    repository_id,
    COUNT(*) as deployment_count,
    AVG(duration_seconds) as avg_duration,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_count
FROM deployments
GROUP BY week, repository_id;
```

### PostgreSQL Schema

**Purpose**: Relational data for entities and relationships

**Core Tables**:

```sql
-- Organizations
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Teams
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, slug)
);

-- Repositories
CREATE TABLE repositories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    url TEXT,
    default_branch VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider, provider_id)
);

-- Developers
CREATE TABLE developers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    github_username VARCHAR(255),
    gitlab_username VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Redis Cache Structure

**Key Patterns**:

```
org:{org_id} -> JSON organization
team:{team_id} -> JSON team
metrics:dora:{repo_id}:{period} -> JSON metrics
ratelimit:{ip}:{endpoint} -> Request count
```

## Event Schema Design

### Kafka Topics

```yaml
git.commits:
  partitions: 10
  replication: 3
  retention.ms: 604800000

git.pull_requests:
  partitions: 10
  replication: 3
  retention.ms: 604800000
```

## Communication Patterns

### Synchronous Communication

```
Client → API Service → Database
```

### Asynchronous Communication

```
Collector → Kafka → Data Processor → Database
```

## Performance Considerations

- Database connection pooling
- Redis caching with TTL
- Kafka batch processing
- Query optimization with indexes
- Horizontal scaling capability