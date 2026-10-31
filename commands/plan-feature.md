---
description: Plan a feature — lightweight PRD + story breakdown, then create the tickets in the tracker
argument-hint: <feature description>
---

Plan the feature described in `$ARGUMENTS` (ask for it if empty).

Delegate to the `pm-planner` agent. It must:

1. Clarify the goal and any ambiguous scope (a few sharp questions, then stop).
2. Produce a **lightweight PRD** (problem, users, in/out of scope, success criteria,
   non-functional needs, open questions).
3. Break it into **vertical stories**, each shipping with tests — title, user story,
   acceptance criteria (Given/When/Then), S/M/L estimate, dependencies, layers touched.
4. **Reuse any existing specs** in the repo first (don't regenerate), then **ask where specs
   go** (`standards/tracker.md`): local Markdown specs (default — `specs/epic-xx/us-xxx.md`,
   preferred even if a JIRA MCP exists), JIRA, or both. Never assume the source.
5. **Create the epic + stories idempotently** in the chosen source (search before create;
   confirm large batches).
6. Report the PRD summary, created specs/tickets (ids/keys + paths/URLs) and a suggested
   build order.

This is planning only — no production code is written here. Hand the build order to the
dev agents (`backend-fastapi`, `frontend-react`, `db-migration`) afterwards.
