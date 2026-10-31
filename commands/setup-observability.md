---
description: Opt-in — add structured logging (+request-id, health/ready) to the current project; metrics and distributed tracing only if asked
---

Set up **observability** in the current project, following `standards/observability.md`.
This is **opt-in**: nothing here is applied by default when a backend is scaffolded — a
project only gets it when this command is run. Be idempotent: if a piece already exists,
**merge / skip** it and show a diff before writing.

By default this sets up **structured logs only** (the minimum that Grafana/Loki or Splunk
can consume). Metrics and distributed tracing are **extra tiers** the user opts into — ask
before adding them; don't pull in dependencies nobody requested.

## 1. Detect the layout & stack

Apply `standards/project-layout.md`: monorepo (`back/` + `front/`) vs standalone back/front.
Detect Python (`pyproject.toml`/`requirements.txt`) and frontend (`package.json`). Only
touch the parts that exist.

## 2. Ask scope (before writing anything)

Confirm which tiers to install — default to **logs only**:
- **Logs** (always): structured JSON + request-id correlation + `/health` `/ready`.
- **Metrics** (opt-in): RED signals via `prometheus-client`, exposed on `/metrics`. No OTel.
- **Distributed tracing** (opt-in, multi-service only): OpenTelemetry + OTLP export. Skip
  unless the project actually spans several services and the user wants it.

## 3. Logs — structured JSON to stdout (the core)

- Add **`structlog`** (preferred) or a stdlib JSON formatter to dev/runtime deps. Configure
  one event per line to **stdout** — never log to files, no `print()`.
- Standard fields on every line: `timestamp`, `level`, `message`, `service`, `env`,
  `request_id` (and `trace_id`/`span_id` only if the tracing tier is enabled).
- A **request-id middleware**: read or generate `X-Request-Id`, bind it in the log context
  for the whole request, echo it back in the response header. For multi-service calls,
  propagate it as `X-Request-Id`/`correlation_id` (or `traceparent` if tracing is enabled).
- Redact secrets/PII (`standards/security.md`): tokens, passwords, emails, personal data.
- Add **`GET /health`** (liveness, cheap) and **`GET /ready`** (readiness: DB/broker
  reachable) — unauthenticated, fast, no sensitive detail.

## 4. Metrics — only if opted in

- Add **`prometheus-client`**; expose `/metrics`. Instrument the **RED** signals (Rate,
  Errors, Duration) per endpoint plus a few key business counters. No OTel, no vendor SDK —
  the infra scrapes `/metrics` (Prometheus/Grafana) or bridges it.

## 5. Distributed tracing — only if opted in

- Add **OpenTelemetry** + FastAPI/SQLAlchemy auto-instrumentation for HTTP + DB spans; add
  manual spans around meaningful business operations. Export via **OTLP** to
  `OTEL_EXPORTER_OTLP_ENDPOINT` (with `OTEL_SERVICE_NAME`), both via env — never hardcoded.
  The same `trace_id` must appear in the logs so infra can stitch *log → trace*.

## 6. Frontend — only if a front exists

- Add an **error boundary** to catch render errors. Report client errors / RUM via the
  project's tool (Sentry, or OTel web if the tracing tier is on) **when configured**. Never
  log tokens/PII — redact first. Propagate the request id / `traceparent` on API calls.

## 7. Boundary (state it to the user)

The app only **emits** (structured logs to stdout, `/metrics`, optional OTLP). **Forwarding,
aggregation, dashboards, alerting and on-call belong to infra** — keep the app decoupled
from any specific backend (Grafana/Loki/Tempo/Prometheus, Splunk, CloudWatch/X-Ray).

## 8. Report

Detected stack, the tiers installed (logs / metrics / tracing), deps added, files
created/merged, and the env vars the infra must provide. If only logs were installed, say so
explicitly and note that `/setup-observability` can be re-run to add metrics or tracing.
