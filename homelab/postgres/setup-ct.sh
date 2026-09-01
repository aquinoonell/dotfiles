#!/usr/bin/env bash
# Run *inside* CT 110 after pct create. Installs Docker + Postgres 16.
set -euo pipefail

apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir -p /root/postgres/data
# compose file is pushed separately to /root/postgres/docker-compose.yml
cd /root/postgres
docker compose up -d
docker compose ps
