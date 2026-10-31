# Architecture Decision Records — buildcraft-ai

The foundation's own design decisions (it dogfoods `standards/adr.md`). Each ADR records one
significant decision and **why**. ADRs are immutable once Accepted — to change a decision,
add a new ADR that supersedes the old one. New decision? Run `/adr`.

| # | Decision |
|---|---|
| [0001](./0001-claude-native-sub-agents-over-bmad.md) | Claude-native sub-agents, not BMAD as an engine |
| [0002](./0002-english-only-canonical-content.md) | English-only canonical content (one FR reading-guide exception) |
| [0003](./0003-ci-cd-out-of-scope.md) | CI/CD is out of scope (owned by the infra team) |
| [0004](./0004-single-target-stack-fastapi-react.md) | Single target stack (FastAPI + React); off-stack via /refonte |
| [0005](./0005-committed-vs-local-files.md) | Committed shared artifacts vs local per-developer files |
| [0006](./0006-no-release-command.md) | No /release command; Conventional Commits feed the infra pipeline |
| [0007](./0007-dual-target-claude-and-copilot.md) | Dual target (Claude Code + Copilot CLI) from one source; global per-dev |

Template: [`0000-template.md`](./0000-template.md).
