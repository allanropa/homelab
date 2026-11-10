#!/usr/bin/env bash
# Review the upstream master branch before deploying; its revision is not pinned.
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
tmp=$(mktemp -d /tmp/imap-mcp.XXXXXXXX)
[[ "$tmp" =~ ^/tmp/imap-mcp\.[a-zA-Z0-9]{8}$ && -d "$tmp" && ! -L "$tmp" ]] || die 'Ruta temporal inesperada; no se eliminara automaticamente'
trap 'rm -rf -- "$tmp"' EXIT

git -c maintenance.auto=false clone --no-checkout --no-tags --branch master -- git@github.com:allanropa/imap-mcp.git "$tmp/repo"
git -C "$tmp/repo" checkout --detach
[[ -f "$tmp/repo/requirements.txt" && -f "$tmp/repo/code/server.py" && -f "$tmp/repo/code/connector.py" ]] || die 'Faltan requirements.txt o archivos necesarios de code/'

export MCP_BUILD_CONTEXT="$tmp/repo"
export MCP_DOCKERFILE="$script_dir/Dockerfile"
compose=(docker compose -p imap_connector --project-directory "$script_dir" -f "$script_dir/docker-compose.yml")
"${compose[@]}" config --quiet
if "$apply"; then
  "${compose[@]}" build mcp
  "${compose[@]}" up -d --no-deps --no-build mcp
else
  printf '%s\n' 'Verificacion completada; no se ha ejecutado build ni up.'
fi
