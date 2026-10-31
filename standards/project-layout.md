# Standard — Project layouts (monorepo & separate repos)

The platform must work with two organizations. **First rule for any agent: detect the
layout before acting** (look for `back/`+`front/` at the root, or a single back repo, or
a single front repo).

## A. Monorepo (e.g. `asset_api`)

```
project/
  back/        app/ · alembic/ · tests/ · pyproject/requirements
  front/       src/ · package.json · vite.config.ts · tailwind/postcss
  docker-compose.yml      # orchestrates back + front + postgres + (redis/localstack|azurite…)
  .pre-commit-config.yaml # shared by both
  .env / .env.example     # at the root
  CLAUDE.md               # at the root, describes both sub-projects
```
- Root `docker-compose` brings up the whole stack.
- Commands scoped per folder: `pytest` in `back/`, `npm test` in `front/`.
- A single root `CLAUDE.md` pointing both back **and** front to the `standards/`.

## B. Separate repos (e.g. `oilabs-backend` + `oilabs-frontend`)

```
oilabs-backend/   app/ · alembic/ · tests/ · docker-compose.yml · CLAUDE.md
oilabs-frontend/  src/ · package.json · vite/tailwind · CLAUDE.md
```
- Each repo has its own `CLAUDE.md` and `.mcp.json`.
- The API contract is shared via the backend OpenAPI (type generation on the front).

## Local dev stack — Traefik routing (`.localhost` domains)

The local stack is reverse-proxied by **Traefik**; services are reached through readable
`*.localhost` domains, **never** through published `host:port` mappings. `*.localhost` resolves
to `127.0.0.1` in browsers with no `/etc/hosts` edit.

- **Route every HTTP service with Traefik labels**, not `ports:`. Only Traefik itself publishes
  `80` (and `8080` for its dashboard). Don't `ports:`-expose the API, the front, or Adminer.
- **Domain convention**: `<service>.<project>.localhost` — e.g. `api.myproject.localhost`,
  `myproject.localhost` (front), `adminer.myproject.localhost`, `traefik.myproject.localhost`.
- Each routed service carries the labels; the router name must be unique per service:

  ```yaml
  api:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.myproject.localhost`)"
      - "traefik.http.services.api.loadbalancer.server.port=8000"  # container port, not host
  front:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.front.rule=Host(`myproject.localhost`)"
      - "traefik.http.services.front.loadbalancer.server.port=5173"
  ```

Bring it up / inspect it with the `docker-stack` skill.

## Implications for agents

- `backend-fastapi` operates in `back/` (monorepo) or at the root (separate back repo).
- `frontend-react` operates in `front/` or at the root of the front repo.
- Always **locate** `pyproject.toml`/`requirements.txt` (back) and `package.json` (front)
  rather than assuming a path.
- The `docker-stack` skill looks for `docker-compose.yml` (root in a monorepo).

## Backend naming variants (align, do not impose)

Projects diverge slightly; the agent **aligns with what exists**:
- **Code organization**: feature/vertical (`{feature}/router.py…`, the default) **or**
  layer/horizontal (`routers/{feature}.py`, `services/…`). Chosen once at `/new-project`,
  recorded in `CLAUDE.md` (full spec in `standards/backend-fastapi.md`). Detect it from the
  existing tree and follow it; never mix the two.
- `repository/` **or** `crud/` (same role: data access).
- `exceptions.py` **or** `error/` (domain exceptions).
- `core/` **or** `config/` (settings/DB/dependencies).
- Possible extras: `tasks/` (Celery, see `standards/async-tasks.md`), Redis, object-storage
  emulator (LocalStack for AWS **or** Azurite for Azure), `engine/` (compute).

The layering rule (Router → Service → Data → Model) stays the same regardless of naming
**or** layout.
