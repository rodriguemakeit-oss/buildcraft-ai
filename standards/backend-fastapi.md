# Standard — Backend FastAPI

Source of truth for all backend Python code in the platform. Clean Architecture, async first.

## Principles

- **Clean Architecture**: strict separation `Router → Service → Repository → Model`.
- **Type safety**: Pydantic v2 for all validation (input/output).
- **Async first**: `async def` for endpoints, services, repositories.
- **Fail fast**: custom domain exceptions, never a silent `return None` in a service.
- **Convention over configuration**: read the existing code before writing, align with it.
- **Testability**: each layer testable in isolation via dependency injection.

## Stack

FastAPI · SQLAlchemy 2.0+ async (`mapped_column`) · Alembic (async) · Pydantic v2 ·
pydantic-settings · pytest + pytest-asyncio + httpx (`AsyncClient`) · stdlib/structlog logging.

## Layered architecture

```
Router (HTTP) → Service (business) → Repository (data) → Model (DB)
     ↕                ↕                     ↕
  Schemas         Exceptions            Session
 (Pydantic)        (custom)          (AsyncSession)
```

- **Router**: HTTP validation, serialization, status codes. No business logic.
- **Service**: business rules, orchestration, raises custom exceptions.
- **Repository**: DB queries, pure CRUD. No business logic.
- **Model**: tables, relationships, DB constraints.

## Code organization (two layouts)

Two layouts are supported. **Feature (vertical) is the default**; a project may instead opt
into **layer (horizontal)**. The choice is made **once** at `/new-project`, recorded in the
project's `CLAUDE.md`, and applied consistently. Agents and skills **detect the existing
layout and follow it** — never mix the two in one project.

The **layering rule (Router → Service → Repository → Model) and every other rule in this
standard are identical in both layouts** — only the physical grouping of files differs.

### Feature / vertical (default)

Everything for one feature lives together; you add or remove a feature without touching
other folders. Scales best past ~10 features.

```
app/
  core/        config.py · database.py · exceptions.py · dependencies.py
  {feature}/   router.py · service.py · repository.py · models.py · schemas.py · exceptions.py
  tests/{feature}/  test_router.py · test_service.py · test_repository.py
```

### Layer / horizontal (opt-in)

Files grouped by technical role, one module per feature inside each layer. Familiar
(Django/Nest), the layer is obvious at a glance — good on small/medium projects.

```
app/
  core/          config.py · database.py · exceptions.py · dependencies.py
  routers/       {feature}.py
  services/      {feature}.py
  repositories/  {feature}.py         # or crud/ (same role)
  models/        {feature}.py
  schemas/       {feature}.py
  exceptions/    {feature}.py         # or a single core/exceptions.py
  tests/
    routers/test_{feature}.py · services/test_{feature}.py · repositories/test_{feature}.py
```

## Naming conventions

- **snake_case** for everything that PEP 8 lowercases: modules/files, functions, methods,
  variables, parameters, table/column names. `PascalCase` only for classes and Pydantic
  schemas; `UPPER_SNAKE_CASE` for constants. No camelCase in Python.
- Router: `APIRouter(prefix="/{feature}s", tags=["{Feature}s"])`
- Endpoints: `list_/get_/create_/update_/partial_update_/delete_{feature}`
- Classes: `{Feature}Service`, `{Feature}Repository`, model `{Feature}` (table plural snake_case)
- Schemas: `{Feature}Create/Update/Response/ListResponse`
- Exceptions: `{Feature}NotFoundError`, `{Feature}AlreadyExistsError`

## Function size & call depth

- **≤ 100 lines per function** (body, excluding signature/docstring). Past that, split into
  focused helpers. Exceptions are allowed only when splitting would *hurt* readability
  (e.g. a single straight-line mapping/serialization); justify them with a short comment.
- **Max call depth of 2 between your own functions.** Avoid `a()` → `b()` → `c()` → `d()`
  chains where each only forwards to the next. Beyond two hops, prefer **composition at the
  caller**: have the orchestrator call the helpers in sequence and pass each result to the
  next, rather than burying the flow inside nested calls.

  ```python
  # ❌ deep chain: each function delegates to the next
  async def handle(payload):        # depth 1 → calls validate
      return await validate(payload)
  async def validate(payload):      # depth 2 → calls persist
      return await persist(payload)
  async def persist(payload): ...   # depth 3 …

  # ✅ flat composition: the service orchestrates, results flow forward
  async def handle(payload):
      data = validate(payload)
      entity = build_entity(data)
      return await repository.save(entity)
  ```

  This keeps the Router → Service → Repository → Model layering as the *only* legitimate
  depth; helpers inside a layer compose at the top, they don't nest into each other.

## Comments — explain *why*, never *what*

The code says *what* it does; a comment earns its place only when it says something the code
cannot. Write **fewer, higher-value** comments.

- **CAPITAL RULE — keep it minimal.** A comment or docstring is **as short as it can be**:
  one line whenever possible, only what's strictly necessary. No preamble, no restatement, no
  padding. If it doesn't earn its length, cut it.
- **No references.** Never point to an ADR, a user story, a ticket, an issue or a PR from a
  comment or docstring. Write a **generic, self-contained** sentence that explains the thing
  itself — the code must be understandable without chasing an external link.
- **No decorative banners or section separators.** No ASCII rules, box-drawing lines, or
  `# ─── Adminer ───────────` headers — in Python, YAML, Dockerfiles, compose files, anywhere.
  Structure comes from functions, modules and files, not from drawn dividers.
- **No comments that restate the code.** `# create the user` above `create_user(...)`, or
  `# lightweight PostgreSQL web UI` next to an obvious service, adds nothing — delete it.
- **Do** comment the non-obvious *why*: a workaround and the reason for it, a subtle invariant,
  a business rule that isn't visible in the types. If a comment would just narrate the next
  line, the better fix is usually a clearer name.
- **Docstrings stay** where they carry contract, not narration: public endpoints (Swagger),
  services/exceptions with non-trivial behavior. Keep them **generic and minimal** — one line
  stating the contract. A docstring that repeats the signature is noise.

## Mandatory patterns

```python
# core/exceptions.py
class AppError(Exception):
    def __init__(self, detail: str, status_code: int = 400):
        self.detail, self.status_code = detail, status_code

class NotFoundError(AppError):
    def __init__(self, entity: str, id):
        super().__init__(f"{entity} with id {id} not found", 404)
```

```python
# Structured pagination
class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]; total: int; skip: int; limit: int; has_more: bool
```

```python
# Global handler
@app.exception_handler(AppError)
async def app_error_handler(request, exc):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
```

```python
# Logging (parameterized, never an f-string at the log call)
logger.info("Creating %s", feature, extra={"data": data.model_dump()})
logger.error("Failed to create %s: %s", feature, e, exc_info=True)
```

## Rules

1. Read the existing code before writing.
2. DI for the DB session via `Depends(get_session)`.
3. Correct status codes: 201 create, 204 delete, 404 not found, 409 conflict.
4. Pagination on every `list` endpoint (with `total`).
5. `PATCH` = partial update, `PUT` = full replacement.
6. Alembic: `autogenerate` then **mandatory manual review** (full rules in `standards/migrations.md`).
7. Docstrings on endpoints (Swagger).
8. Index frequently filtered columns; define constraints (unique/check/FK) at the model level.
9. Tests per layer: router (integration), service + repository (unit).
10. No hardcoded secrets — config via pydantic-settings.
