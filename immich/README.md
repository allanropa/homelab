# Immich — Docker Compose

## Environment Variables

This stack uses two environment files:

- `.env`: Non-sensitive configuration, versioned in Git (paths, versions, timezone, etc.).
- `/etc/homelab/secrets/immich.env`: Sensitive configuration, excluded from Git (database passwords, credentials, etc.).

Both files are required to run Docker Compose correctly.

## Commands

Run all commands from `/opt/homelab/immich/`.

**Start services**

```bash
docker compose \
  --env-file .env \
  --env-file /etc/homelab/secrets/immich.env \
  up -d
```

**Stop services**

```bash
docker compose \
  --env-file .env \
  --env-file /etc/homelab/secrets/immich.env \
  down
```

**Update services**

```bash
docker compose \
  --env-file .env \
  --env-file /etc/homelab/secrets/immich.env \
  pull

docker compose \
  --env-file .env \
  --env-file /etc/homelab/secrets/immich.env \
  up -d
```

**Validate configuration**

```bash
docker compose \
  --env-file .env \
  --env-file /etc/homelab/secrets/immich.env \
  config --quiet
```

## Notes


