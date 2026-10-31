---
description: Audit a project against the standards and propose a prioritized refactor plan
argument-hint: "[path to audit]  (default: current project)"
---

Audit the project at `$ARGUMENTS` (default: the current repository) against the foundation
`standards/`, then propose a prioritized plan. **Audit only** — do not change code until
the user approves; then dev agents execute in batches.

1. **Map the project.** Detect layout/stack (`standards/project-layout.md`): monorepo vs
   separate repos, backend/frontend, ORM, auth, services. Note naming variants to align
   with (`crud/`≈`repository/`, `error/`≈`exceptions.py`, `config/`≈`core/`), and the
   current **backend code organization** — feature/vertical (`{feature}/router.py…`) vs
   layer/horizontal (`routers/{feature}.py`, `services/…`; `standards/backend-fastapi.md`).
2. **Compare to the standards.** Walk `backend-fastapi.md`, `frontend-react.md`,
   `testing.md`, `security.md`, `project-layout.md`. Look for gaps: mixed layers
   (router↔repo shortcuts), silent `return None`, missing/weak tests, hardcoded secrets,
   unpaginated endpoints, raw SQL, missing migrations, no input validation, front not on
   Tailwind + portfolio Fluid DS, hand-written API types instead of generated from OpenAPI
   (`api-contract.md`), unstructured logging / no correlation ids / `print()`
   (`observability.md`), slow/heavy work blocking the request instead of a Celery task
   (`async-tasks.md`), stale/missing user/API docs, etc. Use the `security-reviewer` agent
   for the security pass and `doc-writer` for the documentation gap.
3. **Prioritize.** Rank findings **Critical / High / Medium / Low** by risk × effort, each
   with file:line, the standard it violates, and a concrete fix. Group into batches that
   can land as small PRs.
4. **Offer the architecture choice.** Whatever the current organization, **ask whether the
   user wants to keep it or migrate** feature/vertical ↔ layer/horizontal (default: keep).
   If they migrate, add it as a **dedicated, all-or-nothing batch** (move every layer of
   every feature, fix imports, keep tests mirroring the code) so the project never ends up
   half-vertical/half-horizontal, and record the new layout in `CLAUDE.md`. Treat it as
   structural — worth an `/adr`. This is a move-and-reimport batch, not a behavior change.
5. **Plan.** A sequenced, approvable refactor plan: which agent does each batch
   (`backend-fastapi`, `frontend-react`, `db-migration`, `qa-tester`), order, and
   dependencies (an archi migration usually lands **first**, before feature-level fixes, to
   avoid rebasing them). Optionally offer to create tickets via `pm-planner` / `/plan-feature`.
6. **Stop for approval.** Present the plan; execute only what the user greenlights.
