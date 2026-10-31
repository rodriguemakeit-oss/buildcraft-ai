# Standard — Authentication & authorization (Okta)

**Okta** is the identity provider (OIDC / OAuth2). This standard consolidates the auth rules
referenced across `security.md`, `backend-fastapi.md` and `frontend-react.md`. Golden rule:
**authentication ≠ authorization** — verify *who* the caller is **and** check *what* they're
allowed to do, on every protected operation.

## Backend (FastAPI) — verify the token

- **Verify the JWT on every protected endpoint**: signature against Okta's **JWKS** (fetch +
  cache the keys), and the `iss`, `aud`, `exp`/`nbf` claims. Reject with **401** on a
  missing/invalid/expired token.
- Implement it once as a **dependency** (`Depends`) that extracts the bearer token, verifies
  it, and returns the **principal** (user id + roles/scopes from the claims). Reuse it; never
  re-implement per route.
- **No signing secret in code.** Issuer, audience and JWKS URL come from config
  (pydantic-settings / env). Keys are rotated by Okta — always go through JWKS, never pin a key.

## Backend — authorize the action

- **Per-resource authorization**, explicit: ownership and/or role/scope, enforced in the
  dependency or the service — **not** just "is authenticated". Reject with **403** on
  insufficient rights (distinct from 401).
- Roles/scopes come from the token claims (e.g. `groups` / `scp`). **Least privilege**:
  default deny, grant explicitly.

## Frontend (React)

- `@okta/okta-react` + `okta-auth-js`: login redirect, protected routes, and the token
  manager for storage/refresh. Attach the access token as `Authorization: Bearer <token>` on
  API calls.
- **Token storage**: prefer the okta-auth-js token manager / in-memory; don't put tokens in
  `localStorage` without a justified reason (`security.md`).
- **UI role-gating is UX, not security**: hiding a button by role is fine, but the **server
  must enforce** it anyway — never trust the client.

## Cross-cutting

- **Local dev**: use a dev Okta tenant or a test token; **never disable auth** on a shared
  environment.
- **Observability** (`observability.md`): log auth **failures** (no tokens/secrets/PII),
  include the user id (an identifier, not personal content) for correlation.
- **Testing** (`testing.md`): cover protected endpoints — **401** (no/invalid token) and
  **403** (wrong role); in unit/integration tests, override the auth dependency to inject a
  fake principal instead of minting real tokens.
