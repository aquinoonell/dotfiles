#!/usr/bin/env bash
# Build mdBook from bookstack-content/course and deploy to homelab (CT 104 :8089).
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
COURSE="$DIR/../bookstack-content/course"
PROXMOX="${PROXMOX_HOST:-proxmox}"
REMOTE_HTML="/root/kiwix-guide/html"

if ! command -v mdbook >/dev/null; then
  echo "Install mdbook: brew install mdbook"
  exit 1
fi

echo "==> Sync course markdown into src/chapters"
rm -rf "$DIR/src/chapters"
mkdir -p "$DIR/src/chapters/parqtool"
cp "$COURSE"/*.md "$DIR/src/chapters/"
cp "$COURSE"/parqtool/*.md "$DIR/src/chapters/parqtool/"

echo "==> Build"
cd "$DIR"
mdbook build

echo "==> Deploy to $PROXMOX (CT 104)"
tar czf /tmp/course-book.tar.gz -C "$DIR" book
scp /tmp/course-book.tar.gz "root@$PROXMOX:/tmp/"
ssh "root@$PROXMOX" "pct push 104 /tmp/course-book.tar.gz /tmp/course-book.tar.gz && \
  pct exec 104 -- bash -c 'rm -rf $REMOTE_HTML/* && tar xzf /tmp/course-book.tar.gz -C /tmp && cp -r /tmp/book/* $REMOTE_HTML/'"

echo "==> Done: http://192.168.1.175:8089"
