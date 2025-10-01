# Analytics

## Overview

The Analytics API provides access to software engineering metrics and insights in the SEI Platform. This includes DORA metrics, team performance indicators, repository statistics, and developer productivity data. Analytics data is calculated from historical events and aggregated in TimescaleDB for efficient time-series queries.

## Endpoints

### Get DORA Metrics

Retrieve DORA (DevOps Research and Assessment) metrics for a team or repository.

```http
GET /api/v1/analytics/dora/{team_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| start_date | string (ISO 8601) | 30 days ago | Start date for metrics calculation |
| end_date | string (ISO 8601) | now | End date for metrics calculation |
| repository_id | string (UUID) | - | Filter by specific repository |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/dora/770e8400-e29b-41d4-a716-446655440002?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "deployment_frequency": {
      "value": 2.5,
      "unit": "per_day",
      "rating": "elite",
      "trend": "increasing"
    },
    "lead_time_for_changes": {
      "value": 18.3,
      "unit": "hours",
      "rating": "elite",
      "trend": "decreasing"
    },
    "change_failure_rate": {
      "value": 0.12,
      "unit": "percentage",
      "rating": "elite",
      "trend": "stable"
    },
    "time_to_restore_service": {
      "value": 2.1,
      "unit": "hours",
      "rating": "elite",
      "trend": "decreasing"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

### Get Team Metrics

Get comprehensive performance metrics for a team.

```http
GET /api/v1/analytics/team/{team_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| start_date | string (ISO 8601) | 30 days ago | Start date for metrics |
| end_date | string (ISO 8601) | now | End date for metrics |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/team/770e8400-e29b-41d4-a716-446655440002?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "velocity": {
      "story_points_completed": 145,
      "stories_completed": 23,
      "avg_velocity_per_sprint": 72.5
    },
    "cycle_time": {
      "avg_hours": 42.3,
      "median_hours": 38.5,
      "p95_hours": 96.2
    },
    "code_quality": {
      "pr_review_coverage": 0.98,
      "avg_review_comments": 4.2,
      "code_churn_rate": 0.15
    },
    "activity": {
      "commits": 342,
      "pull_requests": 67,
      "code_reviews": 145,
      "deployments": 78
    },
    "team_health": {
      "member_count": 8,
      "active_members": 8,
      "avg_utilization": 0.82
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc124"
  }
}
```

### Get Repository Analytics

Get analytics for a specific repository.

```http
GET /api/v1/analytics/repository/{repository_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository_id | string (UUID) | Yes | Repository identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| start_date | string (ISO 8601) | 30 days ago | Start date for metrics |
| end_date | string (ISO 8601) | now | End date for metrics |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/repository/bb0e8400-e29b-41d4-a716-446655440006?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "repository_id": "bb0e8400-e29b-41d4-a716-446655440006",
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "commits": {
      "total": 156,
      "avg_per_day": 5.0,
      "lines_added": 8432,
      "lines_removed": 4231,
      "unique_authors": 8
    },
    "pull_requests": {
      "opened": 34,
      "merged": 31,
      "closed_without_merge": 2,
      "avg_time_to_merge_hours": 16.8,
      "median_time_to_merge_hours": 12.5
    },
    "code_reviews": {
      "total_reviews": 87,
      "avg_reviews_per_pr": 2.8,
      "avg_comments_per_pr": 5.2,
      "avg_response_time_hours": 4.1
    },
    "deployments": {
      "total": 28,
      "successful": 26,
      "failed": 2,
      "avg_per_day": 0.9
    },
    "health": {
      "test_coverage": 0.78,
      "build_success_rate": 0.93,
      "deployment_success_rate": 0.93
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc125"
  }
}
```

### Get Developer Analytics

Get performance metrics for a specific developer.

```http
GET /api/v1/analytics/developer/{developer_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| developer_id | string (UUID) | Yes | Developer identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| start_date | string (ISO 8601) | 30 days ago | Start date for metrics |
| end_date | string (ISO 8601) | now | End date for metrics |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/developer/990e8400-e29b-41d4-a716-446655440004?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "developer_id": "990e8400-e29b-41d4-a716-446655440004",
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "contributions": {
      "commits": 87,
      "pull_requests_opened": 12,
      "pull_requests_merged": 11,
      "code_reviews_given": 24,
      "lines_added": 3245,
      "lines_removed": 1832
    },
    "quality": {
      "pr_acceptance_rate": 0.92,
      "avg_pr_size_lines": 245,
      "code_review_participation": 0.85,
      "avg_comments_per_review": 3.8
    },
    "velocity": {
      "avg_cycle_time_hours": 38.2,
      "avg_commits_per_day": 2.8,
      "active_days": 18,
      "activity_rate": 0.58
    },
    "collaboration": {
      "repositories_contributed": 5,
      "teammates_collaborated": 7,
      "avg_review_response_time_hours": 4.2
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc126"
  }
}
```

### Get Deployment Metrics

Get deployment frequency and success metrics.

```http
GET /api/v1/analytics/deployments
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| team_id | string (UUID) | - | Filter by team |
| repository_id | string (UUID) | - | Filter by repository |
| environment | string | - | Filter by environment (production, staging, etc.) |
| start_date | string (ISO 8601) | 30 days ago | Start date for metrics |
| end_date | string (ISO 8601) | now | End date for metrics |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/deployments?team_id=770e8400-e29b-41d4-a716-446655440002&environment=production&start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "filters": {
      "team_id": "770e8400-e29b-41d4-a716-446655440002",
      "environment": "production"
    },
    "summary": {
      "total_deployments": 78,
      "successful_deployments": 74,
      "failed_deployments": 4,
      "success_rate": 0.95,
      "avg_per_day": 2.5
    },
    "frequency": {
      "daily_avg": 2.5,
      "weekly_avg": 17.5,
      "rating": "elite"
    },
    "duration": {
      "avg_minutes": 8.3,
      "median_minutes": 7.2,
      "p95_minutes": 15.6
    },
    "by_repository": [
      {
        "repository_id": "bb0e8400-e29b-41d4-a716-446655440006",
        "repository_name": "api-service",
        "deployments": 45,
        "success_rate": 0.96
      },
      {
        "repository_id": "cc0e8400-e29b-41d4-a716-446655440007",
        "repository_name": "web-frontend",
        "deployments": 33,
        "success_rate": 0.94
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc127"
  }
}
```

### Get Trend Data

Get time-series trend data for metrics over a period.

```http
GET /api/v1/analytics/trends
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| metric | string | - | Metric type (deployment_frequency, lead_time, cycle_time, etc.) |
| team_id | string (UUID) | - | Filter by team |
| repository_id | string (UUID) | - | Filter by repository |
| granularity | string | daily | Time granularity (hourly, daily, weekly, monthly) |
| start_date | string (ISO 8601) | 30 days ago | Start date |
| end_date | string (ISO 8601) | now | End date |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/analytics/trends?metric=deployment_frequency&team_id=770e8400-e29b-41d4-a716-446655440002&granularity=daily&start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "metric": "deployment_frequency",
    "granularity": "daily",
    "period": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z"
    },
    "data_points": [
      {
        "timestamp": "2024-01-01T00:00:00Z",
        "value": 2.0
      },
      {
        "timestamp": "2024-01-02T00:00:00Z",
        "value": 3.0
      },
      {
        "timestamp": "2024-01-03T00:00:00Z",
        "value": 2.0
      }
    ],
    "statistics": {
      "min": 0.0,
      "max": 5.0,
      "avg": 2.5,
      "median": 2.0
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc128"
  }
}
```

## Error Responses

### 400 Bad Request

**Invalid Date Range**:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid date range",
    "details": {
      "issue": "start_date must be before end_date"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc129"
  }
}
```

**Invalid Metric Type**:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid metric type",
    "details": {
      "field": "metric",
      "issue": "Must be one of: deployment_frequency, lead_time, cycle_time, change_failure_rate"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc130"
  }
}
```

### 404 Not Found

**Resource Not Found**:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Team not found",
    "details": {
      "team_id": "770e8400-e29b-41d4-a716-446655440002"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc131"
  }
}
```

### 422 Unprocessable Entity

**Insufficient Data**:

```json
{
  "error": {
    "code": "INSUFFICIENT_DATA",
    "message": "Not enough data to calculate metrics",
    "details": {
      "reason": "No deployments found in specified period",
      "minimum_required": 3
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc132"
  }
}
```

## Data Model

### DORA Metrics Ratings

DORA metrics are rated according to the DevOps Research and Assessment benchmarks:

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deployment Frequency | Multiple per day | Weekly to monthly | Monthly to biannually | Less than biannually |
| Lead Time for Changes | < 1 hour | 1 day to 1 week | 1 week to 1 month | > 1 month |
| Change Failure Rate | < 15% | 16-30% | 31-45% | > 45% |
| Time to Restore Service | < 1 hour | < 1 day | 1 day to 1 week | > 1 week |

### Metric Types

Available metrics for trend analysis:

- `deployment_frequency` - Number of deployments per time period
- `lead_time` - Time from commit to production deployment
- `cycle_time` - Time from start to completion of work items
- `change_failure_rate` - Percentage of deployments causing failures
- `mttr` - Mean time to restore service
- `pr_merge_time` - Time to merge pull requests
- `code_review_time` - Time to complete code reviews

### Granularity Options

Time granularity for trend data:

- `hourly` - Data points every hour
- `daily` - Data points every day
- `weekly` - Data points every week
- `monthly` - Data points every month

## Code Examples

### Python

```python
import requests
import os
from datetime import datetime, timedelta

API_URL = "https://api.sei-platform.com/api/v1"
API_KEY = os.getenv("SEI_API_KEY")

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

# Get DORA metrics
def get_dora_metrics(team_id, start_date=None, end_date=None, repository_id=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()
    if repository_id:
        params["repository_id"] = repository_id

    response = requests.get(
        f"{API_URL}/analytics/dora/{team_id}",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get team metrics
def get_team_metrics(team_id, start_date=None, end_date=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/analytics/team/{team_id}",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get repository analytics
def get_repository_analytics(repository_id, start_date=None, end_date=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/analytics/repository/{repository_id}",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get developer analytics
def get_developer_analytics(developer_id, start_date=None, end_date=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/analytics/developer/{developer_id}",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get deployment metrics
def get_deployment_metrics(
    team_id=None,
    repository_id=None,
    environment=None,
    start_date=None,
    end_date=None
):
    params = {}
    if team_id:
        params["team_id"] = team_id
    if repository_id:
        params["repository_id"] = repository_id
    if environment:
        params["environment"] = environment
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/analytics/deployments",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get trend data
def get_trend_data(
    metric,
    team_id=None,
    repository_id=None,
    granularity="daily",
    start_date=None,
    end_date=None
):
    params = {"metric": metric, "granularity": granularity}
    if team_id:
        params["team_id"] = team_id
    if repository_id:
        params["repository_id"] = repository_id
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/analytics/trends",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Usage examples
if __name__ == "__main__":
    team_id = "770e8400-e29b-41d4-a716-446655440002"
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)

    # Get DORA metrics for team
    dora = get_dora_metrics(team_id, start_date, end_date)
    print(f"Deployment Frequency: {dora['deployment_frequency']['value']} {dora['deployment_frequency']['unit']}")
    print(f"Rating: {dora['deployment_frequency']['rating']}")

    # Get team metrics
    team_metrics = get_team_metrics(team_id, start_date, end_date)
    print(f"Team Velocity: {team_metrics['velocity']['story_points_completed']} points")

    # Get deployment trends
    trends = get_trend_data(
        metric="deployment_frequency",
        team_id=team_id,
        granularity="daily",
        start_date=start_date,
        end_date=end_date
    )
    print(f"Average deployment frequency: {trends['statistics']['avg']}")
```

### JavaScript/TypeScript

```typescript
const API_URL = 'https://api.sei-platform.com/api/v1';
const API_KEY = process.env.SEI_API_KEY;

interface DORAMetrics {
  team_id: string;
  period: {
    start: string;
    end: string;
  };
  deployment_frequency: MetricValue;
  lead_time_for_changes: MetricValue;
  change_failure_rate: MetricValue;
  time_to_restore_service: MetricValue;
}

interface MetricValue {
  value: number;
  unit: string;
  rating: 'elite' | 'high' | 'medium' | 'low';
  trend: 'increasing' | 'decreasing' | 'stable';
}

interface TrendData {
  metric: string;
  granularity: string;
  period: {
    start: string;
    end: string;
  };
  data_points: Array<{
    timestamp: string;
    value: number;
  }>;
  statistics: {
    min: number;
    max: number;
    avg: number;
    median: number;
  };
}

class AnalyticsAPI {
  private headers: HeadersInit;

  constructor(apiKey: string) {
    this.headers = {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    };
  }

  async getDORAMetrics(
    teamId: string,
    startDate?: Date,
    endDate?: Date,
    repositoryId?: string
  ): Promise<DORAMetrics> {
    const url = new URL(`${API_URL}/analytics/dora/${teamId}`);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());
    if (repositoryId) url.searchParams.set('repository_id', repositoryId);

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async getTeamMetrics(
    teamId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<any> {
    const url = new URL(`${API_URL}/analytics/team/${teamId}`);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async getRepositoryAnalytics(
    repositoryId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<any> {
    const url = new URL(`${API_URL}/analytics/repository/${repositoryId}`);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async getDeveloperAnalytics(
    developerId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<any> {
    const url = new URL(`${API_URL}/analytics/developer/${developerId}`);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async getDeploymentMetrics(
    teamId?: string,
    repositoryId?: string,
    environment?: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<any> {
    const url = new URL(`${API_URL}/analytics/deployments`);
    if (teamId) url.searchParams.set('team_id', teamId);
    if (repositoryId) url.searchParams.set('repository_id', repositoryId);
    if (environment) url.searchParams.set('environment', environment);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async getTrendData(
    metric: string,
    teamId?: string,
    repositoryId?: string,
    granularity: string = 'daily',
    startDate?: Date,
    endDate?: Date
  ): Promise<TrendData> {
    const url = new URL(`${API_URL}/analytics/trends`);
    url.searchParams.set('metric', metric);
    url.searchParams.set('granularity', granularity);
    if (teamId) url.searchParams.set('team_id', teamId);
    if (repositoryId) url.searchParams.set('repository_id', repositoryId);
    if (startDate) url.searchParams.set('start_date', startDate.toISOString());
    if (endDate) url.searchParams.set('end_date', endDate.toISOString());

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }
}

// Usage examples
async function main() {
  const api = new AnalyticsAPI(API_KEY!);
  const teamId = '770e8400-e29b-41d4-a716-446655440002';
  const endDate = new Date();
  const startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);

  // Get DORA metrics
  const dora = await api.getDORAMetrics(teamId, startDate, endDate);
  console.log(`Deployment Frequency: ${dora.deployment_frequency.value} ${dora.deployment_frequency.unit}`);
  console.log(`Rating: ${dora.deployment_frequency.rating}`);

  // Get team metrics
  const teamMetrics = await api.getTeamMetrics(teamId, startDate, endDate);
  console.log(`Team Velocity: ${teamMetrics.velocity.story_points_completed} points`);

  // Get deployment trends
  const trends = await api.getTrendData(
    'deployment_frequency',
    teamId,
    undefined,
    'daily',
    startDate,
    endDate
  );
  console.log(`Average deployment frequency: ${trends.statistics.avg}`);
}
```

### cURL

```bash
# Get DORA metrics
curl -X GET "https://api.sei-platform.com/api/v1/analytics/dora/770e8400-e29b-41d4-a716-446655440002?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get team metrics
curl -X GET "https://api.sei-platform.com/api/v1/analytics/team/770e8400-e29b-41d4-a716-446655440002?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get repository analytics
curl -X GET "https://api.sei-platform.com/api/v1/analytics/repository/bb0e8400-e29b-41d4-a716-446655440006?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get developer analytics
curl -X GET "https://api.sei-platform.com/api/v1/analytics/developer/990e8400-e29b-41d4-a716-446655440004?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get deployment metrics
curl -X GET "https://api.sei-platform.com/api/v1/analytics/deployments?team_id=770e8400-e29b-41d4-a716-446655440002&environment=production&start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get trend data
curl -X GET "https://api.sei-platform.com/api/v1/analytics/trends?metric=deployment_frequency&team_id=770e8400-e29b-41d4-a716-446655440002&granularity=daily&start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"
```

## Best Practices

### Date Range Selection

1. Use appropriate date ranges for metrics calculation
2. Align date ranges with sprint cycles or reporting periods
3. Consider data freshness and calculation costs for large ranges
4. Use consistent time zones (UTC recommended) across all requests

### Metric Interpretation

1. Always consider rating context when interpreting metrics
2. Focus on trends rather than absolute values
3. Compare metrics against baselines and industry benchmarks
4. Account for team size and project complexity

### Performance Optimization

1. Cache analytics results for frequently accessed metrics
2. Use appropriate granularity for trend data
3. Filter by specific entities to reduce calculation time
4. Schedule heavy analytics queries during off-peak hours

### Data Quality

1. Ensure complete data collection from all platforms
2. Validate identity mappings for accurate attribution
3. Handle missing data gracefully in calculations
4. Monitor data pipeline health and freshness

## Rate Limiting

Analytics endpoints are subject to more restrictive rate limits due to computational costs:

- 100 requests per hour per API key
- 10 requests per minute (burst limit)

See [Authentication](authentication.md) for details on rate limit headers and handling.

## Next Steps

- [Teams API](teams.md) - Manage teams for metrics calculation
- [Repositories API](repositories.md) - Configure repositories for tracking
- [Developers API](developers.md) - Manage developer identity mappings
- [Organizations API](organizations.md) - View organization-level metrics