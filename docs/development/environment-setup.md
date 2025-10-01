# Development Environment Setup

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (20.10+) and **Docker Compose** (2.0+)
- **Git** (2.30+)
- **Python** (3.11+) - for local development
- **Node.js** (18+) and **npm** (9+) - for frontend development
- **Make** - for using Makefile commands

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/rcdelacruz/open-source-sei-platform.git
cd open-source-sei-platform
```

### 2. Create Environment File

```bash
cp .env.example .env
```

Edit `.env` and configure your API tokens:

- `GITHUB_TOKEN` - Your GitHub Personal Access Token
- `GITLAB_TOKEN` - Your GitLab Access Token (if using GitLab)
- `JIRA_API_TOKEN` - Your Jira API Token (if using Jira)

### 3. Start the Development Environment

Using Make (recommended):

```bash
make dev
```

Or using Docker Compose directly:

```bash
docker-compose up -d
```

### 4. Verify Services are Running

Check service status:

```bash
docker-compose ps
```

All services should show `Up` or `Up (healthy)` status.

### 5. Access the Services

Once all services are running, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **API Documentation** | http://localhost:8080/docs | N/A |
| **API Service** | http://localhost:8080 | N/A |
| **Frontend (Dev)** | http://localhost:3002 | N/A |
| **Metabase (BI)** | http://localhost:3000 | Setup on first access |
| **Grafana** | http://localhost:3001 | admin / admin123 |
| **Airflow** | http://localhost:8082 | admin / admin123 |
| **Kafka UI** | http://localhost:8083 | N/A |
| **PgAdmin** | http://localhost:8084 | admin@sei.com / admin123 |

### 6. Check API Health

Test that the API is responding:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "status": "healthy",
  "service": "api-service",
  "version": "0.1.0",
  "timestamp": "2025-09-30T10:00:00.000000"
}
```

Check readiness (includes database connectivity):

```bash
curl http://localhost:8080/ready
```

Expected response:

```json
{
  "ready": true,
  "checks": {
    "postgres": "healthy",
    "timescaledb": "healthy"
  }
}
```

## Service Architecture

The development environment includes the following services:

### Core Services

1. **API Service** (`api-service`)
    - Main REST API built with FastAPI
    - Port: 8080
    - Provides CRUD operations for organizations, teams, repositories, developers
    - Serves analytics endpoints for DORA metrics and team performance

2. **Git Collector** (`git-collector`)
    - Collects data from GitHub, GitLab, Bitbucket
    - Port: 8000
    - Polls repositories for commits, pull requests, and issues

3. **Jira Collector** (`jira-collector`)
    - Collects data from Jira and other project management tools
    - Port: 8001
    - Syncs issues, sprints, and project data

4. **Data Processor** (`data-processor`)
    - Processes raw events from Kafka
    - Transforms and stores data in TimescaleDB
    - Port: 8002

### Data Storage

1. **TimescaleDB** (`timescaledb`)
    - Time-series database for metrics and events
    - Port: 5432
    - Database: `sei_platform`
    - User: `sei_user` / Password: `sei_password`

2. **PostgreSQL** (`postgresql`)
    - Relational database for metadata
    - Port: 5433 (mapped to avoid conflict)
    - Database: `sei_metadata`
    - User: `sei_user` / Password: `sei_password`

3. **Redis** (`redis`)
    - Cache and session storage
    - Port: 6379

4. **Kafka + Zookeeper** (`kafka`, `zookeeper`)
    - Event streaming and message queue
    - Kafka Port: 9092, 29092
    - Zookeeper Port: 2181

### Analytics & Monitoring

1. **Metabase** (`metabase`)
    - Self-service BI tool
    - Port: 3000

2. **Prometheus** (`prometheus`)
    - Metrics collection
    - Port: 9090

3. **Grafana** (`grafana`)
    - Dashboards and visualization
    - Port: 3001

4. **Apache Airflow** (`airflow-webserver`, `airflow-scheduler`)
    - Workflow orchestration
    - Port: 8082

### Development Tools

1. **Kafka UI** (`kafka-ui`)
    - Web interface for Kafka
    - Port: 8083

2. **PgAdmin** (`pgadmin`)
    - PostgreSQL administration
    - Port: 8084

## Development Workflow

### Building Services

Build all services:

```bash
make build
# or
docker-compose build
```

Build a specific service:

```bash
docker-compose build api-service
```

### Viewing Logs

View logs from all services:

```bash
make dev-logs
# or
docker-compose logs -f
```

View logs from a specific service:

```bash
docker-compose logs -f api-service
```

View logs from specific service groups:

```bash
make logs-api          # API service logs
make logs-collectors   # Data collector logs
make logs-processors   # Data processor logs
```

### Stopping Services

Stop all services:

```bash
make dev-stop
# or
docker-compose down
```

Stop and remove volumes (WARNING: This deletes all data):

```bash
docker-compose down -v
```

### Restarting Services

Restart all services:

```bash
make dev-restart
# or
docker-compose restart
```

Restart a specific service:

```bash
docker-compose restart api-service
```

## Database Access

### PostgreSQL (Metadata)

Using psql:

```bash
docker-compose exec postgresql psql -U sei_user -d sei_metadata
```

Using PgAdmin:

1. Navigate to http://localhost:8084
2. Login with `admin@sei.com` / `admin123`
3. Add server:
    - Host: `postgresql` (or `host.docker.internal` from host machine)
    - Port: `5432`
    - Database: `sei_metadata`
    - User: `sei_user`
    - Password: `sei_password`

### TimescaleDB (Time-series Data)

Using psql:

```bash
docker-compose exec timescaledb psql -U sei_user -d sei_platform
```

### Redis

Using redis-cli:

```bash
docker-compose exec redis redis-cli
```

## Running Tests

Run all tests:

```bash
make test
```

Run specific test suites:

```bash
make test-unit          # Unit tests only
make test-integration   # Integration tests only
make test-e2e          # End-to-end tests
```

## Code Quality

Run linters:

```bash
make lint
```

Format code:

```bash
make format
```

Run security scans:

```bash
make security
```

## Troubleshooting

### Services won't start

1. Check if ports are already in use:

    ```bash
    lsof -i :8080  # Check API port
    lsof -i :5432  # Check TimescaleDB port
    ```

2. Check Docker resources (ensure you have enough memory):

    ```bash
    docker system df
    ```

3. View service logs for errors:

    ```bash
    docker-compose logs api-service
    ```

### Database connection errors

1. Ensure databases are running:

    ```bash
    docker-compose ps postgresql timescaledb
    ```

2. Check database logs:

    ```bash
    docker-compose logs postgresql
    docker-compose logs timescaledb
    ```

3. Test database connectivity:

    ```bash
    curl http://localhost:8080/ready
    ```

### Port conflicts

If you have port conflicts, you can modify the ports in `docker-compose.yml`. For example, to change the API port from 8080 to 8888:

```yaml
api-service:
  ports:
    - "8888:8080"  # Change external port
```

### Clean slate

To completely reset the environment:

```bash
make reset
# or
make clean
make clean-builds
make install
make dev
```

## Next Steps

After setting up the development environment:

1. **Review the API Documentation**: http://localhost:8080/docs
2. **Set up integrations**: Configure GitHub, GitLab, or Jira tokens in `.env`
3. **Read the Architecture docs**: `docs/architecture.md`
4. **Check the Roadmap**: `docs/ROADMAP.md`
5. **Contributing**: Read `docs/CONTRIBUTING.md`

## Getting Help

-  Documentation: `docs/`
-  Issues: https://github.com/rcdelacruz/open-source-sei-platform/issues
-  Discussions: https://github.com/rcdelacruz/open-source-sei-platform/discussions

---

**Happy coding!**