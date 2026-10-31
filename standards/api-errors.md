# Standard — API error handling

The error contract is part of the **API contract** (`api-contract.md`): the frontend's
generated types and error handling depend on a **stable, consistent error shape**. Define it
once, map every exception to it centrally, and never leak internals.

## Canonical error envelope

Pick **one** shape per project and use it everywhere (recommended: RFC 9457
`application/problem+json`, or a simple consistent JSON):

```json
{
  "code": "measurement_point_not_found",   // machine-readable, stable
  "message": "Measurement point 42 was not found",  // human-readable, safe to show
  "errors": [                               // field-level, for validation (422)
    { "field": "rows[3].value", "message": "must be a positive number" }
  ],
  "request_id": "01J..."                    // echoes the correlation id (observability.md)
}
```

- `code` is the **stable** part clients branch on (don't break it casually — it's contract).
- `request_id`/`trace_id` lets support tie a user-visible error to the logs.

## Map exceptions → status centrally

Register FastAPI **exception handlers** in one place; routers/services just raise **domain
exceptions** (`backend-fastapi.md`), they don't build HTTP responses:

| Situation | Status |
|---|---|
| Validation (Pydantic / bad input) | **422** |
| Unauthenticated (no/invalid token) | **401** |
| Forbidden (insufficient rights) | **403** |
| Resource not found | **404** |
| Conflict (duplicate, state) | **409** |
| Unexpected / unhandled | **500** (generic message + `request_id`) |

## Rules

- **Never leak internals in prod**: no stack traces, SQL, or framework messages in the
  response (`security.md`). Log the detail server-side (with `trace_id`); return a generic
  message + the `request_id`.
- **Validation errors** are returned in the same envelope (the `errors[]` array), one entry
  per invalid field — predictable for the front to render inline.
- The error envelope is **versioned with the API**: changing `code`s or the shape is a
  **contract change** — regenerate the front types (`sync-api-types`) and review.
- Document the error responses in OpenAPI (status codes per endpoint) so they show in
  `/docs` and in the generated types.
