# Standard — Async tasks & background processing (Celery + Redis)

For work that must not block the HTTP request: long-running or heavy jobs — **large file
ingestion (Excel/CSV) with many business rules**, bulk operations, external calls, report
generation. The reference setup (as on `asset_api`) is a **Celery worker** with **Redis** as
broker; tasks live in `tasks/` (`standards/project-layout.md`). Scaffold one with the
`scaffold-celery-task` skill.

## Decide first — ask the user (mandatory gate)

**Celery + Redis is opt-in, never automatic.** Before wiring any broker/worker, **stop and
ask the user to confirm** whether this work actually needs it. A small file (a few hundred
rows), a quick transform or a fast third-party call does **not** justify the operational cost
of Celery + Redis — do it **synchronously in the request**, or with FastAPI `BackgroundTasks`
for fire-and-forget side effects. Only introduce Celery + Redis once the user has validated it.

Rules of thumb to bring to the user:
- **In-request (sync)** — fast, bounded work that finishes well within the request budget.
- **`BackgroundTasks`** — light, best-effort after-response work (send an email, warm a cache)
  that needs no status, retries or durability.
- **Celery + Redis** — genuinely slow/heavy/large or flaky work that needs a job id, progress,
  retries, or must survive a restart.

Present the trade-off and let the user pick; don't default to Celery because the input is a
file.

## When to offload

Once the user has chosen Celery: offload when the work is slow, CPU/IO-heavy, processes a
large input, or calls a flaky third party. Otherwise keep it in the request. The API
**enqueues** and returns a **job id immediately** (HTTP 202); the client polls a status
endpoint. Never make the user wait on a 30-second request.

## Architecture (stays Clean)

- The Celery task is a **thin entrypoint**: it loads inputs, calls the **service layer**
  (where the business rules live — same services the routers use), and records the result.
  **No business logic in the task body** (Router/Task → Service → Repository → Model).
- **Don't put big payloads on the broker.** Pass **references** (a file id / object-storage
  key, a DB id), not the file bytes or large lists. Store input/output files in **object
  storage** — provider-agnostic behind a small storage interface: **AWS S3** (local:
  **LocalStack**) or **Azure Blob** (local: **Azurite**), never in Redis or the DB. The cloud
  target is a per-project choice (asked at `/new-project` / `/refonte`); don't hardcode one.
- Broker/result: **Redis** broker; a result backend (Redis/DB) only if you actually read
  results. Config (broker URL, queues) via pydantic-settings / env — never hardcoded.

## Large files (Excel/CSV)

- **Stream, don't slurp**: read row-by-row / in chunks (`openpyxl` read-only mode,
  `pandas` `chunksize`, CSV streaming). Never load a whole large workbook into memory.
- **Validate per row** against the Pydantic/service rules; **accumulate errors into a
  report** (row number + reason) instead of failing the whole job on the first bad row.
  Return a downloadable error report alongside the result.
- **Batch** DB writes (bulk insert / `executemany`), commit per chunk; cap memory.
- Guard inputs **before** processing: file type, size limit, expected columns/schema.

## Reliability

- **Idempotent tasks**: re-running must not double-apply (natural keys / upserts / an
  already-processed guard). Pair with `acks_late=True` so a crash re-delivers safely.
- **Retries** with exponential backoff and a `max_retries`; only retry transient errors.
  Send terminal failures to a dead-letter/failed state, not an infinite loop.
- **Time limits** (`soft_time_limit` + hard limit) so a stuck job can't pin a worker.
- **Granularity**: split very large jobs into a Celery `group`/`chord` of per-chunk subtasks
  with a final aggregation, rather than one giant task.

## Status & progress

- Persist a **job record** in the DB: `queued → running (progress %) → done | failed`, with
  a result/error reference. The API exposes `GET /jobs/{id}` for polling. Update progress
  per chunk so the UI can show it.

## Observability (`standards/observability.md`)

- **Propagate the correlation/trace context** from the request into the task so logs join up
  (`request_id`/`trace_id` in the task's log context). Log start/end, counts, duration,
  failures — structured, no secrets/PII (don't log file contents).
- Track the RED signals per task type (rate, errors, duration) and queue depth.

## Security & testing

- Validate and sanitize every input; no secrets in task args; scan/limit uploaded files.
- **Test the rules at the service layer** (unit, the heavy part); test task wiring with
  `task_always_eager` or a mocked broker; one integration test on a representative file
  (happy path + a file with invalid rows → error report). `standards/testing.md`.
