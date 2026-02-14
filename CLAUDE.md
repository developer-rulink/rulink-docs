# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Multi-service documentation hub for the RuLink platform, built with MkDocs (Material theme). Each service is an independent MkDocs project with its own `mkdocs.yml` and `docs/` directory.

## Service Modules

| Directory | Site Name | Production URL |
|---|---|---|
| `auth/` | Сервис аутентификации | rulink.io/support/auth |
| `cadastral/` | Получение кадастровой информации | rulink.io/support/cadastral |
| `cryptoservice/` | Сервис работы с электронной подписью | rulink.io/support/crypto |
| `legal/` | Правовой центр | rulink.io/legal |
| `pki/` | PKI Сервис. Проверка сертификатов | rulink.io/support/pki |
| `system/` | Системные настройки | rulink.io/support/system |
| `examples/` | Служебный проект — примеры разметки | (not public) |
| `images/` | Статические ресурсы | rulink.io/images/{filename} |
| `static/` | Устаревший проект (не используется) | — |

## Common Commands

**Activate Python virtual environment (required before build commands):**
```bash
source venv/bin/activate
```

**Build a single service (run from its directory):**
```bash
cd auth && mkdocs build
```

**Serve a service locally with hot-reload:**
```bash
cd auth && mkdocs serve
```

**Lint all Markdown files:**
VSCode default build task (`Ctrl+Shift+B`) runs markdownlint on all `.md` files in the workspace.

**Production deployment (all services):**
```bash
bash update-mkdocs.sh
```

## Architecture

Each service directory follows this structure:
```
{service}/
├── mkdocs.yml        # MkDocs config (theme, nav, plugins)
├── docs/             # Markdown source content
│   ├── index.md
│   └── assets/       # Per-service assets (favicon.svg, etc.)
├── overrides/        # Material theme overrides
│   └── main.html     # Extends base.html — adds SEO meta tags + Yandex Metrika
└── site/             # Generated static HTML (gitignored, build output)
```

The `images/` directory is a standalone static asset store — not a MkDocs project. Files there are served at `rulink.io/images/{filename}`.

## MkDocs Configuration Conventions

All services share the same base configuration pattern:
- **Theme:** Material, language `ru`, `custom_dir: overrides`
- **Logo/Favicon:** `assets/favicon.svg`
- **Copyright:** `2026 © ООО Облакотех`
- **Plugins:** `search`, `i18n` (Russian)
- **Social links:** Telegram `@rulinkio`, Email `hello@rulink.io`
- **Nav last item:** always `НА ГЛАВНУЮ: 'https://rulink.io/support'`

Standard Markdown extensions enabled everywhere: `admonition`, `pymdownx.details`, `pymdownx.superfences` (with Mermaid), `pymdownx.highlight`, `attr_list`, `md_in_html`, `pymdownx.blocks.caption`, `def_list`, `pymdownx.tasklist`.

## Theme Overrides

Each service has `overrides/main.html` that:
1. Injects per-service SEO meta tags (`description`, `keywords`, Open Graph, Twitter Card)
2. Injects Yandex Metrika analytics counter

When adding a new service, copy `overrides/main.html` from an existing service and update the meta content.

## Adding New Documentation

- **New service:** add a folder with `docs/index.md`, `mkdocs.yml` matching existing conventions, and `overrides/main.html` adapted from an existing service.
- **New page in existing service:** add `.md` file to `docs/`, then register it under `nav:` in that service's `mkdocs.yml`.
- **Shared images:** place in `images/` directory and reference via `https://rulink.io/images/{filename}`.
- Use the `examples/` project as a live reference for supported Markdown extensions and formatting patterns.
