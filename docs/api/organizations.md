# Organizations

## Overview

Organizations are the top-level entities in the SEI Platform that represent companies or business units. All teams, repositories, and developers are associated with an organization. Organizations provide isolation and access control for multi-tenant environments.

## Endpoints

### List Organizations

Retrieve a paginated list of all organizations.

```http
GET /api/v1/organizations
```

**Query Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| skip | integer | 0 | Number of records to skip for pagination |
| limit | integer | 100 | Maximum number of records to return (max: 1000) |
| sort | string | created_at | Field to sort by (name, created_at, updated_at) |
| order | string | desc | Sort order (asc, desc) |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/organizations?skip=0&limit=50" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Acme Corporation",
      "domain": "acme.com",
      "settings": {
        "timezone": "America/New_York",
        "default_branch": "main"
      },
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "name": "Tech Innovations Inc",
      "domain": "techinnovations.io",
      "settings": {
        "timezone": "UTC",
        "default_branch": "main"
      },
      "created_at": "2024-01-05T14:20:00Z",
      "updated_at": "2024-01-10T09:15:00Z"
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

### Get Organization

Retrieve a specific organization by ID.

```http
GET /api/v1/organizations/{organization_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| organization_id | string (UUID) | Yes | Organization identifier |

**Request Example**:

```bash
curl -X GET "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json"
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Acme Corporation",
    "domain": "acme.com",
    "settings": {
      "timezone": "America/New_York",
      "default_branch": "main",
      "notifications_enabled": true
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc124"
  }
}
```

### Create Organization

Create a new organization.

```http
POST /api/v1/organizations
```

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Organization name (min: 3, max: 100 characters) |
| domain | string | No | Organization domain (e.g., company.com) |
| settings | object | No | Organization-specific settings (default: {}) |

**Request Example**:

```bash
curl -X POST "https://api.sei-platform.com/api/v1/organizations" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corporation",
    "domain": "acme.com",
    "settings": {
      "timezone": "America/New_York",
      "default_branch": "main"
    }
  }'
```

**Request Body**:

```json
{
  "name": "Acme Corporation",
  "domain": "acme.com",
  "settings": {
    "timezone": "America/New_York",
    "default_branch": "main"
  }
}
```

**Response** (201 Created):

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Acme Corporation",
    "domain": "acme.com",
    "settings": {
      "timezone": "America/New_York",
      "default_branch": "main"
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

### Update Organization

Update an existing organization.

```http
PUT /api/v1/organizations/{organization_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| organization_id | string (UUID) | Yes | Organization identifier |

**Request Body** (all fields optional):

| Field | Type | Description |
|-------|------|-------------|
| name | string | Updated organization name |
| domain | string | Updated organization domain |
| settings | object | Updated organization settings |

**Request Example**:

```bash
curl -X PUT "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corporation Ltd",
    "settings": {
      "timezone": "America/Los_Angeles",
      "default_branch": "main",
      "notifications_enabled": true
    }
  }'
```

**Request Body**:

```json
{
  "name": "Acme Corporation Ltd",
  "settings": {
    "timezone": "America/Los_Angeles",
    "default_branch": "main",
    "notifications_enabled": true
  }
}
```

**Response** (200 OK):

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Acme Corporation Ltd",
    "domain": "acme.com",
    "settings": {
      "timezone": "America/Los_Angeles",
      "default_branch": "main",
      "notifications_enabled": true
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T11:45:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T11:45:00Z",
    "request_id": "req_abc126"
  }
}
```

### Delete Organization

Delete an organization. This operation is irreversible and will cascade delete all associated teams, repositories, and data.

```http
DELETE /api/v1/organizations/{organization_id}
```

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| organization_id | string (UUID) | Yes | Organization identifier |

**Request Example**:

```bash
curl -X DELETE "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
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
      "issue": "Organization name must be at least 3 characters"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc127"
  }
}
```

### 404 Not Found

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Organization not found"
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc128"
  }
}
```

### 409 Conflict

**Duplicate Organization**:

```json
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Organization with this domain already exists",
    "details": {
      "field": "domain",
      "value": "acme.com"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc129"
  }
}
```

### 422 Unprocessable Entity

**Invalid Data**:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Request body validation failed",
    "details": {
      "errors": [
        {
          "field": "settings.timezone",
          "message": "Invalid timezone format"
        }
      ]
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc130"
  }
}
```

## Data Model

### Organization Object

| Field | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Unique organization identifier |
| name | string | Organization name |
| domain | string or null | Organization domain |
| settings | object | Organization-specific configuration |
| created_at | string (ISO 8601) | Creation timestamp |
| updated_at | string (ISO 8601) | Last update timestamp |

### Settings Object

Common settings fields:

| Field | Type | Description |
|-------|------|-------------|
| timezone | string | IANA timezone (e.g., "America/New_York") |
| default_branch | string | Default git branch name (e.g., "main") |
| notifications_enabled | boolean | Enable email notifications |

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

# List organizations
def list_organizations(skip=0, limit=100):
    response = requests.get(
        f"{API_URL}/organizations",
        headers=headers,
        params={"skip": skip, "limit": limit}
    )
    response.raise_for_status()
    return response.json()["data"]

# Get organization
def get_organization(org_id):
    response = requests.get(
        f"{API_URL}/organizations/{org_id}",
        headers=headers
    )
    response.raise_for_status()
    return response.json()["data"]

# Create organization
def create_organization(name, domain=None, settings=None):
    data = {
        "name": name,
        "domain": domain,
        "settings": settings or {}
    }
    response = requests.post(
        f"{API_URL}/organizations",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Update organization
def update_organization(org_id, name=None, domain=None, settings=None):
    data = {}
    if name:
        data["name"] = name
    if domain:
        data["domain"] = domain
    if settings:
        data["settings"] = settings

    response = requests.put(
        f"{API_URL}/organizations/{org_id}",
        headers=headers,
        json=data
    )
    response.raise_for_status()
    return response.json()["data"]

# Delete organization
def delete_organization(org_id):
    response = requests.delete(
        f"{API_URL}/organizations/{org_id}",
        headers=headers
    )
    response.raise_for_status()
    return True

# Usage examples
if __name__ == "__main__":
    # List all organizations
    orgs = list_organizations()
    print(f"Found {len(orgs)} organizations")

    # Create a new organization
    new_org = create_organization(
        name="Tech Innovations Inc",
        domain="techinnovations.io",
        settings={
            "timezone": "UTC",
            "default_branch": "main"
        }
    )
    print(f"Created organization: {new_org['id']}")

    # Get organization details
    org = get_organization(new_org["id"])
    print(f"Organization: {org['name']}")

    # Update organization
    updated_org = update_organization(
        org_id=new_org["id"],
        name="Tech Innovations Limited",
        settings={
            "timezone": "America/New_York",
            "default_branch": "main",
            "notifications_enabled": True
        }
    )
    print(f"Updated organization: {updated_org['name']}")
```

### JavaScript/TypeScript

```typescript
const API_URL = 'https://api.sei-platform.com/api/v1';
const API_KEY = process.env.SEI_API_KEY;

interface Organization {
  id: string;
  name: string;
  domain?: string;
  settings: Record<string, any>;
  created_at: string;
  updated_at: string;
}

interface CreateOrganizationRequest {
  name: string;
  domain?: string;
  settings?: Record<string, any>;
}

interface UpdateOrganizationRequest {
  name?: string;
  domain?: string;
  settings?: Record<string, any>;
}

class OrganizationsAPI {
  private headers: HeadersInit;

  constructor(apiKey: string) {
    this.headers = {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    };
  }

  async listOrganizations(skip = 0, limit = 100): Promise<Organization[]> {
    const url = new URL(`${API_URL}/organizations`);
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

  async getOrganization(orgId: string): Promise<Organization> {
    const response = await fetch(`${API_URL}/organizations/${orgId}`, {
      method: 'GET',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data;
  }

  async createOrganization(request: CreateOrganizationRequest): Promise<Organization> {
    const response = await fetch(`${API_URL}/organizations`, {
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

  async updateOrganization(
    orgId: string,
    request: UpdateOrganizationRequest
  ): Promise<Organization> {
    const response = await fetch(`${API_URL}/organizations/${orgId}`, {
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

  async deleteOrganization(orgId: string): Promise<void> {
    const response = await fetch(`${API_URL}/organizations/${orgId}`, {
      method: 'DELETE',
      headers: this.headers
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }
  }
}

// Usage examples
async function main() {
  const api = new OrganizationsAPI(API_KEY!);

  // List organizations
  const orgs = await api.listOrganizations();
  console.log(`Found ${orgs.length} organizations`);

  // Create organization
  const newOrg = await api.createOrganization({
    name: 'Tech Innovations Inc',
    domain: 'techinnovations.io',
    settings: {
      timezone: 'UTC',
      default_branch: 'main'
    }
  });
  console.log(`Created organization: ${newOrg.id}`);

  // Get organization
  const org = await api.getOrganization(newOrg.id);
  console.log(`Organization: ${org.name}`);

  // Update organization
  const updatedOrg = await api.updateOrganization(newOrg.id, {
    name: 'Tech Innovations Limited',
    settings: {
      timezone: 'America/New_York',
      default_branch: 'main',
      notifications_enabled: true
    }
  });
  console.log(`Updated organization: ${updatedOrg.name}`);

  // Delete organization
  await api.deleteOrganization(newOrg.id);
  console.log('Organization deleted');
}
```

### cURL

```bash
# List organizations
curl -X GET "https://api.sei-platform.com/api/v1/organizations?skip=0&limit=50" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Get organization
curl -X GET "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Create organization
curl -X POST "https://api.sei-platform.com/api/v1/organizations" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corporation",
    "domain": "acme.com",
    "settings": {
      "timezone": "America/New_York",
      "default_branch": "main"
    }
  }'

# Update organization
curl -X PUT "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Acme Corporation Ltd",
    "settings": {
      "timezone": "America/Los_Angeles",
      "notifications_enabled": true
    }
  }'

# Delete organization
curl -X DELETE "https://api.sei-platform.com/api/v1/organizations/550e8400-e29b-41d4-a716-446655440000" \
  -H "X-API-Key: sei_live_..."
```

## Best Practices

### Organization Naming

1. Use descriptive names that clearly identify the business entity
2. Avoid special characters in organization names
3. Keep names between 3-100 characters

### Domain Configuration

1. Use the primary company domain for the organization
2. Ensure domain uniqueness across organizations
3. Domain can be left null for internal or testing organizations

### Settings Management

1. Store organization-specific configurations in the settings object
2. Keep settings flat when possible for easier querying
3. Document custom settings in your application

### Deletion Safety

1. Always backup data before deleting an organization
2. Implement soft deletes in production environments
3. Notify all organization members before deletion
4. Consider archiving instead of deletion for audit trails

## Rate Limiting

Organization endpoints are subject to the standard rate limits:

- 1000 requests per hour per API key
- 100 requests per minute (burst limit)

See [Authentication](authentication.md) for details on rate limit headers and handling.

## Next Steps

- [Teams API](teams.md) - Manage teams within organizations
- [Repositories API](repositories.md) - Manage repositories
- [Developers API](developers.md) - Manage developers
- [Analytics API](analytics.md) - View organization metrics