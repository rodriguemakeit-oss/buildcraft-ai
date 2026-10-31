---
description: Create the next Architecture Decision Record from a decision (Nygard format)
argument-hint: <the decision / title>
---

Record the architectural decision described in `$ARGUMENTS` (ask for it if empty), following
`standards/adr.md`.

1. **Locate** `docs/adr/` (create it + `0000-template.md` from the standard if missing).
2. **Number** the ADR: next zero-padded sequential after the highest existing
   `docs/adr/NNNN-*.md` (start at `0001`).
3. **Draft** `docs/adr/NNNN-kebab-title.md` from the template:
   - **Context**: the problem, forces, constraints (pull real detail from the codebase and
     the conversation — don't write filler).
   - **Decision**: what we'll do, active voice.
   - **Consequences**: what gets easier/harder, trade-offs accepted, follow-ups.
   - **Alternatives considered**: each option and **why not** — the part future readers need.
   - Fill Status (`Proposed` unless told it's accepted), Date (today), Deciders, Refs
     (ticket key/PR if known).
4. **Supersede** if this replaces an earlier ADR: mark the old one
   `Superseded by ADR-NNNN` and cross-link both.
5. **Report** the file created and a one-paragraph summary. ADRs are committed
   (shared) — commit only if the user asks, with a `docs:` Conventional Commit
   (`standards/commits.md`).
