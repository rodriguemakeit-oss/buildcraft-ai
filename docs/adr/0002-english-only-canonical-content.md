# ADR-0002 — English-only canonical content (one FR reading-guide exception)

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: README.fr.md

## Context

Readers and contributors include non-anglophones. But the standards/agents/skills/commands
are **loaded into the agents' context** at runtime, and a single working language keeps the
content consistent and avoids divergence.

## Decision

All **canonical content** (standards, agents, skills, commands, README, docs) is written in
**English**. The **only** exception is `README.fr.md` — a French *reading guide* (overview,
component map, glossary) that explains the repo without translating it. Canonical files stay
English; the guide stays high-level so it doesn't drift.

## Consequences

- + One working language for the agents; a single source of truth.
- + Non-anglophones still have a French entry point.
- − The FR guide must be kept roughly in sync when components are added/renamed.

## Alternatives considered

- **Translate every file** — rejected: duplicates the repo, guaranteed drift, breaks the
  agents' working language.
- **A French summary block at the top of each file** — rejected: token bloat and noise in
  the context the agents load.
