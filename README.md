# Buildcraft AI

Reusable engineering standards and coding-assistant workflows for FastAPI and React projects.

## What is included

- `standards/` — shared conventions for APIs, security, testing, documentation, and delivery
- `agents/`, `skills/`, `commands/`, `hooks/` — focused development workflows
- `AGENTS.md` and `.github/instructions/` — repository guidance and tool adapters
- `docs/` — setup guides, command examples, and architecture decisions

## Getting started

Choose the [Claude Code guide](docs/claude-code.md) or the [GitHub Copilot CLI guide](docs/copilot-cli.md). Start with the standards, then tailor authentication, UI components, and project tracking to your application.

## Design

The standards directory is the canonical source; integrations point to it instead of maintaining separate copies of the same rules. The repository includes no hosted service or project credentials.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution and versioning practices, and [VALIDATION.md](VALIDATION.md) for validation details.