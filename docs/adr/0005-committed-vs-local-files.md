# ADR-0005 — Committed shared artifacts vs local per-developer files

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: commands/onboard-project.md, standards/pre-commit.md, standards/pull-request.md, standards/api-contract.md

## Context

`/onboard-project` and `/new-project` generate several files. Some hold **per-developer**
configuration or credentials; others are **shared team artifacts** that everyone must run
against. Treating them the same would either leak local config or lose shared quality gates.

## Decision

- **Local, not committed** (added to `.git/info/exclude`): `CLAUDE.md`, `.mcp.json`,
  `.claude/` — they hold per-developer overrides and credentials.
- **Committed, shared**: `.pre-commit-config.yaml`, `.secrets.baseline`,
  `.github/pull_request_template.md`, `docs/adr/`, and the generated API contract
  (`openapi.json` snapshot + generated front types).

## Consequences

- + Secrets and personal preferences stay out of the repo; shared quality artifacts are
  versioned and consistent across the team.
- − Contributors must know which is which — documented in `CONTRIBUTING.md`.

## Alternatives considered

- **Commit everything** — rejected: leaks local config and credentials (`.mcp.json`).
- **Commit nothing** — rejected: loses the shared pre-commit / PR / contract artifacts.
