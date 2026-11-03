# Python Project Guide

## Before coding

-   Inspect `pyproject.toml`, lockfiles, package layout, existing tests,
    and current Python version.
-   Follow the project's existing framework and conventions. Do not
    migrate Flask to FastAPI, or vice versa, unless asked.
-   Prefer `pyproject.toml` for project metadata and tool configuration
    when compatible with the repository.

## Style and typing

-   Use clear names, small functions, and explicit return types for
    public functions.
-   Add type hints to application code and use modern built-in generics
    when supported by the project's Python version.
-   Prefer `pathlib.Path` for filesystem paths and context managers for
    resources.
-   Use dataclasses or validated models when they improve clarity; avoid
    creating classes for trivial data transformations.
-   Keep functions pure where practical and isolate I/O at system
    boundaries.
-   Avoid broad `except Exception` blocks. Catch expected exceptions and
    preserve useful error context.
-   Do not use mutable default arguments.
-   Avoid hidden global state and import-time side effects.

## Application architecture

-   Separate domain/business rules from HTTP handlers, database access,
    and external service clients.
-   Keep route/controller functions thin: parse input, call application
    logic, and map results to HTTP responses.
-   Put external API calls behind small clients or adapters when this
    makes them testable.
-   Use dependency injection or explicit parameters for dependencies
    rather than patching global state.
-   Avoid premature abstraction. Introduce interfaces when there is a
    real boundary or testing need.

## FastAPI guidance (when FastAPI is already used)

-   Define request and response schemas explicitly with Pydantic.
-   Use response models to make API contracts clear.
-   Use dependency injection for authentication, database sessions, and
    shared services.
-   Choose sync or async functions based on the I/O libraries in use; do
    not assume `async` automatically makes code faster.
-   Return appropriate HTTP status codes and stable error shapes.
-   Keep database transactions explicit and short.
-   Avoid putting business logic directly in route handlers.

## Flask guidance (when Flask is already used)

-   Use application factories when they fit the current app structure.
-   Organize routes with blueprints for meaningful feature boundaries.
-   Keep configuration environment-specific and out of source control.
-   Avoid importing and initializing the whole application in modules
    that should be independently testable.

## Persistence and data

-   Make transaction boundaries explicit.
-   Use parameterized queries or the ORM's safe query APIs; never build
    SQL by concatenating untrusted input.
-   Treat migrations as versioned code and review generated migrations
    before applying them.
-   Design writes to be safe under retries where relevant; consider
    uniqueness constraints and idempotency.
-   Avoid N+1 queries and unbounded result sets. Add pagination where
    collection sizes can grow.
-   Store timestamps consistently, preferably in UTC, and convert for
    display at the edges.

## Dependencies and configuration

-   Use the repository's existing dependency manager and lockfile.
-   Keep secrets in environment variables or the project's
    secret-management mechanism.
-   Validate required configuration at startup and fail with actionable
    messages.
-   Do not add a library for a task the standard library already handles
    well unless there is a clear benefit.

## Logging and errors

-   Use the project's logging setup; prefer structured fields when
    supported.
-   Include useful context such as operation identifiers, but never log
    credentials, tokens, or sensitive request bodies.
-   Do not expose stack traces or database details in public API
    responses.
-   Avoid silently swallowing errors or returning success-shaped
    defaults after failures.

## Tests

-   Use the test framework already configured; pytest is a sensible
    default for new projects.
-   Test observable behavior, boundary conditions, and failure paths.
-   Prefer unit tests for business rules and integration tests for
    database/framework behavior.
-   Mock external systems at clear boundaries, not every internal
    function.
-   Keep tests deterministic; freeze time or seed randomness when
    needed.
-   Add regression tests for bug fixes.
