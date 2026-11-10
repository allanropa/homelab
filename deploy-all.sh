#!/usr/bin/env bash
set -uo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
failed=()
dirs=()
for dir in "$root"/*/; do
  [[ $dir == "$root/silverbullet-mcp/" ]] || dirs+=("$dir")
done
# Deploy the connector after SilverBullet has created its default network.
dirs+=("$root/silverbullet-mcp/")

for dir in "${dirs[@]}"; do
  project=${dir%/}
  project=${project##*/}

  if [[ -f "${dir}compose.yaml" ]]; then
    file="${dir}compose.yaml"
  elif [[ -f "${dir}compose.yml" ]]; then
    file="${dir}compose.yml"
  elif [[ -f "${dir}docker-compose.yml" ]]; then
    file="${dir}docker-compose.yml"
  elif [[ -f "${dir}docker-compose.yaml" ]]; then
    file="${dir}docker-compose.yaml"
  else
    continue
  fi

  printf '\n==> %s\n' "$project"
  compose=(docker compose --project-directory "$dir" -f "$file")
  if [[ $project == expenses ]]; then
    compose+=(-f "${dir}docker-compose.caddy.yml")
  elif [[ $project == caddy ]]; then
    compose+=(--env-file /etc/homelab/secrets/caddy.env)
  elif [[ $project == immich ]]; then
    compose+=(--env-file "${dir}.env" --env-file /etc/homelab/secrets/immich.env)
  fi

  if [[ $project == silverbullet-mcp ]]; then
    if ! bash "${dir}deploy.sh" --apply; then
      failed+=("$project")
    fi
  elif ! "${compose[@]}" pull --ignore-buildable; then
    printf 'Error al descargar imagenes de %s; se omite su despliegue.\n' "$project" >&2
    failed+=("$project")
  elif [[ $project == expenses ]]; then
    if ! bash "${dir}deploy.sh"; then
      failed+=("$project")
    fi
  elif ! "${compose[@]}" up -d --build; then
    failed+=("$project")
  fi
done

if (( ${#failed[@]} )); then
  printf '\nError en los proyectos: %s\n' "${failed[*]}" >&2
  exit 1
fi

printf '\nTodos los proyectos se han desplegado correctamente.\n'
