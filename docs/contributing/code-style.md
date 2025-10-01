# Code Style Guide

Consistent code style improves readability and maintainability. This guide covers style requirements for all languages used in the SEI Platform.

## Python

### Style Guide

Follow PEP 8 with these specific requirements:

- Line length: 100 characters maximum
- Indentation: 4 spaces (no tabs)
- String quotes: Double quotes for strings, single for keys
- Import sorting: isort with black profile

### Formatting Tools

Use Black for automatic formatting:

```bash
# Format all Python files
black src/ --line-length 100

# Check formatting
black src/ --check --line-length 100
```

### Linting

Use flake8 and pylint:

```bash
# Run flake8
flake8 src/ --max-line-length=100

# Run pylint
pylint src/ --max-line-length=100
```

### Type Hints

All new code must include type hints:

```python
from typing import List, Optional, Dict, Any
from datetime import datetime

def calculate_metrics(
    team_id: str,
    start_date: datetime,
    end_date: datetime,
    metric_types: Optional[List[str]] = None
) -> Dict[str, Any]:
    """
    Calculate metrics for a team.

    Args:
        team_id: Unique team identifier
        start_date: Start of date range
        end_date: End of date range
        metric_types: Optional list of specific metrics to calculate

    Returns:
        Dictionary containing calculated metrics

    Raises:
        ValueError: If date range is invalid
    """
    if start_date > end_date:
        raise ValueError("start_date must be before end_date")

    results: Dict[str, Any] = {}
    # Implementation
    return results
```

### Docstrings

Use Google-style docstrings:

```python
class DataCollector:
    """
    Collects data from external sources.

    This class handles authentication, rate limiting, and error
    handling for data collection operations.

    Attributes:
        api_key: Authentication key for the data source
        rate_limit: Maximum requests per minute
        retry_count: Number of retries for failed requests

    Example:
        >>> collector = DataCollector(api_key="key123")
        >>> data = collector.collect(source="github")
    """

    def __init__(self, api_key: str, rate_limit: int = 100):
        """
        Initialize the data collector.

        Args:
            api_key: API authentication key
            rate_limit: Maximum requests per minute (default: 100)
        """
        self.api_key = api_key
        self.rate_limit = rate_limit
```

### Imports

Organize imports in three groups:

```python
# Standard library imports
import os
import sys
from datetime import datetime
from typing import List, Optional

# Third-party imports
import pandas as pd
import requests
from flask import Flask, jsonify

# Local application imports
from app.models import Team, Metric
from app.services import DataCollector
from app.utils import validate_date_range
```

Sort with isort:

```bash
isort src/ --profile black
```

### Naming Conventions

- Classes: PascalCase
- Functions: snake_case
- Constants: UPPER_SNAKE_CASE
- Private methods: _leading_underscore
- Protected attributes: _single_underscore

```python
# Constants
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30

# Classes
class MetricCalculator:
    """Calculator for team metrics."""

    def __init__(self):
        self._cache = {}  # Private attribute

    def calculate_velocity(self, team_id: str) -> float:
        """Public method."""
        return self._fetch_from_cache(team_id)

    def _fetch_from_cache(self, key: str) -> float:
        """Private helper method."""
        return self._cache.get(key, 0.0)
```

### Error Handling

Use specific exceptions and proper error handling:

```python
class TeamNotFoundError(Exception):
    """Raised when team ID is not found."""
    pass

def get_team_metrics(team_id: str) -> Dict[str, Any]:
    """Get metrics for a team."""
    try:
        team = Team.query.get(team_id)
        if not team:
            raise TeamNotFoundError(f"Team {team_id} not found")

        return team.calculate_metrics()

    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        raise
    except Exception as e:
        logger.exception("Unexpected error calculating metrics")
        raise
```

## TypeScript/JavaScript

### Style Guide

Follow the Airbnb JavaScript Style Guide with modifications:

- Use TypeScript for all new code
- Prefer functional components in React
- Use async/await over promises
- Enable strict mode in TypeScript

### Formatting

Use Prettier for formatting:

```bash
# Format all TypeScript files
prettier --write "src/**/*.{ts,tsx}"

# Check formatting
prettier --check "src/**/*.{ts,tsx}"
```

### Linting

Use ESLint with TypeScript plugin:

```bash
# Run ESLint
eslint "src/**/*.{ts,tsx}"

# Fix auto-fixable issues
eslint "src/**/*.{ts,tsx}" --fix
```

### TypeScript Configuration

Enable strict type checking in tsconfig.json:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true
  }
}
```

### Type Definitions

Define interfaces for all data structures:

```typescript
interface Team {
  id: string;
  name: string;
  members: TeamMember[];
  createdAt: Date;
  updatedAt: Date;
}

interface TeamMember {
  userId: string;
  role: 'developer' | 'lead' | 'manager';
  joinedAt: Date;
}

interface MetricData {
  teamId: string;
  metricType: string;
  value: number;
  timestamp: Date;
  metadata?: Record<string, unknown>;
}
```

### React Components

Use functional components with TypeScript:

```typescript
import React, { useState, useEffect } from 'react';

interface MetricCardProps {
  teamId: string;
  metricType: string;
  refreshInterval?: number;
}

export const MetricCard: React.FC<MetricCardProps> = ({
  teamId,
  metricType,
  refreshInterval = 60000,
}) => {
  const [data, setData] = useState<MetricData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchMetric = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/v1/teams/${teamId}/metrics/${metricType}`);
        const result = await response.json();
        setData(result);
        setError(null);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    fetchMetric();
    const interval = setInterval(fetchMetric, refreshInterval);

    return () => clearInterval(interval);
  }, [teamId, metricType, refreshInterval]);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorDisplay error={error} />;
  if (!data) return null;

  return (
    <div className="metric-card">
      <h3>{metricType}</h3>
      <p className="metric-value">{data.value}</p>
    </div>
  );
};
```

### Naming Conventions

- Components: PascalCase
- Hooks: camelCase with use prefix
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case for files, PascalCase for components

```typescript
// Constants
const MAX_RETRIES = 3;
const API_BASE_URL = process.env.REACT_APP_API_URL;

// Custom hooks
function useTeamMetrics(teamId: string) {
  // Implementation
}

// Components
function MetricsDashboard() {
  // Implementation
}
```

### Async/Await

Prefer async/await over promises:

```typescript
// Good
async function fetchTeamData(teamId: string): Promise<Team> {
  try {
    const response = await fetch(`/api/v1/teams/${teamId}`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    logger.error('Failed to fetch team data', error);
    throw error;
  }
}

// Avoid
function fetchTeamData(teamId: string): Promise<Team> {
  return fetch(`/api/v1/teams/${teamId}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.json();
    })
    .catch(error => {
      logger.error('Failed to fetch team data', error);
      throw error;
    });
}
```

## SQL

### Style Guide

Follow SQL Style Guide best practices:

- Keywords in UPPERCASE
- Table and column names in snake_case
- Indent nested queries
- Use explicit JOINs

### Examples

```sql
-- Good
SELECT
    t.id,
    t.name,
    COUNT(m.id) AS member_count,
    AVG(mt.value) AS avg_velocity
FROM teams t
    LEFT JOIN team_members m ON t.id = m.team_id
    LEFT JOIN metrics mt ON t.id = mt.team_id
WHERE
    t.is_active = TRUE
    AND mt.metric_type = 'velocity'
    AND mt.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    t.id,
    t.name
HAVING
    COUNT(m.id) > 0
ORDER BY
    avg_velocity DESC
LIMIT 10;

-- Create indexes for performance
CREATE INDEX idx_metrics_team_type_date
    ON metrics (team_id, metric_type, created_at DESC);

-- Use meaningful constraint names
ALTER TABLE team_members
    ADD CONSTRAINT fk_team_members_team_id
    FOREIGN KEY (team_id)
    REFERENCES teams (id)
    ON DELETE CASCADE;
```

## YAML

### Style Guide

For Kubernetes manifests and configuration files:

- 2-space indentation
- No tabs
- Explicit string quotes for special characters
- Comments for complex configurations

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: sei-platform
  labels:
    app: api-service
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
        version: v1.0.0
    spec:
      containers:
      - name: api-service
        image: sei-platform/api-service:latest
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

## Markdown

### Style Guide

For documentation files:

- Use ATX-style headers
- One sentence per line for easy diffs
- Code blocks with language specifiers
- Relative links for internal references

```markdown
# Main Title

## Section Title

This is a paragraph.
It uses one sentence per line.

### Subsection

Code example:

​```python
def example():
    return "Hello, World!"
​```

Links:

- [Internal link](../guide/setup.md)
- [External link](https://example.com)

Lists:

- Item one
- Item two
    - Nested item
    - Another nested item
```

## Configuration Files

### .editorconfig

Use EditorConfig for consistent formatting:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{py,java,go}]
indent_style = space
indent_size = 4

[*.{js,ts,tsx,json,yml,yaml}]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

## Code Review Checklist

Before submitting code, verify:

- [ ] Code follows language-specific style guide
- [ ] Automated formatters have been run
- [ ] Linters pass with no errors
- [ ] Type hints/types are present
- [ ] Documentation is complete
- [ ] Tests are included
- [ ] No hardcoded values or secrets
- [ ] Error handling is appropriate
- [ ] Performance is acceptable
- [ ] Security best practices followed

## Tools Configuration

### Setup Pre-commit Hooks

Install pre-commit hooks to automatically check style:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
        language_version: python3.10

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        args: ["--max-line-length=100"]

  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.0
    hooks:
      - id: prettier
        types_or: [javascript, typescript, tsx, json, yaml]
```

## Additional Resources

- [PEP 8 Style Guide](https://pep8.org/)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Contributing Guidelines](guidelines.md)
- [Pull Request Guide](pull-requests.md)
