# Running Services

This guide explains how to run SEI Platform services locally for development and debugging.

## Prerequisites

Before running services, ensure you have:

- Docker and Docker Compose installed
- Make utility installed
- Python 3.9+ installed
- Node.js 16+ installed
- At least 8GB RAM available
- Ports 3000-3002, 5432-5433, 6379, 8000-8001, 8080-8084, 9090, 9092 available

## Quick Start

Start all services with a single command:

```bash
make dev
```

This command will:

- Build all Docker images
- Start all services in containers
- Initialize databases
- Wait for services to be ready
- Display service URLs

Services will be available at:

- Frontend: http://localhost:3002
- API: http://localhost:8080
- Metabase: http://localhost:3000
- Grafana: http://localhost:3001
- Airflow: http://localhost:8082
- Kafka UI: http://localhost:8083
- PgAdmin: http://localhost:8084

## Running Individual Services

### API Service

Run the API service standalone:

```bash
# Using Docker Compose
docker-compose up api-service

# Without Docker (requires databases running)
cd src/apis
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

The API will be available at http://localhost:8080 with interactive documentation at http://localhost:8080/docs.

### Git Collector

Run the Git collector service:

```bash
# Using Docker Compose
docker-compose up git-collector

# Without Docker
cd src/collectors/git
pip install -r requirements.txt
python main.py
```

### Jira Collector

Run the Jira collector service:

```bash
# Using Docker Compose
docker-compose up jira-collector

# Without Docker
cd src/collectors/jira
pip install -r requirements.txt
python main.py
```

### Data Processor

Run the data processor service:

```bash
# Using Docker Compose
docker-compose up data-processor

# Without Docker
cd src/processors
pip install -r requirements.txt
python main.py
```

### Frontend Development Server

Run the frontend in development mode:

```bash
# Using Docker Compose
docker-compose up frontend-dev

# Without Docker
cd src/frontend
npm install
npm start
```

The development server will be available at http://localhost:3002 with hot module reloading enabled.

## Running Infrastructure Services

### Database Services

Start only the database services:

```bash
# TimescaleDB (primary data store)
docker-compose up -d timescaledb

# PostgreSQL (metadata store)
docker-compose up -d postgresql
```

Connect to databases:

```bash
# TimescaleDB
psql -h localhost -p 5432 -U sei_user -d sei_platform

# PostgreSQL
psql -h localhost -p 5433 -U sei_user -d sei_metadata
```

### Message Queue

Start Kafka and Zookeeper:

```bash
docker-compose up -d zookeeper kafka
```

Verify Kafka is running:

```bash
# Using Kafka UI
open http://localhost:8083

# Using command line
docker exec sei-kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Cache Service

Start Redis:

```bash
docker-compose up -d redis
```

Connect to Redis:

```bash
# Using redis-cli
docker exec -it sei-redis redis-cli

# Using make target
make shell-redis
```

## Service Dependencies

Services must be started in the correct order to satisfy dependencies:

1. **Infrastructure Services**
    - Zookeeper
    - Kafka
    - Redis
    - TimescaleDB
    - PostgreSQL

2. **Collection Services**
    - Git Collector (requires Kafka, Redis)
    - Jira Collector (requires Kafka, Redis)

3. **Processing Services**
    - Data Processor (requires Kafka, TimescaleDB, Redis)

4. **API Services**
    - API Service (requires TimescaleDB, PostgreSQL, Redis)

5. **Frontend Services**
    - Frontend (requires API Service)

Docker Compose handles these dependencies automatically through the `depends_on` configuration.

## Environment Configuration

### Environment Variables

Create a `.env` file from the example:

```bash
cp .env.example .env
```

Edit the `.env` file to configure:

- Database connection strings
- API keys for external services
- Service-specific settings
- Feature flags

Common environment variables:

- `KAFKA_BROKERS` - Kafka broker addresses
- `REDIS_URL` - Redis connection URL
- `TIMESCALE_URL` - TimescaleDB connection URL
- `POSTGRES_URL` - PostgreSQL connection URL
- `LOG_LEVEL` - Logging level (DEBUG, INFO, WARNING, ERROR)
- `GITHUB_TOKEN` - GitHub API token for Git collector
- `JIRA_URL` - Jira instance URL
- `JIRA_TOKEN` - Jira API token

### Configuration Files

Services use configuration files in the `config/` directory:

- `config/prometheus.yml` - Prometheus monitoring
- `config/kong.yml` - API gateway routing
- `config/grafana/` - Grafana dashboards

Override configuration by:

- Setting environment variables
- Mounting custom config files as volumes
- Using Docker Compose override files

### Development vs Production

Use different configuration for environments:

```bash
# Development
make config-dev

# Production
make config-prod
```

## Hot Reloading and Development Mode

### Python Services

Python services use uvicorn with the `--reload` flag for automatic reloading:

```python
# In main.py
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)
```

Changes to Python files will automatically restart the service.

### Frontend Development

The frontend uses Create React App's development server with hot module replacement:

```bash
npm start
```

Changes to React components will update in the browser without full page reload.

### Volume Mounts

Docker Compose mounts source code as volumes for hot reloading:

```yaml
volumes:
  - ./src/apis:/app
  - ./src/frontend:/app
```

This allows editing files on the host with changes reflected in containers.

## Debugging Services

### Debug Mode

Enable debug logging:

```bash
# Set environment variable
export LOG_LEVEL=DEBUG

# Or in .env file
LOG_LEVEL=DEBUG
```

### Viewing Logs

View logs for all services:

```bash
# Using make
make dev-logs

# Using docker-compose
docker-compose logs -f
```

View logs for specific services:

```bash
# API service
make logs-api

# Collectors
make logs-collectors

# Processors
make logs-processors

# Specific service
docker-compose logs -f api-service
```

### Interactive Debugging

Attach to running containers:

```bash
# API service shell
make shell-api

# Database shell
make shell-db

# Redis shell
make shell-redis

# Any container
docker exec -it <container-name> /bin/bash
```

### Remote Debugging

For Python services using debugpy:

1. Add debugpy to requirements
2. Configure debugpy in code
3. Expose debug port in docker-compose
4. Connect from IDE

Example configuration:

```python
import debugpy
debugpy.listen(("0.0.0.0", 5678))
debugpy.wait_for_client()
```

### Health Checks

Check service health:

```bash
# API service
curl http://localhost:8080/health

# Git collector
curl http://localhost:8081/health

# All services
make status
```

## Common Operations

### Restart Services

Restart all services:

```bash
make dev-restart
```

Restart specific service:

```bash
docker-compose restart api-service
```

### Stop Services

Stop all services:

```bash
make dev-stop
```

Stop specific service:

```bash
docker-compose stop api-service
```

### Rebuild Services

Rebuild after dependency changes:

```bash
# Rebuild all
docker-compose build

# Rebuild specific service
docker-compose build api-service

# Force rebuild without cache
docker-compose build --no-cache
```

### Clean Environment

Remove all containers, volumes, and images:

```bash
make clean
```

Remove build artifacts:

```bash
make clean-builds
```

## Performance Optimization

### Resource Limits

Configure resource limits in docker-compose.yml:

```yaml
services:
  api-service:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### Database Tuning

Optimize database settings for development:

- Reduce shared_buffers for local development
- Disable fsync for faster writes (dev only)
- Increase work_mem for complex queries

### Parallel Startup

Start independent services in parallel:

```bash
docker-compose up -d timescaledb postgresql redis &
docker-compose up -d zookeeper kafka &
wait
docker-compose up -d git-collector jira-collector data-processor
```

## Troubleshooting

### Port Conflicts

If ports are in use:

```bash
# Check what's using a port
lsof -i :8080

# Kill process using port
kill -9 <PID>

# Or change port in docker-compose.yml
```

### Database Connection Issues

If services can't connect to databases:

1. Verify databases are running
2. Check connection strings in .env
3. Wait for databases to be ready
4. Check network connectivity

```bash
# Test database connection
docker exec sei-timescaledb pg_isready -U sei_user

# Check logs
docker-compose logs timescaledb
```

### Memory Issues

If services crash due to memory:

1. Increase Docker memory limit
2. Reduce number of running services
3. Add swap space
4. Optimize container resource usage

### Service Won't Start

If a service fails to start:

1. Check service logs
2. Verify dependencies are running
3. Check environment variables
4. Rebuild the container
5. Remove volumes and restart

```bash
# Remove volumes
docker-compose down -v

# Rebuild and restart
docker-compose up --build
```

### Network Issues

If services can't communicate:

```bash
# Check Docker network
docker network ls
docker network inspect sei-network

# Verify service connectivity
docker exec api-service ping timescaledb
```

## Advanced Configuration

### Custom Docker Compose

Create a docker-compose override:

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  api-service:
    environment:
      LOG_LEVEL: DEBUG
    ports:
      - "8080:8080"
```

### Service Scaling

Scale services horizontally:

```bash
# Scale API service to 3 instances
docker-compose up --scale api-service=3
```

### Development Tools

Additional development tools:

```bash
# Jupyter notebook for data analysis
make jupyter

# PostgreSQL admin interface
open http://localhost:8084
```

## Best Practices

### Local Development

For efficient local development:

- Run only services you're working on
- Use volume mounts for hot reloading
- Enable debug logging for your service
- Use health checks to verify services
- Keep databases running to avoid restart delays

### Resource Management

To conserve resources:

- Stop unused services
- Use `docker-compose down -v` to clean volumes
- Prune unused images and containers regularly
- Monitor resource usage with `docker stats`

### Configuration Management

For managing configuration:

- Use .env files for local overrides
- Never commit secrets to version control
- Document required environment variables
- Provide sensible defaults
- Use separate configs for dev/staging/prod
