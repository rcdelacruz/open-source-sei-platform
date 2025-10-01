# Configuration

Configure the SEI Platform to integrate with your development tools.

## Configuration Overview

The platform uses environment variables for configuration. All settings are defined in the `.env` file.

## Environment Variables

### Application Settings

```bash
# Environment
ENVIRONMENT=development          # development, staging, production
LOG_LEVEL=INFO                  # DEBUG, INFO, WARNING, ERROR
DEBUG=true                      # Enable debug mode

# API Configuration
API_RATE_LIMIT=1000            # Requests per window
JWT_SECRET=your_secret_here    # Change in production
JWT_EXPIRATION=3600            # Token expiration in seconds
```

### Database Configuration

```bash
# TimescaleDB (Time-series data)
TIMESCALE_URL=postgresql://sei_user:sei_password@timescaledb:5432/sei_platform

# PostgreSQL (Metadata)
POSTGRES_URL=postgresql://sei_user:sei_password@postgresql:5432/sei_metadata

# Redis (Cache)
REDIS_URL=redis://redis:6379
```

### Message Queue Configuration

```bash
# Kafka
KAFKA_BROKERS=kafka:9092
KAFKA_TOPIC_PREFIX=sei_
```

### Integration Credentials

#### GitHub

```bash
GITHUB_TOKEN=ghp_your_token_here
```

**Required Scopes:**
- `repo` - Access repository data
- `read:org` - Read organization data
- `read:user` - Read user profile data

**How to Generate:**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token (classic)"
3. Select required scopes
4. Generate token and copy

#### GitLab

```bash
GITLAB_TOKEN=glpat_your_token_here
GITLAB_API_URL=https://gitlab.com/api/v4
```

**Required Scopes:**
- `api` - Full API access
- `read_api` - Read-only API access (alternative)

**How to Generate:**
1. Go to GitLab Settings → Access Tokens
2. Name your token
3. Select `api` scope
4. Create token and copy

#### Jira

```bash
JIRA_API_TOKEN=your_jira_token_here
JIRA_BASE_URL=https://your-domain.atlassian.net
JIRA_USERNAME=your.email@company.com
```

**How to Generate:**
1. Go to Jira Account Settings → Security → API tokens
2. Click "Create API token"
3. Name your token
4. Copy the token

#### Slack

```bash
SLACK_BOT_TOKEN=xoxb-your-token-here
```

**How to Generate:**
1. Go to [Slack API](https://api.slack.com/apps)
2. Create new app or select existing
3. Go to OAuth & Permissions
4. Install app to workspace
5. Copy Bot User OAuth Token

### Security Configuration

```bash
# Encryption
ENCRYPTION_KEY=your_encryption_key_here

# CORS
CORS_ORIGINS=["*"]  # Restrict in production

# API Security
API_RATE_LIMIT=1000
```

### Monitoring Configuration

```bash
# Prometheus
PROMETHEUS_URL=http://prometheus:9090

# Grafana
GRAFANA_URL=http://grafana:3000
```

### Email Configuration (Optional)

```bash
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

## Feature Flags

Enable or disable specific features:

```bash
ENABLE_ML_FEATURES=true
ENABLE_REAL_TIME_PROCESSING=true
ENABLE_PREDICTIVE_ANALYTICS=false
```

## Configuration Files

### Development Configuration

Located at `config/dev.env.example`:

```bash
# Development-specific settings
DEBUG=true
LOG_LEVEL=DEBUG
ENVIRONMENT=development
```

### Production Configuration

Located at `config/production.env.example`:

```bash
# Production-specific settings
DEBUG=false
LOG_LEVEL=INFO
ENVIRONMENT=production
```

## Service-Specific Configuration

### API Service

Configuration in `src/apis/config.py`:

```python
class Settings(BaseSettings):
    environment: str = "development"
    log_level: str = "INFO"
    debug: bool = True

    # Security
    jwt_secret: str = "your_jwt_secret_here"
    jwt_algorithm: str = "HS256"
    jwt_expiration: int = 3600

    # Database
    postgres_url: str
    timescale_url: str
    redis_url: str
```

### Git Collector

Configuration in `src/collectors/git/config.py`:

```python
class Settings(BaseSettings):
    # GitHub API
    github_token: str = ""
    github_api_url: str = "https://api.github.com"

    # GitLab API
    gitlab_token: str = ""
    gitlab_api_url: str = "https://gitlab.com/api/v4"

    # Rate Limiting
    rate_limit_requests: int = 5000
    rate_limit_window: int = 3600
```

## Database Configuration

### PostgreSQL

Connection string format:
```
postgresql://user:password@host:port/database
```

Default:
```
postgresql://sei_user:sei_password@postgresql:5432/sei_metadata
```

### TimescaleDB

Connection string format:
```
postgresql://user:password@host:port/database
```

Default:
```
postgresql://sei_user:sei_password@timescaledb:5432/sei_platform
```

### Redis

Connection string format:
```
redis://host:port
```

Default:
```
redis://redis:6379
```

## Kafka Configuration

```bash
# Brokers
KAFKA_BROKERS=kafka:9092

# Topics
KAFKA_TOPIC_PREFIX=sei_

# Consumer Groups
KAFKA_CONSUMER_GROUP=data-processor-group
```

## Testing Configuration

Create a separate `.env.test` file for testing:

```bash
ENVIRONMENT=test
LOG_LEVEL=DEBUG
POSTGRES_URL=postgresql://test_user:test_pass@localhost:5432/test_db
TIMESCALE_URL=postgresql://test_user:test_pass@localhost:5432/test_timescale
```

## Configuration Best Practices

### Security

1. **Never commit `.env` files** to version control
2. **Use strong passwords** for all services
3. **Rotate tokens regularly**
4. **Use different credentials** for each environment
5. **Encrypt sensitive data** at rest

### Development

1. Use `.env.example` as a template
2. Document all environment variables
3. Provide sensible defaults
4. Validate configuration on startup

### Production

1. Use secrets management (AWS Secrets Manager, HashiCorp Vault)
2. Enable SSL/TLS for all connections
3. Restrict CORS origins
4. Enable rate limiting
5. Use strong JWT secrets

## Validation

Verify configuration:

```bash
# Check API configuration
curl http://localhost:8080/health

# Check database connectivity
curl http://localhost:8080/ready

# View current configuration (be careful with sensitive data)
docker-compose exec api-service env | grep -v PASSWORD
```

## Troubleshooting

### Invalid Configuration

If services fail to start, check logs:

```bash
docker-compose logs api-service
```

Common issues:

- Missing required environment variables
- Invalid database connection strings
- Incorrect API tokens
- Port conflicts

### Database Connection Issues

Verify connection strings:

```bash
# Test PostgreSQL
docker-compose exec postgresql psql -U sei_user -d sei_metadata -c "SELECT 1"

# Test TimescaleDB
docker-compose exec timescaledb psql -U sei_user -d sei_platform -c "SELECT 1"
```

### API Token Issues

Test tokens manually:

```bash
# GitHub
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user

# GitLab
curl -H "PRIVATE-TOKEN: YOUR_TOKEN" https://gitlab.com/api/v4/user
```

## Next Steps

- [Development Setup](../development/environment-setup.md)
- [Running Services](../development/running-services.md)
- [API Reference](../api/introduction.md)