# Developers

## Overview

Developers represent individual engineers and contributors in the SEI Platform. Developer entities track personal metrics, code contributions, and team affiliations. Each developer can be associated with multiple teams and have identity mappings to various platforms (GitHub, GitLab, JIRA).

## Endpoints

### List Developers

Retrieve a paginated list of all developers, optionally filtered by team.

```http
GET /api/v1/developers
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| team_id | string (UUID) | - | Filter developers by team ID |
| is_active | boolean | - | Filter by active status |
| skip | integer | 0 | Number of records to skip for pagination |
| limit | integer | 100 | Maximum number of records to return (max: 1000) |
| sort | string | created_at | Field to sort by (name, email, created_at) |
| order | string | desc | Sort order (asc, desc) |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/developers?team_id=770e8400-e29b-41d4-a716-446655440002&is_active=true&skip=0&limit=50" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "990e8400-e29b-41d4-a716-446655440004",
      "team_id": "770e8400-e29b-41d4-a716-446655440002",
      "email": "alice@acme.com",
      "name": "Alice Johnson",
      "github_username": "alicej",
      "gitlab_username": null,
      "jira_username": "alice.johnson",
      "is_active": true,
      "joined_at": "2024-01-05T10:00:00Z",
      "created_at": "2024-01-05T10:00:00Z"
    },
    {
      "id": "aa0e8400-e29b-41d4-a716-446655440005",
      "team_id": "770e8400-e29b-41d4-a716-446655440002",
      "email": "bob@acme.com",
      "name": "Bob Smith",
      "github_username": "bobsmith",
      "gitlab_username": "bob.smith",
      "jira_username": "bsmith",
      "is_active": true,
      "joined_at": "2024-01-08T14:30:00Z",
      "created_at": "2024-01-08T14:30:00Z"
    }
  ],
  "meta": {
    "total": 2,
    "skip": 0,
    "limit": 50,
    "has_more": false,
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

### Get Developer

Retrieve a specific developer by ID.

```http
GET /api/v1/developers/{developer_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| developer_id | string (UUID) | Yes | Developer identifier |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440004",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "email": "alice@acme.com",
    "name": "Alice Johnson",
    "github_username": "alicej",
    "gitlab_username": null,
    "jira_username": "alice.johnson",
    "is_active": true,
    "joined_at": "2024-01-05T10:00:00Z",
    "created_at": "2024-01-05T10:00:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc124"
  }
}
```

### Create Developer

Add a new developer to the SEI Platform.

```http
POST /api/v1/developers
```

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Developer email address (unique) |
| name | string | No | Full name of the developer |
| team_id | string (UUID) | No | Team ID to assign developer to |
| github_username | string | No | GitHub username for identity mapping |
| gitlab_username | string | No | GitLab username for identity mapping |
| jira_username | string | No | JIRA username for identity mapping |

**Request Example**:

```bash
curl -X POST "https://api.sei-platform.com/api/v1/developers" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@acme.com",
    "name": "Alice Johnson",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "github_username": "alicej",
    "jira_username": "alice.johnson"
  }'
```

**Request Body**:

```json
{
  "email": "alice@acme.com",
  "name": "Alice Johnson",
  "team_id": "770e8400-e29b-41d4-a716-446655440002",
  "github_username": "alicej",
  "jira_username": "alice.johnson"
}
```

**Response** (201 Created):

```json
{
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440004",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "email": "alice@acme.com",
    "name": "Alice Johnson",
    "github_username": "alicej",
    "gitlab_username": null,
    "jira_username": "alice.johnson",
    "is_active": true,
    "joined_at": "2024-01-15T10:30:00Z",
    "created_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc125"
  }
}
```

### Update Developer

Update an existing developer's information.

```http
PUT /api/v1/developers/{developer_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| developer_id | string (UUID) | Yes | Developer identifier |

**Request Body** (all fields optional):

| Field | Type | Description |
|-------|------|-------------|
| email | string | Updated email address |
| name | string | Updated full name |
| team_id | string (UUID) | Transfer developer to different team |
| github_username | string | Updated GitHub username |
| gitlab_username | string | Updated GitLab username |
| jira_username | string | Updated JIRA username |
| is_active | boolean | Set developer active/inactive status |

**Request Example**:

```bash
curl -X PUT "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice J. Johnson",
    "gitlab_username": "alice.johnson",
    "is_active": true
  }'
```

**Request Body**:

```json
{
  "name": "Alice J. Johnson",
  "gitlab_username": "alice.johnson",
  "is_active": true
}
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440004",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "email": "alice@acme.com",
    "name": "Alice J. Johnson",
    "github_username": "alicej",
    "gitlab_username": "alice.johnson",
    "jira_username": "alice.johnson",
    "is_active": true,
    "joined_at": "2024-01-05T10:00:00Z",
    "created_at": "2024-01-05T10:00:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T11:45:00Z",
    "request_id": "req_abc126"
  }
}
```

### Delete Developer

Remove a developer from the SEI Platform. This will not delete historical metrics data.

```http
DELETE /api/v1/developers/{developer_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| developer_id | string (UUID) | Yes | Developer identifier |

**Request Example**:

```bash
curl -X DELETE "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "Authorization: Bearer <jwt_token>"
```

**Response** (204 No Content):

```http
HTTP/1.1 204 No Content
```

## Developer Metrics

### Get Developer Metrics

Get performance metrics for a specific developer.

```http
GET /api/v1/developers/{developer_id}/metrics
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
curl -X GET "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004/metrics?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
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
    "commits": {
      "total": 87,
      "lines_added": 3245,
      "lines_removed": 1832,
      "repositories": 5
    },
    "pull_requests": {
      "opened": 12,
      "merged": 11,
      "reviewed": 24,
      "avg_time_to_merge_hours": 16.3
    },
    "code_reviews": {
      "comments_made": 45,
      "avg_response_time_hours": 4.2
    },
    "activity": {
      "active_days": 18,
      "total_days": 31,
      "activity_rate": 0.58
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc127"
  }
}
```

## Error Responses

### 400 Bad Request

**Validation Error**:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": {
      "field": "email",
      "issue": "Email address is required"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc128"
  }
}
```

### 404 Not Found

**Developer Not Found**:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Developer not found"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc129"
  }
}
```

**Team Not Found**:

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
    "request_id": "req_abc130"
  }
}
```

### 409 Conflict

**Duplicate Email**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Developer with this email already exists",
    "details": {
      "field": "email",
      "value": "alice@acme.com"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc131"
  }
}
```

**Duplicate Username**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "GitHub username already assigned to another developer",
    "details": {
      "field": "github_username",
      "value": "alicej"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc132"
  }
}
```

## Data Model

### Developer Object

| Field | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Unique developer identifier |
| team_id | string (UUID) or null | Team this developer belongs to |
| email | string | Developer email address (unique) |
| name | string or null | Full name of the developer |
| github_username | string or null | GitHub username for identity mapping |
| gitlab_username | string or null | GitLab username for identity mapping |
| jira_username | string or null | JIRA username for identity mapping |
| is_active | boolean | Whether developer is currently active |
| joined_at | string (ISO 8601) | Date developer joined the team |
| created_at | string (ISO 8601) | Record creation timestamp |

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

# List developers
def list_developers(team_id=None, is_active=None, skip=0, limit=100):
    params = {"skip": skip, "limit": limit}
    if team_id:
        params["team_id"] = team_id
    if is_active is not None:
        params["is_active"] = is_active

    response = requests.get(
        f"{API_URL}/developers",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get developer
def get_developer(developer_id):
    response = requests.get(
        f"{API_URL}/developers/{developer_id}",
        headers=headers
    )
    response.raise_for_status()
    return response.json()["data"]

# Create developer
def create_developer(
    email,
    name=None,
    team_id=None,
    github_username=None,
    gitlab_username=None,
    jira_username=None
):
    data = {
        "email": email,
        "name": name,
        "team_id": team_id,
        "github_username": github_username,
        "gitlab_username": gitlab_username,
        "jira_username": jira_username
    }
    # Remove None values
    data = {k: v for k, v in data.items() if v is not None}

    response = requests.post(
        f"{API_URL}/developers",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Update developer
def update_developer(developer_id, **kwargs):
    response = requests.put(
        f"{API_URL}/developers/{developer_id}",
        headers=headers,
        json=kwargs
    )
    response.raise_for_status()
    return response.json()["data"]

# Delete developer
def delete_developer(developer_id):
    response = requests.delete(
        f"{API_URL}/developers/{developer_id}",
        headers=headers
    )
    response.raise_for_status()
    return True

# Get developer metrics
def get_developer_metrics(developer_id, start_date=None, end_date=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/developers/{developer_id}/metrics",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Usage examples
if __name__ == "__main__":
    team_id = "770e8400-e29b-41d4-a716-446655440002"

    # Create a new developer
    new_dev = create_developer(
        email="alice@acme.com",
        name="Alice Johnson",
        team_id=team_id,
        github_username="alicej",
        jira_username="alice.johnson"
    )
    print(f"Created developer: {new_dev['id']}")

    # List developers for team
    developers = list_developers(team_id=team_id, is_active=True)
    print(f"Found {len(developers)} active developers")

    # Get developer metrics
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)
    metrics = get_developer_metrics(
        new_dev["id"],
        start_date=start_date,
        end_date=end_date
    )
    print(f"Developer metrics: {metrics['commits']['total']} commits")

    # Update developer
    updated_dev = update_developer(
        new_dev["id"],
        name="Alice J. Johnson",
        gitlab_username="alice.johnson"
    )
    print(f"Updated developer: {updated_dev['name']}")
```

### JavaScript/TypeScript

```typescript
const API_URL = 'https://api.sei-platform.com/api/v1';
const API_KEY = process.env.SEI_API_KEY;

interface Developer {
  id: string;
  team_id?: string;
  email: string;
  name?: string;
  github_username?: string;
  gitlab_username?: string;
  jira_username?: string;
  is_active: boolean;
  joined_at: string;
  created_at: string;
}

interface CreateDeveloperRequest {
  email: string;
  name?: string;
  team_id?: string;
  github_username?: string;
  gitlab_username?: string;
  jira_username?: string;
}

interface UpdateDeveloperRequest {
  email?: string;
  name?: string;
  team_id?: string;
  github_username?: string;
  gitlab_username?: string;
  jira_username?: string;
  is_active?: boolean;
}

interface DeveloperMetrics {
  developer_id: string;
  period: {
    start: string;
    end: string;
  };
  commits: {
    total: number;
    lines_added: number;
    lines_removed: number;
    repositories: number;
  };
  pull_requests: {
    opened: number;
    merged: number;
    reviewed: number;
    avg_time_to_merge_hours: number;
  };
  code_reviews: {
    comments_made: number;
    avg_response_time_hours: number;
  };
  activity: {
    active_days: number;
    total_days: number;
    activity_rate: number;
  };
}

class DevelopersAPI {
  private headers: HeadersInit;

  constructor(apiKey: string) {
    this.headers = {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    };
  }

  async listDevelopers(
    teamId?: string,
    isActive?: boolean,
    skip = 0,
    limit = 100
  ): Promise<Developer[]> {
    const url = new URL(`${API_URL}/developers`);
    if (teamId) url.searchParams.set('team_id', teamId);
    if (isActive !== undefined) url.searchParams.set('is_active', isActive.toString());
    url.searchParams.set('skip', skip.toString());
    url.searchParams.set('limit', limit.toString());

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

  async getDeveloper(developerId: string): Promise<Developer> {
    const response = await fetch(`${API_URL}/developers/${developerId}`, {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async createDeveloper(request: CreateDeveloperRequest): Promise<Developer> {
    const response = await fetch(`${API_URL}/developers`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify(request)
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async updateDeveloper(
    developerId: string,
    request: UpdateDeveloperRequest
  ): Promise<Developer> {
    const response = await fetch(`${API_URL}/developers/${developerId}`, {
      method: 'PUT',
      headers: this.headers,
      body: JSON.stringify(request)
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async deleteDeveloper(developerId: string): Promise<void> {
    const response = await fetch(`${API_URL}/developers/${developerId}`, {
      method: 'DELETE',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }
  }

  async getDeveloperMetrics(
    developerId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<DeveloperMetrics> {
    const url = new URL(`${API_URL}/developers/${developerId}/metrics`);
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
  const api = new DevelopersAPI(API_KEY!);
  const teamId = '770e8400-e29b-41d4-a716-446655440002';

  // Create developer
  const newDev = await api.createDeveloper({
    email: 'alice@acme.com',
    name: 'Alice Johnson',
    team_id: teamId,
    github_username: 'alicej',
    jira_username: 'alice.johnson'
  });
  console.log(`Created developer: ${newDev.id}`);

  // List developers
  const developers = await api.listDevelopers(teamId, true);
  console.log(`Found ${developers.length} active developers`);

  // Get developer metrics
  const endDate = new Date();
  const startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);
  const metrics = await api.getDeveloperMetrics(newDev.id, startDate, endDate);
  console.log(`Developer has ${metrics.commits.total} commits`);

  // Update developer
  const updatedDev = await api.updateDeveloper(newDev.id, {
    name: 'Alice J. Johnson',
    gitlab_username: 'alice.johnson'
  });
  console.log(`Updated developer: ${updatedDev.name}`);
}
```

### cURL

```bash
# List developers
curl -X GET "https://api.sei-platform.com/api/v1/developers?team_id=770e8400-e29b-41d4-a716-446655440002&is_active=true" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get developer
curl -X GET "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Create developer
curl -X POST "https://api.sei-platform.com/api/v1/developers" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@acme.com",
    "name": "Alice Johnson",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "github_username": "alicej",
    "jira_username": "alice.johnson"
  }'

# Update developer
curl -X PUT "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice J. Johnson",
    "gitlab_username": "alice.johnson",
    "is_active": true
  }'

# Delete developer
curl -X DELETE "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004" \
  -H "X-API-Key: sei_live_..."

# Get developer metrics
curl -X GET "https://api.sei-platform.com/api/v1/developers/990e8400-e29b-41d4-a716-446655440004/metrics?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"
```

## Best Practices

### Identity Mapping

1. Link all relevant platform usernames (GitHub, GitLab, JIRA) to each developer
2. Verify username mappings to ensure accurate attribution
3. Update mappings promptly when developers change usernames
4. Use consistent username formats across platforms

### Email Management

1. Use corporate email addresses for accurate identity management
2. Keep email addresses up to date when developers change
3. Ensure email uniqueness across the platform
4. Handle email changes carefully to maintain historical data

### Team Assignment

1. Assign developers to their primary team
2. Update team assignments when developers change roles
3. Use is_active flag for developers who leave the organization
4. Consider maintaining inactive developers for historical metrics

### Privacy Considerations

1. Only collect necessary developer information
2. Respect privacy settings for individual metrics
3. Anonymize data when sharing aggregate metrics
4. Follow GDPR and other privacy regulations

## Rate Limiting

Developer endpoints are subject to the standard rate limits:

- 1000 requests per hour per API key
- 100 requests per minute (burst limit)

See [Authentication](authentication.md) for details on rate limit headers and handling.

## Next Steps

- [Teams API](teams.md) - Manage teams that developers belong to
- [Repositories API](repositories.md) - View repositories developers contribute to
- [Analytics API](analytics.md) - View detailed developer metrics
- [Organizations API](organizations.md) - Manage parent organizations