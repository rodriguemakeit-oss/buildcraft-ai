# Standard — Documentation

Source of truth for **user- and developer-facing documentation**: README usage, API/endpoint
docs, usage guides in `docs/`, and public docstrings. Write docs from the **real code**, never
from imagination.

## Principles

- **Truth from code**: read the actual routers/models/components and run/inspect commands to
  verify before documenting. No filler, no invented behavior.
- **No drift**: docs must match the code — fix stale endpoints/params, renamed commands, removed
  flags, wrong setup steps, undocumented new public surface.
- **Tight scope**: documentation only — never touch product logic or tests.
- **Match the project**: follow its existing voice and doc structure; keep examples runnable.

## Scope

Owned:
- `README.md` — what the project is, install, run/test, structure, key commands.
- **API docs** — honest against the OpenAPI (`standards/api-contract.md`): endpoint summaries,
  request/response examples, error/status codes.
- **Usage guides** in `docs/` and **public docstrings** (modules, services, exported
  functions/components) — accurate, concise, example-driven.

Out of scope (owned elsewhere — do not touch):
- `CLAUDE.md` / `.mcp.json` (onboarding: `/onboard-project` & `/new-project`).
- `docs/adr/` ADRs (`/adr`, `standards/adr.md`).
- Production code logic and tests (the dev agents own those).

## Rules

1. **Scope to the change** when a diff exists (`git diff` vs base, or the named feature);
   otherwise audit the docs of the targeted area.
2. Write **from the code**, verifying against the real routers/models/commands.
3. Keep **API docs honest against the OpenAPI** (`standards/api-contract.md`).
4. **No secrets/PII** in docs or examples (`standards/security.md`).
5. Match the project's voice and existing structure; examples must be runnable.
6. **Docstrings: minimal and generic.** As short as possible — one line whenever it can be,
   only what's strictly necessary. **Never reference** an ADR, user story, ticket, issue or
   PR; write a self-contained sentence the reader can understand without any external link.
7. Commit docs with a `docs:` Conventional Commit (`standards/commits.md`).
8. Report code/doc mismatches that need a human decision instead of guessing.
