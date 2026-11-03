#!/bin/bash
set -euo pipefail

wait_ready() {
  until docker info >/dev/null 2>&1 && iptables -L DOCKER-USER >/dev/null 2>&1; do
    sleep 2
  done
}

bridge_for() {
  local id
  id="$(docker network inspect -f '{{.Id}}' "$1")"
  printf 'br-%s\n' "${id:0:12}"
}

ensure_jump() {
  local parent="$1" bridge="$2" target="$3"
  if ! iptables -C "$parent" -i "$bridge" -j "$target" 2>/dev/null; then
    iptables -I "$parent" 1 -i "$bridge" -j "$target"
  fi
}

remove_jump() {
  local parent="$1" bridge="$2" target="$3"
  while iptables -C "$parent" -i "$bridge" -j "$target" 2>/dev/null; do
    iptables -D "$parent" -i "$bridge" -j "$target"
  done
}

drop_stale_jumps() {
  local parent="$1" bridge="$2" prefix="$3"
  local args=()
  while read -r -a args; do
    [[ "${args[0]:-}" == "-A" && "${args[1]:-}" == "$parent" ]] || continue
    [[ "${args[2]:-}" == "-i" && "${args[4]:-}" == "-j" ]] || continue
    [[ "${args[5]:-}" == "$prefix"* ]] || continue
    [[ "${args[3]:-}" == "$bridge" ]] && continue
    remove_jump "$parent" "${args[3]}" "${args[5]}"
  done < <(iptables -S "$parent")
}

build_chain() {
  local chain="$1" gw="$2" subnet="$3" public="$4"
  iptables -N "$chain" 2>/dev/null || iptables -F "$chain"
  iptables -F "$chain"
  iptables -A "$chain" -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
  iptables -A "$chain" -d "$gw" -j DROP
  iptables -A "$chain" -d "$subnet" -j RETURN
  iptables -A "$chain" -d 0.0.0.0/8 -j DROP
  iptables -A "$chain" -d 10.0.0.0/8 -j DROP
  iptables -A "$chain" -d 100.64.0.0/10 -j DROP
  iptables -A "$chain" -d 127.0.0.0/8 -j DROP
  iptables -A "$chain" -d 169.254.0.0/16 -j DROP
  iptables -A "$chain" -d 172.16.0.0/12 -j DROP
  iptables -A "$chain" -d 192.168.0.0/16 -j DROP
  iptables -A "$chain" -d 224.0.0.0/4 -j DROP
  if [[ "$public" == 1 ]]; then
    iptables -A "$chain" -j RETURN
  else
    iptables -A "$chain" -j DROP
  fi
}

swap_in() {
  local bridge="$1" gw="$2" subnet="$3" base="$4" public="$5"
  local live next
  live="$(iptables -S INPUT | awk -v br="$bridge" -v base="$base" '$1=="-A" && $2=="INPUT" && $3=="-i" && $4==br && $5=="-j" && index($6, base)==1 { print $6; exit }')"
  if [[ "$live" == "${base}A" ]]; then
    next="${base}B"
  else
    next="${base}A"
  fi
  build_chain "$next" "$gw" "$subnet" "$public"
  ensure_jump INPUT "$bridge" "$next"
  ensure_jump DOCKER-USER "$bridge" "$next"
  if [[ -n "$live" && "$live" != "$next" ]]; then
    remove_jump INPUT "$bridge" "$live"
    remove_jump DOCKER-USER "$bridge" "$live"
    iptables -F "$live" 2>/dev/null || true
    iptables -X "$live" 2>/dev/null || true
  fi
  drop_stale_jumps INPUT "$bridge" "$base"
  drop_stale_jumps DOCKER-USER "$bridge" "$base"
  echo "isolated ${bridge} via ${next} gw=${gw} subnet=${subnet} public=${public}"
}

lock_ipv6() {
  local bridge="$1"
  if ! ip6tables -C INPUT -i "$bridge" -m conntrack --ctstate NEW -j DROP 2>/dev/null; then
    ip6tables -I INPUT 1 -i "$bridge" -m conntrack --ctstate NEW -j DROP
  fi
  if ! ip6tables -C DOCKER-USER -i "$bridge" -j DROP 2>/dev/null; then
    ip6tables -I DOCKER-USER 1 -i "$bridge" -j DROP
  fi
}

apply_all() {
  local name bridge gw subnet base public
  while read -r name base public; do
    docker network inspect "$name" >/dev/null 2>&1 || continue
    bridge="$(bridge_for "$name")"
    gw="$(docker network inspect -f '{{(index .IPAM.Config 0).Gateway}}' "$name")"
    subnet="$(docker network inspect -f '{{(index .IPAM.Config 0).Subnet}}' "$name")"
    [[ -n "$gw" && -n "$subnet" ]] || continue
    swap_in "$bridge" "$gw" "$subnet" "$base" "$public"
    lock_ipv6 "$bridge"
  done <<'EOF'
cloudflared ISOCF 1
expenses_default ISOEX 0
EOF
}

wait_ready
apply_all
while true; do
  timeout 60 docker events --filter type=network >/dev/null 2>&1 || true
  apply_all || true
done
