---
applyTo: "**/*.md"
---

# Documentation — Copilot path-scoped instructions

Apply the canonical standard **`standards/documentation.md`** (in the `buildcraft-ai` repo on
your `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`). **Read it — don't restate or reinvent it.** Also apply:
`standards/api-contract.md` (API docs honest against the OpenAPI), `standards/security.md`
(no secrets/PII), `standards/commits.md` (`docs:` commits).

Reminders (full text in the standard):

- Write docs **from the real code**, not from imagination; fix drift (stale endpoints, renamed
  commands, removed flags, wrong setup steps, undocumented new public surface).
- Scope = README usage, API/endpoint docs, `docs/` guides, public docstrings. **Do not** touch
  `CLAUDE.md`/`.mcp.json`, `docs/adr/`, product logic or tests.
- Keep examples runnable; match the project's existing voice and structure.
