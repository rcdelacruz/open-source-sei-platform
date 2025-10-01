# Project Structure

This document describes the organization and structure of the SEI Platform repository.

## Repository Overview

The SEI Platform follows a service-oriented architecture with clear separation between data collection, processing, API services, and frontend components.

```
sei-platform/
├── src/                    # Source code
│   ├── apis/              # API services
│   ├── collectors/        # Data collectors
│   ├── processors/        # Data processors
│   ├── frontend/          # React frontend
│   └── workflows/         # Airflow DAGs
├── config/                # Configuration files
├── docs/                  # Documentation
├── k8s/                   # Kubernetes manifests
├── scripts/               # Utility scripts
└── tests/                 # Test suites
```

## Directory Structure

### Source Code (`src/`)

The `src/` directory contains all application source code organized by service type.

#### API Services (`src/apis/`)

RESTful API services built with FastAPI:

- `main.py` - FastAPI application entry point
- `config.py` - Configuration management
- `database.py` - Database connection handling
- `routes/` - API endpoint definitions
    - `health.py` - Health check endpoints
    - `organizations.py` - Organization management
    - `teams.py` - Team management
    - `developers.py` - Developer metrics
    - `repositories.py` - Repository analytics
    - `analytics.py` - Analytics endpoints
- `models/` - SQLAlchemy models
- `schemas/` - Pydantic schemas for validation
- `services/` - Business logic layer
- `Dockerfile` - Container image definition
- `requirements.txt` - Python dependencies

#### Data Collectors (`src/collectors/`)

Services that collect data from external sources:

**Git Collector (`src/collectors/git/`)**

- `main.py` - Collector service entry point
- `config.py` - Git-specific configuration
- `routes/` - Collector API endpoints
    - `health.py` - Health check
    - `collector.py` - Collection triggers
- `services/` - Git data collection logic
- `models/` - Data models for Git entities
- `Dockerfile` - Container image definition

**Jira Collector (`src/collectors/jira/`)**

- `main.py` - Collector service entry point
- `config.py` - Jira-specific configuration
- `routes/` - Collector API endpoints
- `services/` - Jira data collection logic
- `models/` - Data models for Jira entities
- `Dockerfile` - Container image definition

#### Data Processors (`src/processors/`)

Services that process and transform collected data:

- `main.py` - Processor entry point
- `config.py` - Processor configuration
- `routes/` - Processing API endpoints
- `processors/` - Data processing logic
    - `velocity.py` - Velocity calculations
    - `quality.py` - Code quality metrics
    - `collaboration.py` - Collaboration metrics
    - `flow.py` - Development flow metrics
- `Dockerfile` - Container image definition

#### Frontend (`src/frontend/`)

React-based web application:

- `public/` - Static assets
- `src/` - React application source
    - `components/` - Reusable React components
    - `pages/` - Page-level components
    - `hooks/` - Custom React hooks
    - `services/` - API client services
    - `utils/` - Utility functions
    - `types/` - TypeScript type definitions
- `package.json` - Node.js dependencies
- `tsconfig.json` - TypeScript configuration
- `Dockerfile.dev` - Development container
- `Dockerfile.prod` - Production container

#### Workflows (`src/workflows/`)

Apache Airflow DAGs for orchestration:

- `dags/` - Airflow DAG definitions
    - `data_collection.py` - Collection workflows
    - `data_processing.py` - Processing workflows
    - `data_export.py` - Export workflows
- `plugins/` - Custom Airflow plugins
- `logs/` - Airflow execution logs

### Configuration (`config/`)

Environment-specific configuration files:

- `prometheus.yml` - Prometheus monitoring configuration
- `kong.yml` - API gateway configuration
- `grafana/` - Grafana dashboards and provisioning
- `dev.env.example` - Development environment template
- `prod.env.example` - Production environment template

### Documentation (`docs/`)

Project documentation in Markdown format:

- `getting-started/` - Quick start guides
- `architecture/` - System architecture
- `development/` - Development guides
- `deployment/` - Deployment instructions
- `api/` - API reference documentation
- `contributing/` - Contribution guidelines

### Kubernetes (`k8s/`)

Kubernetes deployment manifests:

- `namespace.yaml` - Namespace definition
- `configmaps/` - Configuration maps
- `secrets/` - Secret definitions
- `deployments/` - Deployment manifests
- `services/` - Service definitions
- `ingress/` - Ingress rules
- `staging/` - Staging environment
- `production/` - Production environment

### Scripts (`scripts/`)

Utility and automation scripts:

- `init-timescaledb.sql` - TimescaleDB initialization
- `init-postgresql.sql` - PostgreSQL initialization
- `backup-databases.sh` - Database backup script
- `restore-databases.sh` - Database restore script
- `generate-config.py` - Configuration generator
- `export-data.py` - Data export utility

### Tests (`tests/`)

Comprehensive test suites:

- `unit/` - Unit tests
- `integration/` - Integration tests
- `e2e/` - End-to-end tests
- `load/` - Load and performance tests
- `fixtures/` - Test fixtures and data
- `conftest.py` - Pytest configuration

## File Naming Conventions

### Python Files

Follow PEP 8 naming conventions:

- Module names: lowercase with underscores (e.g., `data_processor.py`)
- Class names: PascalCase (e.g., `DataProcessor`)
- Function names: lowercase with underscores (e.g., `process_data`)
- Constants: uppercase with underscores (e.g., `MAX_RETRIES`)

### TypeScript/JavaScript Files

Follow standard JavaScript conventions:

- Component files: PascalCase (e.g., `Dashboard.tsx`)
- Utility files: camelCase (e.g., `apiClient.ts`)
- Hook files: camelCase with prefix (e.g., `useAuth.ts`)
- Type definition files: PascalCase (e.g., `User.types.ts`)

### Configuration Files

Use descriptive names with appropriate extensions:

- YAML files: `.yml` or `.yaml`
- Environment files: `.env` or `.env.example`
- JSON files: `.json`
- Docker files: `Dockerfile` or `Dockerfile.<env>`

## Code Organization Principles

### Separation of Concerns

Each service maintains clear boundaries:

- Collectors: Data ingestion only
- Processors: Data transformation only
- APIs: Data access and business logic
- Frontend: User interface and interaction

### Dependency Flow

Services follow a unidirectional data flow:

```
Collectors → Kafka → Processors → TimescaleDB → APIs → Frontend
```

### Configuration Management

Configuration follows the 12-factor app methodology:

- Environment variables for configuration
- Separate config files per environment
- No secrets in source code
- Default values with overrides

### Module Independence

Each service can be:

- Developed independently
- Tested independently
- Deployed independently
- Scaled independently

### Shared Code

Common code is organized into reusable modules:

- Database models shared via packages
- Utility functions in dedicated modules
- Schemas defined once, used everywhere
- Types exported and imported as needed

## Service Dependencies

### API Service

Dependencies:

- TimescaleDB (primary data store)
- PostgreSQL (metadata store)
- Redis (caching layer)

### Collectors

Dependencies:

- Kafka (message queue)
- Redis (state management)
- External APIs (data sources)

### Processors

Dependencies:

- Kafka (message consumption)
- TimescaleDB (data storage)
- Redis (coordination)

### Frontend

Dependencies:

- API Service (data access)
- WebSocket connection (real-time updates)

## Development Workflow

### Adding New Features

When adding features, follow this structure:

1. **Create feature branch** from master
2. **Add code** in appropriate service directory
3. **Add tests** in corresponding test directory
4. **Update documentation** in docs directory
5. **Update configuration** if needed
6. **Submit pull request** for review

### Adding New Services

For new services:

1. **Create service directory** under `src/`
2. **Add Dockerfile** for containerization
3. **Add to docker-compose.yml** for local development
4. **Create Kubernetes manifests** in `k8s/`
5. **Add Makefile targets** for common operations
6. **Document service** in architecture docs

### Modifying Existing Services

When modifying services:

1. **Update source code** in service directory
2. **Update tests** to match changes
3. **Update schemas** if data models change
4. **Update API documentation** if endpoints change
5. **Update migrations** if database changes
6. **Update dependencies** if required

## Best Practices

### Keep Services Focused

Each service should have a single, well-defined responsibility:

- Avoid mixing concerns across service boundaries
- Use message queues for inter-service communication
- Maintain clear API contracts

### Maintain Clean Boundaries

Organize code to maintain clear separation:

- Business logic in service layer
- Data access in repository layer
- Validation in schema layer
- Routing in route layer

### Use Consistent Structure

Follow established patterns:

- All services use similar directory structure
- Common patterns for error handling
- Consistent logging and monitoring
- Shared coding standards

### Document As You Go

Keep documentation synchronized:

- Update docs when changing features
- Add comments for complex logic
- Maintain API documentation
- Document configuration options
