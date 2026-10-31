---
name: react-feature
description: >
  Builds a React + TypeScript feature (component + hook + test) using Tailwind CSS and the
  portfolio Fluid Design System (NJ* components). Use when adding frontend UI/behavior.
---

# Build a React feature

Apply `standards/frontend-react.md` and `standards/testing.md`. Detect the layout
(monorepo `front/` vs standalone) and read the project's Tailwind/Vite setup, state
library and i18n before coding.

1. Ask for the feature (what the user sees/does), the data it needs, and where it lives in
   the route/component tree.
2. **UI = Fluid first**: build from `@portfolio-ui/fluid-design-system-react` `NJ*`
   components (NJButton, NJCheckbox, NJTabs, NJTooltip…). Never re-create a component that
   already exists in Fluid.
3. **Layout/spacing/responsive = Tailwind**; custom `nj-`/scss CSS only as a last resort.
4. Isolate data fetching in a **hook**; expose explicit `loading / error / empty / data`
   states. No data logic inside the presentational component.
5. Strict TypeScript: typed props and API shapes, no unjustified `any`.
6. i18n via the project's library — **no hardcoded user-facing text**.
7. **Test** the key component with React Testing Library: render, interaction, and the
   loading/error/empty/data states; mock the network at fetch level (MSW preferred).
8. Run lint + tests, fix, and report: files touched, Fluid components used, states handled.
