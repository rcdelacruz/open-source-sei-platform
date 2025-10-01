# Testing

This guide covers the testing strategy, frameworks, and practices for the SEI Platform.

## Testing Philosophy

The SEI Platform follows a comprehensive testing approach:

- Write tests before or alongside production code
- Maintain high test coverage (target 80%+)
- Favor integration tests for business logic
- Use unit tests for complex algorithms
- Include end-to-end tests for critical user flows
- Run tests automatically in CI/CD pipeline

## Test Structure

Tests are organized by type in the `tests/` directory:

```
tests/
├── unit/              # Unit tests
│   ├── apis/         # API service units
│   ├── collectors/   # Collector units
│   ├── processors/   # Processor units
│   └── frontend/     # Frontend units
├── integration/       # Integration tests
│   ├── api/          # API integration tests
│   ├── collectors/   # Collector integration tests
│   └── processors/   # Processor integration tests
├── e2e/              # End-to-end tests
│   ├── specs/        # Test specifications
│   └── fixtures/     # Test data
├── load/             # Load and performance tests
│   └── locustfile.py
├── fixtures/         # Shared test fixtures
└── conftest.py       # Pytest configuration
```

## Testing Frameworks

### Python Tests

Python services use pytest with additional plugins:

- `pytest` - Test framework
- `pytest-cov` - Coverage reporting
- `pytest-asyncio` - Async test support
- `factory-boy` - Test data factories
- `freezegun` - Time mocking

Install test dependencies:

```bash
pip install -r requirements.txt
```

### Frontend Tests

Frontend uses Jest and React Testing Library:

- `jest` - Test runner
- `@testing-library/react` - React component testing
- `@testing-library/user-event` - User interaction simulation
- `@testing-library/jest-dom` - DOM matchers

Install frontend test dependencies:

```bash
cd src/frontend
npm install
```

### End-to-End Tests

E2E tests use Playwright or Cypress:

- Cross-browser testing
- Visual regression testing
- Network mocking
- Screenshot comparison

## Running Tests

### All Tests

Run all test suites:

```bash
make test
```

This runs:

- Python unit tests
- Python integration tests
- Frontend tests
- Coverage reports

### Unit Tests

Run only unit tests:

```bash
# All unit tests
make test-unit

# Python unit tests
pytest tests/unit/ -v

# Frontend unit tests
cd src/frontend && npm test
```

### Integration Tests

Run integration tests:

```bash
# All integration tests
make test-integration

# Specific integration test
pytest tests/integration/api/test_analytics.py -v
```

### End-to-End Tests

Run E2E tests:

```bash
# All E2E tests
make test-e2e

# Specific E2E test
cd tests/e2e && npm test -- specs/dashboard.spec.ts
```

### Load Tests

Run load and performance tests:

```bash
# Using make
make test-load

# Using locust directly
cd tests/load
locust -f locustfile.py --headless -u 100 -r 10 -t 300s
```

### Test Coverage

Generate coverage reports:

```bash
# Python coverage
pytest --cov=src --cov-report=html --cov-report=term

# View HTML report
open htmlcov/index.html

# Frontend coverage
cd src/frontend && npm test -- --coverage
```

## Writing Tests

### Unit Test Example

Python unit test using pytest:

```python
# tests/unit/processors/test_velocity.py
import pytest
from src.processors.processors.velocity import calculate_velocity

def test_calculate_velocity_with_valid_data():
    """Test velocity calculation with valid data."""
    commits = [
        {"date": "2024-01-01", "additions": 100, "deletions": 20},
        {"date": "2024-01-02", "additions": 150, "deletions": 30},
    ]

    result = calculate_velocity(commits)

    assert result["total_commits"] == 2
    assert result["total_changes"] == 300
    assert result["net_changes"] == 200

def test_calculate_velocity_with_empty_data():
    """Test velocity calculation with empty data."""
    commits = []

    result = calculate_velocity(commits)

    assert result["total_commits"] == 0
    assert result["total_changes"] == 0

@pytest.mark.parametrize("commits,expected", [
    ([{"date": "2024-01-01", "additions": 10, "deletions": 5}], 15),
    ([{"date": "2024-01-01", "additions": 100, "deletions": 50}], 150),
])
def test_calculate_velocity_parametrized(commits, expected):
    """Test velocity calculation with various inputs."""
    result = calculate_velocity(commits)
    assert result["total_changes"] == expected
```

### Integration Test Example

Integration test with database:

```python
# tests/integration/api/test_developers.py
import pytest
from fastapi.testclient import TestClient
from src.apis.main import app
from src.apis.database import get_db

@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)

@pytest.fixture
def db_session():
    """Create test database session."""
    # Setup test database
    session = create_test_session()
    yield session
    # Teardown
    session.close()

def test_get_developers(client, db_session):
    """Test getting list of developers."""
    # Arrange - seed test data
    create_test_developer(db_session, name="John Doe")
    create_test_developer(db_session, name="Jane Smith")

    # Act
    response = client.get("/api/v1/developers")

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    assert data[0]["name"] == "John Doe"

def test_get_developer_metrics(client, db_session):
    """Test getting developer metrics."""
    # Arrange
    developer = create_test_developer(db_session, name="John Doe")
    create_test_commits(db_session, developer_id=developer.id, count=10)

    # Act
    response = client.get(f"/api/v1/developers/{developer.id}/metrics")

    # Assert
    assert response.status_code == 200
    metrics = response.json()
    assert metrics["total_commits"] == 10
    assert "velocity" in metrics
```

### Frontend Test Example

React component test:

```typescript
// tests/unit/frontend/components/Dashboard.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Dashboard from '@/components/Dashboard';
import { mockApiClient } from '../mocks/apiClient';

describe('Dashboard Component', () => {
  beforeEach(() => {
    // Setup mocks
    mockApiClient.getMetrics.mockResolvedValue({
      velocity: 100,
      quality: 85,
    });
  });

  test('renders dashboard with metrics', async () => {
    render(<Dashboard />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('Velocity: 100')).toBeInTheDocument();
      expect(screen.getByText('Quality: 85')).toBeInTheDocument();
    });
  });

  test('refreshes data on button click', async () => {
    const user = userEvent.setup();
    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('Velocity: 100')).toBeInTheDocument();
    });

    const refreshButton = screen.getByRole('button', { name: /refresh/i });
    await user.click(refreshButton);

    expect(mockApiClient.getMetrics).toHaveBeenCalledTimes(2);
  });

  test('displays error message on API failure', async () => {
    mockApiClient.getMetrics.mockRejectedValue(new Error('API Error'));

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText(/error loading metrics/i)).toBeInTheDocument();
    });
  });
});
```

### E2E Test Example

End-to-end test using Playwright:

```typescript
// tests/e2e/specs/dashboard.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Dashboard Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3002');
  });

  test('should display dashboard with metrics', async ({ page }) => {
    // Wait for dashboard to load
    await page.waitForSelector('[data-testid="dashboard"]');

    // Verify metrics are displayed
    const velocity = await page.textContent('[data-testid="velocity-metric"]');
    expect(velocity).toBeTruthy();

    const quality = await page.textContent('[data-testid="quality-metric"]');
    expect(quality).toBeTruthy();
  });

  test('should navigate to team details', async ({ page }) => {
    // Click on team
    await page.click('[data-testid="team-link"]');

    // Verify navigation
    await expect(page).toHaveURL(/.*\/teams\/\d+/);

    // Verify team details are displayed
    await expect(page.locator('h1')).toContainText('Team Details');
  });

  test('should filter metrics by date range', async ({ page }) => {
    // Select date range
    await page.fill('[data-testid="start-date"]', '2024-01-01');
    await page.fill('[data-testid="end-date"]', '2024-01-31');
    await page.click('[data-testid="apply-filter"]');

    // Wait for metrics to update
    await page.waitForResponse(resp =>
      resp.url().includes('/api/v1/metrics') && resp.status() === 200
    );

    // Verify filtered data
    const dateRange = await page.textContent('[data-testid="date-range"]');
    expect(dateRange).toContain('Jan 1 - Jan 31');
  });
});
```

## Test Fixtures

### Python Fixtures

Create reusable test fixtures:

```python
# tests/conftest.py
import pytest
from datetime import datetime
from src.apis.database import Base, engine

@pytest.fixture(scope="session")
def test_db():
    """Create test database."""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def db_session(test_db):
    """Create database session for test."""
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def sample_developer():
    """Create sample developer data."""
    return {
        "name": "John Doe",
        "email": "john@example.com",
        "team_id": 1,
    }

@pytest.fixture
def sample_commits():
    """Create sample commit data."""
    return [
        {
            "sha": "abc123",
            "message": "Fix bug",
            "author": "John Doe",
            "date": datetime(2024, 1, 1),
            "additions": 10,
            "deletions": 5,
        },
        {
            "sha": "def456",
            "message": "Add feature",
            "author": "John Doe",
            "date": datetime(2024, 1, 2),
            "additions": 50,
            "deletions": 10,
        },
    ]
```

### Frontend Fixtures

Mock API responses:

```typescript
// tests/unit/frontend/mocks/apiClient.ts
export const mockApiClient = {
  getMetrics: jest.fn(),
  getDevelopers: jest.fn(),
  getTeams: jest.fn(),
};

export const mockMetrics = {
  velocity: 100,
  quality: 85,
  collaboration: 92,
  flow: 78,
};

export const mockDevelopers = [
  { id: 1, name: 'John Doe', email: 'john@example.com' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
];
```

## Test Data Factories

Use factory-boy for generating test data:

```python
# tests/factories.py
import factory
from datetime import datetime
from src.apis.models import Developer, Team, Commit

class TeamFactory(factory.Factory):
    class Meta:
        model = Team

    id = factory.Sequence(lambda n: n)
    name = factory.Faker('company')
    created_at = factory.LazyFunction(datetime.utcnow)

class DeveloperFactory(factory.Factory):
    class Meta:
        model = Developer

    id = factory.Sequence(lambda n: n)
    name = factory.Faker('name')
    email = factory.Faker('email')
    team = factory.SubFactory(TeamFactory)
    created_at = factory.LazyFunction(datetime.utcnow)

class CommitFactory(factory.Factory):
    class Meta:
        model = Commit

    sha = factory.Faker('sha1')
    message = factory.Faker('sentence')
    author = factory.SubFactory(DeveloperFactory)
    date = factory.Faker('date_time_this_year')
    additions = factory.Faker('random_int', min=1, max=100)
    deletions = factory.Faker('random_int', min=1, max=50)

# Usage in tests
def test_developer_with_commits():
    developer = DeveloperFactory()
    commits = CommitFactory.create_batch(5, author=developer)
    assert len(commits) == 5
```

## Mocking and Stubbing

### Mocking External Services

Mock external API calls:

```python
# tests/unit/collectors/test_git_collector.py
import pytest
from unittest.mock import Mock, patch
from src.collectors.git.services.collector import GitCollector

@patch('src.collectors.git.services.collector.requests.get')
def test_fetch_commits(mock_get):
    """Test fetching commits from GitHub API."""
    # Arrange
    mock_response = Mock()
    mock_response.json.return_value = [
        {"sha": "abc123", "message": "Test commit"}
    ]
    mock_response.status_code = 200
    mock_get.return_value = mock_response

    collector = GitCollector()

    # Act
    commits = collector.fetch_commits("owner/repo")

    # Assert
    assert len(commits) == 1
    assert commits[0]["sha"] == "abc123"
    mock_get.assert_called_once()

@patch('src.collectors.git.services.collector.kafka_producer')
def test_send_to_kafka(mock_producer):
    """Test sending data to Kafka."""
    collector = GitCollector()

    collector.send_to_kafka({"data": "test"})

    mock_producer.send.assert_called_once_with(
        "commits",
        {"data": "test"}
    )
```

### Database Mocking

Use in-memory SQLite for tests:

```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.apis.database import Base

@pytest.fixture(scope="function")
def test_db():
    """Create in-memory test database."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)

    Session = sessionmaker(bind=engine)
    session = Session()

    yield session

    session.close()
```

## Testing Best Practices

### Arrange-Act-Assert Pattern

Structure tests clearly:

```python
def test_calculate_metrics():
    # Arrange - set up test data
    commits = create_test_commits(count=10)

    # Act - execute the function
    metrics = calculate_metrics(commits)

    # Assert - verify results
    assert metrics["count"] == 10
    assert metrics["velocity"] > 0
```

### Test Isolation

Ensure tests are independent:

- Use fixtures for setup and teardown
- Avoid shared state between tests
- Reset databases between tests
- Clear caches and mocks
- Don't rely on test execution order

### Descriptive Test Names

Use clear, descriptive test names:

```python
# Good
def test_calculate_velocity_returns_zero_for_empty_commits():
    pass

# Bad
def test_velocity():
    pass
```

### Test Edge Cases

Cover boundary conditions:

```python
def test_calculate_average():
    # Normal case
    assert calculate_average([1, 2, 3]) == 2

    # Edge cases
    assert calculate_average([]) == 0
    assert calculate_average([1]) == 1
    assert calculate_average([0, 0, 0]) == 0

    # Error cases
    with pytest.raises(TypeError):
        calculate_average(None)
```

### Avoid Test Duplication

Use parametrized tests:

```python
@pytest.mark.parametrize("input,expected", [
    ([], 0),
    ([1], 1),
    ([1, 2, 3], 6),
    ([0, 0, 0], 0),
])
def test_sum_values(input, expected):
    assert sum_values(input) == expected
```

## Continuous Integration

### Running Tests in CI

Tests run automatically on pull requests:

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest --cov=src --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v2
```

### Test Coverage Requirements

Enforce minimum coverage:

```ini
# pytest.ini
[pytest]
addopts = --cov=src --cov-report=term --cov-fail-under=80
```

### Pre-commit Hooks

Run tests before commits:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest
        name: pytest
        entry: pytest
        language: system
        pass_filenames: false
        always_run: true
```

## Debugging Tests

### Run Specific Tests

Run individual tests:

```bash
# Single test file
pytest tests/unit/processors/test_velocity.py

# Single test function
pytest tests/unit/processors/test_velocity.py::test_calculate_velocity

# Tests matching pattern
pytest -k "velocity"
```

### Verbose Output

Get detailed test output:

```bash
# Verbose mode
pytest -v

# Show print statements
pytest -s

# Show local variables on failure
pytest -l
```

### Debug Failed Tests

Use pytest debugging:

```bash
# Drop into debugger on failure
pytest --pdb

# Drop into debugger at start of test
pytest --trace
```

### Test Performance

Profile slow tests:

```bash
# Show slowest tests
pytest --durations=10

# Profile test execution
pytest --profile
```
