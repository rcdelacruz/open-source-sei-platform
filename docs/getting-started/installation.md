# Installation

Detailed installation instructions for the SEI Platform.

## System Requirements

### Minimum Requirements

- **CPU**: 4 cores
- **RAM**: 8 GB
- **Storage**: 50 GB
- **OS**: Linux, macOS, or Windows with WSL2

### Recommended Requirements

- **CPU**: 8+ cores
- **RAM**: 16+ GB
- **Storage**: 100+ GB SSD
- **OS**: Linux (Ubuntu 20.04+, CentOS 8+)

### Software Dependencies

- Docker 20.10 or higher
- Docker Compose 2.0 or higher
- Git 2.30 or higher
- Python 3.11 or higher (for local development)
- Node.js 18 or higher (for frontend development)

## Installation Methods

### Method 1: Docker Compose (Recommended)

This is the fastest way to get started. All services run in containers.

#### Step 1: Install Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**macOS:**
Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

**Windows:**
Download and install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)

#### Step 2: Clone Repository

```bash
git clone https://github.com/rcdelacruz/open-source-sei-platform.git
cd open-source-sei-platform
```

#### Step 3: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` to configure:

```bash
# Database Configuration
TIMESCALE_URL=postgresql://sei_user:sei_password@timescaledb:5432/sei_platform
POSTGRES_URL=postgresql://sei_user:sei_password@postgresql:5432/sei_metadata

# API Keys (optional for initial setup)
GITHUB_TOKEN=your_github_token_here
GITLAB_TOKEN=your_gitlab_token_here
JIRA_API_TOKEN=your_jira_token_here
JIRA_BASE_URL=https://your-domain.atlassian.net
```

#### Step 4: Start Services

Using Make:
```bash
make dev
```

Or using Docker Compose directly:
```bash
docker-compose up -d
```

#### Step 5: Verify Installation

Check service status:
```bash
docker-compose ps
```

All services should show "Up" or "Up (healthy)".

Test API:
```bash
curl http://localhost:8080/health
```

### Method 2: Kubernetes (Production)

For production deployments, use Kubernetes.

#### Prerequisites

- Kubernetes cluster (v1.24+)
- kubectl configured
- Helm 3 installed

#### Step 1: Create Namespace

```bash
kubectl create namespace sei-platform
```

#### Step 2: Deploy Services

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

#### Step 3: Verify Deployment

```bash
kubectl get pods -n sei-platform
kubectl get services -n sei-platform
```

### Method 3: Local Development

For active development on services.

#### Prerequisites

- Python 3.11+
- Node.js 18+
- PostgreSQL 14+
- TimescaleDB 2.11+
- Redis 7+
- Apache Kafka 3.5+

#### Step 1: Install Python Dependencies

```bash
pip install -r requirements.txt
```

#### Step 2: Install Frontend Dependencies

```bash
cd src/frontend
npm install
```

#### Step 3: Start Databases

```bash
# Start PostgreSQL, TimescaleDB, Redis, Kafka
docker-compose up -d postgresql timescaledb redis kafka zookeeper
```

#### Step 4: Run Services

In separate terminals:

```bash
# API Service
cd src/apis
uvicorn main:app --reload --port 8080

# Git Collector
cd src/collectors/git
uvicorn main:app --reload --port 8000

# Jira Collector
cd src/collectors/jira
uvicorn main:app --reload --port 8001

# Data Processor
cd src/processors
uvicorn main:app --reload --port 8002

# Frontend
cd src/frontend
npm start
```

## Post-Installation Configuration

### Database Setup

Initialize databases:

```bash
# Run migrations
make db-migrate

# Seed with sample data
make db-seed
```

### Configure Integrations

#### GitHub Integration

1. Generate a Personal Access Token:

    - Go to GitHub Settings → Developer settings → Personal access tokens
    - Generate new token with `repo` and `read:org` scopes

2. Add to `.env`:
   ```bash
   GITHUB_TOKEN=ghp_your_token_here
   ```

#### GitLab Integration

1. Generate an Access Token:

    - Go to GitLab Settings → Access Tokens
    - Create token with `api` scope

2. Add to `.env`:
   ```bash
   GITLAB_TOKEN=glpat_your_token_here
   ```

#### Jira Integration

1. Generate an API Token:

    - Go to Jira Account Settings → Security → API tokens
    - Create token

2. Add to `.env`:
   ```bash
   JIRA_API_TOKEN=your_token_here
   JIRA_BASE_URL=https://your-domain.atlassian.net
   ```

### Access Services

After installation, access:

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| API Docs | http://localhost:8080/docs | None |
| Frontend | http://localhost:3002 | None |
| Metabase | http://localhost:3000 | Setup wizard |
| Grafana | http://localhost:3001 | admin / admin123 |
| Airflow | http://localhost:8082 | admin / admin123 |

## Verification

### Health Checks

Check API health:
```bash
curl http://localhost:8080/health
```

Check readiness:
```bash
curl http://localhost:8080/ready
```

### Service Logs

View logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api-service
```

## Troubleshooting

### Port Conflicts

If ports are already in use, modify `docker-compose.yml`:

```yaml
services:
  api-service:
    ports:
      - "8888:8080"  # Change external port
```

### Memory Issues

Increase Docker memory allocation:

- Docker Desktop: Settings → Resources → Memory (16GB recommended)

### Database Connection Errors

Ensure databases are running:
```bash
docker-compose ps postgresql timescaledb
```

Check logs:
```bash
docker-compose logs postgresql timescaledb
```

### Build Failures

Clean and rebuild:
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## Uninstallation

### Remove Containers

```bash
docker-compose down
```

### Remove Containers and Volumes

Warning: This deletes all data.

```bash
docker-compose down -v
```

### Remove Images

```bash
docker-compose down --rmi all
```

## Next Steps

- [Configuration Guide](configuration.md)
- [Development Setup](../development/environment-setup.md)
- [Architecture Overview](../architecture/overview.md)
- [API Reference](../api/introduction.md)