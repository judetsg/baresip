# Demo Guide — Smart Doorbell (GUI)

Two **Linphone** windows are open on your desktop after `Start all`:

- **Window "visitor"** — the doorbell panel (`sip:visitor@127.0.0.1`, SIP port 5070)
- **Window "owner"** — the phone inside the house (`sip:owner@127.0.0.1`, SIP port 5080)

Both register automatically with the Asterisk container (`doorbell-device`) on
`127.0.0.1:5060`. The green dot next to the account name means "registered".

> The phones do **not** auto-answer — click the green call button to pick up.

---

## Demo 1 — Voice call + call recording

1. In the **visitor** window, click the search bar, type `owner`, press **Enter**.
2. The **owner** window rings and shows **Visitor** as the caller. Click **Answer**.
3. Talk; audio flows both ways. Recording starts automatically.
4. Hang up from either side.
5. Verify the recording:

   ```bash
   docker exec doorbell-device ls -la /var/spool/asterisk/monitor/
   ```
   → a new `.wav` file (PCM 8 kHz mono).

6. **Listen to it** on your speakers:

   ```bash
   ./scripts/play-recording.sh          # play the most recent recording
   ./scripts/play-recording.sh --info   # show codec / duration / size
   ./scripts/play-recording.sh --list   # list recordings
   ./scripts/play-recording.sh <name>.wav
   ```

   In the guided demo (`./demo.sh` → option 4), press **`p`** on step 1 or
   step 8 to play the latest recording.

---

## Demo 2 — IVR (greeting menu)

1. In the **visitor** window, dial `9999` and press Enter (or click the call button).
2. You hear the welcome greeting, then a 5-second pause to choose.
3. Press a digit:
   - **1** → go to voicemail (leave a message for the owner).
   - **2** → ring the owner.
   - **0** → repeat the greeting.
   - no input (5 s) → goodbye and hang up.
   - invalid digit → "invalid" prompt, then repeats (max 3 tries).

---

## Demo 3 — Voicemail (leave + replay)

**Leave a message**

1. From the **visitor** window, dial `9999`, wait for the greeting, press **1**.
2. Voicemail plays its greeting, then records your message after the beep.
3. Speak, then hang up (or wait for the max length).

**Verify the message**

```bash
docker exec doorbell-device find /var/spool/asterisk/voicemail -type f
```
→ a `.wav` under `default/owner/INBOX/`.

**Replay the message**

1. In the **owner** window, dial `*97` and press Enter.
2. Enter the mailbox PIN: **5678** (owner) — visitor's mailbox uses **1234**.
3. Keypad: `1` new messages, `2` old, `3` advanced, `4` folders, `0` options,
   `*` help, `#` exit.

---

## Demo 4 — Call recording + CDR

After any call:

```bash
# Recordings
docker exec doorbell-device ls -la /var/spool/asterisk/monitor/

# CDR log
docker exec doorbell-device cat /var/log/asterisk/cdr-csv/Master.csv

# Inspect a recording
docker cp doorbell-device:/var/spool/asterisk/monitor/<file>.wav /tmp/
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 /tmp/<file>.wav
```

---

## Demo 5 — One-to-one video

Asterisk relays video without transcoding, so both sides must offer a common
codec (**VP8** here).

1. In the **visitor** window, start a call to `owner` (search bar → `owner` → Enter).
2. Before/while ringing, click the **video camera** button in the call window to
   enable video (both windows have `capture=1` / `display=1`).
3. The **owner** answers; click the video button there too if needed.
4. Both windows show the live camera image.

> If the camera does not open, check the camera device in Linphone's
> *Settings → Video*.

---

## Stopping the demo

```bash
./scripts/stop-all.sh          # or menu option 2 in ./demo.sh
```

## Quick reference — dial codes

| Code | Action |
|---|---|
| `owner` | Call the owner (from the visitor window) |
| `visitor` | Call the visitor (from the owner window) |
| `9999` | IVR greeting menu |
| `*43` | Echo test (audio check) |
| `*44` | Playback test |
| `*97` | Check your own voicemail (PIN 5678 for owner, 1234 for visitor) |
| `1` (in IVR) | Leave a voicemail for the owner |
| `2` (in IVR) | Ring the owner |
| `0` (in IVR) | Repeat greeting |
