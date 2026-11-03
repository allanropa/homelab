#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
source_dir="$(mktemp -d -t expenses-deploy.XXXXXX)"

cleanup() {
  rm -rf "$source_dir"
}
trap cleanup EXIT

backend_repo="${BACKEND_REPOSITORY:-git@github.com:allanropa/expenses-be.git}"
frontend_repo="${FRONTEND_REPOSITORY:-git@github.com:allanropa/expenses-fe.git}"
backend_branch="${BACKEND_BRANCH:-master}"
frontend_branch="${FRONTEND_BRANCH:-master}"

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

echo "==> Cloning backend"
git clone --depth 1 --branch "$backend_branch" "$backend_repo" "$source_dir/backend"

echo "==> Cloning frontend"
git clone --depth 1 --branch "$frontend_branch" "$frontend_repo" "$source_dir/frontend"

export BACKEND_CONTEXT="$source_dir/backend"
export FRONTEND_CONTEXT="$source_dir/frontend"

echo "==> Rebuilding and redeploying"
"${compose[@]}" up -d --build

if [ "$("${compose[@]}" ps -q backend | xargs -r docker inspect -f '{{.State.Status}}' 2>/dev/null)" != "running" ]; then
  echo "Backend did not stay running. Recent logs:"
  "${compose[@]}" logs --no-color --tail=80 backend
  exit 1
fi

echo "==> Removing dangling images"
docker image prune -f

echo "==> Service status"
"${compose[@]}" ps
