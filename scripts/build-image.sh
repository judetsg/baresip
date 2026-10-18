#!/bin/bash
# Build the doorbell Docker image
set -e
cd "$(dirname "$0")/.."
echo "=== Building doorbell image ==="
docker build -t doorbell-device -f docker/Dockerfile .
echo "=== Done. Run with: ./scripts/run.sh ==="