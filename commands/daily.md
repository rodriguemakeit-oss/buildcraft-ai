---
description: Daily standup — reconcile git activity with the tracker, report, and update statuses
argument-hint: "[since when, e.g. 'yesterday' | '3 days ago']  (default: yesterday)"
---

Run the daily standup. Window = `$ARGUMENTS` if given, otherwise **since yesterday**.

Delegate to the `tracker-sync` agent. It must:

1. Gather git activity over the window (`git log --since`, branch, WIP, open PRs via `gh`)
   and extract referenced ticket keys.
2. Read the corresponding ticket state from the configured source (`standards/tracker.md`).
3. Reconcile git ↔ tickets (merged-but-not-Done, commits on a To-Do ticket, stale
   in-progress, untracked work).
4. Produce a concise standup: **Done since last / In progress / Next / Blockers &
   mismatches**, each line linking its ticket URL.
5. **Propose** the implied status transitions and apply them after confirmation.

> When invoked by a scheduled routine (non-interactive), the agent should apply only the
> unambiguous transitions automatically (e.g. merged PR → Done) and list the rest as
> blockers for human review — never bulk-change silently.

> **What's the spec source?** `/daily` reconciles git against the project's specs. **Local
> Markdown specs under `specs/` are the default** — no MCP needed; it reads/updates the
> `status:` field in the US files. If the project records work in **JIRA**, the Atlassian MCP
> is used instead. With **neither** specs nor a tracker, `/daily` degrades to a plain
> commit/PR summary (which `git log`/`gh` already give) — tell the user to plan with
> `/plan-feature` to make `/daily` worthwhile.
