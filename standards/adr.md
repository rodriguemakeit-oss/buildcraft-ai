# Standard — Architecture Decision Records (ADR)

An **ADR** captures one significant, hard-to-reverse decision and **why** it was made, so
six months later (or for a newcomer) the rationale is in the repo — no Git archaeology, no
lost context. Lightweight (Michael Nygard format), one file per decision, versioned.

## When to write one

Write an ADR for a decision that is **structural and costly to change**, e.g.: monorepo vs
separate repos, async vs sync SQLAlchemy, OpenTelemetry vs a vendor SDK, auth model, a new
external dependency or service, an API-versioning choice. **Not** for everyday code choices.

## Location & naming

- Live in `docs/adr/` in the project repo, **committed** (shared knowledge, not local).
- `NNNN-kebab-title.md`, zero-padded sequential number: `0001-use-async-sqlalchemy.md`.
- `docs/adr/0000-template.md` holds the template. ADRs are immutable once **Accepted**: to
  change a decision, write a **new** ADR that supersedes the old one (link both ways).

## Statuses

`Proposed` → `Accepted` → (later) `Deprecated` / `Superseded by ADR-XXXX`. Never edit the
decision of an accepted ADR; supersede it instead.

## Template

```markdown
# ADR-NNNN — <title>

- **Status**: Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
- **Date**: YYYY-MM-DD
- **Deciders**: <people / roles>
- **Refs**: <ticket key, PR, related ADRs>

## Context

The problem, the forces and constraints at play, what makes this decision non-trivial.

## Decision

What we decided, stated plainly (active voice: "We will …").

## Consequences

What becomes easier and what becomes harder as a result — including the trade-offs we
accept and any follow-up work this implies.

## Alternatives considered

Each option weighed and **why it was not chosen** (this is the part future-you needs).
```

## How it ties in

- Created via the `/adr` command (auto-numbers the next ADR from this template).
- `pm-planner` may propose an ADR when planning surfaces a structural choice; `/ship` may
  suggest one when a diff encodes a non-obvious architectural decision.
- ADRs complement (don't replace) the `standards/` (org-wide rules) and `CLAUDE.md`
  (project specifics): an ADR records a **project's own** decision and its history.
