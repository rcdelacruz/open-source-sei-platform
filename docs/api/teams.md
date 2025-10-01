# Teams

## Overview

Teams represent groups of developers within an organization in the SEI Platform. Teams are used to organize developers, manage repositories, and track engineering metrics. Each team belongs to a single organization and can have multiple developers and repositories assigned to it.

## Endpoints

### List Teams

Retrieve a paginated list of all teams, optionally filtered by organization.

```http
GET /api/v1/teams
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| organization_id | string (UUID) | - | Filter teams by organization ID |
| skip | integer | 0 | Number of records to skip for pagination |
| limit | integer | 100 | Maximum number of records to return (max: 1000) |
| sort | string | created_at | Field to sort by (name, created_at, updated_at) |
| order | string | desc | Sort order (asc, desc) |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/teams?organization_id=550e8400-e29b-41d4-a716-446655440000&skip=0&limit=50" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "organization_id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Platform Team",
      "description": "Core platform development team",
      "settings": {
        "sprint_length": 14,
        "code_review_required": true
      },
      "created_at": "2024-01-05T10:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": "880e8400-e29b-41d4-a716-446655440003",
      "organization_id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Mobile Team",
      "description": "iOS and Android development",
      "settings": {
        "sprint_length": 14,
        "code_review_required": true
      },
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

### Get Team

Retrieve a specific team by ID.

```http
GET /api/v1/teams/{team_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "organization_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Platform Team",
    "description": "Core platform development team",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true,
      "deployment_frequency_target": "daily"
    },
    "created_at": "2024-01-05T10:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc124"
  }
}
```

### Create Team

Create a new team within an organization.

```http
POST /api/v1/teams
```

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| organization_id | string (UUID) | Yes | Organization ID this team belongs to |
| name | string | Yes | Team name (min: 2, max: 100 characters) |
| description | string | No | Team description (max: 500 characters) |
| settings | object | No | Team-specific settings (default: {}) |

**Request Example**:

```bash
curl -X POST "https://api.sei-platform.com/api/v1/teams" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Platform Team",
    "description": "Core platform development team",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true
    }
  }'
```

**Request Body**:

```json
{
  "organization_id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Platform Team",
  "description": "Core platform development team",
  "settings": {
    "sprint_length": 14,
    "code_review_required": true
  }
}
```

**Response** (201 Created):

```json
{
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "organization_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Platform Team",
    "description": "Core platform development team",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc125"
  }
}
```

### Update Team

Update an existing team.

```http
PUT /api/v1/teams/{team_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Request Body** (all fields optional):

| Field | Type | Description |
|-------|------|-------------|
| name | string | Updated team name |
| description | string | Updated team description |
| settings | object | Updated team settings |

**Request Example**:

```bash
curl -X PUT "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Core Platform Team",
    "description": "Core platform infrastructure and API development",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true,
      "deployment_frequency_target": "daily"
    }
  }'
```

**Request Body**:

```json
{
  "name": "Core Platform Team",
  "description": "Core platform infrastructure and API development",
  "settings": {
    "sprint_length": 14,
    "code_review_required": true,
    "deployment_frequency_target": "daily"
  }
}
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "organization_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Core Platform Team",
    "description": "Core platform infrastructure and API development",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true,
      "deployment_frequency_target": "daily"
    },
    "created_at": "2024-01-05T10:00:00Z",
    "updated_at": "2024-01-15T11:45:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T11:45:00Z",
    "request_id": "req_abc126"
  }
}
```

### Delete Team

Delete a team. This operation will unassign all developers and repositories but will not delete them.

```http
DELETE /api/v1/teams/{team_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Request Example**:

```bash
curl -X DELETE "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "Authorization: Bearer <jwt_token>"
```

**Response** (204 No Content):

```http
HTTP/1.1 204 No Content
```

## Team Members

### List Team Members

Get all developers assigned to a team.

```http
GET /api/v1/teams/{team_id}/members
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| skip | integer | 0 | Number of records to skip for pagination |
| limit | integer | 100 | Maximum number of records to return |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members" \
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
      "is_active": true,
      "joined_at": "2024-01-08T14:30:00Z",
      "created_at": "2024-01-08T14:30:00Z"
    }
  ],
  "meta": {
    "total": 2,
    "skip": 0,
    "limit": 100,
    "has_more": false
  }
}
```

### Add Team Member

Add a developer to a team.

```http
POST /api/v1/teams/{team_id}/members
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| developer_id | string (UUID) | Yes | Developer ID to add to team |

**Request Example**:

```bash
curl -X POST "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "developer_id": "990e8400-e29b-41d4-a716-446655440004"
  }'
```

**Request Body**:

```json
{
  "developer_id": "990e8400-e29b-41d4-a716-446655440004"
}
```

**Response** (201 Created):

```json
{
  "data": {
    "team_id": "770e8400-e29b-41d4-a716-446655440002",
    "developer_id": "990e8400-e29b-41d4-a716-446655440004",
    "joined_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc127"
  }
}
```

### Remove Team Member

Remove a developer from a team.

```http
DELETE /api/v1/teams/{team_id}/members/{developer_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team_id | string (UUID) | Yes | Team identifier |
| developer_id | string (UUID) | Yes | Developer identifier to remove |

**Request Example**:

```bash
curl -X DELETE "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members/990e8400-e29b-41d4-a716-446655440004" \
  -H "Authorization: Bearer <jwt_token>"
```

**Response** (204 No Content):

```http
HTTP/1.1 204 No Content
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
      "field": "name",
      "issue": "Team name must be at least 2 characters"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc128"
  }
}
```

### 404 Not Found

**Team Not Found**:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Team not found"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc129"
  }
}
```

**Organization Not Found**:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Organization not found",
    "details": {
      "organization_id": "550e8400-e29b-41d4-a716-446655440000"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc130"
  }
}
```

### 409 Conflict

**Duplicate Team Name**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Team with this name already exists in organization",
    "details": {
      "field": "name",
      "value": "Platform Team"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc131"
  }
}
```

**Developer Already in Team**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Developer is already a member of this team",
    "details": {
      "developer_id": "990e8400-e29b-41d4-a716-446655440004",
      "team_id": "770e8400-e29b-41d4-a716-446655440002"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc132"
  }
}
```

## Data Model

### Team Object

| Field | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Unique team identifier |
| organization_id | string (UUID) | Organization this team belongs to |
| name | string | Team name |
| description | string or null | Team description |
| settings | object | Team-specific configuration |
| created_at | string (ISO 8601) | Creation timestamp |
| updated_at | string (ISO 8601) | Last update timestamp |

### Settings Object

Common settings fields:

| Field | Type | Description |
|-------|------|-------------|
| sprint_length | integer | Sprint duration in days (e.g., 14) |
| code_review_required | boolean | Require code reviews for merges |
| deployment_frequency_target | string | Target deployment frequency (daily, weekly, etc.) |

## Code Examples

### Python

```python
import requests
import os

API_URL = "https://api.sei-platform.com/api/v1"
API_KEY = os.getenv("SEI_API_KEY")

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

# List teams
def list_teams(organization_id=None, skip=0, limit=100):
    params = {"skip": skip, "limit": limit}
    if organization_id:
        params["organization_id"] = organization_id

    response = requests.get(
        f"{API_URL}/teams",
        headers=headers,
        params=params
    )
    response.raise_for_status()
    return response.json()["data"]

# Get team
def get_team(team_id):
    response = requests.get(
        f"{API_URL}/teams/{team_id}",
        headers=headers
    )
    response.raise_for_status()
    return response.json()["data"]

# Create team
def create_team(organization_id, name, description=None, settings=None):
    data = {
        "organization_id": organization_id,
        "name": name,
        "description": description,
        "settings": settings or {}
    }
    response = requests.post(
        f"{API_URL}/teams",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Update team
def update_team(team_id, name=None, description=None, settings=None):
    data = {}
    if name:
        data["name"] = name
    if description is not None:
        data["description"] = description
    if settings:
        data["settings"] = settings

    response = requests.put(
        f"{API_URL}/teams/{team_id}",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Delete team
def delete_team(team_id):
    response = requests.delete(
        f"{API_URL}/teams/{team_id}",
        headers=headers
    )
    response.raise_for_status()
    return True

# List team members
def list_team_members(team_id):
    response = requests.get(
        f"{API_URL}/teams/{team_id}/members",
        headers=headers
    )
    response.raise_for_status()
    return response.json()["data"]

# Add team member
def add_team_member(team_id, developer_id):
    data = {"developer_id": developer_id}
    response = requests.post(
        f"{API_URL}/teams/{team_id}/members",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Remove team member
def remove_team_member(team_id, developer_id):
    response = requests.delete(
        f"{API_URL}/teams/{team_id}/members/{developer_id}",
        headers=headers
    )
    response.raise_for_status()
    return True

# Usage examples
if __name__ == "__main__":
    org_id = "550e8400-e29b-41d4-a716-446655440000"

    # Create a new team
    new_team = create_team(
        organization_id=org_id,
        name="Platform Team",
        description="Core platform development team",
        settings={
            "sprint_length": 14,
            "code_review_required": True
        }
    )
    print(f"Created team: {new_team['id']}")

    # List teams for organization
    teams = list_teams(organization_id=org_id)
    print(f"Found {len(teams)} teams")

    # Add member to team
    developer_id = "990e8400-e29b-41d4-a716-446655440004"
    add_team_member(new_team["id"], developer_id)
    print(f"Added developer {developer_id} to team")

    # List team members
    members = list_team_members(new_team["id"])
    print(f"Team has {len(members)} members")
```

### JavaScript/TypeScript

```typescript
const API_URL = 'https://api.sei-platform.com/api/v1';
const API_KEY = process.env.SEI_API_KEY;

interface Team {
  id: string;
  organization_id: string;
  name: string;
  description?: string;
  settings: Record<string, any>;
  created_at: string;
  updated_at: string;
}

interface CreateTeamRequest {
  organization_id: string;
  name: string;
  description?: string;
  settings?: Record<string, any>;
}

interface UpdateTeamRequest {
  name?: string;
  description?: string;
  settings?: Record<string, any>;
}

interface TeamMember {
  id: string;
  team_id: string;
  email: string;
  name?: string;
  github_username?: string;
  is_active: boolean;
  joined_at: string;
  created_at: string;
}

class TeamsAPI {
  private headers: HeadersInit;

  constructor(apiKey: string) {
    this.headers = {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    };
  }

  async listTeams(
    organizationId?: string,
    skip = 0,
    limit = 100
  ): Promise<Team[]> {
    const url = new URL(`${API_URL}/teams`);
    if (organizationId) {
      url.searchParams.set('organization_id', organizationId);
    }
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

  async getTeam(teamId: string): Promise<Team> {
    const response = await fetch(`${API_URL}/teams/${teamId}`, {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async createTeam(request: CreateTeamRequest): Promise<Team> {
    const response = await fetch(`${API_URL}/teams`, {
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

  async updateTeam(teamId: string, request: UpdateTeamRequest): Promise<Team> {
    const response = await fetch(`${API_URL}/teams/${teamId}`, {
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

  async deleteTeam(teamId: string): Promise<void> {
    const response = await fetch(`${API_URL}/teams/${teamId}`, {
      method: 'DELETE',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }
  }

  async listTeamMembers(teamId: string): Promise<TeamMember[]> {
    const response = await fetch(`${API_URL}/teams/${teamId}/members`, {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async addTeamMember(teamId: string, developerId: string): Promise<any> {
    const response = await fetch(`${API_URL}/teams/${teamId}/members`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ developer_id: developerId })
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async removeTeamMember(teamId: string, developerId: string): Promise<void> {
    const response = await fetch(
      `${API_URL}/teams/${teamId}/members/${developerId}`,
      {
        method: 'DELETE',
        headers: this.headers
      }
    );

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }
  }
}

// Usage examples
async function main() {
  const api = new TeamsAPI(API_KEY!);
  const orgId = '550e8400-e29b-41d4-a716-446655440000';

  // Create team
  const newTeam = await api.createTeam({
    organization_id: orgId,
    name: 'Platform Team',
    description: 'Core platform development team',
    settings: {
      sprint_length: 14,
      code_review_required: true
    }
  });
  console.log(`Created team: ${newTeam.id}`);

  // List teams
  const teams = await api.listTeams(orgId);
  console.log(`Found ${teams.length} teams`);

  // Add team member
  const developerId = '990e8400-e29b-41d4-a716-446655440004';
  await api.addTeamMember(newTeam.id, developerId);
  console.log(`Added developer to team`);

  // List team members
  const members = await api.listTeamMembers(newTeam.id);
  console.log(`Team has ${members.length} members`);
}
```

### cURL

```bash
# List teams
curl -X GET "https://api.sei-platform.com/api/v1/teams?organization_id=550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get team
curl -X GET "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Create team
curl -X POST "https://api.sei-platform.com/api/v1/teams" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Platform Team",
    "description": "Core platform development team",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true
    }
  }'

# Update team
curl -X PUT "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Core Platform Team",
    "settings": {
      "sprint_length": 14,
      "code_review_required": true,
      "deployment_frequency_target": "daily"
    }
  }'

# Delete team
curl -X DELETE "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002" \
  -H "X-API-Key: sei_live_..."

# List team members
curl -X GET "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Add team member
curl -X POST "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "developer_id": "990e8400-e29b-41d4-a716-446655440004"
  }'

# Remove team member
curl -X DELETE "https://api.sei-platform.com/api/v1/teams/770e8400-e29b-41d4-a716-446655440002/members/990e8400-e29b-41d4-a716-446655440004" \
  -H "X-API-Key: sei_live_..."
```

## Best Practices

### Team Organization

1. Create teams based on functional areas or product ownership
2. Keep team sizes manageable (5-10 developers recommended)
3. Use descriptive team names that reflect their purpose
4. Document team responsibilities in the description field

### Settings Management

1. Define standard settings across teams for consistency
2. Use settings for team-specific configurations
3. Document custom settings in your application
4. Review and update settings regularly as processes evolve

### Member Management

1. Assign developers to teams based on their primary responsibilities
2. Update team memberships when roles change
3. Remove inactive members to keep metrics accurate
4. Consider multi-team assignments for cross-functional work

### Deletion Considerations

1. Review team dependencies before deletion
2. Reassign repositories and developers before deleting teams
3. Export team metrics and historical data for archival
4. Consider deactivating teams instead of deletion

## Rate Limiting

Team endpoints are subject to the standard rate limits:

- 1000 requests per hour per API key
- 100 requests per minute (burst limit)

See [Authentication](authentication.md) for details on rate limit headers and handling.

## Next Steps

- [Organizations API](organizations.md) - Manage organizations
- [Developers API](developers.md) - Manage team members
- [Repositories API](repositories.md) - Assign repositories to teams
- [Analytics API](analytics.md) - View team metrics