# Contributing to buildcraft-ai

This repo is the **source of truth** for how `portfolio/` projects are built with Claude Code and
GitHub Copilot CLI. It is meant to be **self-sufficient**: everything a contributor needs is in
the repo — the design rationale lives in [`docs/adr/`](./docs/adr/README.md), the status in
[`ROADMAP.md`](./ROADMAP.md), the usage in [`docs/claude-code.md`](./docs/claude-code.md) /
[`docs/copilot-cli.md`](./docs/copilot-cli.md) (FR guides:
[`claude-code.fr.md`](./docs/claude-code.fr.md), [`copilot-cli.fr.md`](./docs/copilot-cli.fr.md)).

> No external memory required. (A maintainer's Claude Code instance may hold local memory,
> but it is **not** a dependency — the repo stands on its own.)

## Design principles

- **Claude-native** primitives only: agents, skills, commands, hooks, standards (ADR-0001).
- **Standards are the source of truth.** Agents/skills/commands *apply* standards; they don't
  restate them — they link to `standards/*.md`. In reminders, **name the concern, not the mutable
  value** (write "respect the function-size limit", not the number) so changing a value touches
  only the standard — never the wrappers.
- **Dual target, one source** (ADR-0007): the socle also serves **GitHub Copilot CLI** via thin
  adapters (`AGENTS.md`, `.github/instructions/*.instructions.md`) that **only point** to
  `standards/`. A rule evolution = a single edit in `standards/`; the adapters don't change. See
  [`docs/copilot-cli.md`](./docs/copilot-cli.md).
- **Reusable logic lives in a standard, not in an agent.** If a behavior should reach both tools,
  put the rules in `standards/*.md` and have the agent **and** the Copilot adapters point to it
  (e.g. doc-writing → `standards/documentation.md`). An agent that hoards its own rules can't be
  shared.
- **English-only** canonical content; the only French files are **reading guides**
  (`docs/*.fr.md`) (ADR-0002, extended by ADR-0007).
- **Target stack = FastAPI + React** (ADR-0004). Don't add other-stack agents.
- **CI/CD is out of scope** — owned by infra; the chain stops at pre-commit (ADR-0003).
- **Keep it lean.** A new piece must earn its place; prefer extending an existing standard to
  adding a near-duplicate. Wire every new piece into the agents/commands that should use it.

## How to add a component

| Add a… | Where | Then |
|---|---|---|
| **Standard** | `standards/<name>.md` | link it from the agents/commands/standards that apply it; if backend/frontend devs should follow it, also point to it from the Copilot adapters (`AGENTS.md`, `.github/instructions/*.instructions.md`) — **pointer only, no rule text**; add to the `docs/claude-code.md` "Contents" + "Status" lists and the `docs/claude-code.fr.md` table |
| **Agent** | `agents/<name>.md` (frontmatter: name, description, tools, model) | reference the standards it reads; add to `docs/claude-code.md` + `.fr.md` tables |
| **Skill** | `skills/<name>/SKILL.md` | reference its standard; have the relevant agent invoke it; add to `docs/claude-code.md` + `.fr.md` |
| **Command** | `commands/<name>.md` (frontmatter: description, argument-hint) | keep it an orchestrator that delegates to agents/skills/standards; add an example to `docs/claude-code-commands.md` + `docs/claude-code.fr.md`, and its Copilot equivalent to `docs/copilot-cli-commands.md` (+ `.fr.md`); add to `docs/claude-code.md` + `.fr.md` |
| **Hook** | `hooks/<name>.sh` + register in `hooks/hooks.json` | read the hook JSON from stdin; stay best-effort (only the secret guard blocks) |

Keep command prompts lean — put examples in `docs/claude-code-commands.md`, not in the command file (it's
loaded into context on every invocation).

## Committed vs local (ADR-0005)

- **Local, not committed** (per developer): `CLAUDE.md`, `.mcp.json`, `.claude/`.
- **Committed, shared**: `.pre-commit-config.yaml`, `.secrets.baseline`,
  `.github/pull_request_template.md`, `docs/adr/`, the generated API contract.

## Decisions

Record any significant, hard-to-reverse decision as an ADR in
[`docs/adr/`](./docs/adr/README.md) (run `/adr`). ADRs are immutable once Accepted; supersede
rather than edit.

## Versioning & releasing the plugin

- Bump `version` in `.claude-plugin/plugin.json` on **every notable change** (Claude's plugin
  update is version-based). Roughly: new agent/skill/command/standard → minor; doc/wording/
  wiring fix → patch. Keep the **version badge in `README.md`** in sync with the same number.
- Commits follow **Conventional Commits** (`standards/commits.md`); the `commit-msg` hook
  validates them.
- The `standards/` and agents are code: change them via PR + review. Use the PR template /
  the Definition of Done (`standards/pull-request.md`).
- The marketplace points at the **remote** so teammates `marketplace update` + `plugin update`
  without a local clone (see [`docs/claude-code.md`](./docs/claude-code.md)).
