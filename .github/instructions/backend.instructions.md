---
applyTo: "**/*.py"
---

# Backend (FastAPI) — Copilot path-scoped instructions

Apply the canonical standard **`standards/backend-fastapi.md`** (in the `buildcraft-ai` repo
on your `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`). **Read it — don't restate or reinvent it.** Also
apply, as relevant: `standards/testing.md`, `standards/security.md`, `standards/auth-okta.md`,
`standards/api-errors.md`, `standards/observability.md`, `standards/async-tasks.md`,
`standards/project-layout.md`.

Reminders (full text and rationale live in the standard):

- **Clean Architecture**: Router → Service → Repository → Model, **async first**. Router = HTTP
  only; Service = business rules; Repository = pure data access.
- **Naming & readability**: snake_case for everything PEP 8 lowercases; `PascalCase` only for
  classes/Pydantic schemas. Respect the **function-size and call-depth limits** (compose at the
  caller, don't nest helpers). **Comments**: no decorative banners/separators, no comment that
  restates the code — comment the *why*, not the *what*.
- **Errors**: custom domain exceptions → central exception handlers → canonical error envelope.
  Never a silent `return None` in a service.
- **Auth**: Okta JWT (JWKS, iss/aud/exp) in a reusable dependency + per-resource authorization
  (401 vs 403). No hardcoded secrets — config via pydantic-settings.
- **Tests** ship with the change: router (integration), service + repository (unit).
- **Local stack** (`standards/project-layout.md`): route services via **Traefik labels** to
  `*.localhost` domains — no `host:port` publishing except Traefik itself.
- If you change the HTTP contract, re-export the OpenAPI snapshot (`standards/api-contract.md`).
