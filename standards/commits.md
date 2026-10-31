# Standard — Commit messages (Conventional Commits)

Commit messages follow **[Conventional Commits](https://www.conventionalcommits.org/)**.
This is not cosmetic: the **infra release pipeline derives the version bump and the
CHANGELOG from these messages** on merge to the prod branch. Garbage in (`fix bug`, `wip`)
→ wrong semver bump and an unreadable changelog. The socle's job is to keep the **inputs**
clean; the pipeline owns the tag + changelog output.

## Format

```
type(scope)!: short imperative subject

optional body explaining the what/why (wrap ~72 cols)

optional footers (BREAKING CHANGE:, Refs: PROJ-123, Co-Authored-By: …)
```

- **type** — one of the allowed types below.
- **scope** — optional, the area touched (`auth`, `users`, `back`, `front`…).
- **!** — optional, marks a breaking change (or use the `BREAKING CHANGE:` footer).
- **subject** — imperative mood, lower-case start, **no trailing period**, ≤ 72 chars.

## Allowed types → release impact

| Type | Use for | Semver |
|------|---------|--------|
| `feat` | a new feature | **minor** |
| `fix` | a bug fix | **patch** |
| `perf` | a performance improvement | patch |
| `refactor` | code change, no behavior change | none |
| `docs` | documentation only | none |
| `test` | tests only | none |
| `build` | build system / dependencies | none |
| `ci` | CI config (owned by infra) | none |
| `chore` | tooling / housekeeping | none |
| `revert` | revert a previous commit | varies |

A **breaking change** (`feat!:` / `fix!:` or a `BREAKING CHANGE:` footer) → **major** bump.

> Align the allowed `type`s / `scope`s to **exactly** what the project's release pipeline
> consumes (some pipelines key off PR titles instead of commits — match that). When in
> doubt, check a recently generated CHANGELOG and mirror its categories.

## Rules

- One logical change per commit; the subject states intent, not the file list.
- Reference the tracker issue in a footer (`Refs: PROJ-123`) so commit ↔ ticket ↔ PR link up
  (`standards/tracker.md`).
- AI-assisted commits keep the `Co-Authored-By:` trailer.
- **Enforced by a `commit-msg` hook** via pre-commit (`conventional-pre-commit`, see
  `standards/pre-commit.md`) so a malformed message is rejected before it reaches the
  pipeline.

## Examples

```
feat(auth): add Okta token refresh on 401
fix(users): cap pagination at 100 to prevent unbounded queries
refactor(back)!: drop the legacy /v1 users endpoint

BREAKING CHANGE: clients must move to /v2/users.
Refs: PROJ-412
```
