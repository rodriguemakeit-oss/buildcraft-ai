---
description: Scaffold a brand-new project from the standards (interactive: monorepo vs split repos, stack, infra)
argument-hint: "[project name]"
---

Bootstrap a **new** project from scratch on the `buildcraft-ai` standards. (For an
**existing** project, use `/onboard-project` instead.) Project name = `$ARGUMENTS` if given.

## 1. Ask the questions (interactive)

Collect the choices up front — present them as options, with the recommended default first:

- **Project name** (kebab-case) — if not in `$ARGUMENTS`.
- **Layout** (`standards/project-layout.md`):
  - **Monorepo** — `back/` + `front/` + shared `docker-compose`/`.env`/pre-commit, one root
    `CLAUDE.md` (e.g. `asset_api`).
  - **Separate repos** — `<name>-backend` + `<name>-frontend`, each its own
    `CLAUDE.md`/`.mcp.json`; API contract via the backend OpenAPI (e.g. `oilabs-*`).
- **Components**: backend only · frontend only · both.
- **Backend** (if any): **code organization** (**feature/vertical** default — `{feature}/…`
  — or layer/horizontal — `routers/{feature}.py`, `services/…`; see
  `standards/backend-fastapi.md`), DB engine (**Postgres** default), data-access naming
  (**`repository/`** or `crud/`), domain-error style (`exceptions.py` or `error/`),
  settings folder (`core/` or `config/`), **Okta** auth (y/n), extras (**Redis**, **Celery**
  `tasks/`) — defaults off, like `asset_api` when enabled.
- **Object storage** (if the project stores files): **ask the cloud target** and wire the
  matching local Docker service — **AWS → LocalStack** (S3) or **Azure → Azurite** (Blob), or
  **none**. Default off; never assume the provider (`standards/async-tasks.md`).
- **Frontend** (if any): Vite + React + TS + **Tailwind + portfolio Fluid Design System (NJ\*)**
  + Vitest (this is the standard, `standards/frontend-react.md`).
- **Infra**: docker-compose with **Traefik** + **Adminer** (y/n, default y if backend).
- **Specs**: local Markdown under `specs/` (default) · JIRA (Atlassian MCP) · both
  (`standards/tracker.md`).

Confirm the summarized choices before generating.

## 2. Create the directory & git layout

- **Monorepo**: one repo `<name>/` with `back/` and/or `front/`, root `docker-compose.yml`,
  root `.env.example`, one root `CLAUDE.md`. `git init` once.
- **Separate repos**: `<name>-backend/` and/or `<name>-frontend/`, each `git init`'d, each
  with its own `CLAUDE.md`/`.mcp.json`; the front references the back's OpenAPI for types.
- Do **not** create any remote (no GitHub repo); tell the user to add the remote themselves.

## 3. Scaffold the skeleton (delegate to the agents/skills)

- **Backend** → `backend-fastapi` agent + `scaffold-fastapi-feature` skill, following
  `standards/backend-fastapi.md` + `project-layout.md`. Base skeleton: `app/` (Router →
  Service → Repository → Model), `core/` settings via pydantic-settings, async SQLAlchemy
  session, `main.py`, Alembic init, `tests/` + `conftest.py`, `pyproject.toml` (deps:
  fastapi, sqlalchemy[asyncio], alembic, pydantic, pydantic-settings, pytest, ruff, etc.),
  `Dockerfile`. Honor the chosen naming variants **and code organization** (feature/vertical
  by default, or layer/horizontal). Add Redis/Celery only if asked; for object storage wire
  the service matching the chosen cloud target (**LocalStack** for AWS, **Azurite** for Azure).
- **Frontend** → `frontend-react` agent + `react-feature` skill, following
  `standards/frontend-react.md`: Vite + React + TS, Tailwind + Fluid DS wired, Vitest + RTL,
  a starter page, `package.json`, `Dockerfile`.
- **Infra** → `docker-stack` skill: `docker-compose.yml` (back + front + postgres +
  Traefik + Adminer + any extras), healthchecks, `.env.example`. Monorepo = root compose.

## 4. Quality, onboarding files, first commit

- **pre-commit** → run `/setup-precommit` in each repo (committed `.pre-commit-config.yaml`
  + `.secrets.baseline`).
- **PR template** → `.github/pull_request_template.md` from `standards/pull-request.md`
  (committed, shared).
- **`CLAUDE.md`** (per `/onboard-project` §2) and **`.mcp.json`** (postgres restricted +
  the chosen tracker). Record the chosen **backend code organization** (feature/vertical vs
  layer/horizontal) and naming variants in `CLAUDE.md` so later agents/skills follow it.
  These stay **local** — add to `.git/info/exclude`. (pre-commit files do get committed.)
- Initial commit per repo: the committed skeleton + `.pre-commit-config.yaml`
  (`CLAUDE.md`/`.mcp.json` excluded). Commit only if the user wants it.

## 5. Report

Summarize: layout chosen, repos/folders created, stack enabled, files generated (committed
vs local), and the next steps — install the plugin
(`claude plugin marketplace add …` / `install buildcraft-ai@renewable-flex-internal`),
add a git remote, run the stack (`docker compose up`), and start a feature with
`/plan-feature`.
