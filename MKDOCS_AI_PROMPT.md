# AI Prompt: Generate MkDocs Material Documentation

Use this prompt to have AI generate a complete MkDocs Material documentation site with professional styling.

---

## Prompt for AI

Create a complete MkDocs Material documentation site with the following specifications:

### Project Configuration

Generate these files with the following structure:

```
PROJECT_ROOT/
├── docs/
│   ├── stylesheets/
│   │   └── extra.css
│   ├── javascripts/
│   │   ├── mermaid-init.js
│   │   └── nav-scroll.js
│   ├── overrides/
│   └── index.md
└── mkdocs.yml
```

### Requirements

1. **Create mkdocs.yml** with:
   - Material theme with custom_dir: docs/overrides
   - Work Sans font for text, JetBrains Mono for code
   - Indigo/black color palette with blue accent
   - Full markdown extension suite including Mermaid support
   - Navigation structure for the project

2. **Create docs/stylesheets/extra.css** with this COMPLETE file:

```css
/* Custom styles for Professional Documentation */

@import url('https://fonts.googleapis.com/css2?family=Work+Sans:wght@300;400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap');

:root {
  --md-primary-fg-color: #2C3E50;
  --md-accent-fg-color: #3498DB;
  --md-content-padding: 0.75rem 1rem;
  --md-sidebar-width: 15rem;
  --md-toc-width: 12rem;
}

.md-tabs { display: none !important; }

.md-header {
  position: fixed;
  width: 100%;
  left: 0;
  right: 0;
}

.md-header__inner {
  padding: 0 1rem;
  max-width: none;
}

.md-header__topic {
  margin-left: 0;
}

body {
  font-family: 'Work Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  font-weight: 400;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code, pre, .md-typeset code {
  font-family: 'JetBrains Mono', 'Courier New', monospace;
  font-weight: 400;
}

.md-container {
  max-width: none;
}

.md-main__inner {
  max-width: none;
  margin: 0;
}

html {
  overflow-y: scroll;
}

body {
  overflow-y: scroll;
}

.md-sidebar--primary {
  width: var(--md-sidebar-width);
  left: 0;
  position: fixed;
  height: 100%;
  top: 3.6rem;
  padding-top: 0;
  background-color: #fafafa;
  border-right: 1px solid #e0e0e0;
  z-index: 1;
  overflow: hidden;
}

[data-md-color-scheme="slate"] .md-sidebar--primary {
  background-color: #1e1e1e;
  border-right: 1px solid #333;
}

.md-sidebar--primary .md-sidebar__scrollwrap {
  overflow-y: scroll;
  overflow-x: hidden;
  height: calc(100vh - 3.6rem);
  padding: 0;
  scrollbar-width: thin;
  scrollbar-color: #ccc transparent;
  width: 100%;
}

.md-sidebar--primary .md-sidebar__scrollwrap::-webkit-scrollbar {
  width: 6px;
}

.md-sidebar--primary .md-sidebar__scrollwrap::-webkit-scrollbar-track {
  background: transparent;
}

.md-sidebar--primary .md-sidebar__scrollwrap::-webkit-scrollbar-thumb {
  background-color: #ccc;
  border-radius: 3px;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-sidebar__scrollwrap::-webkit-scrollbar-thumb {
  background-color: #444;
}

.md-sidebar--primary .md-sidebar__inner {
  width: 100%;
  padding: 0.5rem 0;
}

.md-sidebar--primary .md-nav {
  width: 100%;
  padding: 0;
  margin: 0;
}

.md-sidebar--primary .md-nav__title {
  display: none;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list {
  margin: 0;
  padding: 0;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item {
  margin: 0;
  border-bottom: 1px solid #e8e8e8;
  width: 100%;
  display: block;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item {
  border-bottom: 1px solid #2a2a2a;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item:last-child {
  border-bottom: none;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item > .md-nav__link {
  font-weight: 600;
  font-size: 0.693rem;
  padding: 0.55rem 1rem;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #666;
  background-color: #f5f5f5;
  display: block;
  width: 100%;
  transition: background-color 0.2s ease, color 0.2s ease;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item > .md-nav__link {
  color: #999;
  background-color: #252525;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item > .md-nav__link:hover {
  background-color: #eeeeee;
  color: #333;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item > .md-nav__link:hover {
  background-color: #2a2a2a;
  color: #ccc;
}

.md-sidebar--primary .md-nav__item--nested > .md-nav > .md-nav__list {
  padding: 0;
  margin: 0;
  background-color: white;
  display: block;
  width: 100%;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav__item--nested > .md-nav > .md-nav__list {
  background-color: #1a1a1a;
}

.md-sidebar--primary .md-nav__item--nested .md-nav__link {
  font-size: 0.7392rem;
  font-weight: 400;
  padding: 0.45rem 1rem 0.45rem 1.75rem;
  margin: 0;
  border-left: 3px solid transparent;
  transition: background-color 0.2s ease, color 0.2s ease, border-left-color 0.2s ease;
  color: #555;
  display: block;
  width: 100%;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav__item--nested .md-nav__link {
  color: #aaa;
}

.md-sidebar--primary .md-nav__item--nested .md-nav__link:hover {
  background-color: #f8f8f8;
  border-left-color: #3498DB;
  color: #333;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav__item--nested .md-nav__link:hover {
  background-color: #242424;
  color: #fff;
}

.md-sidebar--primary .md-nav__item--nested .md-nav__link--active {
  color: #3498DB;
  font-weight: 500;
  background-color: #e8f4fd;
  border-left-color: #3498DB;
}

[data-md-color-scheme="slate"] .md-sidebar--primary .md-nav__item--nested .md-nav__link--active {
  color: #5dade2;
  background-color: #1e3a52;
  border-left-color: #5dade2;
}

.md-sidebar--primary .md-nav__item {
  padding: 0;
  margin: 0;
  display: block;
  width: 100%;
}

.md-sidebar--primary .md-nav__item .md-nav__item {
  margin: 0;
  padding: 0;
}

.md-sidebar--primary .md-nav__icon {
  display: none;
}

.md-sidebar--primary .md-nav__link--index {
  position: relative;
}

.md-sidebar--primary .md-nav__link {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  box-sizing: border-box;
}

.md-sidebar--primary .md-nav__item--nested .md-nav__link--index {
  display: none;
}

.md-sidebar--primary .md-nav--primary > .md-nav__list > .md-nav__item > .md-nav__link {
  display: block;
}

.md-sidebar--primary .md-nav__item--active > label.md-nav__link + a.md-nav__link {
  display: none !important;
}

.md-sidebar--primary .md-nav__item > input.md-nav__toggle + label.md-nav__link + a.md-nav__link {
  display: none !important;
}

.md-sidebar--primary .md-nav__item--active > label.md-nav__link {
  display: block;
  cursor: pointer;
}

.md-sidebar--primary .md-nav__item--nested > .md-nav {
  display: block;
  width: 100%;
  overflow: hidden;
}

.md-sidebar--primary .md-nav__toggle:checked ~ .md-nav__list {
  max-height: none;
}

.md-sidebar--primary .md-nav__list {
  overflow: hidden;
}

.md-sidebar--primary .md-nav--primary {
  font-size: 0.7392rem;
}

.md-content {
  padding: 0;
  max-width: none;
  margin-left: var(--md-sidebar-width);
  margin-right: var(--md-toc-width);
  min-height: 100vh;
}

.md-content__inner {
  margin: 0 auto;
  max-width: 1000px;
  padding: 0.5rem 1rem;
}

.md-main {
  margin-top: 3.6rem;
}

.md-main__inner {
  margin-top: 0;
  min-height: calc(100vh - 3.6rem);
}

.md-sidebar--secondary {
  width: var(--md-toc-width);
  right: 0;
  position: fixed;
  height: 100%;
  top: 3.6rem;
  padding-top: 0;
  overflow: hidden;
}

.md-sidebar--secondary .md-sidebar__scrollwrap {
  overflow-y: scroll;
  overflow-x: hidden;
  height: calc(100vh - 3.6rem);
  padding: 0.5rem 0;
  scrollbar-width: thin;
  scrollbar-color: #ccc transparent;
}

.md-sidebar--secondary .md-sidebar__scrollwrap::-webkit-scrollbar {
  width: 6px;
}

.md-sidebar--secondary .md-sidebar__scrollwrap::-webkit-scrollbar-track {
  background: transparent;
}

.md-sidebar--secondary .md-sidebar__scrollwrap::-webkit-scrollbar-thumb {
  background-color: #ccc;
  border-radius: 3px;
}

[data-md-color-scheme="slate"] .md-sidebar--secondary .md-sidebar__scrollwrap::-webkit-scrollbar-thumb {
  background-color: #444;
}

.md-sidebar--secondary .md-nav__title {
  font-weight: 600;
  font-size: 0.693rem;
  padding: 0.55rem 1rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

[data-md-color-scheme="slate"] .md-sidebar--secondary .md-nav__title {
  color: #999;
}

.md-sidebar--secondary .md-nav__link {
  font-size: 0.7392rem;
  font-weight: 400;
  padding: 0.45rem 1rem 0.45rem 1rem;
  margin: 0;
  border-left: 3px solid transparent;
  transition: all 0.2s ease;
  color: #555;
}

[data-md-color-scheme="slate"] .md-sidebar--secondary .md-nav__link {
  color: #aaa;
}

.md-sidebar--secondary .md-nav__link:hover {
  border-left-color: #3498DB;
  color: #333;
}

[data-md-color-scheme="slate"] .md-sidebar--secondary .md-nav__link:hover {
  color: #fff;
}

.md-sidebar--secondary .md-nav__link--active {
  border-left-color: #3498DB;
  font-weight: 500;
  color: #3498DB;
}

[data-md-color-scheme="slate"] .md-sidebar--secondary .md-nav__link--active {
  color: #5dade2;
  border-left-color: #5dade2;
}

.md-typeset {
  font-size: 0.8316rem;
  line-height: 1.5;
  letter-spacing: 0;
}

.md-typeset h1 {
  font-weight: 700;
  font-size: 1.6632rem;
  margin-bottom: 0.5rem;
  margin-top: 0;
  letter-spacing: -0.02em;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  padding-bottom: 0.3rem;
}

.md-typeset h2 {
  font-weight: 600;
  font-size: 1.2936rem;
  margin-top: 1rem;
  margin-bottom: 0.4rem;
  letter-spacing: -0.01em;
}

.md-typeset h3 {
  font-weight: 600;
  font-size: 1.0626rem;
  margin-top: 0.75rem;
  margin-bottom: 0.3rem;
}

.md-typeset h4 {
  font-weight: 600;
  font-size: 0.924rem;
  margin-top: 0.5rem;
  margin-bottom: 0.3rem;
}

.md-typeset p {
  margin-bottom: 0.5rem;
}

.md-typeset pre {
  border-radius: 4px;
  padding: 0.5rem;
  margin: 0.5rem 0;
  line-height: 1.4;
}

.md-typeset code {
  padding: 0.1rem 0.35rem;
  border-radius: 2px;
  font-size: 0.79464em;
}

.md-typeset table:not([class]) {
  font-size: 0.7854rem;
  border-radius: 0;
  overflow: hidden;
  margin: 0.5rem 0;
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.md-typeset table:not([class]) th {
  font-weight: 600;
  background-color: rgba(0, 0, 0, 0.04);
  color: var(--md-default-fg-color);
  padding: 0.6rem 0.75rem;
  border-bottom: 2px solid rgba(0, 0, 0, 0.1);
}

.md-typeset table:not([class]) td {
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.md-nav__item {
  padding: 0;
}

.md-nav__link {
  transition: all 0.15s ease;
}

.md-typeset .admonition {
  border-radius: 0;
  border-left-width: 3px;
  margin: 0.5rem 0;
  padding: 0.4rem 0.6rem;
}

.md-typeset .admonition-title {
  font-weight: 600;
  font-size: 0.7854rem;
  margin-bottom: 0.3rem;
}

.md-search__input {
  font-family: 'Work Sans', sans-serif;
  border-radius: 6px;
}

.md-footer {
  display: none;
}

.md-content__inner {
  padding-bottom: 2rem;
}

@media screen and (max-width: 76.1875em) {
  .md-content {
    padding: 0.75rem 1rem;
  }
  .md-content__inner {
    padding: 0 0.75rem;
  }
  .md-footer {
    margin-left: 0;
    margin-right: 0;
  }
}

@media screen and (max-width: 60em) {
  .md-sidebar--secondary {
    display: none;
  }
  .md-content {
    padding: 0.5rem 0.75rem;
  }
  .md-content__inner {
    padding: 0 0.5rem;
  }
  .md-footer {
    margin-left: 0;
    margin-right: 0;
  }
}

img.emoji {
  display: none !important;
}

.md-typeset ul {
  margin: 0.4rem 0;
}

.md-typeset li {
  margin: 0.15rem 0;
}

.md-typeset blockquote {
  border-left: 4px solid var(--md-primary-fg-color);
  padding-left: 0.75rem;
  margin: 0.5rem 0;
  font-style: normal;
  color: rgba(0, 0, 0, 0.7);
}

[data-md-color-scheme="slate"] .md-typeset blockquote {
  color: rgba(255, 255, 255, 0.7);
}

.md-typeset hr {
  margin: 1rem 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

[data-md-color-scheme="slate"] .md-typeset hr {
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.md-typeset .mermaid {
  margin: 1rem 0;
  text-align: center;
}

.md-typeset .mermaid svg {
  max-width: 100%;
  height: auto;
}
```

3. **Create docs/javascripts/mermaid-init.js**:

```javascript
mermaid.initialize({
  startOnLoad: true,
  theme: 'neutral'
});
```

4. **Create docs/javascripts/nav-scroll.js** (accessibility-first auto-scroll for left navigation):

```javascript
// Accessibility-first nav scroll: prevents motion sickness and vertigo
(function() {
  // Check if user prefers reduced motion (accessibility)
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function scrollActiveIntoView() {
    const activeLink = document.querySelector('.md-sidebar--primary .md-nav__link--active');
    if (!activeLink) return;

    const scrollWrap = activeLink.closest('.md-sidebar__scrollwrap');
    if (!scrollWrap) return;

    // Check if active item is already visible in viewport
    const rect = activeLink.getBoundingClientRect();
    const scrollWrapRect = scrollWrap.getBoundingClientRect();

    // If already fully visible, don't scroll (prevents unnecessary jittering)
    if (rect.top >= scrollWrapRect.top && rect.bottom <= scrollWrapRect.bottom) {
      return;
    }

    // Only scroll if item is off-screen - position at 20% from top
    const linkTop = activeLink.offsetTop;
    const scrollWrapHeight = scrollWrap.clientHeight;
    const targetScroll = linkTop - (scrollWrapHeight * 0.2);

    // ALWAYS use instant scroll to prevent motion sickness/vertigo
    scrollWrap.scrollTo({
      top: targetScroll,
      behavior: 'instant'  // No animation - accessibility best practice
    });
  }

  // Initial page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => setTimeout(scrollActiveIntoView, 100));
  } else {
    setTimeout(scrollActiveIntoView, 100);
  }

  // On navigation - wait for Material's instant loading to complete
  if (typeof document$ !== 'undefined') {
    document$.subscribe(() => {
      setTimeout(scrollActiveIntoView, 100);
    });
  }
})();
```

5. **Create docs/overrides/** - Empty directory for future template overrides

6. **Markdown Formatting Rules**:
   - NO EMOJIS anywhere in documentation
   - Use 4-space indentation for nested bullets under numbered lists
   - Always add blank line before bullet lists
   - Use Mermaid diagrams WITHOUT custom style colors (just use neutral theme)

6. **MkDocs.yml Template Structure**:

```yaml
site_name: [PROJECT_NAME]
site_description: [PROJECT_DESCRIPTION]
site_author: [AUTHOR]
site_url: https://[USERNAME].github.io/[REPO]

repo_name: [USERNAME]/[REPO]
repo_url: https://github.com/[USERNAME]/[REPO]
edit_uri: edit/master/docs/

theme:
  name: material
  custom_dir: docs/overrides
  language: en
  palette:
    - scheme: default
      primary: indigo
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: black
      accent: light blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  font:
    text: Work Sans
    code: JetBrains Mono
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.sections
    - navigation.expand
    - navigation.indexes
    - navigation.top
    - toc.follow
    - search.suggest
    - search.highlight
    - search.share
    - content.code.copy
    - content.code.annotate

extra_css:
  - stylesheets/extra.css

extra_javascript:
  - https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js
  - javascripts/mermaid-init.js
  - javascripts/nav-scroll.js

markdown_extensions:
  - abbr
  - admonition
  - attr_list
  - def_list
  - footnotes
  - meta
  - md_in_html
  - toc:
      permalink: true
      toc_depth: 3
  - pymdownx.arithmatex:
      generic: true
  - pymdownx.betterem:
      smart_enable: all
  - pymdownx.caret
  - pymdownx.details
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.inlinehilite
  - pymdownx.keys
  - pymdownx.magiclink:
      repo_url_shorthand: true
      user: [USERNAME]
      repo: [REPO]
  - pymdownx.mark
  - pymdownx.smartsymbols
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.tasklist:
      custom_checkbox: true
  - pymdownx.tilde

nav:
  - Home: index.md
  # AI: Generate navigation structure based on project context
  # NOTE: "Home" will NOT appear in the left sidebar navigation
  # The CSS automatically hides the Home link - users access it via header/logo
  # Start with actual content sections below:
  - Getting Started:
    - Overview: getting-started/overview.md
    - Installation: getting-started/installation.md
  # ... continue with other sections

plugins:
  - search

extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/[USERNAME]/[REPO]
```

### Style Characteristics

- **Minimal, professional design** with tight spacing
- **Three-pane layout**: Left nav (15rem), center content (max 1000px), right TOC (12rem)
- **Hidden navigation tabs** - sidebar-only navigation
- **Hidden footer** - uses bottom padding instead
- **Hidden Home link** - CSS automatically hides "Home" from left sidebar; accessible via header logo/title only
- **Smart navigation scrolling** - Active nav items automatically scroll into view only when off-screen, positioned at 20% from top to minimize movement
- **Accessibility-first** - Uses instant scrolling (no animation) to prevent motion sickness and vertigo; only scrolls when necessary to eliminate jittering
- **Professional typography**: Work Sans for text, JetBrains Mono for code
- **Clean navigation**: No expand/collapse icons, no logos, no duplicates
- **Color scheme**: Indigo/black primary, blue accent, muted professional colors
- **Responsive**: Adapts for tablet and mobile

### Instructions for AI

When generating documentation:

1. Create ALL files mentioned above
2. Replace `[USERNAME]`, `[REPO]`, `[PROJECT_NAME]`, etc. with actual values
3. Generate appropriate navigation structure in the `nav:` section based on project needs
   - **IMPORTANT**: Always include `- Home: index.md` as the first nav item
   - The CSS will automatically hide it from the left sidebar
   - Don't worry about it showing up - it won't!
4. Create comprehensive markdown documentation files in the docs/ folder
5. Use proper markdown formatting (4-space indentation, blank lines before lists)
6. NO EMOJIS in any documentation content
7. Use Mermaid diagrams without custom colors (neutral theme handles light/dark mode)
8. Ensure all code examples use proper syntax highlighting

---

## Example Usage

**User Input:**
"Create MkDocs documentation for my Python data analysis library called 'DataViz Pro' by user 'johndoe'. Include sections for Installation, Quick Start, API Reference, and Examples."

**AI Should Generate:**
- Complete mkdocs.yml with nav structure for those sections
- docs/index.md (home page)
- docs/installation.md
- docs/quick-start.md
- docs/api-reference.md
- docs/examples.md
- docs/stylesheets/extra.css (complete file from above)
- docs/javascripts/mermaid-init.js (from above)
- docs/javascripts/nav-scroll.js (from above)
- docs/overrides/ directory (empty)

All with professional styling and smart navigation scrolling applied automatically.
