---
applyTo: "**/*.{ts,tsx,jsx}"
---

# Frontend (React + TypeScript) — Copilot path-scoped instructions

Apply the canonical standard **`standards/frontend-react.md`** (in the `buildcraft-ai` repo on
your `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`). **Read it — don't restate or reinvent it.** Also apply,
as relevant: `standards/testing.md`, `standards/security.md`, `standards/auth-okta.md`,
`standards/api-contract.md`.

Reminders (full text and rationale live in the standard):

- **UI = portfolio Fluid Design System first**: use the `NJ*` components from
  `@portfolio-ui/fluid-design-system-react`; **Tailwind** for layout/spacing. Never recreate a
  Fluid component.
- **Strict TypeScript**, no unjustified `any`. API types are **generated** from the backend
  OpenAPI (`sync-api-types`), never hand-written.
- **Naming & readability**: native TS casing — camelCase (vars/functions/hooks), PascalCase
  (components/types). Keep generated OpenAPI field casing as-is. Respect the **function-size and
  call-depth limits** (compose at the caller, don't nest helpers). **Comments**: no decorative
  banners/separators, no comment that restates the code — comment the *why*, not the *what*.
- Data fetching isolated in hooks; explicit **loading / error / empty / data** states.
- **Package manager: npm only** — `npm install`/`npm ci`/`npm run`; commit only
  `package-lock.json`. Never pnpm or yarn.
- Auth via Okta; render API errors from the canonical envelope (`standards/api-errors.md`).
- i18n via the project's library — no hardcoded text. One RTL test per key component.
