#!/usr/bin/env bash
# Start everything: Asterisk container + two Linphone windows
set -e
cd "$(dirname "$0")/.."

# Kill any existing instances first (idempotent restart)
pkill -x linphone 2>/dev/null || true
docker compose -f docker/docker-compose.yml down 2>/dev/null || true
sleep 1

echo "=== Starting Asterisk container ==="
docker compose -f docker/docker-compose.yml up -d
sleep 3

# Regenerate clean, deterministic softphone profiles (also wipes stale
# call history so the GUI never shows leftover "anonymous" entries).
./scripts/setup-linphone.sh --clean

echo "=== Starting Linphone windows ==="

# Instance 1: visitor
RUNTIME_1="/tmp/linphone_runtime_1"
mkdir -p "$RUNTIME_1"; chmod 700 "$RUNTIME_1"
XDG_CONFIG_HOME="$HOME/.config/linphone_app1" XDG_DATA_HOME="$HOME/.local/share/linphone_app1" XDG_RUNTIME_DIR="$RUNTIME_1" dbus-run-session linphone > /tmp/opencode/linphone_app1.log 2>&1 &
sleep 8

# Instance 2: owner
RUNTIME_2="/tmp/linphone_runtime_2"
mkdir -p "$RUNTIME_2"; chmod 700 "$RUNTIME_2"
XDG_CONFIG_HOME="$HOME/.config/linphone_app2" XDG_DATA_HOME="$HOME/.local/share/linphone_app2" XDG_RUNTIME_DIR="$RUNTIME_2" dbus-run-session linphone > /tmp/opencode/linphone_app2.log 2>&1 &
sleep 8

echo ""
echo "=== Everything is running ==="
echo "  Asterisk:   doorbell-device container"
echo "  Linphone:   visitor (sip port 5070) + owner (sip port 5080)"
echo ""
echo "To stop everything: ./scripts/stop-all.sh"
