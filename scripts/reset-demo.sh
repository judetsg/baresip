#!/usr/bin/env bash
# Reset demo: clean recordings, voicemail, CDR, softphone state, restore dialplan.
# Leaves the demo stopped — run "Start all" afterwards.
cd "$(dirname "$0")/.."

echo "=== Resetting demo ==="

# 1. Stop the softphones first so they do not rewrite their databases on exit.
pkill -x linphone 2>/dev/null || true

# 2. Clean Asterisk test data
docker exec doorbell-device sh -c "rm -f /var/spool/asterisk/monitor/*.wav; find /var/spool/asterisk/voicemail -type f -delete; rm -f /var/log/asterisk/cdr-csv/Master.csv" 2>/dev/null || true

# 3. Restore dialplan from backup if exists, otherwise just reload
if [ -f /tmp/opencode/extensions.conf.cli-backup ]; then
    cp /tmp/opencode/extensions.conf.cli-backup configs/extensions.conf
fi

# Remove any leftover test extensions
python3 - <<'PY'
p='configs/extensions.conf'
s=open(p).read()
s=s.replace("exten => 9998,1,VoiceMail(owner,u)\n same => n,Hangup()\n","")
s=s.replace("exten => 9997,1,VoiceMailMain(owner)\n same => n,Hangup()\n","")
open(p,'w').write(s)
PY

docker exec doorbell-device asterisk -rx "dialplan reload" 2>&1 | tail -1

# 4. Regenerate pristine softphone profiles (wipes stale call history)
./scripts/setup-linphone.sh --clean

echo "=== Reset complete ==="
echo "    Run \"Start all\" to relaunch a clean demo."
