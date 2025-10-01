# Repositories

## Overview

Repositories represent code repositories from various source control platforms (GitHub, GitLab, Bitbucket) in the SEI Platform. Repository entities track code commits, pull requests, deployments, and other software engineering metrics. Each repository belongs to a team and organization.

## Endpoints

### List Repositories

Retrieve a paginated list of all repositories, optionally filtered by team or platform.

```http
GET /api/v1/repositories
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| team_id | string (UUID) | - | Filter repositories by team ID |
| platform | string | - | Filter by platform (github, gitlab, bitbucket) |
| is_active | boolean | - | Filter by active status |
| skip | integer | 0 | Number of records to skip for pagination |
| limit | integer | 100 | Maximum number of records to return (max: 1000) |
| sort | string | created_at | Field to sort by (name, created_at, updated_at) |
| order | string | desc | Sort order (asc, desc) |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/repositories?team_id=770e8400-e29b-41d4-a716-446655440002&platform=github&skip=0&limit=50" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "bb0e8400-e29b-41d4-a716-446655440006",
      "team_id": "770e8400-e29b-41d4-a716-446655440002",
      "name": "api-service",
      "platform": "github",
      "external_id": "12345678",
      "url": "https://github.com/acme-corp/api-service",
      "default_branch": "main",
      "is_private": true,
      "is_active": true,
      "created_at": "2024-01-05T10:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": "cc0e8400-e29b-41d4-a716-446655440007",
      "team_id": "770e8400-e29b-41d4-a716-446655440002",
      "name": "web-frontend",
      "platform": "github",
      "external_id": "23456789",
      "url": "https://github.com/acme-corp/web-frontend",
      "default_branch": "main",
      "is_private": false,
      "is_active": true,
      "created_at": "2024-01-08T14:30:00Z",
      "updated_at": "2024-01-12T09:15:00Z"
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

### Get Repository

Retrieve a specific repository by ID.

```http
GET /api/v1/repositories/{repository_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository_id | string (UUID) | Yes | Repository identifier |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "bb0e8400-e29b-41d4-a716-446655440006",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "api-service",
    "platform": "github",
    "external_id": "12345678",
    "url": "https://github.com/acme-corp/api-service",
    "default_branch": "main",
    "is_private": true,
    "is_active": true,
    "created_at": "2024-01-05T10:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc124"
  }
}
```

### Create Repository

Add a new repository to track in the SEI Platform.

```http
POST /api/v1/repositories
```

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team ID this repository belongs to |
| name | string | Yes | Repository name (e.g., "api-service") |
| platform | string | Yes | Source control platform (github, gitlab, bitbucket) |
| external_id | string | Yes | Platform-specific repository ID |
| url | string | No | Full URL to repository |
| default_branch | string | No | Default branch name (default: "main") |
| is_private | boolean | No | Whether repository is private (default: false) |
| is_active | boolean | No | Whether to actively track metrics (default: true) |

**Request Example**:

```bash
curl -X POST "https://api.sei-platform.com/api/v1/repositories" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "api-service",
    "platform": "github",
    "external_id": "12345678",
    "url": "https://github.com/acme-corp/api-service",
    "default_branch": "main",
    "is_private": true,
    "is_active": true
  }'
```

**Request Body**:

```json
{
  "team_id": "770e8400-e29b-41d4-a716-446655440002",
  "name": "api-service",
  "platform": "github",
  "external_id": "12345678",
  "url": "https://github.com/acme-corp/api-service",
  "default_branch": "main",
  "is_private": true,
  "is_active": true
}
```

**Response** (201 Created):

```json
{
  "data": {
    "id": "bb0e8400-e29b-41d4-a716-446655440006",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "api-service",
    "platform": "github",
    "external_id": "12345678",
    "url": "https://github.com/acme-corp/api-service",
    "default_branch": "main",
    "is_private": true,
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc125"
  }
}
```

### Update Repository

Update an existing repository.

```http
PUT /api/v1/repositories/{repository_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository_id | string (UUID) | Yes | Repository identifier |

**Request Body** (all fields optional):

| Field | Type | Description |
|-------|------|-------------|
| team_id | string (UUID) | Transfer repository to different team |
| name | string | Updated repository name |
| default_branch | string | Updated default branch |
| url | string | Updated repository URL |
| is_private | boolean | Updated privacy status |
| is_active | boolean | Enable or disable metric tracking |

**Request Example**:

```bash
curl -X PUT "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "default_branch": "develop",
    "is_active": true
  }'
```

**Request Body**:

```json
{
  "default_branch": "develop",
  "is_active": true
}
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "bb0e8400-e29b-41d4-a716-446655440006",
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "api-service",
    "platform": "github",
    "external_id": "12345678",
    "url": "https://github.com/acme-corp/api-service",
    "default_branch": "develop",
    "is_private": true,
    "is_active": true,
    "created_at": "2024-01-05T10:00:00Z",
    "updated_at": "2024-01-15T11:45:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T11:45:00Z",
    "request_id": "req_abc126"
  }
}
```

### Delete Repository

Remove a repository from tracking. This will stop collecting metrics but will not delete historical data.

```http
DELETE /api/v1/repositories/{repository_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository_id | string (UUID) | Yes | Repository identifier |

**Request Example**:

```bash
curl -X DELETE "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "Authorization: Bearer <jwt_token>"
```

**Response** (204 No Content):

```http
HTTP/1.1 204 No Content
```

## Repository Statistics

### Get Repository Stats

Get aggregated statistics for a repository.

```http
GET /api/v1/repositories/{repository_id}/stats
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository_id | string (UUID) | Yes | Repository identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| start_date | string (ISO 8601) | 30 days ago | Start date for statistics |
| end_date | string (ISO 8601) | now | End date for statistics |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006/stats?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
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
      "total": 342,
      "by_author": 12
    },
    "pull_requests": {
      "opened": 45,
      "merged": 40,
      "closed": 3,
      "avg_time_to_merge_hours": 18.5
    },
    "deployments": {
      "total": 28,
      "successful": 26,
      "failed": 2
    },
    "contributors": {
      "active": 8,
      "total": 12
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
      "field": "platform",
      "issue": "Platform must be one of: github, gitlab, bitbucket"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc128"
  }
}
```

### 404 Not Found

**Repository Not Found**:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Repository not found"
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

**Duplicate Repository**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Repository already exists",
    "details": {
      "field": "external_id",
      "value": "12345678",
      "platform": "github"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc131"
  }
}
```

## Data Model

### Repository Object

| Field | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Unique repository identifier |
| team_id | string (UUID) | Team this repository belongs to |
| name | string | Repository name |
| platform | string | Source control platform (github, gitlab, bitbucket) |
| external_id | string | Platform-specific repository ID |
| url | string or null | Full URL to repository |
| default_branch | string | Default branch name (e.g., "main", "master") |
| is_private | boolean | Whether repository is private |
| is_active | boolean | Whether metrics are actively tracked |
| created_at | string (ISO 8601) | Creation timestamp |
| updated_at | string (ISO 8601) | Last update timestamp |

### Platform Values

Supported platform values:

- `github` - GitHub repositories
- `gitlab` - GitLab repositories
- `bitbucket` - Bitbucket repositories

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

# List repositories
def list_repositories(team_id=None, platform=None, is_active=None, skip=0, limit=100):
    params = {"skip": skip, "limit": limit}
    if team_id:
        params["team_id"] = team_id
    if platform:
        params["platform"] = platform
    if is_active is not None:
        params["is_active"] = is_active

    response = requests.get(
        f"{API_URL}/repositories",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get repository
def get_repository(repository_id):
    response = requests.get(
        f"{API_URL}/repositories/{repository_id}",
        headers=headers
    )
    response.raise_for_status()
    return response.json()["data"]

# Create repository
def create_repository(
    team_id,
    name,
    platform,
    external_id,
    url=None,
    default_branch="main",
    is_private=False,
    is_active=True
):
    data = {
        "team_id": team_id,
        "name": name,
        "platform": platform,
        "external_id": external_id,
        "url": url,
        "default_branch": default_branch,
        "is_private": is_private,
        "is_active": is_active
    }
    response = requests.post(
        f"{API_URL}/repositories",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Update repository
def update_repository(repository_id, **kwargs):
    response = requests.put(
        f"{API_URL}/repositories/{repository_id}",
        headers=headers,
        json=kwargs
    )
    response.raise_for_status()
    return response.json()["data"]

# Delete repository
def delete_repository(repository_id):
    response = requests.delete(
        f"{API_URL}/repositories/{repository_id}",
        headers=headers
    )
    response.raise_for_status()
    return True

# Get repository stats
def get_repository_stats(repository_id, start_date=None, end_date=None):
    params = {}
    if start_date:
        params["start_date"] = start_date.isoformat()
    if end_date:
        params["end_date"] = end_date.isoformat()

    response = requests.get(
        f"{API_URL}/repositories/{repository_id}/stats",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Usage examples
if __name__ == "__main__":
    team_id = "770e8400-e29b-41d4-a716-446655440002"

    # Create a new repository
    new_repo = create_repository(
        team_id=team_id,
        name="api-service",
        platform="github",
        external_id="12345678",
        url="https://github.com/acme-corp/api-service",
        default_branch="main",
        is_private=True
    )
    print(f"Created repository: {new_repo['id']}")

    # List repositories for team
    repos = list_repositories(team_id=team_id, platform="github")
    print(f"Found {len(repos)} GitHub repositories")

    # Get repository stats
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)
    stats = get_repository_stats(
        new_repo["id"],
        start_date=start_date,
        end_date=end_date
    )
    print(f"Repository stats: {stats['commits']['total']} commits")

    # Update repository
    updated_repo = update_repository(
        new_repo["id"],
        default_branch="develop",
        is_active=True
    )
    print(f"Updated repository: {updated_repo['name']}")
```

### JavaScript/TypeScript

```typescript
const API_URL = 'https://api.sei-platform.com/api/v1';
const API_KEY = process.env.SEI_API_KEY;

interface Repository {
  id: string;
  team_id: string;
  name: string;
  platform: 'github' | 'gitlab' | 'bitbucket';
  external_id: string;
  url?: string;
  default_branch: string;
  is_private: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

interface CreateRepositoryRequest {
  team_id: string;
  name: string;
  platform: 'github' | 'gitlab' | 'bitbucket';
  external_id: string;
  url?: string;
  default_branch?: string;
  is_private?: boolean;
  is_active?: boolean;
}

interface UpdateRepositoryRequest {
  team_id?: string;
  name?: string;
  default_branch?: string;
  url?: string;
  is_private?: boolean;
  is_active?: boolean;
}

interface RepositoryStats {
  repository_id: string;
  period: {
    start: string;
    end: string;
  };
  commits: {
    total: number;
    by_author: number;
  };
  pull_requests: {
    opened: number;
    merged: number;
    closed: number;
    avg_time_to_merge_hours: number;
  };
  deployments: {
    total: number;
    successful: number;
    failed: number;
  };
  contributors: {
    active: number;
    total: number;
  };
}

class RepositoriesAPI {
  private headers: HeadersInit;

  constructor(apiKey: string) {
    this.headers = {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    };
  }

  async listRepositories(
    teamId?: string,
    platform?: string,
    isActive?: boolean,
    skip = 0,
    limit = 100
  ): Promise<Repository[]> {
    const url = new URL(`${API_URL}/repositories`);
    if (teamId) url.searchParams.set('team_id', teamId);
    if (platform) url.searchParams.set('platform', platform);
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

  async getRepository(repositoryId: string): Promise<Repository> {
    const response = await fetch(`${API_URL}/repositories/${repositoryId}`, {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async createRepository(request: CreateRepositoryRequest): Promise<Repository> {
    const response = await fetch(`${API_URL}/repositories`, {
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

  async updateRepository(
    repositoryId: string,
    request: UpdateRepositoryRequest
  ): Promise<Repository> {
    const response = await fetch(`${API_URL}/repositories/${repositoryId}`, {
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

  async deleteRepository(repositoryId: string): Promise<void> {
    const response = await fetch(`${API_URL}/repositories/${repositoryId}`, {
      method: 'DELETE',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }
  }

  async getRepositoryStats(
    repositoryId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<RepositoryStats> {
    const url = new URL(`${API_URL}/repositories/${repositoryId}/stats`);
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
  const api = new RepositoriesAPI(API_KEY!);
  const teamId = '770e8400-e29b-41d4-a716-446655440002';

  // Create repository
  const newRepo = await api.createRepository({
    team_id: teamId,
    name: 'api-service',
    platform: 'github',
    external_id: '12345678',
    url: 'https://github.com/acme-corp/api-service',
    default_branch: 'main',
    is_private: true
  });
  console.log(`Created repository: ${newRepo.id}`);

  // List repositories
  const repos = await api.listRepositories(teamId, 'github');
  console.log(`Found ${repos.length} GitHub repositories`);

  // Get repository stats
  const endDate = new Date();
  const startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);
  const stats = await api.getRepositoryStats(newRepo.id, startDate, endDate);
  console.log(`Repository has ${stats.commits.total} commits`);

  // Update repository
  const updatedRepo = await api.updateRepository(newRepo.id, {
    default_branch: 'develop'
  });
  console.log(`Updated repository: ${updatedRepo.name}`);
}
```

### cURL

```bash
# List repositories
curl -X GET "https://api.sei-platform.com/api/v1/repositories?team_id=770e8400-e29b-41d4-a716-446655440002&platform=github" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get repository
curl -X GET "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Create repository
curl -X POST "https://api.sei-platform.com/api/v1/repositories" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "name": "api-service",
    "platform": "github",
    "external_id": "12345678",
    "url": "https://github.com/acme-corp/api-service",
    "default_branch": "main",
    "is_private": true,
    "is_active": true
  }'

# Update repository
curl -X PUT "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "default_branch": "develop",
    "is_active": true
  }'

# Delete repository
curl -X DELETE "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006" \
  -H "X-API-Key: sei_live_..."

# Get repository stats
curl -X GET "https://api.sei-platform.com/api/v1/repositories/bb0e8400-e29b-41d4-a716-446655440006/stats?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"
```

## Best Practices

### Repository Setup

1. Use the platform's repository ID as the external_id
2. Keep repository names consistent with the source platform
3. Set is_private accurately to respect access controls
4. Use is_active to control which repositories are tracked

### Platform Integration

1. Verify external_id matches the platform's repository ID format
2. Use webhooks to keep repository data synchronized
3. Handle platform-specific differences in branch naming
4. Store full repository URLs for easy access

### Metric Tracking

1. Set is_active=false for archived repositories
2. Review inactive repositories regularly
3. Use the stats endpoint for periodic reporting
4. Consider time zones when analyzing time-based metrics

### Team Assignment

1. Assign repositories to teams based on ownership
2. Update team assignments when ownership changes
3. Keep repository-team relationships up to date
4. Document repository ownership in team descriptions

## Rate Limiting

Repository endpoints are subject to the standard rate limits:

- 1000 requests per hour per API key
- 100 requests per minute (burst limit)

See [Authentication](authentication.md) for details on rate limit headers and handling.

## Next Steps

- [Teams API](teams.md) - Manage teams that own repositories
- [Developers API](developers.md) - Manage repository contributors
- [Analytics API](analytics.md) - View repository metrics and DORA metrics
- [Organizations API](organizations.md) - Manage parent organizations