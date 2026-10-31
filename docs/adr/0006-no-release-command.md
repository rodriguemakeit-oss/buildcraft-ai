# ADR-0006 — No /release command; Conventional Commits feed the infra pipeline

- **Status**: Accepted
- **Date**: 2026-06-27
- **Deciders**: Massinissa
- **Refs**: standards/commits.md, ADR-0003

## Context

On merge to the prod branch, the **infra release pipeline already creates the Git tag and the
CHANGELOG**, deriving the version bump and the changelog from the commit messages. A
foundation `/release` command would duplicate — and could conflict with — that pipeline.

## Decision

The foundation provides **no `/release` command**. Instead it keeps the pipeline's **inputs**
clean: **Conventional Commits** (`standards/commits.md`) enforced by a `commit-msg`
pre-commit hook, so the pipeline derives the correct bump and a readable changelog.

## Consequences

- + No duplication or conflict with infra; correct bumps and changelog with no extra step.
- − Relies on the pipeline keying off commit messages — align the allowed commit `type`s to
  what the pipeline consumes (some pipelines key off PR titles instead).

## Alternatives considered

- **Own `/release` + changelog generation** — rejected: redundant with the infra pipeline,
  double source of truth, tag/changelog conflicts.
