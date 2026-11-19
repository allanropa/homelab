#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"

compose=(
  docker compose
  --project-name expenses
  --project-directory "$script_dir"
  -f "$script_dir/docker-compose.yml"
  -f "$script_dir/docker-compose.caddy.yml"
)

if [ ! -f /etc/homelab/secrets/expenses.env ]; then
  echo "Error: /etc/homelab/secrets/expenses.env not found."
  exit 1
fi

echo "==> Downloading application images"
"${compose[@]}" pull backend frontend

echo "==> Deploying"
"${compose[@]}" up -d

if [ "$("${compose[@]}" ps -q backend | xargs -r docker inspect -f '{{.State.Status}}' 2>/dev/null)" != "running" ]; then
  echo "Backend did not stay running. Recent logs:"
  "${compose[@]}" logs --no-color --tail=80 backend
  exit 1
fi

echo "==> Removing dangling images"
docker image prune -f

echo "==> Service status"
"${compose[@]}" ps
