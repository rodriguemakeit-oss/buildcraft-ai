---
description: Onboard an existing project as-is — CLAUDE.md + .mcp.json; off-stack projects prompt for /refonte or a degraded onboard
---

Bootstrap the current repository so it uses the `buildcraft-ai` foundation. Be
idempotent: if a file already exists, show a diff and ask before overwriting.

## 1. Detect the layout & stack

Apply `standards/project-layout.md`:
- Monorepo if `back/` + `front/` exist at the root; otherwise standalone back and/or front.
- **Identify the actual frameworks** before anything else: backend (`pyproject.toml`/
  `requirements.txt` → Python; `*.csproj`/`*.sln`/`Program.cs` → .NET; `pom.xml`/`build.gradle`
  → Java; `package.json` with Express/Nest → Node…) and frontend (`package.json`: React vs
  **Angular** (`@angular/*`/`angular.json`) vs Vue…).
- Detect: docker-compose services + ports, DB engine, ORM (SQLAlchemy vs SQLModel,
  async vs sync), auth (Okta), Celery/Redis, object storage (LocalStack/AWS or Azurite/Azure),
  test runner, pre-commit hooks.
- Read `.env.example`/`docker-compose.yml` for DB connection (user/password/db/port). Never
  read or echo real secrets from `.env`.

## 1b. Stack gate — full onboard, `/refonte`, or degraded onboard

This command is most valuable on the **target stack**: a **FastAPI (Python)** backend and/or
a **React (TypeScript)** frontend — what the dev agents (`backend-fastapi`, `frontend-react`)
and the stack-specific standards cover.

- **On stack** (FastAPI and/or React) → proceed with the **full onboard** (steps 2→5).
- **Off stack** (e.g. **.NET, Spring, Express** backend, or **Angular/Vue** frontend) →
  **ask the user** before doing anything:

  > This project is on `<detected stack>`, not the target FastAPI + React stack. Two options:
  > **(a) `/refonte`** — reverse-engineer it and rebuild it on the standards, with parity
  > (recommended if you intend to migrate); or **(b) a degraded onboard** — keep it as-is and
  > wire only the **cross-cutting** standards (the FastAPI/React standards and dev agents
  > won't apply). Which do you want?

  - If the user **validates `/refonte`** → hand off to `/refonte` and **stop** here.
  - If the user **chooses to stay** → continue with a **degraded onboard** (see the mode note
    in the steps below); `/refonte` stays available later.

## 2. Generate `CLAUDE.md` (root, or per repo if separate)

> **Degraded mode** (off-stack, user chose to stay): point only to the **cross-cutting**
> standards — `security`, `testing`, `observability`, `api-contract`, `commits`,
> `pre-commit`, `tracker`, `adr`. **Omit** `backend-fastapi`/`frontend-react` and state
> explicitly that those standards and the matching dev agents **do not apply** to this stack.
> Record the project's real stack/frameworks and conventions, and note that `/refonte`
> remains the path to migrate. Everything below applies to whichever components exist.

Minimal and project-specific. It must:
- Point to the foundation standards (`backend-fastapi`, `frontend-react`, `project-layout`,
  `testing`, `security`).
- List **project overrides** where the project diverges from a standard (e.g. SQLModel +
  sync sessions, `crud/` instead of `repository/`) — the agents align with what exists.
  Record the detected **backend code organization** (feature/vertical vs layer/horizontal;
  `standards/backend-fastapi.md`) so agents/skills follow it. Onboarding adopts it **as-is**
  — switching layouts is a `/refactor-audit` (or `/refonte`) decision, not an onboard step.
- Give the real run/test/lint commands and local hosts/ports.
- Capture any non-obvious project knowledge found (patterns, conventions) — migrate it from
  any pre-existing `.github/copilot*` agents/skills before they are removed.

## 3. Generate `.mcp.json`

- `postgres` via `@crystaldba/postgres-mcp --access-mode=restricted`, DATABASE_URI built
  from the detected local dev values (local creds may be inlined; never inline prod creds).
  In **degraded mode**, include it only if the DB is Postgres (skip for SQL Server/MySQL/…).
- `atlassian` (JIRA) hosted MCP **only if** the project tracks work in JIRA — specs default
  to local Markdown under `specs/` (`standards/tracker.md`), which needs no MCP.

## 3b. Keep the onboarding files local (not committed)

`CLAUDE.md`, `.mcp.json` and `.claude/` stay **local per developer** — they are not
committed to the project repo. Without touching the shared `.gitignore`, add them to
`.git/info/exclude` (local-only) so they don't show up as changes:

```
echo -e "\n# AI platform onboarding — kept local\nCLAUDE.md\n.mcp.json\n.claude/" >> .git/info/exclude
```
(`CLAUDE.md` may already be covered by an existing root-`.md` ignore rule; that's fine.)

## 3c. Set up pre-commit

Run the `/setup-precommit` workflow (`standards/pre-commit.md`): scaffold/merge a
stack-aware `.pre-commit-config.yaml`, generate `.secrets.baseline`, install the hook and
run a baseline pass. Unlike the onboarding files above, `.pre-commit-config.yaml` and
`.secrets.baseline` **are committed** to the project repo (shared, not local).

In **degraded mode** this still applies — `/setup-precommit` already keys off the real
stack: it keeps the hygiene + `detect-secrets` + `conventional-pre-commit` hooks and the
ESLint/Prettier hooks for an Angular/Vue front, and drops the Python-only ruff/bandit.

## 3d. Scaffold the PR template

Create `.github/pull_request_template.md` from `standards/pull-request.md` (the Definition of
Done checklist) if absent. Like pre-commit, this is a **committed** shared artifact (not
local). It applies in degraded mode too — trim checklist lines that don't fit the stack.

## 4. Flag obsolete config (do NOT delete blindly)

- Propose removing `.github/copilot*` (replaced by this plugin) — only after its knowledge
  has been migrated into `CLAUDE.md`.
- **Keep** `.github/workflows/` (CI) and `.claude/settings.local.json` (accumulated
  permissions). List anything ambiguous and ask before removing.

## 5. Report

Summarize: detected layout/stack, files created, overrides recorded, folders proposed for
removal, and the two install commands the user must run themselves:
`claude plugin marketplace add …` and `claude plugin install buildcraft-ai@renewable-flex-internal`.
