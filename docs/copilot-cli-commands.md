# GitHub Copilot CLI — the equivalent of each command

Claude Code commands (`/ship`, `/daily`…) are **Claude-specific**: they live in `commands/` and
Copilot CLI does not read them. But a command is just a saved prompt that **orchestrates the
standards/agents/skills**. So in Copilot you reach the same result by **typing that prompt
yourself** — referencing the same standard (and, where useful, the shared skill).

> Prerequisite: the socle is wired globally (see [`copilot-cli.md`](./copilot-cli.md)), so
> `AGENTS.md` + the path-scoped instructions are already in context and the standards live in
> your `~/buildcraft-ai` clone. Skills are available too — Copilot reads them from
> `~/.agents/skills`, so you can invoke e.g. `security-review` or `scaffold-fastapi-feature`
> directly.

## Quick map

| Claude command | Copilot equivalent | Leans on |
|---|---|---|
| `/new-project` | prompt: scaffold from the standards (no `CLAUDE.md`/`.mcp.json`) | `project-layout`, `backend-fastapi`, `frontend-react`, `pre-commit` |
| `/onboard-project` | **nothing to do** — the socle is already global; optionally set up pre-commit | `pre-commit` |
| `/refonte` | prompt: reverse-engineer → rebuild on the standards (do it in stages) | `legacy-analyst` method, all dev standards |
| `/refactor-audit` | prompt: audit vs the standards, ranked gaps with `file:line` | all standards |
| `/setup-precommit` | prompt: set up pre-commit for the stack | `pre-commit` |
| `/setup-observability` | prompt: add structured logs (opt-in; metrics/tracing on demand) | `observability` |
| `/plan-feature` | prompt: PRD + story breakdown → local specs (default) or JIRA | `tracker` (JIRA optional) |
| `/daily` | prompt: reconcile git ↔ specs, propose transitions | `tracker` (JIRA optional) |
| `/ship` | prompt: tests + lint + security review → PR | `pull-request`, `security-review` skill |
| `/adr` | prompt: write the next ADR | `adr` |

There is **no saved shortcut** — you type the prompt. (You *could* turn the frequent ones into
real Copilot shortcuts via custom agents in `.github/agents/*.agent.md`; deliberately not done
yet — see the agents discussion in `copilot-cli.md`.)

## Per command (copy-paste prompts)

### `/new-project`
```
Scaffold a new FastAPI + React monorepo following standards/project-layout.md:
back/ (Clean Architecture per standards/backend-fastapi.md) + front/ (Vite + React + TS +
Tailwind + portfolio Fluid per standards/frontend-react.md), a docker-compose, and pre-commit
per standards/pre-commit.md. Then git init and make the initial commit.
```
Heavy orchestration — drive it in steps. Note: Copilot has **no** `CLAUDE.md`/`.mcp.json` (those
are Claude-only); your instructions come from the global socle, not per-project files.

### `/onboard-project`
For Copilot there is usually **nothing to onboard**: the global setup
([`copilot-cli.md`](./copilot-cli.md)) already wires the socle for *every* project, and there is
no `CLAUDE.md`/`.mcp.json` to generate. The one shared, committed artifact worth adding is
pre-commit — see `/setup-precommit` below. (If your team wants the standards *committed* into the
repo, that's the per-project model we deliberately did **not** choose — see ADR-0007.)

### `/refonte`
```
Reverse-engineer this legacy app into a target-agnostic spec: inventory the stack, data model,
API surface, business rules and risks, citing file:line. Then rebuild it on standards/ (FastAPI
+ React), checking behavior against the legacy for parity.
```
Big task — split it: spec first, then rebuild feature by feature.

### `/refactor-audit`
```
Audit this project against the standards in ~/buildcraft-ai/standards. List the gaps ranked
Critical/High/Medium/Low, each with file:line and a concrete fix. Don't change anything yet.
```

### `/setup-precommit`
```
Set up pre-commit for this stack per standards/pre-commit.md: hygiene hooks, detect-secrets,
conventional-commits, ruff + bandit (Python), eslint + prettier (front). Generate
.secrets.baseline and install both git stages, then run a baseline pass.
```
Pre-commit is **tool-agnostic**, so the result is identical to the Claude command. This is the
shared enforcement gate for both tools.

### `/setup-observability`
```
Set up observability for this project per standards/observability.md. It's opt-in: by default
add structured JSON logging to stdout (structlog) with a request_id middleware and /health +
/ready. Ask me before adding metrics (prometheus-client on /metrics) or distributed tracing
(OpenTelemetry/OTLP) — don't pull those in unless I confirm.
```
Nothing is added to a scaffolded backend by default — run this to opt in. The app only emits;
collection/dashboards/alerting belong to infra.

### `/plan-feature`
```
Write a lightweight PRD and a vertical-slice story breakdown (acceptance criteria as
Given/When/Then, S/M/L estimate, layers touched) for: <feature>. First reuse any existing
specs in the repo; then ask me where specs go — local Markdown under specs/epic-xx/us-xxx
(default) or JIRA — and create the epic + stories there idempotently.
```
Per `standards/tracker.md`, **local Markdown specs are the default and need no MCP**. Only pick
JIRA if the team tracks work there (Atlassian MCP in `~/.copilot/mcp-config.json`). Always ask
first, and reuse specs already copied into the repo instead of regenerating.

### `/daily`
```
Reconcile my git activity (recent commits, current branch, open PRs via gh) with my specs.
Produce a standup — Done / In progress / Next / Blockers — and propose the status transitions
(e.g. merged PR → Done). Apply them only after I confirm.
```
The value is the **git ↔ spec** reconciliation. By default that source is **local Markdown specs
under `specs/`** (no MCP — it reads/updates the `status:` field); JIRA is used only if the
project tracks work there. With neither, this degrades to a git summary `git log` already gives.

### `/ship`
```
Prepare this branch to ship per standards/pull-request.md: run the tests and lint, run a
security review (use the security-review skill), and only if everything is green write a
Conventional Commit and open/update the PR via gh. Stop and tell me on any blocker.
```
Unlike the Claude command, this is a **manual gate** — there's no enforced stop, so read each
step before continuing.

### `/adr`
```
Write the next-numbered ADR in docs/adr/ following standards/adr.md (Nygard format: Context,
Decision, Consequences, Alternatives) for this decision: <decision>.
```
