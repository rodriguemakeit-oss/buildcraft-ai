# Standard — Security

Checklist applied by the `security-reviewer` agent and the secret-blocking hook.

## Secrets & config

- **No hardcoded secrets** (keys, tokens, passwords, URIs with credentials). Everything in
  env vars / a secrets manager. `.env` never committed.
- `.mcp.json`: no prod credentials; **read-only** Postgres user for inspection.

## Authentication & authorization (Okta)

Full rules in `standards/auth-okta.md`. In short:
- Verify the JWT (signature, `iss`, `aud`, expiry) on every protected endpoint.
- Explicit authorization per resource (ownership / role), not just authentication.
- No signing secret in code; keys via Okta JWKS.

## Input & DB

- Strict Pydantic validation on all inputs; reject the unexpected.
- **Always** use the ORM or parameterized queries — never concatenated SQL (injection).
- Cap payload size and max pagination.

## Transport & exposure

- HTTPS everywhere (terminated by Traefik); HSTS, security headers.
- CORS restricted to known origins.
- Rate limiting on sensitive endpoints (auth, writes).
- Non-verbose error messages (no stack trace exposed in prod) — see `standards/api-errors.md`.

## Dependencies & CI

- `pip-audit` (Python) / `npm audit` (front) in CI; track updates.
- `bandit` (Python) and `detect-secrets` in pre-commit (see `standards/pre-commit.md`,
  scaffolded by `/setup-precommit`).

## Logging

- No secrets or personal data (PII) in logs — redact before logging. Structured logs and
  correlation are covered by `standards/observability.md`.

## Review (security-reviewer)

On every sensitive diff: secrets? missing authz? injection? weak validation? sensitive
data logged? CORS/headers? vulnerable dependency?
