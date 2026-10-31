# Claude Code — command examples

One concrete example per **Claude Code** slash-command, to illustrate the flow. Examples use a
fictional `asset_api` feature (importing an Excel of measurement points) for continuity. Output is
illustrative — the exact result depends on your project and tracker.

> Using **GitHub Copilot CLI**? It has no slash-commands; the equivalent of each command is in
> [`copilot-cli-commands.md`](./copilot-cli-commands.md).

---

## `/new-project`

```
/new-project forecast-portal
```
Asks the layout (monorepo vs split repos), components (back/front), backend options (DB,
Okta, Redis/Celery…), infra (Traefik + Adminer) and tracker — then scaffolds the skeleton,
runs `/setup-precommit`, and generates `CLAUDE.md` + `.mcp.json`.

→ *Result*: `forecast-portal/` with `back/` + `front/`, `docker-compose.yml`,
`.pre-commit-config.yaml`, an initial commit, and the next steps (add a remote, `docker
compose up`).

## `/onboard-project`

```
/onboard-project        # run inside an existing repo
```
Detects the layout/stack, generates a project-specific `CLAUDE.md` + `.mcp.json`, sets up
pre-commit, and flags obsolete config (`.github/copilot*`).

→ *Off-stack* (e.g. Angular + .NET): it stops and **asks** — switch to `/refonte` (rewrite),
or do a *degraded onboard* (cross-cutting standards only).

## `/refonte`

```
/refonte ~/Sources/legacy/old-django-app
```
`legacy-analyst` reverse-engineers the app into a spec → records the rewrite decisions as
ADRs → `/new-project` scaffolds the target → `pm-planner` creates parity stories → dev agents
rebuild, checking behavior against the legacy.

→ *Result*: a new FastAPI + React project + a backlog of parity tickets.

## `/refactor-audit`

```
/refactor-audit
```
Walks the project against the `standards/`, lists gaps ranked Critical/High/Medium/Low with
`file:line` and a fix, grouped into batches.

→ *Result*: e.g. “High — raw SQL in `users/repository.py:42` (injection); Medium — endpoint
`/orders` unpaginated”. Stops for your approval before any change.

## `/setup-precommit`

```
/setup-precommit
```
Detects the stack and writes a `.pre-commit-config.yaml` (hygiene + detect-secrets +
conventional-commits + ruff/bandit for Python + eslint/prettier for the front), generates
`.secrets.baseline`, installs both git stages, and runs a baseline pass.

→ *Result*: malformed commits and hardcoded secrets are now blocked at commit time.

## `/setup-observability`

```
/setup-observability
```
Opt-in — observability is **not** added to a scaffolded backend by default. Run this to wire
it in: structured JSON logs to stdout with a `request_id` + `/health`/`/ready` (the default
scope), and — only if you ask for them — RED metrics via `prometheus-client` on `/metrics`
and distributed tracing via OpenTelemetry/OTLP. The app only emits; infra owns collection,
dashboards and alerting (`standards/observability.md`).

→ *Result*: the app emits Grafana/Splunk-ready structured logs (and optionally metrics/traces)
without coupling to any specific backend.

## `/plan-feature`

```
/plan-feature Allow a manager to upload an Excel of measurement points and track processing
```
`pm-planner` clarifies scope, writes a lightweight PRD, breaks it into vertical stories
(acceptance criteria, S/M/L, layers), and creates the tickets.

→ *Result*: epic `ASSET_API-210` + stories `ASSET_API-211..214`, with a suggested build order.

## `/daily`

```
/daily
```
`tracker-sync` gathers git activity (commits, branch, open PRs via `gh`), reads the matching
ticket statuses, reconciles git ↔ tickets, and proposes status updates.

→ *Result*: a standup (Done / In progress / Next / Blockers) + proposed transitions
(`ASSET_API-211 → Done`) applied after confirmation.

> ⚠️ **`/daily` needs a spec source to be worthwhile.** Its value is the **git ↔ spec
> reconciliation** and the **status updates**. By default that source is **local Markdown
> specs under `specs/`** (no MCP needed — it reads/updates the `status:` field); if the
> project tracks work in **JIRA**, the Atlassian MCP is used instead. With neither, `/daily`
> degrades to a plain commit/PR summary that `git log` and `gh pr list` already give you —
> plan with `/plan-feature` to make it worthwhile. (By contrast, `/ship` only needs the
> source for its single sync step; everything else works without it.)

## `/ship`

```
/ship ASSET_API-211
```
A quality **gate**: shows the diff, runs tests + lint, runs the security review, then (only
if green) writes a Conventional Commit, opens/updates the PR via `gh`, refreshes docs, and
syncs the ticket. Stops on any blocker.

→ *Result*: e.g. “tests ✅, security ⚠️ (1 required fix) → stopped”. Fix and re-run; once
green it opens PR #142 and moves `ASSET_API-211` to In Review.

## `/adr`

```
/adr Use a Celery worker + Redis for the Excel import instead of synchronous processing
```
Creates the next-numbered `docs/adr/NNNN-*.md` (Nygard format) — Context, Decision,
Consequences, Alternatives — pulling real detail from the code and conversation.

→ *Result*: `docs/adr/0007-celery-worker-for-excel-import.md` (Status: Proposed), committed
with a `docs:` commit if you ask.
