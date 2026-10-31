# buildcraft-ai

[![version](https://img.shields.io/badge/version-0.23.1-blue.svg)](./.claude-plugin/plugin.json)
[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-D97757?logo=anthropic&logoColor=white)](./docs/claude-code.md)
[![GitHub Copilot CLI](https://img.shields.io/badge/GitHub_Copilot-CLI-24292e?logo=githubcopilot&logoColor=white)](./docs/copilot-cli.md)

> 🇫🇷 Lecteur non anglophone ? Guides de lecture en français :
> [Claude Code](./docs/claude-code.fr.md) · [Copilot CLI](./docs/copilot-cli.fr.md).

Reusable, **AI-tool-agnostic** development foundation for all `portfolio/` projects: specialized
agents, skills, workflows and shared **standards** (the single source of truth) to build and
maintain **FastAPI + React** projects consistently — the same quality end to end
(*edit → commit → review → ship → track*) without reinventing the conventions each time.

It serves a **mixed team from one source**: **Claude Code** (as a plugin) and **GitHub Copilot
CLI** (via thin adapters). The rules live only in `standards/`; both tools point to them, so a
single evolution reaches both (see [ADR-0007](./docs/adr/0007-dual-target-claude-and-copilot.md)).

## What's inside

- `standards/` — **source of truth** for all conventions (backend, frontend, documentation,
  tests, migrations, security, auth, API contract, observability, commits, ADRs…).
- `agents/` · `skills/` · `commands/` · `hooks/` — Claude-native primitives.
- `AGENTS.md` · `.github/instructions/` · `scripts/` — Copilot CLI adapters and setup.

## Documentation

| Guide | What for |
|---|---|
| **[docs/claude-code.md](./docs/claude-code.md)** (FR: [.fr](./docs/claude-code.fr.md)) | Use the socle with **Claude Code**: install the plugin, onboard a project, update, daily flow. |
| **[docs/copilot-cli.md](./docs/copilot-cli.md)** (FR: [.fr](./docs/copilot-cli.fr.md)) | Use the socle with **GitHub Copilot CLI**: global per-dev setup, mapping, trade-offs. |
| **[CONTRIBUTING.md](./CONTRIBUTING.md)** | Design principles, how to add a component, versioning, recording decisions. |
| **[ROADMAP.md](./ROADMAP.md)** | Status of the foundation and what's next. |
| **[docs/adr/](./docs/adr/README.md)** | Architecture Decision Records — the *why* behind the design. |
| **[docs/claude-code-commands.md](./docs/claude-code-commands.md)** | One concrete example per Claude Code command. |
| **[docs/copilot-cli-commands.md](./docs/copilot-cli-commands.md)** | The Copilot CLI equivalent of each command. |

## In short

`standards/` and agents are code: change them via PR + review, bump `version` in
`.claude-plugin/plugin.json` on every notable change, and keep all canonical content in
**English** (the only French files are reading guides: `docs/*.fr.md`). See
[CONTRIBUTING.md](./CONTRIBUTING.md).
