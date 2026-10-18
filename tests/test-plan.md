# Test Plan

## Phase 2 — Base calls
- [ ] Softphone A registers as visitor (status: Registered).
- [ ] Softphone B registers as owner.
- [ ] Call visitor -> owner: audio both ways.
- [ ] Call owner -> visitor: audio both ways.
- [ ] Echo test *43 works.
- [ ] Playback test *44 works.

## Phase 3 — IVR
- [ ] Dial 9999: hear welcome tone.
- [ ] Press 1: routes to voicemail.
- [ ] Press 2: rings owner.
- [ ] Press 0: repeats greeting.
- [ ] Press invalid digit: "invalid" + repeat (max 3 then hangup).
- [ ] No input for 5s: "goodbye" + hangup.

## Phase 4 — Voicemail
- [ ] Leave a message for owner (via busy/unavail or IVR digit 1).
- [ ] Dial *97 as owner: hear message count.
- [ ] Listen, delete, verify empty.
- [ ] PIN (5678) required to access.

## Phase 5 — Recording
- [ ] After a call, a WAV appears in /var/spool/asterisk/monitor.
- [ ] WAV plays back correctly.
- [ ] CDR row present in /var/log/asterisk/cdr-csv/Master.csv.

## Phase 6 — Video
- [ ] Video call visitor <-> owner: picture on both sides.
- [ ] Mixed (voice-only <-> video): falls back to voice.
- [ ] CPU/RAM acceptable during video call.

## Phase 7 — Soak
- [ ] 50 calls in a loop: no zombie channels.
- [ ] No memory growth beyond baseline.
- [ ] No errors in full log.