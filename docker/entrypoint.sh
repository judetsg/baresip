#!/bin/bash
# Start Asterisk in foreground so Docker keeps the container alive.
set -e

# Ensure runtime dirs exist (in case of volume mounts)
mkdir -p /var/spool/asterisk/monitor /var/spool/asterisk/voicemail /var/log/asterisk 2>/dev/null || true

echo "=== Starting Asterisk (doorbell device) ==="
exec asterisk -f -U asterisk -G asterisk