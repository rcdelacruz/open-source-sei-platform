# API Introduction

The SEI Platform provides a comprehensive REST API for accessing all platform features programmatically.

## API Overview

The API follows REST principles and returns JSON responses. All endpoints are versioned and documented with OpenAPI/Swagger.

## Base URL

```
http://localhost:8080/api/v1
```

Production:
```
https://your-domain.com/api/v1
```

## Authentication

Currently, the API does not require authentication for development. In production, JWT-based authentication will be required.

Future authentication header:
```
Authorization: Bearer <your_jwt_token>
```

## Response Format

All API responses follow a consistent structure:

### Success Response

```json
{
  "id": "uuid",
  "name": "Example",
  "created_at": "2025-09-30T10:00:00.000000",
  "updated_at": "2025-09-30T10:00:00.000000"
}
```

### Error Response

```json
{
  "detail": "Error message describing what went wrong"
}
```

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 204 | No Content - Request successful, no content returned |
| 400 | Bad Request - Invalid request parameters |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource does not exist |
| 422 | Unprocessable Entity - Validation error |
| 500 | Internal Server Error - Server error |

## Rate Limiting

Default rate limits:

- 1000 requests per hour per IP address
- Burst limit: 100 requests per minute

Rate limit headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1696089600
```

## Pagination

List endpoints support pagination:

Query parameters:

- `skip`: Number of records to skip (default: 0)
- `limit`: Maximum number of records to return (default: 100, max: 1000)

Example:
```
GET /api/v1/organizations?skip=0&limit=50
```

## Filtering

Many endpoints support filtering through query parameters:

```
GET /api/v1/repositories?team_id=<uuid>&platform=github
```

## Interactive Documentation

Access the interactive API documentation:

- **Swagger UI**: http://localhost:8080/docs
- **ReDoc**: http://localhost:8080/redoc

## API Endpoints

### Core Resources

- [Organizations](organizations.md) - Organization management
- [Teams](teams.md) - Team management
- [Repositories](repositories.md) - Repository tracking
- [Developers](developers.md) - Developer profiles

### Analytics

- [Analytics](analytics.md) - DORA metrics and team performance

## Example Request

```bash
curl -X GET "http://localhost:8080/api/v1/organizations" \
  -H "Accept: application/json"
```

## Client Libraries

### Python

```python
import httpx

client = httpx.Client(base_url="http://localhost:8080")
response = client.get("/api/v1/organizations")
organizations = response.json()
```

### JavaScript

```javascript
fetch('http://localhost:8080/api/v1/organizations')
  .then(response => response.json())
  .then(data => console.log(data));
```

### cURL

```bash
curl -X GET "http://localhost:8080/api/v1/organizations" \
  -H "Accept: application/json"
```

## Versioning

The API is versioned through the URL path:

- Current version: `v1`
- Base path: `/api/v1`

Breaking changes will result in a new API version.

## Next Steps

- Explore [Organizations API](organizations.md)
- Learn about [Teams API](teams.md)
- Check [Analytics API](analytics.md)