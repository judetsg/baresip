#!/bin/bash
# Basic smoke tests for the doorbell device
set -e
CONTAINER=doorbell-device
echo "=== Smoke test: $CONTAINER ==="

run() { docker exec "$CONTAINER" asterisk -rx "$1"; }

echo "--- Asterisk version ---"
run "core show version"

echo "--- PJSIP endpoints ---"
run "pjsip show endpoints"

echo "--- Dialplan contexts ---"
run "dialplan show" | head -40

echo "--- Loaded modules (key ones) ---"
run "module show like pjsip" | head -5
run "module show like voicemail" | head -5
run "module show like mixmonitor" | head -5

echo "--- Active channels (should be 0 at idle) ---"
run "core show channels"

echo "=== Smoke test done ==="