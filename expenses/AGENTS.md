# Project Guidance for OpenCode

These instructions apply to the entire repository. Follow more specific
`AGENTS.md` files in subdirectories when present.

## General principles

-   First inspect the existing repository, README, dependency manifests,
    tests, and local conventions before changing code.
-   Prefer a small, focused change over a broad rewrite. Preserve
    existing behavior unless the task explicitly requests a behavior
    change.
-   Do not assume a framework, library, command, or architecture is
    present. Verify it in the repository first.
-   Explain important assumptions when requirements are ambiguous. Ask a
    concise question if an ambiguity could cause an expensive or risky
    change.
-   Keep code readable, typed where practical, and easy to test. Avoid
    clever abstractions and speculative generality.
-   Do not add dependencies unless they provide clear value. Prefer
    established project dependencies and standard-library solutions
    where reasonable.
-   Never commit secrets, credentials, private keys, access tokens, or
    real personal data. Use environment variables and documented example
    values.
-   Do not silently change public APIs, database schemas, configuration
    formats, or dependency major versions.
-   Do not claim tests passed unless you actually ran them. Report
    commands run and any limitations.

## Workflow

1.  Inspect relevant files and the current git diff before editing.
2.  Identify the smallest implementation that satisfies the request.
3.  Follow the language-specific guidance in `guides/`.
4.  Add or update tests for changed behavior.
5.  Run focused tests and relevant lint/type checks available in the
    repository.
6.  Review the final diff for unrelated edits, security concerns, and
    accidental generated files.
7.  Summarize what changed, tests run, and any follow-up work.

## Design and maintainability

-   Keep business logic separate from transport/UI code and
    infrastructure details.
-   Prefer explicit interfaces and clear data flow over hidden side
    effects.
-   Validate untrusted input at system boundaries.
-   Handle errors intentionally; do not swallow exceptions or expose
    internal stack traces to end users.
-   Use structured logging where the project already supports it. Never
    log secrets or sensitive payloads.
-   Keep functions focused and names descriptive. Avoid unnecessary
    comments that merely repeat the code.
-   Add comments for non-obvious decisions and constraints, not
    line-by-line narration.

## Git and tooling

-   Do not reset, revert, or overwrite unrelated user changes.
-   Do not create commits, push branches, deploy, or perform destructive
    operations unless explicitly requested.
-   Use the package manager and lockfile already chosen by the
    repository.
-   Do not run migrations against production or delete data without
    explicit authorization.
-   Prefer repository-local commands and reproducible setup
    instructions.

## Documentation

-   Update documentation when setup, behavior, configuration, or APIs
    change.
-   Keep examples runnable and mark placeholders clearly.
-   Document required environment variables without including real
    values.
