---
description: Scaffold/merge a stack-aware .pre-commit-config.yaml, install the hook, run a baseline pass
---

Set up **pre-commit** in the current project, following `standards/pre-commit.md`. Be
idempotent: if a config already exists, **merge** (don't clobber) and show a diff before
writing.

## 1. Detect the layout & stack

Apply `standards/project-layout.md`: monorepo (`back/` + `front/`) vs standalone back/front.
Detect Python (`pyproject.toml`/`requirements.txt`) and frontend (`package.json`). Include
only the relevant hook groups.

## 2. Build `.pre-commit-config.yaml`

From the baseline in `standards/pre-commit.md`:
- Always: `pre-commit-hooks` hygiene set + `detect-secrets` + `conventional-pre-commit`
  (`commit-msg` stage, validates `standards/commits.md`).
- If Python: `ruff` (+`--fix`) + `ruff-format` + `bandit`.
- If frontend: local `prettier` + `eslint` hooks (`npx --no-install`, respecting the
  project's own config/versions).
- **Monorepo**: one root config; scope Python hooks with `files: ^back/` and point
  `bandit -c back/pyproject.toml`.

If a `.pre-commit-config.yaml` already exists, reconcile: keep the project's extra hooks,
add the missing baseline ones, surface the diff, ask before overwriting. Pin `rev`s to
current releases (the user can `pre-commit autoupdate` later).

## 3. Secrets baseline

If `detect-secrets` is available, generate the committed baseline:
`detect-secrets scan > .secrets.baseline` (never echo any detected secret value).

## 4. Wire it in

- Add `pre-commit` to the project's **dev dependencies** (e.g. `[project.optional-dependencies]`
  / `requirements-dev.txt`, or `package.json` devDependencies for a front-only repo).
- Install both git stages: `pre-commit install --hook-type pre-commit --hook-type commit-msg`.
- Run a baseline pass: `pre-commit run --all-files`. Report failures; auto-fixes
  (formatting) can be re-staged. Do **not** force-fix security findings — surface them.

## 5. Commit policy (important)

Unlike the onboarding files, `.pre-commit-config.yaml` and `.secrets.baseline` are a
**shared project artifact → they are committed** to the repo (do not add them to
`.git/info/exclude`). Note this to the user; commit only if they ask.

## 6. Report

Detected stack, the hooks enabled, the files created/merged, the baseline-pass result, and
the one-line teammate instruction: `pre-commit install` after cloning.
