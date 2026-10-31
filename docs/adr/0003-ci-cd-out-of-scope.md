# ADR-0003 — CI/CD is out of scope (owned by the infra team)

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: standards/observability.md, standards/commits.md, ADR-0006

## Context

The infra team owns the CI/CD pipelines, deployments, and log forwarding/aggregation
(Splunk / AWS-managed). Duplicating that in the foundation would create conflicting
ownership.

## Decision

The foundation's quality chain stops at **pre-commit**. There is **no CI standard or
command** (e.g. no `/setup-ci`). Apps **emit** structured logs to stdout + OpenTelemetry
(OTLP); the infra forwards/aggregates them. `/onboard-project` **keeps** `.github/workflows/`
untouched.

## Consequences

- + Clear ownership boundary, no duplication or conflict with infra.
- + The app stays decoupled from any specific observability backend.
- − The release tag + changelog are produced by the infra pipeline, so we must feed it clean
  input via Conventional Commits (see ADR-0006).

## Alternatives considered

- **Ship our own CI scaffolding / Renovate config** — rejected: crosses the infra boundary;
  at most a sample config left for infra to activate.
