---
description: Pre-ship gate — tests, security review, then open/update the PR and sync the ticket
argument-hint: "[ticket key, e.g. PROJ-123]  (optional; auto-detected from the branch)"
---

Prepare the current change to ship. Be a **gate**: stop on any blocker, do not force
through. Ticket key = `$ARGUMENTS` if given, else inferred from the branch/commits.

1. **Status.** Show `git status` + `git diff` vs the base branch and the files touched.
   Detect the layout/stack so the right tooling is used.
2. **Tests & quality.** Run the project's tests (`pytest`, front tests) and linters
   (`ruff`, `eslint`/`prettier`) for the touched areas. Report failures; do not proceed
   until green.
3. **Security review.** Run the `security-review` skill (or the `security-reviewer` agent)
   on the diff. A **BLOCK** verdict stops the ship; surface required fixes.
4. **Commit & PR.** Only commit/push when the user asked (branch first if on the default
   branch). The commit message and PR title **follow `standards/commits.md`** (Conventional
   Commits) so the infra release pipeline derives the right bump + changelog. Open or update
   the PR with `gh`: a clear title and a body following the Definition of Done checklist
   (`standards/pull-request.md`) — change summary, tests run, security verdict, docs/ADR;
   reference the ticket key.
   End the PR body with:
   `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
5. **Docs freshness.** If the diff changes user/API-facing behavior, have the `doc-writer`
   agent update the affected docs (README usage, API docs, public docstrings) before the PR.
6. **Sync the ticket.** Via `tracker-sync` / `standards/tracker.md`: move the ticket to the
   project's "In Review" (or "Done" once merged) status and link the PR. Propose, confirm,
   apply.
7. **Report.** Test/lint/security results, docs updated, the PR URL, and the ticket
   transition. If the diff encodes a non-obvious architectural decision, suggest recording
   it with `/adr` (`standards/adr.md`).
