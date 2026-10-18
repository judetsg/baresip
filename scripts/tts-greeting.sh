#!/usr/bin/env bash
# Generate the IVR greeting WAV from text using offline text-to-speech.
#
# It uses espeak-ng. If espeak-ng is not installed, it fetches a private copy
# into ~/.cache/doorbell-tts (no sudo needed, since the voice *data* is already
# installed by speech-dispatcher). Finally it converts the result to the
# Asterisk formats via scripts/make-sounds.sh.
#
# Usage:
#   ./scripts/tts-greeting.sh                 # default 3-option menu text
#   ./scripts/tts-greeting.sh "Custom text"   # your own text
#   VOICE=en-gb ./scripts/tts-greeting.sh     # pick a voice
set -euo pipefail
cd "$(dirname "$0")/.."

VOICE="${VOICE:-en-us}"
SPEED="${SPEED:-150}"
OUT="sounds/custom/welcome.wav"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/doorbell-tts"

TEXT="${*:-Welcome to the doorbell. Press 1 to leave a message. Press 2 to call the owner. Press 3 to repeat this menu.}"

# --- locate espeak-ng binary -------------------------------------------------
find_engine() {
    if command -v espeak-ng >/dev/null 2>&1; then
        command -v espeak-ng; return 0
    fi
    if [ -x "$CACHE/espeak-ng/usr/bin/espeak-ng" ]; then
        echo "$CACHE/espeak-ng/usr/bin/espeak-ng"; return 0
    fi
    # not installed: fetch a private copy (no root required)
    if command -v apt-get >/dev/null 2>&1 && command -v dpkg-deb >/dev/null 2>&1; then
        echo "  espeak-ng not installed - fetching a private copy..." >&2
        mkdir -p "$CACHE/espeak-ng"
        ( cd "$CACHE/espeak-ng" && apt-get download espeak-ng >/dev/null 2>&1 ) || true
        deb=$(ls "$CACHE/espeak-ng"/*.deb 2>/dev/null | head -1 || true)
        [ -n "$deb" ] && dpkg-deb -x "$deb" "$CACHE/espeak-ng" >/dev/null 2>&1 || true
        if [ -x "$CACHE/espeak-ng/usr/bin/espeak-ng" ]; then
            echo "$CACHE/espeak-ng/usr/bin/espeak-ng"; return 0
        fi
    fi
    return 1
}

# --- locate the voice data ---------------------------------------------------
find_data() {
    local d
    for d in /usr/lib/*/espeak-ng-data /usr/lib/espeak-ng-data \
             /usr/share/espeak-ng-data "$CACHE"/espeak-ng/usr/lib/*/espeak-ng-data \
             "$CACHE"/espeak-ng/usr/share/espeak-ng-data; do
        [ -d "$d" ] && { echo "$d"; return 0; }
    done
    # no data anywhere: fetch espeak-ng-data too
    if command -v apt-get >/dev/null 2>&1 && command -v dpkg-deb >/dev/null 2>&1; then
        echo "  fetching voice data..." >&2
        mkdir -p "$CACHE/espeak-ng"
        ( cd "$CACHE/espeak-ng" && apt-get download espeak-ng-data >/dev/null 2>&1 ) || true
        deb=$(ls "$CACHE/espeak-ng"/espeak-ng-data*.deb 2>/dev/null | head -1 || true)
        [ -n "$deb" ] && dpkg-deb -x "$deb" "$CACHE/espeak-ng" >/dev/null 2>&1 || true
        d=$(find "$CACHE/espeak-ng" -type d -name espeak-ng-data 2>/dev/null | head -1)
        [ -n "$d" ] && { echo "$d"; return 0; }
    fi
    return 1
}

ENGINE=$(find_engine) || {
    echo "No espeak-ng available and could not fetch one." >&2
    echo "Install it with:  sudo apt install espeak-ng" >&2
    echo "Or record your own voice:  ./scripts/record-greeting.sh" >&2
    exit 1
}
DATA=$(find_data) || {
    echo "Could not find espeak-ng voice data." >&2
    echo "Install it with:  sudo apt install espeak-ng-data" >&2
    exit 1
}

echo "=== Generating greeting with espeak-ng (voice: $VOICE) ==="
echo "  text: $TEXT"

TMP=$(mktemp -d)
ESPEAK_DATA_PATH="$DATA" "$ENGINE" -v "$VOICE" -s "$SPEED" -w "$TMP/welcome.wav" "$TEXT"
cp "$TMP/welcome.wav" "$OUT"
rm -rf "$TMP"

./scripts/make-sounds.sh
echo "=== Greeting saved to $OUT (+ .ulaw / .alaw) ==="
