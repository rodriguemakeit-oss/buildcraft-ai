# Standard — Frontend React

## Principles

- **Function components + hooks** only. No classes.
- **Strict TypeScript** (`strict: true`), no unjustified `any`.
- **Separation**: `components/` (presentation) · `hooks/` (logic) · `api/` (network) ·
  `pages/` · `store`/`slices` (global state via Redux Toolkit or equivalent).
- **State**: local first; server state via TanStack Query (or Redux slices per project);
  global only when necessary.
- **Accessibility**: labels, ARIA roles, keyboard navigation (Fluid DS already helps a lot).

## UI — MANDATORY: Tailwind CSS + portfolio Fluid Design System

Every UI component **must** build on the portfolio Fluid Design System, complemented by
Tailwind for layout/spacing. **Never reinvent a button, input, modal, tab, tooltip…
that already exists in Fluid.**

Packages:
```
@portfolio-ui/fluid-design-system          # tokens / styles
@portfolio-ui/fluid-design-system-react    # React components (NJ* prefix)
tailwindcss + @tailwindcss/vite           # Tailwind v4
```

Fluid components are imported from `@portfolio-ui/fluid-design-system-react`, `NJ` prefix:
```tsx
import { NJButton, NJCheckbox, NJTabs, NJTab, NJTooltip } from '@portfolio-ui/fluid-design-system-react';

<NJButton variant="primary" onClick={onSave}>Save</NJButton>
```
Fluid CSS classes are prefixed `nj-` (e.g. `.nj-form-item`, `.nj-search`) — use them for
small adjustments, not to recreate components.

Setup (Tailwind v4 + Fluid), as wired in `asset_api`:
```css
/* assets/style/index.css */
@import 'tailwindcss';
```
```scss
/* assets/style/global.scss — load Fluid styles once */
@use '@portfolio-ui/fluid-design-system-react/css';
```
```ts
// vite.config.ts → @tailwindcss/vite plugin ; main.tsx imports index.css then global.scss
```

Arbitration rule: **Fluid first** (components, tokens, colors, typography) → **Tailwind**
for layout (flex/grid, spacing, responsive) → custom `nj-`/scss CSS only as a last resort,
justified.

## Conventions

- **Package manager: npm only.** Use `npm install` / `npm ci` / `npm run …`; commit **only**
  `package-lock.json`. Do **not** use pnpm or yarn, and never commit `pnpm-lock.yaml` or
  `yarn.lock`. Scripts and docs assume npm.
- **Naming follows the TS/React ecosystem** (camelCase by default), not Python snake_case:
  - `camelCase` — variables, functions, hooks (`useUsers`), object props, non-component files.
  - `PascalCase` — components, types/interfaces, enums, and their files (`UserRow.tsx`).
  - `UPPER_SNAKE_CASE` — module-level constants only.
  - API payload fields keep whatever casing the **generated** OpenAPI types expose (often
    snake_case from the backend) — never hand-rename them.
- One component per file (PascalCase); hooks named `useXxx`.
- Data fetching isolated in a hook (`useUsers`), never inline in JSX.
- Explicit states: loading / error / empty / data.
- No business logic in components: extract into a hook or a pure util.
- i18n via the project's library (e.g. `i18next`), no hardcoded text.

## Function size & call depth

- **≤ 100 lines per function/component body.** Past that, extract sub-components, custom
  hooks, or pure utils. Exceptions only when splitting hurts readability (justify with a
  comment). A component that grows huge is usually missing a hook or a child component.
- **Max call depth of 2 between your own functions.** Avoid chains where each helper only
  forwards to the next (`a()` → `b()` → `c()` → `d()`). Beyond two hops, **compose at the
  caller**: run the helpers in sequence and feed each result into the next.

  ```ts
  // ❌ deep chain — each function just delegates
  const handle = (input) => validate(input);
  const validate = (input) => transform(input);
  const transform = (input) => persist(input); // …

  // ✅ flat composition — the hook/util orchestrates, results flow forward
  const handle = (input) => {
    const data = validate(input);
    const payload = transform(data);
    return persist(payload);
  };
  ```

  The legitimate depth is the layering (component → hook → api), not helpers nested into
  each other inside a layer.

## Comments — explain *why*, never *what*

The code says *what* it does; a comment earns its place only when it says something the code
cannot. Write **fewer, higher-value** comments.

- **CAPITAL RULE — keep it minimal.** A comment or docstring is **as short as it can be**:
  one line whenever possible, only what's strictly necessary. No preamble, no restatement, no
  padding. If it doesn't earn its length, cut it.
- **No references.** Never point to an ADR, a user story, a ticket, an issue or a PR from a
  comment or JSDoc. Write a **generic, self-contained** sentence that explains the thing
  itself — the code must be understandable without chasing an external link.
- **No decorative banners or section separators.** No ASCII rules, box-drawing lines, or
  `// ─── Header ───────────` dividers — in TS/TSX, config, CSS, anywhere. Structure comes from
  components, hooks, modules and files, not from drawn dividers.
- **No comments that restate the code.** `// render the list` above a `.map`, or a comment
  paraphrasing the next JSX line, adds nothing — delete it.
- **Do** comment the non-obvious *why*: a workaround (and why it's needed), a subtle effect
  dependency, a business rule not visible in the types. If a comment would just narrate the
  next line, the better fix is usually a clearer name.
- Justify only genuine exceptions (e.g. a component kept over ~100 lines because splitting hurts
  readability) — that's the *why* kind of comment.

## Patterns

```tsx
// hooks/useUsers.ts — isolated, typed fetching
export function useUsers() {
  return useQuery({ queryKey: ["users"], queryFn: () => api.get<User[]>("/users") });
}
```

```tsx
// Component: Fluid for UI, Tailwind for layout, explicit states
function UsersList() {
  const { data, isLoading, error } = useUsers();
  if (isLoading) return <NJSpinner />;
  if (error) return <NJAlert variant="danger">{error.message}</NJAlert>;
  if (!data?.length) return <p className="text-center p-4">No users</p>;
  return (
    <ul className="flex flex-col gap-2">
      {data.map(u => <UserRow key={u.id} user={u} />)}
    </ul>
  );
}
```

## Rules

1. **Fluid Design System is mandatory** for all UI components; Tailwind for layout.
2. Strict TypeScript; API types **generated** from the backend OpenAPI, never hand-written
   (`standards/api-contract.md`, via the `sync-api-types` skill).
3. Auth via Okta (`@okta/okta-react`, `standards/auth-okta.md`); never store tokens in
   `localStorage` without reason. Render API errors from the canonical envelope
   (`standards/api-errors.md`) — show `message`, map `errors[]` to fields.
4. Tests: React Testing Library (behavior, not implementation), one test per key component.
5. No secret/key in the bundle; variables via `import.meta.env` (public prefix).
6. Lint/format: ESLint + Prettier (via hooks + pre-commit).
