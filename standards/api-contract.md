# Standard — API contract (OpenAPI)

The backend's **OpenAPI schema is the single source of truth** for the HTTP contract. The
frontend never hand-writes request/response types — it **generates** them from that schema.
Critical for **separate repos** (the only contract between `*-backend` and `*-frontend`);
useful in a monorepo too. See `standards/project-layout.md`.

## Backend (producer)

- FastAPI auto-generates the schema at `/openapi.json` (Swagger UI at `/docs`). Keep it
  accurate: every endpoint typed with Pydantic v2 request/response models, explicit
  `response_model`, and documented status codes (incl. error ones).
- **Consistent envelopes**: a stable **error shape** (`standards/api-errors.md`) and a stable
  pagination shape across endpoints — the front depends on both.
- **Export a committed snapshot** so the front can regenerate without running the API:
  ```bash
  python -c "import json, app.main as m; print(json.dumps(m.app.openapi()))" > openapi.json
  ```
  Commit `openapi.json` at the backend root (separate repos) or at `back/` (monorepo).
  Regenerate it whenever the contract changes; treat a diff as a contract change to review.

## Frontend (consumer)

- Generate TypeScript types from the schema with **`openapi-typescript`** into
  `src/api/types.ts` (do not edit by hand — regenerate). Pair with a typed client
  (`openapi-fetch`) or, for TanStack Query hooks, `orval` — pick one per project and stay
  consistent.
- Source of the schema:
  - **Monorepo**: read the backend's `back/openapi.json` (or `http://localhost:8000/openapi.json`).
  - **Separate repos**: consume the **committed `openapi.json`** from the backend repo
    (pinned/vendored), not a live URL, so the front builds reproducibly.
- Generated types/clients are **committed** (a build artifact teammates rely on), regenerated
  via the `sync-api-types` skill.

## Versioning & breaking changes

- Version the API path (`/api/v1/...`). A breaking change (removed/renamed field, changed
  type, stricter validation) requires a new version or a coordinated front update — never
  silently break consumers.
- Keep the front's generated types **in sync** with the backend snapshot. A drift means the
  front is built against a stale contract: regenerate and reconcile before shipping.

## Workflow

1. Backend changes an endpoint/model → re-export `openapi.json`.
2. Front runs the `sync-api-types` skill → regenerates `src/api/types.ts` (+ client/hooks).
3. TypeScript surfaces any break at compile time; fix the callers.
4. `/ship` checks the contract is current as part of the pre-ship gate.
