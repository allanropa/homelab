#!/usr/bin/env bash
set -euo pipefail

if [[ -f /etc/default/docker-volume-backup ]]; then
  # shellcheck disable=SC1091
  source /etc/default/docker-volume-backup
fi

BACKUP_DIR="${BACKUP_DIR:-/var/backups/docker-volumes}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
HELPER_IMAGE="${HELPER_IMAGE:-postgres:16-alpine}"
STOP_CONTAINERS="${STOP_CONTAINERS:-1}"
STOP_CONTAINERS_BY_NAME="${STOP_CONTAINERS_BY_NAME:-}"
SKIP="${SKIP:-}"
EXTRA_DIRS="${EXTRA_DIRS:-}"
LOG_FILE="${LOG_FILE:-/var/log/docker-volume-backup.log}"
LOCK_FILE="${LOCK_FILE:-/var/lock/docker-volume-backup.lock}"
BACKUP_OWNER="${BACKUP_OWNER:-dietpi:dietpi}"

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"
chown "$BACKUP_OWNER" "$BACKUP_DIR"
chmod 755 "$BACKUP_DIR"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "docker volume backup already running" >&2
  exit 1
fi

log() {
  printf '%s %s\n' "$(date -Is)" "$*" | tee -a "$LOG_FILE"
}

skip_volume() {
  local vol="$1" token
  for token in $SKIP; do
    [[ "$vol" == *"$token"* ]] && return 0
  done
  return 1
}

stamp="$(date +%Y%m%d-%H%M%S)"
dest="${BACKUP_DIR}/${stamp}"
mkdir -p "$dest"
chown "$BACKUP_OWNER" "$dest"
chmod 755 "$dest"
failed=0

log "start dest=$dest"

stopped_named_containers=()
for name in $STOP_CONTAINERS_BY_NAME; do
  mapfile -t containers < <(docker ps -q --filter "name=^/${name}$")
  if [[ ${#containers[@]} -gt 0 ]]; then
    log "stopping configured container $name: ${containers[*]}"
    docker stop "${containers[@]}" >/dev/null
    stopped_named_containers+=("${containers[@]}")
  fi
done

mapfile -t volumes < <(docker volume ls -q)
for vol in "${volumes[@]}"; do
  if skip_volume "$vol"; then
    log "skip volume $vol"
    continue
  fi

  containers=()
  mapfile -t containers < <(docker ps -q --filter "volume=${vol}")
  if [[ "$STOP_CONTAINERS" == "1" && ${#containers[@]} -gt 0 ]]; then
    log "stopping containers for $vol: ${containers[*]}"
    docker stop "${containers[@]}" >/dev/null
  fi

  if docker run --rm --entrypoint tar \
    -v "${vol}:/volume:ro" \
    -v "${dest}:/backup" \
    "$HELPER_IMAGE" \
    -czf "/backup/${vol}.tar.gz" -C /volume .; then
    log "ok volume $vol"
  else
    log "FAILED volume $vol"
    failed=1
  fi

  if [[ "$STOP_CONTAINERS" == "1" && ${#containers[@]} -gt 0 ]]; then
    if docker start "${containers[@]}" >/dev/null; then
      log "started containers for $vol"
    else
      log "FAILED restart for $vol: ${containers[*]}"
      failed=1
    fi
  fi
done

if [[ -n "$EXTRA_DIRS" ]]; then
  for dir in $EXTRA_DIRS; do
    if [[ ! -d "$dir" ]]; then
      log "skip missing dir $dir"
      continue
    fi
    name="$(basename "$dir")"
    if tar -C "$(dirname "$dir")" -czf "${dest}/${name}.tar.gz" "$name"; then
      log "ok dir $dir"
    else
      log "FAILED dir $dir"
      failed=1
    fi
  done
fi

if [[ ${#stopped_named_containers[@]} -gt 0 ]]; then
  if docker start "${stopped_named_containers[@]}" >/dev/null; then
    log "started configured containers: ${stopped_named_containers[*]}"
  else
    log "FAILED restart for configured containers: ${stopped_named_containers[*]}"
    failed=1
  fi
fi

find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -print -exec rm -rf {} + | while read -r old; do
  log "removed $old"
done

ln -sfn "$dest" "${BACKUP_DIR}/latest"
chown -h "$BACKUP_OWNER" "${BACKUP_DIR}/latest"
chown -R "$BACKUP_OWNER" "$dest"
log "done failed=$failed"
exit "$failed"
