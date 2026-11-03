# Application Security Guide

## Trust boundaries

-   Treat all client input, imported files, webhook payloads, and
    external API responses as untrusted.
-   Validate input at boundaries and enforce authorization on the server
    for every protected operation.
-   Authentication is not authorization: verify the caller may access
    the specific resource.
-   Do not rely on hidden UI controls or client-side checks for
    security.

## Secrets and sensitive data

-   Never hardcode secrets or commit `.env` files containing real
    credentials.
-   Provide `.env.example` with placeholder values only.
-   Do not print tokens, passwords, session cookies, private keys, or
    sensitive personal data in logs.
-   Keep server-only credentials out of React/browser bundles.
-   Return generic public errors while retaining safe diagnostic detail
    in server logs.

## Web and API

-   Use parameterized SQL or safe ORM APIs.
-   Apply request size limits and validation where relevant.
-   Use secure session/cookie settings and CSRF protection when the
    authentication model requires it.
-   Configure CORS narrowly; do not treat CORS as authentication.
-   Rate-limit sensitive or abuse-prone endpoints where appropriate.
-   Use HTTPS at deployment boundaries and secure cookies in production.
-   Avoid open redirects and unsafe URL fetching from user-controlled
    inputs.

## Authorization and multi-user data

-   Scope database reads and writes to the authenticated principal or
    authorized group.
-   Check access on every request, including background jobs and file
    downloads.
-   Use unpredictable identifiers where they reduce enumeration risk,
    but never treat unguessable IDs as authorization by themselves.
-   For invite keys or group access keys, store a hash where practical,
    support rotation/revocation, and avoid logging the raw key.
-   Apply least privilege to admin functions and keep private
    administration endpoints separate from public capabilities.

## Dependencies and operations

-   Use lockfiles and review dependency changes.
-   Avoid running untrusted scripts or shell commands without
    inspection.
-   Do not perform destructive operations, production migrations, or
    deployments unless explicitly requested.
-   Document security-sensitive configuration and operational
    assumptions.
