# Contributing Guidelines

Thank you for your interest in contributing to the Open Source SEI Platform. This document provides guidelines and best practices for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful, inclusive, and collaborative environment. We expect all contributors to:

- Be respectful and considerate in all interactions
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Accept differing viewpoints gracefully
- Prioritize the community's best interests

Report unacceptable behavior to conduct@sei-platform.org.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- Git installed and configured
- Docker and Docker Compose
- Python 3.10 or higher
- Node.js 18 or higher
- kubectl (for Kubernetes development)
- A GitHub account

### Setting Up Development Environment

1. Fork the repository on GitHub

2. Clone your fork:

    ```bash
    git clone https://github.com/YOUR_USERNAME/open-source-sei-platform.git
    cd open-source-sei-platform
    ```

3. Add upstream remote:

    ```bash
    git remote add upstream https://github.com/rcdelacruz/open-source-sei-platform.git
    ```

4. Set up the development environment:

    ```bash
    make quickstart
    ```

5. Verify the setup:

    ```bash
    make test
    ```

### Development Workflow

1. Create a feature branch:

    ```bash
    git checkout -b feature/your-feature-name
    ```

2. Make your changes following the code style guide

3. Write or update tests for your changes

4. Run tests locally:

    ```bash
    make test
    make lint
    ```

5. Commit your changes with a descriptive message:

    ```bash
    git commit -m "Add feature: description of your changes"
    ```

6. Keep your branch updated:

    ```bash
    git fetch upstream
    git rebase upstream/master
    ```

7. Push to your fork:

    ```bash
    git push origin feature/your-feature-name
    ```

8. Open a Pull Request on GitHub

## Contribution Types

### Bug Reports

When reporting bugs, include:

- Clear, descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- Environment details (OS, versions, etc.)
- Screenshots if applicable
- Relevant logs or error messages

Use the bug report template when creating issues.

### Feature Requests

For new features, provide:

- Problem description and use case
- Proposed solution
- Alternative solutions considered
- Impact on existing features
- Implementation complexity estimate

Use the feature request template when creating issues.

### Documentation

Documentation improvements are always welcome:

- Fix typos and grammatical errors
- Clarify confusing sections
- Add missing documentation
- Update outdated content
- Create tutorials and examples

### Code Contributions

Code contributions should:

- Address a specific issue or feature request
- Include comprehensive tests
- Follow the code style guidelines
- Update relevant documentation
- Pass all CI/CD checks

## Code Review Process

All contributions go through code review:

1. Automated checks run on PR creation:

    - Linting and formatting
    - Unit tests
    - Integration tests
    - Security scans
    - Code coverage analysis

2. Maintainers review the code for:

    - Code quality and maintainability
    - Test coverage
    - Documentation completeness
    - Breaking changes
    - Performance implications

3. Address review feedback:

    - Make requested changes
    - Respond to comments
    - Update tests if needed

4. Once approved, maintainers merge the PR

## Testing Guidelines

### Unit Tests

Write unit tests for all new code:

```python
import pytest
from app.services import DataCollector

def test_data_collector_initialization():
    collector = DataCollector(api_key="test_key")
    assert collector.is_authenticated()

def test_data_collection_success():
    collector = DataCollector(api_key="test_key")
    result = collector.collect_data()
    assert result.status == "success"
    assert len(result.data) > 0
```

### Integration Tests

Test interactions between components:

```python
@pytest.mark.integration
def test_api_to_database_flow():
    # Create test data via API
    response = client.post('/api/v1/metrics', json=test_data)
    assert response.status_code == 201

    # Verify data in database
    record = db.query(Metric).filter_by(id=response.json['id']).first()
    assert record is not None
    assert record.value == test_data['value']
```

### End-to-End Tests

Test complete user workflows:

```javascript
describe('Dashboard Workflow', () => {
  it('should display team metrics', async () => {
    await page.goto('http://localhost:3000/dashboard');
    await page.waitForSelector('.metrics-card');

    const metrics = await page.$$eval('.metric-value',
      els => els.map(el => el.textContent)
    );

    expect(metrics.length).toBeGreaterThan(0);
  });
});
```

### Test Coverage

Maintain high test coverage:

- Aim for 80% overall coverage
- 90% for critical paths
- 100% for security-sensitive code

Run coverage reports:

```bash
make test-coverage
```

## Documentation Requirements

All code changes must include documentation:

### Code Documentation

Add docstrings to all functions and classes:

```python
def calculate_dora_metrics(team_id: str, start_date: datetime, end_date: datetime) -> DORAMetrics:
    """
    Calculate DORA metrics for a team within a date range.

    Args:
        team_id: Unique identifier for the team
        start_date: Start of the date range
        end_date: End of the date range

    Returns:
        DORAMetrics object containing calculated metrics

    Raises:
        ValueError: If date range is invalid
        TeamNotFoundError: If team_id doesn't exist
    """
    # Implementation
```

### API Documentation

Document all API endpoints:

```python
@app.route('/api/v1/teams/<team_id>/metrics', methods=['GET'])
def get_team_metrics(team_id):
    """
    Get metrics for a specific team.

    Path Parameters:
        team_id (str): Team identifier

    Query Parameters:
        start_date (str): Start date in ISO 8601 format
        end_date (str): End date in ISO 8601 format
        metric_type (str): Type of metrics to retrieve

    Returns:
        200: Metrics data
        404: Team not found
        400: Invalid parameters
    """
```

### User Documentation

Update user-facing documentation:

- Add new features to user guides
- Update screenshots if UI changed
- Add usage examples
- Update troubleshooting guides

## Commit Message Guidelines

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:

- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code formatting (no logic changes)
- refactor: Code refactoring
- perf: Performance improvements
- test: Adding or updating tests
- chore: Build process or auxiliary tool changes

Examples:

```
feat(api): add DORA metrics calculation endpoint

Implement new endpoint for calculating DORA metrics including
deployment frequency, lead time, change failure rate, and MTTR.

Closes #123
```

```
fix(database): resolve connection pool exhaustion

Fixed issue where database connections were not being properly
released, causing pool exhaustion under high load.

Fixes #456
```

## Branch Naming

Use descriptive branch names:

- feature/add-github-integration
- fix/database-connection-leak
- docs/update-installation-guide
- refactor/simplify-auth-flow

## Pull Request Guidelines

### PR Title

Use clear, descriptive titles:

- Good: "Add support for GitLab data collection"
- Good: "Fix memory leak in data processor"
- Bad: "Update code"
- Bad: "Bug fix"

### PR Description

Include in the description:

- Summary of changes
- Related issue numbers
- Testing performed
- Screenshots (for UI changes)
- Breaking changes
- Migration notes

Use the PR template provided.

### PR Size

Keep PRs focused and manageable:

- Aim for <500 lines of code
- One feature or fix per PR
- Split large changes into multiple PRs
- Create draft PRs for work in progress

## Security

### Reporting Security Issues

Do not open public issues for security vulnerabilities.

Email security@sei-platform.org with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

### Security Guidelines

- Never commit secrets or credentials
- Use environment variables for configuration
- Validate all user inputs
- Implement proper authentication and authorization
- Follow OWASP security best practices
- Keep dependencies updated

## Performance Considerations

When contributing, consider performance:

- Profile before optimizing
- Use appropriate data structures
- Implement caching where beneficial
- Minimize database queries
- Use async/await for I/O operations
- Add indexes for frequently queried fields

## Accessibility

Ensure contributions are accessible:

- Use semantic HTML
- Provide alt text for images
- Ensure keyboard navigation
- Meet WCAG 2.1 Level AA standards
- Test with screen readers
- Maintain sufficient color contrast

## Internationalization

Prepare for future internationalization:

- Avoid hardcoded strings
- Use i18n libraries
- Format dates, numbers, and currencies properly
- Consider RTL language support
- Use Unicode for text handling

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project README
- Annual contributor highlights

Significant contributors may be invited to join the maintainers team.

## Getting Help

Need help with your contribution?

- Ask questions in GitHub Discussions
- Join our Discord channel
- Email contributors@sei-platform.org
- Check the FAQ in documentation

## Resources

- [Code Style Guide](code-style.md)
- [Pull Request Guide](pull-requests.md)
- [Project Roadmap](roadmap.md)
- [Architecture Documentation](../architecture/overview.md)

Thank you for contributing to the Open Source SEI Platform!
