# ADR-0004 — Single target stack (FastAPI + React); off-stack via /refonte

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: standards/backend-fastapi.md, standards/frontend-react.md, commands/refonte.md, commands/onboard-project.md

## Context

Deep, opinionated standards require a **target stack**. Most `portfolio/` projects are FastAPI +
React, but some existing projects run on other stacks (.NET, Angular, Spring, Express…).
Supporting every stack would dilute the standards and explode maintenance.

## Decision

The standards and dev agents target **FastAPI (Python) + React (TypeScript)**. For an
**existing off-stack project**, `/onboard-project` detects the stack and **asks**: switch to
**`/refonte`** (rewrite onto the standards, with parity) or do a **degraded onboard** (wire
only the cross-cutting standards; the FastAPI/React standards and agents don't apply). We do
**not** add .NET/Angular/… agents.

## Consequences

- + Standards can be deep and specific; agents are expert in one stack.
- + A clear path (`/refonte`) for legacy migration, and a graceful fallback (degraded onboard).
- − Off-stack projects get only the cross-cutting value unless rewritten.

## Alternatives considered

- **Multi-stack support** (agents/standards per framework) — rejected: dilutes the
  foundation, huge maintenance surface, shallow standards.
- **Refuse off-stack projects entirely** — rejected: the degraded onboard still delivers the
  cross-cutting standards.
