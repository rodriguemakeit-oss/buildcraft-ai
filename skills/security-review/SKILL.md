---
name: security-review
description: >
  Applies the security checklist (OWASP, secrets, Okta authz, injection, dependencies) to a
  diff or a targeted area, ranked by severity. Use before /ship or on any sensitive change.
---

# Security review

Apply `standards/security.md` as the checklist. Scope to the diff when one exists
(`git diff` staged or vs the base branch); otherwise audit the targeted area. This is a
**review**: report findings, do not edit production code.

1. Identify the changed/targeted files and the sensitive surfaces (auth, personal data,
   dynamic queries, file/network I/O, new dependencies).
2. Walk the checklist:
   - **Secrets**: no hardcoded keys/tokens/passwords/credential URIs; `.env` not committed;
     no prod creds in `.mcp.json`.
   - **Authn/Authz (Okta)**: JWT verified (signature, `iss`, `aud`, expiry); explicit
     per-resource authorization, not just authentication.
   - **Input & DB**: strict Pydantic validation; ORM/parameterized queries only; payload
     size and pagination capped.
   - **Transport/exposure**: HTTPS/HSTS, security headers, CORS restricted, rate limiting
     on auth/writes, non-verbose errors (no stack traces in prod).
   - **Logging**: no secrets / personal data in logs.
   - **Dependencies**: run `pip-audit` / `npm audit` when available; flag vulnerable pkgs.
3. Gather evidence with `grep`/`git`/audit tools where useful.
4. Report findings ranked **Critical / High / Medium / Low**, each with file:line and a
   concrete fix.
5. End with a verdict: **PASS** / **PASS with required fixes** / **BLOCK**.
