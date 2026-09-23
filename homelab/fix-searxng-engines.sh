#!/usr/bin/env bash
# Deploy SearXNG configuration to CT 103 (DuckDuckGo primary + IT extras).
# Run from Mac: ./fix-searxng-engines.sh
#
# Deploys:
#   - searxng-settings-override.yml → /etc/searxng/settings.yml (inside container)
#   - searxng-hostnames.yml → /etc/searxng/searxng-hostnames.yml (for hostnames plugin)
#
# Requires: ssh access to root@proxmox, CT 103 running with searxng container.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDE_SRC="${SCRIPT_DIR}/searxng-settings-override.yml"
HOSTNAMES_SRC="${SCRIPT_DIR}/searxng-hostnames.yml"

PROXMOX_HOST="${PROXMOX_HOST:-proxmox}"
CT_ID="103"
CONTAINER="searxng"
SEARXNG_URL="http://searxng.lan"

log() { printf '==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ -f "$OVERRIDE_SRC" ]] || die "Missing $OVERRIDE_SRC"
[[ -f "$HOSTNAMES_SRC" ]] || die "Missing $HOSTNAMES_SRC"

log "Deploying SearXNG config to CT $CT_ID..."

ssh_pct() {
  ssh "root@${PROXMOX_HOST}" "pct exec $CT_ID -- $*"
}

log "Checking SearXNG container..."
ssh_pct docker ps --format "'{{.Names}}'" | grep -q "$CONTAINER" || die "Container $CONTAINER not running on CT $CT_ID"

log "Backing up current settings..."
BACKUP="settings.yml.bak.$(date +%Y%m%d-%H%M%S)"
ssh_pct docker exec "$CONTAINER" cp /etc/searxng/settings.yml "/etc/searxng/$BACKUP" 2>/dev/null || warn "No existing settings.yml to backup"

log "Copying settings overlay..."
cat "$OVERRIDE_SRC" | ssh "root@${PROXMOX_HOST}" "pct exec $CT_ID -- docker exec -i $CONTAINER tee /etc/searxng/settings.yml > /dev/null"

log "Copying hostnames file..."
cat "$HOSTNAMES_SRC" | ssh "root@${PROXMOX_HOST}" "pct exec $CT_ID -- docker exec -i $CONTAINER tee /etc/searxng/searxng-hostnames.yml > /dev/null"

log "Restarting container..."
ssh_pct docker restart "$CONTAINER"

log "Waiting for SearXNG to come up..."
for i in $(seq 1 30); do
  if curl -fsS --max-time 2 "$SEARXNG_URL/" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

log "Running smoke tests..."
FAILED=0

smoke_test() {
  local name="$1"
  local query="$2"
  local expected_pattern="$3"
  local exclude_pattern="${4:-}"
  
  log "  Test: $name"
  local result
  result=$(curl -fsS --max-time 15 "$SEARXNG_URL/search?q=$(echo "$query" | sed 's/ /+/g')" 2>&1) || {
    warn "    FAIL: Request failed"
    FAILED=$((FAILED + 1))
    return
  }
  
  if echo "$result" | grep -qE "$expected_pattern"; then
    log "    PASS: Found expected results"
  else
    warn "    FAIL: Expected pattern not found: $expected_pattern"
    FAILED=$((FAILED + 1))
  fi
  
  if [[ -n "$exclude_pattern" ]] && echo "$result" | grep -qE "$exclude_pattern"; then
    warn "    FAIL: Found unwanted pattern: $exclude_pattern"
    FAILED=$((FAILED + 1))
  fi
}

smoke_test "DuckDuckGo general search" \
  "rust programming&engines=duckduckgo" \
  "(rust-lang\.org|github\.com|wikipedia\.org|class=\"result)" \
  ""

smoke_test "Default search uses DuckDuckGo or fallback" \
  "rust programming" \
  "(duckduckgo|bing|rust-lang\.org|class=\"result)" \
  ""

smoke_test "DataFusion RecordBatch (IT search)" \
  "DataFusion RecordBatch&categories=it,general" \
  "(apache\.org|docs\.rs|github\.com)" \
  "(ebay\.com|autoparts|squarespace)"

if [[ $FAILED -eq 0 ]]; then
  log "All smoke tests passed!"
else
  warn "$FAILED smoke test(s) failed — check configuration"
fi

log "Deployed engines:"
ssh_pct docker exec "$CONTAINER" grep -E "^  - name:|disabled:|weight:" /etc/searxng/settings.yml | head -40

log "Done. Test at: $SEARXNG_URL"
