---
applyTo: "**/alembic/**,**/migrations/**,**/versions/*.py"
---

# Database migrations (Alembic) — Copilot path-scoped instructions

Apply the canonical standard **`standards/migrations.md`** (in the `buildcraft-ai` repo on your
`COPILOT_CUSTOM_INSTRUCTIONS_DIRS`); the `alembic-migration` skill scaffolds one. **Read it —
don't restate or reinvent it.**

Reminders (full text in the standard):

- **Autogenerate, then mandatory manual review** — never trust the generated script blindly.
- One logical change per migration; clean `revision`/`down_revision` chain, no branches.
- A working `downgrade()` (reversible) unless truly impossible — then say so explicitly.
- No data loss without an explicit, called-out decision. Keep the project's async setup.
- Validate on a dev DB: `alembic upgrade head` → `downgrade -1` → back up. Flag sensitive
  migrations (drops, PII columns, large backfills) for security review.
