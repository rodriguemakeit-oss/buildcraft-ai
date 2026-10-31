# Roadmap & status

Self-contained status of the foundation. (A more detailed historical plan may exist outside
the repo, but it is **optional** — this file is the in-repo source of truth.)

## Done

The foundation covers the full dev/PM lifecycle on the **FastAPI + React** stack:

- **Plugin & distribution** — Claude Code plugin via a local marketplace.
- **17 standards** — backend, frontend (Tailwind + Fluid DS), documentation, project-layout,
  testing, migrations, security, auth-okta, api-contract, api-errors, observability, tracker,
  pre-commit, commits, adr, async-tasks, pull-request.
- **9 agents** — backend-fastapi, frontend-react, db-migration, qa-tester, security-reviewer,
  pm-planner, tracker-sync, doc-writer, legacy-analyst.
- **7 skills** — scaffold-fastapi-feature, alembic-migration, react-feature, security-review,
  docker-stack, sync-api-types, scaffold-celery-task.
- **9 commands** — new-project, onboard-project, refonte, refactor-audit, setup-precommit,
  plan-feature, daily, ship, adr.
- **2 hooks** — format-lint, block-secrets.
- **Docs** — a slim root `README.md` (summary + documentation map) pointing to per-tool guides
  `docs/claude-code.md` and `docs/copilot-cli.md` (each with a FR reading guide), per-command
  references (`docs/claude-code-commands.md` + the Copilot equivalents `docs/copilot-cli-commands.md`),
  this roadmap, and the foundation's own ADRs (`docs/adr/`).
- **Dual target** — GitHub Copilot CLI interop from one source (ADR-0007): `AGENTS.md` +
  `.github/instructions/` (backend, frontend, documentation, tests, migrations), skills reused
  as-is, `scripts/copilot-*.sh`, and the `docs/copilot-cli.md` guide (+ FR). Rules stay
  single-sourced in `standards/`.

## Remaining — final wiring on a pilot (deferred by design)

Wiring onto real projects was kept for the end, once the foundation was complete:

1. Connect the live **Atlassian/JIRA OAuth MCP** on a pilot and validate
   read/create/transition end-to-end (closes the MCP phase).
2. Onboard the pilot (`oilabs-backend`) via `/onboard-project`; test `/daily` against JIRA.
3. Schedule the morning **`/daily`** routine (via `/schedule`) once a pilot is wired.
4. Run **`/refactor-audit`** on the pilot and iterate the standards from the findings.

## Candidate enrichments (not started)

- `standards/config-secrets.md` — config layering (pydantic-settings / env / secrets manager).
- `standards/dockerfile.md` — Dockerfile conventions (multi-stage, slim, non-root, healthcheck)
  to complement the compose-focused `docker-stack` skill.

## Out of scope (decided)

CI/CD (ADR-0003), a `/release` command (ADR-0006), multi-stack support (ADR-0004), and
translating canonical files (ADR-0002). See `docs/adr/`.
