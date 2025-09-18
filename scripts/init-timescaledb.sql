-- TimescaleDB initialization script

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS metrics;
CREATE SCHEMA IF NOT EXISTS events;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Create main metrics table
CREATE TABLE IF NOT EXISTS metrics.engineering_metrics (
    time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    organization_id UUID NOT NULL,
    team_id UUID,
    repository_id UUID,
    developer_id UUID,
    metric_type VARCHAR(50) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DOUBLE PRECISION NOT NULL,
    metadata JSONB,
    tags JSONB
);

-- Convert to hypertable
SELECT create_hypertable('metrics.engineering_metrics', 'time', if_not_exists => TRUE);

-- Create events table
CREATE TABLE IF NOT EXISTS events.raw_events (
    time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_id UUID NOT NULL DEFAULT gen_random_uuid(),
    source VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Convert to hypertable
SELECT create_hypertable('events.raw_events', 'time', if_not_exists => TRUE);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_metrics_org_team ON metrics.engineering_metrics (organization_id, team_id, time DESC);
CREATE INDEX IF NOT EXISTS idx_metrics_type ON metrics.engineering_metrics (metric_type, metric_name, time DESC);
CREATE INDEX IF NOT EXISTS idx_events_source ON events.raw_events (source, event_type, time DESC);
CREATE INDEX IF NOT EXISTS idx_events_processed ON events.raw_events (processed, time DESC);

-- Create retention policies
SELECT add_retention_policy('metrics.engineering_metrics', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('events.raw_events', INTERVAL '6 months', if_not_exists => TRUE);

-- Create continuous aggregates for common queries
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.daily_metrics
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 day', time) AS day,
    organization_id,
    team_id,
    metric_type,
    metric_name,
    AVG(metric_value) AS avg_value,
    MAX(metric_value) AS max_value,
    MIN(metric_value) AS min_value,
    COUNT(*) AS count
FROM metrics.engineering_metrics
GROUP BY day, organization_id, team_id, metric_type, metric_name;

-- Add refresh policy
SELECT add_continuous_aggregate_policy('analytics.daily_metrics',
    start_offset => INTERVAL '1 month',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists => TRUE
);