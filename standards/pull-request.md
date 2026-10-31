# Standard — Pull requests & Definition of Done

A PR is "done" when it meets the checklist below. `/ship` enforces most of it automatically;
the **PR template** is the human-facing version for manual PRs. The template is a **committed
project artifact** (`.github/pull_request_template.md`), scaffolded by `/onboard-project` and
`/new-project`.

## Definition of Done

- **Tests**: new/changed behavior is covered; the suite passes (`testing.md`).
- **Security**: reviewed — no secrets, authz enforced, inputs validated (`security.md`,
  `auth-okta.md`); a BLOCK verdict is resolved.
- **Docs**: user/API-facing changes are reflected (README/API docs) (`doc-writer`).
- **ADR**: a structural decision is recorded (`adr.md` / `/adr`).
- **Contract**: if the HTTP contract changed, the OpenAPI snapshot and the front types are
  regenerated (`api-contract.md`).
- **Hygiene**: pre-commit / lint green; commit + PR title follow Conventional Commits
  (`commits.md`); the ticket is referenced.
- **Readability**: naming follows the language convention (snake_case back, camelCase/
  PascalCase front), functions stay **≤ 100 lines** (exceptions justified), and call chains
  keep **depth ≤ 2** — compose at the caller instead of nesting helpers
  (`backend-fastapi.md` / `frontend-react.md`).

## PR template (scaffold into `.github/pull_request_template.md`)

```markdown
## What & why
<!-- Short summary of the change and the motivation. Link the ticket: Refs: PROJ-123 -->

## Changes
-

## Checklist
- [ ] Tests added/updated and passing
- [ ] Security reviewed (secrets, Okta authz, input validation)
- [ ] Docs updated (README / API) if user-facing
- [ ] ADR added if a structural decision was made
- [ ] API contract regenerated if the HTTP contract changed
- [ ] Conventional Commit title; ticket referenced
- [ ] pre-commit / lint green
- [ ] Readability: convention-correct naming, functions ≤ 100 lines, call depth ≤ 2

## Screenshots / notes
<!-- UI changes, migration notes, anything a reviewer should know -->
```

Keep the checklist aligned with the Definition of Done above; adjust per project only where a
standard genuinely doesn't apply (e.g. a backend-only repo dropping the screenshots line).
