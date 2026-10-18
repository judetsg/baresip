#!/bin/bash
# Run the doorbell device container
set -e
cd "$(dirname "$0")/.."
echo "=== Starting doorbell device ==="
docker compose -f docker/docker-compose.yml up -d
echo "=== Container status ==="
docker ps --filter name=doorbell-device
echo ""
echo "To view logs: docker logs -f doorbell-device"
echo "To enter CLI:  docker exec -it doorbell-device asterisk -r"