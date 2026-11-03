# Testing Guide

## General expectations

-   Add or update tests whenever behavior changes.
-   Start with the narrowest relevant test command, then run broader
    checks if practical.
-   Do not rewrite tests simply to make a failing implementation pass;
    verify the intended behavior.
-   Keep tests deterministic, isolated, and understandable.
-   Test behavior and contracts rather than private implementation
    details.
-   Include regression coverage for bug fixes.

## Python

-   Use the project's configured test runner; use pytest by default only
    if no runner is established.
-   Cover normal behavior, edge cases, invalid input, and expected
    failures.
-   Use fixtures for repeated setup and teardown.
-   Mock network calls and external services at adapter boundaries.
-   Use temporary directories and test databases where possible.
-   Ensure tests clean up resources and do not depend on execution
    order.

## React

-   Follow the existing runner (for example, Vitest or Jest) and testing
    library.
-   Test through roles, labels, and visible output where practical.
-   Cover interactions, form validation, loading, empty, and error
    states.
-   Avoid snapshots as the only test for meaningful behavior.
-   Mock network boundaries, not internal component details.

## Integration and end-to-end

-   Use integration tests for database queries, authentication
    boundaries, API contracts, and serialization.
-   Use end-to-end tests for critical user journeys when the project has
    suitable infrastructure.
-   Keep test data isolated and avoid using production services or real
    credentials.
-   Document tests that require optional services, containers, or
    environment variables.

## Reporting

When finishing a change, report: - Tests and checks actually run. -
Whether each passed or failed. - Any checks not run and why. - Known
gaps that materially affect confidence.
