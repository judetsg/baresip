# CLI Demo Guide — Smart Doorbell

All features can be tested via the Asterisk CLI without a softphone.

## Prerequisites
```bash
cd /home/miora/Projets/Linux_Embarque
./scripts/start-all.sh   # starts container + Linphone windows
```

## Quick commands

### Check system status
```bash
docker exec doorbell-device asterisk -rx "pjsip show endpoints" | grep -iE 'visitor/|owner/' | grep -v 'Endpoint:'
docker exec doorbell-device asterisk -rx "core show channels" | tail -2
```

### Test IVR (reach + timeout)
```bash
docker exec doorbell-device asterisk -rx "channel originate Local/s@ivr-main application NoOp"
```
→ Plays welcome tone, waits 5s, plays goodbye, hangs up.

### Test echo
```bash
docker exec doorbell-device asterisk -rx "channel originate Local/*43@internal application NoOp"
```

### Test playback
```bash
docker exec doorbell-device asterisk -rx "channel originate Local/*44@internal application NoOp"
```

### Test voice call (visitor → owner)
```bash
docker exec doorbell-device asterisk -rx "channel originate Local/owner@internal application Wait 10"
```
→ Rings owner (auto-answers), holds 10s, records the call.

### Test voicemail (leave a message)
```bash
# Add temporary extension
python3 -c "
p='configs/extensions.conf'; s=open(p).read()
if '9998' not in s:
    s=s.replace('exten => 9999,1,Goto(ivr-main,s,1)\n','exten => 9999,1,Goto(ivr-main,s,1)\nexten => 9998,1,VoiceMail(owner,u)\n same => n,Hangup()\n',1)
    open(p,'w').write(s)
"
docker exec doorbell-device asterisk -rx "dialplan reload"
docker exec doorbell-device asterisk -rx "channel originate Local/9998@internal application Wait 20"
# Clean up
python3 -c "
p='configs/extensions.conf'; s=open(p).read()
s=s.replace('exten => 9998,1,VoiceMail(owner,u)\n same => n,Hangup()\n','')
open(p,'w').write(s)
"
docker exec doorbell-device asterisk -rx "dialplan reload"
```

### Test voicemail replay
```bash
# Add temporary extension
python3 -c "
p='configs/extensions.conf'; s=open(p).read()
if '9997' not in s:
    s=s.replace('exten => 9999,1,Goto(ivr-main,s,1)\n','exten => 9999,1,Goto(ivr-main,s,1)\nexten => 9997,1,VoiceMailMain(owner)\n same => n,Hangup()\n',1)
    open(p,'w').write(s)
"
docker exec doorbell-device asterisk -rx "dialplan reload"
docker exec doorbell-device asterisk -rx "channel originate Local/9997@internal application Wait 10"
# Clean up
python3 -c "
p='configs/extensions.conf'; s=open(p).read()
s=s.replace('exten => 9997,1,VoiceMailMain(owner)\n same => n,Hangup()\n','')
open(p,'w').write(s)
"
docker exec doorbell-device asterisk -rx "dialplan reload"
```

### Verify results
```bash
# Recordings
docker exec doorbell-device ls -la /var/spool/asterisk/monitor/

# Voicemail messages
docker exec doorbell-device find /var/spool/asterisk/voicemail -type f

# CDR log
docker exec doorbell-device cat /var/log/asterisk/cdr-csv/Master.csv

# Inspect a recording
docker cp doorbell-device:/var/spool/asterisk/monitor/<file>.wav /tmp/rec.wav
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 /tmp/rec.wav
```

### Automated demo
```bash
./scripts/cli-demo.sh
```
Runs all tests automatically and reports results.

### IVR DTMF navigation (GUI)
In the Linphone GUI, dial `9999`, then press:
- `1` → leave voicemail for owner
- `2` → ring owner
- `0` → repeat greeting
- (no input 5s) → goodbye + hangup
- (invalid digit) → invalid + repeat (max 3)