---
name: docker-stack
description: >
  Brings the local dev stack up/down and inspects logs/health via docker-compose
  (FastAPI + Postgres + Traefik + Adminer, plus Redis and object storage — LocalStack for AWS
  or Azurite for Azure — when present). Use to run,
  restart, or debug the local environment.
---

# Manage the Docker stack

Apply `standards/project-layout.md`. **Locate** the compose file first (`docker-compose.yml`
at the repo root, or the monorepo root) — do not assume a path. Detect the declared
services and ports before acting; never echo real secrets from `.env`.

Common actions (use the project's compose command, `docker compose` or `docker-compose`):

- **Up**: `docker compose up -d`, then wait for health and report the exposed URLs/ports
  (API, Adminer, Traefik dashboard, …).
- **Down**: `docker compose down` (add `-v` only when the user explicitly wants to wipe
  volumes/data — confirm first).
- **Status**: `docker compose ps` — show which services are up/healthy.
- **Logs**: `docker compose logs -f --tail=100 <service>` for a targeted service.
- **Restart/rebuild**: `docker compose restart <service>` or `up -d --build` after a
  Dockerfile/dependency change.

Workflow:
1. Read the compose file: services, ports, depends_on, healthchecks, env sources.
2. Run the requested action.
3. Verify health (`ps` + a quick curl on the API/health endpoint if defined).
4. Report: services running, exposed URLs/ports, and any failing container with its last
   log lines.
