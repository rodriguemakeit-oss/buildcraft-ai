---
description: Rebuild an existing project (any stack) onto the FastAPI + React standards — discovery, scaffold, parity rebuild
argument-hint: "[path to the legacy project]"
---

Rewrite the legacy project at `$ARGUMENTS` (ask if empty) **from scratch on the target
standards** (FastAPI + React + the `standards/`), preserving its behavior. For when an
in-place refactor is judged too costly — often because the legacy is on a **different stack**
(Django, Flask, Rails, Express, Spring, .NET, Angular, Vue…).

> Pick the right tool: **same stack, fixable in place → `/refactor-audit`**. **FastAPI+React,
> adopt as-is → `/onboard-project`** (it redirects off-stack projects here). **Greenfield,
> nothing to preserve → `/new-project`.** `/refonte` is the rewrite-with-parity path.
> Confirm this is what's wanted before starting.

## 1. Discovery (framework-agnostic)

Run the `legacy-analyst` agent on the legacy project → the **reverse spec**: feature
catalogue, data model, API surface, business rules (with legacy `file:line`), UI flows,
integrations, and the risk list. Do **not** touch the legacy code — it's the reference.

## 2. Scope & decisions (record as ADRs)

With the user, decide **what to preserve / drop / modernize** from the spec, and the big
choices: target layout (monorepo vs split repos), **backend code organization**
(feature/vertical default vs layer/horizontal — `standards/backend-fastapi.md`),
**data-migration strategy** (schema mapping + ETL), and **cutover approach** (incremental
*strangler-fig* vs big-bang). Record each structural decision with `/adr`
(`standards/adr.md`) — the "why we rewrote / what we dropped" is exactly what ADRs are for.

## 3. Scaffold the target

Run `/new-project`, pre-filling the answers from the spec (name, layout, components, stack
options, infra, tracker). This wires the skeleton + `/setup-precommit` +
`CLAUDE.md`/`.mcp.json` on the standards.

## 4. Plan the rebuild

Hand the reverse spec to `pm-planner` / `/plan-feature`: an **epic** with stories mapped
~1:1 to the legacy features, prioritized (core domain first), as tracker tickets. Each story
carries its parity acceptance criteria drawn from the spec.

## 5. Data migration

Model the new schema (`backend-fastapi` + `db-migration`, Alembic) from the spec's data
model, then plan the **migration scripts** (legacy → new) as their own tracked work. Treat
data as a first-class deliverable, not an afterthought.

## 6. Rebuild iteratively, with parity checks

Per story: `backend-fastapi` / `frontend-react` / `db-migration` implement on the standards
(Clean Architecture, Fluid DS, tests, `api-contract` types, `observability`, Conventional
commits). **Verify behavior against the legacy** using the spec's `file:line` references as
the parity checklist. Keep the legacy running as the reference until parity is reached;
prefer incremental cutover where feasible.

## 7. Report

Coverage of the spec (features rebuilt vs remaining), the ADRs recorded, the data-migration
status, parity gaps, and the next batch. Iterate until parity, then cut over.
