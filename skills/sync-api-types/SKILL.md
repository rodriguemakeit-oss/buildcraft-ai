---
name: sync-api-types
description: >
  Regenerates the frontend's TypeScript types (and optional typed client/hooks) from the
  backend OpenAPI schema, and reports any drift. Use when the API contract changed or front
  types look stale. Follows standards/api-contract.md.
---

# Sync frontend types from the backend OpenAPI

Apply `standards/api-contract.md` and `standards/project-layout.md`. The backend OpenAPI is
the source of truth; the front's types are **generated**, never hand-edited.

1. **Locate the schema.**
   - Monorepo: `back/openapi.json` (re-export it first if stale, see step 2) or
     `http://localhost:8000/openapi.json` if the API is running.
   - Separate repos: the **committed `openapi.json`** vendored from the backend repo
     (pinned), not a live URL.
2. **Refresh the backend snapshot** if you can run the backend (keeps it accurate):
   ```bash
   python -c "import json, app.main as m; print(json.dumps(m.app.openapi()))" > openapi.json
   ```
   (Adapt the import path to the project's app factory.)
3. **Generate the types** with the project's tool (detect from `package.json`; default to
   `openapi-typescript`):
   ```bash
   npx --no-install openapi-typescript ./openapi.json -o src/api/types.ts
   ```
   If the project uses `orval` (TanStack Query hooks) or `openapi-fetch`, run its configured
   script instead — stay consistent with what's already set up.
4. **Report drift.** Show the diff on `src/api/types.ts`. If types changed, run `tsc --noEmit`
   (or the project's type-check) to surface broken call sites; list them for the
   `frontend-react` agent to fix. Do not hand-edit the generated file.
5. **Commit policy.** The generated types and the backend `openapi.json` snapshot are
   **committed** (shared build artifacts) — unlike the local onboarding files.
