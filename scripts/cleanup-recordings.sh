#!/bin/bash
# Delete recordings older than N days (default 7)
DAYS=${1:-7}
CONTAINER=doorbell-device
echo "Deleting recordings older than $DAYS days..."
docker exec "$CONTAINER" find /var/spool/asterisk/monitor -name '*.wav' -mtime +$DAYS -delete
echo "Done."