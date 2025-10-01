# Database Schema

## Overview

The SEI Platform uses two primary databases:

- **PostgreSQL**: Relational data (organizations, teams, developers, repositories)
- **TimescaleDB**: Time-series data (commits, pull requests, deployments)

## PostgreSQL Schema

### Organizations Table

```sql
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_created_at ON organizations(created_at);
```

### Teams Table

```sql
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(organization_id, slug)
);

CREATE INDEX idx_teams_organization_id ON teams(organization_id);
CREATE INDEX idx_teams_slug ON teams(organization_id, slug);
```

### Developers Table

```sql
CREATE TABLE developers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    github_username VARCHAR(255),
    gitlab_username VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_developers_email ON developers(email);
CREATE INDEX idx_developers_github_username ON developers(github_username);
CREATE INDEX idx_developers_gitlab_username ON developers(gitlab_username);
```

### Team Members Table

```sql
CREATE TABLE team_members (
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    developer_id UUID NOT NULL REFERENCES developers(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (team_id, developer_id)
);

CREATE INDEX idx_team_members_team_id ON team_members(team_id);
CREATE INDEX idx_team_members_developer_id ON team_members(developer_id);
```

### Repositories Table

```sql
CREATE TABLE repositories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    default_branch VARCHAR(255) NOT NULL DEFAULT 'main',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(provider, provider_id)
);

CREATE INDEX idx_repositories_organization_id ON repositories(organization_id);
CREATE INDEX idx_repositories_provider ON repositories(provider, provider_id);
CREATE INDEX idx_repositories_name ON repositories(name);
```

## TimescaleDB Schema

### Commits Hypertable

```sql
CREATE TABLE commits (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    commit_sha VARCHAR(40) NOT NULL,
    author_id UUID NOT NULL REFERENCES developers(id),
    lines_added INTEGER NOT NULL DEFAULT 0,
    lines_deleted INTEGER NOT NULL DEFAULT 0,
    files_changed INTEGER NOT NULL DEFAULT 0,
    message TEXT,
    UNIQUE(repository_id, commit_sha)
);

-- Convert to hypertable
SELECT create_hypertable('commits', 'time');

-- Create indexes
CREATE INDEX idx_commits_repository_id ON commits(repository_id, time DESC);
CREATE INDEX idx_commits_author_id ON commits(author_id, time DESC);
CREATE INDEX idx_commits_sha ON commits(commit_sha);
```

### Pull Requests Hypertable

```sql
CREATE TABLE pull_requests (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    pr_number INTEGER NOT NULL,
    author_id UUID NOT NULL REFERENCES developers(id),
    state VARCHAR(20) NOT NULL,
    merged_at TIMESTAMPTZ,
    lines_added INTEGER NOT NULL DEFAULT 0,
    lines_deleted INTEGER NOT NULL DEFAULT 0,
    review_comments INTEGER NOT NULL DEFAULT 0,
    UNIQUE(repository_id, pr_number)
);

-- Convert to hypertable
SELECT create_hypertable('pull_requests', 'time');

-- Create indexes
CREATE INDEX idx_pull_requests_repository_id ON pull_requests(repository_id, time DESC);
CREATE INDEX idx_pull_requests_author_id ON pull_requests(author_id, time DESC);
CREATE INDEX idx_pull_requests_state ON pull_requests(state);
```

### Deployments Hypertable

```sql
CREATE TABLE deployments (
    time TIMESTAMPTZ NOT NULL,
    repository_id UUID NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    environment VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    duration_seconds INTEGER,
    deployed_by UUID REFERENCES developers(id)
);

-- Convert to hypertable
SELECT create_hypertable('deployments', 'time');

-- Create indexes
CREATE INDEX idx_deployments_repository_id ON deployments(repository_id, time DESC);
CREATE INDEX idx_deployments_environment ON deployments(environment, time DESC);
CREATE INDEX idx_deployments_status ON deployments(status);
```

## Continuous Aggregates

### Daily Commit Statistics

```sql
CREATE MATERIALIZED VIEW daily_commit_stats
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS day,
    repository_id,
    COUNT(*) AS commit_count,
    SUM(lines_added) AS total_lines_added,
    SUM(lines_deleted) AS total_lines_deleted,
    SUM(files_changed) AS total_files_changed,
    COUNT(DISTINCT author_id) AS unique_authors
FROM commits
GROUP BY day, repository_id;

-- Refresh policy
SELECT add_continuous_aggregate_policy('daily_commit_stats',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);
```

### Weekly DORA Metrics

```sql
CREATE MATERIALIZED VIEW weekly_dora_metrics
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 week', time) AS week,
    repository_id,
    COUNT(*) AS deployment_count,
    AVG(duration_seconds) AS avg_duration_seconds,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS success_count
FROM deployments
GROUP BY week, repository_id;

-- Refresh policy
SELECT add_continuous_aggregate_policy('weekly_dora_metrics',
    start_offset => INTERVAL '2 weeks',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);
```

### Monthly Developer Activity

```sql
CREATE MATERIALIZED VIEW monthly_developer_activity
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 month', time) AS month,
    author_id,
    repository_id,
    COUNT(*) AS commit_count,
    SUM(lines_added) AS total_lines_added,
    SUM(lines_deleted) AS total_lines_deleted
FROM commits
GROUP BY month, author_id, repository_id;

-- Refresh policy
SELECT add_continuous_aggregate_policy('monthly_developer_activity',
    start_offset => INTERVAL '3 months',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);
```

## Data Retention Policies

### Compress Old Data

```sql
-- Compress commits older than 90 days
SELECT add_compression_policy('commits', INTERVAL '90 days');

-- Compress pull requests older than 90 days
SELECT add_compression_policy('pull_requests', INTERVAL '90 days');

-- Compress deployments older than 90 days
SELECT add_compression_policy('deployments', INTERVAL '90 days');
```

### Drop Old Raw Data

```sql
-- Drop raw commits older than 2 years
SELECT add_retention_policy('commits', INTERVAL '2 years');

-- Drop raw pull requests older than 2 years
SELECT add_retention_policy('pull_requests', INTERVAL '2 years');

-- Drop raw deployments older than 2 years
SELECT add_retention_policy('deployments', INTERVAL '2 years');
```

## Migrations

### Alembic Configuration

**alembic.ini**:

```ini
[alembic]
script_location = alembic
sqlalchemy.url = postgresql://user:pass@localhost/sei_platform

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

### Example Migration

**alembic/versions/001_initial_schema.py**:

```python
"""Initial schema

Revision ID: 001
Create Date: 2024-01-01 00:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

# revision identifiers
revision = '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Create organizations table
    op.create_table(
        'organizations',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('slug', sa.String(255), nullable=False, unique=True),
        sa.Column('created_at', sa.TIMESTAMP(timezone=True), nullable=False),
        sa.Column('updated_at', sa.TIMESTAMP(timezone=True), nullable=False)
    )

    # Create indexes
    op.create_index('idx_organizations_slug', 'organizations', ['slug'])
    op.create_index('idx_organizations_created_at', 'organizations', ['created_at'])


def downgrade():
    op.drop_table('organizations')
```

## Performance Optimization

### Connection Pooling

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/sei_platform',
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=40,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### Query Optimization Tips

1. **Use appropriate indexes** for frequently queried columns
2. **Partition hypertables** by time for better performance
3. **Use continuous aggregates** instead of real-time aggregation
4. **Enable compression** for old data to save space
5. **Use connection pooling** to reduce connection overhead

### Monitoring Queries

```sql
-- Check hypertable statistics
SELECT * FROM timescaledb_information.hypertables;

-- Check chunk information
SELECT * FROM timescaledb_information.chunks
WHERE hypertable_name = 'commits'
ORDER BY range_start DESC;

-- Check compression stats
SELECT * FROM timescaledb_information.compression_settings;

-- Check continuous aggregate stats
SELECT * FROM timescaledb_information.continuous_aggregates;
```

## Backup and Restore

### PostgreSQL Backup

```bash
# Full backup
pg_dump -h localhost -U postgres -d sei_platform -F c -f backup.dump

# Restore
pg_restore -h localhost -U postgres -d sei_platform backup.dump
```

### TimescaleDB Backup

```bash
# Backup with TimescaleDB extension
pg_dump -h localhost -U postgres -d sei_platform \
    --format=custom \
    --file=timescale_backup.dump

# Restore
pg_restore -h localhost -U postgres -d sei_platform \
    --clean \
    timescale_backup.dump
```

## Next Steps

- [Data Models](data-models.md) - Entity relationships and models
- [API Design](api-design.md) - API endpoints and data access
- [Security](security.md) - Database security and access control