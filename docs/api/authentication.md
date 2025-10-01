# Authentication

## Overview

The SEI Platform API uses JWT (JSON Web Token) authentication and API keys to authenticate requests. All API requests must include authentication credentials.

## Authentication Methods

### JWT Token Authentication

JWT tokens are used for user-based authentication and provide short-lived access tokens.

**Request Header**:

```http
Authorization: Bearer <jwt_token>
```

**Token Structure**:

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "org_id": "660e8400-e29b-41d4-a716-446655440001",
  "role": "admin",
  "exp": 1705392000,
  "iat": 1705305600
}
```

### API Key Authentication

API keys are used for service-to-service authentication and long-lived integrations.

**Request Header**:

```http
X-API-Key: sei_live_<your_api_key>
```

**API Key Format**: `sei_live_` prefix followed by 32 random characters

## Obtaining Authentication Credentials

### Get JWT Token

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response**:

```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 86400
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

### Refresh JWT Token

```http
POST /api/v1/auth/refresh
Authorization: Bearer <expired_token>
```

**Response**:

```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 86400
  }
}
```

### Create API Key

```http
POST /api/v1/api-keys
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "Production Integration",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**Response**:

```json
{
  "data": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "key": "sei_live_abcdef1234567890abcdef1234567890",
    "name": "Production Integration",
    "created_at": "2024-01-15T10:30:00Z",
    "expires_at": "2025-12-31T23:59:59Z"
  }
}
```

**IMPORTANT**: The API key is only shown once. Store it securely.

### List API Keys

```http
GET /api/v1/api-keys
Authorization: Bearer <jwt_token>
```

**Response**:

```json
{
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "name": "Production Integration",
      "last_used_at": "2024-01-15T09:45:00Z",
      "created_at": "2024-01-15T10:30:00Z",
      "expires_at": "2025-12-31T23:59:59Z"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### Revoke API Key

```http
DELETE /api/v1/api-keys/{key_id}
Authorization: Bearer <jwt_token>
```

**Response**:

```http
HTTP/1.1 204 No Content
```

## Authentication Errors

### 401 Unauthorized

**Missing Token**:

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "No authentication credentials provided"
  }
}
```

**Invalid Token**:

```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Invalid or malformed authentication token"
  }
}
```

**Expired Token**:

```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Authentication token has expired"
  }
}
```

### 403 Forbidden

```json
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You do not have permission to access this resource"
  }
}
```

## Security Best Practices

### Token Security

1. **Never expose tokens** in client-side code or logs
2. **Use HTTPS** for all API requests
3. **Store tokens securely** using secure storage mechanisms
4. **Rotate API keys regularly** (every 90 days recommended)
5. **Use short-lived tokens** and refresh them as needed

### API Key Management

1. **Create separate API keys** for each integration
2. **Use descriptive names** to identify API key purpose
3. **Set expiration dates** for API keys
4. **Monitor API key usage** via last_used_at field
5. **Revoke unused keys** immediately

### Request Security

**Example: Secure API Request**

```python
import requests
import os

API_URL = "https://api.sei-platform.com/api/v1"
API_KEY = os.getenv("SEI_API_KEY")  # Never hardcode

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

response = requests.get(f"{API_URL}/organizations", headers=headers)
response.raise_for_status()
data = response.json()
```

## Rate Limiting

All authenticated endpoints are subject to rate limiting:

- **1000 requests per hour** per API key/token
- **100 requests per minute** (burst limit)

**Rate Limit Headers**:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1705392000
```

**Rate Limit Exceeded**:

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded",
    "details": {
      "limit": 1000,
      "reset_at": "2024-01-15T11:00:00Z"
    }
  }
}
```

## Authentication Flow

### Web Application Flow

```mermaid
sequenceDiagram
    participant User
    participant WebApp
    participant API

    User->>WebApp: Enter credentials
    WebApp->>API: POST /api/v1/auth/login
    API-->>WebApp: JWT token
    WebApp->>WebApp: Store token
    WebApp->>API: API request with token
    API-->>WebApp: Response
    WebApp-->>User: Display data
```

### Service Integration Flow

```mermaid
sequenceDiagram
    participant Admin
    participant WebUI
    participant API
    participant Service

    Admin->>WebUI: Create API key
    WebUI->>API: POST /api/v1/api-keys
    API-->>WebUI: API key
    WebUI-->>Admin: Display key (once)
    Admin->>Service: Configure API key
    Service->>API: Request with API key
    API-->>Service: Response
```

## Code Examples

### Python

```python
import requests

class SEIClient:
    def __init__(self, api_key: str):
        self.base_url = "https://api.sei-platform.com/api/v1"
        self.headers = {
            "X-API-Key": api_key,
            "Content-Type": "application/json"
        }

    def get_organizations(self):
        response = requests.get(
            f"{self.base_url}/organizations",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()["data"]

# Usage
client = SEIClient(api_key="sei_live_...")
orgs = client.get_organizations()
```

### JavaScript/TypeScript

```typescript
class SEIClient {
    private baseUrl = 'https://api.sei-platform.com/api/v1';
    private apiKey: string;

    constructor(apiKey: string) {
        this.apiKey = apiKey;
    }

    async getOrganizations() {
        const response = await fetch(`${this.baseUrl}/organizations`, {
            headers: {
                'X-API-Key': this.apiKey,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`API error: ${response.statusText}`);
        }

        const data = await response.json();
        return data.data;
    }
}

// Usage
const client = new SEIClient('sei_live_...');
const orgs = await client.getOrganizations();
```

### cURL

```bash
# Using API Key
curl -X GET "https://api.sei-platform.com/api/v1/organizations" \
  -H "X-API-Key: sei_live_..." \
  -H "Content-Type: application/json"

# Using JWT Token
curl -X GET "https://api.sei-platform.com/api/v1/organizations" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

## Testing Authentication

### Test API Key

```http
GET /api/v1/auth/verify
X-API-Key: <your_api_key>
```

**Response**:

```json
{
  "data": {
    "authenticated": true,
    "auth_type": "api_key",
    "organization_id": "660e8400-e29b-41d4-a716-446655440001",
    "permissions": ["read", "write"]
  }
}
```

### Test JWT Token

```http
GET /api/v1/auth/verify
Authorization: Bearer <jwt_token>
```

**Response**:

```json
{
  "data": {
    "authenticated": true,
    "auth_type": "jwt",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "organization_id": "660e8400-e29b-41d4-a716-446655440001",
    "role": "admin",
    "expires_at": "2024-01-16T10:30:00Z"
  }
}
```

## Next Steps

- [Organizations API](organizations.md) - Manage organizations
- [Teams API](teams.md) - Manage teams
- [API Introduction](introduction.md) - API overview and getting started