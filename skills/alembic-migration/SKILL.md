---
name: alembic-migration
description: >
  Creates an async Alembic migration from a model change: autogenerate, mandatory manual
  review, then apply with an up/down round-trip check. Use after any model change.
---

# Create an Alembic migration

Apply `standards/backend-fastapi.md`. Detect the layout and locate `alembic.ini` +
`alembic/` (or `migrations/`); keep the project's existing **async** setup.

1. Confirm the model change and read the current history (`alembic history --verbose`,
   `alembic current`).
2. Autogenerate: `alembic revision --autogenerate -m "<short intent>"`.
3. **Mandatory manual review** of the generated script — never apply blindly:
   - Detected ops match the intent (no spurious drops from metadata drift).
   - Server defaults, enum changes, index/constraint **names** are explicit and stable.
   - Nullable → not-null on a populated table is split (add nullable → backfill → enforce).
   - Foreign-key/table creation order is correct.
   - `downgrade()` is present and actually reverses `upgrade()`.
4. Add any required **data migration** (batched backfill) by hand inside the script.
5. Round-trip on a dev DB: `alembic upgrade head` → `alembic downgrade -1` →
   `alembic upgrade head`. Fix until clean.
6. Report: revision id, ops, reversibility, data steps, and risks.

If the migration drops data, touches PII columns, or runs a large backfill, flag it for
the `security-reviewer` / `db-migration` agent before applying it anywhere shared.
