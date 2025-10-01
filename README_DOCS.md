# Documentation Guide

This project uses MkDocs with Material theme for documentation.

## Features

- Developer-friendly navigation
- Minimal, clean design
- Work Sans font family
- Three-pane layout:
  - Left: Navigation menu
  - Center: Content with comfortable padding
  - Right: Table of contents for current page
- Full viewport utilization
- No emojis (clean, professional appearance)
- Dark/light mode support
- Code syntax highlighting
- Mobile responsive

## Local Development

### Prerequisites

Install MkDocs and dependencies:

```bash
pip3 install --user mkdocs mkdocs-material pymdown-extensions
```

Or using the requirements file:

```bash
pip3 install --user -r requirements-docs.txt
```

### Serve Documentation Locally

Start the development server:

```bash
mkdocs serve
```

The documentation will be available at: http://127.0.0.1:8000

With custom port:

```bash
mkdocs serve --dev-addr=127.0.0.1:8085
```

### Build Documentation

Build static site:

```bash
mkdocs build
```

Output will be in the `site/` directory.

## Documentation Structure

```
docs/
├── index.md                    # Homepage
├── getting-started/
│   ├── overview.md
│   ├── quick-start.md
│   ├── installation.md
│   └── configuration.md
├── development/
│   ├── environment-setup.md
│   ├── project-structure.md
│   ├── running-services.md
│   ├── testing.md
│   └── code-quality.md
├── architecture/
│   ├── overview.md
│   ├── system-design.md
│   ├── data-models.md
│   ├── api-design.md
│   ├── database-schema.md
│   └── security.md
├── api/
│   ├── introduction.md
│   ├── authentication.md
│   ├── organizations.md
│   ├── teams.md
│   ├── repositories.md
│   ├── developers.md
│   └── analytics.md
├── services/
│   ├── api-service.md
│   ├── git-collector.md
│   ├── jira-collector.md
│   └── data-processor.md
├── deployment/
│   ├── docker-compose.md
│   ├── kubernetes.md
│   ├── production.md
│   └── monitoring.md
├── contributing/
│   ├── guidelines.md
│   ├── code-style.md
│   ├── pull-requests.md
│   └── roadmap.md
└── progress/
    ├── current-status.md
    ├── completed-sprints.md
    └── upcoming-work.md
```

## Configuration

Documentation configuration is in `mkdocs.yml`. Key settings:

### Theme Customization

- **Font**: Work Sans (text) and JetBrains Mono (code)
- **Colors**: Indigo primary and accent
- **Features**: Navigation tabs, table of contents, search

### Custom CSS

Custom styling is in `docs/stylesheets/extra.css`:

- Full viewport layout
- Work Sans font enforcement
- Comfortable content padding
- Improved readability
- Clean table and code styling

### Custom JavaScript

Custom JavaScript is in `docs/javascripts/extra.js`:

- Emoji removal functionality
- Additional enhancements as needed

## Writing Documentation

### Markdown Extensions

Available extensions:

- **Admonitions**: Note, warning, tip boxes
- **Code highlighting**: Syntax highlighting for all languages
- **Tables**: Full table support
- **Mermaid**: Diagrams and flowcharts
- **Task lists**: Checkboxes in lists
- **Tabs**: Tabbed content blocks

### Examples

#### Admonition

```markdown
!!! note
    This is a note

!!! warning
    This is a warning
```

#### Code Block

```markdown
```python
def hello():
    print("Hello, World!")
```​
```

#### Table

```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

#### Mermaid Diagram

```markdown
```mermaid
graph LR
    A[Start] --> B[Process]
    B --> C[End]
```​
```

## Style Guide

### No Emojis

This documentation avoids emojis for a professional appearance.

Bad:
```
## Installation 🚀
```

Good:
```
## Installation
```

### Clear Headers

Use descriptive headers:

```markdown
# Main Title
## Section
### Subsection
```

### Code Examples

Always provide complete, working examples:

```markdown
```bash
# Good: Complete command
curl http://localhost:8080/health

# Bad: Partial command
curl localhost...
```​
```

### Links

Use descriptive link text:

Good:
```markdown
See the [Installation Guide](installation.md)
```

Bad:
```markdown
Click [here](installation.md)
```

## Deployment

### GitHub Pages

Deploy to GitHub Pages:

```bash
mkdocs gh-deploy
```

This builds and pushes to the `gh-pages` branch.

### Custom Domain

Configure in `mkdocs.yml`:

```yaml
site_url: https://your-domain.com
```

## Troubleshooting

### Build Errors

Check for:
- Missing files referenced in navigation
- Broken internal links
- Invalid markdown syntax

### Serve Issues

If the server won't start:

```bash
# Kill existing process
pkill -f "mkdocs serve"

# Start fresh
mkdocs serve
```

### Plugin Errors

If you see plugin errors, check `mkdocs.yml` plugins section and ensure dependencies are installed.

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)

## Maintenance

### Regular Tasks

1. Update content as features are added
2. Keep screenshots current
3. Verify all links work
4. Review and update examples
5. Maintain consistency in style

### Version Updates

When updating MkDocs or plugins:

```bash
pip3 install --user --upgrade mkdocs mkdocs-material pymdown-extensions
```