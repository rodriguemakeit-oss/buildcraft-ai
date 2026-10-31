# ADR-0001 — Claude-native sub-agents, not BMAD as an engine

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: README.md, agents/

## Context

We needed a reusable foundation for AI-assisted development across the `portfolio/` projects.
BMAD offers a useful role taxonomy (PM / Architect / Dev / QA) and planning artifacts, but
it is a heavy external engine. Claude Code natively supports sub-agents, skills, commands
and hooks distributed as a plugin.

## Decision

We build the foundation on **native Claude Code sub-agents, skills, commands and hooks**,
distributed as a Claude Code plugin via a local marketplace. We borrow **only** BMAD's role
taxonomy and its planning artifacts (lightweight PRD, story breakdown) — not its engine.

## Consequences

- + Idiomatic to Claude Code, no external runtime, easy to evolve and version.
- + The same primitives (agents/skills/commands) compose naturally.
- − We own and maintain our agents and standards instead of inheriting them.

## Alternatives considered

- **BMAD as the engine** — rejected: heavy external dependency, not native to Claude Code.
- **Plain prompts / a single mega-agent** — rejected: not reusable, no separation of roles,
  no on-demand loading.
