# Pull Request Guide

This guide covers the pull request process for the SEI Platform project, from creation to merge.

## Before Creating a Pull Request

### Check Prerequisites

Before opening a PR, ensure you have:

- Created an issue describing the change (unless it's a trivial fix)
- Discussed the approach with maintainers (for significant changes)
- Read the contributing guidelines
- Set up your development environment
- Created a feature branch from the latest master

### Run Local Checks

Run all checks locally before pushing:

```bash
# Run linters
make lint

# Run formatters
make format

# Run all tests
make test

# Check test coverage
make test-coverage

# Run security scans
make security
```

Fix any issues before proceeding.

## Creating a Pull Request

### PR Title

Follow conventional commits format for PR titles:

**Format**:

```
<type>(<scope>): <description>
```

**Types**:

- feat: New feature
- fix: Bug fix
- docs: Documentation only
- style: Code style changes (formatting, etc.)
- refactor: Code refactoring
- perf: Performance improvements
- test: Adding or updating tests
- chore: Build process or tooling changes

**Examples**:

```
feat(api): add DORA metrics calculation endpoint
fix(database): resolve connection pool exhaustion
docs(deployment): update Kubernetes deployment guide
refactor(auth): simplify JWT token validation
```

### PR Description

Use the provided PR template and include:

**Summary**: Brief description of what and why

```markdown
## Summary

This PR adds support for calculating DORA metrics (deployment frequency,
lead time for changes, change failure rate, and mean time to recovery)
for teams. This addresses the core requirement for engineering metrics
tracking.
```

**Related Issues**: Link related issues

```markdown
## Related Issues

Closes #123
Relates to #456
```

**Changes Made**: List key changes

```markdown
## Changes Made

- Implemented DORA metrics calculation service
- Added new API endpoints for metrics retrieval
- Created database migrations for metrics storage
- Added comprehensive unit and integration tests
- Updated API documentation
```

**Testing**: Describe testing performed

```markdown
## Testing

- Added unit tests with 95% coverage
- Integration tests verify end-to-end flow
- Manually tested against production-like dataset
- Load tested with 10,000 requests/second
```

**Screenshots**: For UI changes, include before/after screenshots

```markdown
## Screenshots

### Before
![Before](path/to/before.png)

### After
![After](path/to/after.png)
```

**Breaking Changes**: Call out any breaking changes

```markdown
## Breaking Changes

- Changed API endpoint from `/metrics` to `/api/v1/metrics`
- Renamed `team_id` parameter to `teamId` for consistency

### Migration Guide

Update API calls:
​```diff
- GET /metrics?team_id=123
+ GET /api/v1/metrics?teamId=123
​```
```

**Checklist**: Complete the checklist

```markdown
## Checklist

- [x] Tests added/updated
- [x] Documentation updated
- [x] Code follows style guide
- [x] All tests passing
- [x] No breaking changes (or documented)
```

## PR Size and Scope

### Keep PRs Small

Aim for PRs with:

- Less than 500 lines of code changed
- Single, focused purpose
- Clear scope and boundaries

### Split Large Changes

For large features, create multiple PRs:

1. **PR 1**: Database schema and models
2. **PR 2**: Core business logic
3. **PR 3**: API endpoints
4. **PR 4**: Frontend components
5. **PR 5**: Documentation and examples

Each PR should be independently reviewable and mergeable.

### Draft PRs

For work in progress:

```markdown
## [WIP] Feature Name

This is a work in progress to gather early feedback on the approach.

Current status:
- [x] Database schema designed
- [x] Core logic implemented
- [ ] Tests to be added
- [ ] Documentation pending

Feedback needed on:
- API design approach
- Error handling strategy
```

Mark as draft until ready for full review.

## Code Review Process

### Automated Checks

When you create a PR, automated checks run:

**Continuous Integration**:

- Linting (flake8, pylint, ESLint)
- Formatting (Black, Prettier)
- Type checking (mypy, TypeScript)
- Unit tests
- Integration tests
- Security scanning (Bandit, npm audit)
- Code coverage analysis

**All checks must pass** before review.

### Reviewer Assignment

The system automatically assigns reviewers based on:

- Code ownership (CODEOWNERS file)
- Area of expertise
- Recent activity
- Availability

You can also request specific reviewers.

### Review Timeline

Expected timeline:

- Initial review: Within 2 business days
- Follow-up reviews: Within 1 business day
- Merge: After approval and CI passes

### Addressing Review Comments

When you receive feedback:

**1. Read all comments carefully**

Understand the feedback before responding or making changes.

**2. Respond to each comment**

Either:

- Acknowledge and make the requested change
- Ask for clarification if needed
- Explain your approach if you disagree

**3. Make requested changes**

Commit changes with clear messages:

```bash
git commit -m "refactor: extract validation logic to separate function

Addresses review feedback from @reviewer"
```

**4. Re-request review**

After addressing all comments:

```bash
# Push changes
git push origin feature/your-feature

# Request re-review on GitHub UI
```

**5. Mark resolved**

When you've addressed a comment, mark it as resolved.

### Common Review Feedback

#### Code Quality

**Issue**: Complex function needs simplification

```python
# Reviewer feedback: This function is too complex

# Before
def process_data(data):
    result = []
    for item in data:
        if item['type'] == 'metric':
            if item['value'] > 0:
                if item['team_id'] in allowed_teams:
                    result.append(transform(item))
    return result

# After: Extracted helper functions
def is_valid_metric(item):
    return (item['type'] == 'metric' and
            item['value'] > 0 and
            item['team_id'] in allowed_teams)

def process_data(data):
    valid_metrics = filter(is_valid_metric, data)
    return [transform(item) for item in valid_metrics]
```

#### Testing

**Issue**: Missing test cases

```python
# Reviewer feedback: Add tests for error cases

# Add edge case tests
def test_calculate_metrics_with_empty_data():
    """Test that empty data returns default values."""
    result = calculate_metrics(team_id="123", data=[])
    assert result.deployment_frequency == 0
    assert result.lead_time == 0

def test_calculate_metrics_with_invalid_team():
    """Test that invalid team raises error."""
    with pytest.raises(TeamNotFoundError):
        calculate_metrics(team_id="invalid", data=test_data)
```

#### Documentation

**Issue**: Missing docstring

```python
# Reviewer feedback: Add docstring

def calculate_dora_metrics(team_id: str, start_date: datetime, end_date: datetime):
    """
    Calculate DORA metrics for a team within a date range.

    Args:
        team_id: Unique identifier for the team
        start_date: Start of the date range (inclusive)
        end_date: End of the date range (inclusive)

    Returns:
        DORAMetrics object containing:
        - deployment_frequency: Deployments per day
        - lead_time: Average hours from commit to deploy
        - change_failure_rate: Percentage of failed deployments
        - recovery_time: Average hours to recover from failure

    Raises:
        ValueError: If date range is invalid
        TeamNotFoundError: If team_id doesn't exist
    """
```

#### Performance

**Issue**: N+1 query problem

```python
# Reviewer feedback: This causes N+1 queries

# Before
def get_teams_with_members():
    teams = Team.query.all()
    return [
        {
            'team': team,
            'members': team.members.all()  # N+1: Query for each team
        }
        for team in teams
    ]

# After: Use eager loading
def get_teams_with_members():
    teams = Team.query.options(
        joinedload(Team.members)
    ).all()
    return [
        {
            'team': team,
            'members': team.members  # Already loaded
        }
        for team in teams
    ]
```

## Merging

### Merge Criteria

PRs are merged when:

- All automated checks pass
- At least one maintainer approves
- All review comments addressed
- No merge conflicts
- Branch is up-to-date with master

### Merge Strategies

We use **squash and merge** for most PRs:

- Creates single commit on master
- Keeps history clean
- Preserves PR reference

For some cases, we use **merge commit**:

- Feature branches with meaningful commit history
- PRs with co-authors
- When commits tell a story

### Post-Merge

After your PR is merged:

**1. Delete your branch**

```bash
git branch -d feature/your-feature
git push origin --delete feature/your-feature
```

**2. Update your local master**

```bash
git checkout master
git pull upstream master
```

**3. Verify in production**

Monitor that your changes work as expected in production.

**4. Close related issues**

If not automatically closed, manually close related issues.

## Troubleshooting

### CI Failures

**Linting failures**:

```bash
# Run linter locally
make lint

# Auto-fix issues
make format
```

**Test failures**:

```bash
# Run tests locally
make test

# Run specific test
pytest tests/test_specific.py -v

# Debug failing test
pytest tests/test_specific.py -v -s --pdb
```

**Merge conflicts**:

```bash
# Update from master
git fetch upstream
git rebase upstream/master

# Resolve conflicts
# Edit conflicting files
git add .
git rebase --continue

# Force push (be careful!)
git push origin feature/your-feature --force-with-lease
```

### Review Delays

If your PR hasn't been reviewed:

- Ensure all CI checks pass
- Ping in PR comments after 3 business days
- Ask in Discord #dev channel
- Email maintainers@sei-platform.org

### Disagreements

If you disagree with feedback:

1. Explain your reasoning politely
2. Provide evidence (benchmarks, examples)
3. Suggest alternatives
4. Be open to compromise

If no consensus, maintainers make final decision.

## Best Practices

### Before Submitting

- Test locally in clean environment
- Review your own code first
- Check diff for unintended changes
- Verify no debug code or console.logs
- Ensure no secrets or credentials

### During Review

- Respond promptly to feedback
- Ask questions if unclear
- Be receptive to suggestions
- Thank reviewers for their time

### Communication

- Be professional and respectful
- Focus on code, not people
- Explain your reasoning
- Admit mistakes gracefully

### Learning

- Learn from feedback
- Apply lessons to future PRs
- Help review others' PRs
- Contribute to review discussions

## PR Templates

### Bug Fix Template

```markdown
## Bug Fix: [Brief Description]

### Problem
[Describe the bug and its impact]

### Root Cause
[Explain what caused the bug]

### Solution
[Describe how you fixed it]

### Testing
- [ ] Added regression test
- [ ] Verified fix in development
- [ ] Tested edge cases

Fixes #[issue-number]
```

### Feature Template

```markdown
## Feature: [Feature Name]

### Description
[What does this feature do and why is it needed?]

### Implementation
[Key technical decisions and approach]

### Testing
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Documentation updated

Closes #[issue-number]
```

### Documentation Template

```markdown
## Documentation: [Area]

### Changes
[What documentation was added/updated?]

### Motivation
[Why was this documentation needed?]

### Checklist
- [ ] Checked for broken links
- [ ] Verified code examples work
- [ ] Updated table of contents if needed
```

## Additional Resources

- [Contributing Guidelines](guidelines.md)
- [Code Style Guide](code-style.md)
- [GitHub Pull Request Documentation](https://docs.github.com/en/pull-requests)
- [Conventional Commits](https://www.conventionalcommits.org/)

## Questions?

- Check [GitHub Discussions](https://github.com/rcdelacruz/open-source-sei-platform/discussions)
- Ask in Discord #dev channel
- Email contributors@sei-platform.org

Thank you for contributing to the SEI Platform!
