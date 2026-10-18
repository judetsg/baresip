#!/usr/bin/env bash
# Generate deterministic Linphone profiles for the two demo softphones.
#
# Why this exists:
#   Linphone Desktop 4.x keeps its state in ~/.config/<app>/linphone/linphonerc
#   plus runtime databases under ~/.local/share/<app>/linphone/. When those grow
#   stale (old test calls, half-finished setup-assistant runs) the GUI can show
#   confusing things such as a phantom "default identity" and a warning icon.
#   This script rewrites both profiles from scratch so the demo always looks the
#   same: one clean SIP account per window, named "visitor" and "owner".
#
# Usage:
#   ./scripts/setup-linphone.sh           # write clean profiles, keep call history
#   ./scripts/setup-linphone.sh --clean   # also wipe friends / call history
set -euo pipefail

CLEAN=0
case "${1:-}" in
    --clean) CLEAN=1 ;;
    "")      ;;
    *) echo "Usage: $0 [--clean]" >&2; exit 2 ;;
esac

# gen <app-dir> <sip-user> <password> <sip-port> <audio-rtp-port> <video-rtp-port>
gen() {
    local app="$1" user="$2" pass="$3" sip_port="$4" artp="$5" vrtp="$6"
    local confdir="$HOME/.config/$app/linphone"
    local datadir="$HOME/.local/share/$app/linphone"

    mkdir -p "$confdir" "$datadir"

    if [ "$CLEAN" = 1 ]; then
        rm -f "$datadir/friends.db" "$datadir/call-history.db" "$datadir/zidcache"
    fi

    local ha1
    ha1=$(printf '%s' "$user:asterisk:$pass" | md5sum | awk '{print $1}')

    cat > "$confdir/linphonerc" <<EOF
[misc]
version_check_url_root=https://linphone.org/releases

[sip]
root_ca=/usr/share/linphone/rootca.pem
verify_server_certs=0
verify_server_cn=0
media_encryption=none
transports=udp
sip_port=$sip_port
guess_hostname=1
inc_timeout=30
in_call_timeout=0
delayed_timeout=4
register_only_when_network_is_up=1
register_only_when_upnp_is_ok=1
default_proxy=0

[proxy_0]
reg_proxy=sip:127.0.0.1:5060;transport=udp
reg_identity="$user" <sip:$user@127.0.0.1>
reg_route=sip:127.0.0.1:5060;transport=udp
reg_expires=3600
reg_sendregister=1
publish=0

[auth_info_0]
username=$user
userid=$user
ha1=$ha1
realm=asterisk
algorithm=MD5

[video]
displaytype=MSOGL
capture=1
display=1
size=vga

[video_codec_0]
mime=VP8
rate=90000
enabled=16

[audio_codec_0]
mime=PCMU
rate=8000
channels=1
enabled=16

[audio_codec_1]
mime=PCMA
rate=8000
channels=1
enabled=16

[rtp]
audio_rtp_port=$artp
video_rtp_port=$vrtp
EOF
    chmod 600 "$confdir/linphonerc"
    echo "  wrote $confdir/linphonerc  ($user, sip port $sip_port)"
}

echo "=== Generating Linphone profiles ==="
gen linphone_app1 visitor pass_visitor 5070 7078 9078
gen linphone_app2 owner   pass_owner   5080 7178 9178
echo "=== Linphone profiles ready ==="
