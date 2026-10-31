# Standard — Observability (logs, metrics, traces)

> **Opt-in — not applied by default.** A scaffolded backend does **not** get observability
> automatically. A project opts in by running **`/setup-observability`**, which applies this
> reference. Default scope is **structured logs only**; metrics and distributed tracing are
> extra tiers the team enables on demand.

What the **application** must emit *once observability is enabled* so it can be operated. The
app stays **vendor-neutral**; **collection, forwarding, dashboards and alerting are owned by
the infra team** (Grafana/Loki, Splunk or AWS-managed). The app writes to stdout (and, if the
tiers are enabled, exposes `/metrics` and/or exports OTLP); infra does the rest.

## Tiers

- **Logs** (the core, default): structured JSON to stdout + request-id correlation +
  `/health` `/ready`. No external SDK required.
- **Metrics** (opt-in): RED signals via `prometheus-client` on `/metrics`. No OpenTelemetry.
- **Distributed tracing** (opt-in, multi-service only): OpenTelemetry + OTLP. Only worth it
  when a request crosses several services.

## Logs

- **Structured JSON to stdout** (12-factor), one event per line — never log to files. The
  infra collector picks up stdout. Python: `structlog` (preferred) or the stdlib logger with
  a JSON formatter. **No `print()`**, no f-string-only logging.
- Standard fields on every line: `timestamp`, `level`, `message`, `service`, `env`,
  `request_id`, and `trace_id`/`span_id` **only when the tracing tier is enabled**. Add
  domain context as explicit key/values, not interpolated prose.
- **Levels with intent**: `DEBUG` dev only, `INFO` business events, `WARNING` recoverable,
  `ERROR` failed operation (with stack), `CRITICAL` outage. Default prod level `INFO`.
- **No secrets, no PII** in logs (RGPD / `standards/security.md`): redact tokens, passwords,
  emails, personal data. Log identifiers (user id), not personal content.

## Correlation

- A middleware reads or generates a **request id** (`X-Request-Id`), puts it in the log
  context for the whole request, and echoes it in the response header.
- For a request crossing services, propagate the request id (`X-Request-Id`/`correlation_id`)
  so the logs share one identifier. If the tracing tier is on, use **W3C trace context**
  (`traceparent`) instead — this is what lets infra stitch *log → trace → metric*.

## Metrics — opt-in (`prometheus-client`, vendor-neutral)

- The **RED** signals (Rate, Errors, Duration) per endpoint, plus a few key business
  counters. Expose on `/metrics`; infra scrapes it (Prometheus/Grafana) or bridges it. Don't
  run your own backend, don't pull in a vendor SDK.

## Traces — opt-in (OpenTelemetry, multi-service only)

- Only for genuine **distributed** tracing across services. Instrument with **OpenTelemetry**;
  export via **OTLP** to the endpoint provided by infra (`OTEL_EXPORTER_OTLP_ENDPOINT`,
  `OTEL_SERVICE_NAME` via env — never hardcoded). OTel feeds Grafana/Tempo, Splunk
  Observability **or** AWS X-Ray without app changes.
- FastAPI: use the OTel FastAPI/SQLAlchemy auto-instrumentation for HTTP + DB spans. Add
  manual spans around meaningful business operations. Keep the same `trace_id` in the logs.

## Health & readiness

- `GET /health` (liveness, cheap) and `GET /ready` (readiness: DB/broker reachable) for the
  orchestrator. Keep them unauthenticated, fast, and free of sensitive detail.

## Frontend

- Catch render errors with an **error boundary**; report client errors / RUM via the
  project's tool (Sentry, or OTel web if the tracing tier is on) when configured. **Never**
  log tokens or PII; redact before sending. Propagate the request id / `traceparent` on API
  calls so front↔back correlate.

## Boundary

The app only **emits** (structured logs to stdout; `/metrics` and/or OTLP when enabled).
**Forwarding, aggregation, dashboards, alerting and on-call belong to infra** — keep the app
decoupled from any specific backend (Grafana/Loki/Tempo/Prometheus, Splunk, CloudWatch/
X-Ray). See the team's observability architecture docs for the platform side.
