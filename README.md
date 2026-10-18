# Smart Doorbell / Intercom (Embedded Asterisk Project)

A lightweight embedded doorbell/intercom built on **Alpine Linux + Asterisk**, fully testable on your laptop with Docker.

## Features
1. **Greeting menu (IVR)** — visitor hears a welcome + keypad menu.
2. **Voicemail** — leave a message if no one answers.
3. **Call recording** — every call saved as a WAV file + CDR log.
4. **Simple one-to-one video** — H264/VP8 relayed by Asterisk (no transcoding).

## Quick start

### Prerequisites
- Docker (with your user in the `docker` group)
- **Linphone** softphone for testing (`sudo apt install linphone-desktop`)

### Run it
The easiest way is the unified menu:

```bash
./demo.sh
```

Options: `1) Start all` · `2) Stop all` · `3) Reset demo` · `4) Guided demo`.

Or drive the scripts directly:

```bash
./scripts/build-image.sh    # build the Asterisk image (first time)
./scripts/start-all.sh      # container + two Linphone windows (visitor, owner)
./scripts/stop-all.sh       # stop everything
./scripts/reset-demo.sh     # wipe recordings/voicemail/CDR + softphone state
```

`start-all.sh` regenerates clean, deterministic Linphone profiles via
`scripts/setup-linphone.sh` so the two windows always come up correctly named
(**visitor** and **owner**) with a single registered SIP account each.

### Test
```bash
./scripts/smoke-test.sh
```

### Make a call
Two Linphone windows open:
- **visitor** — the doorbell panel
- **owner** — the phone inside the house

The phones do **not** auto-answer. In the visitor window, dial `owner` → the
owner window rings and shows **Visitor** as the caller → click Answer.
Dial `9999` for the IVR, `*43` for echo test, `*44` for playback, `*97` for voicemail.

See `docs/demo-guide.md` for the full step-by-step walkthrough (voice, IVR,
voicemail, recording, video).

### Inspect
```bash
docker exec -it doorbell-device asterisk -r                       # Asterisk CLI
docker logs -f doorbell-device                                   # logs
docker exec doorbell-device ls /var/spool/asterisk/monitor       # recordings
docker exec doorbell-device ls /var/spool/asterisk/voicemail/default  # voicemail
```

### Listen to a recording
```bash
./scripts/play-recording.sh          # play the most recent call recording
./scripts/play-recording.sh --info   # show its codec / duration / size
./scripts/play-recording.sh --list   # list all recordings
```

### Record your own greeting
```bash
./scripts/record-greeting.sh 5   # record 5 seconds from mic
# then restart the container
```

### Cleanup old recordings
```bash
./scripts/cleanup-recordings.sh 7   # delete older than 7 days
```

## Project layout
See `PLAN.md` for the full plan and phases.

## Notes
- Video is relayed only (no transcoding). Both sides must use the same codec (VP8 here).
- Voicemail is stored on-device; no email delivery in base setup.
- Container runs as the `asterisk` user (non-root).
