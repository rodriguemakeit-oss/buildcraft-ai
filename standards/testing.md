# Standard — Testing

## Principles

- **Every feature ships with its tests.** No PR without tests.
- **Pyramid**: many unit tests, fewer integration, a few end-to-end.
- **Isolation**: a test does not depend on ordering or on another test's state.
- **Determinism**: no real network, no uncontrolled system clock.

## Backend (pytest)

- Tests **mirror the code layout** (`standards/backend-fastapi.md`): feature/vertical →
  `tests/{feature}/test_*.py`; layer/horizontal → `tests/{layer}/test_{feature}.py`.
- `test_repository.py` — unit, DB queries (test DB / transaction rollback).
- `test_service.py` — unit, business logic, repository mocked/injected.
- `test_router.py` — integration, `httpx.AsyncClient`, status codes + payloads.
- `conftest.py`: fixtures `async session`, `client`, data factories.
- Coverage target defined per project (e.g. ≥ 80% lines, 100% on critical services).

```python
@pytest.mark.asyncio
async def test_get_user_not_found(client: AsyncClient):
    resp = await client.get("/users/999")
    assert resp.status_code == 404
```

## Frontend (RTL + Vitest/Jest)

- Test **behavior** (what the user sees), not implementation.
- One test per key component: render, interaction, error/loading/empty states.
- Mock the network at the fetch level (MSW preferred).

## Cross-cutting rules

1. Name tests by intent: `test_<action>_<condition>_<result>`.
2. Cover the happy path **and** error cases (404/409/validation).
3. No `sleep`; use conditional waits.
4. Tests run in CI and via the `/ship` hook before push.
