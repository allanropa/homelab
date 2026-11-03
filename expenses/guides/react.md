# React Project Guide

## Core principles

-   Inspect the existing project structure, conventions, dependencies,
    and tests before changing code.
-   Follow the project's established framework, router, styling system,
    and component patterns. Do not add a new library without a clear
    benefit.
-   Prefer TypeScript for new React code when supported.
-   Optimize for readability and maintainability before cleverness or
    premature performance optimization.

## Component design and reuse

-   Build small, focused components with one clear responsibility.
-   Extract a component when it has a meaningful UI responsibility,
    reusable behavior, independent state, or enough complexity to
    understand separately.
-   Prefer composition: parent components coordinate; child components
    render focused pieces of UI.
-   Keep reusable UI components separate from page-level components and
    domain-specific business logic.
-   Avoid both extremes: do not keep an entire page in one component,
    but do not create components for every trivial `<div>` or one-line
    expression.
-   Give components descriptive names based on their purpose, not their
    visual implementation.
-   Keep component props explicit, typed, and as small as practical.
    Avoid passing large objects when only a few fields are needed.
-   Use children or composition slots when they make component APIs
    simpler than many boolean props.
-   Keep components that are tightly coupled and only used together
    close to each other. Move genuinely shared components to a shared
    location.
-   Do not duplicate substantial UI or business logic. Extract shared
    behavior only when there is a stable common concept.

## File size and structure

-   Keep files small enough to understand without scrolling through
    unrelated concerns. As a guideline, aim for roughly 150--250 lines
    per component file; this is not a hard limit, and a focused longer
    file is better than artificial fragmentation.
-   If a component file grows beyond that range or mixes multiple
    responsibilities, consider splitting it into smaller components,
    hooks, utilities, types, or API modules.
-   A page component should usually compose other components rather than
    implement every visual section inline.
-   Keep each file focused on one primary concern. Avoid mixing UI
    rendering, complex business rules, API requests, data normalization,
    and large constant collections in one file.
-   Co-locate files by feature when that improves discoverability.
    Follow the repository's existing structure rather than reorganizing
    the whole app without need.
-   Use barrel files (`index.ts`) only when they improve imports and do
    not create confusing circular dependencies.
-   Do not split files solely to satisfy a line count. The goal is clear
    responsibilities, not hitting a metric.

## Suggested component organization

Adapt this to the existing repository; do not force a restructure if the
project already has a good convention.

``` text
src/
  app/                 # App setup, routes, providers
  pages/                # Route-level screens
  components/
    ui/                 # Generic reusable UI components
    layout/             # Navigation, shell, shared layout
  features/
    expenses/
      components/       # Feature-specific components
      hooks/            # Feature-specific hooks
      api.ts            # API calls for this feature
      types.ts          # Feature types
      utils.ts          # Pure feature helpers
      ExpensesPage.tsx  # Page composition
  hooks/                # Truly shared hooks
  lib/                  # Shared clients and integrations
  types/                # Shared domain types, only when genuinely shared
```

## Separation of concerns

-   Keep page components focused on orchestration, layout, and composing
    feature components.
-   Put complex reusable stateful behavior in custom hooks when doing so
    makes the component easier to read and test.
-   Keep pure calculations and transformations in ordinary functions or
    feature utilities, not buried in JSX.
-   Put network requests in the project's established API/data-access
    layer instead of embedding fetch logic throughout components.
-   Keep API response types and domain types explicit. Normalize server
    data at a clear boundary if needed.
-   Avoid effects for values that can be derived during render.
-   Do not introduce global state for data that can remain local to a
    component or feature.
-   Avoid giant conditional JSX blocks; extract named components or
    helper functions when that clarifies intent.

## State, hooks, and effects

-   Keep state close to the components that own it.
-   Derive values during render rather than duplicating them in state.
-   Use effects to synchronize with external systems, not to calculate
    derived values.
-   Never call hooks conditionally, in loops, or inside nested
    functions.
-   Include correct effect dependencies. Do not silence hook lint rules
    without documenting why.
-   Extract a custom hook when stateful logic is reused or when it
    meaningfully simplifies a component; do not create a hook merely to
    wrap one trivial line.
-   Handle loading, empty, success, and error states for asynchronous
    work.
-   Prevent stale request results from overwriting newer state when
    requests can overlap.

## TypeScript

-   Define explicit types for component props, API responses, and
    non-trivial domain data.
-   Prefer `unknown` over `any` for untrusted values and narrow types
    before use.
-   Avoid type assertions that merely silence errors. Validate data at
    runtime at trust boundaries.
-   Use discriminated unions for states with distinct variants when that
    improves correctness.
-   Keep shared types in the feature or shared location that owns them;
    avoid duplicated definitions.

## Accessibility and UX

-   Use semantic HTML elements and native controls where possible.
-   Every interactive control must have an accessible name.
-   Support keyboard navigation and visible focus.
-   Associate form controls with labels and provide clear validation
    messages.
-   Do not use color as the only indicator of state.
-   Confirm destructive actions when appropriate and communicate success
    or failure.
-   Make responsive layouts consistent with the existing design system.

## Performance

-   Measure before optimizing.
-   Avoid unnecessary effects, state updates, and expensive work during
    render.
-   Use memoization only when it addresses a real performance issue or
    stable-reference requirement.
-   Avoid rendering huge lists without pagination or virtualization when
    data size warrants it.
-   Split code at meaningful route or feature boundaries if supported by
    the build system.

## API integration

-   Centralize API configuration and shared request behavior according
    to the project's established pattern.
-   Handle non-2xx responses explicitly; `fetch` does not reject just
    because the server returned an HTTP error.
-   Validate or safely narrow API data before relying on it.
-   Keep authentication/session behavior consistent with the backend's
    security model.
-   Never put server-only credentials in environment variables exposed
    to the client.

## Testing

-   Follow the existing test runner and component-testing approach.
-   Test user-visible behavior and important state transitions.
-   Prefer accessible queries by role and label.
-   Cover validation, loading/error states, and regression cases.
-   Avoid tests that depend on implementation details unless there is a
    strong reason.

## Before finishing a frontend task

-   Review whether any component has grown too large or is doing
    multiple jobs.
-   Check whether repeated UI or logic should be extracted without
    overengineering.
-   Confirm loading, empty, error, and success states where relevant.
-   Run the relevant tests, lint, and type checks available in the
    repository.
-   Report checks actually run; never claim a check passed if it was not
    executed.
