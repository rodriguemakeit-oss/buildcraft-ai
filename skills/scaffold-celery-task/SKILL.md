---
name: scaffold-celery-task
description: >
  Generates a Celery background task (thin task -> service layer) with a job-status record,
  enqueue endpoint, progress tracking and tests, compliant with standards/async-tasks.md.
  Use for slow/heavy work like large Excel/CSV ingestion with business rules.
---

# Scaffold a Celery task

Apply `standards/async-tasks.md`, `standards/backend-fastapi.md` and `standards/testing.md`.
Detect the layout first (monorepo `back/` vs standalone) and **align with the project's real
naming** (`tasks/`, `crud/`≈`repository/`, `core/`≈`config/`). If Celery/Redis aren't wired
yet, scaffold the app + config (broker URL via pydantic-settings) before the task.

0. **Confirm Celery is the right tool (mandatory gate).** Before scaffolding anything, **ask
   the user to validate** that this work really needs Celery + Redis. Describe the job, then
   offer the alternatives from `standards/async-tasks.md`: **in-request (sync)** for fast
   bounded work, **FastAPI `BackgroundTasks`** for light fire-and-forget, **Celery + Redis**
   only for genuinely slow/heavy/large/flaky work needing a job id, progress, retries or
   durability. A small file is **not** a reason on its own. **Do not proceed** to the steps
   below until the user has chosen Celery; if they pick a lighter option, implement that
   instead and stop.

1. Ask for the job (what it processes, input = a **reference**: file id / object-storage
   key / DB id — never raw bytes), the business rules, and the expected output.
2. **Enqueue endpoint** (`router.py`): validate the input (file type/size/columns), create
   the job record, **enqueue** the task, return **202** with the `job_id`. No processing in
   the request.
3. **Job status**: a `Job` model + repository (`queued → running(progress%) → done | failed`,
   result/error reference) and a `GET /jobs/{id}` endpoint to poll.
4. **Task** (`tasks/{job}.py`): a **thin** Celery task — load inputs from the reference,
   call the **service layer**, update job status/progress per chunk, persist the result.
   No business logic in the task body. Configure `acks_late=True`, `max_retries` + backoff,
   `soft_time_limit`. Make it **idempotent** (guard/upsert against re-delivery).
5. **Service**: the actual rules. For large files, **stream** (openpyxl read-only / pandas
   `chunksize`), validate **per row**, accumulate an **error report** (row + reason) instead
   of failing the whole job, batch DB writes per chunk. Keep files in object storage.
6. **Logging**: propagate the request `request_id` (and `trace_id` if the project enabled
   tracing) into the task log context; log start/end, counts, duration, failures —
   structured, no secrets/PII. Full observability (metrics/tracing) is opt-in via
   `/setup-observability` (`standards/observability.md`).
7. **Tests** mirroring the project's layout (`tests/{job}/…` vertical, `tests/{layer}/…`
   horizontal — see `standards/testing.md`): service unit tests (the rules — happy path **and** a file
   with invalid rows → error report), the task with `task_always_eager` (or a mocked
   broker), and one router integration test (enqueue → 202 → status transitions).
8. If a new model was added (the `Job` table), chain into the `alembic-migration` skill.
9. Run `pytest tests/{job}` (and lint if available), fix, and report files created, the
   enqueue/status endpoints, and how progress + errors are surfaced.
