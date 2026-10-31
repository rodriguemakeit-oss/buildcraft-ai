# ADR-0007 — Dual target: Claude Code and GitHub Copilot CLI from one source

- **Status**: Accepted
- **Date**: 2026-06-29
- **Deciders**: Massinissa
- **Refs**: ADR-0001 (Claude-native primitives), ADR-0002 (English-only canonical content),
  `docs/copilot-cli.md`, `AGENTS.md`, `.github/instructions/`

## Context

The socle is Claude-native (ADR-0001), distributed as a Claude Code plugin. But the team is
**mixed**: some developers use Claude Code, others **GitHub Copilot CLI**. We want both to apply
the same conventions, and — critically — we want **a single evolution of a standard to reach both
tools** without maintaining two copies (the drift ADR-0002 already warns against).

Two facts shape the options:
- Copilot CLI reads `AGENTS.md` + `.github/instructions/*.instructions.md`, and **Agent Skills**
  in `SKILL.md` format from `~/.agents/skills` / `.github/skills` — the **same format** our
  `skills/` already use. It has **no plugin/marketplace** mechanism and **no hook engine**.
- Claude Code reads `CLAUDE.md` + `agents/` and (today) **ignores** `AGENTS.md` and
  `.github/instructions/`, so Copilot-facing files are inert for Claude users.

## Decision

We will support both tools from **one source of truth**, with **thin adapters**:

1. **`standards/` stays the single source of truth.** It holds the rule text; nothing else does.
2. **Add Copilot-facing adapters that only point to standards** — never restate them:
   `AGENTS.md` (primary instructions) and `.github/instructions/{backend,frontend}.instructions.md`
   (path-scoped via `applyTo`). Editing a standard is enough; adapters don't change for a rule
   evolution.
3. **Reuse skills as-is.** Our `SKILL.md` files are already Copilot-compatible; Copilot reads them
   via `~/.agents/skills`. No second copy.
4. **Distribute to Copilot users globally, per developer**, not committed per project: a local
   clone of this repo wired through `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` + a `~/.agents/skills`
   symlink (`scripts/copilot-setup.sh`, `scripts/copilot-doctor.sh`). Project repos stay clean.
5. **Enforcement is pre-commit** for everyone (Copilot has no hooks); the Claude hooks remain a
   fast local loop for Claude users only.
6. **Documentation**: canonical `docs/copilot-cli.md` (English, ADR-0002) plus a French reading
   guide `docs/copilot-cli.fr.md`. This **extends** ADR-0002's single-FR-guide exception to
   "French **reading guides**" (`README.fr.md`, `docs/*.fr.md`) — still guides, still non-canonical.

## Consequences

- + One evolution → both targets: change a `standards/*.md`, every user `git pull`s (Copilot) or
  `plugin update`s (Claude). No per-project copies, no fan-out of PRs.
- + Skills are shared verbatim; Copilot files can't contradict the standards (they only point).
- − Each Copilot dev configures their machine once and must `git pull` to refresh (version is
  per-dev, not pinned per project); a skipped setup silently yields no standards — mitigated by
  `copilot-setup.sh` / `copilot-doctor.sh`.
- − The socle is not visible inside project repos or CI for Copilot users.
- − Two thin instruction surfaces (`agents/` for Claude, `AGENTS.md`+instructions for Copilot)
  must both be wired when a **new** standard/skill is added (rule text still lives once). Captured
  in `CONTRIBUTING.md`.

## Alternatives considered

- **Committed-per-project adapters** (drop `AGENTS.md` + standards into each repo) — rejected: it
  forces N copies of the rules (Copilot has no plugin to read a central `standards/`), so every
  evolution becomes N re-syncs + N PRs and per-project version drift — exactly what we avoid.
- **Translate / fork content per tool** — rejected: duplicates the source, guaranteed drift
  (same reasoning as ADR-0002).
- **Wait for Claude Code to read `AGENTS.md`** and converge on one file — rejected as a dependency:
  not implemented yet; our design already works today and would only get simpler if it lands.
- **Copilot-only or Claude-only** — rejected: the team is mixed; we standardize conventions, not
  tools.
