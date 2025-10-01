# Docker Compose Deployment

Docker Compose provides a simple way to run the SEI Platform for development and small-scale deployments. This guide covers setup, configuration, and troubleshooting.

## Prerequisites

Before deploying with Docker Compose, ensure you have:

- Docker Engine 20.10 or higher
- Docker Compose v2.0 or higher
- At least 8GB of RAM available
- 20GB of free disk space
- Linux, macOS, or Windows with WSL2

Verify your installation:

```bash
docker --version
docker compose version
```

## Quick Start

The fastest way to get the platform running:

```bash
# Clone the repository
git clone https://github.com/rcdelacruz/open-source-sei-platform.git
cd open-source-sei-platform

# Copy and configure environment variables
cp .env.example .env

# Start all services
make dev

# Or use docker-compose directly
docker-compose up -d
```

The platform will be available at the following endpoints:

- Frontend Dashboard: http://localhost:3002
- API Service: http://localhost:8080
- Metabase: http://localhost:3000
- Grafana: http://localhost:3001
- Airflow: http://localhost:8082
- Kafka UI: http://localhost:8083
- PgAdmin: http://localhost:8084

## Architecture Overview

The Docker Compose setup includes the following service categories:

### Core Services

**TimescaleDB**: Time-series database for metrics storage

- Port: 5432
- Volume: timescale_data
- Initial data loaded from init-timescaledb.sql

**PostgreSQL**: Metadata and configuration storage

- Port: 5433
- Volume: postgres_data
- Initial data loaded from init-postgresql.sql

**Redis**: Caching and session management

- Port: 6379
- Volume: redis_data
- Used for API response caching and rate limiting

### Message Queue

**Zookeeper**: Kafka coordination service

- Port: 2181
- Required for Kafka operation

**Kafka**: Event streaming platform

- Ports: 9092 (internal), 29092 (external)
- Volume: kafka_data
- Used for data collection pipelines

### Analytics

**Metabase**: Business intelligence and visualization

- Port: 3000
- Volume: metabase_data
- Default credentials: admin/admin123

### Monitoring

**Prometheus**: Metrics collection

- Port: 9090
- Configuration: config/prometheus.yml
- Retention: 200 hours

**Grafana**: Metrics visualization

- Port: 3001
- Default credentials: admin/admin123
- Volume: grafana_data

### API Gateway

**Kong**: API gateway and routing

- Ports: 8000 (proxy), 8001 (admin)
- Configuration: config/kong.yml
- Database-less mode for simplicity

### Application Services

**Git Collector**: GitHub/GitLab data collection

- Connects to Kafka and Redis
- Configuration via environment variables

**Jira Collector**: Project management data collection

- Connects to Kafka and Redis
- Requires Jira API credentials

**Data Processor**: Stream processing pipeline

- Processes Kafka messages
- Writes to TimescaleDB

**API Service**: REST/GraphQL API

- Port: 8080
- Connects to all databases
- Serves frontend and external clients

**Frontend Dev**: React development server

- Port: 3002
- Hot reload enabled
- Connects to API service

### Workflow Orchestration

**Airflow Webserver**: DAG management UI

- Port: 8082
- Default credentials: admin/admin123

**Airflow Scheduler**: Task scheduling and execution

- Runs scheduled data collection workflows
- Monitors DAG execution

### Development Tools

**Kafka UI**: Kafka topic and consumer monitoring

- Port: 8083
- Provides insight into message flow

**PgAdmin**: PostgreSQL database management

- Port: 8084
- Default credentials: admin@sei.com/admin123

## Environment Configuration

### Required Environment Variables

Edit the `.env` file with your credentials:

```bash
# Database Configuration
TIMESCALE_URL=postgresql://sei_user:sei_password@timescaledb:5432/sei_platform
POSTGRES_URL=postgresql://sei_user:sei_password@postgresql:5432/sei_metadata
REDIS_URL=redis://redis:6379

# Message Queue
KAFKA_BROKERS=kafka:9092
KAFKA_TOPIC_PREFIX=sei_

# API Keys
GITHUB_TOKEN=your_github_token_here
GITLAB_TOKEN=your_gitlab_token_here
JIRA_API_TOKEN=your_jira_token_here
JIRA_BASE_URL=https://your-domain.atlassian.net
SLACK_BOT_TOKEN=your_slack_token_here

# Authentication
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRATION=3600

# Application Settings
LOG_LEVEL=INFO
DEBUG=true
ENVIRONMENT=development
```

### Obtaining API Keys

**GitHub Token**:

1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Generate new token with `repo`, `read:org`, `read:user` scopes
3. Copy token to `.env` file

**GitLab Token**:

1. Go to GitLab User Settings > Access Tokens
2. Create token with `read_api`, `read_repository` scopes
3. Copy token to `.env` file

**Jira API Token**:

1. Go to Atlassian Account > Security > API tokens
2. Create API token
3. Copy token and base URL to `.env` file

## Service Management

### Starting Services

Start all services in detached mode:

```bash
docker-compose up -d
```

Start specific services:

```bash
docker-compose up -d timescaledb redis kafka
```

Start with logs visible:

```bash
docker-compose up
```

### Stopping Services

Stop all services:

```bash
docker-compose down
```

Stop and remove volumes:

```bash
docker-compose down -v
```

Stop specific services:

```bash
docker-compose stop api-service frontend-dev
```

### Restarting Services

Restart all services:

```bash
docker-compose restart
```

Restart specific service:

```bash
docker-compose restart api-service
```

### Viewing Logs

Follow all logs:

```bash
docker-compose logs -f
```

Follow specific service logs:

```bash
docker-compose logs -f api-service
docker-compose logs -f git-collector jira-collector
```

View last 100 lines:

```bash
docker-compose logs --tail=100 api-service
```

### Service Health Checks

Check service status:

```bash
docker-compose ps
```

View resource usage:

```bash
docker stats
```

Inspect specific service:

```bash
docker-compose exec api-service /bin/bash
```

## Database Operations

### Accessing Databases

Access TimescaleDB:

```bash
docker-compose exec timescaledb psql -U sei_user -d sei_platform
```

Access PostgreSQL:

```bash
docker-compose exec postgresql psql -U sei_user -d sei_metadata
```

Access Redis:

```bash
docker-compose exec redis redis-cli
```

### Running Migrations

Execute database migrations:

```bash
make db-migrate
```

### Seeding Sample Data

Populate with sample data for testing:

```bash
make db-seed
```

### Backup and Restore

Create database backup:

```bash
make db-backup
```

Restore from backup:

```bash
make db-restore
```

## Network Configuration

All services communicate on the `sei-network` bridge network. Service names are used as hostnames for inter-service communication.

Service discovery:

- Services can reference each other by container name
- Example: `api-service` connects to `timescaledb:5432`
- No need for IP addresses

Exposing additional ports:

Edit `docker-compose.yml` to add port mappings:

```yaml
api-service:
  ports:
    - "8080:8080"
    - "8081:8081"  # Add new port
```

## Volume Management

### Data Persistence

The following volumes store persistent data:

- `timescale_data`: TimescaleDB data
- `postgres_data`: PostgreSQL data
- `redis_data`: Redis persistence
- `kafka_data`: Kafka topics and logs
- `metabase_data`: Metabase dashboards
- `prometheus_data`: Metrics history
- `grafana_data`: Grafana dashboards
- `pgadmin_data`: PgAdmin configuration

### Backing Up Volumes

Create volume backups:

```bash
docker run --rm \
  -v sei-platform_timescale_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/timescale-$(date +%Y%m%d).tar.gz /data
```

### Restoring Volumes

Restore from backup:

```bash
docker run --rm \
  -v sei-platform_timescale_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar xzf /backup/timescale-20250101.tar.gz -C /
```

### Cleaning Volumes

Remove unused volumes:

```bash
docker volume prune -f
```

## Troubleshooting

### Common Issues

**Services fail to start**:

Check logs for errors:

```bash
docker-compose logs [service-name]
```

Verify environment variables are set:

```bash
docker-compose config
```

**Port conflicts**:

Check if ports are already in use:

```bash
lsof -i :5432
lsof -i :8080
```

Modify port mappings in `docker-compose.yml` if needed.

**Out of memory**:

Increase Docker memory limit:

- Docker Desktop: Settings > Resources > Memory
- Linux: Edit `/etc/docker/daemon.json`

**Database connection failures**:

Wait for database to be ready:

```bash
docker-compose logs timescaledb | grep "ready to accept connections"
```

Check connection string in `.env` file.

**Kafka connection issues**:

Ensure Zookeeper is running:

```bash
docker-compose ps zookeeper
```

Check Kafka advertised listeners configuration.

### Performance Tuning

**Database Performance**:

Increase shared buffers in TimescaleDB:

```yaml
timescaledb:
  command:
    - postgres
    - -c
    - shared_buffers=2GB
    - -c
    - max_connections=200
```

**Kafka Performance**:

Adjust memory settings:

```yaml
kafka:
  environment:
    KAFKA_HEAP_OPTS: "-Xmx2G -Xms2G"
```

**Redis Performance**:

Enable persistence and memory limits:

```yaml
redis:
  command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru
```

### Debugging

Enable debug logging:

```bash
# Edit .env
LOG_LEVEL=DEBUG
DEBUG=true

# Restart services
docker-compose restart
```

Access service shell:

```bash
docker-compose exec api-service /bin/bash
docker-compose exec git-collector sh
```

View service resource usage:

```bash
docker stats --no-stream
```

## Production Considerations

Docker Compose is suitable for development and small deployments, but for production consider:

- Use production-ready configuration file: `docker-compose.prod.yml`
- Enable SSL/TLS for all exposed services
- Use secrets management instead of `.env` file
- Implement proper backup strategies
- Set up log aggregation
- Enable health checks and restart policies
- Use external managed databases for better reliability
- Implement rate limiting and security policies
- Monitor resource usage and scale appropriately

For production deployments, consider using Kubernetes instead. See the [Kubernetes Deployment](kubernetes.md) guide.

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Production Deployment Guide](production.md)
- [Monitoring Setup](monitoring.md)

## Makefile Commands

The project includes helpful Makefile targets:

```bash
make dev          # Start development environment
make dev-stop     # Stop development environment
make dev-restart  # Restart development environment
make dev-logs     # Follow all logs
make clean        # Clean up containers and volumes
make reset        # Complete environment reset
```

View all available commands:

```bash
make help
```
