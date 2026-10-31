---
name: scaffold-fastapi-feature
description: >
  Generates a complete FastAPI feature module (router, service, repository, models,
  schemas, exceptions) plus its tests, compliant with standards/backend-fastapi.md. Use
  when adding a new backend resource/feature.
---

# Scaffold a FastAPI feature

Apply `standards/backend-fastapi.md` and `standards/testing.md`. Detect the layout first
(monorepo `back/` vs standalone), the **code organization** (feature/vertical vs
layer/horizontal — from `CLAUDE.md` and the existing tree), and **align with the project's
real naming** (`crud/` ≈ `repository/`, `error/` ≈ `exceptions.py`, `config/` ≈ `core/`) —
do not impose paths, and never mix the two layouts in one project.

1. Ask for the feature name (**singular**) and its fields (name, type, nullable, unique,
   FK). Confirm the layered convention (Router → Service → Repository → Model).
2. Create the files where the project's layout puts them (same file names either way):
   - **feature/vertical** (default): `app/{feature}/router.py`, `service.py`,
     `repository.py`, `models.py`, `schemas.py`, `exceptions.py`.
   - **layer/horizontal**: `app/routers/{feature}.py`, `services/{feature}.py`,
     `repositories/{feature}.py`, `models/{feature}.py`, `schemas/{feature}.py`,
     `exceptions/{feature}.py` — matching the project's existing variant names.
3. **Router**: `APIRouter(prefix="/{feature}s", tags=["{Feature}s"])`, paginated REST
   endpoints (`list_/get_/create_/update_/partial_update_/delete_`), correct status codes
   (201 create, 204 delete, 404, 409), docstrings for Swagger, DB session via `Depends`.
4. **Schemas**: `{Feature}Create / Update / Response / ListResponse` (Pydantic v2);
   pagination via the shared `PaginatedResponse` pattern.
5. **Service**: business rules, raises custom exceptions, no silent `return None`.
   **Repository**: pure async CRUD, no business logic.
6. **Exceptions**: `{Feature}NotFoundError`, `{Feature}AlreadyExistsError` extending the
   app's base error.
7. **Models**: `mapped_column`, indexes on filtered columns, constraints (unique/check/FK)
   at the model level.
8. **Tests** mirroring the code layout — vertical: `tests/{feature}/test_router.py`,
   `test_service.py`, `test_repository.py`; horizontal: `tests/routers/test_{feature}.py`,
   `tests/services/test_{feature}.py`, `tests/repositories/test_{feature}.py`. Router =
   integration (`AsyncClient`), service + repository = unit — happy path **and** error
   cases (404/409/validation).
9. If a new model was added, chain into the `alembic-migration` skill.
10. Run the feature's tests (and lint if available), fix, and report files created +
    coverage.
