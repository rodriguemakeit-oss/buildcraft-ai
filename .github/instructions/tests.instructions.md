---
applyTo: "**/test_*.py,**/*_test.py,**/tests/**,**/*.{test,spec}.{ts,tsx,jsx},**/__tests__/**"
---

# Tests — Copilot path-scoped instructions

Apply the canonical standard **`standards/testing.md`** (in the `buildcraft-ai` repo on your
`COPILOT_CUSTOM_INSTRUCTIONS_DIRS`). **Read it — don't restate or reinvent it.**

Reminders (full text in the standard):

- Cover the **happy path AND error cases** (404/409/validation), not just success.
- Backend pyramid: `test_repository.py` (unit, DB), `test_service.py` (unit, repo mocked/
  injected), `test_router.py` (integration, `httpx.AsyncClient`).
- Frontend: test **behavior** (what the user sees); mock the network at the fetch level (MSW);
  cover loading / error / empty / data states.
- Determinism: no real network, no `sleep`, no reliance on test ordering or shared state.
- Name by intent: `test_<action>_<condition>_<result>`. Reuse the project's fixtures/factories.
