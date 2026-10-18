#!/usr/bin/env bash
# Play (or inspect) a call recording from the doorbell container.
#
# Recordings live inside the container under /var/spool/asterisk/monitor/.
# This copies one out to the host and plays it on your speakers.
#
# Usage:
#   ./scripts/play-recording.sh                 # play the most recent recording
#   ./scripts/play-recording.sh <name.wav>      # play a specific file (name or full path)
#   ./scripts/play-recording.sh --list          # list recordings
#   ./scripts/play-recording.sh --info          # show details of the latest recording
#   ./scripts/play-recording.sh --path          # copy and print the host path only
set -euo pipefail

CONTAINER=doorbell-device
HOSTDIR="${TMPDIR:-/tmp}"
MONITOR_DIR=/var/spool/asterisk/monitor

# --- pick the container-side file -----------------------------------------
latest() {
    docker exec "$CONTAINER" sh -c "ls -1t $MONITOR_DIR/*.wav 2>/dev/null | head -1"
}

case "${1:-}" in
    --list|-l)
        docker exec "$CONTAINER" sh -c "ls -lt $MONITOR_DIR/*.wav 2>/dev/null || echo '(no recordings yet)'"
        exit 0
        ;;
    "" )            SRC=$(latest) ;;
    --info|-i|--path|-p) SRC=$(latest); MODE="${1}" ;;
    -*)             echo "Unknown option: $1" >&2; exit 2 ;;
    * )             case "$1" in /*) SRC="$1" ;; *) SRC="$MONITOR_DIR/$1" ;; esac ;;
esac
MODE="${MODE:-play}"

if [ -z "$SRC" ]; then
    echo "No recording found. Make a call first (guided demo, step 1)." >&2
    exit 1
fi

DEST="$HOSTDIR/doorbell-$(basename "$SRC")"
docker cp "$CONTAINER:$SRC" "$DEST" >/dev/null

case "$MODE" in
    --path|-p)
        echo "$DEST"
        exit 0
        ;;
    --info|-i)
        echo "File: $SRC"
        echo "Host copy: $DEST"
        if command -v ffprobe >/dev/null 2>&1; then
            ffprobe -v error \
                -show_entries stream=codec_name,sample_rate,channels \
                -show_entries format=duration,size,bit_rate \
                -of default=noprint_wrappers=1 "$DEST"
        else
            ls -la "$DEST"
        fi
        exit 0
        ;;
esac

# --- play it ---------------------------------------------------------------
echo "Playing: $(basename "$SRC")"
for player in "ffplay -nodisp -autoexit -loglevel error" "pw-play" "paplay" "aplay -q" "play -q"; do
    bin=${player%% *}
    if command -v "$bin" >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        if $player "$DEST"; then
            exit 0
        fi
    fi
done

echo "Could not find a working audio player." >&2
echo "The recording was copied to: $DEST" >&2
exit 1
