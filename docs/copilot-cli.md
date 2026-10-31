# Using the socle from GitHub Copilot CLI

This foundation is **Claude-native** (ADR-0001) but it is meant to serve a **mixed team**: some
devs use **Claude Code**, others **GitHub Copilot CLI**. The contract is:

> **One source of truth, two targets.** The rules live only in [`standards/`](../standards). A
> single evolution to a standard reaches both tools — nobody maintains two copies.

This is enforced by ADR-0007. This document explains how it works and how a Copilot CLI dev sets
it up.

> **⚠️ Use the Copilot CLI, not the VSCode extension.** The whole wiring hangs on
> `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, which **only the CLI reads**. The VSCode Copilot extension
> ignores it, doesn't see the socle's `*.instructions.md`, and can't open the `standards/*.md`
> they point to — so it generates with **zero** standards loaded (wrong architecture, plain CSS
> instead of Tailwind/Fluid, decorative comments…). If you use Copilot, use `copilot` in the
> terminal after the one-time setup below. The VSCode extension is **not supported** by this socle.

## How the socle maps to each tool

| Brick | Claude Code | Copilot CLI |
|---|---|---|
| Rules (truth) | `standards/*.md` | **same** `standards/*.md` |
| Instructions | `agents/*.md` + `CLAUDE.md` | `AGENTS.md` + `.github/instructions/*.instructions.md` |
| Procedures | `skills/*/SKILL.md` | **same** `SKILL.md` (Copilot reads `~/.agents/skills`) |
| Enforcement | hooks + pre-commit | **pre-commit** (Copilot has no hook engine) |
| Workflows | `/ship`, `/daily`, `/adr`… | a prompt per command — see [`copilot-cli-commands.md`](./copilot-cli-commands.md) |

The Copilot-facing files (`AGENTS.md`, the `*.instructions.md`) contain **no rules** — they point
to `standards/`. That is what keeps the two targets in sync: editing a standard is enough.

> Claude Code ignores `AGENTS.md` and `.github/instructions/` today (it reads `CLAUDE.md`), so
> these files are inert for Claude users — they cannot mislead them. And by design they can't
> contradict the standards, since they only reference them.

### Which agents are covered

Copilot gets the **file-editing** personas via `AGENTS.md` + path-scoped instructions, each
pointing to its standard:

| Claude agent | Copilot surface (`applyTo`) | Standard |
|---|---|---|
| `backend-fastapi` | `**/*.py` | `backend-fastapi.md` |
| `frontend-react` | `**/*.{ts,tsx,jsx}` | `frontend-react.md` |
| `doc-writer` | `**/*.md` | `documentation.md` |
| `qa-tester` | test globs | `testing.md` |
| `db-migration` | `**/alembic/**`, `**/migrations/**` | `migrations.md` |
| `security-reviewer` | — (shared `security-review` **skill**) | `security.md` |

The **workflow / PM agents** (`pm-planner`, `tracker-sync`, `legacy-analyst`) have **no**
path-scoped mapping — they are command-shaped, not file-editing. Run them by following the
matching standard by hand (e.g. `standards/tracker.md`).

## Distribution model — global, per developer (ADR-0007)

Claude Code distributes the socle as a **plugin** (installed once, available in every project).
Copilot CLI has **no plugin mechanism**, so the socle is wired **globally on each developer's
machine** and **not committed into project repos**. Project repositories stay clean; the socle
lives in one local clone that every project on that machine reads from.

Trade-offs accepted (see ADR-0007): each dev configures their machine once, and each dev refreshes
the socle with `git pull` (version is per-dev, not pinned per project).

## One-time setup (per developer)

1. **Clone the socle** somewhere stable (not inside a project):

   ```bash
   git clone https://github.com/rodriguemakeit-oss/buildcraft-ai.git ~/buildcraft-ai
   ```

2. **Run the setup helper** (idempotent — links skills, prints the env line to add):

   ```bash
   ~/buildcraft-ai/scripts/copilot-setup.sh
   ```

   It does the following, which you can also do by hand:

   - **Custom instructions** — point Copilot at the clone so it loads `AGENTS.md` +
     `.github/instructions/*` in every project. Add to your shell profile (`~/.zshrc`/`~/.bashrc`):

     ```bash
     export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/buildcraft-ai"
     ```

   - **Skills** — Copilot reads `~/.agents/skills`. Symlink the socle's skills:

     ```bash
     mkdir -p ~/.agents && ln -s ~/buildcraft-ai/skills ~/.agents/skills
     ```

   - **MCP servers** (optional) — declare shared servers in `~/.copilot/mcp-config.json`
     (Copilot ships with the GitHub MCP server already configured).

3. **Verify**:

   ```bash
   ~/buildcraft-ai/scripts/copilot-doctor.sh
   ```

## Daily use (concrete trace)

In any project, run `copilot`. On start it loads `AGENTS.md` + the path-scoped instructions from
the clone. When you ask for, say, a new endpoint:

1. `AGENTS.md` (already in context) says: apply `standards/backend-fastapi.md`.
2. The backend `*.instructions.md` fires because you touched a `**/*.py` file.
3. Copilot **opens** `standards/backend-fastapi.md` in the clone (it has the path) and reads the
   rules — Router→Service→Repository, snake_case, ≤100 lines, depth ≤2…
4. It writes the code **in your project**, respecting those rules.

The generated code lands in your project; the rules were read from the socle clone — both are on
your machine, so Copilot reads one to write the other. This mirrors how a Claude agent reads
`standards/*.md` from the installed plugin.

## Updating / evolution

A rule change is a **single edit** in `standards/` upstream. Each user refreshes:

```bash
# Copilot users
cd ~/buildcraft-ai && git pull

# Claude Code users
claude plugin marketplace update renewable-flex-internal && claude plugin update buildcraft-ai@renewable-flex-internal
```

You do **not** touch `AGENTS.md` or the `*.instructions.md` for a rule change — they only point.
You touch them only when **adding** a new standard or skill (then wire both indexes, see
`CONTRIBUTING.md`).

## Enforcement (no hooks in Copilot)

Copilot CLI has no equivalent of the Claude quality hooks. The shared gate for **both** tools is
**pre-commit** (`standards/pre-commit.md`): ruff (`N`, `PLR0915`), ESLint
(`naming-convention`, `max-lines-per-function`), detect-secrets, conventional-commits. Install it
per project (`/setup-precommit` for Claude users, or `pre-commit install` by hand).

## Limits of this model

- A dev who skips the setup gets **no** standards from Copilot, silently. Re-run `copilot-doctor`.
- Version is per-dev: two devs can lag behind each other until both `git pull`.
- The socle is not visible inside project repos / CI. If you need it pinned and visible per
  project, that is a different model (committed-per-project) deliberately **not** chosen here —
  see ADR-0007 for why.
