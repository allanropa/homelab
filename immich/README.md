# Immich - Docker Compose

## Configuration

Review the Compose configuration and adapt storage locations, versions and
other settings to your environment. The stack uses a `.env` file for
non-sensitive settings and a separate environment file for credentials.
Both are required. Keep secrets out of Git and do not overwrite an existing
secrets file. Check the Compose file for its configured secrets location before
running commands; supplying an environment file does not change paths referenced
inside the Compose configuration.

## Operation

Run Compose from this directory, supplying both environment files. Replace the
placeholder with the secrets file used by your configuration:

```bash
docker compose --env-file .env --env-file "<secrets-file>" config --quiet
docker compose --env-file .env --env-file "<secrets-file>" up -d
```

Before updating, review the release notes and the configuration compatibility for
the chosen Immich version. Consult the official Immich documentation for
installation, updates and recovery procedures.

## Backups

Before changes or updates, create and verify backups of the database, media and
configuration needed for recovery. Store credentials separately and securely,
and test the restoration procedure.
