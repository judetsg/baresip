#!/usr/bin/env bash
# Stop everything
cd "$(dirname "$0")/.."
pkill -x linphone 2>/dev/null || true
sleep 1
docker compose -f docker/docker-compose.yml down 2>/dev/null || true
echo "Everything stopped."