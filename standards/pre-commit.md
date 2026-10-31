# Standard — pre-commit

The commit-time safety net. It runs the **same tools** as the Claude quality hooks
(`hooks/format-lint.sh`, `hooks/block-secrets.sh`) and as CI, so style/secret problems are
caught before they reach review. Applied by the `/setup-precommit` command.

## Committed, not local

Unlike the onboarding files (`CLAUDE.md`, `.mcp.json`, `.claude/` — kept local per
developer), `.pre-commit-config.yaml` and `.secrets.baseline` are a **shared project
artifact**: commit them so the whole team runs the same checks. Add `pre-commit` to the
project's dev dependencies and document `pre-commit install` in the README/contributing.

## Baseline hooks (every project)

- **Hygiene** (`pre-commit/pre-commit-hooks`): `trailing-whitespace`, `end-of-file-fixer`,
  `check-yaml`, `check-json`, `check-toml`, `check-added-large-files`,
  `check-merge-conflict`, `detect-private-key`.
- **Secrets** (`Yelp/detect-secrets`): scan against a committed `.secrets.baseline`
  (`detect-secrets scan > .secrets.baseline`). Reinforces the Claude `block-secrets` hook.

## Commit messages (`commit-msg` stage)

Validate Conventional Commits (`standards/commits.md`) at commit time so the infra release
pipeline always gets clean input. This runs on the **commit-msg** git stage, not pre-commit:

```yaml
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.6.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
        args: []   # optionally restrict to the pipeline's allowed types
```

Install both stages: `pre-commit install --hook-type pre-commit --hook-type commit-msg`.

## Python (backend)

- **ruff** (`astral-sh/ruff-pre-commit`): `ruff` (lint `--fix`) + `ruff-format`. Same tool
  as `format-lint.sh`, so no divergence.
- **bandit** (`PyCQA/bandit`): security lint (required by `standards/security.md`).

## Frontend

Run the project's own ESLint/Prettier (respect its config and pinned versions) via **local**
hooks, mirroring `format-lint.sh`:

```yaml
- repo: local
  hooks:
    - id: prettier
      name: prettier
      entry: npx --no-install prettier --write
      language: system
      files: \.(ts|tsx|js|jsx|css|scss|json|md|ya?ml|html)$
    - id: eslint
      name: eslint
      entry: npx --no-install eslint --fix
      language: system
      files: \.(ts|tsx|js|jsx)$
```

## Example `.pre-commit-config.yaml` (Python + frontend)

Pin `rev`s to current releases and refresh periodically (`pre-commit autoupdate`).

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-toml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/PyCQA/bandit
    rev: 1.8.2
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]   # or -ll to flag only medium+ severity
        additional_dependencies: ["bandit[toml]"]
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ["--baseline", ".secrets.baseline"]
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.6.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
  - repo: local
    hooks:
      - id: prettier
        name: prettier
        entry: npx --no-install prettier --write
        language: system
        files: \.(ts|tsx|js|jsx|css|scss|json|md|ya?ml|html)$
      - id: eslint
        name: eslint
        entry: npx --no-install eslint --fix
        language: system
        files: \.(ts|tsx|js|jsx)$
```

## Naming & function size (lint-enforced)

The readability rules from `standards/backend-fastapi.md` / `standards/frontend-react.md`
(snake_case back, native casing front, **functions ≤ 100 lines**) are enforced by the linters
above — configure them so the gate catches violations, not just review:

- **Python (ruff)** — enable `N` (pep8-naming → snake_case) and `PLR0915` (too-many-statements,
  the function-size proxy). In `pyproject.toml`:
  ```toml
  [tool.ruff.lint]
  extend-select = ["N", "PLR0915"]
  [tool.ruff.lint.pylint]
  max-statements = 50   # ~100 lines; raise locally with a justified noqa for exceptions
  ```
- **Frontend (ESLint)** — `@typescript-eslint/naming-convention` (camelCase/PascalCase) and
  `max-lines-per-function`:
  ```jsonc
  "rules": {
    "max-lines-per-function": ["warn", { "max": 100, "skipBlankLines": true, "skipComments": true }]
  }
  ```

**Call depth (max 2)** has no reliable linter — it stays a **review-time check** (PR + the
`security-reviewer`/`/code-review` pass): flag chains where helpers only forward to the next
instead of composing at the caller.

## Layout adaptation

- **Standalone backend / frontend**: include only the relevant hook groups.
- **Monorepo** (`back/` + `front/`): keep one root config. Scope Python hooks to the backend
  with `files: ^back/` (point `bandit -c back/pyproject.toml`); the frontend local hooks are
  already scoped by file extension. `npx` resolves the front package from `front/`.

## Install & run

```bash
pre-commit install --hook-type pre-commit --hook-type commit-msg   # both stages (per clone)
detect-secrets scan > .secrets.baseline
pre-commit run --all-files         # baseline pass; fix or audit findings
```

## Alignment

- **Claude hooks** fix style on edit (fast loop); **pre-commit** is the gate at commit;
  **CI** re-runs the same checks. Same tools end-to-end → no surprises, fewer round-trips.
- pre-commit replaces ad-hoc husky/lint-staged setups for these checks.
