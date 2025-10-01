# Code Quality

This guide covers code quality standards, tools, and practices for the SEI Platform.

## Code Quality Standards

The SEI Platform maintains high code quality through:

- Consistent code style and formatting
- Static analysis and linting
- Type checking and validation
- Code review processes
- Automated quality checks
- Pre-commit hooks
- Continuous integration checks

## Python Code Quality

### Code Formatting

Python code uses Black for consistent formatting:

```bash
# Format all Python code
make format

# Format specific file
black src/apis/main.py

# Check formatting without changes
black --check src/
```

Black configuration in `pyproject.toml`:

```toml
[tool.black]
line-length = 100
target-version = ['py39']
include = '\.pyi?$'
exclude = '''
/(
    \.git
  | \.venv
  | build
  | dist
)/
'''
```

### Import Sorting

Use isort to organize imports:

```bash
# Sort imports
isort src/

# Check import order
isort --check-only src/

# Combined with Black
isort src/ --profile=black
```

Configuration in `pyproject.toml`:

```toml
[tool.isort]
profile = "black"
line_length = 100
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
```

### Linting

Flake8 checks for code quality issues:

```bash
# Run flake8
make lint

# Check specific file
flake8 src/apis/main.py

# Generate report
flake8 src/ --format=html --htmldir=reports/flake8
```

Configuration in `.flake8`:

```ini
[flake8]
max-line-length = 100
exclude = .git,__pycache__,build,dist,.venv
ignore = E203,E266,E501,W503
max-complexity = 10
per-file-ignores =
    __init__.py:F401
```

### Static Analysis

Pylint performs deep code analysis:

```bash
# Run pylint
pylint src/

# Check specific module
pylint src/apis/

# Generate report
pylint src/ --output-format=json > reports/pylint.json
```

Configuration in `.pylintrc`:

```ini
[MASTER]
max-line-length=100
disable=
    C0111,  # missing-docstring
    C0103,  # invalid-name
    R0903,  # too-few-public-methods

[MESSAGES CONTROL]
confidence=HIGH,INFERENCE

[DESIGN]
max-args=7
max-attributes=10
max-locals=15
```

### Type Checking

MyPy provides static type checking:

```bash
# Run mypy
mypy src/

# Check specific module
mypy src/apis/

# Generate HTML report
mypy src/ --html-report reports/mypy
```

Configuration in `mypy.ini`:

```ini
[mypy]
python_version = 3.9
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
no_implicit_optional = True

[mypy-tests.*]
ignore_errors = True
```

Type annotation examples:

```python
from typing import List, Dict, Optional
from datetime import datetime

def calculate_velocity(
    commits: List[Dict[str, any]],
    start_date: datetime,
    end_date: Optional[datetime] = None
) -> Dict[str, float]:
    """Calculate development velocity.

    Args:
        commits: List of commit dictionaries
        start_date: Start of measurement period
        end_date: End of measurement period (defaults to now)

    Returns:
        Dictionary with velocity metrics
    """
    pass
```

### Security Scanning

Bandit scans for security issues:

```bash
# Run bandit
bandit -r src/

# Generate JSON report
bandit -r src/ -f json -o reports/bandit-report.json

# Check specific severity
bandit -r src/ -ll  # Only high severity
```

Safety checks dependencies:

```bash
# Check for vulnerabilities
safety check

# Check specific requirements file
safety check -r requirements.txt

# Generate report
safety check --json > reports/safety-report.json
```

## JavaScript/TypeScript Code Quality

### Code Formatting

Prettier formats JavaScript/TypeScript code:

```bash
# Format frontend code
cd src/frontend
npm run format

# Check formatting
npm run format:check

# Format specific file
prettier --write src/components/Dashboard.tsx
```

Configuration in `.prettierrc`:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "avoid"
}
```

### Linting

ESLint checks JavaScript/TypeScript code:

```bash
# Run ESLint
cd src/frontend
npm run lint

# Fix auto-fixable issues
npm run lint:fix

# Check specific file
eslint src/components/Dashboard.tsx
```

Configuration in `.eslintrc.json`:

```json
{
  "extends": [
    "react-app",
    "react-app/jest",
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
```

### Type Checking

TypeScript compiler checks types:

```bash
# Type check
cd src/frontend
npx tsc --noEmit

# Watch mode
npx tsc --noEmit --watch
```

Configuration in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
```

## Docker Quality

### Dockerfile Linting

Hadolint checks Dockerfiles:

```bash
# Lint all Dockerfiles
make lint

# Lint specific Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile

# Generate report
docker run --rm -i hadolint/hadolint --format json < Dockerfile > reports/hadolint.json
```

Best practices for Dockerfiles:

- Use specific image tags, not latest
- Minimize layer count
- Order commands by change frequency
- Use multi-stage builds
- Don't run as root user
- Clean up in same layer
- Use .dockerignore

Example well-formatted Dockerfile:

```dockerfile
FROM python:3.9-slim as base

WORKDIR /app

# Install dependencies first (cache layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Run as non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

## Pre-commit Hooks

Pre-commit hooks ensure code quality before commits:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
make hooks-install

# Run hooks manually
pre-commit run --all-files
```

Configuration in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict

  - repo: https://github.com/psf/black
    rev: 23.11.0
    hooks:
      - id: black
        language_version: python3.9

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: ["--max-line-length=100"]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]
```

## Code Review Process

### Pull Request Requirements

All code changes require:

1. **Passing CI Checks**
    - All tests pass
    - Code coverage meets threshold
    - Linting passes
    - Type checking passes
    - Security scans pass

2. **Code Review Approval**
    - At least one reviewer approval
    - No unresolved comments
    - Changes address review feedback

3. **Documentation Updates**
    - API documentation updated
    - README updated if needed
    - Changelog entry added
    - Architecture docs updated

4. **Testing Requirements**
    - New features have tests
    - Bug fixes have regression tests
    - Test coverage maintained or improved

### Review Checklist

Reviewers should verify:

- Code follows style guidelines
- Logic is clear and correct
- Error handling is appropriate
- Security considerations addressed
- Performance implications considered
- Documentation is complete
- Tests are comprehensive
- No hardcoded credentials or secrets

### Code Review Best Practices

For authors:

- Keep PRs small and focused
- Write clear PR descriptions
- Self-review before requesting review
- Respond to feedback promptly
- Update based on comments

For reviewers:

- Review promptly (within 24 hours)
- Be constructive and specific
- Ask questions, don't demand
- Acknowledge good practices
- Test changes locally if needed

## Continuous Integration Checks

### GitHub Actions Workflow

CI pipeline runs on every push and PR:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [master, develop]
  pull_request:
    branches: [master, develop]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run linters
        run: make lint

  type-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run mypy
        run: mypy src/

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest --cov=src --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Run security checks
        run: |
          pip install safety bandit
          safety check
          bandit -r src/
```

### Required Status Checks

Configure branch protection rules:

- Require status checks to pass before merging
- Require branches to be up to date
- Require linear history
- Do not allow bypassing rules

Status checks required:

- lint
- type-check
- test
- security
- build

## Code Metrics

### Complexity Metrics

Monitor code complexity:

```bash
# Calculate cyclomatic complexity
radon cc src/ -a

# Calculate maintainability index
radon mi src/ -s

# Generate HTML report
radon cc src/ -a --total-average -o reports/complexity.html
```

Complexity thresholds:

- A (1-5): Simple, low risk
- B (6-10): Moderate complexity
- C (11-20): Complex, higher risk
- D (21-50): Very complex, test thoroughly
- F (50+): Extremely complex, consider refactoring

### Code Coverage

Maintain high test coverage:

```bash
# Generate coverage report
pytest --cov=src --cov-report=html --cov-report=term

# View detailed report
open htmlcov/index.html

# Check coverage threshold
pytest --cov=src --cov-fail-under=80
```

Coverage targets:

- Overall: 80% minimum
- Critical paths: 90%+ recommended
- New code: 100% for new features
- Bug fixes: Include regression test

### Technical Debt

Track technical debt:

- Use TODO comments sparingly
- Create issues for known problems
- Regular refactoring sessions
- Address warnings and deprecations
- Update dependencies regularly

## Best Practices

### Writing Clean Code

Follow these principles:

- Single Responsibility Principle
- Don't Repeat Yourself (DRY)
- Keep It Simple (KISS)
- Meaningful names
- Small functions (under 50 lines)
- Clear comments when needed
- Consistent error handling

### Code Organization

Maintain clean structure:

- Group related functionality
- Consistent file organization
- Clear module boundaries
- Avoid circular dependencies
- Use appropriate design patterns

### Documentation

Document effectively:

- Docstrings for all public functions
- Type hints for parameters and returns
- Clear inline comments for complex logic
- README for each module
- API documentation auto-generated

Example well-documented function:

```python
def calculate_velocity(
    commits: List[Dict[str, Any]],
    start_date: datetime,
    end_date: Optional[datetime] = None
) -> Dict[str, float]:
    """Calculate development velocity metrics.

    Analyzes commit data to compute velocity metrics including
    commit frequency, code changes, and productivity trends.

    Args:
        commits: List of commit dictionaries with keys:
            - date: Commit timestamp
            - additions: Lines added
            - deletions: Lines deleted
        start_date: Start of measurement period
        end_date: End of measurement period. Defaults to current time.

    Returns:
        Dictionary containing:
            - total_commits: Number of commits
            - total_changes: Sum of additions and deletions
            - net_changes: Additions minus deletions
            - avg_daily_commits: Average commits per day
            - velocity_score: Normalized velocity metric

    Raises:
        ValueError: If start_date is after end_date
        TypeError: If commits is not a list

    Example:
        >>> commits = [
        ...     {"date": "2024-01-01", "additions": 100, "deletions": 20},
        ...     {"date": "2024-01-02", "additions": 50, "deletions": 10}
        ... ]
        >>> result = calculate_velocity(commits, datetime(2024, 1, 1))
        >>> result["total_commits"]
        2
    """
    if not isinstance(commits, list):
        raise TypeError("commits must be a list")

    if end_date and start_date > end_date:
        raise ValueError("start_date must be before end_date")

    # Implementation here
    pass
```

### Error Handling

Handle errors consistently:

- Use specific exception types
- Log errors with context
- Provide helpful error messages
- Clean up resources properly
- Don't catch exceptions silently

Example:

```python
import logging
from typing import Optional

logger = logging.getLogger(__name__)

def fetch_data(repo_id: str) -> Optional[dict]:
    """Fetch repository data with proper error handling."""
    try:
        response = api_client.get(f"/repos/{repo_id}")
        response.raise_for_status()
        return response.json()

    except requests.HTTPError as e:
        if e.response.status_code == 404:
            logger.warning(f"Repository not found: {repo_id}")
            return None
        logger.error(f"HTTP error fetching repo {repo_id}: {e}")
        raise

    except requests.RequestException as e:
        logger.error(f"Network error fetching repo {repo_id}: {e}")
        raise

    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON response for repo {repo_id}: {e}")
        raise

    finally:
        # Cleanup if needed
        pass
```

## Automated Quality Gates

### Quality Metrics Thresholds

Enforce quality standards:

- Code coverage: 80% minimum
- Complexity: A-B rating required
- Linting: Zero errors
- Type coverage: 90% minimum
- Security: No high/critical issues
- Duplication: Under 5%

### Fail Fast Strategy

Stop builds on quality issues:

- Failed tests block merge
- Linting errors prevent deployment
- Security vulnerabilities block release
- Coverage drops rejected
- Type errors must be fixed

### Quality Dashboard

Monitor quality metrics:

- Code coverage trends
- Complexity over time
- Technical debt tracking
- Security vulnerability count
- Test execution time
- Build success rate

Tools for monitoring:

- SonarQube for code quality
- Codecov for coverage tracking
- Dependabot for dependency updates
- GitHub Security for vulnerability alerts
