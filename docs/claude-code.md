# Using the socle with Claude Code

> 🇫🇷 Lecteur non anglophone ? Voir le **[Guide de lecture en français](./claude-code.fr.md)**.
> Back to the [root README](../README.md).

How to install, onboard and run the `buildcraft-ai` foundation as a **Claude Code plugin**.
For GitHub Copilot CLI instead, see [`copilot-cli.md`](./copilot-cli.md).

## Contents

- `agents/` — specialized sub-agents (dev, PM, QA, security, ticket tracking).
- `skills/` — reusable procedures loaded on demand.
- `commands/` — workflow slash-commands (`/daily`, `/plan-feature`, `/ship`…). One example
  each in [`claude-code-commands.md`](./claude-code-commands.md).
- `hooks/` — quality automations (format, lint, secret blocking).
- `standards/` — **source of truth** for conventions (backend, frontend, documentation, tests, migrations, security, auth-okta, api-contract, api-errors, observability, tracker, pre-commit, commits, adr, async-tasks, pull-request).
- `docs/` — per-command [`claude-code-commands.md`](./claude-code-commands.md), the Copilot CLI
  interop guide [`copilot-cli.md`](./copilot-cli.md), and the foundation's own
  [`adr/`](./adr/README.md) (design decisions).
- `AGENTS.md` + `.github/instructions/` — **Copilot CLI** adapters (thin pointers to
  `standards/`; see [`copilot-cli.md`](./copilot-cli.md)).
- `scripts/` — `copilot-setup.sh` / `copilot-doctor.sh` (wire Copilot CLI to the socle).

## Install in a project

1. Register the marketplace and install the plugin (once per machine — afterwards the
   agents/skills/commands/standards are available in every project):

   ```bash
   claude plugin marketplace add https://github.com/rodriguemakeit-oss/buildcraft-ai.git
   claude plugin install buildcraft-ai@renewable-flex-internal
   ```

2. Onboard the project. Installing the plugin does **not** create the per-project files.
   Each project still needs a `CLAUDE.md` (project specifics + pointer to the standards)
   and a `.mcp.json` (tools). Generate them with the bundled command — it detects the
   layout/stack and scaffolds both, then flags obsolete config to remove:

   ```
   /onboard-project
   ```

   These per-project files are intentionally not auto-created on install: they hold
   project-specific overrides and credentials, so they live in the project repo, not in
   the plugin. `/onboard-project` is idempotent (it diffs before overwriting). If you
   prefer, you can also write `CLAUDE.md` by hand or start from `/init`.

   **Which entry command?**
   - `/new-project` — greenfield, nothing to preserve (interactive monorepo/split, stack, infra).
   - `/onboard-project` — adopt an existing project as-is. On **FastAPI + React** it does a
     full onboard; on an **off-stack** project (.NET, Angular, Spring…) it **asks**: switch
     to `/refonte` (rewrite) or do a **degraded onboard** (cross-cutting standards only).
   - `/refactor-audit` — improve an existing project **in place** (same stack).
   - `/refonte` — **rewrite** a legacy project (any stack) onto the standards, with parity —
     when an in-place refactor is too costly.

   **Onboarding files stay local**: `CLAUDE.md`, `.mcp.json` and `.claude/` are kept
   local per developer (added to `.git/info/exclude`), not committed to the project repo.

3. Obsolete config: `/onboard-project` proposes removing old `.github/copilot*` (after
   migrating their knowledge into `CLAUDE.md`). It keeps `.github/workflows/` (CI) and
   `.claude/settings.local.json` (accumulated permissions).

## Updating

The plugin is installed **once per machine** (user level), not per project — so updating
it propagates to **every** project automatically. You do not re-install per project, and
your local per-project files (`CLAUDE.md`, `.mcp.json`) are not affected.

```bash
claude plugin marketplace update renewable-flex-internal
claude plugin update buildcraft-ai@renewable-flex-internal   # restart the session to apply
```

`renewable-flex-internal` is the marketplace name, `buildcraft-ai` the plugin name. `update`
needs the **qualified** `plugin@marketplace` name (the bare `buildcraft-ai` returns "not
found"). A **session restart** is required for the new version to load.

Update detection is version-based: bump `version` in `.claude-plugin/plugin.json` on every
notable change so `claude plugin update` picks it up.

Handy commands:
```bash
claude plugin list                      # installed plugins + versions
claude plugin details buildcraft-ai   # component inventory + token cost
claude plugin marketplace list          # configured marketplaces
```

> The marketplace points at the **remote**
> (`example.invalid/rodriguemakeit-oss/buildcraft-ai`), so teammates just
> `marketplace update` + `plugin update` — no local clone needed.

## Daily follow-up (scheduled `/daily`)

`/daily` is meant to run every morning with no manual action, via a scheduled cloud agent
(routine). Set it up once per project with the `/schedule` skill — e.g. a weekday-morning
cron running `/daily` in the project directory. Non-interactively the `tracker-sync` agent
applies only the unambiguous status transitions (merged PR → Done) and lists the rest as
blockers for human review; it never bulk-changes silently. A tracker must be configured in
the project's `.mcp.json` (`/onboard-project`) for status sync; otherwise `/daily` still
produces the git-based report.

## Status

- [x] Plugin + marketplace structure
- [x] Standards: backend / frontend (Tailwind + Fluid DS) / layout / documentation / tests / migrations / security / auth-okta / api-contract / api-errors / observability / tracker / pre-commit / commits / adr / async-tasks / pull-request
- [x] Agents `backend-fastapi`, `frontend-react`, `db-migration`, `qa-tester`, `security-reviewer`
- [x] Agents `pm-planner` / `tracker-sync` (tracker-agnostic, via `standards/tracker.md`)
- [x] Agent `doc-writer` (user/API docs from the real code; scoped — not CLAUDE.md/ADR)
- [x] Agent `legacy-analyst` (reverse-engineer any stack into a target-agnostic spec)
- [x] Skills `scaffold-fastapi-feature`, `alembic-migration`, `react-feature`, `security-review`, `docker-stack`, `sync-api-types`, `scaffold-celery-task`
- [x] Command `/new-project` (scaffold a brand-new project: interactive monorepo/split, stack, infra)
- [x] Command `/onboard-project` (adopt an existing project as-is: CLAUDE.md + .mcp.json)
- [x] Command `/refonte` (rewrite a legacy project of any stack onto the standards, with parity)
- [x] Commands `/plan-feature`, `/daily`, `/ship`, `/refactor-audit`
- [x] Command `/setup-precommit` (stack-aware `.pre-commit-config.yaml` + `standards/pre-commit.md`)
- [x] Command `/setup-observability` (opt-in structured logs; metrics/tracing on demand + `standards/observability.md`)
- [x] Command `/adr` (next Architecture Decision Record, Nygard format + `standards/adr.md`)
- [x] Quality hooks (format/lint on edit + hardcoded-secret / `.env` blocking)
- [x] Governance in-repo: ADRs (`docs/adr/`), `CONTRIBUTING.md`, `ROADMAP.md` (self-sufficient)
- [x] Tracker contract (`standards/tracker.md`); `.mcp.json` scaffolded per project by `/onboard-project`
- [x] Dual target — GitHub Copilot CLI interop (`AGENTS.md`, `.github/instructions/`, `scripts/copilot-*.sh`, `docs/copilot-cli.md`) from one source (ADR-0007); covers backend, frontend, documentation, tests, migrations + the security-review skill

> Hooks run tools found on `PATH` (`ruff`, `eslint`/`prettier` via `npx`, `jq`). They are
> best-effort and never block the dev loop except the deterministic secret guard
> (`exit 2`). Activate the project venv so `ruff` is on `PATH` for auto-formatting.
