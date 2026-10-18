#!/usr/bin/env bash
# Record a greeting with your microphone and convert it to Asterisk-friendly
# formats (see scripts/make-sounds.sh for why mu-law WAV is not enough).
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="sounds/custom/welcome.wav"
DUR=${1:-5}

echo "Recording ${DUR}s from the default microphone... (speak now)"
ffmpeg -y -loglevel error -f alsa -i default -t "$DUR" -ar 8000 -ac 1 -c:a pcm_s16le "$OUT"

./scripts/make-sounds.sh

echo "Saved: $OUT  (+ .ulaw / .alaw next to it)"
echo "The sounds volume is live-mounted, so the IVR picks it up on the next call."
