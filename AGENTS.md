# AGENTS.md — buildcraft-ai (GitHub Copilot CLI entry point)

> **This file is for GitHub Copilot CLI.** Claude Code uses `agents/` + `CLAUDE.md`; Copilot
> CLI uses **this file** plus [`.github/instructions/*.instructions.md`](./.github/instructions).
> Both targets share **one source of truth**: the rules live only in
> [`standards/`](./standards). This file and the instruction files **do not restate rules —
> they point to the standards.** Full interop model: [`docs/copilot-cli.md`](./docs/copilot-cli.md).

You are working on an `portfolio/` project — a **FastAPI** backend and/or a **React + TypeScript**
frontend. Apply the platform standards. The canonical rules are in `standards/<name>.md` of
this `buildcraft-ai` repo (the one on your `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`); open and read
the relevant standard before coding, then align with the target project's real conventions.

## Non-negotiables (cross-cutting)

- **Naming & readability** (`standards/backend-fastapi.md`, `standards/frontend-react.md`):
  snake_case in Python; native camelCase/PascalCase in TS/React. Respect the **function-size
  and call-depth limits** in the standards — compose at the caller instead of nesting helpers.
  Follow the **comments rule**: no decorative banners/separators, no comment that restates the
  code — comment the *why*, not the *what*.
- **Security** (`standards/security.md`, `standards/auth-okta.md`): no hardcoded secrets; Okta
  JWT verification (JWKS/iss/aud/exp) + **per-resource authorization**; validate all inputs.
- **Tests ship with the change** (`standards/testing.md`).
- **Errors**: the canonical error envelope (`standards/api-errors.md`).
- **Commits**: Conventional Commits (`standards/commits.md`).

## Backend (FastAPI / Python)

Apply `standards/backend-fastapi.md` (+ `testing`, `security`, `auth-okta`, `api-errors`,
`observability`, `async-tasks`, `project-layout`). Clean Architecture:
**Router → Service → Repository → Model**, async first; custom domain exceptions mapped to HTTP
by central handlers (no silent `return None`). Details:
[`.github/instructions/backend.instructions.md`](./.github/instructions/backend.instructions.md).

## Frontend (React / TypeScript)

Apply `standards/frontend-react.md` (+ `testing`, `security`, `auth-okta`, `api-contract`). UI =
**portfolio Fluid Design System** (`NJ*`) first, **Tailwind** for layout; never recreate a Fluid
component. API types are **generated** from the backend OpenAPI, never hand-written. Details:
[`.github/instructions/frontend.instructions.md`](./.github/instructions/frontend.instructions.md).

## Documentation

Apply `standards/documentation.md`: write user/API docs **from the real code** (no drift, no
invention); scope = README/API/`docs/`/public docstrings; never touch `CLAUDE.md`, `docs/adr/`,
product logic or tests. Path-scoped:
[`.github/instructions/documentation.instructions.md`](./.github/instructions/documentation.instructions.md).

## Tests, migrations, security review

- **Tests** — `standards/testing.md`: every change ships its tests; happy path **and** error
  cases (404/409/validation); determinism. Path-scoped:
  `.github/instructions/tests.instructions.md`.
- **DB migrations** — `standards/migrations.md` (+ the `alembic-migration` skill): autogenerate
  then **mandatory manual review**, reversible `downgrade()`, no silent data loss. Path-scoped:
  `.github/instructions/migrations.instructions.md`.
- **Security review** — use the **`security-review` skill** (in `~/.agents/skills`) with
  `standards/security.md`: checklist by severity (secrets, Okta authz, injections, deps, logs).

## Not handled by Copilot here

- **Hooks** (format/lint/secret-block) are Claude-only; the shared enforcement gate for everyone
  is **pre-commit** (`standards/pre-commit.md`) — run it.
- **Slash workflows** (`/ship`, `/daily`, `/adr`…) are Claude commands; the equivalent is to
  follow the matching standard by hand (e.g. `standards/pull-request.md` before opening a PR).
- **PM / tracker workflows** (`pm-planner`, `tracker-sync`) and **legacy analysis**
  (`legacy-analyst`) are Claude agents with no path-scoped Copilot mapping — do them by following
  the matching standard by hand (e.g. `standards/tracker.md`).
