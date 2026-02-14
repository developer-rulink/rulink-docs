# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Multi-service documentation site using MkDocs + Material theme for RuLink services (ООО Облакотех). Each service is a standalone MkDocs project built independently.

## Common Commands

Run these from within a specific service directory (e.g., `cd auth`):

```bash
# Serve locally with live reload
mkdocs serve

# Build static site
mkdocs build

# Serve on a custom port
mkdocs serve -a localhost:8001
```

Production deployment (run from repo root on the server):
```bash
bash update-mkdocs.sh
```

Markdown linting (VSCode default build task):
```
markdownlint: Lint all Markdown files in the workspace
```

## Architecture

**Monorepo** — one folder per service, each independently buildable:

| Directory    | Purpose |
|-------------|---------|
| `auth/`     | Identity service docs |
| `cadastral/`| Cadastral information service docs |
| `cryptoservice/` | Electronic signature service docs |
| `pki/`      | PKI / certificate authority info (internal) |
| `system/`   | Shared system configuration docs (common across services) |
| `legal/`    | Legal agreements and policies |
| `examples/` | Non-public markup examples |
| `images/`   | Shared image assets, served at `https://rulink.io/images/{filename}` |
| `static/`   | Legacy project, not actively used |

**Per-service structure:**
```
{service}/
├── docs/           # Markdown source files
├── overrides/      # MkDocs Material theme overrides
│   └── main.html   # Adds meta tags and Yandex.Metrika analytics
└── mkdocs.yml      # Site config: nav, theme, plugins, markdown extensions
```

## MkDocs Configuration Conventions

All services share the same pattern in `mkdocs.yml`:
- Theme: Material, language `ru`
- `custom_dir: overrides` for analytics and OpenGraph meta tags
- Plugins: `search` + `i18n` (default language: `ru`)
- Markdown extensions: admonitions, pymdownx suite (superfences, highlight, critic, caret, keys, mark, tilde), mermaid diagrams via custom fence, `def_list`, `pymdownx.tasklist`
- Site URL pattern: `https://rulink.io/support/{service}`

When adding a new service:
1. Create `{service}/docs/index.md`
2. Copy `mkdocs.yml` and `overrides/` from an existing service and update `site_name`, `site_url`, and `nav`
3. Update `overrides/main.html` meta tags for the new service
4. Add the build step to `update-mkdocs.sh`
