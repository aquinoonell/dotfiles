#!/usr/bin/env bash
# Homelab status / ensure-core-running via Proxmox.
# Usage: homelab-mode.sh status|start-core
set -euo pipefail

PROXMOX="${PROXMOX_HOST:-proxmox}"
CORE=(101 102 103 104 110)

log() { printf '==> %s\n' "$*"; }
remote() { ssh -o BatchMode=yes -o ConnectTimeout=10 "$PROXMOX" "$@"; }

status() {
  log "Containers:"
  remote "pct list"
  log "VMs:"
  remote "qm list"
}

start_core() {
  log "Start core CTs: ${CORE[*]}"
  for id in "${CORE[@]}"; do
    remote "pct status $id" 2>/dev/null | grep -q stopped && remote "pct start $id" || true
  done
}

case "${1:-status}" in
  status) status ;;
  start-core|learning|full) start_core ;;
  *) echo "Usage: $0 {status|start-core}" >&2; exit 1 ;;
esac
