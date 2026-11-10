#!/usr/bin/env bash
# Deploy the current tip of the remote main branch; review code before --apply.
# Requires GitHub SSH access and the shared network created by Hermes Compose.
set -euo pipefail

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

apply=false
case "${1-}" in
  '') ;;
  --apply) apply=true ;;
  *) die 'Uso: bash deploy.sh [--apply]' ;;
esac
[[ $# -le 1 ]] || die 'Uso: bash deploy.sh [--apply]'
script_dir=$(dirname -- "$(realpath -e -- "${BASH_SOURCE[0]}")")
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=yes'
export COMPOSE_DISABLE_ENV_FILE=1
tmp=$(mktemp -d /tmp/guild-wars-2-mcp.XXXXXXXX)
[[ "$tmp" =~ ^/tmp/guild-wars-2-mcp\.[a-zA-Z0-9]{8}$ && -d "$tmp" && ! -L "$tmp" ]] || die 'Ruta temporal inesperada; no se eliminara automaticamente'
trap 'rm -rf -- "$tmp"' EXIT

origin=git@github.com:allanropa/guild-wars-2-mcp.git
git -c maintenance.auto=false clone --no-checkout --no-tags --branch master -- "$origin" "$tmp/repo"
git -C "$tmp/repo" -c maintenance.auto=false fetch --no-tags --no-recurse-submodules origin refs/heads/master
fetched=$(git -C "$tmp/repo" rev-parse --verify 'FETCH_HEAD^{commit}')
git -C "$tmp/repo" checkout --detach "$fetched"
[[ -f "$tmp/repo/requirements.txt" && -f "$tmp/repo/code/server.py" && -f "$tmp/repo/code/connector.py" ]] || die 'Faltan requirements.txt o archivos necesarios de code/'

export MCP_BUILD_CONTEXT="$tmp/repo"
export MCP_DOCKERFILE="$tmp/Dockerfile"
printf '%s\n' \
  'FROM python:3.12-alpine' \
  'RUN adduser -D -u 10001 connector' \
  'WORKDIR /app' \
  'COPY requirements.txt /app/requirements.txt' \
  'RUN pip install --no-cache-dir -r /app/requirements.txt' \
  'COPY code/ /app/' \
  'USER connector' \
  'ENTRYPOINT ["python", "/app/server.py"]' > "$MCP_DOCKERFILE"
compose=(docker compose -p guild_wars_2_connector --project-directory "$script_dir" -f "$script_dir/docker-compose.yml")
"${compose[@]}" config --quiet
if "$apply"; then
  "${compose[@]}" build mcp
  "${compose[@]}" up -d --no-deps --no-build mcp
else
  printf '%s\n' 'Verificacion completada; no se ha ejecutado build ni up.'
fi
