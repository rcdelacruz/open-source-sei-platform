# Quick Start

Get the SEI Platform up and running in under 5 minutes.

## Prerequisites

Ensure you have the following installed:

- Docker (20.10+)
- Docker Compose (2.0+)
- Git (2.30+)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/rcdelacruz/open-source-sei-platform.git
cd open-source-sei-platform
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` to add your API tokens (optional for initial setup):

```bash
GITHUB_TOKEN=your_github_token_here
JIRA_API_TOKEN=your_jira_token_here
```

### 3. Start the Platform

```bash
make dev
```

Or using Docker Compose:

```bash
docker-compose up -d
```

### 4. Verify Installation

Check that all services are running:

```bash
docker-compose ps
```

Test the API:

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

## Access the Services

Once running, access the following services:

| Service | URL | Credentials |
|---------|-----|-------------|
| API Documentation | http://localhost:8080/docs | None |
| API Service | http://localhost:8080 | None |
| Frontend | http://localhost:3002 | None |
| Metabase | http://localhost:3000 | Setup required |
| Grafana | http://localhost:3001 | admin / admin123 |
| Airflow | http://localhost:8082 | admin / admin123 |

## Next Steps

1. **Explore the API**: Visit http://localhost:8080/docs to see all available endpoints
2. **Configure Integrations**: Add your GitHub, GitLab, or Jira credentials
3. **Review Architecture**: Learn about the system design in the [Architecture section](../architecture/overview.md)
4. **Start Development**: Follow the [Development Guide](../development/environment-setup.md)

## Stopping the Platform

To stop all services:

```bash
make dev-stop
```

Or:

```bash
docker-compose down
```

## Troubleshooting

### Port Conflicts

If you encounter port conflicts, modify the port mappings in `docker-compose.yml`:

```yaml
services:
  api-service:
    ports:
      - "8888:8080"  # Change 8080 to 8888
```

### Services Not Starting

Check service logs:

```bash
docker-compose logs api-service
```

### Database Connection Issues

Verify databases are running:

```bash
docker-compose ps postgresql timescaledb
```

Check the readiness endpoint:

```bash
curl http://localhost:8080/ready
```

## Getting Help

- Review the [Full Installation Guide](installation.md)
- Check the [Development Setup Guide](../development/environment-setup.md)
- Report issues on [GitHub](https://github.com/rcdelacruz/open-source-sei-platform/issues)